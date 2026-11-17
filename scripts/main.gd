extends Node2D
## 아그라 전기 - 프로토타입 메인
## 마을 운영(자원·명령) + 낮/밤 순환 + 균열 웨이브 침공을 관리한다.

const Mercenary = preload("res://scripts/mercenary.gd")
const Monster = preload("res://scripts/monster.gd")

const WORLD_SIZE := Vector2(640, 360)
const DAY_LENGTH := 45.0
const HALL_MAX_HP := 300.0
const RECRUIT_COST := 60
const WAGE_PER_MERC := 5
const MAX_MERCS := 10
const START_MERCS := 4

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

var buildings: Dictionary = {
	"hall": {"name": "영주관", "pos": Vector2(320, 190), "size": Vector2(46, 34), "color": Color("8a5a3c")},
	"inn": {"name": "여관", "pos": Vector2(200, 115), "size": Vector2(40, 28), "color": Color("b5743f")},
	"mess": {"name": "식당", "pos": Vector2(440, 115), "size": Vector2(36, 26), "color": Color("c9925a")},
	"training": {"name": "훈련장", "pos": Vector2(190, 262), "size": Vector2(48, 30), "color": Color("9c8f6e")},
	"farm": {"name": "밭", "pos": Vector2(450, 268), "size": Vector2(56, 34), "color": Color("7f9c3d")},
	"forest": {"name": "숲", "pos": Vector2(75, 75), "size": Vector2(64, 52), "color": Color("2f5e34")},
	"plaza": {"name": "광장", "pos": Vector2(320, 125), "size": Vector2(34, 22), "color": Color("c8b88a")},
}
var rifts: Array[Vector2] = [Vector2(530, 30), Vector2(520, 335), Vector2(30, 330)]

var mercs: Array = []
var monsters: Array = []
var log_lines: Array[String] = []

var rng := RandomNumberGenerator.new()
var modulate_node: CanvasModulate
var hud_label: Label
var info_label: Label
var log_label: Label
var banner: Label
var banner_tween: Tween
var speed_button: Button


func _ready() -> void:
	rng.randomize()
	modulate_node = CanvasModulate.new()
	add_child(modulate_node)
	_build_hud()
	for i in START_MERCS:
		_spawn_merc()
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
		target = Color(0.42, 0.40, 0.68)
	elif phase_time > DAY_LENGTH - 8.0:
		target = Color(1.0, 0.78, 0.66)
	modulate_node.color = modulate_node.color.lerp(target, clampf(delta * 1.5, 0.0, 1.0))


# ------------------------------------------------------------------ 생성/전투

func _spawn_merc() -> void:
	var m: Mercenary = Mercenary.new()
	m.game = self
	m.position = building_pos("plaza")
	add_child(m)
	m.randomize_identity(rng)
	if not mercs.is_empty():
		m.friend = mercs[rng.randi() % mercs.size()]
	mercs.append(m)
	add_log("%s(%s · %s) 합류." % [m.merc_name, m.job_name(), m.trait_text()])


func _spawn_monster(elite: bool) -> void:
	var mo: Monster = Monster.new()
	mo.game = self
	var r: Vector2 = rifts[rng.randi() % rifts.size()]
	mo.position = r + Vector2(rng.randf_range(-8, 8), rng.randf_range(-8, 8))
	mo.setup(day, elite)
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
	var p: Vector2 = b["pos"]
	var s: Vector2 = b["size"]
	return p + Vector2(rng.randf_range(-s.x * 0.4, s.x * 0.4), rng.randf_range(-s.y * 0.3, s.y * 0.3))


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
		add_log("집결 지점을 지정했다. 밤에 용병들이 이곳을 지킨다.")
		return
	selected = null
	var best := 12.0
	for m in mercs:
		var d: float = m.position.distance_to(p)
		if d < best:
			best = d
			selected = m


func _on_recruit() -> void:
	if mercs.size() >= MAX_MERCS:
		add_log("여관에 더 머물 자리가 없다. (최대 %d명)" % MAX_MERCS)
	elif gold < RECRUIT_COST:
		add_log("금화가 부족하다.")
	else:
		gold -= RECRUIT_COST
		_spawn_merc()


func _on_rally() -> void:
	placing_rally = true
	add_log("지도에서 집결 지점을 클릭하라. (우클릭: 취소)")


func _on_clear_rally() -> void:
	has_rally = false
	placing_rally = false
	add_log("집결 지점을 해제했다. 용병들이 스스로 판단한다.")


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
	add_log("훈련장을 강화했다. 훈련 효율 x%.1f" % train_bonus)


func _on_speed() -> void:
	Engine.time_scale = 2.0 if Engine.time_scale < 1.5 else 1.0
	speed_button.text = "배속 x%d" % int(Engine.time_scale)


# ------------------------------------------------------------------ HUD

func add_log(text: String) -> void:
	log_lines.append(text)
	while log_lines.size() > 5:
		log_lines.remove_at(0)
	if log_label:
		log_label.text = "\n".join(PackedStringArray(log_lines))


func _build_hud() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)

	hud_label = _make_label(Vector2(6, 4), 10)
	layer.add_child(hud_label)

	log_label = _make_label(Vector2(6, 290), 8)
	layer.add_child(log_label)

	info_label = _make_label(Vector2(330, 300), 8)
	layer.add_child(info_label)

	banner = _make_label(Vector2(0, 150), 18)
	banner.size = Vector2(WORLD_SIZE.x, 30)
	banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	banner.modulate.a = 0.0
	layer.add_child(banner)

	var menu := VBoxContainer.new()
	menu.position = Vector2(552, 36)
	menu.custom_minimum_size = Vector2(84, 0)
	menu.add_theme_constant_override("separation", 3)
	layer.add_child(menu)
	_add_button(menu, "용병 모집\n금화 %d" % RECRUIT_COST, _on_recruit)
	_add_button(menu, "집결 지점", _on_rally)
	_add_button(menu, "집결 해제", _on_clear_rally)
	_add_button(menu, "방책 수리\n목재 20", _on_repair)
	_add_button(menu, "훈련장 강화\n목재 30", _on_upgrade_training)
	speed_button = _add_button(menu, "배속 x1", _on_speed)


