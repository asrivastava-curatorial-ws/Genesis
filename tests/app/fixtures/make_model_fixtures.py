"""Small models in the formats the built-in engine converts, for the tests:
a bench 2 m wide, 0.6 m deep and 0.4 m high in each.  make_fixtures.py <out folder>   (run by the engine's Python)"""
import os, sys
import bpy
out = sys.argv[sys.argv.index("--") + 1] if "--" in sys.argv else sys.argv[1]
os.makedirs(out, exist_ok=True)
bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.ops.mesh.primitive_cube_add(size=1, location=(0, 0, 0.2))
o = bpy.context.object
o.name = "Bench"
o.scale = (2.0, 0.6, 0.4)
bpy.ops.object.transform_apply(scale=True)
m = bpy.data.materials.new("Oak")
m.use_nodes = True
m.node_tree.nodes["Principled BSDF"].inputs["Base Color"].default_value = (0.6, 0.3, 0.1, 1)
o.data.materials.append(m)
bpy.ops.wm.usd_export(filepath=os.path.join(out, "bench.usdc"))
bpy.ops.wm.stl_export(filepath=os.path.join(out, "bench.stl"))
bpy.ops.wm.ply_export(filepath=os.path.join(out, "bench.ply"))
bpy.ops.wm.alembic_export(filepath=os.path.join(out, "bench.abc"), as_background_job=False)
# Collada by hand (Blender 5 no longer writes it): the same bench, Z up, in centimetres.
x, y, z = 100.0, 30.0, 40.0
pos = [(-x, -y, 0), (x, -y, 0), (x, y, 0), (-x, y, 0), (-x, -y, z), (x, -y, z), (x, y, z), (-x, y, z)]
tris = [0, 2, 1, 0, 3, 2, 4, 5, 6, 4, 6, 7, 0, 1, 5, 0, 5, 4, 1, 2, 6, 1, 6, 5, 2, 3, 7, 2, 7, 6, 3, 0, 4, 3, 4, 7]
dae = """<?xml version="1.0" encoding="utf-8"?>
<COLLADA xmlns="http://www.collada.org/2005/11/COLLADASchema" version="1.4.1">
  <asset><unit name="centimeter" meter="0.01"/><up_axis>Z_UP</up_axis></asset>
  <library_effects><effect id="oak-fx"><profile_COMMON><technique sid="common"><lambert>
    <diffuse><color>0.6 0.3 0.1 1</color></diffuse></lambert></technique></profile_COMMON></effect></library_effects>
  <library_materials><material id="oak" name="Oak"><instance_effect url="#oak-fx"/></material></library_materials>
  <library_geometries><geometry id="bench" name="Bench"><mesh>
    <source id="bench-pos"><float_array id="bench-pos-a" count="24">%s</float_array>
      <technique_common><accessor source="#bench-pos-a" count="8" stride="3">
        <param name="X" type="float"/><param name="Y" type="float"/><param name="Z" type="float"/></accessor></technique_common></source>
    <vertices id="bench-v"><input semantic="POSITION" source="#bench-pos"/></vertices>
    <triangles material="oak" count="12"><input semantic="VERTEX" source="#bench-v" offset="0"/><p>%s</p></triangles>
  </mesh></geometry></library_geometries>
  <library_visual_scenes><visual_scene id="scene"><node id="Bench" name="Bench">
    <instance_geometry url="#bench"><bind_material><technique_common>
      <instance_material symbol="oak" target="#oak"/></technique_common></bind_material></instance_geometry>
  </node></visual_scene></library_visual_scenes>
  <scene><instance_visual_scene url="#scene"/></scene>
</COLLADA>
""" % (" ".join("%g %g %g" % p for p in pos), " ".join(str(i) for i in tris))
open(os.path.join(out, "bench.dae"), "w", encoding="utf-8").write(dae)
print("fixtures:", sorted(os.listdir(out)))
