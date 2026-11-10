@tool
extends RefCounted

# The film as an edit: how one shot turns into the next (a cut, a dissolve,
# through black or white), words on the picture for a while (titles), a fade
# at the start and the end, and a soundtrack. The shots themselves are
# GnMovie's; what moves in them is GnTimeline's.
#
# The transitions and titles are put on the rendered frames afterwards, by
# the graphics card, the same for the real-time renderer, Eevee and Cycles.
# A dissolve needs no extra frames: every shot starts and ends at rest, so
# the shot going out holds its last frame and the one coming in its first.

const GnScene := preload("res://addons/genesis/core/gn_scene.gd")
const GnFfmpeg := preload("res://addons/genesis/core/gn_ffmpeg.gd")
const GnPaths := preload("res://addons/genesis/core/gn_paths.gd")

const META := &"gn_film"
## How a shot comes in after the one before it (the first: how the film opens).
const TRANSITIONS := ["Cut", "Dissolve", "Through black", "Through white"]
const PLACES := ["Lower left", "Lower middle", "Centre", "Top left", "Top middle"]
const DEFAULTS := {"fade_out": 0.0, "titles": [], "sound": "", "sound_volume": 1.0, "sound_fade": 2.0}
const TITLE := {"text": "Title", "from": 0.5, "to": 4.5, "place": "Lower left", "size": 0.06, "fade": 0.5,
	"colour": Color(1, 1, 1)}
const SOUND_TYPES := ["mp3", "wav", "ogg", "flac", "m4a", "aac", "opus"]


static func _holder() -> Node:
	return GnScene.find_role("movie")


## The film's settings: DEFAULTS with what the scene has stored.
static func settings() -> Dictionary:
	var out := DEFAULTS.duplicate(true)
	var m := _holder()
	if m:
		out.merge((m.get_meta(META, {}) as Dictionary).duplicate(true), true)
	return out


static func set_value(key: String, value: Variant, action := "") -> void:
	var m := _holder()
	if m == null:
		if GnScene.root() == null:
			return
		m = Node3D.new()
		m.name = "Movie"
		m.set_meta(&"gn_shots", [])
		GnScene.add_node(m, GnScene.root(), "Genesis: new movie", "movie")
	var s: Dictionary = (m.get_meta(META, {}) as Dictionary).duplicate(true)
	s[key] = value
	GnScene.set_props(action if action != "" else "Genesis: film %s" % key.replace("_", " "), [[m, "metadata/" + META, s]])


static func titles() -> Array:
	return settings().titles


static func add_title(text: String, from: float, seconds := 4.0) -> int:
	var list := titles()
	var t := TITLE.duplicate()
	t.text = text
	t.from = maxf(from, 0.0)
	t.to = t.from + maxf(seconds, 0.2)
	list.append(t)
	set_value("titles", list, "Genesis: add a title")
	return list.size() - 1


static func set_title(index: int, changes: Dictionary, action := "Genesis: change a title") -> void:
	var list := titles()
	if index < 0 or index >= list.size():
		return
	(list[index] as Dictionary).merge(changes, true)
	if float(list[index].to) < float(list[index].from) + 0.1:
		list[index].to = float(list[index].from) + 0.1
	set_value("titles", list, action)


static func remove_title(index: int) -> void:
	var list := titles()
	if index >= 0 and index < list.size():
		list.remove_at(index)
		set_value("titles", list, "Genesis: remove a title")


## How a shot comes in: {"kind": one of TRANSITIONS, "seconds": how long}.
static func transition_of(shot: Dictionary) -> Dictionary:
	var kind := str(shot.get("transition", "Cut"))
	return {"kind": kind if kind in TRANSITIONS else "Cut", "seconds": clampf(float(shot.get("transition_s", 1.0)), 0.1, 10.0)}


## Where the shots start, in seconds: one entry a shot, and the film's end.
static func cuts(shots: Array) -> PackedFloat32Array:
	var out := PackedFloat32Array()
	var t := 0.0
	for s in shots:
		out.append(t)
		t += float(s.seconds)
	out.append(t)
	return out


