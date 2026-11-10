"""Oriel's converter, run inside Blender in the background like oriel_render.py:

    python oriel_convert.py -- params.json        (or blender -b --python ... -- params.json)

params: {"mode": "hdr" | "material" | "model", "input": file, "output": file or folder, "result": result.json}
  hdr       an EXR sky (BlendKit's) written as a Radiance .hdr, which Oriel reads
  material  a material .blend (BlendKit's): its colour, normal, roughness and
            occlusion pictures written as PNG files, or its flat colour, so
            Oriel can make a preset of it
  model     a model in a format Oriel does not read itself, written as a .glb:
            USD, Alembic, PLY and STL through Blender's own readers; IFC
            (buildings from Revit, Archicad...) through IfcOpenShell; Collada,
            3DS and the other formats Assimp knows through Assimp. "up": "y"
            or "z" says which way is up in a file that does not say (PLY, STL)
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


# ----------------------------------------------------------------- models

USD_EXT = ("usd", "usda", "usdc", "usdz")
# What Assimp reads well enough to be worth offering (it knows more).
ASSIMP_EXT = ("dae", "3ds", "ase", "ac", "lwo", "lws", "x", "ms3d", "off", "3mf", "dxf", "cob", "md2", "md3", "md5mesh",
              "smd", "ogex", "xgl", "zgl", "irr", "irrmesh", "q3o", "q3s", "raw", "ter", "hmp", "nff", "ndo", "b3d", "bvh", "csm", "amf")


def _new_material(name, colour, alpha=1.0, texture=None):
    mat = bpy.data.materials.new(name or "Material")
    if bpy.app.version < (5, 0, 0):
        mat.use_nodes = True
    bsdf = next((n for n in mat.node_tree.nodes if n.bl_idname == "ShaderNodeBsdfPrincipled"), None) if mat.node_tree else None
    if bsdf is None:
        return mat
    bsdf.inputs["Base Color"].default_value = (colour[0], colour[1], colour[2], 1.0)
    bsdf.inputs["Roughness"].default_value = 0.6
    if alpha < 0.999:
        bsdf.inputs["Alpha"].default_value = max(alpha, 0.02)
        for attr, val in (("blend_method", "BLEND"), ("surface_render_method", "BLENDED")):
            try:
                setattr(mat, attr, val)
            except Exception:
                pass
    if texture and os.path.exists(texture):
        try:
            tex = mat.node_tree.nodes.new("ShaderNodeTexImage")
            tex.image = bpy.data.images.load(texture, check_existing=True)
            mat.node_tree.links.new(tex.outputs["Color"], bsdf.inputs["Base Color"])
        except Exception:
            pass
    return mat


def _mesh(name, verts, tris, normals=None, uvs=None):
    """A Blender mesh from flat arrays: verts (n, 3), tris (m, 3)."""
    import numpy as np
    me = bpy.data.meshes.new(name or "Mesh")
    nv, nt = len(verts), len(tris)
    me.vertices.add(nv)
    me.vertices.foreach_set("co", np.asarray(verts, dtype=np.float32).ravel())
    me.loops.add(nt * 3)
    me.loops.foreach_set("vertex_index", np.asarray(tris, dtype=np.int32).ravel())
    me.polygons.add(nt)
    me.polygons.foreach_set("loop_start", np.arange(0, nt * 3, 3, dtype=np.int32))
    me.polygons.foreach_set("loop_total", np.full(nt, 3, dtype=np.int32))
    if uvs is not None and len(uvs) == nv:
        layer = me.uv_layers.new(name="UVMap")
        per_loop = np.asarray(uvs, dtype=np.float32)[np.asarray(tris, dtype=np.int32).ravel()]
        layer.data.foreach_set("uv", per_loop.ravel())
    me.update(calc_edges=True)
    me.validate(clean_customdata=False)
    if normals is not None and len(normals) == nv:
        try:
            me.normals_split_custom_set_from_vertices(np.asarray(normals, dtype=np.float32).tolist())
        except Exception:
            pass
    return me


def import_assimp(src):
    """Collada, 3DS and friends. Assimp hands the scene over Y-up; it is
    turned to Blender's Z-up here and back to Y-up by the glTF writer."""
    import numpy as np
    import assimp_py as ai
    from mathutils import Matrix
    flags = (ai.Process_Triangulate | ai.Process_JoinIdenticalVertices | ai.Process_GenSmoothNormals
             | ai.Process_SortByPType | ai.Process_FlipUVs * 0)
    sc = ai.import_file(src, flags)
    folder = os.path.dirname(src)
    mats = []
    for i, m in enumerate(sc.materials or []):
        col = m.get("COLOR_DIFFUSE") or [0.8, 0.8, 0.8]
        tex = None
        for kind, paths in (m.get("TEXTURES") or {}).items():
            if kind == ai.TextureType_DIFFUSE and paths:
                cand = paths[0].replace("\\", "/")
                for c in (cand, os.path.join(folder, cand), os.path.join(folder, os.path.basename(cand))):
                    if os.path.exists(c):
                        tex = c
                        break
        mats.append(_new_material(str(m.get("NAME") or "Material %d" % (i + 1)), col, float(m.get("OPACITY", 1.0)), tex))
    meshes = []
    for i, m in enumerate(sc.meshes):
        v = np.frombuffer(m.vertices, dtype=np.float32).reshape(-1, 3)
        idx = np.frombuffer(m.indices, dtype=np.uint32).astype(np.int32)
        if len(idx) % 3 != 0 or len(v) == 0 or len(idx) == 0:
            meshes.append(None)   # points or lines only
            continue
        n = np.frombuffer(m.normals, dtype=np.float32).reshape(-1, 3) if m.normals is not None else None
        uv = None
        if m.texcoords:
            comps = (m.num_uv_components[0] if m.num_uv_components else 2) or 2
            raw = np.frombuffer(m.texcoords[0], dtype=np.float32)
            uv = raw.reshape(-1, comps)[:, :2] if len(raw) % comps == 0 else None
        me = _mesh(m.name or "Mesh %d" % (i + 1), v, idx.reshape(-1, 3), n, uv)
        if 0 <= m.material_index < len(mats):
            me.materials.append(mats[m.material_index])
        meshes.append(me)
    y_up_to_z_up = Matrix(((1, 0, 0, 0), (0, 0, -1, 0), (0, 1, 0, 0), (0, 0, 0, 1)))
    count = 0

    def walk(node, parent_matrix):
        nonlocal count
        t = node.transformation
        local = Matrix([list(r) for r in t]) if t is not None else Matrix.Identity(4)
        world = parent_matrix @ local
        for k, mi in enumerate(node.mesh_indices or ()):
            me = meshes[mi] if 0 <= mi < len(meshes) else None
            if me is None:
                continue
            name = node.name if node.name and not node.name.startswith("<") else me.name
            o = bpy.data.objects.new(name if k == 0 else "%s %d" % (name, k + 1), me)
            o.matrix_world = y_up_to_z_up @ world
            bpy.context.scene.collection.objects.link(o)
            count += 1
        for c in node.children or ():
            walk(c, world)

    walk(sc.root_node, Matrix.Identity(4))
    return {"objects": count}


