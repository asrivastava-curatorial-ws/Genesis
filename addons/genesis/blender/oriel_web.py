# Baked light for Oriel's web walkthroughs.
#
# oriel_render.py has built the scene as it does for a Cycles render. Here
# every shape gets a second set of texture coordinates in which no two
# faces overlap (a lightmap layout), the objects are laid out as patches
# on a few large pictures (atlases), and Cycles bakes into them the light
# that falls on each surface: from the sun and the lamps, and what bounces.
# The viewer multiplies a surface's own colour by that light, so nothing has
# to be lit while a visitor walks: a headset's own browser can draw it.
# A bake is noisy where a render would be denoised, so each atlas is cleaned
# with Open Image Denoise (the library Blender carries), or a simple
# edge-keeping blur where that is missing.
#
# What is written into the walkthrough's scene folder:
#   scene.glb          the shapes, each with its lightmap layout as a second UV set
#   lightmaps/lm_N.*   the atlases: light as colour, 8 bits, each with its own range
#   bake.json          which atlas and which patch each object has, and the ranges
#
# The same shape placed many times is still one shape in the file: every
# copy has its own patch, and the layout inside a patch is the shape's own.

import ctypes
import glob
import json
import math
import os
import time

import bpy
import numpy as np

LAYOUT = "oriel_lm"        # the shape's own lightmap layout (0..1), written into scene.glb
TARGET = "oriel_bake"      # where a patch lies in its atlas, for the bake only
NODE = "oriel_bake_target"
PAD = 3                    # pixels kept free round a patch
# Copies of one shape beyond this many share the patches of the first ones.
MAX_COPIES = 24

PRESETS = {
    "Draft": {"density": 10.0, "atlas": 1024, "max_patch": 512, "ground": 1024, "samples": 24, "bounces": 3, "max_atlases": 4},
    "Good": {"density": 20.0, "atlas": 2048, "max_patch": 1024, "ground": 2048, "samples": 96, "bounces": 5, "max_atlases": 6},
    "High": {"density": 40.0, "atlas": 4096, "max_patch": 2048, "ground": 4096, "samples": 384, "bounces": 8, "max_atlases": 6},
}


def _activate(obj):
    for o in bpy.context.selected_objects:
        o.select_set(False)
    obj.select_set(True)
    bpy.context.view_layer.objects.active = obj


def _area(obj):
    me = obj.data
    a = np.zeros(len(me.polygons), dtype=np.float64)
    me.polygons.foreach_get("area", a)
    s = obj.matrix_world.to_scale()
    return float(a.sum()) * (abs(s.x * s.y * s.z) ** (2.0 / 3.0))


def _uv_area(me, layer):
    """How much of the unit square a layout fills."""
    me.calc_loop_triangles()
    n = len(me.loop_triangles)
    if n == 0:
        return 0.0
    loops = np.zeros(n * 3, dtype=np.int32)
    me.loop_triangles.foreach_get("loops", loops)
    uv = np.zeros(len(me.loops) * 2, dtype=np.float64)
    layer.data.foreach_get("uv", uv)
    uv = uv.reshape(-1, 2)[loops].reshape(n, 3, 2)
    e1 = uv[:, 1] - uv[:, 0]
    e2 = uv[:, 2] - uv[:, 0]
    return float(np.abs(e1[:, 0] * e2[:, 1] - e1[:, 1] * e2[:, 0]).sum() * 0.5)


def _ensure_first_uv(me):
    """The lightmap layout must be the second set in the file: a shape without coordinates gets an empty first set."""
    if len(me.uv_layers) == 0:
        me.uv_layers.new(name="UVMap", do_init=False)


