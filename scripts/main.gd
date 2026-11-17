extends Node2D
## 아그라 전기 - 프로토타입 메인
## 마을 운영(자원·명령) + 낮/밤 순환 + 균열 웨이브 침공을 관리한다.
## 그래픽: Kenney Tiny Town / Tiny Dungeon (CC0), 폰트: 갈무리 (OFL)

const Mercenary = preload("res://scripts/mercenary.gd")
const Monster = preload("res://scripts/monster.gd")
const TOWN_TEX := preload("res://assets/kenney_tiny_town/tilemap_packed.png")
const DUNGEON_TEX := preload("res://assets/kenney_tiny_dungeon/tilemap_packed.png")

const WORLD_SIZE := Vector2(640, 360)
const TILE := 16
const DAY_LENGTH := 45.0
const HALL_MAX_HP := 400.0
const RECRUIT_COST := 60
const WAGE_PER_MERC := 5
const MAX_MERCS := 10

const COL_TEXT := Color("f4e6c8")
const COL_DARK := Color("1e140c")

var gold: float = 120.0
var food: float = 30.0
var wood: float = 20.0
var residue: int = 0
var day: int = 1
var is_night := false
var phase_time := 0.0
var to_spawn := 0
var spawn_timer := 0.0
var game_over := false
var hall_hp: float = HALL_MAX_HP
var train_bonus: float = 1.0
var elapsed := 0.0

var rally_point := Vector2.ZERO
var has_rally := false
var placing_rally := false
var selected = null

## pos: 건물 중심, spot: 용병이 모이는 자리, spread: 모이는 범위, label: 이름표 위치
var buildings: Dictionary = {
	"hall": {"name": "영주관", "pos": Vector2(272, 184), "spot": Vector2(272, 226), "spread": Vector2(40, 5), "label": Vector2(272, 150)},
	"inn": {"name": "여관", "pos": Vector2(152, 88), "spot": Vector2(152, 124), "spread": Vector2(18, 4), "label": Vector2(152, 58)},
	"mess": {"name": "식당", "pos": Vector2(392, 88), "spot": Vector2(392, 124), "spread": Vector2(18, 4), "label": Vector2(392, 58)},
	"training": {"name": "훈련장", "pos": Vector2(152, 240), "spot": Vector2(152, 266), "spread": Vector2(30, 3), "label": Vector2(152, 220)},
	"farm": {"name": "밭", "pos": Vector2(408, 232), "spot": Vector2(408, 236), "spread": Vector2(30, 10), "label": Vector2(408, 204)},
	"forest": {"name": "숲", "pos": Vector2(48, 80), "spot": Vector2(56, 126), "spread": Vector2(36, 3), "label": Vector2(104, 40)},
	"plaza": {"name": "광장", "pos": Vector2(280, 104), "spot": Vector2(280, 108), "spread": Vector2(22, 10), "label": Vector2(280, 76)},
}
var hall_rect := Rect2(224, 160, 96, 48)
var rifts: Array[Vector2] = [Vector2(590, 262), Vector2(500, 50), Vector2(22, 250)]

var mercs: Array = []
var monsters: Array = []
var log_lines: Array[String] = []

var rng := RandomNumberGenerator.new()
var dungeon_tex: Texture2D = DUNGEON_TEX
var static_tex: ImageTexture
var font_s: FontFile
var font_m: FontFile
var font_l: FontFile

var modulate_node: CanvasModulate
var hud_label: Label
var info_label: Label
var log_label: Label
var banner: Label
var banner_tween: Tween
var speed_button: Button


func _ready() -> void:
	rng.randomize()
	font_s = _load_font("res://assets/fonts/Galmuri7.ttf")
	font_m = _load_font("res://assets/fonts/Galmuri9.ttf")
	font_l = _load_font("res://assets/fonts/Galmuri11.ttf")
	_compose_static()
	modulate_node = CanvasModulate.new()
	add_child(modulate_node)
	y_sort_enabled = true
	_build_hud()
	# 시작 편성은 고정: 전사 2, 궁수 1, 사제 1. 이후 모집은 무작위.
	for job in [0, 1, 2, 0]:
		_spawn_merc(job)
	add_log("세계의 끝 영지에 도착했다. 균열의 기운이 짙다.")
	_show_banner("아그라 전기 — 1일째 아침")