## What the edit does to the picture at `t` seconds, as a recipe:
##   "other":  -1, or the time whose frame is mixed in (a dissolve's other shot)
##   "mix":    how much of that other frame (0-1)
##   "wash":   a colour laid over (through black or white, the fades), with its alpha
##   "titles": [[title, alpha], ...] showing now
## An empty recipe ({}) means the frame is left as it is.
static func recipe(shots: Array, t: float, film: Dictionary, fps: int) -> Dictionary:
	var out := {"other": -1.0, "mix": 0.0, "wash": Color(0, 0, 0, 0), "titles": []}
	var at := cuts(shots)
	var end: float = at[at.size() - 1]
	var frame := 1.0 / maxf(fps, 1)
	for i in shots.size():
		var tr := transition_of(shots[i])
		if tr.kind == "Cut":
			continue
		var cut: float = at[i]
		if i == 0:
			# The film opens: up from black or white (a dissolve opens from black).
			var d: float = minf(tr.seconds, float(shots[0].seconds))
			if t < cut + d:
				var c := Color(1, 1, 1) if tr.kind == "Through white" else Color(0, 0, 0)
				c.a = 1.0 - smoothstep(0.0, 1.0, (t - cut) / d)
				out.wash = c
			continue
		# Half of it in the shot going out, half in the one coming in; never
		# more than half of either shot.
		var half: float = minf(tr.seconds * 0.5, minf(float(shots[i - 1].seconds), float(shots[i].seconds)) * 0.5)
		if t < cut - half or t >= cut + half:
			continue
		var u := (t - (cut - half)) / (2.0 * half)        # 0 to 1 across the transition
		if tr.kind == "Dissolve":
			# (The frame at the very join is the outgoing shot's last, as GnMovie has it.)
			if t <= cut + 0.000001:
				out.other = cut + frame                       # the incoming shot's first frame
				out.mix = smoothstep(0.0, 1.0, u)
			else:
				out.other = cut                               # the outgoing shot's last frame
				out.mix = 1.0 - smoothstep(0.0, 1.0, u)
		else:
			var c := Color(1, 1, 1) if tr.kind == "Through white" else Color(0, 0, 0)
			c.a = 1.0 - absf(u * 2.0 - 1.0)
			c.a = smoothstep(0.0, 1.0, c.a)
			out.wash = c
	var fade_out := minf(float(film.get("fade_out", 0.0)), end)
	if fade_out > 0.0 and t > end - fade_out:
		var a := smoothstep(0.0, 1.0, (t - (end - fade_out)) / fade_out)
		if a > (out.wash as Color).a:
			out.wash = Color(0, 0, 0, a)
	for title in film.get("titles", []):
		var from := float(title.get("from", 0.0))
		var to := float(title.get("to", from + 1.0))
		if t < from or t > to or str(title.get("text", "")).strip_edges() == "":
			continue
		var fade := clampf(float(title.get("fade", 0.5)), 0.0, (to - from) * 0.5)
		var a := 1.0 if fade <= 0.0 else minf(smoothstep(0.0, 1.0, (t - from) / fade), smoothstep(0.0, 1.0, (to - t) / fade))
		if a > 0.003:
			(out.titles as Array).append([title, a])
	if out.other < 0.0 and (out.wash as Color).a <= 0.003 and (out.titles as Array).is_empty():
		return {}
	return out


## Whether the edit changes any frame at all.
static func has_edit(shots: Array, film: Dictionary) -> bool:
	if float(film.get("fade_out", 0.0)) > 0.0:
		return true
	for title in film.get("titles", []):
		if str(title.get("text", "")).strip_edges() != "":
			return true
	for s in shots:
		if transition_of(s).kind != "Cut":
			return true
	return false


## Puts the edit on the frames in `dir` (frame_00000.png…, `fps` a second):
## transitions between the shots, the fades, the titles. In place: the
## frames a dissolve mixes in are read before anything is changed.
## Returns how many frames were changed.
static func finish_frames(dir: String, shots: Array, film: Dictionary, fps: int, host: Node, progress := Callable()) -> int:
	if not has_edit(shots, film):
		return 0
	var end: float = cuts(shots)[shots.size()]
	var total := int(ceil(end * fps))
	var recipes := {}
	var others := {}
	for f in total:
		var r := recipe(shots, float(f) / fps, film, fps)
		if r.is_empty():
			continue
		recipes[f] = r
		if float(r.other) >= 0.0:
			var of := clampi(int(round(float(r.other) * fps)), 0, total - 1)
			r["other_frame"] = of
			if not others.has(of):
				others[of] = Image.load_from_file(dir.path_join("frame_%05d.png" % of))
	var textures := {}
	for of in others:
		if others[of] != null and not (others[of] as Image).is_empty():
			textures[of] = ImageTexture.create_from_image(others[of])
	var changed := 0
	var done := 0
	for f in recipes:
		var file := dir.path_join("frame_%05d.png" % f)
		var img := Image.load_from_file(file) if FileAccess.file_exists(file) else null
		done += 1
		if img == null or img.is_empty():
			continue
		var r: Dictionary = recipes[f]
		var out: Image = await compose(img, textures.get(r.get("other_frame", -1)), r, host)
		if out and not out.is_empty() and out.save_png(file) == OK:
			changed += 1
		if progress.is_valid() and done % 10 == 0:
			progress.call(done, recipes.size())
	return changed


