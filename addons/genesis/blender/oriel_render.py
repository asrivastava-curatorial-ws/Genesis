"""Oriel's render bridge: Blender's Eevee and Cycles behind Oriel's own window.

Oriel writes the scene as a glTF file (scene.glb) and a job file (job.json)
that says everything glTF cannot: lights in the units Oriel's editor shows
them, the sky, fog, exposure, cameras and what to render. This script runs
inside Blender, in the background, and is never shown:

    blender -b --factory-startup --python oriel_render.py -- job.json
    python oriel_render.py -- job.json          (Blender as a Python module)

It builds the scene, renders each request to a floating-point EXR, and then
does the finishing that Oriel's editor does on screen (distance fog, glow,
exposure and the same tone curve) itself, in numpy, so a picture from Eevee
or Cycles is graded like the editor's view of the same camera. The result is
an 8-bit PNG per request; Oriel adds its own look (grading, titles, logos)
afterwards, exactly as it does for its own renders.

Progress goes to status.json beside the job (written atomically), so Oriel
can show it and the work survives being stopped: a film that is stopped
resumes at the first missing frame.

Blender 4.0 or newer. Tested with 4.0, 4.5 LTS and 5.2 LTS.
Part of Oriel, MIT licence.
"""

import json
import math
import os
import re
import struct
import sys
import time
import traceback
import zlib

import bpy
import numpy as np
from mathutils import Matrix, Vector

SCHEMA = "oriel-job/1"
BV = bpy.app.version

# --------------------------------------------------------------------------
# The job, the log and the status file
# --------------------------------------------------------------------------


def _job_path():
    argv = sys.argv
    rest = argv[argv.index("--") + 1:] if "--" in argv else argv[1:]
    for a in rest:
        if a.endswith(".json"):
            return a
    raise SystemExit("oriel_render: no job file given (… -- job.json)")


JOB_PATH = os.path.abspath(_job_path())
JOB_DIR = os.path.dirname(JOB_PATH)
with open(JOB_PATH, "r", encoding="utf-8") as _f:
    JOB = json.load(_f)


def _abs(p):
    if not p:
        return p
    return p if os.path.isabs(p) else os.path.join(JOB_DIR, p)


STATUS_PATH = _abs(JOB.get("status", "status.json"))
LOG_PATH = _abs(JOB.get("log", ""))
OUT_DIR = _abs(JOB.get("out_dir", "out"))
os.makedirs(OUT_DIR, exist_ok=True)


def _redirect_output(path):
    """Everything Blender prints, from Python and from C, into the log."""
    if not path:
        return
    fd = os.open(path, os.O_WRONLY | os.O_CREAT | os.O_APPEND, 0o644)
    sys.stdout.flush()
    sys.stderr.flush()
    os.dup2(fd, 1)
    os.dup2(fd, 2)
    os.close(fd)


_redirect_output(LOG_PATH)


def log(*args):
    print("[oriel]", *args, flush=True)


class Status:
    """status.json: what is happening, how far along, what came out."""

    def __init__(self, path):
        self.path = path
        self.data = {
            "schema": SCHEMA, "state": "starting", "stage": "", "progress": 0.0,
            "message": "", "outputs": [], "warnings": [], "error": "",
            "blender": bpy.app.version_string, "engine": "", "device": "",
            "started": time.time(), "updated": time.time(), "eta": -1,
        }
        self._last = 0.0
        self._render_base = 0.0
        self._render_span = 1.0
        self.write(force=True)

    def write(self, force=False):
        now = time.time()
        if not force and now - self._last < 0.4:
            return
        self._last = now
        self.data["updated"] = now
        tmp = self.path + ".tmp"
        with open(tmp, "w", encoding="utf-8") as f:
            json.dump(self.data, f)
        os.replace(tmp, self.path)

    def set(self, force=True, **kw):
        self.data.update(kw)
        p = float(self.data.get("progress", 0.0))
        el = time.time() - self.data["started"]
        self.data["eta"] = int(el * (1.0 - p) / p) if p > 0.02 else -1
        self.write(force=force)

    def warn(self, text):
        if text not in self.data["warnings"]:
            self.data["warnings"].append(text)
            log("warning:", text)
        self.write(force=True)

    def output(self, path):
        self.data["outputs"].append(path)
        self.write(force=True)

    # Each render gets a span of the overall progress; Blender's own sample
    # counter moves within it.
    def span(self, base, span):
        self._render_base = base
        self._render_span = span
        self.set(progress=base)

    def within(self, fraction):
        self.set(force=False, progress=min(0.999, self._render_base + self._render_span * max(0.0, min(1.0, fraction))))


STATUS = Status(STATUS_PATH)

_SAMPLE_RX = [
    re.compile(r"Sample (\d+)/(\d+)"),
    re.compile(r"Rendering (\d+) / (\d+) samples"),
    re.compile(r"(\d+)/(\d+) [Ss]amples"),
]


def _on_stats(stats, *_):
    text = str(stats)
    for rx in _SAMPLE_RX:
        m = rx.search(text)
        if m:
            a, b = int(m.group(1)), int(m.group(2))
            if b > 0:
                STATUS.within(a / b)
            return


try:
    bpy.app.handlers.render_stats.append(_on_stats)
except Exception:  # an old Blender without the handler: progress per render only
    pass

# --------------------------------------------------------------------------
# Coordinates: Oriel's editor is Y-up, Blender is Z-up. Both are right-handed
# metres; (x, y, z) in the editor is (x, -z, y) in Blender.
# --------------------------------------------------------------------------

C = Matrix(((1, 0, 0, 0), (0, 0, -1, 0), (0, 1, 0, 0), (0, 0, 0, 1)))
C_INV = C.inverted()
C3 = np.array([[1, 0, 0], [0, 0, -1], [0, 1, 0]], dtype=np.float64)


def gmat(m):
    """12 numbers, row-major 3 x 4 (basis columns x, y, z, then origin)."""
    return Matrix(((m[0], m[1], m[2], m[3]), (m[4], m[5], m[6], m[7]), (m[8], m[9], m[10], m[11]), (0, 0, 0, 1)))


def object_matrix(m):
    """A mesh's transform: its data came in through glTF, already converted."""
    return C @ gmat(m) @ C_INV


def view_matrix(m):
    """A camera's or light's transform: both look down their own -Z with +Y up
    in both programs, so only the world changes."""
    return C @ gmat(m)


def gvec(v):
    return Vector((v[0], -v[2], v[1]))


def col3(c, default=(1.0, 1.0, 1.0)):
    c = c if c else default
    return (float(c[0]), float(c[1]), float(c[2]))


# --------------------------------------------------------------------------
# Small helpers for node trees, which changed names between versions
# --------------------------------------------------------------------------


def sock(node, *names):
    for n in names:
        if n in node.inputs:
            return node.inputs[n]
    return None


def out(node, *names):
    for n in names:
        if n in node.outputs:
            return node.outputs[n]
    return node.outputs[0]


def principled(mat):
    if not mat or not mat.node_tree:
        return None
    for n in mat.node_tree.nodes:
        if n.bl_idname == "ShaderNodeBsdfPrincipled":
            return n
    return None


def set_input(node, names, value):
    s = sock(node, *names) if isinstance(names, (list, tuple)) else sock(node, names)
    if s is not None and not s.is_linked:
        try:
            s.default_value = value
        except Exception:
            pass
    return s


def engine_identifier(name):
    items = [e.identifier for e in bpy.types.RenderSettings.bl_rna.properties["engine"].enum_items]
    if name == "cycles":
        return "CYCLES"
    for cand in ("BLENDER_EEVEE_NEXT", "BLENDER_EEVEE"):
        if cand in items:
            return cand
    return items[0]


def is_eevee_next():
    return BV >= (4, 2, 0)


# --------------------------------------------------------------------------
# EXR in, PNG out: small readers and writers so the finishing never depends
# on Blender's colour management or compositor, which change between versions.
# --------------------------------------------------------------------------


def _read_cstr(b, i):
    j = b.index(b"\0", i)
    return b[i:j].decode("latin-1"), j + 1


def _read_header(b, i):
    attrs = {}
    while True:
        name, i = _read_cstr(b, i)
        if not name:
            return attrs, i
        typ, i = _read_cstr(b, i)
        size = struct.unpack_from("<i", b, i)[0]
        i += 4
        attrs[name] = (typ, b[i:i + size])
        i += size


def _channels(attrs):
    chans = []
    cb = attrs["channels"][1]
    j = 0
    while cb[j:j + 1] != b"\0":
        cname, j = _read_cstr(cb, j)
        ptype = struct.unpack_from("<i", cb, j)[0]
        j += 16
        chans.append((cname, ptype))
    return chans


def read_exr(path):
    """Scanline OpenEXR, single or multi-part (Blender 5 writes each pass as
    a part), NONE, ZIPS or ZIP compression, HALF or FLOAT, into
    {channel name: float32 array (h, w)}, top row first."""
    with open(path, "rb") as f:
        b = f.read()
    if b[:4] != b"\x76\x2f\x31\x01":
        raise ValueError("not an EXR file: %s" % path)
    flags = struct.unpack_from("<I", b, 4)[0]
    multipart = bool(flags & 0x1000)
    if flags & 0x200 and not multipart:
        raise ValueError("tiled EXR is not supported")
    i = 8
    headers = []
    if multipart:
        while True:
            attrs, i = _read_header(b, i)
            if not attrs:
                break
            headers.append(attrs)
    else:
        attrs, i = _read_header(b, i)
        headers.append(attrs)
    parts = []
    for attrs in headers:
        if "type" in attrs and attrs["type"][1].rstrip(b"\0") not in (b"scanlineimage",):
            raise ValueError("only scanline EXR parts are supported")
        comp = attrs["compression"][1][0]
        x0, y0, x1, y1 = struct.unpack("<iiii", attrs["dataWindow"][1])
        w, h = x1 - x0 + 1, y1 - y0 + 1
        lines_per = {0: 1, 2: 1, 3: 16}.get(comp)
        if lines_per is None:
            raise ValueError("EXR compression %d is not supported" % comp)
        nchunks = struct.unpack("<i", attrs["chunkCount"][1])[0] if "chunkCount" in attrs else (h + lines_per - 1) // lines_per
        parts.append({"chans": _channels(attrs), "comp": comp, "w": w, "h": h, "y0": y0, "y1": y1,
                      "lines": lines_per, "n": nchunks})
    offsets = []
    for p in parts:
        offsets.append(struct.unpack_from("<%dQ" % p["n"], b, i))
        i += 8 * p["n"]
    bpp = {0: 4, 1: 2, 2: 4}
    dt = {0: np.uint32, 1: np.float16, 2: np.float32}
    out = {}
    for pi, p in enumerate(parts):
        w, h = p["w"], p["h"]
        for c, _ in p["chans"]:
            out[c] = np.empty((h, w), dtype=np.float32)
        line_bytes = sum(w * bpp[t] for _, t in p["chans"])
        for off in offsets[pi]:
            if multipart:
                off += 4            # the part number
            y, size = struct.unpack_from("<ii", b, off)
            data = b[off + 8:off + 8 + size]
            n_lines = min(p["lines"], p["y1"] - y + 1)
            if p["comp"] != 0 and size < n_lines * line_bytes:
                raw = np.frombuffer(zlib.decompress(data), dtype=np.uint8).astype(np.int64)
                # Undo OpenEXR's predictor, then its byte interleaving.
                raw[1:] = raw[1:] - 128
                raw = (np.cumsum(raw) & 0xFF).astype(np.uint8)
                half = (raw.size + 1) // 2
                inter = np.empty(raw.size, dtype=np.uint8)
                inter[0::2] = raw[:half]
                inter[1::2] = raw[half:]
                data = inter.tobytes()
            pos = 0
            for ln in range(n_lines):
                row = y - p["y0"] + ln
                for cname, ptype in p["chans"]:
                    out[cname][row] = np.frombuffer(data, dtype=dt[ptype], count=w, offset=pos).astype(np.float32)
                    pos += w * bpp[ptype]
    return out