func _process(delta: float) -> void:
	elapsed += delta
	if not game_over:
		phase_time += delta
		if is_night:
			_update_night(delta)
		elif phase_time >= DAY_LENGTH:
			_start_night()
	_update_lighting(delta)
	_update_hud()
	queue_redraw()


# ------------------------------------------------------------------ 낮/밤

func _start_night() -> void:
	is_night = true
	phase_time = 0.0
	to_spawn = 3 + day * 2
	spawn_timer = 1.0
	_show_banner("%d일째 밤 — 균열이 열린다" % day)
	add_log("균열에서 마물이 몰려온다! (%d마리)" % to_spawn)


func _update_night(delta: float) -> void:
	spawn_timer -= delta
	if to_spawn > 0 and spawn_timer <= 0.0:
		spawn_timer = maxf(0.6, 2.0 - day * 0.15)
		to_spawn -= 1
		var elite := day % 3 == 0 and to_spawn == 0
		_spawn_monster(elite)
	if to_spawn <= 0 and monsters.is_empty():
		_start_day()


func _start_day() -> void:
	is_night = false
	phase_time = 0.0
	day += 1
	var wage := mercs.size() * WAGE_PER_MERC
	if gold >= wage:
		gold -= wage
		add_log("새벽이 왔다. 임금 %d 금화 지급." % wage)
	else:
		gold = 0.0
		for m in mercs:
			m.morale = maxf(0.0, m.morale - 25.0)
		add_log("임금 체불! 용병들의 사기가 떨어졌다.")
	for m in mercs:
		m.on_dawn()
	_show_banner("%d일째 아침" % day)


func _update_lighting(delta: float) -> void:
	var target := Color(1, 1, 1)
	if is_night:
		target = Color(0.45, 0.42, 0.72)
	elif phase_time > DAY_LENGTH - 8.0:
		target = Color(1.0, 0.8, 0.68)
	modulate_node.color = modulate_node.color.lerp(target, clampf(delta * 1.5, 0.0, 1.0))


# ------------------------------------------------------------------ 생성/전투

func _spawn_merc(forced_job: int = -1) -> void:
	var m: Mercenary = Mercenary.new()
	m.game = self
	m.position = building_pos("plaza")
	add_child(m)
	var taken: Array[String] = []
	for other in mercs:
		taken.append(other.merc_name)
	m.randomize_identity(rng, forced_job, taken)
	if not mercs.is_empty():
		m.friend = mercs[rng.randi() % mercs.size()]
	mercs.append(m)
	add_log("%s(%s · %s) 합류." % [m.merc_name, m.job_name(), m.trait_text()])


func _spawn_monster(elite: bool) -> void:
	var mo: Monster = Monster.new()
	mo.game = self
	var r: Vector2 = rifts[rng.randi() % rifts.size()]
	mo.position = r + Vector2(rng.randf_range(-8, 8), rng.randf_range(-8, 8))
	mo.setup(day, elite, rng)
	add_child(mo)
	monsters.append(mo)
	if elite:
		add_log("엘리트 마물이 나타났다!")


func on_monster_killed(mo) -> void:
	monsters.erase(mo)
	gold += mo.reward
	if mo.elite:
		residue += 3
		add_log("엘리트 마물 처치! 마물의 잔재 +3")
	elif rng.randf() < 0.2:
		residue += 1
	mo.queue_free()


func damage_hall(amount: float) -> void:
	if game_over:
		return
	hall_hp -= amount
	if hall_hp <= 0.0:
		hall_hp = 0.0
		game_over = true
		_show_banner("영주관이 무너졌다... (R: 다시 시작)", true)
		add_log("%d일째 밤, 세계의 끝 영지가 함락되었다." % day)


func building_pos(key: String) -> Vector2:
	var b: Dictionary = buildings[key]
	var p: Vector2 = b["spot"]
	var s: Vector2 = b["spread"]
	return (p + Vector2(rng.randf_range(-s.x, s.x), rng.randf_range(-s.y, s.y))).round()


# ------------------------------------------------------------------ 입력

func _unhandled_input(event: InputEvent) -> void:
	var key := event as InputEventKey
	if key and key.pressed and not key.echo:
		if key.keycode == KEY_R and game_over:
			Engine.time_scale = 1.0
			get_tree().reload_current_scene()
		elif key.keycode == KEY_SPACE:
			_on_speed()
		return
	var mb := event as InputEventMouseButton
	if mb == null or not mb.pressed:
		return
	var p := get_global_mouse_position()
	if mb.button_index == MOUSE_BUTTON_RIGHT:
		placing_rally = false
		return
	if mb.button_index != MOUSE_BUTTON_LEFT:
		return
	if placing_rally:
		rally_point = p
		has_rally = true
		placing_rally = false
		add_log("집결 지점 지정. 밤에 이곳을 지킨다.")
		return
	selected = null
	var best := 12.0
	for m in mercs:
		var d: float = (m.position + Vector2(0, -7)).distance_to(p)
		if d < best:
			best = d
			selected = m


