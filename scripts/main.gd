extends Node2D
## 아그라 전기 - 프로토타입 메인
## 마을 운영(자원·명령) + 낮/밤 순환 + 균열 웨이브 침공을 관리한다.
## 그래픽: Kenney Tiny Town / Tiny Dungeon (CC0), 폰트: 갈무리 (OFL)

const Mercenary = preload("res://scripts/mercenary.gd")
const Monster = preload("res://scripts/monster.gd")
const JobData = preload("res://scripts/job_data.gd")
const MapArt = preload("res://scripts/map_art.gd")
const TOWN_TEX := preload("res://assets/kenney_tiny_town/tilemap_packed.png")
const DUNGEON_TEX := preload("res://assets/kenney_tiny_dungeon/tilemap_packed.png")

const WORLD_SIZE := Vector2(640, 360)
const TILE := 16
const DAY_LENGTH := 45.0
const HALL_MAX_HP := 400.0
const RECRUIT_COST := 60
const WAGE_PER_MERC := 5
const MAX_MERCS := 10
const TRAIN_SUPPORT_COST := 30
const TRAIN_SUPPORT_XP := 20.0
const VACATION_COST := 10

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
	"hall": {"name": "영주관", "pos": Vector2(272, 184), "spot": Vector2(272, 226), "spread": Vector2(40, 5), "label": Vector2(272, 140)},
	"inn": {"name": "여관", "pos": Vector2(152, 88), "spot": Vector2(152, 124), "spread": Vector2(18, 4), "label": Vector2(152, 58)},
	"mess": {"name": "식당", "pos": Vector2(392, 88), "spot": Vector2(392, 124), "spread": Vector2(18, 4), "label": Vector2(392, 58)},
	"training": {"name": "훈련장", "pos": Vector2(152, 240), "spot": Vector2(152, 266), "spread": Vector2(30, 3), "label": Vector2(152, 220)},
	"farm": {"name": "밭", "pos": Vector2(408, 232), "spot": Vector2(408, 236), "spread": Vector2(30, 10), "label": Vector2(408, 204)},
	"forest": {"name": "숲", "pos": Vector2(48, 80), "spot": Vector2(56, 136), "spread": Vector2(36, 3), "label": Vector2(104, 40)},
	"plaza": {"name": "광장", "pos": Vector2(280, 104), "spot": Vector2(280, 136), "spread": Vector2(40, 3), "label": Vector2(280, 76)},
}
var hall_rect := Rect2(224, 160, 96, 48)
var rifts: Array[Vector2] = [Vector2(590, 262), Vector2(500, 50), Vector2(22, 250)]

var mercs: Array = []
var monsters: Array = []
var summons: Array = []
var log_lines: Array[String] = []

var rng := RandomNumberGenerator.new()
var dungeon_tex: Texture2D = DUNGEON_TEX
var nav := AStarGrid2D.new()
var static_tex: ImageTexture
var font_s: FontFile
var font_m: FontFile
var font_l: FontFile

var modulate_node: CanvasModulate
var hud_label: Label
var res_labels: Array[Label] = []
var info_label: Label
var log_label: Label
var banner: Label
var banner_tween: Tween
var speed_button: Button
var growth_panel: Panel
var growth_text: RichTextLabel
var promote_button: Button
var dismiss_button: Button
var dismiss_armed := false
var last_growth_text := ""


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
	# 시작 편성은 고정: 기사 · 거너 · 힐러 · 마법사. 이후 모집은 직업도 무작위.
	for job_id in ["knight", "gunner", "healer", "mage"]:
		_spawn_merc(job_id)
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
	for m in mercs:
		m.on_night_start()
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
	for sm in summons:
		if is_instance_valid(sm):
			sm.queue_free()
	summons.clear()
	_show_banner("%d일째 아침" % day)