def unwrap(obj, margin):
    """Gives the object's mesh its lightmap layout. Returns the share of the unit square it fills."""
    me = obj.data
    _ensure_first_uv(me)
    # A layer made or a mode changed moves the layers in memory: they are asked for again by name each time.
    first = me.uv_layers[0].name
    if me.uv_layers.get(LAYOUT) is None:
        me.uv_layers.new(name=LAYOUT, do_init=False)
    keep_render = [l.name for l in me.uv_layers if l.active_render]
    me.uv_layers.active = me.uv_layers[LAYOUT]
    _activate(obj)
    hidden = obj.hide_viewport, obj.hide_get()
    obj.hide_viewport = False
    obj.hide_set(False)
    bpy.ops.object.mode_set(mode="EDIT")
    bpy.ops.mesh.reveal()
    bpy.ops.mesh.select_all(action="SELECT")
    bpy.ops.uv.smart_project(angle_limit=math.radians(66.0), island_margin=margin, area_weight=0.0, correct_aspect=True, scale_to_bounds=False)
    bpy.ops.object.mode_set(mode="OBJECT")
    obj.hide_viewport = hidden[0]
    obj.hide_set(hidden[1])
    # The materials go on reading the first set.
    me = obj.data
    me.uv_layers.active = me.uv_layers[first]
    for l in me.uv_layers:
        l.active_render = (l.name in keep_render) if keep_render else (l.name == first)
    return max(_uv_area(me, me.uv_layers[LAYOUT]), 1e-6)


def pack(sizes, atlas, pad=PAD):
    """Lays squares of the given sides out on atlases of side `atlas`, tallest first, shelf by shelf.
    Returns [(atlas index, x, y)] in the order given, and how many atlases."""
    order = sorted(range(len(sizes)), key=lambda i: -sizes[i])
    out = [None] * len(sizes)
    k = 0
    x = y = shelf = 0
    for i in order:
        s = sizes[i] + pad * 2
        if x + s > atlas:
            x = 0
            y += shelf
            shelf = 0
        if y + s > atlas:
            k += 1
            x = y = shelf = 0
        out[i] = (k, x + pad, y + pad)
        x += s
        shelf = max(shelf, s)
    return out, k + 1


def _copy_layout(me, rect, atlas):
    """A bake layer: the mesh's own layout moved into its patch of the atlas (Blender's v runs upwards)."""
    if me.uv_layers.get(TARGET) is None:
        me.uv_layers.new(name=TARGET, do_init=False)
    uv = np.zeros(len(me.loops) * 2, dtype=np.float32)
    me.uv_layers[LAYOUT].data.foreach_get("uv", uv)
    uv = uv.reshape(-1, 2)
    x, y, s = rect
    uv = uv * (s / atlas) + np.array([x / atlas, y / atlas], dtype=np.float32)
    me.uv_layers[TARGET].data.foreach_set("uv", uv.ravel())


def _planar(obj, region):
    """The ground's layout: straight down onto the region round the design. Beyond it the viewer holds the edge."""
    me = obj.data
    _ensure_first_uv(me)
    first = me.uv_layers[0].name
    for layer in (LAYOUT, TARGET):
        if me.uv_layers.get(layer) is None:
            me.uv_layers.new(name=layer, do_init=False)
    n = len(me.vertices)
    co = np.zeros(n * 3, dtype=np.float64)
    me.vertices.foreach_get("co", co)
    co = co.reshape(-1, 3)
    m = np.array(obj.matrix_world)
    w = co @ m[:3, :3].T + m[:3, 3]
    li = np.zeros(len(me.loops), dtype=np.int32)
    me.loops.foreach_get("vertex_index", li)
    x0, y0, x1, y1 = region
    # Blender's world: x across, y away. Up the picture is +y.
    uv = np.stack([(w[li, 0] - x0) / (x1 - x0), (w[li, 1] - y0) / (y1 - y0)], axis=1).astype(np.float32)
    me.uv_layers[LAYOUT].data.foreach_set("uv", uv.ravel())
    me.uv_layers[TARGET].data.foreach_set("uv", uv.ravel())
    me.uv_layers.active = me.uv_layers[first]
    for l in me.uv_layers:
        l.active_render = l.name == first


def _target_nodes(objs, image):
    """Every material of these objects gets the picture to bake into, as its active node."""
    for o in objs:
        if len(o.material_slots) == 0 or any(s.material is None for s in o.material_slots):
            mat = bpy.data.materials.get("oriel_plain") or bpy.data.materials.new("oriel_plain")
            mat.use_nodes = True
            if len(o.material_slots) == 0:
                o.data.materials.append(mat)
            for s in o.material_slots:
                if s.material is None:
                    s.material = mat
        for s in o.material_slots:
            mat = s.material
            if not mat.use_nodes:
                mat.use_nodes = True
            nt = mat.node_tree
            node = nt.nodes.get(NODE)
            if node is None:
                node = nt.nodes.new("ShaderNodeTexImage")
                node.name = NODE
            node.image = image
            for n in nt.nodes:
                n.select = False
            node.select = True
            nt.nodes.active = node


