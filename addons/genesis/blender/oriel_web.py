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
VLIGHT = "oriel_light"     # baked light at the corners of a finely made shape, written into scene.glb as its colours
SOURCE = "oriel_src"       # which object a vertex of the joined stand-in came from
# A shape whose triangles are no larger than this many texels is lit at its
# corners: a lightmap could show nothing finer, and such a shape (a radiator,
# a sofa, a plant) unwraps badly. Less than SHARE of its surface may lie in
# larger triangles.
VERTEX_TEXELS = 4.0
VERTEX_SHARE = 0.15
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


def _big_share(obj, density):
    """How much of the object's surface lies in triangles too large to be lit at their corners alone."""
    me = obj.data
    a = np.zeros(len(me.polygons), dtype=np.float64)
    me.polygons.foreach_get("area", a)
    s = obj.matrix_world.to_scale()
    a *= abs(s.x * s.y * s.z) ** (2.0 / 3.0)
    total = float(a.sum())
    if total <= 0.0:
        return 1.0
    return float(a[a > VERTEX_TEXELS / (density * density)].sum()) / total


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
    # (Not "correct aspect": that follows the material's picture, and a palette of colours
    # 64 pixels by 4 would press the whole layout into a sliver.)
    bpy.ops.uv.smart_project(angle_limit=math.radians(66.0), island_margin=margin, area_weight=0.0, correct_aspect=False, scale_to_bounds=False)
    bpy.ops.object.mode_set(mode="OBJECT")
    me = obj.data
    fill = _uv_area(me, me.uv_layers[LAYOUT])
    if fill < 0.25 and len(me.polygons) <= 20000:
        # Rings and long strips (a cornice round a room) leave the square nearly empty when packed
        # as boxes: packed by their true outlines they nest. Kept only if it is the better layout.
        n = len(me.loops) * 2
        before = np.zeros(n, dtype=np.float32)
        me.uv_layers[LAYOUT].data.foreach_get("uv", before)
        try:
            bpy.ops.object.mode_set(mode="EDIT")
            bpy.ops.mesh.select_all(action="SELECT")
            bpy.ops.uv.select_all(action="SELECT")
            bpy.ops.uv.pack_islands(shape_method="CONCAVE", rotate=True, margin=margin)
        except Exception:
            pass
        finally:
            bpy.ops.object.mode_set(mode="OBJECT")
        me = obj.data
        again = _uv_area(me, me.uv_layers[LAYOUT])
        if again > fill * 1.1:
            fill = again
        else:
            me.uv_layers[LAYOUT].data.foreach_set("uv", before)
    obj.hide_viewport = hidden[0]
    obj.hide_set(hidden[1])
    # The materials go on reading the first set.
    me = obj.data
    me.uv_layers.active = me.uv_layers[first]
    for l in me.uv_layers:
        l.active_render = (l.name in keep_render) if keep_render else (l.name == first)
    return max(fill, 1e-6)


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


def _turn_faces(obj):
    """Turns every face of the object round (its other side becomes its front)."""
    _activate(obj)
    bpy.ops.object.mode_set(mode="EDIT")
    bpy.ops.mesh.reveal()
    bpy.ops.mesh.select_all(action="SELECT")
    bpy.ops.mesh.flip_normals()
    bpy.ops.object.mode_set(mode="OBJECT")


def _joined(objs, flip=False):
    """The objects of one atlas as a single object, standing in for them while they are baked: Cycles
    takes its time over every object it is asked to bake, and a scene of a few hundred is then baked
    in the time of one. Each keeps its own patch (its bake layer) and its own materials.
    `flip`: with every face turned round, to bake the light on the other side."""
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
    if len(twins) > 1:
        bpy.ops.object.join()
    one = bpy.context.view_layer.objects.active
    if flip:
        _turn_faces(one)
    return one