func _update_lighting(delta: float) -> void:
	var target := Color(1, 1, 1)
	if is_night:
		target = Color(0.45, 0.42, 0.72)
	elif phase_time > DAY_LENGTH - 8.0:
		target = Color(1.0, 0.8, 0.68)
	modulate_node.color = modulate_node.color.lerp(target, clampf(delta * 1.5, 0.0, 1.0))


# ------------------------------------------------------------------ 생성/전투

func _spawn_merc(forced_job: String = "") -> void:
	var m: Mercenary = Mercenary.new()
	m.game = self
	m.position = building_pos("plaza")
	add_child(m)
	var taken: Array[String] = []
	for other in mercs:
		taken.append(other.merc_name)
	m.roll_identity(rng, forced_job, taken)
	if not mercs.is_empty():
		m.friend = mercs[rng.randi() % mercs.size()]
	mercs.append(m)
	add_log("[%s] %s(%s) 합류." % [m.grade_info()["name"], m.merc_name, m.title()])
	if m.grade == JobData.GRADES.size() - 1:
		_show_banner("레전더리 쪼꼬미 %s 탄생!" % m.merc_name)


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
	for i in 12:
		var c := (p + Vector2(rng.randf_range(-s.x, s.x), rng.randf_range(-s.y, s.y))).round()
		if is_walkable(c):
			return c
	return p


# ------------------------------------------------------------------ 길찾기
## 16px 격자 A*. 길(징검돌) 비용 1, 잔디·흙 비용 3 → 용병은 되도록 길로 다닌다.

func _build_nav(roads: Array[Vector2i], blocked: Array[Vector2i]) -> void:
	nav.region = Rect2i(0, 0, 40, 23)
	nav.cell_size = Vector2(TILE, TILE)
	nav.offset = Vector2(TILE / 2.0, TILE / 2.0)
	nav.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	nav.default_compute_heuristic = AStarGrid2D.HEURISTIC_OCTILE
	nav.default_estimate_heuristic = AStarGrid2D.HEURISTIC_OCTILE
	nav.update()
	nav.fill_weight_scale_region(nav.region, 3.0)
	for c in roads:
		nav.set_point_weight_scale(c, 1.0)
	for c in blocked:
		nav.set_point_solid(c, true)


func cell_of(p: Vector2) -> Vector2i:
	return Vector2i(clampi(int(p.x / TILE), 0, 39), clampi(int(p.y / TILE), 0, 22))


func is_walkable(p: Vector2) -> bool:
	return not nav.is_point_solid(cell_of(p))


## 목적지가 막혀 있으면 가장 가까운 칸까지의 경로를 돌려준다. 첫 점(현재 칸)은 뺀다.
func find_path(from: Vector2, to: Vector2) -> PackedVector2Array:
	var pts := nav.get_point_path(cell_of(from), cell_of(to), true)
	if pts.size() > 0:
		pts.remove_at(0)
	return pts


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
	var picked = null
	var best := 12.0
	for m in mercs:
		var d: float = (m.position + Vector2(0, -9)).distance_to(p)
		if d < best:
			best = d
			picked = m
	select(picked)


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


# ------------------------------------------------------------------ 육성

func select(m) -> void:
	selected = m
	dismiss_armed = false
	last_growth_text = ""
	if growth_panel:
		growth_panel.visible = m != null


## 금화로 집중 훈련을 지원한다: 즉시 경험치.
func train_support(m) -> bool:
	if gold < TRAIN_SUPPORT_COST:
		add_log("금화가 부족하다.")
		return false
	gold -= TRAIN_SUPPORT_COST
	m.gain_xp(TRAIN_SUPPORT_XP)
	add_log("%s에게 훈련 지원. 경험치 +%d" % [m.merc_name, int(TRAIN_SUPPORT_XP)])
	return true


## 휴가: 기력 · 사기 회복.
func vacation(m) -> bool:
	if gold < VACATION_COST:
		add_log("금화가 부족하다.")
		return false
	gold -= VACATION_COST
	m.energy = 100.0
	m.morale = minf(100.0, m.morale + 25.0)
	add_log("%s에게 휴가를 줬다. 기력·사기 회복." % m.merc_name)
	return true