def _srgb(x):
    return np.where(x <= 0.0031308, x * 12.92, 1.055 * np.power(np.maximum(x, 0.0031308), 1.0 / 2.4) - 0.055)


def _read(image):
    w, h = image.size
    a = np.zeros(w * h * 4, dtype=np.float32)
    image.pixels.foreach_get(a)
    return a.reshape(h, w, 4)


def _grow(rgb, known, rounds):
    """Spreads baked light a few pixels into the unbaked gaps, so that smoothing a patch's edge finds light, not black."""
    for _ in range(rounds):
        if known.all():
            break
        acc = np.zeros_like(rgb)
        cnt = np.zeros(known.shape, dtype=np.float32)
        for dy, dx in ((0, 1), (0, -1), (1, 0), (-1, 0)):
            k = np.roll(known, (dy, dx), axis=(0, 1))
            c = np.roll(rgb, (dy, dx), axis=(0, 1))
            acc += c * k[..., None]
            cnt += k
        fill = (~known) & (cnt > 0)
        rgb[fill] = acc[fill] / cnt[fill][:, None]
        known = known | fill
    return rgb


def _joined(objs):
    """The objects of one atlas as a single object, standing in for them while they are baked: Cycles
    takes its time over every object it is asked to bake, and a scene of a few hundred is then baked
    in the time of one. Each keeps its own patch (its bake layer) and its own materials."""
    twins = []
    for o in objs:
        t = o.copy()
        t.data = o.data.copy()
        me = t.data
        # The join lines layers up by name: every mesh's own first layer under one name.
        if len(me.uv_layers) and me.uv_layers[0].name not in ("UVMap", LAYOUT, TARGET) and me.uv_layers.get("UVMap") is None:
            me.uv_layers[0].name = "UVMap"
        bpy.context.scene.collection.objects.link(t)
        t.hide_render = False
        t.hide_viewport = False
        twins.append(t)
        o.hide_render = True
    for o in bpy.context.selected_objects:
        o.select_set(False)
    for t in twins:
        t.hide_set(False)
        t.select_set(True)
    bpy.context.view_layer.objects.active = twins[0]
    bpy.ops.object.join()
    return bpy.context.view_layer.objects.active


def _oidn_library():
    """Open Image Denoise as Blender itself carries it (beside the program, or beside the bpy module), or ""."""
    starts = []
    if getattr(bpy, "__file__", None):
        starts.append(os.path.dirname(bpy.__file__))
    if bpy.app.binary_path:
        starts.append(os.path.dirname(bpy.app.binary_path))
    pats = ("lib/libOpenImageDenoise.so*", "libOpenImageDenoise.so*", "lib/libOpenImageDenoise*.dylib", "libOpenImageDenoise*.dylib",
            "OpenImageDenoise.dll", "blender.shared/OpenImageDenoise.dll", "Resources/lib/libOpenImageDenoise*.dylib")
    for start in starts:
        d = start
        for _ in range(7):
            for pat in pats:
                hits = sorted(h for h in glob.glob(os.path.join(d, pat)) if "_core" not in h and "_device" not in h)
                if hits:
                    return hits[0]
            up = os.path.dirname(d)
            if up == d:
                break
            d = up
    return ""