def write_png(path, img):
    """img: (h, w, 3 or 4) uint8 or uint16. Written atomically."""
    h, w, c = img.shape
    depth = 16 if img.dtype == np.uint16 else 8
    ctype = 6 if c == 4 else 2
    if depth == 16:
        rows = img.astype(">u2").reshape(h, w * c).view(np.uint8).reshape(h, w * c * 2)
    else:
        rows = img.reshape(h, w * c)
    raw = np.empty((h, rows.shape[1] + 1), dtype=np.uint8)
    raw[:, 0] = 0
    raw[:, 1:] = rows
    comp = zlib.compress(raw.tobytes(), 6)

    def chunk(tag, data):
        return struct.pack(">I", len(data)) + tag + data + struct.pack(">I", zlib.crc32(tag + data) & 0xFFFFFFFF)

    png = b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", struct.pack(">IIBBBBB", w, h, depth, ctype, 0, 0, 0)) \
        + chunk(b"IDAT", comp) + chunk(b"IEND", b"")
    tmp = path + ".part"
    with open(tmp, "wb") as f:
        f.write(png)
    os.replace(tmp, path)


def find_channel(layers, *suffixes):
    for s in suffixes:
        for k in layers:
            if k == s or k.endswith("." + s):
                return layers[k]
    return None


# --------------------------------------------------------------------------
# The scene
# --------------------------------------------------------------------------

SCENE = JOB.get("scene", {})
OBJECTS = {}        # glTF node name -> Blender object
WARNED = set()


def warn_once(key, text):
    if key not in WARNED:
        WARNED.add(key)
        STATUS.warn(text)


def reset():
    bpy.ops.wm.read_factory_settings(use_empty=True)
    sc = bpy.context.scene
    sc.render.resolution_percentage = 100
    sc.render.use_file_extension = True
    sc.view_settings.view_transform = "Standard"
    sc.view_settings.look = "None"
    sc.view_settings.exposure = 0.0
    sc.view_settings.gamma = 1.0
    try:
        sc.display_settings.display_device = "sRGB"
    except Exception:
        pass


def import_glb(path):
    STATUS.set(stage="scene", message="Reading the scene")
    before = set(bpy.data.objects)
    bpy.ops.import_scene.gltf(filepath=path)
    for o in bpy.data.objects:
        if o not in before:
            OBJECTS[o.name] = o
    log("imported %d objects from %s" % (len(OBJECTS), os.path.basename(path)))


def apply_object_flags():
    for name, spec in SCENE.get("objects", {}).items():
        o = OBJECTS.get(name)
        if o is None:
            continue
        if not spec.get("cast_shadow", True):
            try:
                o.visible_shadow = False
            except Exception:
                pass
        if spec.get("hidden", False):
            o.hide_render = True
        if spec.get("shadow_only", False):
            try:
                o.visible_camera = False
            except Exception:
                pass
        if "id_color" in spec:
            c = spec["id_color"]
            o.color = (float(c[0]), float(c[1]), float(c[2]), 1.0)
        if spec.get("camera_only", False):
            # Seen, but lights nothing (an area light's glowing panel).
            for attr in ("visible_diffuse", "visible_glossy", "visible_transmission", "visible_volume_scatter", "visible_shadow"):
                try:
                    setattr(o, attr, False)
                except Exception:
                    pass


# ----------------------------------------------------------------- materials


def _image_nodes(mat):
    return [n for n in mat.node_tree.nodes if n.bl_idname == "ShaderNodeTexImage"]


def _normal_map_nodes(mat):
    return [n for n in mat.node_tree.nodes if n.bl_idname == "ShaderNodeNormalMap"]


def _triplanar(mat, spec):
    """Godot's triplanar mapping: textures projected along the three axes,
    in world or object space, scaled per axis. Colour and roughness use
    Blender's box projection; normal maps are re-oriented per axis."""
    nt = mat.node_tree
    nodes, links = nt.nodes, nt.links
    sc = spec.get("scale", [1, 1, 1])
    off = spec.get("offset", [0, 0, 0])
    world = spec.get("world", False)
    sharp = float(spec.get("sharpness", 1.0))
    if world:
        src = nodes.new("ShaderNodeNewGeometry")
        pos = out(src, "Position")
    else:
        src = nodes.new("ShaderNodeTexCoord")
        pos = out(src, "Object")
    mapping = nodes.new("ShaderNodeMapping")
    mapping.vector_type = "POINT"
    # Godot (x, y, z) scale -> Blender (x, z, y).
    mapping.inputs["Scale"].default_value = (sc[0], sc[2], sc[1])
    mapping.inputs["Location"].default_value = (off[0], off[2], off[1])
    links.new(pos, mapping.inputs["Vector"])
    vec = mapping.outputs["Vector"]
    normal_images = set()
    for nm in _normal_map_nodes(mat):
        c = nm.inputs["Color"]
        if c.is_linked and c.links[0].from_node.bl_idname == "ShaderNodeTexImage":
            normal_images.add(c.links[0].from_node)
    for img in _image_nodes(mat):
        if img in normal_images:
            continue
        img.projection = "BOX"
        img.projection_blend = max(0.0, min(1.0, 0.25 / max(sharp, 0.05)))
        for l in list(img.inputs["Vector"].links):
            links.remove(l)
        links.new(vec, img.inputs["Vector"])
    for nm in _normal_map_nodes(mat):
        c = nm.inputs["Color"]
        if not c.is_linked:
            continue
        tex = c.links[0].from_node
        if tex.bl_idname != "ShaderNodeTexImage" or tex.image is None:
            continue
        strength = nm.inputs["Strength"].default_value
        targets = [l.to_socket for l in nm.outputs["Normal"].links]
        normal = _triplanar_normal(nt, tex.image, vec, sharp, strength)
        for t in targets:
            links.new(normal, t)


def _triplanar_normal(nt, image, vec, sharp, strength):
    """Ben Golus's whiteout-blended triplanar normal map, in nodes."""
    nodes, links = nt.nodes, nt.links
    geo = nodes.new("ShaderNodeNewGeometry")
    n = out(geo, "Normal")
    sep_p = nodes.new("ShaderNodeSeparateXYZ")
    links.new(vec, sep_p.inputs[0])
    sep_n = nodes.new("ShaderNodeSeparateXYZ")
    links.new(n, sep_n.inputs[0])

    def combine(a, b_):
        c = nodes.new("ShaderNodeCombineXYZ")
        links.new(a, c.inputs[0])
        links.new(b_, c.inputs[1])
        return c.outputs[0]

    def sample(uv):
        t = nodes.new("ShaderNodeTexImage")
        t.image = image
        t.interpolation = "Linear"
        try:
            image.colorspace_settings.name = "Non-Color"
        except Exception:
            pass
        links.new(uv, t.inputs["Vector"])
        # t * 2 - 1, with the strength on x and y
        m = nodes.new("ShaderNodeVectorMath")
        m.operation = "MULTIPLY_ADD"
        links.new(t.outputs["Color"], m.inputs[0])
        m.inputs[1].default_value = (2.0, 2.0, 2.0)
        m.inputs[2].default_value = (-1.0, -1.0, -1.0)
        s = nodes.new("ShaderNodeVectorMath")
        s.operation = "MULTIPLY"
        links.new(m.outputs[0], s.inputs[0])
        s.inputs[1].default_value = (strength, strength, 1.0)
        return s.outputs[0]

    px, py, pz = sep_p.outputs
    nx, ny, nz = sep_n.outputs
    tx = sample(combine(py, pz))   # projected along X: (y, z)
    ty = sample(combine(px, pz))   # along Y: (x, z)
    tz = sample(combine(px, py))   # along Z: (x, y)

    def whiteout(t, na, nb, nc, order):
        """(t.xy + n.ab, |t.z| * n.c), then swizzled back into world axes."""
        st = nodes.new("ShaderNodeSeparateXYZ")
        links.new(t, st.inputs[0])
        a = nodes.new("ShaderNodeMath")
        a.operation = "ADD"
        links.new(st.outputs[0], a.inputs[0])
        links.new(na, a.inputs[1])
        b_ = nodes.new("ShaderNodeMath")
        b_.operation = "ADD"
        links.new(st.outputs[1], b_.inputs[0])
        links.new(nb, b_.inputs[1])
        ab = nodes.new("ShaderNodeMath")
        ab.operation = "ABSOLUTE"
        links.new(st.outputs[2], ab.inputs[0])
        cz = nodes.new("ShaderNodeMath")
        cz.operation = "MULTIPLY"
        links.new(ab.outputs[0], cz.inputs[0])
        links.new(nc, cz.inputs[1])
        comps = {"a": a.outputs[0], "b": b_.outputs[0], "c": cz.outputs[0]}
        c = nodes.new("ShaderNodeCombineXYZ")
        for i, k in enumerate(order):
            links.new(comps[k], c.inputs[i])
        return c.outputs[0]

    # X projection: tangent (y, z) -> world (c, a, b); Y: (x, z) -> (a, c, b); Z: (x, y) -> (a, b, c)
    wx = whiteout(tx, ny, nz, nx, "cab")
    wy = whiteout(ty, nx, nz, ny, "acb")
    wz = whiteout(tz, nx, ny, nz, "abc")
    # Blend weights: |n| ^ (4 * sharpness), normalised.
    weights = []
    for comp in (nx, ny, nz):
        ab = nodes.new("ShaderNodeMath")
        ab.operation = "ABSOLUTE"
        links.new(comp, ab.inputs[0])
        pw = nodes.new("ShaderNodeMath")
        pw.operation = "POWER"
        links.new(ab.outputs[0], pw.inputs[0])
        pw.inputs[1].default_value = 4.0 * max(sharp, 0.25)
        weights.append(pw.outputs[0])
    total = nodes.new("ShaderNodeMath")
    total.operation = "ADD"
    links.new(weights[0], total.inputs[0])
    links.new(weights[1], total.inputs[1])
    total2 = nodes.new("ShaderNodeMath")
    total2.operation = "ADD"
    links.new(total.outputs[0], total2.inputs[0])
    links.new(weights[2], total2.inputs[1])
    acc = None
    for wvec, wgt in zip((wx, wy, wz), weights):
        d = nodes.new("ShaderNodeMath")
        d.operation = "DIVIDE"
        links.new(wgt, d.inputs[0])
        links.new(total2.outputs[0], d.inputs[1])
        sc = nodes.new("ShaderNodeVectorMath")
        sc.operation = "SCALE"
        links.new(wvec, sc.inputs[0])
        links.new(d.outputs[0], sc.inputs["Scale"])
        if acc is None:
            acc = sc.outputs[0]
        else:
            ad = nodes.new("ShaderNodeVectorMath")
            ad.operation = "ADD"
            links.new(acc, ad.inputs[0])
            links.new(sc.outputs[0], ad.inputs[1])
            acc = ad.outputs[0]
    nrm = nodes.new("ShaderNodeVectorMath")
    nrm.operation = "NORMALIZE"
    links.new(acc, nrm.inputs[0])
    return nrm.outputs[0]


def _emission_only(mat, strength=1.0):
    """Godot's unshaded: the colour as it is, lit by nothing."""
    nt = mat.node_tree
    bsdf = principled(mat)
    outn = next((n for n in nt.nodes if n.bl_idname == "ShaderNodeOutputMaterial"), None)
    if bsdf is None or outn is None:
        return
    em = nt.nodes.new("ShaderNodeEmission")
    base = sock(bsdf, "Base Color")
    if base.is_linked:
        nt.links.new(base.links[0].from_socket, em.inputs["Color"])
    else:
        em.inputs["Color"].default_value = base.default_value
    em.inputs["Strength"].default_value = strength
    alpha = sock(bsdf, "Alpha")
    if alpha is not None and (alpha.is_linked or alpha.default_value < 0.999):
        tr = nt.nodes.new("ShaderNodeBsdfTransparent")
        mix = nt.nodes.new("ShaderNodeMixShader")
        if alpha.is_linked:
            nt.links.new(alpha.links[0].from_socket, mix.inputs[0])
        else:
            mix.inputs[0].default_value = alpha.default_value
        nt.links.new(tr.outputs[0], mix.inputs[1])
        nt.links.new(em.outputs[0], mix.inputs[2])
        nt.links.new(mix.outputs[0], outn.inputs["Surface"])
    else:
        nt.links.new(em.outputs[0], outn.inputs["Surface"])