## 전직: 레벨 조건 + 마물의 잔재 + 금화.
func try_promote(m) -> bool:
	var nt: Dictionary = m.next_tier()
	if nt.is_empty():
		add_log("%s은(는) 이미 최고 단계다." % m.merc_name)
		return false
	if m.level < int(nt["level"]):
		add_log("전직하려면 Lv.%d이 필요하다." % int(nt["level"]))
		return false
	if residue < int(nt["residue"]) or gold < int(nt["gold"]):
		add_log("전직 비용 부족: 잔재 %d, 금화 %d" % [int(nt["residue"]), int(nt["gold"])])
		return false
	residue -= int(nt["residue"])
	gold -= int(nt["gold"])
	m.promote()
	add_log("%s, %s(으)로 전직!" % [m.merc_name, m.title()])
	_show_banner("%s → %s" % [m.merc_name, m.title()])
	return true


## 방출: 쪼꼬미를 영지에서 내보낸다. 되돌릴 수 없다.
func dismiss_merc(m) -> void:
	if not mercs.has(m):
		return
	mercs.erase(m)
	m.clear_summons()
	for o in mercs:
		if o.friend == m:
			o.friend = null
			o.morale = maxf(0.0, o.morale - 10.0)
	if selected == m:
		select(null)
	add_log("%s을(를) 방출했다." % m.merc_name)
	m.queue_free()


func _on_train_support() -> void:
	if selected != null and is_instance_valid(selected):
		train_support(selected)


func _on_vacation() -> void:
	if selected != null and is_instance_valid(selected):
		vacation(selected)


func _on_promote() -> void:
	if selected != null and is_instance_valid(selected):
		try_promote(selected)


func _on_dismiss() -> void:
	if selected == null or not is_instance_valid(selected):
		return
	if not dismiss_armed:
		dismiss_armed = true
		dismiss_button.text = "정말 방출?"
		return
	dismiss_merc(selected)


func _on_close_panel() -> void:
	select(null)


func _build_growth_panel(root: Control) -> void:
	growth_panel = Panel.new()
	growth_panel.position = Vector2(300, 30)
	growth_panel.size = Vector2(254, 262)
	growth_panel.visible = false
	growth_panel.add_theme_stylebox_override("panel", _frame("ui_panel", 6, Vector2(6, 6)))
	root.add_child(growth_panel)
	growth_text = RichTextLabel.new()
	growth_text.bbcode_enabled = true
	growth_text.scroll_active = false
	growth_text.position = Vector2(6, 4)
	growth_text.size = Vector2(242, 206)
	growth_text.mouse_filter = Control.MOUSE_FILTER_IGNORE
	growth_panel.add_child(growth_text)
	var grid := GridContainer.new()
	grid.columns = 3
	grid.position = Vector2(6, 214)
	grid.add_theme_constant_override("h_separation", 2)
	grid.add_theme_constant_override("v_separation", 2)
	growth_panel.add_child(grid)
	var buttons: Array[Button] = []
	buttons.append(_add_button(grid, "훈련 지원 %dG" % TRAIN_SUPPORT_COST, _on_train_support))
	buttons.append(_add_button(grid, "휴가 %dG" % VACATION_COST, _on_vacation))
	promote_button = _add_button(grid, "전직", _on_promote)
	buttons.append(promote_button)
	dismiss_button = _add_button(grid, "방출", _on_dismiss)
	buttons.append(dismiss_button)
	buttons.append(_add_button(grid, "닫기", _on_close_panel))
	for b in buttons:
		b.custom_minimum_size = Vector2(79, 20)