def import_ifc(src):
    """A building from Revit, Archicad, Allplan...: every element as its own
    object, named as in the model, under its storey, in the model's colours.
    Elements that repeat (the same window forty times) share one mesh."""
    import multiprocessing
    import numpy as np
    import ifcopenshell
    import ifcopenshell.geom
    from mathutils import Matrix
    f = ifcopenshell.open(src)
    settings = ifcopenshell.geom.settings()
    for key, val in (("weld-vertices", True), ("apply-default-materials", True), ("use-world-coords", False)):
        try:
            settings.set(key, val)
        except Exception:
            pass
    # Spaces and openings are not things to see.
    skip = [e for e in f.by_type("IfcOpeningElement")] + [e for e in f.by_type("IfcSpace")]
    kw = {"exclude": skip} if skip else {}
    it = ifcopenshell.geom.iterator(settings, f, max(1, multiprocessing.cpu_count()), **kw)
    mesh_by_geom = {}
    mat_by_key = {}
    storeys = {}
    count = 0
    classes = {}

    def storey_of(el):
        seen = 0
        while el is not None and seen < 8:
            seen += 1
            for rel in getattr(el, "ContainedInStructure", None) or ():
                return rel.RelatingStructure
            up = None
            for rel in getattr(el, "Decomposes", None) or ():
                up = rel.RelatingObject
            if up is None:
                for rel in getattr(el, "FillsVoids", None) or ():      # a window in a wall's opening
                    for v in getattr(rel.RelatingOpeningElement, "VoidsElements", None) or ():
                        up = v.RelatingBuildingElement
            el = up
        return None

    def material_for(m):
        d = m.diffuse
        col = (d.r(), d.g(), d.b()) if hasattr(d, "r") else tuple(d)[:3]
        alpha = 1.0 - float(m.transparency) if getattr(m, "has_transparency", False) and m.transparency == m.transparency else 1.0
        # The style's own name ("Brick"), not the engine's ("IfcSurfaceStyleShading-46").
        name = m.name
        try:
            style = f.by_id(m.instance_id())
            name = getattr(style, "Name", None) or name
        except Exception:
            pass
        key = (name, round(col[0], 3), round(col[1], 3), round(col[2], 3), round(alpha, 3))
        if key not in mat_by_key:
            mat_by_key[key] = _new_material(name, col, alpha)
        return mat_by_key[key]

    if not it.initialize():
        return {"objects": 0, "note": "the IFC file has no geometry Oriel can show"}
    while True:
        sh = it.get()
        try:
            el = f.by_id(sh.id)
            g = sh.geometry
            me = mesh_by_geom.get(g.id)
            if me is None:
                v = np.array(g.verts, dtype=np.float32).reshape(-1, 3)
                tris = np.array(g.faces, dtype=np.int32).reshape(-1, 3)
                if len(v) and len(tris):
                    me = _mesh(el.is_a(), v, tris)
                    mats = [material_for(m) for m in g.materials]
                    for m in mats:
                        me.materials.append(m)
                    ids = np.array(g.material_ids, dtype=np.int32)
                    if len(mats) > 1 and len(ids) == len(tris):
                        me.polygons.foreach_set("material_index", np.clip(ids, 0, len(mats) - 1))
                    # IFC surfaces are faceted or smooth by their geometry; flat reads right for buildings.
                    mesh_by_geom[g.id] = me
            if me is not None:
                name = (getattr(el, "Name", None) or el.is_a()[3:]).strip() or el.is_a()[3:]
                o = bpy.data.objects.new(name[:60], me)
                m = np.array(sh.transformation.matrix, dtype=np.float64)
                m = m.reshape(4, 4, order="F") if m.size == 16 else np.vstack([m.reshape(4, 3).T, [0, 0, 0, 1]])
                o.matrix_world = Matrix(m.tolist())
                o["ifc_class"] = el.is_a()
                o["ifc_id"] = str(getattr(el, "GlobalId", ""))
                st = storey_of(el)
                parent = None
                if st is not None:
                    sid = st.id()
                    if sid not in storeys:
                        e = bpy.data.objects.new((getattr(st, "Name", None) or st.is_a()[3:])[:60], None)
                        e["ifc_class"] = st.is_a()
                        bpy.context.scene.collection.objects.link(e)
                        storeys[sid] = e
                    parent = storeys[sid]
                bpy.context.scene.collection.objects.link(o)
                if parent is not None:
                    o.parent = parent          # the storey stays at the origin, so places are unchanged
                classes[el.is_a()] = classes.get(el.is_a(), 0) + 1
                count += 1
        except Exception as e:      # one bad element must not lose the building
            print("[oriel] IFC element skipped:", e, flush=True)
        if not it.next():
            break
    return {"objects": count, "storeys": len(storeys), "classes": classes}