func _on_recruit() -> void:
	if mercs.size() >= MAX_MERCS:
		add_log("여관에 자리가 없다. (최대 %d명)" % MAX_MERCS)
	elif gold < RECRUIT_COST:
		add_log("금화가 부족하다.")
	else:
		gold -= RECRUIT_COST
		_spawn_merc()


func _on_rally() -> void:
	placing_rally = true
	add_log("집결 지점을 클릭하라. (우클릭: 취소)")


func _on_clear_rally() -> void:
	has_rally = false
	placing_rally = false
	add_log("집결 해제. 용병들이 스스로 판단한다.")


func _on_repair() -> void:
	if wood < 20.0:
		add_log("목재가 부족하다.")
		return
	wood -= 20.0
	hall_hp = minf(HALL_MAX_HP, hall_hp + 80.0)
	add_log("방책을 수리했다. 영주관 +80")


func _on_upgrade_training() -> void:
	if wood < 30.0:
		add_log("목재가 부족하다.")
		return
	wood -= 30.0
	train_bonus += 0.5
	add_log("훈련장 강화. 훈련 효율 x%.1f" % train_bonus)


func _on_speed() -> void:
	Engine.time_scale = 2.0 if Engine.time_scale < 1.5 else 1.0
	speed_button.text = "배속 x%d" % int(Engine.time_scale)


# ------------------------------------------------------------------ HUD

func add_log(text: String) -> void:
	log_lines.append(text)
	while log_lines.size() > 4:
		log_lines.remove_at(0)
	if log_label:
		log_label.text = "\n".join(PackedStringArray(log_lines))


func _load_font(path: String) -> FontFile:
	var f: FontFile = load(path)
	f.antialiasing = TextServer.FONT_ANTIALIASING_NONE
	f.hinting = TextServer.HINTING_NONE
	f.subpixel_positioning = TextServer.SUBPIXEL_POSITIONING_DISABLED
	f.generate_mipmaps = false
	return f


func _box(bg: Color, border: Color, width: int = 1) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.border_color = border
	s.set_border_width_all(width)
	s.set_content_margin_all(3)
	s.anti_aliasing = false
	return s


func _make_theme() -> Theme:
	var th := Theme.new()
	th.default_font = font_m
	th.default_font_size = 10
	th.set_stylebox("normal", "Button", _box(Color("6b4a2f"), COL_DARK))
	th.set_stylebox("hover", "Button", _box(Color("8a6340"), COL_DARK))
	th.set_stylebox("pressed", "Button", _box(Color("4a3220"), COL_DARK))
	th.set_stylebox("focus", "Button", StyleBoxEmpty.new())
	for c in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
		th.set_color(c, "Button", COL_TEXT)
	th.set_color("font_color", "Label", COL_TEXT)
	th.set_stylebox("panel", "Panel", _box(Color(0.12, 0.08, 0.05, 0.85), COL_DARK))
	return th


func _build_hud() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var root := Control.new()
	root.size = WORLD_SIZE
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.theme = _make_theme()
	layer.add_child(root)

	var top := Panel.new()
	top.position = Vector2(-1, -1)
	top.size = Vector2(WORLD_SIZE.x + 2, 27)
	root.add_child(top)
	var bottom := Panel.new()
	bottom.position = Vector2(-1, 294)
	bottom.size = Vector2(556, 67)
	root.add_child(bottom)

	hud_label = _make_label(Vector2(6, 2), Vector2(628, 24))
	root.add_child(hud_label)
	log_label = _make_label(Vector2(6, 298), Vector2(286, 60))
	root.add_child(log_label)
	info_label = _make_label(Vector2(300, 298), Vector2(250, 60))
	root.add_child(info_label)

	banner = _make_label(Vector2(0, 132), Vector2(WORLD_SIZE.x, 20))
	banner.add_theme_font_override("font", font_l)
	banner.add_theme_font_size_override("font_size", 12)
	banner.add_theme_constant_override("outline_size", 4)
	banner.add_theme_color_override("font_outline_color", COL_DARK)
	banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	banner.modulate.a = 0.0
	root.add_child(banner)

	var menu := VBoxContainer.new()
	menu.position = Vector2(558, 32)
	menu.size = Vector2(78, 0)
	menu.add_theme_constant_override("separation", 2)
	root.add_child(menu)
	_add_button(menu, "용병 모집\n금화 %d" % RECRUIT_COST, _on_recruit)
	_add_button(menu, "집결 지점", _on_rally)
	_add_button(menu, "집결 해제", _on_clear_rally)
	_add_button(menu, "방책 수리\n목재 20", _on_repair)
	_add_button(menu, "훈련장 강화\n목재 30", _on_upgrade_training)
	speed_button = _add_button(menu, "배속 x1", _on_speed)