func _growth_bbcode(m) -> String:
	var g: Dictionary = m.grade_info()
	var j: Dictionary = m.job()
	var gc: String = (g["color"] as Color).to_html(false)
	var t := "[color=#%s]◆ %s[/color]  %s (%s)  Lv.%d\n" % [gc, g["name"], m.merc_name, m.gender, m.level]
	t += "%s  [color=#a89878](%s %d단계 · %s)[/color]\n" % [m.title(), j["name"], m.tier + 1, j["role"]]
	t += "경험치 %d / %d\n" % [int(m.xp), int(m.xp_needed())]
	var parts: Array[String] = []
	for sid in JobData.STATS:
		var v: float = m.stats[sid]
		var sname: String = JobData.STAT_NAMES[sid]
		if sid == j["primary"]:
			parts.append("[color=#ffd84a]%s %d[/color]" % [sname, int(v)])
		else:
			parts.append("%s %d" % [sname, int(v)])
	t += "  ".join(PackedStringArray(parts.slice(0, 3))) + "\n"
	t += "  ".join(PackedStringArray(parts.slice(3))) + "   [color=#a89878]합계 %d[/color]\n" % int(m.stat_total())
	t += "체력 %d/%d  공격 %d  방어 %d\n" % [int(m.hp), int(m.max_hp), int(m.atk), int(m.defense)]
	t += "사거리 %d  공격 간격 %.1f초\n" % [int(m.attack_range), m.attack_interval]
	t += "[color=#a89878]%s[/color]\n" % j["perk"]
	t += "성격: %s\n" % m.trait_text()
	var friend_name := "-"
	if m.friend != null and is_instance_valid(m.friend):
		friend_name = m.friend.merc_name
	t += "기력 %d  허기 %d  사기 %d  친구 %s\n" % [int(m.energy), int(m.hunger), int(m.morale), friend_name]
	var nt: Dictionary = m.next_tier()
	if nt.is_empty():
		t += "[color=#ffd84a]최고 단계에 도달했다[/color]"
	else:
		var ready: bool = m.level >= int(nt["level"])
		t += "[color=#%s]다음 전직: %s\nLv.%d · 잔재 %d · 금화 %d[/color]" % [
			"7fe07f" if ready else "a89878", nt["name"], int(nt["level"]), int(nt["residue"]), int(nt["gold"])]
	return t


func _update_growth_panel() -> void:
	if growth_panel == null or not growth_panel.visible:
		return
	if selected == null or not is_instance_valid(selected):
		select(null)
		return
	var t := _growth_bbcode(selected)
	if t != last_growth_text:
		last_growth_text = t
		growth_text.text = t
	var nt: Dictionary = selected.next_tier()
	promote_button.disabled = nt.is_empty() or selected.level < int(nt["level"])
	if not dismiss_armed:
		dismiss_button.text = "방출"


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


## 자체 그림 테두리(assets/agra/ui_*.png)를 9칸으로 늘려 쓰는 스타일. tint로 눌림·비활성 표현.
func _frame(name: String, margin: int, content: Vector2, tint := Color.WHITE) -> StyleBoxTexture:
	var s := StyleBoxTexture.new()
	s.texture = MapArt.own_tex(name)
	s.set_texture_margin_all(margin)
	s.content_margin_left = content.x
	s.content_margin_right = content.x
	s.content_margin_top = content.y
	s.content_margin_bottom = content.y
	s.modulate_color = tint
	return s


