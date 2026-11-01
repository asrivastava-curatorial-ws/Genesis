extends RefCounted

# Writes a Radiance .hdr picture (the format HDRI skies come in), run-length
# encoded scanline by scanline the way photo tools write it. Godot reads these
# but cannot write them; the smoke tour and the end-to-end test make their
# test skies with it.


static func write(path: String, img: Image) -> Error:
	var w := img.get_width()
	var h := img.get_height()
	var out := PackedByteArray()
	out.append_array(("#?RADIANCE\nFORMAT=32-bit_rle_rgbe\n\n-Y %d +X %d\n" % [h, w]).to_ascii_buffer())
	for y in h:
		var rows := [PackedByteArray(), PackedByteArray(), PackedByteArray(), PackedByteArray()]
		for x in w:
			var c := img.get_pixel(x, y)
			var v := maxf(c.r, maxf(c.g, c.b))
			if v < 1e-32:
				for k in 4:
					rows[k].append(0)
				continue
			# v = m * 2^e with m in [0.5, 1): the shared exponent.
			var e := int(floor(log(v) / log(2.0))) + 1
			var scale := 256.0 / pow(2.0, e)
			rows[0].append(clampi(int(c.r * scale), 0, 255))
			rows[1].append(clampi(int(c.g * scale), 0, 255))
			rows[2].append(clampi(int(c.b * scale), 0, 255))
			rows[3].append(e + 128)
		out.append_array(PackedByteArray([2, 2, w >> 8, w & 255]))
		for k in 4:
			var i := 0
			while i < w:
				var n := mini(128, w - i)
				out.append(n)
				out.append_array(rows[k].slice(i, i + n))
				i += n
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f == null:
		return FileAccess.get_open_error()
	f.store_buffer(out)
	f.close()
	return OK


## A test sky: blue above, dark ground below, and a small, very bright sun at
## (u, v) of the panorama.
static func test_sky(width: int, u: float, v: float) -> Image:
	var h := width / 2
	var img := Image.create(width, h, false, Image.FORMAT_RGBF)
	img.fill(Color(0.3, 0.45, 0.8))
	for y in range(h / 2, h):
		for x in width:
			img.set_pixel(x, y, Color(0.2, 0.25, 0.15))
	var sx := int(u * width)
	var sy := int(v * h)
	for dy in range(-2, 3):
		for dx in range(-2, 3):
			img.set_pixel(clampi(sx + dx, 0, width - 1), clampi(sy + dy, 0, h - 1), Color(60.0, 55.0, 50.0))
	return img