def _oidn(rgb):
    """The picture with its sampling noise taken out by Open Image Denoise (version 2's C interface), or None."""
    path = _oidn_library()
    if not path:
        return None
    try:
        lib = ctypes.CDLL(path)
        P = ctypes.c_void_p
        lib.oidnNewDevice.restype = P
        lib.oidnNewDevice.argtypes = [ctypes.c_int]
        lib.oidnCommitDevice.argtypes = [P]
        lib.oidnNewFilter.restype = P
        lib.oidnNewFilter.argtypes = [P, ctypes.c_char_p]
        lib.oidnSetSharedFilterImage.argtypes = [P, ctypes.c_char_p, P, ctypes.c_int] + [ctypes.c_size_t] * 5
        lib.oidnSetFilterBool.argtypes = [P, ctypes.c_char_p, ctypes.c_bool]
        lib.oidnCommitFilter.argtypes = [P]
        lib.oidnExecuteFilter.argtypes = [P]
        lib.oidnGetDeviceError.restype = ctypes.c_int
        lib.oidnGetDeviceError.argtypes = [P, ctypes.POINTER(ctypes.c_char_p)]
        lib.oidnReleaseFilter.argtypes = [P]
        lib.oidnReleaseDevice.argtypes = [P]
    except (OSError, AttributeError):
        return None
    dev = lib.oidnNewDevice(1)        # the processor: a lightmap is small, and it is always there
    if not dev:
        return None
    lib.oidnCommitDevice(dev)
    h, w, _ = rgb.shape
    src = np.ascontiguousarray(rgb, dtype=np.float32)
    dst = np.zeros_like(src)
    flt = lib.oidnNewFilter(dev, b"RT")
    FLOAT3 = 3
    lib.oidnSetSharedFilterImage(flt, b"color", src.ctypes.data_as(P), FLOAT3, w, h, 0, 0, 0)
    lib.oidnSetSharedFilterImage(flt, b"output", dst.ctypes.data_as(P), FLOAT3, w, h, 0, 0, 0)
    lib.oidnSetFilterBool(flt, b"hdr", True)
    lib.oidnCommitFilter(flt)
    lib.oidnExecuteFilter(flt)
    msg = ctypes.c_char_p()
    err = lib.oidnGetDeviceError(dev, ctypes.byref(msg))
    lib.oidnReleaseFilter(flt)
    lib.oidnReleaseDevice(dev)
    if err != 0 or not np.isfinite(dst).all():
        return None
    return dst


def _smooth(rgb, known, rounds=3):
    """Without the denoiser: a blur that stops at edges of brightness (three widening passes)."""
    out = rgb.copy()
    for r in range(rounds):
        step = 1 << r
        lum = out @ np.array([0.2126, 0.7152, 0.0722], dtype=np.float32)
        acc = out.copy()
        wsum = np.ones(lum.shape, dtype=np.float32)
        for dy in (-step, 0, step):
            for dx in (-step, 0, step):
                if dy == 0 and dx == 0:
                    continue
                c = np.roll(out, (dy, dx), axis=(0, 1))
                l2 = np.roll(lum, (dy, dx), axis=(0, 1))
                k = np.roll(known, (dy, dx), axis=(0, 1))
                wgt = np.exp(-np.abs(l2 - lum) / (0.25 * np.maximum(lum, l2) + 0.02)).astype(np.float32) * k
                acc += c * wgt[..., None]
                wsum += wgt
        out = acc / wsum[..., None]
    return out


def _save(path, rgb8, scene):
    """An 8-bit picture as a JPEG (lightmaps compress well, and a browser reads nothing faster)."""
    h, w, _ = rgb8.shape
    img = bpy.data.images.new("oriel_lm_out", w, h, alpha=False)
    img.colorspace_settings.name = "sRGB"
    px = np.ones((h, w, 4), dtype=np.float32)
    px[..., :3] = rgb8.astype(np.float32) / 255.0
    img.pixels.foreach_set(px.ravel())
    img.filepath_raw = path
    img.file_format = "JPEG"
    try:
        img.save(filepath=path, quality=95)
    except TypeError:
        img.save()
    bpy.data.images.remove(img)