func _make_theme() -> Theme:
	var th := Theme.new()
	th.default_font = font_m
	th.default_font_size = 10
	var pad := Vector2(5, 3)
	th.set_stylebox("normal", "Button", _frame("ui_button", 5, pad))
	th.set_stylebox("hover", "Button", _frame("ui_button", 5, pad, Color(1.25, 1.18, 1.1)))
	th.set_stylebox("pressed", "Button", _frame("ui_button", 5, pad, Color(0.72, 0.66, 0.62)))
	th.set_stylebox("focus", "Button", StyleBoxEmpty.new())
	for c in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
		th.set_color(c, "Button", COL_TEXT)
	th.set_color("font_color", "Label", COL_TEXT)
	th.set_stylebox("disabled", "Button", _frame("ui_button", 5, pad, Color(0.5, 0.5, 0.5)))
	th.set_color("font_disabled_color", "Button", Color("8a7a68"))
	th.set_font("normal_font", "RichTextLabel", font_m)
	th.set_font("bold_font", "RichTextLabel", font_m)
	th.set_font_size("normal_font_size", "RichTextLabel", 10)
	th.set_font_size("bold_font_size", "RichTextLabel", 10)
	th.set_color("default_color", "RichTextLabel", COL_TEXT)
	th.set_stylebox("panel", "Panel", _frame("ui_panel", 6, Vector2(6, 6), Color(1, 1, 1, 0.95)))
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

	hud_label = _make_label(Vector2(6, 2), Vector2(628, 12))
	root.add_child(hud_label)
	# 자원 줄: 아이콘(금화·식량·목재·잔재) + 숫자
	var icons := MapArt.own_tex("icons")
	for i in 4:
		var ic := TextureRect.new()
		var at := AtlasTexture.new()
		at.atlas = icons
		at.region = Rect2(i * 14, 0, 14, 14)
		ic.texture = at
		ic.position = Vector2(4 + i * 72, 12)
		ic.mouse_filter = Control.MOUSE_FILTER_IGNORE
		root.add_child(ic)
		var l := _make_label(Vector2(20 + i * 72, 13), Vector2(52, 12))
		root.add_child(l)
		res_labels.append(l)
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
	_build_growth_panel(root)


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
	hud_label.text = "%d일째  %s        영주관 %d/%d    용병 %d/%d" % [
		day, phase, int(hall_hp), int(HALL_MAX_HP), mercs.size(), MAX_MERCS]
	var vals := [int(gold), int(food), int(wood), residue]
	var names := ["금화", "식량", "목재", "잔재"]
	for i in res_labels.size():
		res_labels[i].text = "%s %d" % [names[i], vals[i]]
	if selected != null and is_instance_valid(selected):
		info_label.text = selected.describe()
	else:
		info_label.text = "쪼꼬미를 클릭하면 육성 창이 열린다.\nSPACE 배속 · 우클릭 집결 취소"
	_update_growth_panel()


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


## 영주관·여관·식당 (assets/agra, 자체 그림). 발밑 가운데를 건물 칸 묶음의 아래 가운데에 맞춘다.
## 영주관은 성벽이 한 줄 위로 솟아서 그 줄도 막는다.
func _place_buildings(img: Image, blocked: Array[Vector2i]) -> void:
	for b in [["inn", Rect2i(8, 4, 3, 3)], ["mess", Rect2i(23, 4, 3, 3)], ["hall", Rect2i(14, 10, 6, 3)]]:
		var art: Image = MapArt.own(b[0])
		var r: Rect2i = b[1]
		var foot := Vector2i(int((r.position.x + r.size.x / 2.0) * TILE), r.end.y * TILE)
		img.blend_rect(art, Rect2i(Vector2i.ZERO, art.get_size()), foot - Vector2i(art.get_width() / 2, art.get_height()))
		for y in range(r.position.y, r.end.y):
			for x in range(r.position.x, r.end.x):
				blocked.append(Vector2i(x, y))
	for x in range(14, 20):
		blocked.append(Vector2i(x, 9))


## 자체 그림 띠에서 한 프레임을 발밑(foot) 기준으로 맵에 찍는다.
func _stamp_own(img: Image, name: String, frame: int, w: int, h: int, foot: Vector2i) -> void:
	img.blend_rect(MapArt.own(name), Rect2i(frame * w, 0, w, h), foot - Vector2i(w / 2, h))


## 큰길·샛길 칸 (길찾기 비용 1). 그림과 상관없이 같은 배치.
func _road_cells() -> Array[Vector2i]:
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
	return path


