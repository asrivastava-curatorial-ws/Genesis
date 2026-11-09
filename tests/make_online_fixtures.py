"""Fixtures for tests/app/online_tests.gd: a stand-in for Poly Haven's API
(lists, file trees with MD5s) and the small files it points at.
    python3 tests/make_online_fixtures.py <folder> <port>"""
import hashlib
import json
import os
import struct
import sys
import zlib

root, port = sys.argv[1], int(sys.argv[2])
files = os.path.join(root, "files")
os.makedirs(files, exist_ok=True)
base = "http://127.0.0.1:%d/files/" % port


def png(path, rgb, size=8):
    raw = b"".join(b"\0" + bytes(rgb) * size for _ in range(size))
    def chunk(t, d):
        return struct.pack(">I", len(d)) + t + d + struct.pack(">I", zlib.crc32(t + d) & 0xFFFFFFFF)
    data = b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", struct.pack(">IIBBBBB", size, size, 8, 2, 0, 0, 0)) + \
        chunk(b"IDAT", zlib.compress(raw)) + chunk(b"IEND", b"")
    open(path, "wb").write(data)


def entry(name):
    p = os.path.join(files, name)
    d = open(p, "rb").read()
    return {"url": base + name, "md5": hashlib.md5(d).hexdigest(), "size": len(d)}


# A sky: a tiny Radiance HDR (header, then flat RGBE scanlines).
hdr = b"#?RADIANCE\nFORMAT=32-bit_rle_rgbe\n\n-Y 4 +X 8\n" + bytes([128, 128, 160, 129]) * 32
open(os.path.join(files, "test_sky_2k.hdr"), "wb").write(hdr)
# A material's maps.
png(os.path.join(files, "test_brick_diff_2k.png"), (150, 60, 40))
png(os.path.join(files, "test_brick_nor_gl_2k.png"), (128, 128, 255))
png(os.path.join(files, "test_brick_rough_2k.png"), (200, 200, 200))
for t in ("test_sky", "test_brick", "test_chair"):
    png(os.path.join(files, t + ".png"), (90, 90, 90), 16)
# A model: one triangle, glTF with its buffer and a texture beside it.
tri = struct.pack("<9f", 0, 0, 0, 1, 0, 0, 0, 1, 0)
open(os.path.join(files, "test_chair.bin"), "wb").write(tri)
png(os.path.join(files, "test_chair_diff.png"), (120, 80, 50))
gltf = {"asset": {"version": "2.0"}, "scene": 0, "scenes": [{"nodes": [0]}], "nodes": [{"mesh": 0, "name": "chair"}],
        "meshes": [{"primitives": [{"attributes": {"POSITION": 0}, "material": 0}]}],
        "materials": [{"pbrMetallicRoughness": {"baseColorTexture": {"index": 0}}}],
        "textures": [{"source": 0}], "images": [{"uri": "textures/test_chair_diff.png"}],
        "buffers": [{"uri": "test_chair.bin", "byteLength": 36}],
        "bufferViews": [{"buffer": 0, "byteOffset": 0, "byteLength": 36}],
        "accessors": [{"bufferView": 0, "componentType": 5126, "count": 3, "type": "VEC3", "min": [0, 0, 0], "max": [1, 1, 0]}]}
open(os.path.join(files, "test_chair_2k.gltf"), "w").write(json.dumps(gltf))

lists = {
    "hdris": {"test_sky": {"name": "Test sky", "categories": ["skies", "outdoor"], "tags": ["clear"], "authors": {"A. Tester": "All"}, "download_count": 5}},
    "textures": {"test_brick": {"name": "Test brick", "categories": ["brick", "wall"], "tags": ["red"], "authors": {"B. Tester": "All"}, "download_count": 9, "dimensions": [2000, 2000]}},
    "models": {"test_chair": {"name": "Test chair", "categories": ["furniture", "seating"], "tags": ["wood"], "authors": {"C. Tester": "All"}, "download_count": 7}},
}
for t, d in lists.items():
    json.dump(d, open(os.path.join(files, "ph_assets_%s.json" % t), "w"))
json.dump({"hdri": {"2k": {"hdr": entry("test_sky_2k.hdr")}}}, open(os.path.join(files, "ph_files_test_sky.json"), "w"))
json.dump({"Diffuse": {"2k": {"png": entry("test_brick_diff_2k.png")}}, "nor_gl": {"2k": {"png": entry("test_brick_nor_gl_2k.png")}},
           "Rough": {"2k": {"png": entry("test_brick_rough_2k.png")}}}, open(os.path.join(files, "ph_files_test_brick.json"), "w"))
g = entry("test_chair_2k.gltf")
g["include"] = {"test_chair.bin": entry("test_chair.bin"), "textures/test_chair_diff.png": entry("test_chair_diff.png")}
json.dump({"gltf": {"2k": {"gltf": g}}}, open(os.path.join(files, "ph_files_test_chair.json"), "w"))
print("fixtures in", files)