def _water(mat, spec):
    """Oriel's water: clear, glossy, with small waves; the colour of its depth."""
    nt = mat.node_tree
    for n in list(nt.nodes):
        nt.nodes.remove(n)
    outn = nt.nodes.new("ShaderNodeOutputMaterial")
    bsdf = nt.nodes.new("ShaderNodeBsdfPrincipled")
    deep = col3(spec.get("deep"), (0.02, 0.08, 0.1))
    shallow = col3(spec.get("shallow"), (0.16, 0.34, 0.33))
    set_input(bsdf, "Base Color", (*shallow, 1.0))
    set_input(bsdf, "Roughness", 0.03)
    set_input(bsdf, "IOR", 1.333)
    set_input(bsdf, ("Transmission Weight", "Transmission"), 0.0 if spec.get("ocean") else 0.6)
    set_input(bsdf, ("Coat Weight",), 0.0)
    # Waves: a little noise as a bump, at the scale Godot used.
    tc = nt.nodes.new("ShaderNodeNewGeometry")
    mp = nt.nodes.new("ShaderNodeMapping")
    s = float(spec.get("wave_scale", 0.35)) * 2.0
    mp.inputs["Scale"].default_value = (s, s, s)
    nt.links.new(out(tc, "Position"), mp.inputs["Vector"])
    noise = nt.nodes.new("ShaderNodeTexNoise")
    try:
        noise.noise_dimensions = "3D"
    except Exception:
        pass
    noise.inputs["Scale"].default_value = 1.0
    noise.inputs["Detail"].default_value = 6.0
    nt.links.new(mp.outputs["Vector"], noise.inputs["Vector"])
    bump = nt.nodes.new("ShaderNodeBump")
    bump.inputs["Strength"].default_value = 0.15 * float(spec.get("wave_strength", 0.6))
    bump.inputs["Distance"].default_value = 0.05
    nt.links.new(out(noise, "Fac"), bump.inputs["Height"])
    nt.links.new(bump.outputs["Normal"], sock(bsdf, "Normal"))
    # Deeper water tints darker: a volume absorber the colour of its depth.
    if not spec.get("ocean"):
        vol = nt.nodes.new("ShaderNodeVolumeAbsorption")
        vol.inputs["Color"].default_value = (*deep, 1.0)
        vol.inputs["Density"].default_value = 1.0 / max(float(spec.get("clarity", 3.0)), 0.2)
        nt.links.new(vol.outputs[0], outn.inputs["Volume"])
    else:
        set_input(bsdf, "Base Color", (*deep, 1.0))
    nt.links.new(bsdf.outputs[0], outn.inputs["Surface"])


def _terrain(mat, spec):
    """Painted ground: up to five world-tiled materials blended by the weights
    Oriel painted, which travel as the mesh's vertex colours."""
    nt = mat.node_tree
    for n in list(nt.nodes):
        nt.nodes.remove(n)
    outn = nt.nodes.new("ShaderNodeOutputMaterial")
    bsdf = nt.nodes.new("ShaderNodeBsdfPrincipled")
    geo = nt.nodes.new("ShaderNodeNewGeometry")
    layers = spec.get("layers", [])

    def layer_colour(L):
        img = _load_image(L.get("albedo"))
        tint = col3(L.get("tint"))
        if img is None:
            rgb = nt.nodes.new("ShaderNodeRGB")
            rgb.outputs[0].default_value = (*tint, 1.0)
            return rgb.outputs[0], None
        if L.get("photo"):
            t = nt.nodes.new("ShaderNodeTexImage")
            t.image = img
            _use_uv(mat, 1, [t])
            return t.outputs["Color"], t
        mp = nt.nodes.new("ShaderNodeMapping")
        s = 1.0 / max(float(L.get("scale", 2.0)), 0.01)
        mp.inputs["Scale"].default_value = (s, s, s)
        nt.links.new(out(geo, "Position"), mp.inputs["Vector"])
        t = nt.nodes.new("ShaderNodeTexImage")
        t.image = img
        t.projection = "BOX"
        t.projection_blend = 0.2
        nt.links.new(mp.outputs["Vector"], t.inputs["Vector"])
        mul = nt.nodes.new("ShaderNodeMix")
        mul.data_type = "RGBA"
        mul.blend_type = "MULTIPLY"
        mul.inputs[0].default_value = 1.0
        nt.links.new(t.outputs["Color"], mul.inputs[6])
        mul.inputs[7].default_value = (*tint, 1.0)
        return mul.outputs[2], t

    if not layers:
        nt.links.new(bsdf.outputs[0], outn.inputs["Surface"])
        return
    colour, _ = layer_colour(layers[0])
    attr = nt.nodes.new("ShaderNodeVertexColor")
    try:
        attr.layer_name = spec.get("weights_attribute", "")
    except Exception:
        pass
    sep = nt.nodes.new("ShaderNodeSeparateColor")
    nt.links.new(attr.outputs["Color"], sep.inputs[0])
    weights = [sep.outputs[0], sep.outputs[1], sep.outputs[2], attr.outputs["Alpha"]]
    for k, L in enumerate(layers[1:5]):
        if not L.get("used", True):
            continue
        c, _ = layer_colour(L)
        mix = nt.nodes.new("ShaderNodeMix")
        mix.data_type = "RGBA"
        nt.links.new(weights[k], mix.inputs[0])
        nt.links.new(colour, mix.inputs[6])
        nt.links.new(c, mix.inputs[7])
        colour = mix.outputs[2]
    nt.links.new(colour, sock(bsdf, "Base Color"))
    set_input(bsdf, "Roughness", float(layers[0].get("roughness", 0.95)))
    nt.links.new(bsdf.outputs[0], outn.inputs["Surface"])


def _uv_name(mat, index):
    """The name of a mesh's UV map number `index` among meshes using `mat`."""
    for o in bpy.data.objects:
        if o.type == "MESH" and any(sl.material == mat for sl in o.material_slots):
            uvs = o.data.uv_layers
            if len(uvs) > index:
                return uvs[index].name
    return ""


def _use_uv(mat, index, image_nodes):
    name = _uv_name(mat, index)
    if not name:
        return
    nt = mat.node_tree
    uv = nt.nodes.new("ShaderNodeUVMap")
    uv.uv_map = name
    for img in image_nodes:
        v = img.inputs["Vector"]
        for l in list(v.links):
            nt.links.remove(l)
        nt.links.new(uv.outputs["UV"], v)


def _detail(mat, d):
    """Godot's detail map: a second picture over the colour, usually on the
    second UV map (the editor's lawn uses it to break up its repeat)."""
    img = _load_image(d.get("image"))
    bsdf = principled(mat)
    if img is None or bsdf is None:
        return
    nt = mat.node_tree
    base = sock(bsdf, "Base Color")
    tex = nt.nodes.new("ShaderNodeTexImage")
    tex.image = img
    mp = nt.nodes.new("ShaderNodeMapping")
    sc = d.get("scale", [1, 1])
    mp.inputs["Scale"].default_value = (float(sc[0]), float(sc[1]), 1.0)
    name = _uv_name(mat, int(d.get("uv", 0)))
    uv = nt.nodes.new("ShaderNodeUVMap")
    if name:
        uv.uv_map = name
    nt.links.new(uv.outputs["UV"], mp.inputs["Vector"])
    nt.links.new(mp.outputs["Vector"], tex.inputs["Vector"])
    mix = nt.nodes.new("ShaderNodeMix")
    mix.data_type = "RGBA"
    mix.blend_type = {"add": "ADD", "sub": "SUBTRACT", "mul": "MULTIPLY"}.get(d.get("blend", "mix"), "MIX")
    if base.is_linked:
        nt.links.new(base.links[0].from_socket, mix.inputs[6])
    else:
        mix.inputs[6].default_value = base.default_value
    nt.links.new(tex.outputs["Color"], mix.inputs[7])
    if mix.blend_type == "MIX":
        nt.links.new(tex.outputs["Alpha"], mix.inputs[0])
    else:
        mix.inputs[0].default_value = 1.0
    nt.links.new(mix.outputs[2], base)


_IMAGES = {}


def _load_image(path, non_color=False):
    if not path:
        return None
    p = _abs(path)
    if p in _IMAGES:
        return _IMAGES[p]
    if not os.path.exists(p):
        return None
    try:
        img = bpy.data.images.load(p, check_existing=True)
        if non_color:
            img.colorspace_settings.name = "Non-Color"
    except Exception:
        img = None
    _IMAGES[p] = img
    return img


def fix_materials():
    specs = SCENE.get("materials", {})
    for mat in bpy.data.materials:
        spec = specs.get(mat.name)
        if not mat.use_nodes or mat.node_tree is None:
            continue
        bsdf = principled(mat)
        # Alpha that lets light through: windows must not stop the sun.
        if is_eevee_next():
            try:
                mat.use_transparent_shadow = True
            except Exception:
                pass
        else:
            try:
                if mat.blend_method in ("BLEND", "HASHED", "CLIP"):
                    mat.shadow_method = "HASHED"
            except Exception:
                pass
        if spec is None:
            continue
        try:
            kind = spec.get("kind", "")
            if kind == "water":
                _water(mat, spec)
                continue
            if kind == "terrain":
                _terrain(mat, spec)
                continue
            if spec.get("triplanar"):
                _triplanar(mat, spec["triplanar"])
            if int(spec.get("uv", 0)) == 1:
                _use_uv(mat, 1, _image_nodes(mat))
            if spec.get("detail"):
                _detail(mat, spec["detail"])
            if bsdf is not None:
                if "ior" in spec:
                    set_input(bsdf, "IOR", float(spec["ior"]))
                if spec.get("coat"):
                    set_input(bsdf, ("Coat Weight", "Clearcoat"), float(spec["coat"].get("weight", 1.0)))
                    set_input(bsdf, ("Coat Roughness", "Clearcoat Roughness"), float(spec["coat"].get("roughness", 0.0)))
                if "specular" in spec:
                    set_input(bsdf, ("Specular IOR Level", "Specular"), float(spec["specular"]))
                if spec.get("no_vertex_colour"):
                    for n in list(mat.node_tree.nodes):
                        if n.bl_idname in ("ShaderNodeVertexColor", "ShaderNodeAttribute"):
                            for l in list(n.outputs[0].links):
                                # The colour went into a multiply with the base colour:
                                # pass the other input through instead.
                                tgt = l.to_node
                                mat.node_tree.links.remove(l)
                                if tgt.bl_idname in ("ShaderNodeMix", "ShaderNodeMixRGB"):
                                    for s in tgt.inputs:
                                        if s.type == "RGBA" and not s.is_linked:
                                            s.default_value = (1, 1, 1, 1)
            if spec.get("unshaded"):
                _emission_only(mat, float(spec.get("emission_strength", 1.0)))
        except Exception as e:  # a material that can't be fixed renders as glTF made it
            warn_once("mat:" + mat.name, "material %s kept as imported (%s)" % (mat.name, e))


# ----------------------------------------------------------------- instancers


def _matrices(path, count):
    a = np.fromfile(_abs(path), dtype="<f4")
    a = a.reshape(count, 12).astype(np.float64)
    m = np.zeros((count, 4, 4))
    m[:, :3, :] = a.reshape(count, 3, 4)
    m[:, 3, 3] = 1.0
    c = np.eye(4)
    c[:3, :3] = C3
    return c @ m @ np.linalg.inv(c)


def _euler_xyz(r):
    """Rotation matrices (n, 3, 3) to Blender XYZ Euler angles."""
    sy = np.clip(-r[:, 2, 0], -1.0, 1.0)
    ry = np.arcsin(sy)
    rx = np.arctan2(r[:, 2, 1], r[:, 2, 2])
    rz = np.arctan2(r[:, 1, 0], r[:, 0, 0])
    gimbal = np.abs(sy) > 0.99999
    if np.any(gimbal):
        rx[gimbal] = np.arctan2(-r[gimbal, 1, 2], r[gimbal, 1, 1])
        rz[gimbal] = 0.0
    return np.stack([rx, ry, rz], axis=1)


def build_instancers():
    """Copies of one model (vegetation, crowds, seats): one point per copy and
    Geometry Nodes instancing, so a hundred thousand copies stay cheap."""
    for k, spec in enumerate(SCENE.get("instancers", [])):
        base = OBJECTS.get(spec["base"])
        if base is None:
            warn_once("inst:" + spec["base"], "a set of copies lost its model (%s)" % spec["base"])
            continue
        n = int(spec["count"])
        if n <= 0:
            continue
        m = _matrices(spec["file"], n)
        pos = m[:, :3, 3]
        basis = m[:, :3, :3]
        scale = np.linalg.norm(basis, axis=1)        # length of each column
        scale = np.maximum(scale, 1e-8)
        rot = basis / scale[:, None, :]
        eul = _euler_xyz(rot)
        mesh = bpy.data.meshes.new("oriel_points_%d" % k)
        mesh.vertices.add(n)
        mesh.vertices.foreach_set("co", pos.astype(np.float32).ravel())
        for name, data in (("oriel_rot", eul), ("oriel_scale", scale)):
            at = mesh.attributes.new(name, "FLOAT_VECTOR", "POINT")
            at.data.foreach_set("vector", data.astype(np.float32).ravel())
        mesh.update()
        obj = bpy.data.objects.new("oriel_copies_%d" % k, mesh)
        obj.color = base.color      # the ID pass colour of the model
        bpy.context.scene.collection.objects.link(obj)
        mod = obj.modifiers.new("copies", "NODES")
        mod.node_group = _instancer_group(base)
        # The model itself is only a source.
        base.hide_render = True
        base.hide_viewport = True
        for ch in base.children_recursive:
            ch.hide_render = True
        log("instancer %d: %d copies of %s" % (k, n, base.name))