## One frame with its recipe on it.
static func compose(image: Image, other: Texture2D, r: Dictionary, host: Node) -> Image:
	if DisplayServer.get_name() == "headless":
		return image
	var sub := SubViewport.new()
	sub.size = image.get_size()
	sub.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	sub.transparent_bg = false
	var w := float(image.get_width())
	var h := float(image.get_height())
	var base := TextureRect.new()
	base.texture = ImageTexture.create_from_image(image)
	base.size = Vector2(w, h)
	sub.add_child(base)
	if other != null and float(r.get("mix", 0.0)) > 0.0:
		var over := TextureRect.new()
		over.texture = other
		over.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		over.size = Vector2(w, h)
		over.modulate.a = clampf(float(r.mix), 0.0, 1.0)
		sub.add_child(over)
	var wash: Color = r.get("wash", Color(0, 0, 0, 0))
	if wash.a > 0.003:
		var cover := ColorRect.new()
		cover.color = wash
		cover.size = Vector2(w, h)
		sub.add_child(cover)
	for pair in r.get("titles", []):
		sub.add_child(title_label(pair[0], float(pair[1]), Vector2(w, h)))
	host.add_child(sub)
	var low_power := OS.low_processor_usage_mode
	OS.low_processor_usage_mode = false
	for i in 3:
		await RenderingServer.frame_post_draw
	OS.low_processor_usage_mode = low_power
	var out := sub.get_texture().get_image()
	host.remove_child(sub)
	sub.queue_free()
	return out if out and not out.is_empty() else image


## A title as it is drawn on a picture of `size`.
static func title_label(title: Dictionary, alpha: float, size: Vector2) -> Label:
	var label := Label.new()
	label.text = str(title.get("text", ""))
	var px := maxi(int(size.y * clampf(float(title.get("size", 0.06)), 0.015, 0.3)), 6)
	label.add_theme_font_size_override("font_size", px)
	var c: Color = title.get("colour", Color(1, 1, 1)) if title.get("colour") is Color else Color(1, 1, 1)
	label.add_theme_color_override("font_color", Color(c.r, c.g, c.b, 0.97))
	label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.55))
	label.add_theme_constant_override("shadow_offset_x", maxi(px / 18, 1))
	label.add_theme_constant_override("shadow_offset_y", maxi(px / 18, 1))
	label.add_theme_constant_override("line_spacing", int(px * 0.15))
	label.modulate.a = clampf(alpha, 0.0, 1.0)
	var place := str(title.get("place", "Lower left"))
	var margin := size.y * 0.06
	label.size = Vector2(size.x - 2.0 * margin, 0)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT if place.ends_with("left") else HORIZONTAL_ALIGNMENT_CENTER
	var lines := label.text.count("\n") + 1
	var block := px * 1.35 * lines
	var y := margin
	if place.begins_with("Lower"):
		y = size.y - margin - block
	elif place == "Centre":
		y = (size.y - block) * 0.5
	label.position = Vector2(margin, y)
	return label


## FFmpeg's words for the film's soundtrack, to go between the frames and
## the output: [] when there is none or the file is gone.
static func sound_args(film: Dictionary, seconds: float) -> Array:
	var file := str(film.get("sound", ""))
	if file == "" or not FileAccess.file_exists(file) or seconds <= 0.0:
		return []
	var vol := clampf(float(film.get("sound_volume", 1.0)), 0.0, 4.0)
	var fade := clampf(float(film.get("sound_fade", 2.0)), 0.0, seconds)
	var filters := ["volume=%.3f" % vol]
	if fade > 0.0:
		filters.append("afade=t=out:st=%.3f:d=%.3f" % [seconds - fade, fade])
	# Music shorter than the film plays again; longer is cut at the film's end.
	return ["-stream_loop", "-1", "-i", file, "-af", ",".join(filters), "-c:a", "aac", "-b:a", "192k",
		"-map", "0:v:0", "-map", "1:a:0", "-t", "%.3f" % seconds]


## Joins frames into a video with the film's sound: FFmpeg's arguments.
static func video_args(frames_pattern: String, fps: int, out: String, film: Dictionary, seconds: float) -> Array:
	var args := ["-y", "-framerate", str(fps), "-i", frames_pattern]
	var sound := sound_args(film, seconds)
	if not sound.is_empty():
		# The sound is the second input: its -i goes before the output's settings.
		args.append_array(sound.slice(0, 4))
		args.append_array(["-c:v", "libx264", "-pix_fmt", "yuv420p", "-crf", "17", "-preset", "slow"])
		args.append_array(sound.slice(4))
	else:
		args.append_array(["-c:v", "libx264", "-pix_fmt", "yuv420p", "-crf", "17", "-preset", "slow"])
	args.append(out)
	return args