def model(src, dest, up="y"):
    ext = os.path.splitext(src)[1].lower().lstrip(".")
    bpy.ops.wm.read_factory_settings(use_empty=True)
    info = {}
    # A file that does not say which way is up is read as the user says.
    axes = {"forward_axis": "NEGATIVE_Z", "up_axis": "Y"} if up != "z" else {"forward_axis": "Y", "up_axis": "Z"}
    if ext in USD_EXT:
        bpy.ops.wm.usd_import(filepath=src)
    elif ext == "abc":
        bpy.ops.wm.alembic_import(filepath=src, as_background_job=False)
    elif ext == "ply":
        bpy.ops.wm.ply_import(filepath=src, **axes)
    elif ext == "stl":
        bpy.ops.wm.stl_import(filepath=src, **axes)
    elif ext == "ifc":
        info = import_ifc(src)
    elif ext == "blend":
        bpy.ops.wm.open_mainfile(filepath=src)
    else:
        info = import_assimp(src)
    n_mesh = sum(1 for o in bpy.data.objects if o.type == "MESH" and len(o.data.polygons) > 0)
    if n_mesh == 0:
        return done(error=info.get("note") or "there is nothing to show in %s" % os.path.basename(src))
    for o in list(bpy.data.objects):
        if o.type in ("CAMERA", "LIGHT"):
            bpy.data.objects.remove(o, do_unlink=True)
    os.makedirs(os.path.dirname(dest), exist_ok=True)
    bpy.ops.export_scene.gltf(filepath=dest, export_format="GLB", export_apply=True, export_extras=True,
                              export_cameras=False, export_lights=False, export_yup=True)
    if not os.path.exists(dest):
        return done(error="the model could not be written")
    info.update({"error": "", "output": dest, "meshes": n_mesh})
    done(**info)


try:
    if P["mode"] == "hdr":
        to_hdr(P["input"], P["output"])
    elif P["mode"] == "material":
        material(P["input"], P["output"])
    elif P["mode"] == "model":
        model(P["input"], P["output"], str(P.get("up", "y")))
    else:
        done(error="unknown mode %s" % P["mode"])
except Exception as e:
    traceback.print_exc()
    done(error="%s: %s" % (type(e).__name__, e))
sys.stdout.flush()
os._exit(0)