def _instancer_group(base):
    g = bpy.data.node_groups.new("oriel_copies_" + base.name, "GeometryNodeTree")
    if hasattr(g, "interface"):
        g.interface.new_socket("Geometry", in_out="INPUT", socket_type="NodeSocketGeometry")
        g.interface.new_socket("Geometry", in_out="OUTPUT", socket_type="NodeSocketGeometry")
    else:  # Blender 3.x style
        g.inputs.new("NodeSocketGeometry", "Geometry")
        g.outputs.new("NodeSocketGeometry", "Geometry")
    nodes, links = g.nodes, g.links
    gi = nodes.new("NodeGroupInput")
    go = nodes.new("NodeGroupOutput")
    info = nodes.new("GeometryNodeObjectInfo")
    info.inputs["Object"].default_value = base
    try:
        info.transform_space = "ORIGINAL"
    except Exception:
        pass
    if "As Instance" in info.inputs:
        info.inputs["As Instance"].default_value = True
    inst = nodes.new("GeometryNodeInstanceOnPoints")
    rot = nodes.new("GeometryNodeInputNamedAttribute")
    rot.data_type = "FLOAT_VECTOR"
    rot.inputs["Name"].default_value = "oriel_rot"
    scl = nodes.new("GeometryNodeInputNamedAttribute")
    scl.data_type = "FLOAT_VECTOR"
    scl.inputs["Name"].default_value = "oriel_scale"
    links.new(gi.outputs[0], inst.inputs["Points"])
    links.new(out(info, "Geometry"), inst.inputs["Instance"])
    rot_out = rot.outputs["Attribute"] if "Attribute" in rot.outputs else rot.outputs[0]
    scl_out = scl.outputs["Attribute"] if "Attribute" in scl.outputs else scl.outputs[0]
    target = inst.inputs["Rotation"]
    if getattr(target, "type", "") == "ROTATION":
        conv = nodes.new("FunctionNodeEulerToRotation")
        links.new(rot_out, conv.inputs[0])
        links.new(conv.outputs[0], target)
    else:
        links.new(rot_out, target)
    links.new(scl_out, inst.inputs["Scale"])
    links.new(inst.outputs[0], go.inputs[0])
    return g


# ----------------------------------------------------------------- lights

_LIGHTS = []


def _window(d, rng):
    nd = (d / max(rng, 1e-3)) ** 4
    nd = max(1.0 - nd, 0.0)
    return nd * nd


def _godot_attenuation(d, rng, decay):
    return _window(d, rng) * max(d, 1e-4) ** (-decay)


def light_power(L):
    """Blender watts that light a white wall as brightly as Oriel's editor
    shows it. Godot (without physical units) gives a white surface facing
    the light radiance energy x attenuation; Blender's point light of P watts
    gives P / (4 pi^2 d^2), its sun of S W/m^2 gives S / pi, its area light
    P / (pi^2 d^2). The editor's falloff is set per light and is often not the
    inverse square, so the match is made at the distance that light mostly
    reaches (d_ref, found by Oriel along the light's beam)."""
    t = L["type"]
    e = float(L.get("energy", 1.0))
    if t == "sun":
        return math.pi * e
    d = float(L.get("d_ref", 3.0))
    if t == "area":
        # Several of the editor's lights make up one area light here.
        s = 0.0
        for part in L.get("parts", []):
            s += float(part["energy"]) * _godot_attenuation(d, float(part.get("range", 10.0)), float(part.get("decay", 1.0)))
        return math.pi * math.pi * d * d * s
    att = _godot_attenuation(d, float(L.get("range", 10.0)), float(L.get("decay", 1.0)))
    return 4.0 * math.pi * math.pi * d * d * e * att


def clear_lights():
    for o in _LIGHTS:
        try:
            data = o.data
            bpy.data.objects.remove(o, do_unlink=True)
            bpy.data.lights.remove(data)
        except Exception:
            pass
    _LIGHTS.clear()


def build_lights(lights):
    clear_lights()
    kinds = {"point": "POINT", "spot": "SPOT", "sun": "SUN", "area": "AREA"}
    for i, L in enumerate(lights):
        t = L.get("type", "point")
        if t not in kinds:
            continue
        data = bpy.data.lights.new("oriel_light_%d" % i, kinds[t])
        data.color = col3(L.get("color"))
        data.energy = light_power(L) * float(L.get("scale", 1.0))
        try:
            data.use_shadow = bool(L.get("shadow", True))
        except Exception:
            pass
        if t in ("point", "spot"):
            data.shadow_soft_size = max(float(L.get("radius", 0.05)), 0.0)
        if t == "spot":
            data.spot_size = max(min(float(L.get("spot_angle", 45.0)) * 2.0, 180.0), 1.0) * math.pi / 180.0
            data.spot_blend = max(0.0, min(1.0, float(L.get("spot_blend", 0.3))))
            try:
                data.show_cone = False
            except Exception:
                pass
        if t == "sun":
            data.angle = max(float(L.get("angle", 0.53)), 0.0) * math.pi / 180.0
        if t == "area":
            shape = L.get("shape", "RECTANGLE")
            data.shape = shape if shape in ("SQUARE", "RECTANGLE", "DISK", "ELLIPSE") else "RECTANGLE"
            sz = L.get("size", [1.0, 1.0])
            data.size = max(float(sz[0]), 0.01)
            if data.shape in ("RECTANGLE", "ELLIPSE"):
                data.size_y = max(float(sz[1]), 0.01)
            if L.get("two_sided"):
                warn_once("area2", "two-sided area lights are lit on one side in Eevee and Cycles")
        if "volume" in L:
            try:
                data.volume_factor = float(L["volume"])
            except Exception:
                pass
        o = bpy.data.objects.new(data.name, data)
        o.matrix_world = view_matrix(L["matrix"])
        bpy.context.scene.collection.objects.link(o)
        _LIGHTS.append(o)
    log("lights: %d" % len(_LIGHTS))


# ----------------------------------------------------------------- the sky

WORLD_INFO = {}


def build_world(w):
    """The editor's sky as the world: its gradient and clouds, or the photo,
    lighting the scene by `ambient` and seen by the camera as it is."""
    world = bpy.data.worlds.get("oriel_world") or bpy.data.worlds.new("oriel_world")
    bpy.context.scene.world = world
    world.use_nodes = True
    nt = world.node_tree
    for n in list(nt.nodes):
        nt.nodes.remove(n)
    outn = nt.nodes.new("ShaderNodeOutputWorld")
    kind = w.get("kind", "gradient")
    WORLD_INFO.clear()
    WORLD_INFO.update(w)
    if kind == "hdri" and w.get("hdri") and os.path.exists(_abs(w["hdri"])):
        colour = _hdri_world(nt, w)
    elif kind == "color":
        rgb = nt.nodes.new("ShaderNodeRGB")
        rgb.outputs[0].default_value = (*col3(w.get("color"), (0.05, 0.05, 0.05)), 1.0)
        colour = rgb.outputs[0]
    else:
        colour = _gradient_world(nt, w)
    # Seen as it is by the camera and in reflections; lighting by `ambient`.
    lp = nt.nodes.new("ShaderNodeLightPath")
    mx = nt.nodes.new("ShaderNodeMath")
    mx.operation = "MAXIMUM"
    nt.links.new(out(lp, "Is Camera Ray"), mx.inputs[0])
    nt.links.new(out(lp, "Is Glossy Ray"), mx.inputs[1])
    amb = float(w.get("ambient", 1.0))
    fac = nt.nodes.new("ShaderNodeMapRange")
    nt.links.new(mx.outputs[0], fac.inputs["Value"])
    fac.inputs["From Min"].default_value = 0.0
    fac.inputs["From Max"].default_value = 1.0
    fac.inputs["To Min"].default_value = amb
    fac.inputs["To Max"].default_value = 1.0
    bg = nt.nodes.new("ShaderNodeBackground")
    nt.links.new(colour, bg.inputs["Color"])
    nt.links.new(fac.outputs[0], bg.inputs["Strength"])
    nt.links.new(bg.outputs[0], outn.inputs["Surface"])


def _direction(nt):
    """The world-space direction a world shader is looking along."""
    tc = nt.nodes.new("ShaderNodeTexCoord")
    return out(tc, "Generated")


def _hdri_world(nt, w):
    tex = nt.nodes.new("ShaderNodeTexEnvironment")
    tex.image = bpy.data.images.load(_abs(w["hdri"]), check_existing=True)
    mp = nt.nodes.new("ShaderNodeMapping")
    mp.vector_type = "VECTOR"
    # Godot's panorama starts at -Z and runs towards +X; Blender's starts a
    # quarter turn away. Then the sky's own rotation (about up).
    mp.inputs["Rotation"].default_value = (0.0, 0.0, math.pi * 0.5 + float(w.get("rotation", 0.0)))
    nt.links.new(_direction(nt), mp.inputs["Vector"])
    nt.links.new(mp.outputs["Vector"], tex.inputs["Vector"])
    s = nt.nodes.new("ShaderNodeVectorMath")
    s.operation = "SCALE"
    nt.links.new(tex.outputs["Color"], s.inputs[0])
    s.inputs["Scale"].default_value = float(w.get("strength", 1.0))
    return s.outputs[0]


