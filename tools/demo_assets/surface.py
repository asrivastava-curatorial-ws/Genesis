"""One scanned surface, as Oriel's material presets want it.

    surface.py <archive.zip> <ambientCG asset> <folder> <name>

Writes <name>_Color.jpg, <name>_NormalGL.jpg and <name>_Roughness.jpg (and
<name>_Metalness.jpg for a metal) at 1024 pixels across. The archives carry
their normal maps in the DirectX sense (green pointing down the picture);
Oriel reads the OpenGL sense, so green is turned over. A set without a
roughness map (painted plaster) gets an even one: matt.
"""
import io
import sys
import zipfile

from PIL import Image, ImageChops

archive, asset, folder, name = sys.argv[1:5]
ACROSS = 1024


def picture(z, suffix):
    for item in z.namelist():
        if item.endswith("%s_%s.jpg" % (asset, suffix)):
            return Image.open(io.BytesIO(z.read(item)))
    return None


def fitted(img):
    if img.width > ACROSS:
        img = img.resize((ACROSS, max(1, round(img.height * ACROSS / img.width))), Image.LANCZOS)
    return img


with zipfile.ZipFile(archive) as z:
    colour = picture(z, "Color")
    if colour is None:
        sys.exit("no %s_Color.jpg in %s" % (asset, archive))
    colour = fitted(colour.convert("RGB"))
    colour.save("%s/%s_Color.jpg" % (folder, name), quality=90)
    normal = picture(z, "NormalDX")
    if normal is not None:
        r, g, b = fitted(normal.convert("RGB")).split()
        Image.merge("RGB", (r, ImageChops.invert(g), b)).save("%s/%s_NormalGL.jpg" % (folder, name), quality=92)
    else:
        Image.new("RGB", colour.size, (128, 128, 255)).save("%s/%s_NormalGL.jpg" % (folder, name), quality=92)
    rough = picture(z, "Roughness")
    if rough is not None:
        fitted(rough.convert("L")).save("%s/%s_Roughness.jpg" % (folder, name), quality=90)
    else:
        Image.new("L", colour.size, 224).save("%s/%s_Roughness.jpg" % (folder, name), quality=90)
    metal = picture(z, "Metalness")
    if metal is not None:
        fitted(metal.convert("L")).save("%s/%s_Metalness.jpg" % (folder, name), quality=90)
print("%s: %s at %d x %d" % (name, asset, colour.width, colour.height))
