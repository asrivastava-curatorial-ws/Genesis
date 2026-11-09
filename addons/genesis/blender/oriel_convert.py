"""Oriel's converter, run inside Blender in the background like oriel_render.py:

    python oriel_convert.py -- params.json        (or blender -b --python ... -- params.json)

params: {"mode": "hdr" | "material", "input": file, "output": file or folder, "result": result.json}
  hdr       an EXR sky (BlendKit's) written as a Radiance .hdr, which Oriel reads
  material  a material .blend (BlendKit's): its colour, normal, roughness and
            occlusion pictures written as PNG files, or its flat colour, so
            Oriel can make a preset of it
The result (paths, or an "error") is written to params["result"].
Part of Oriel, MIT licence.
"""
import json
import os
import sys
import traceback

import bpy

args = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else sys.argv[1:]
P = json.load(open(args[0], encoding="utf-8"))
OUT = P.get("result", os.path.join(os.path.dirname(args[0]), "result.json"))


def done(**kw):
    tmp = OUT + ".tmp"
    with open(tmp, "w", encoding="utf-8") as f:
        json.dump(kw, f)
    os.replace(tmp, OUT)


def to_hdr(src, dest):
    img = bpy.data.images.load(src)
    os.makedirs(os.path.dirname(dest), exist_ok=True)
    sc = bpy.context.scene
    st = sc.render.image_settings
    if hasattr(st, "media_type"):
        st.media_type = "IMAGE"
    st.file_format = "HDR"
    sc.view_settings.view_transform = "Standard"
    img.save_render(dest, scene=sc)
    done(error="", output=dest)


def _image_from(sock, seen=0):
    """The picture feeding a socket, through the usual in-between nodes."""
    if sock is None or not sock.is_linked or seen > 6:
        return None
    node = sock.links[0].from_node
    if node.bl_idname == "ShaderNodeTexImage" and node.image is not None:
        return node.image
    for name in ("Color", "Image", "Fac", "Value", "Height", "Normal"):
        if name in node.inputs:
            found = _image_from(node.inputs[name], seen + 1)
            if found is not None:
                return found
    for s in node.inputs:
        found = _image_from(s, seen + 1)
        if found is not None:
            return found
    return None


def material(src, outdir):
    bpy.ops.wm.open_mainfile(filepath=src)
    mats = [m for m in bpy.data.materials if m.use_nodes and m.users > 0 and m.name not in ("Dots Stroke", "Material")]
    if not mats:
        mats = [m for m in bpy.data.materials if m.use_nodes]
    if not mats:
        return done(error="the file has no material")
    mat = mats[0]
    bsdf = next((n for n in mat.node_tree.nodes if n.bl_idname == "ShaderNodeBsdfPrincipled"), None)
    if bsdf is None:
        return done(error="the material is not a Principled BSDF one")
    os.makedirs(outdir, exist_ok=True)
    result = {"error": "", "name": mat.name}
    wanted = {"albedo": "Base Color", "roughness": "Roughness", "normal": "Normal"}
    for key, sock_name in wanted.items():
        img = _image_from(bsdf.inputs.get(sock_name))
        if img is None:
            continue
        dest = os.path.join(outdir, "%s.png" % key)
        try:
            if img.packed_file is not None or not os.path.exists(bpy.path.abspath(img.filepath)):
                img.filepath_raw = dest
                img.file_format = "PNG"
                img.save()
            else:
                img2 = bpy.data.images.load(bpy.path.abspath(img.filepath))
                img2.filepath_raw = dest
                img2.file_format = "PNG"
                img2.save()
            result[key] = dest
        except Exception as e:  # keep what could be saved
            result.setdefault("warnings", []).append("%s: %s" % (key, e))
    base = bsdf.inputs.get("Base Color")
    if base is not None and not base.is_linked:
        c = base.default_value
        result["color"] = [c[0], c[1], c[2]]
    # BlendKit materials are usually made for a 2 m repeat on a 1 m cube.
    result["tile"] = 2.0
    done(**result)


try:
    if P["mode"] == "hdr":
        to_hdr(P["input"], P["output"])
    elif P["mode"] == "material":
        material(P["input"], P["output"])
    else:
        done(error="unknown mode %s" % P["mode"])
except Exception as e:
    traceback.print_exc()
    done(error="%s: %s" % (type(e).__name__, e))
sys.stdout.flush()
os._exit(0)