def _gradient_world(nt, w):
    """The editor's cloud sky (gn_cloud_sky.gdshader) rebuilt in nodes:
    top/horizon/ground gradient, sun disc and glow, a deck of clouds."""
    nodes, links = nt.nodes, nt.links
    top = col3(w.get("top"), (0.22, 0.42, 0.78))
    hor = col3(w.get("horizon"), (0.66, 0.77, 0.9))
    gnd = col3(w.get("ground"), (0.3, 0.28, 0.25))
    energy = float(w.get("energy", 1.0))
    cloudiness = float(w.get("cloudiness", 0.0))
    d = _direction(nt)
    sep = nodes.new("ShaderNodeSeparateXYZ")
    links.new(d, sep.inputs[0])
    up = sep.outputs[2]

    def math_node(op, a, b=None, v=None):
        m = nodes.new("ShaderNodeMath")
        m.operation = op
        for idx, x in enumerate((a, b)):
            if x is None:
                continue
            if isinstance(x, (int, float)):
                m.inputs[idx].default_value = x
            else:
                links.new(x, m.inputs[idx])
        if v is not None:
            m.inputs[2].default_value = v
        return m.outputs[0]

    def mix_col(fac, a, b):
        m = nodes.new("ShaderNodeMix")
        m.data_type = "RGBA"
        if isinstance(fac, (int, float)):
            m.inputs[0].default_value = fac
        else:
            links.new(fac, m.inputs[0])
        for idx, c in ((6, a), (7, b)):
            if isinstance(c, tuple):
                m.inputs[idx].default_value = (*c, 1.0)
            else:
                links.new(c, m.inputs[idx])
        return m.outputs[2]

    upc = math_node("MAXIMUM", up, 0.0)
    downc = math_node("MAXIMUM", math_node("MULTIPLY", up, -1.0), 0.0)
    sky_part = mix_col(math_node("POWER", upc, 0.5), hor, top)
    ground_part = mix_col(math_node("POWER", downc, 0.35), hor, gnd)
    is_up = math_node("GREATER_THAN", up, 0.0)
    col = mix_col(is_up, ground_part, sky_part)
    sun = w.get("sun")
    if sun:
        sd = gvec(sun["toward"])
        dot = nodes.new("ShaderNodeVectorMath")
        dot.operation = "DOT_PRODUCT"
        links.new(d, dot.inputs[0])
        dot.inputs[1].default_value = (sd.x, sd.y, sd.z)
        s = dot.outputs["Value"] if "Value" in dot.outputs else dot.outputs[1]
        disc = nodes.new("ShaderNodeMapRange")
        disc.interpolation_type = "SMOOTHSTEP"
        links.new(s, disc.inputs["Value"])
        disc.inputs["From Min"].default_value = 0.9995
        disc.inputs["From Max"].default_value = 0.9998
        glow = math_node("MULTIPLY", math_node("POWER", math_node("MAXIMUM", s, 0.0), 64.0), 0.4)
        amount = math_node("ADD", math_node("MULTIPLY", disc.outputs[0], 20.0), glow)
        k = float(sun.get("energy", 1.0))
        sc = col3(sun.get("color"))
        tint = nodes.new("ShaderNodeVectorMath")
        tint.operation = "SCALE"
        tint.inputs[0].default_value = (sc[0] * k, sc[1] * k, sc[2] * k)
        links.new(amount, tint.inputs["Scale"])
        add = nodes.new("ShaderNodeVectorMath")
        add.operation = "ADD"
        links.new(col, add.inputs[0])
        links.new(tint.outputs[0], add.inputs[1])
        col = add.outputs[0]
    if cloudiness > 0.001:
        # Clouds on a flat deck: direction.xy / (up + 0.08), two scales of noise.
        den = math_node("ADD", upc, 0.08)
        u = math_node("DIVIDE", sep.outputs[0], den)
        v = math_node("DIVIDE", sep.outputs[1], den)
        cxy = nodes.new("ShaderNodeCombineXYZ")
        links.new(u, cxy.inputs[0])
        links.new(v, cxy.inputs[1])
        mp = nodes.new("ShaderNodeMapping")
        s = float(w.get("cloud_scale", 1.6)) * 0.55
        mp.inputs["Scale"].default_value = (s, s, s)
        links.new(cxy.outputs[0], mp.inputs["Vector"])
        noise = nodes.new("ShaderNodeTexNoise")
        noise.inputs["Scale"].default_value = 1.0
        noise.inputs["Detail"].default_value = 5.0
        if "Roughness" in noise.inputs:
            noise.inputs["Roughness"].default_value = 0.5
        links.new(mp.outputs["Vector"], noise.inputs["Vector"])
        n = out(noise, "Fac")
        cover = nodes.new("ShaderNodeMapRange")
        cover.interpolation_type = "SMOOTHSTEP"
        links.new(n, cover.inputs["Value"])
        cover.inputs["From Min"].default_value = 1.0 - cloudiness
        cover.inputs["From Max"].default_value = 1.15 - cloudiness * 0.6
        horizon_fade = nodes.new("ShaderNodeMapRange")
        horizon_fade.interpolation_type = "SMOOTHSTEP"
        links.new(upc, horizon_fade.inputs["Value"])
        horizon_fade.inputs["From Min"].default_value = 0.0
        horizon_fade.inputs["From Max"].default_value = 0.08
        amt = math_node("MULTIPLY", cover.outputs[0], horizon_fade.outputs[0])
        shade = (1.0 - 0.45 * cloudiness) * (1.0 - 0.1 * cloudiness)
        cl = (shade, shade, shade)
        if sun:
            sc = col3(sun.get("color"))
            cl = tuple(shade * (0.65 + 0.35 * c) for c in sc)
        col = mix_col(amt, col, cl)
        flat = 0.72 * 0.9
        col = mix_col(math_node("MULTIPLY", is_up, cloudiness * cloudiness * 0.6), col, (flat, flat * 1.03, flat * 1.07))
    scale = nodes.new("ShaderNodeVectorMath")
    scale.operation = "SCALE"
    links.new(col, scale.inputs[0])
    scale.inputs["Scale"].default_value = energy
    return scale.outputs[0]


def sky_colour(dirs):
    """The sky's colour along directions (n, 3, Blender axes), without clouds,
    for the fog's aerial perspective. A photo sky is sampled small."""
    w = WORLD_INFO
    up = dirs[:, 2]
    if w.get("kind") == "hdri" and "_small" in w:
        small = w["_small"]
        h, wd = small.shape[:2]
        rot = math.pi * 0.5 + float(w.get("rotation", 0.0))
        x, y = dirs[:, 0], dirs[:, 1]
        cx, sx = math.cos(rot), math.sin(rot)
        xr, yr = x * cx - y * sx, x * sx + y * cx
        u = (0.5 - np.arctan2(yr, xr) / (2 * math.pi)) % 1.0
        v = np.arccos(np.clip(up, -1, 1)) / math.pi
        px = np.clip((u * wd).astype(int), 0, wd - 1)
        py = np.clip((v * h).astype(int), 0, h - 1)
        return small[py, px, :3] * float(w.get("strength", 1.0))
    if w.get("kind") == "color":
        return np.tile(np.array(col3(w.get("color"))), (dirs.shape[0], 1))
    top = np.array(col3(w.get("top"), (0.22, 0.42, 0.78)))
    hor = np.array(col3(w.get("horizon"), (0.66, 0.77, 0.9)))
    gnd = np.array(col3(w.get("ground"), (0.3, 0.28, 0.25)))
    a = np.power(np.clip(up, 0, 1), 0.5)[:, None]
    b = np.power(np.clip(-up, 0, 1), 0.35)[:, None]
    sky = hor * (1 - a) + top * a
    ground = hor * (1 - b) + gnd * b
    col = np.where(up[:, None] > 0, sky, ground)
    return col * float(w.get("energy", 1.0))