def _bake_corners(objs, scene, q, flip=False):
    """Bakes the light at every vertex of these objects (as one joined stand-in) and returns it, object
    by object: an array of (r, g, b) per vertex, in the mesh's own order, as baked.
    `flip`: the light on the other side of every face."""
    twins = []
    for k, o in enumerate(objs):
        t = o.copy()
        t.data = o.data.copy()
        me = t.data
        while len(me.color_attributes):
            me.color_attributes.remove(me.color_attributes[0])
        me.color_attributes.new(VLIGHT, "FLOAT_COLOR", "POINT")
        if me.attributes.get(SOURCE) is None:
            me.attributes.new(SOURCE, "INT", "POINT")
        me.attributes[SOURCE].data.foreach_set("value", np.full(len(me.vertices), k, dtype=np.int32))
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
    if len(twins) > 1:
        bpy.ops.object.join()
    one = bpy.context.view_layer.objects.active
    if flip:
        _turn_faces(one)
    me = one.data
    me.color_attributes.active_color = me.color_attributes[VLIGHT]
    samples = scene.cycles.samples
    out = [np.zeros((0, 3), dtype=np.float32) for _ in objs]
    try:
        # Every corner of every triangle is sampled, and some six corners meet at a vertex;
        # neighbours then even one another out. An eighth of the samples each is plenty.
        scene.cycles.samples = max(int(samples // 8), 4)
        scene.render.bake.target = "VERTEX_COLORS"
        bpy.ops.object.bake(type="DIFFUSE", pass_filter={"DIRECT", "INDIRECT"}, target="VERTEX_COLORS")
        me = one.data
        n = len(me.vertices)
        col = np.zeros(n * 4, dtype=np.float32)
        me.color_attributes[VLIGHT].data.foreach_get("color", col)
        rgb = np.maximum(np.nan_to_num(col.reshape(n, 4)[:, :3], nan=0.0, posinf=64.0, neginf=0.0), 0.0)
        src = np.zeros(n, dtype=np.int32)
        me.attributes[SOURCE].data.foreach_get("value", src)
        for k in range(len(objs)):
            out[k] = rgb[src == k]
    finally:
        scene.cycles.samples = samples
        scene.render.bake.target = "IMAGE_TEXTURES"
        me = one.data
        bpy.data.objects.remove(one)
        bpy.data.meshes.remove(me)
        for o in objs:
            o.hide_render = False
    return out


def _settle_corners(me, rgb):
    """Baked light at a mesh's vertices, tidied: vertices that are one point of the surface (split only
    for a seam in a picture) get one light, and each leans towards its neighbours across smooth surface."""
    n = len(me.vertices)
    if n == 0 or len(rgb) != n:
        return rgb
    co = np.zeros(n * 3, dtype=np.float32)
    me.vertices.foreach_get("co", co)
    nor = np.zeros(n * 3, dtype=np.float32)
    try:
        me.vertex_normals.foreach_get("vector", nor)
    except Exception:
        me.vertices.foreach_get("normal", nor)
    co = co.reshape(n, 3)
    nor = nor.reshape(n, 3)
    span = float(np.ptp(co, axis=0).max()) or 1.0
    key = np.concatenate([np.round(co * (20000.0 / span)), np.round(nor * 8.0)], axis=1)
    _, inverse, counts = np.unique(key, axis=0, return_inverse=True, return_counts=True)
    inverse = inverse.ravel()
    summed = np.zeros((len(counts), 3), dtype=np.float64)
    np.add.at(summed, inverse, rgb)
    rgb = (summed / counts[:, None])[inverse].astype(np.float32)
    e = np.zeros(len(me.edges) * 2, dtype=np.int32)
    me.edges.foreach_get("vertices", e)
    e = e.reshape(-1, 2)
    if len(e):
        # A vertex no light reaches at all is one buried in a neighbour (a sofa's arm in its
        # seat): it takes its lit neighbours' light, or a dark seam would show where they meet.
        weights = np.array([0.2126, 0.7152, 0.0722], dtype=np.float32)
        for _ in range(4):
            unlit = (rgb @ weights) <= 1e-7
            if not unlit.any() or unlit.all():
                break
            lit = (~unlit).astype(np.float64)
            acc = np.zeros((n, 3), dtype=np.float64)
            cnt = np.zeros(n, dtype=np.float64)
            np.add.at(acc, e[:, 0], rgb[e[:, 1]] * lit[e[:, 1]][:, None])
            np.add.at(acc, e[:, 1], rgb[e[:, 0]] * lit[e[:, 0]][:, None])
            np.add.at(cnt, e[:, 0], lit[e[:, 1]])
            np.add.at(cnt, e[:, 1], lit[e[:, 0]])
            fill = unlit & (cnt > 0)
            rgb[fill] = (acc[fill] / cnt[fill][:, None]).astype(np.float32)
        smooth = (nor[e[:, 0]] * nor[e[:, 1]]).sum(axis=1) > 0.8
        a, b = e[smooth, 0], e[smooth, 1]
        for _ in range(4):
            acc = np.zeros((n, 3), dtype=np.float64)
            cnt = np.zeros(n, dtype=np.float64)
            np.add.at(acc, a, rgb[b])
            np.add.at(acc, b, rgb[a])
            np.add.at(cnt, a, 1.0)
            np.add.at(cnt, b, 1.0)
            has = cnt > 0
            rgb[has] = (0.5 * rgb[has] + 0.5 * (acc[has] / cnt[has][:, None])).astype(np.float32)
    return rgb


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
    # Finely made shapes are lit at their corners (no layout, no patch): those
    # that stand once in the scene and whose colours are not already in use.
    fine = []
    if q.get("vertex", True):
        users = {}
        for name, o, area in baked:
            users[o.data.name] = users.get(o.data.name, 0) + 1

        def own_colours(o):
            return any(s.material and mats.get(s.material.name, {}).get("vcol") for s in o.material_slots)

        rest = []
        for item in baked:
            name, o, area = item
            if users[o.data.name] == 1 and len(o.data.vertices) >= 24 and not own_colours(o) and _big_share(o, q["density"]) < VERTEX_SHARE:
                fine.append((name, o))
            else:
                rest.append(item)
        baked = rest
    log("web: %d objects to bake into lightmaps, %d lit at their corners, %d grounds, %d see-through left out" % (len(baked), len(fine), len(grounds), skipped))

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
            out_.append(int(min(max(round(s), 8), q["max_patch"] - 2 * PAD)))
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
    total = n_atlas + len(grounds) + (1 if fine else 0)
    step = 0
    lum_ref = []
    patches = []

    def bake_into(objs, image, label, flip=False):
        nonlocal step
        STATUS.set(stage="web", message="Baking the light: %s (%d of %d)" % (label, min(step + 1, total), total), progress=0.18 + 0.7 * min(step, total) / max(total, 1))
        _target_nodes(objs, image)
        t = time.time()
        one = _joined(objs, flip) if flip or (len(objs) > 1 and q.get("joined", True)) else None
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
        if not flip:
            step += 1

    noted = []
    UNLIT = 1e-7

    def _other_side(image, group, label):
        """Faces modelled inside out (and shown from both sides, so that nobody noticed) are baked on
        the side that faces into the object, where no light comes. Objects with a share of such
        texels are baked again with their faces turned, and those texels take that light."""
        px = _read(image)
        lum0 = px[..., :3] @ np.array([0.2126, 0.7152, 0.0722], dtype=np.float32)
        known0 = px[..., 3] > 0.5
        dark = []
        for name, o, (x, y, sz) in group:
            ok = known0[y:y + sz, x:x + sz]
            if ok.any() and float((lum0[y:y + sz, x:x + sz][ok] <= UNLIT).mean()) > 0.03:
                dark.append(o)
        if not dark:
            return
        w, h = image.size
        back = bpy.data.images.new("oriel_back", w, h, alpha=True, float_buffer=True)
        back.colorspace_settings.name = "Non-Color"
        back.generated_color = (0.0, 0.0, 0.0, 0.0)
        bake_into(dark, back, "%s, faces turned" % label, flip=True)
        px2 = _read(back)
        use = known0 & (lum0 <= UNLIT) & (px2[..., 3] > 0.5)
        px[use, :3] = px2[use, :3]
        image.pixels.foreach_set(px.ravel())
        bpy.data.images.remove(back)
        log("web: %d objects of %s have faces inside out: %d texels lit from their other side" % (len(dark), label, int(use.sum())))

    def finish(image, index, file):
        px = _read(image)
        rgb = np.nan_to_num(px[..., :3].astype(np.float32), nan=0.0, posinf=64.0, neginf=0.0)
        rgb = np.maximum(rgb, 0.0)
        known = px[..., 3] > 0.5
        # A texel no light reaches at all lies on a face pressed against another (the back of a
        # skirting board): nobody sees it, but its black would run into its neighbours. It counts as a gap.
        lit = known & ((rgb @ np.array([0.2126, 0.7152, 0.0722], dtype=np.float32)) > UNLIT)
        if lit.any():
            known = lit
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
        _other_side(images[k], groups[k], "atlas %d" % (k + 1))
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

    # Finely made shapes: light at their corners, all of them baked as one object.
    if fine:
        STATUS.set(stage="web", message="Baking the light: furniture and fittings", progress=0.18 + 0.7 * step / max(total, 1))
        t = time.time()
        lights = _bake_corners([o for _, o in fine], sc, q)
        # Shapes modelled inside out: the light on the other side of their faces, where the first found none.
        weights = np.array([0.2126, 0.7152, 0.0722], dtype=np.float32)
        turned = [k for k, v in enumerate(lights) if len(v) and float(((v @ weights) <= UNLIT).mean()) > 0.03]
        if turned:
            backs = _bake_corners([fine[k][1] for k in turned], sc, q, flip=True)
            for k, back in zip(turned, backs):
                if len(back) == len(lights[k]):
                    unlit = (lights[k] @ weights) <= UNLIT
                    lights[k][unlit] = back[unlit]
            log("web: %d finely made objects have faces inside out: lit from their other side" % len(turned))
        lights = [_settle_corners(o.data, v) for (_, o), v in zip(fine, lights)]
        both = np.concatenate([v for v in lights if len(v)]) if any(len(v) for v in lights) else np.zeros((1, 3), dtype=np.float32)
        lum_all = both @ np.array([0.2126, 0.7152, 0.0722], dtype=np.float32)
        vrange = float(max(np.percentile(lum_all, 99.8) * 1.1, 0.02))
        result["vertex_range"] = vrange
        for (name, o), rgb in zip(fine, lights):
            me = o.data
            while len(me.color_attributes):
                me.color_attributes.remove(me.color_attributes[0])
            col = me.color_attributes.new(VLIGHT, "FLOAT_COLOR", "POINT")
            px = np.ones((len(me.vertices), 4), dtype=np.float32)
            if len(rgb) == len(me.vertices):
                # The square root keeps the dark end fine in sixteen bits.
                px[:, :3] = np.sqrt(np.clip(rgb / vrange, 0.0, 1.0))
            me.color_attributes[VLIGHT].data.foreach_set("color", px.ravel())
            me.color_attributes.active_color = me.color_attributes[VLIGHT]
            try:
                me.color_attributes.render_color_index = 0
            except Exception:
                pass
            mean = float((rgb @ np.array([0.2126, 0.7152, 0.0722], dtype=np.float32)).mean()) if len(rgb) else 0.0
            patches.append((name, mean))
            result["objects"][name] = {"vertex": True}
            if len(rgb):
                lum_ref.append(mean)
        log("web: baked %d objects at their corners in %.1f s" % (len(fine), time.time() - t))
        step += 1

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