## Super Retro World 무료판으로 마을을 그린다. 배치는 Kenney판과 같다.
func _compose_srw() -> void:
	var img := Image.create(int(WORLD_SIZE.x), int(WORLD_SIZE.y), false, Image.FORMAT_RGBA8)
	var h := RandomNumberGenerator.new()
	h.seed = 7
	var blocked: Array[Vector2i] = []
	for ty in 23:
		for tx in 40:
			MapArt.grass(img, tx, ty)
	var path := _road_cells()
	# 돌길 + 광장 (광장은 길과 이어 붙여 한 덩어리)
	var cobble: Array = path.duplicate()
	for y in range(5, 8):
		for x in range(15, 20):
			cobble.append(Vector2i(x, y))
	MapArt.autotile(img, "cobble", cobble)
	# 밭: 흙 5x3 + 작물
	var farm: Array = []
	for y in range(13, 16):
		for x in range(23, 28):
			farm.append(Vector2i(x, y))
	MapArt.autotile(img, "dirt", farm)
	for y in range(13, 16):
		for x in range(24, 27):
			_stamp_own(img, "crops", h.randi() % 4, 16, 22, Vector2i(x * TILE + 8, (y + 1) * TILE))
	MapArt.prop(img, "post", 29, 13)
	MapArt.prop(img, "post", 29, 15)
	blocked.append_array([Vector2i(29, 13), Vector2i(29, 15)])
	# 광장: 가운데 분수, 양옆 가로등
	_stamp_own(img, "prop_fountain", 0, 36, 40, Vector2i(280, 120))
	MapArt.prop(img, "lamp", 15, 6)
	MapArt.prop(img, "lamp", 19, 6)
	for c in [Vector2i(16, 6), Vector2i(17, 6), Vector2i(18, 6), Vector2i(16, 5), Vector2i(17, 5), Vector2i(18, 5),
			Vector2i(15, 6), Vector2i(19, 6), Vector2i(17, 7)]:
		blocked.append(c)
	# 식당 옆 통, 여관 옆 표지판
	MapArt.prop(img, "barrel", 26, 6)
	MapArt.prop(img, "bucket", 26, 5)
	MapArt.prop(img, "sign", 11, 7)
	blocked.append_array([Vector2i(26, 6), Vector2i(26, 5)])
	# 훈련장: 울타리 + 허수아비 대신 말뚝, 상자
	MapArt.prop(img, "fence_l", 7, 14)
	for x in range(8, 11):
		MapArt.prop(img, "fence_m", x, 14)
	MapArt.prop(img, "fence_r", 11, 14)
	for x in range(7, 12):
		blocked.append(Vector2i(x, 14))
	_stamp_own(img, "prop_scarecrow", 0, 20, 24, Vector2i(8 * TILE + 8, 16 * TILE))
	_stamp_own(img, "prop_target", 0, 20, 24, Vector2i(10 * TILE + 8, 16 * TILE))
	MapArt.prop(img, "crate", 6, 15)
	blocked.append_array([Vector2i(8, 15), Vector2i(10, 15), Vector2i(6, 15)])
	# 숲: 큰 나무(2x2)와 소나무를 엇갈려
	for ty in range(3, 8, 2):
		for tx in range(0, 6, 2):
			if ty >= 6 and tx >= 4:
				continue
			if h.randf() < 0.75:
				MapArt.prop(img, "tree_big", tx, ty)
				for c in [Vector2i(tx, ty), Vector2i(tx + 1, ty), Vector2i(tx, ty - 1), Vector2i(tx + 1, ty - 1)]:
					blocked.append(c)
			else:
				MapArt.prop(img, "pine", tx, ty)
				MapArt.prop(img, "bush", tx + 1, ty)
				blocked.append_array([Vector2i(tx, ty), Vector2i(tx, ty - 1), Vector2i(tx + 1, ty)])
	# 가장자리 나무
	for p in [Vector2i(32, 9), Vector2i(31, 16), Vector2i(4, 11), Vector2i(2, 14), Vector2i(19, 16),
			Vector2i(13, 2), Vector2i(29, 3), Vector2i(21, 3), Vector2i(33, 12), Vector2i(15, 16)]:
		var k: String = ["pine", "pine", "bush"][h.randi() % 3]
		MapArt.prop(img, k, p.x, p.y)
		blocked.append(p)
	_place_buildings(img, blocked)
	# 풀밭 장식 (지나갈 수 있음): 꽃·풀포기·작은 돌
	var taken := {}
	for c in cobble + farm + blocked:
		taken[c] = true
	for ty in range(1, 23):
		for tx in 40:
			var c := Vector2i(tx, ty)
			if taken.has(c) or h.randf() > 0.07:
				continue
			if Rect2i(7, 3, 5, 5).has_point(c) or Rect2i(22, 2, 5, 6).has_point(c) or Rect2i(13, 8, 8, 6).has_point(c):
				continue   # 건물 그림 위에는 안 놓는다
			MapArt.prop(img, ["flower_w", "flower_r", "tuft_a", "tuft_b", "rock_s"][h.randi() % 5], tx, ty)
	static_tex = ImageTexture.create_from_image(img)
	_build_nav(path, blocked)