def run(G, r):
    """G is oriel_render's own names (its scene, its objects, its status); r the job's "web" entry."""
    t0 = time.time()
    log, STATUS, SCENE, OBJECTS = G["log"], G["STATUS"], G["SCENE"], G["OBJECTS"]
    out = r["out"]
    os.makedirs(os.path.join(out, "lightmaps"), exist_ok=True)
    q = dict(PRESETS.get(r.get("quality", "Good"), PRESETS["Good"]))
    q.update(r.get("bake", {}))
    sc = bpy.context.scene
    specs = SCENE.get("objects", {})
    mats = SCENE.get("materials", {})

    glass = set(r.get("see_through", []))

    def see_through(o):
        """Glass and water take no baked light: what shows in them is what is behind them and the sky."""
        names = [s.material.name for s in o.material_slots if s.material]
        return bool(names) and all(n in glass or mats.get(n, {}).get("kind") == "water" for n in names)

    # ---------------------------------------------------------------- which objects, and how large their patches
    STATUS.set(stage="web", message="Laying out the lightmaps", progress=0.06)
    bounds = SCENE.get("bounds") or [-20, 0, -20, 20, 6, 20]
    # Godot's (x, y up, z) is Blender's (x, -z, y up).
    bx0, bx1 = bounds[0], bounds[3]
    by0, by1 = -bounds[5], -bounds[2]
    grow = max((bx1 - bx0) * 0.25, (by1 - by0) * 0.25, (bounds[4] - bounds[1]) * 2.5, 6.0)
    region = (bx0 - grow, by0 - grow, bx1 + grow, by1 + grow)
    side = max(region[2] - region[0], region[3] - region[1])
    region = (region[0], region[1], region[0] + side, region[1] + side)
    footprint = max((bx1 - bx0) * (by1 - by0), 1.0)

    baked, grounds, skipped = [], [], 0
    for name, spec in specs.items():
        o = OBJECTS.get(name)
        if o is None or o.type != "MESH" or o.data is None or len(o.data.polygons) == 0:
            continue
        if spec.get("base") or spec.get("hidden") or spec.get("shadow_only") or spec.get("camera_only"):
            continue
        if see_through(o):
            skipped += 1
            continue
        area = _area(o)
        if area <= 1e-6:
            continue
        if spec.get("ground") or area > footprint * 6.0:
            grounds.append((name, o))
        else:
            baked.append([name, o, area])
    log("web: %d objects to bake, %d grounds, %d see-through left out" % (len(baked), len(grounds), skipped))

    # One layout per shape, however many times it stands in the scene.
    by_mesh = {}
    for item in baked:
        by_mesh.setdefault(item[1].data.name, []).append(item)
    fill = {}
    done = 0
    for mesh_name, items in by_mesh.items():
        o = items[0][1]
        biggest = max(i[2] for i in items)
        guess = max(q["density"] * math.sqrt(biggest / 0.55), 16.0)
        fill[mesh_name] = unwrap(o, min(max(2.0 / guess, 0.003), 0.04))
        done += 1
        if done % 20 == 0:
            STATUS.set(message="Laying out the lightmaps (%d of %d shapes)" % (done, len(by_mesh)), progress=0.06 + 0.1 * done / len(by_mesh))

    # Copies beyond the first few share those few's patches.
    own, shared = [], {}
    for mesh_name, items in by_mesh.items():
        for k, item in enumerate(items):
            if k < MAX_COPIES:
                own.append(item)
            else:
                shared[item[0]] = items[k % MAX_COPIES][0]

    def sizes_at(scale):
        out_ = []
        for name, o, area in own:
            s = q["density"] * scale * math.sqrt(area / fill[o.data.name])
            out_.append(int(min(max(round(s), 8), q["max_patch"])))
        return out_

    scale = 1.0
    while True:
        sizes = sizes_at(scale)
        places, n_atlas = pack(sizes, q["atlas"])
        if n_atlas <= q["max_atlases"] or scale < 0.12:
            break
        scale *= 0.85
    if scale < 1.0:
        log("web: lightmaps made %.0f%% as fine, to fit %d atlases" % (scale * 100.0, q["max_atlases"]))

    # ---------------------------------------------------------------- the bake
    sc.render.engine = "CYCLES"
    sc.cycles.samples = int(q["samples"])
    sc.cycles.max_bounces = int(q["bounces"])
    sc.cycles.diffuse_bounces = int(q["bounces"])
    try:
        sc.cycles.use_denoising = True
    except Exception:
        pass
    # One scene for every object of an atlas, not one built afresh for each.
    try:
        sc.render.use_persistent_data = True
    except Exception:
        pass
    bake = sc.render.bake
    bake.use_pass_direct = True
    bake.use_pass_indirect = True
    bake.use_pass_color = False
    bake.use_selected_to_active = False
    bake.target = "IMAGE_TEXTURES"
    bake.margin = 4
    try:
        bake.margin_type = "EXTEND"
    except Exception:
        pass
    bake.use_clear = False

    temp_meshes = []
    restore = []
    images = []
    for k in range(n_atlas):
        img = bpy.data.images.new("oriel_atlas_%d" % k, q["atlas"], q["atlas"], alpha=True, float_buffer=True)
        img.colorspace_settings.name = "Non-Color"
        img.generated_color = (0.0, 0.0, 0.0, 0.0)
        images.append(img)
    groups = [[] for _ in range(n_atlas)]
    seen = set()
    for (name, o, area), size, (k, x, y) in zip(own, sizes, places):
        me = o.data
        if me.name in seen:
            # A copy: for the bake it needs coordinates of its own.
            mine = me.copy()
            temp_meshes.append(mine)
            restore.append((o, me))
            o.data = mine
            me = mine
        else:
            seen.add(me.name)
        _copy_layout(me, (x, y, size), q["atlas"])
        groups[k].append((name, o, (x, y, size)))

    result = {"atlases": [], "objects": {}}
    total = n_atlas + len(grounds)
    step = 0
    lum_ref = []
    patches = []

    def bake_into(objs, image, label):
        nonlocal step
        STATUS.set(stage="web", message="Baking the light: %s (%d of %d)" % (label, step + 1, total), progress=0.18 + 0.7 * step / max(total, 1))
        _target_nodes(objs, image)
        t = time.time()
        one = _joined(objs) if len(objs) > 1 and q.get("joined", True) else None
        try:
            for o in bpy.context.selected_objects:
                o.select_set(False)
            for o in ([one] if one else objs):
                o.select_set(True)
            bpy.context.view_layer.objects.active = one or objs[0]
            bpy.ops.object.bake(type="DIFFUSE", pass_filter={"DIRECT", "INDIRECT"}, margin=4, use_clear=False, uv_layer=TARGET)
        finally:
            if one:
                me = one.data
                bpy.data.objects.remove(one)
                bpy.data.meshes.remove(me)
                for o in objs:
                    o.hide_render = False
        log("web: baked %s (%d objects%s) in %.1f s" % (label, len(objs), " as one" if one else "", time.time() - t))
        step += 1

    noted = []

    def finish(image, index, file):
        px = _read(image)
        rgb = np.nan_to_num(px[..., :3].astype(np.float32), nan=0.0, posinf=64.0, neginf=0.0)
        rgb = np.maximum(rgb, 0.0)
        known = px[..., 3] > 0.5
        # Baked light is noisy, patch by patch. The gaps are filled first, so
        # that cleaning finds light on both sides of a patch's edge.
        rgb = _grow(rgb, known.copy(), 8)
        if q.get("denoise", True):
            clean = _oidn(rgb)
            if clean is None:
                if not noted:
                    log("web: no Open Image Denoise with this Blender; the light is smoothed more simply")
                    noted.append(1)
                clean = _smooth(rgb, known)
            rgb = np.maximum(clean, 0.0)
        lum = rgb @ np.array([0.2126, 0.7152, 0.0722], dtype=np.float32)
        lit = lum[known]
        rng = float(max(np.percentile(lit, 99.8) * 1.1, 0.02)) if lit.size else 1.0
        enc = np.clip(_srgb(np.clip(rgb / rng, 0.0, 1.0)) * 255.0 + 0.5, 0, 255).astype(np.uint8)
        _save(os.path.join(out, "lightmaps", file), enc, sc)
        result["atlases"].append({"file": "lightmaps/" + file, "range": rng, "size": image.size[0]})
        return lum, known

    for k in range(n_atlas):
        objs = [g[1] for g in groups[k]]
        if not objs:
            result["atlases"].append({"file": "", "range": 1.0, "size": q["atlas"]})
            continue
        bake_into(objs, images[k], "atlas %d" % (k + 1))
        lum, known = finish(images[k], k, "lm_%d.jpg" % k)
        A = float(q["atlas"])
        for name, o, (x, y, s) in groups[k]:
            # In the file's own coordinates v runs downwards.
            rect = [x / A, 1.0 - (y + s) / A, s / A, s / A]
            sub = lum[y:y + s, x:x + s]
            ok = known[y:y + s, x:x + s]
            mean = float(sub[ok].mean()) if ok.any() else 0.0
            patches.append((name, mean))
            result["objects"][name] = {"atlas": k, "rect": rect}
            if ok.any():
                lum_ref.append(mean)

    # The ground: a picture of its own, laid straight down over the design and round it.
    for name, o in grounds:
        _planar(o, region)
        img = bpy.data.images.new("oriel_ground_%s" % name, q["ground"], q["ground"], alpha=True, float_buffer=True)
        img.colorspace_settings.name = "Non-Color"
        img.generated_color = (0.0, 0.0, 0.0, 0.0)
        bake_into([o], img, "the ground")
        index = len(result["atlases"])
        lum, known = finish(img, index, "lm_%d.jpg" % index)
        # The layout was made in Blender's sense (v up the picture); the file's runs down.
        result["objects"][name] = {"atlas": index, "rect": [0.0, 0.0, 1.0, 1.0], "ground": True}
        if known.any():
            lum_ref.append(float(np.percentile(lum[known], 90)))
            patches.append((name, float(lum[known].mean())))
        bpy.data.images.remove(img)

    # How brightly the sky may shine in a surface: as brightly as light reaches it. A room's floor mirrors the room, not the open sky.
    ref = float(np.percentile(np.array(lum_ref), 90)) if lum_ref else 1.0
    for name, mean in patches:
        result["objects"][name]["env"] = round(float(min(max(mean / max(ref, 1e-4), 0.03), 1.0)), 3)
    for name, first in shared.items():
        if first in result["objects"]:
            result["objects"][name] = dict(result["objects"][first])

    # ---------------------------------------------------------------- the shapes, with their layouts
    STATUS.set(stage="web", message="Writing the shapes", progress=0.92)
    for o, me in restore:
        o.data = me
    for me in temp_meshes:
        bpy.data.meshes.remove(me)
    for me in bpy.data.meshes:
        if me.uv_layers.get(TARGET) is not None:
            me.uv_layers.remove(me.uv_layers[TARGET])
    for img in images:
        bpy.data.images.remove(img)
    uv_index = {}
    for o in bpy.context.selected_objects:
        o.select_set(False)
    picked = 0
    for name, spec in specs.items():
        o = OBJECTS.get(name)
        if o is None or o.type != "MESH" or spec.get("copy_of"):
            continue
        o.hide_viewport = False
        o.hide_set(False)
        o.select_set(True)
        picked += 1
        names = [l.name for l in o.data.uv_layers]
        if LAYOUT in names:
            uv_index[name] = names.index(LAYOUT)
    for name, entry in result["objects"].items():
        src = specs.get(name, {}).get("copy_of") or name
        if uv_index.get(src, 1) != 1:
            entry["uv"] = uv_index[src]
    if picked:
        bpy.context.view_layer.objects.active = bpy.context.selected_objects[0]
    kw = dict(filepath=os.path.join(out, "scene.glb"), export_format="GLB", use_selection=True, export_apply=False, export_texcoords=True,
              export_normals=True, export_tangents=False, export_materials="EXPORT", export_image_format="NONE", export_yup=True, export_animations=False,
              export_skins=False, export_morph=False, export_lights=False, export_cameras=False, export_extras=False)
    try:
        bpy.ops.export_scene.gltf(export_vertex_color="ACTIVE", export_all_vertex_colors=False, **kw)
    except TypeError:
        bpy.ops.export_scene.gltf(**kw)
    result["seconds"] = round(time.time() - t0, 1)
    result["quality"] = r.get("quality", "Good")
    with open(os.path.join(out, "bake.json"), "w", encoding="utf-8") as f:
        json.dump(result, f)
    log("web: %d atlases, %d objects with baked light, in %.0f s" % (len(result["atlases"]), len(result["objects"]), time.time() - t0))
    return result