def prepare_sky_sample():
    w = WORLD_INFO
    if w.get("kind") != "hdri" or not w.get("hdri"):
        return
    try:
        img = bpy.data.images.load(_abs(w["hdri"]), check_existing=True)
        sw, sh = img.size
        px = np.empty(sw * sh * 4, dtype=np.float32)
        img.pixels.foreach_get(px)
        px = px.reshape(sh, sw, 4)[::-1]
        # Small and blurred, as Godot reads its sky for fog (a high mip).
        fy, fx = max(1, sh // 32), max(1, sw // 64)
        small = px[:sh - sh % fy, :sw - sw % fx].reshape(sh // fy, fy, sw // fx, fx, 4).mean(axis=(1, 3))
        w["_small"] = small
    except Exception as e:
        warn_once("skysample", "the photo sky could not be read for the fog (%s)" % e)


# ----------------------------------------------------------------- haze

_HAZE = []


def build_haze(h):
    """Stage haze (the editor's volumetric fog): a box of scattering air
    around the design, so lights draw beams in it."""
    for o in _HAZE:
        bpy.data.objects.remove(o, do_unlink=True)
    _HAZE.clear()
    if not h or float(h.get("density", 0.0)) <= 0.0:
        return
    b = h.get("bounds")
    if not b:
        return
    lo = gvec(b[0:3])
    hi = gvec(b[3:6])
    mn = Vector((min(lo.x, hi.x), min(lo.y, hi.y), min(lo.z, hi.z)))
    mx = Vector((max(lo.x, hi.x), max(lo.y, hi.y), max(lo.z, hi.z)))
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(mn + mx) * 0.5)
    o = bpy.context.active_object
    o.name = "oriel_haze"
    o.scale = mx - mn
    mat = bpy.data.materials.new("oriel_haze")
    mat.use_nodes = True
    nt = mat.node_tree
    for n in list(nt.nodes):
        nt.nodes.remove(n)
    outn = nt.nodes.new("ShaderNodeOutputMaterial")
    vol = nt.nodes.new("ShaderNodeVolumePrincipled")
    vol.inputs["Density"].default_value = float(h["density"]) * float(h.get("scale", 1.0))
    vol.inputs["Anisotropy"].default_value = float(h.get("anisotropy", 0.2))
    vol.inputs["Color"].default_value = (*col3(h.get("albedo"), (1, 1, 1)), 1.0)
    nt.links.new(vol.outputs[0], outn.inputs["Volume"])
    o.data.materials.append(mat)
    _HAZE.append(o)
    sc = bpy.context.scene
    if is_eevee_next():
        try:
            sc.eevee.use_volumetric_shadows = True
            sc.eevee.volumetric_tile_size = "4"
        except Exception:
            pass
    log("haze box %s" % (tuple(round(x, 1) for x in o.scale),))


# ----------------------------------------------------------------- texts


def build_texts():
    for i, t in enumerate(SCENE.get("texts", [])):
        try:
            cu = bpy.data.curves.new("oriel_text_%d" % i, "FONT")
            cu.body = t.get("text", "")
            cu.size = float(t.get("size", 0.25))
            cu.align_x = {"left": "LEFT", "right": "RIGHT"}.get(t.get("align", "center"), "CENTER")
            cu.align_y = "CENTER"
            cu.extrude = float(t.get("depth", 0.0))
            o = bpy.data.objects.new(cu.name, cu)
            # A text faces +Z in Blender and -Z... Godot's Label3D faces +Z too.
            o.matrix_world = view_matrix(t["matrix"])
            mat = bpy.data.materials.new(cu.name)
            mat.use_nodes = True
            bsdf = principled(mat)
            c = col3(t.get("color"))
            if t.get("unshaded", True):
                set_input(bsdf, "Base Color", (0, 0, 0, 1))
                set_input(bsdf, ("Emission Color", "Emission"), (*c, 1.0))
                set_input(bsdf, "Emission Strength", 1.0)
            else:
                set_input(bsdf, "Base Color", (*c, 1.0))
            cu.materials.append(mat)
            bpy.context.scene.collection.objects.link(o)
        except Exception as e:
            warn_once("text", "a text could not be drawn (%s)" % e)


# --------------------------------------------------------------------------
# The engine
# --------------------------------------------------------------------------

ENGINE = JOB.get("engine", "cycles")
QUALITY = JOB.get("quality", {})
DENOISE_OK = True


def setup_engine():
    global DENOISE_OK
    sc = bpy.context.scene
    sc.render.engine = engine_identifier(ENGINE)
    STATUS.set(engine=sc.render.engine)
    samples = int(QUALITY.get("samples", 128))
    if ENGINE == "cycles":
        cy = sc.cycles
        cy.samples = samples
        try:
            cy.use_adaptive_sampling = True
            cy.adaptive_threshold = float(QUALITY.get("noise", 0.01))
        except Exception:
            pass
        if QUALITY.get("time_limit"):
            try:
                cy.time_limit = float(QUALITY["time_limit"])
            except Exception:
                pass
        cy.max_bounces = int(QUALITY.get("bounces", 12))
        cy.diffuse_bounces = min(cy.max_bounces, int(QUALITY.get("diffuse_bounces", 4)))
        cy.glossy_bounces = min(cy.max_bounces, 4)
        cy.transmission_bounces = cy.max_bounces
        cy.volume_bounces = 1
        # Leaves and fences are cut-outs: many layers of them must be seen through.
        cy.transparent_max_bounces = 64
        cy.sample_clamp_indirect = float(QUALITY.get("clamp_indirect", 10.0))
        cy.caustics_reflective = False
        cy.caustics_refractive = False
        try:
            cy.blur_glossy = 1.0
        except Exception:
            pass
        DENOISE_OK = bool(QUALITY.get("denoise", True)) and _has_denoiser()
        if QUALITY.get("denoise", True) and not DENOISE_OK:
            warn_once("oidn", "this Blender has no denoiser, so Cycles renders are noisier; Blender from blender.org has it")
        cy.use_denoising = DENOISE_OK
        if DENOISE_OK:
            try:
                cy.denoiser = "OPENIMAGEDENOISE"
            except Exception:
                pass
        sc.render.use_persistent_data = True
        dev = _cycles_device(JOB.get("device", "auto"))
        STATUS.set(device=dev)
    else:
        ee = sc.eevee
        ee.taa_render_samples = samples
        if is_eevee_next():
            for attr, val in (("use_raytracing", True), ("use_shadows", True), ("shadow_ray_count", 2),
                              ("shadow_step_count", 8), ("use_fast_gi", True), ("use_volumetric_shadows", True),
                              ("fast_gi_distance", 0.0), ("light_threshold", 0.01)):
                try:
                    setattr(ee, attr, val)
                except Exception:
                    pass
            try:
                ee.ray_tracing_method = "SCREEN"
                ee.ray_tracing_options.resolution_scale = "1"
                ee.ray_tracing_options.use_denoise = True
            except Exception:
                pass
        else:
            for attr, val in (("use_gtao", True), ("gtao_distance", 1.0), ("use_ssr", True), ("use_ssr_refraction", True),
                              ("use_soft_shadows", True), ("shadow_cube_size", "2048"), ("shadow_cascade_size", "4096"),
                              ("use_shadow_high_bitdepth", True), ("use_bloom", False), ("use_volumetric_shadows", True)):
                try:
                    setattr(ee, attr, val)
                except Exception:
                    pass
        STATUS.set(device="GPU (Eevee)")
    sc.render.film_transparent = False
    sc.render.filter_size = 1.5
    vl = sc.view_layers[0]
    vl.use_pass_combined = True
    vl.use_pass_z = True
    vl.use_pass_normal = True
    st = sc.render.image_settings
    if hasattr(st, "media_type"):          # Blender 5: a multilayer file is a media type
        st.media_type = "MULTI_LAYER_IMAGE"
    st.file_format = "OPEN_EXR_MULTILAYER"
    st.color_depth = "32"
    try:
        st.exr_codec = "NONE"
    except Exception:
        pass


def _has_denoiser():
    """Ubuntu's own Blender package is built without OpenImageDenoise, and
    asking it to denoise stops the render."""
    try:
        import _cycles
        return bool(getattr(_cycles, "with_openimagedenoise", True))
    except Exception:
        return True


def _cycles_device(want):
    sc = bpy.context.scene
    if want == "cpu":
        sc.cycles.device = "CPU"
        return "CPU"
    try:
        prefs = bpy.context.preferences.addons["cycles"].preferences
    except Exception:
        sc.cycles.device = "CPU"
        return "CPU"
    for kind in ("OPTIX", "CUDA", "HIP", "ONEAPI", "METAL"):
        try:
            prefs.compute_device_type = kind
        except Exception:
            continue
        try:
            if hasattr(prefs, "refresh_devices"):
                prefs.refresh_devices()
            else:
                prefs.get_devices()
        except Exception:
            pass
        devs = [d for d in prefs.devices if d.type == kind]
        if devs:
            for d in prefs.devices:
                d.use = d.type == kind
            sc.cycles.device = "GPU"
            return "%s (%s)" % (kind, ", ".join(d.name for d in devs))
    try:
        prefs.compute_device_type = "NONE"
    except Exception:
        pass
    sc.cycles.device = "CPU"
    if want == "gpu":
        warn_once("nogpu", "no graphics card Cycles can use was found, so the processor rendered")
    return "CPU"


# --------------------------------------------------------------------------
# Cameras
# --------------------------------------------------------------------------


def make_camera(spec, size):
    sc = bpy.context.scene
    cam = sc.camera
    if cam is None:
        data = bpy.data.cameras.new("oriel_camera")
        cam = bpy.data.objects.new("oriel_camera", data)
        sc.collection.objects.link(cam)
        sc.camera = cam
    d = cam.data
    w, h = int(size[0]), int(size[1])
    sc.render.resolution_x = w
    sc.render.resolution_y = h
    sc.render.pixel_aspect_x = sc.render.pixel_aspect_y = 1.0
    cam.matrix_world = view_matrix(spec["matrix"])
    d.clip_start = max(float(spec.get("near", 0.05)), 1e-4)
    d.clip_end = max(float(spec.get("far", 4000.0)), d.clip_start + 1.0)
    proj = spec.get("projection", "persp")
    d.shift_x = 0.0
    d.shift_y = 0.0
    if proj == "ortho":
        d.type = "ORTHO"
        d.sensor_fit = "VERTICAL" if spec.get("keep", "height") == "height" else "HORIZONTAL"
        d.ortho_scale = float(spec.get("size", 10.0))
        if d.sensor_fit == "VERTICAL" and w > h:
            # Blender's ortho scale spans the larger side whatever the fit.
            d.ortho_scale = float(spec.get("size", 10.0)) * w / h
    elif proj == "pano":
        d.type = "PANO"
        try:
            d.panorama_type = "EQUIRECTANGULAR"
        except Exception:
            d.cycles.panorama_type = "EQUIRECTANGULAR"
    else:
        d.type = "PERSP"
        d.lens_unit = "FOV"
        d.sensor_fit = "VERTICAL" if spec.get("keep", "height") == "height" else "HORIZONTAL"
        d.angle = max(min(float(spec.get("fov", 75.0)), 175.0), 1.0) * math.pi / 180.0
        sh = spec.get("shift")
        if sh:
            # Shift is a fraction of the larger side of the frame.
            big = max(w, h)
            d.shift_x = float(sh[0]) * w / big
            d.shift_y = float(sh[1]) * h / big
    dof = spec.get("dof")
    d.dof.use_dof = bool(dof)
    if dof:
        d.dof.focus_distance = max(float(dof.get("focus", 10.0)), 0.05)
        d.dof.aperture_fstop = max(float(dof.get("fstop", 4.0)), 0.5)
    return cam


# --------------------------------------------------------------------------
# Rendering and the finishing
# --------------------------------------------------------------------------

def _render(path):
    sc = bpy.context.scene
    sc.render.filepath = path
    try:
        bpy.ops.render.render(write_still=True)
    except RuntimeError as e:
        global DENOISE_OK
        if "OpenImageDenoise" in str(e) or "OpenImageDenoiser" in str(e):
            DENOISE_OK = False
            sc.cycles.use_denoising = False
            warn_once("oidn", "this Blender has no denoiser, so Cycles renders are noisier; Blender from blender.org has it")
            bpy.ops.render.render(write_still=True)
        else:
            raise
    if not os.path.exists(path):
        raise RuntimeError("Blender rendered nothing to %s" % path)


def render_layers(name):
    """One render of the current camera into {'rgba', 'depth', 'normal'}."""
    path = os.path.join(JOB_DIR, "tmp_%s.exr" % name)
    _render(path)
    layers = read_exr(path)
    try:
        os.remove(path)
    except OSError:
        pass
    r = find_channel(layers, "Combined.R", "R")
    g = find_channel(layers, "Combined.G", "G")
    b = find_channel(layers, "Combined.B", "B")
    a = find_channel(layers, "Combined.A", "A")
    rgba = np.stack([r, g, b, a if a is not None else np.ones_like(r)], axis=-1)
    depth = find_channel(layers, "Depth.Z", "Z")
    nx = find_channel(layers, "Normal.X")
    normal = None
    if nx is not None:
        normal = np.stack([nx, find_channel(layers, "Normal.Y"), find_channel(layers, "Normal.Z")], axis=-1)
    return {"rgba": rgba, "depth": depth, "normal": normal}


def view_directions(cam, w, h):
    """Unit world directions (Blender axes) through each pixel centre."""
    d = cam.data
    sc = bpy.context.scene
    frame = d.view_frame(scene=sc)  # four corners in camera space at some depth
    xs = [v.x for v in frame]
    ys = [v.y for v in frame]
    z = frame[0].z
    if d.type == "ORTHO":
        fwd = (cam.matrix_world.to_3x3() @ Vector((0, 0, -1))).normalized()
        return np.tile(np.array(fwd), (h * w, 1)).reshape(h, w, 3)
    u = np.linspace(min(xs), max(xs), w, endpoint=False) + (max(xs) - min(xs)) / w * 0.5
    v = np.linspace(max(ys), min(ys), h, endpoint=False) - (max(ys) - min(ys)) / h * 0.5
    uu, vv = np.meshgrid(u, v)
    dirs = np.stack([uu, vv, np.full_like(uu, z)], axis=-1)
    rot = np.array(cam.matrix_world.to_3x3())
    dirs = dirs @ rot.T
    return dirs / np.linalg.norm(dirs, axis=-1, keepdims=True)


def apply_fog(rgb, depth, dirs, fog):
    """Godot's depth fog, where the editor applies it: on linear light before
    exposure and the tone curve."""
    if not fog or float(fog.get("density", 0.0)) <= 0.0:
        return rgb
    h, w = rgb.shape[:2]
    rho = float(fog["density"])
    flat = dirs.reshape(-1, 3)
    colour = np.tile(np.array(col3(fog.get("color"), (0.5, 0.6, 0.7))) * float(fog.get("energy", 1.0)), (h * w, 1))
    aerial = float(fog.get("aerial", 0.0))
    if aerial > 0.0:
        colour = colour * (1 - aerial) + sky_colour(flat) * aerial
    scatter = float(fog.get("sun_scatter", 0.0))
    sun = fog.get("sun")
    if scatter > 0.0 and sun:
        sd = np.array(gvec(sun["toward"]))
        amount = np.power(np.clip(flat @ sd, 0, 1), 8.0)[:, None]
        colour = colour + np.array(col3(sun.get("color"))) * float(sun.get("energy", 1.0)) * amount * scatter
    colour = colour.reshape(h, w, 3)
    if depth is None:
        return rgb
    sky = depth > 1e9
    dist = np.where(sky, 0.0, depth)
    # Blender's Z pass is distance along the view axis; Godot's fog uses the
    # distance to the point.
    cam_fwd = np.array(bpy.context.scene.camera.matrix_world.to_3x3() @ Vector((0, 0, -1)))
    cosang = np.clip(dirs @ cam_fwd, 1e-3, 1.0)
    if bpy.context.scene.camera.data.type != "PANO":
        dist = dist / cosang
    amount = 1.0 - np.exp(-dist * rho)
    hd = float(fog.get("height_density", 0.0))
    if abs(hd) >= 1e-4:
        cam_z = bpy.context.scene.camera.matrix_world.translation.z
        z = cam_z + dirs[..., 2] * dist
        vfog = 1.0 - np.exp(np.minimum(0.0, (z - float(fog.get("height", 0.0))) * hd))
        amount = np.maximum(amount, vfog)
    amount = np.where(sky, float(fog.get("sky_affect", 1.0)), amount)[..., None]
    return rgb * (1 - amount) + colour * amount


def _blur(img, radius):
    """A fast, wide blur: three box passes along each axis (close to a Gaussian)."""
    r = max(int(radius), 1)
    out = img
    for axis in (0, 1):
        for _ in range(3):
            c = np.cumsum(out, axis=axis, dtype=np.float64)
            pad = [(0, 0)] * out.ndim
            pad[axis] = (r + 1, r)
            c = np.pad(c, pad, mode="edge")
            n = out.shape[axis]
            hi = np.take(c, np.arange(2 * r + 1, 2 * r + 1 + n), axis=axis)
            lo = np.take(c, np.arange(0, n), axis=axis)
            out = ((hi - lo) / (2 * r + 1)).astype(np.float32)
    return out


def apply_glow(rgb, g, white):
    """Godot's glow: what is brighter than the threshold, spread at several
    sizes, then blended in the way the scene's environment says."""
    if not g or not g.get("enabled"):
        return rgb, None
    h, w = rgb.shape[:2]
    lum = rgb.max(axis=-1, keepdims=True)
    thr = float(g.get("hdr_threshold", 1.0))
    scale = float(g.get("hdr_scale", 2.0))
    bloom = float(g.get("bloom", 0.0))
    bright = np.maximum(rgb * (np.maximum(lum - thr, 0.0) / np.maximum(lum, 1e-6)) * scale, 0.0) + rgb * bloom
    levels = g.get("levels", [0, 0, 1, 0, 1, 0, 0])
    total = sum(levels) or 1.0
    norm = g.get("normalized", False)
    glow = np.zeros_like(rgb)
    # Downsample once for speed: glow is soft anyway.
    f = max(1, int(round(max(h, w) / 960.0)))
    small = bright[:h - h % f, :w - w % f].reshape(h // f, f, w // f, f, 3).mean(axis=(1, 3)) if f > 1 else bright
    base = max(h, w) / 1920.0 / f
    for i, lv in enumerate(levels):
        if lv <= 0.0001:
            continue
        rad = (2 ** (i + 1)) * base * 2.0
        b = _blur(small, max(rad, 1))
        glow_l = np.repeat(np.repeat(b, f, axis=0), f, axis=1) if f > 1 else b
        if glow_l.shape[:2] != rgb.shape[:2]:
            glow_l = np.pad(glow_l, ((0, h - glow_l.shape[0]), (0, w - glow_l.shape[1]), (0, 0)), mode="edge")
        glow += glow_l * (lv / total if norm else lv)
    glow *= float(g.get("intensity", 0.8)) * float(g.get("strength", 1.0))
    mode = g.get("blend", "softlight")
    if mode == "additive":
        return rgb + glow, None
    if mode == "screen":
        gl = np.clip(glow, 0, white)
        return rgb + gl - rgb * gl / white, None
    if mode == "replace":
        return glow, None
    if mode == "mix":
        return rgb * (1 - float(g.get("intensity", 0.8))) + glow, None
    return rgb, glow   # soft light goes on after the tone curve


def _aces(c):
    A, B, Cc, D, E = 0.0245786, 0.000090537, 0.983729, 0.432951, 0.238081
    return (c * (c + A) - B) / (c * (Cc * c + D) + E)


ACES_IN = np.array([[0.59719, 0.35458, 0.04823], [0.07600, 0.90834, 0.01566], [0.02840, 0.13383, 0.83777]]) * 1.8
ACES_OUT = np.array([[1.60475, -0.53108, -0.07367], [-0.10208, 1.10813, -0.00605], [-0.00327, -0.07276, 1.07602]])
AGX_IN = np.array([[0.544814746488245, 0.140416948464053, 0.0888104196149096],
                   [0.373787398372697, 0.754137554567394, 0.178871756420858],
                   [0.0813978551390581, 0.105445496968552, 0.732317823964232]]).T
AGX_OUT = np.array([[1.96488741169489, -0.299313364904742, -0.164352742528393],
                    [-0.855988495690215, 1.32639796461980, -0.238183969428088],
                    [-0.108898916004672, -0.0270845997150571, 1.40253671195648]]).T


def tonemap(rgb, mode, white, agx_contrast=1.25):
    """The editor's tone curves (Godot 4.7), on linear light."""
    if mode == "linear":
        return rgb
    rgb = np.maximum(rgb, 0.0)
    if mode == "reinhard":
        w2 = max(white, 1.0) ** 2
        return rgb * (1.0 + rgb / w2) / (1.0 + rgb)
    if mode == "filmic":
        bias = 2.0
        A, B, Cc, D, E, F = 0.22 * bias * bias, 0.30 * bias, 0.10, 0.20, 0.01, 0.30
        wt = max(white, 1.0)
        wt_t = ((wt * (0.22 * wt + Cc * 0.30) + D * E) / (wt * (0.22 * wt + 0.30) + D * F)) - E / F
        t = ((rgb * (A * rgb + Cc * B) + D * E) / (rgb * (A * rgb + B) + D * F)) - E / F
        return t / wt_t
    if mode == "agx":
        wt = max(white, 2.0)
        cross = 0.18
        shoulder_max = 1.0 - cross
        toe_a = ((1.0 / cross) - 1.0) * cross ** agx_contrast
        sd = cross ** agx_contrast + toe_a
        slope = (agx_contrast * cross ** (agx_contrast - 1.0) * toe_a) / (sd * sd)
        aw = ((wt - cross) ** 2) / shoulder_max * slope
        x = rgb @ AGX_IN.T
        s = x - cross
        ss = slope * s
        s = ss * (1.0 + s / aw) / (1.0 + ss / shoulder_max) + cross
        t = np.power(np.maximum(x, 0.0), agx_contrast)
        t = t / (t + toe_a)
        y = np.where(x < cross, t, s)
        y = np.minimum(y, 1.0)
        return y @ AGX_OUT.T
    # ACES (the editor's default)
    wt = max(white, 1.0) * 1.8
    x = rgb @ ACES_IN.T
    y = _aces(x) @ ACES_OUT.T
    return y / _aces(wt)


def to_srgb(c):
    c = np.clip(c, 0.0, None)
    return np.where(c < 0.0031308, 12.92 * c, 1.055 * np.power(c, 1.0 / 2.4) - 0.055)


def finish(layers, cam, post, fog, keep_alpha=False):
    """Linear render -> the editor's grading -> 8-bit sRGB."""
    rgba = layers["rgba"]
    rgb = rgba[..., :3].astype(np.float32)
    h, w = rgb.shape[:2]
    if fog and float(fog.get("density", 0.0)) > 0 and layers.get("depth") is not None:
        dirs = view_directions(cam, w, h) if cam.data.type != "PANO" else layers.get("dirs")
        if dirs is not None:
            rgb = apply_fog(rgb, layers["depth"], dirs, fog)
    rgb = rgb * float(post.get("exposure", 1.0))
    white = float(post.get("white", 1.0))
    rgb, soft = apply_glow(rgb, post.get("glow"), white)
    mode = post.get("tonemap", "aces")
    rgb = tonemap(rgb, mode, white, float(post.get("agx_contrast", 1.25)))
    if soft is not None:
        g = np.clip(tonemap(soft, mode, white), 0, 1)
        lo = ((16 * rgb - 12) * rgb + 4) * rgb
        hi = np.sqrt(np.clip(rgb, 0, None))
        rgb = np.where(rgb > 1.0, rgb, rgb + g * (np.where(rgb <= 0.25, lo, hi) - rgb))
    bcs = post.get("bcs")
    if bcs:
        rgb = to_srgb(rgb * float(bcs[0]))
        rgb = 0.5 + (rgb - 0.5) * float(bcs[1])
        grey = rgb.mean(axis=-1, keepdims=True)
        rgb = grey + (rgb - grey) * float(bcs[2])
    else:
        rgb = to_srgb(rgb)
    if post.get("dither", True):
        yy, xx = np.mgrid[0:h, 0:w]
        d = np.mod(171.0 * xx + 231.0 * yy, np.array([103.0, 71.0, 97.0])[:, None, None])
        d = np.moveaxis(d / np.array([103.0, 71.0, 97.0])[:, None, None], 0, -1)
        rgb = rgb + (d - 0.5) / 255.0
    out8 = np.clip(np.round(rgb * 255.0), 0, 255).astype(np.uint8)
    if keep_alpha:
        a = np.clip(np.round(rgba[..., 3] * 255.0), 0, 255).astype(np.uint8)
        out8 = np.concatenate([out8, a[..., None]], axis=-1)
    return out8


# --------------------------------------------------------------------------
# What can be rendered
# --------------------------------------------------------------------------

def _out_path(name):
    return name if os.path.isabs(name) else os.path.join(OUT_DIR, name)


def _apply_overrides(r):
    ov = r.get("overrides") or {}
    if "lights" in ov:
        build_lights(ov["lights"])
    if "world" in ov:
        build_world(ov["world"])
        prepare_sky_sample()
    return ov


def _restore_overrides(ov):
    if "lights" in ov:
        build_lights(SCENE.get("lights", []))
    if "world" in ov:
        build_world(SCENE.get("world", {}))
        prepare_sky_sample()


def do_still(r, idx):
    ov = _apply_overrides(r)
    cam = make_camera(r["camera"], r["size"])
    clay = _clay_override(r.get("clay"))
    layers = render_layers("r%d" % idx)
    _clear_override(clay)
    fog = ov.get("fog", SCENE.get("fog"))
    post = dict(SCENE.get("post", {}))
    post.update(r.get("post", {}))
    img = finish(layers, cam, post, fog)
    path = _out_path(r["out"])
    write_png(path, img)
    STATUS.output(path)
    for p in r.get("passes", []):
        _write_pass(p, layers, cam, r, idx)
    _restore_overrides(ov)


def _write_pass(name, layers, cam, r, idx):
    base = os.path.splitext(_out_path(r["out"]))[0]
    path = "%s_%s.png" % (base, name)
    h, w = layers["rgba"].shape[:2]
    if name == "depth" and layers.get("depth") is not None:
        # As the editor's depth pass: distance to the camera, white near,
        # black at 150 m and beyond.
        d = layers["depth"].copy()
        valid = d < 1e9
        if cam.data.type == "PERSP":
            dirs = view_directions(cam, w, h)
            fwd = np.array(cam.matrix_world.to_3x3() @ Vector((0, 0, -1)))
            d = d / np.clip(dirs @ fwd, 1e-3, 1.0)
        g = np.where(valid, 1.0 - np.clip(d / 150.0, 0, 1), 0.0)
        img = np.repeat((np.clip(g, 0, 1) * 65535).astype(np.uint16)[..., None], 3, axis=-1)
        write_png(path, img)
    elif name == "normal" and layers.get("normal") is not None:
        n = layers["normal"].reshape(-1, 3)
        rot = np.array(cam.matrix_world.to_3x3())
        nv = n @ rot            # world -> camera space (rot is orthonormal)
        img = np.clip((nv.reshape(h, w, 3) * 0.5 + 0.5) * 255.0, 0, 255).astype(np.uint8)
        img[layers["depth"] > 1e9] = 0 if layers.get("depth") is not None else img[layers["depth"] > 1e9]
        write_png(path, img)
    elif name in ("id", "mask", "clay"):
        img = _override_pass(name, r, idx)
        if img is not None:
            write_png(path, img)
    else:
        return
    STATUS.output(path)


_OVERRIDE_MATS = {}


def _override_material(kind):
    if kind in _OVERRIDE_MATS:
        return _OVERRIDE_MATS[kind]
    mat = bpy.data.materials.new("oriel_" + kind)
    mat.use_nodes = True
    nt = mat.node_tree
    for n in list(nt.nodes):
        nt.nodes.remove(n)
    outn = nt.nodes.new("ShaderNodeOutputMaterial")
    if kind == "clay":
        b = nt.nodes.new("ShaderNodeBsdfDiffuse")
        b.inputs["Color"].default_value = (0.8, 0.8, 0.8, 1)
        nt.links.new(b.outputs[0], outn.inputs["Surface"])
    elif kind == "id":
        # Each object in the flat colour the editor gives it (set as the
        # object's colour when the scene was built).
        info = nt.nodes.new("ShaderNodeObjectInfo")
        em = nt.nodes.new("ShaderNodeEmission")
        nt.links.new(out(info, "Color"), em.inputs["Color"])
        nt.links.new(em.outputs[0], outn.inputs["Surface"])
    else:  # mask
        em = nt.nodes.new("ShaderNodeEmission")
        em.inputs["Color"].default_value = (1, 1, 1, 1)
        nt.links.new(em.outputs[0], outn.inputs["Surface"])
    _OVERRIDE_MATS[kind] = mat
    return mat


def _clay_override(on):
    if not on:
        return None
    vl = bpy.context.scene.view_layers[0]
    vl.material_override = _override_material("clay")
    return True


def _clear_override(tok):
    if tok:
        bpy.context.scene.view_layers[0].material_override = None


def _override_pass(kind, r, idx):
    sc = bpy.context.scene
    vl = sc.view_layers[0]
    keep = (vl.material_override, sc.render.film_transparent)
    hidden = []
    vl.material_override = _override_material(kind)
    if kind in ("id", "mask"):
        sc.render.film_transparent = True
        if kind == "mask":
            for name, spec in SCENE.get("objects", {}).items():
                o = OBJECTS.get(name)
                if o is not None and spec.get("ground") and not o.hide_render:
                    o.hide_render = True
                    hidden.append(o)
    samples_keep = None
    if ENGINE == "cycles" and kind != "clay":
        samples_keep = (sc.cycles.samples, sc.cycles.use_denoising)
        sc.cycles.samples = 16
        sc.cycles.use_denoising = False
    elif ENGINE != "cycles" and kind != "clay":
        samples_keep = (sc.eevee.taa_render_samples, None)
        sc.eevee.taa_render_samples = 16
    try:
        layers = render_layers("%s%d" % (kind, idx))
    finally:
        vl.material_override, sc.render.film_transparent = keep
        for o in hidden:
            o.hide_render = False
        if samples_keep:
            if ENGINE == "cycles":
                sc.cycles.samples, sc.cycles.use_denoising = samples_keep
            else:
                sc.eevee.taa_render_samples = samples_keep[0]
    rgba = layers["rgba"]
    if kind == "mask":
        a = np.clip(rgba[..., 3], 0, 1)
        return np.repeat((a * 255).astype(np.uint8)[..., None], 3, axis=-1)
    if kind == "id":
        # The colours were given in sRGB by the editor and rendered as linear
        # light: written back as they were given.
        rgb = np.clip(rgba[..., :3], 0, 1) * np.clip(rgba[..., 3:4], 0, 1)
        return np.round(rgb * 255).astype(np.uint8)
    post = SCENE.get("post", {})
    cam = sc.camera
    return finish(layers, cam, post, SCENE.get("fog"))


# ----------------------------------------------------------------- panoramas

FACES = {  # Godot's cube faces: direction and up, in Godot axes
    "px": ((1, 0, 0), (0, 1, 0)), "nx": ((-1, 0, 0), (0, 1, 0)),
    "py": ((0, 1, 0), (0, 0, 1)), "ny": ((0, -1, 0), (0, 0, -1)),
    "pz": ((0, 0, 1), (0, 1, 0)), "nz": ((0, 0, -1), (0, 1, 0)),
}


def _look_matrix(pos, fwd, up):
    """A 3 x 4 Godot transform looking along fwd (Godot axes)."""
    f = np.array(fwd, dtype=float)
    f /= np.linalg.norm(f)
    u = np.array(up, dtype=float)
    x = np.cross(u, -f)   # Godot: basis.z = -forward
    x /= np.linalg.norm(x)
    z = -f
    y = np.cross(z, x)
    return [x[0], y[0], z[0], pos[0], x[1], y[1], z[1], pos[1], x[2], y[2], z[2], pos[2]]


def do_panorama(r, idx):
    ov = _apply_overrides(r)
    width = int(r.get("width", 4096))
    stereo = bool(r.get("stereo"))
    cam_spec = dict(r["camera"])
    m = cam_spec["matrix"]
    pos = (m[3], m[7], m[11])
    post = dict(SCENE.get("post", {}))
    post.update(r.get("post", {}))
    fog = ov.get("fog", SCENE.get("fog"))
    if ENGINE == "cycles":
        spec = {"matrix": _look_matrix(pos, (0, 0, -1), (0, 1, 0)), "projection": "pano",
                "near": cam_spec.get("near", 0.05), "far": cam_spec.get("far", 4000.0)}
        cam = make_camera(spec, (width, width // 2))
        if stereo:
            img = _stereo_pano(cam, width, post, fog, idx)
        else:
            layers = render_layers("pano%d" % idx)
            layers["dirs"] = _equirect_dirs(width, width // 2)
            img = finish(layers, cam, post, fog)
    else:
        if stereo:
            warn_once("eeveestereo", "a stereo 360 needs Cycles; it was rendered with Cycles")
        img = _eevee_pano(pos, width, cam_spec, post, fog, idx)
    path = _out_path(r["out"])
    write_png(path, img)
    STATUS.output(path)
    _restore_overrides(ov)


def _equirect_dirs(w, h):
    """Directions (Blender axes) through each pixel of a Blender equirect image
    from a camera looking along Godot's -Z (Blender +Y)."""
    u = (np.arange(w) + 0.5) / w
    v = (np.arange(h) + 0.5) / h
    uu, vv = np.meshgrid(u, v)
    lon = (uu - 0.5) * 2 * math.pi        # 0 at the centre, + to the right
    lat = (0.5 - vv) * math.pi
    # Centre looks at +Y (Godot -Z); right is +X.
    x = np.cos(lat) * np.sin(lon)
    y = np.cos(lat) * np.cos(lon)
    z = np.sin(lat)
    return np.stack([x, y, z], axis=-1)


def _stereo_pano(cam, width, post, fog, idx):
    sc = bpy.context.scene
    sc.render.use_multiview = True
    sc.render.views_format = "STEREO_3D"
    st = cam.data.stereo
    try:
        st.use_spherical_stereo = True
    except Exception:
        pass
    st.interocular_distance = 0.064
    st.convergence_mode = "PARALLEL"
    try:
        st.use_pole_merge = True
    except Exception:
        pass
    sc.render.image_settings.views_format = "INDIVIDUAL"
    base = os.path.join(JOB_DIR, "tmp_stereo%d" % idx)
    sc.render.filepath = base + ".exr"
    _render_multiview(base)
    eyes = []
    for suffix in ("_L", "_R"):
        p = base + suffix + ".exr"
        if not os.path.exists(p):
            cand = [f for f in os.listdir(JOB_DIR) if f.startswith(os.path.basename(base)) and suffix in f]
            p = os.path.join(JOB_DIR, cand[0]) if cand else p
        layers = read_exr(p)
        os.remove(p)
        r_ = find_channel(layers, "Combined.R", "R")
        rgba = np.stack([r_, find_channel(layers, "Combined.G", "G"), find_channel(layers, "Combined.B", "B"),
                         np.ones_like(r_)], axis=-1)
        eye = {"rgba": rgba, "depth": find_channel(layers, "Depth.Z", "Z"), "dirs": _equirect_dirs(width, width // 2)}
        eyes.append(finish(eye, cam, post, fog))
    sc.render.use_multiview = False
    return np.concatenate(eyes, axis=0)


def _render_multiview(base):
    try:
        bpy.ops.render.render(write_still=True)
    except RuntimeError as e:
        if "OpenImageDenoise" in str(e):
            bpy.context.scene.cycles.use_denoising = False
            bpy.ops.render.render(write_still=True)
        else:
            raise


def _eevee_pano(pos, width, cam_spec, post, fog, idx):
    """Eevee has no panoramic camera: six square views with a margin, stitched."""
    face = max(256, width // 4)
    margin = 4
    n = face + 2 * margin
    fov = 2.0 * math.degrees(math.atan(n / face))
    faces = {}
    for k, (fwd, up) in FACES.items():
        spec = {"matrix": _look_matrix(pos, fwd, up), "fov": fov, "near": cam_spec.get("near", 0.05),
                "far": cam_spec.get("far", 4000.0), "keep": "height"}
        cam = make_camera(spec, (n, n))
        layers = render_layers("face_%s_%d" % (k, idx))
        # Fog per face, before the faces meet (it needs each face's depth).
        rgb = layers["rgba"][..., :3]
        if fog and float(fog.get("density", 0)) > 0 and layers.get("depth") is not None:
            rgb = apply_fog(rgb, layers["depth"], view_directions(cam, n, n), fog)
        faces[k] = rgb
    h = width // 2
    out = np.empty((h, width, 3), dtype=np.float32)
    dirs_all = _equirect_dirs(width, h)
    rows = max(1, 2_000_000 // width)
    for y0 in range(0, h, rows):
        d = dirs_all[y0:y0 + rows]
        # Blender axes back to Godot axes: (x, y, z) -> (x, z, -y)
        g = np.stack([d[..., 0], d[..., 2], -d[..., 1]], axis=-1)
        out[y0:y0 + rows] = _sample_cube(faces, g, face, margin)
    layers = {"rgba": np.concatenate([out, np.ones_like(out[..., :1])], axis=-1), "depth": None}
    cam = bpy.context.scene.camera
    return finish(layers, cam, post, None)


def _sample_cube(faces, g, face, margin):
    ax = np.abs(g)
    res = np.zeros(g.shape[:-1] + (3,), dtype=np.float32)
    major = np.argmax(ax, axis=-1)
    for k, (fwd, up) in FACES.items():
        f = np.array(fwd, dtype=float)
        u_ = np.array(up, dtype=float)
        axis = int(np.argmax(np.abs(f)))
        sign = f[axis]
        sel = (major == axis) & (np.sign(g[..., axis]) == sign)
        if not sel.any():
            continue
        v = g[sel]
        right = np.cross(f, u_)       # screen right for this face
        depth = v @ f
        sx = (v @ right) / depth
        sy = (v @ u_) / depth
        n = face + 2 * margin
        px = (sx * 0.5 * face + n * 0.5) - 0.5
        py = (-sy * 0.5 * face + n * 0.5) - 0.5
        res[sel] = _bilinear(faces[k], px, py)
    return res


def _bilinear(img, x, y):
    h, w = img.shape[:2]
    x = np.clip(x, 0, w - 1.001)
    y = np.clip(y, 0, h - 1.001)
    x0 = np.floor(x).astype(int)
    y0 = np.floor(y).astype(int)
    fx = (x - x0)[:, None]
    fy = (y - y0)[:, None]
    a = img[y0, x0]
    b = img[y0, x0 + 1]
    c = img[y0 + 1, x0]
    d = img[y0 + 1, x0 + 1]
    return (a * (1 - fx) + b * fx) * (1 - fy) + (c * (1 - fx) + d * fx) * fy


# ----------------------------------------------------------------- films


def do_frames(r, idx, base, span):
    """A film, frame by frame. Frames already on disk are kept (a stopped
    film resumes where it stopped)."""
    frames = r["frames"]
    pattern = r.get("pattern", "frame_%05d.png")
    folder = _out_path(r.get("folder", "frames"))
    os.makedirs(folder, exist_ok=True)
    post = dict(SCENE.get("post", {}))
    post.update(r.get("post", {}))
    size = r["size"]
    total = len(frames)
    moved = {}
    for i, fr in enumerate(frames):
        number = int(fr.get("number", i))
        path = os.path.join(folder, pattern % number)
        STATUS.span(base + span * i / total, span / total)
        if os.path.exists(path) and os.path.getsize(path) > 0:
            STATUS.output(path)
            continue
        STATUS.set(stage="frames", message="Frame %d of %d" % (i + 1, total))
        if "sun" in fr or "world" in fr or "lights" in fr:
            if "lights" in fr:
                build_lights(fr["lights"])
            if "world" in fr:
                build_world(fr["world"])
        for name, m in fr.get("nodes", {}).items():
            o = OBJECTS.get(name)
            if o is None:
                continue
            if name not in moved:
                moved[name] = o.matrix_world.copy()
                if o.parent:
                    mw = o.matrix_world.copy()
                    o.parent = None
                    o.matrix_world = mw
            o.matrix_world = object_matrix(m)
        for name, vis in fr.get("visible", {}).items():
            o = OBJECTS.get(name)
            if o is not None:
                o.hide_render = not vis
        cam = make_camera(fr["camera"], size)
        layers = render_layers("f%d" % number)
        fog = fr.get("fog", SCENE.get("fog"))
        p = dict(post)
        p.update(fr.get("post", {}))
        write_png(path, finish(layers, cam, p, fog))
        STATUS.output(path)


def do_pass(r, idx):
    cam = make_camera(r["camera"], r["size"])
    layers = render_layers("p%d" % idx) if r["pass"] in ("depth", "normal") else None
    if layers is None:
        layers = {"rgba": np.zeros((int(r["size"][1]), int(r["size"][0]), 4), dtype=np.float32)}
    _write_pass(r["pass"], layers, cam, r, idx)


# --------------------------------------------------------------------------
# Eevee's indirect light indoors: a light-probe volume over the design,
# baked once per job, when the job asks for it.
# --------------------------------------------------------------------------


def bake_probes(bounds):
    if ENGINE == "cycles" or not is_eevee_next() or not bounds:
        return
    try:
        lo = gvec(bounds[0:3])
        hi = gvec(bounds[3:6])
        mn = Vector((min(lo.x, hi.x), min(lo.y, hi.y), min(lo.z, hi.z)))
        mx = Vector((max(lo.x, hi.x), max(lo.y, hi.y), max(lo.z, hi.z)))
        kind = "VOLUME" if BV >= (4, 1, 0) else "GRID"
        bpy.ops.object.lightprobe_add(type=kind, location=(mn + mx) * 0.5)
        probe = bpy.context.active_object
        probe.scale = (mx - mn) * 0.5
        try:
            probe.data.resolution_x = probe.data.resolution_y = 16
            probe.data.resolution_z = 8
        except Exception:
            pass
        STATUS.set(stage="probes", message="Baking indirect light for Eevee")
        bpy.ops.object.lightprobe_cache_bake(subset="ALL")
        log("light probes baked")
    except Exception as e:
        warn_once("probes", "Eevee's indirect light could not be baked (%s); rooms may look darker than in Cycles" % e)


# --------------------------------------------------------------------------


def main():
    t0 = time.time()
    if JOB.get("schema") != SCHEMA:
        raise SystemExit("unknown job schema %s" % JOB.get("schema"))
    reset()
    STATUS.set(state="running", stage="scene", message="Setting up the scene", progress=0.01)
    import_glb(_abs(JOB["glb"]))
    apply_object_flags()
    fix_materials()
    build_instancers()
    build_lights(SCENE.get("lights", []))
    build_world(SCENE.get("world", {}))
    prepare_sky_sample()
    build_haze(SCENE.get("haze"))
    build_texts()
    setup_engine()
    if JOB.get("bake_probes"):
        bake_probes(SCENE.get("bounds"))
    renders = JOB.get("renders", [])
    weights = [max(len(r.get("frames", [])), 1) * (4 if r.get("kind") == "panorama" else 1) for r in renders]
    total = float(sum(weights)) or 1.0
    done = 0.0
    STATUS.set(progress=0.05)
    for i, r in enumerate(renders):
        base = 0.05 + 0.95 * done / total
        span = 0.95 * weights[i] / total
        STATUS.span(base, span)
        kind = r.get("kind", "still")
        STATUS.set(stage=kind, message=r.get("label", kind))
        if kind == "still":
            do_still(r, i)
        elif kind == "panorama":
            do_panorama(r, i)
        elif kind == "frames":
            do_frames(r, i, base, span)
        elif kind == "pass":
            do_pass(r, i)
        done += weights[i]
    STATUS.set(state="done", stage="", progress=1.0, message="Finished in %d s" % int(time.time() - t0))
    log("done in %.1f s" % (time.time() - t0))


try:
    main()
except SystemExit:
    raise
except Exception as e:
    STATUS.set(state="failed", error="%s: %s" % (type(e).__name__, e), message="The render failed")
    traceback.print_exc()
    sys.stdout.flush()
    os._exit(1)
sys.stdout.flush()
os._exit(0)