func _compose_static() -> void:
	if MapArt.available():
		_compose_srw()
		return
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
	var path := _road_cells()
	var blocked: Array[Vector2i] = []
	for cell in path:
		_stamp(img, src, 43, cell.x, cell.y)
	# 광장과 우물
	for y in range(5, 8):
		for x in range(16, 19):
			_stamp(img, src, 43, x, y)
	_stamp(img, src, 104, 17, 6)
	blocked.append(Vector2i(17, 6))
	# 밭
	_stamp_block(img, src, [[12, 13, 13, 13, 14], [24, 25, 25, 25, 26], [36, 37, 37, 37, 38]], 23, 13)
	for x in range(24, 27):
		_stamp(img, src, 17, x, 14)
	_stamp(img, src, 94, 29, 13)
	_stamp(img, src, 94, 29, 15)
	blocked.append_array([Vector2i(29, 13), Vector2i(29, 15), Vector2i(26, 6), Vector2i(6, 15),
		Vector2i(8, 15), Vector2i(10, 15)])
	for x in range(7, 12):
		blocked.append(Vector2i(x, 14))
	# 건물
	_stamp(img, src, 83, 26, 6)
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
			blocked.append(Vector2i(tx, ty))
	# 가장자리 나무
	for p in [Vector2i(32, 9), Vector2i(31, 16), Vector2i(4, 11), Vector2i(2, 14), Vector2i(19, 16),
			Vector2i(13, 2), Vector2i(29, 3), Vector2i(21, 3), Vector2i(33, 12), Vector2i(15, 16)]:
		_stamp(img, src, [16, 28, 15, 27, 5][h.randi() % 5], p.x, p.y)
		blocked.append(p)
	_place_buildings(img, blocked)
	static_tex = ImageTexture.create_from_image(img)
	_build_nav(path, blocked)


func _draw() -> void:
	draw_texture(static_tex, Vector2.ZERO)
	# 균열
	var rift_tex := MapArt.own_tex("rift")
	var rf := int(elapsed * 6.0) % 3
	for r in rifts:
		draw_circle(r, 22.0, Color(0.1, 0.02, 0.15, 0.45))
		var glow := Color(1.25, 1.1, 1.3) if is_night else Color(0.85, 0.85, 0.9, 0.85)
		draw_texture_rect_region(rift_tex, Rect2(r - Vector2(20, 20), Vector2(40, 40)), Rect2(rf * 40, 0, 40, 40), glow)
		for k in 6:
			var a := elapsed * 1.5 + k * TAU / 6.0
			var sp := (r + Vector2(cos(a), sin(a)) * (20.0 + (k % 2) * 4.0)).floor()
			draw_rect(Rect2(sp, Vector2(1, 1)), Color("e8a0ff"))
	# 이름표
	for key in buildings:
		var b: Dictionary = buildings[key]
		_draw_text(b["label"], b["name"], font_m, 10)
	# 영주관 내구도
	var bar := Rect2(240, 143, 64, 3)
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