func _make_label(pos: Vector2, sz: Vector2) -> Label:
	var l := Label.new()
	l.position = pos
	l.size = sz
	l.clip_text = true
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l


func _add_button(parent: Control, text: String, cb: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.focus_mode = Control.FOCUS_NONE
	b.pressed.connect(cb)
	parent.add_child(b)
	return b


func _show_banner(text: String, sticky: bool = false) -> void:
	if banner_tween and banner_tween.is_valid():
		banner_tween.kill()
	banner.text = text
	banner.modulate.a = 1.0
	if sticky:
		return
	banner_tween = create_tween()
	banner_tween.tween_interval(1.8)
	banner_tween.tween_property(banner, "modulate:a", 0.0, 1.2)


func _update_hud() -> void:
	var phase := ""
	if is_night:
		phase = "밤 · 남은 마물 %d" % (to_spawn + monsters.size())
	else:
		phase = "낮 · 밤까지 %d초" % maxi(0, int(DAY_LENGTH - phase_time))
	hud_label.text = "%d일째  %s        영주관 %d/%d    용병 %d/%d\n금화 %d    식량 %d    목재 %d    마물의 잔재 %d" % [
		day, phase, int(hall_hp), int(HALL_MAX_HP), mercs.size(), MAX_MERCS,
		int(gold), int(food), int(wood), residue]
	if selected != null and is_instance_valid(selected):
		info_label.text = selected.describe()
	else:
		info_label.text = "용병을 클릭하면 정보를 볼 수 있다.\nSPACE 배속 · 우클릭 집결 취소"


# ------------------------------------------------------------------ 맵 (정적 부분은 한 장의 이미지로 미리 합성)

static func tile_src(index: int) -> Rect2i:
	return Rect2i((index % 12) * TILE, (index / 12) * TILE, TILE, TILE)


func _stamp(img: Image, src: Image, index: int, tx: int, ty: int) -> void:
	img.blend_rect(src, tile_src(index), Vector2i(tx * TILE, ty * TILE))


func _stamp_block(img: Image, src: Image, rows: Array, tx: int, ty: int) -> void:
	for r in rows.size():
		var row: Array = rows[r]
		for c in row.size():
			_stamp(img, src, row[c], tx + c, ty + r)


func _compose_static() -> void:
	var src: Image = TOWN_TEX.get_image()
	if src.is_compressed():
		src.decompress()
	src.convert(Image.FORMAT_RGBA8)
	var img := Image.create(int(WORLD_SIZE.x), int(WORLD_SIZE.y), false, Image.FORMAT_RGBA8)
	var h := RandomNumberGenerator.new()
	h.seed = 7
	# 잔디
	for ty in 23:
		for tx in 40:
			var roll := h.randf()
			_stamp(img, src, 2 if roll < 0.05 else (1 if roll < 0.2 else 0), tx, ty)
	# 길 (징검돌)
	var path: Array[Vector2i] = []
	for x in range(1, 27):
		path.append(Vector2i(x, 8))
	for x in range(12, 22):
		path.append(Vector2i(x, 13))
	for y in range(9, 13):
		path.append(Vector2i(12, y))
		path.append(Vector2i(21, y))
	path.append(Vector2i(9, 7))
	path.append(Vector2i(24, 7))
	for y in range(9, 14):
		path.append(Vector2i(9, y))
	for y in range(9, 13):
		path.append(Vector2i(26, y))
	for cell in path:
		_stamp(img, src, 43, cell.x, cell.y)
	# 광장과 우물
	for y in range(5, 8):
		for x in range(16, 19):
			_stamp(img, src, 43, x, y)
	_stamp(img, src, 104, 17, 6)
	# 밭
	_stamp_block(img, src, [[12, 13, 13, 13, 14], [24, 25, 25, 25, 26], [36, 37, 37, 37, 38]], 23, 13)
	for x in range(24, 27):
		_stamp(img, src, 17, x, 14)
	_stamp(img, src, 94, 29, 13)
	_stamp(img, src, 94, 29, 15)
	# 건물
	_stamp_block(img, src, [[52, 53, 54], [64, 67, 66], [88, 89, 91]], 8, 4)    # 여관
	_stamp_block(img, src, [[48, 49, 50], [60, 63, 62], [84, 85, 87]], 23, 4)   # 식당
	_stamp(img, src, 83, 26, 6)
	_stamp_block(img, src, [[96, 97, 97, 97, 97, 98], [108, 109, 109, 109, 109, 110],
		[126, 125, 111, 112, 125, 126]], 14, 10)                                  # 영주관
	# 훈련장
	_stamp_block(img, src, [[44, 45, 45, 45, 46]], 7, 14)
	_stamp(img, src, 95, 8, 15)
	_stamp(img, src, 95, 10, 15)
	_stamp(img, src, 83, 6, 15)
	# 숲
	var trees := [16, 28, 16, 5, 28]
	for ty in range(2, 8):
		for tx in range(0, 6):
			if ty >= 6 and tx >= 4:
				continue
			if h.randf() < 0.15:
				continue
			_stamp(img, src, trees[h.randi() % trees.size()], tx, ty)
	# 가장자리 나무
	for p in [Vector2i(32, 9), Vector2i(31, 16), Vector2i(4, 11), Vector2i(2, 14), Vector2i(19, 16),
			Vector2i(13, 2), Vector2i(29, 3), Vector2i(21, 3), Vector2i(33, 12), Vector2i(15, 16)]:
		_stamp(img, src, [16, 28, 15, 27, 5][h.randi() % 5], p.x, p.y)
	static_tex = ImageTexture.create_from_image(img)


func _draw() -> void:
	draw_texture(static_tex, Vector2.ZERO)
	# 균열
	for r in rifts:
		var pulse := int(elapsed * 4.0) % 2
		draw_circle(r, 20.0, Color(0.1, 0.02, 0.15, 0.55))
		draw_circle(r, 11.0 + pulse, Color("4a1466"))
		draw_circle(r, 7.0, Color("7b2fa8"))
		draw_circle(r, 3.0, Color("f070ff") if is_night else Color("b05ad0"))
		for k in 6:
			var a := elapsed * 1.5 + k * TAU / 6.0
			var sp := (r + Vector2(cos(a), sin(a)) * (14.0 + (k % 2) * 4.0)).floor()
			draw_rect(Rect2(sp, Vector2(1, 1)), Color("e8a0ff"))
	# 이름표
	for key in buildings:
		var b: Dictionary = buildings[key]
		_draw_text(b["label"], b["name"], font_m, 10)
	# 영주관 내구도
	var bar := Rect2(240, 154, 64, 3)
	draw_rect(bar.grow(1), COL_DARK)
	draw_rect(Rect2(bar.position, Vector2(floorf(bar.size.x * hall_hp / HALL_MAX_HP), bar.size.y)), Color("e05a4a"))
	# 집결 지점
	if has_rally:
		draw_arc(rally_point, 90.0, 0.0, TAU, 48, Color(1, 0.9, 0.3, 0.3), 1.0)
		var rp := rally_point.floor()
		draw_rect(Rect2(rp + Vector2(0, -14), Vector2(1, 14)), Color("5a3a20"))
		draw_rect(Rect2(rp + Vector2(1, -14), Vector2(7, 5)), Color("e8c547"))
	if placing_rally:
		draw_rect(Rect2(get_global_mouse_position().floor() - Vector2(1, 1), Vector2(3, 3)), Color(1, 0.9, 0.3))


## 가운데 정렬 + 외곽선 텍스트
func _draw_text(center: Vector2, text: String, font: Font, size: int) -> void:
	var w := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
	var p := Vector2(floorf(center.x - w / 2.0), floorf(center.y))
	draw_string_outline(font, p, text, HORIZONTAL_ALIGNMENT_LEFT, -1, size, 3, COL_DARK)
	draw_string(font, p, text, HORIZONTAL_ALIGNMENT_LEFT, -1, size, COL_TEXT)