func _make_label(pos: Vector2, font_size: int) -> Label:
	var l := Label.new()
	l.position = pos
	l.add_theme_font_size_override("font_size", font_size)
	l.add_theme_constant_override("outline_size", 3)
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
	return l


func _add_button(parent: Control, text: String, cb: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.focus_mode = Control.FOCUS_NONE
	b.add_theme_font_size_override("font_size", 9)
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
	hud_label.text = "%d일째 %s    영주관 %d/%d    용병 %d/%d\n금화 %d   식량 %d   목재 %d   마물의 잔재 %d" % [
		day, phase, int(hall_hp), int(HALL_MAX_HP), mercs.size(), MAX_MERCS,
		int(gold), int(food), int(wood), residue]
	if selected != null and is_instance_valid(selected):
		info_label.text = selected.describe()
	else:
		info_label.text = "용병을 클릭하면 정보를 볼 수 있다.\nSPACE: 배속   우클릭: 집결 지정 취소"


# ------------------------------------------------------------------ 그리기

func _draw() -> void:
	var font := ThemeDB.fallback_font
	draw_rect(Rect2(Vector2.ZERO, WORLD_SIZE), Color("6f9a4a"))
	# 잔디 얼룩 (고정 패턴)
	for i in 60:
		var gx := float((i * 97) % 640)
		var gy := float((i * 53 + 17) % 360)
		draw_rect(Rect2(gx, gy, 3, 2), Color("628b40"))
	# 길
	var hall_p: Vector2 = buildings["hall"]["pos"]
	for key in ["inn", "mess", "training", "farm", "plaza", "forest"]:
		var p: Vector2 = buildings[key]["pos"]
		draw_line(hall_p, p, Color("b39b6b"), 6.0)
	# 균열
	for r in rifts:
		var pulse := sin(elapsed * 3.0) * 2.0
		draw_circle(r, 28.0, Color(0.12, 0.03, 0.18, 0.55))
		draw_circle(r, 11.0 + pulse, Color("5b1a7a"))
		draw_circle(r, 5.0, Color("e040fb") if is_night else Color("9c4dcc"))
	# 건물
	for key in buildings:
		_draw_building(key, font)
	# 영주관 내구도
	var bar := Rect2(hall_p + Vector2(-23, -30), Vector2(46, 3))
	draw_rect(bar, Color(0.1, 0.1, 0.1))
	draw_rect(Rect2(bar.position, Vector2(bar.size.x * hall_hp / HALL_MAX_HP, bar.size.y)), Color("e05a4a"))
	# 집결 지점
	if has_rally:
		draw_arc(rally_point, 90.0, 0.0, TAU, 48, Color(1, 0.9, 0.3, 0.25), 1.0)
		draw_line(rally_point, rally_point + Vector2(0, -14), Color("5a3a20"), 1.0)
		draw_rect(Rect2(rally_point + Vector2(0, -14), Vector2(8, 5)), Color("e8c547"))
	if placing_rally:
		draw_circle(get_global_mouse_position(), 3.0, Color(1, 0.9, 0.3, 0.8))


func _draw_building(key: String, font: Font) -> void:
	var b: Dictionary = buildings[key]
	var p: Vector2 = b["pos"]
	var s: Vector2 = b["size"]
	var c: Color = b["color"]
	var rect := Rect2(p - s / 2.0, s)
	match key:
		"forest":
			for ix in 4:
				for iy in 3:
					var tp := rect.position + Vector2(8 + ix * 16 + (iy % 2) * 6, 8 + iy * 16)
					draw_rect(Rect2(tp + Vector2(-1, 3), Vector2(3, 5)), Color("5a3a20"))
					draw_circle(tp, 7.0, c)
					draw_circle(tp + Vector2(-2, -2), 3.0, c.lightened(0.15))
		"farm":
			draw_rect(rect, Color("8a6a3a"))
			for row in 4:
				draw_line(rect.position + Vector2(3, 5 + row * 8), rect.position + Vector2(s.x - 3, 5 + row * 8), c, 3.0)
		"plaza":
			draw_rect(rect, c)
			draw_circle(p, 5.0, Color("8fb3c9"))
		_:
			draw_rect(Rect2(rect.position + Vector2(2, 2), s), Color(0, 0, 0, 0.25))
			draw_rect(rect, c)
			draw_rect(Rect2(rect.position + Vector2(-3, -6), Vector2(s.x + 6, 10)), c.darkened(0.4))
			draw_rect(Rect2(p + Vector2(-3, s.y / 2.0 - 9), Vector2(6, 9)), Color("3a2418"))
			if key == "hall":
				draw_rect(Rect2(p + Vector2(-1, -s.y / 2.0 - 16), Vector2(1, 10)), Color("3a2418"))
				draw_rect(Rect2(p + Vector2(0, -s.y / 2.0 - 16), Vector2(8, 5)), Color("b83a3a"))
	var label_pos := p + Vector2(-s.x / 2.0 - 10, s.y / 2.0 + 9)
	draw_string(font, label_pos, b["name"], HORIZONTAL_ALIGNMENT_CENTER, s.x + 20, 8, Color(1, 1, 1, 0.9))
