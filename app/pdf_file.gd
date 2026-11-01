extends RefCounted

# Writes a one-page PDF of line drawing, the way a CAD program plots a plan:
# exact vector lines, heavier pens for walls. The end-to-end test and the
# suites make their test plans with it.

const MM := 72.0 / 25.4  # PDF points per millimetre of paper


## A PDF page `width_mm` × `height_mm` whose content stream is `content`
## (PDF drawing operators, in points from the bottom left).
static func write(path: String, width_mm: float, height_mm: float, content: String) -> Error:
	var objects: Array[String] = [
		"<< /Type /Catalog /Pages 2 0 R >>",
		"<< /Type /Pages /Kids [3 0 R] /Count 1 >>",
		"<< /Type /Page /Parent 2 0 R /MediaBox [0 0 %.2f %.2f] /Contents 4 0 R >>" % [width_mm * MM, height_mm * MM],
		"<< /Length %d >>\nstream\n%s\nendstream" % [content.to_ascii_buffer().size(), content],
	]
	var out := "%PDF-1.4\n"
	var offsets: Array[int] = []
	for i in objects.size():
		offsets.append(out.to_ascii_buffer().size())
		out += "%d 0 obj\n%s\nendobj\n" % [i + 1, objects[i]]
	var xref := out.to_ascii_buffer().size()
	out += "xref\n0 %d\n0000000000 65535 f \n" % (objects.size() + 1)
	for o in offsets:
		out += "%010d 00000 n \n" % o
	out += "trailer\n<< /Size %d /Root 1 0 R >>\nstartxref\n%d\n%%%%EOF\n" % [objects.size() + 1, xref]
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f == null:
		return FileAccess.get_open_error()
	f.store_buffer(out.to_ascii_buffer())
	f.close()
	return OK


## A plan plotted at 1:100 on A4: a 10 m × 6 m room, its walls 300 mm thick
## drawn with a heavy pen (0.7 mm); a partition, tables and a 1 m grid with a
## light one (0.18 mm). Like a real plot, it is all lines.
static func test_plan(path: String) -> Error:
	var x0 := 40.0 * MM
	var y0 := 120.0 * MM
	var w := 100.0 * MM   # 10 m at 1:100
	var h := 60.0 * MM    # 6 m
	var t := 3.0 * MM     # 300 mm walls
	var s := PackedStringArray()
	s.append("%.3f w 0 G" % (0.7 * MM))
	s.append("%.3f %.3f %.3f %.3f re S" % [x0, y0, w, h])
	s.append("%.3f %.3f %.3f %.3f re S" % [x0 + t, y0 + t, w - 2 * t, h - 2 * t])
	s.append("%.3f w 0.4 G" % (0.18 * MM))
	s.append("%.3f %.3f m %.3f %.3f l S" % [x0 + 40.0 * MM, y0 + t, x0 + 40.0 * MM, y0 + h - t])
	for i in range(1, 10):
		s.append("%.3f %.3f m %.3f %.3f l S" % [x0 + i * 10.0 * MM, y0 - 5.0 * MM, x0 + i * 10.0 * MM, y0 - 2.0 * MM])
	for i in range(0, 11):
		s.append("%.3f %.3f m %.3f %.3f l S" % [x0 + i * 10.0 * MM, y0 + h + 2.0 * MM, x0 + i * 10.0 * MM, y0 + h + 5.0 * MM])
	for i in range(0, 7):
		s.append("%.3f %.3f m %.3f %.3f l S" % [x0 - 5.0 * MM, y0 + i * 10.0 * MM, x0 - 2.0 * MM, y0 + i * 10.0 * MM])
	for row in 2:
		for col in 4:
			s.append("%.3f %.3f %.3f %.3f re S" % [x0 + (50.0 + col * 11.0) * MM, y0 + (15.0 + row * 20.0) * MM, 8.0 * MM, 8.0 * MM])
	return write(path, 210.0, 297.0, "\n".join(s))
