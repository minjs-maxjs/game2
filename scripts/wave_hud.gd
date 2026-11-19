extends Control
## 일차·웨이브 HUD: 상단 중앙 배너 + 밤 시작 연출 + 균열 위 남은 마물 수.
## - 배너(낮): "N일차 · 낮" + 남은 시간 바 + "오늘 밤: 마물 M마리 (엘리트 1)"
## - 배너(밤): "N일차 · 밤" + "파도 2/3 · 남은 12 / 20" + 처치 진행 바 (휴식 중이면 남은 휴식 초)
## - 새벽에는 정산 창(dawn_panel.gd)이 대신 보이므로 배너를 숨긴다.
## 숫자는 wave_director.gd의 wave_info() / night_preview()에서 읽기만 한다 (계산식 복사 금지).
## 모든 노드는 mouse_filter = IGNORE: 배치 클릭을 막지 않는다. 우상단 메뉴 자리는 비워 둔다.

const StatBar = preload("res://scripts/stat_bar.gd")

const BANNER_POS := Vector2(170, 27)
const BANNER_SIZE := Vector2(300, 28)
const INTRO_Y := 86.0
const INTRO_HOLD := 1.6
const INTRO_FADE := 0.6
const COL_DAY_BAR := Color("e8c547")
const COL_NIGHT_BAR := Color("e05a4a")
const COL_REST_BAR := Color("5ad05a")
const COL_ELITE := Color("ff5a4a")
const COL_EROSION := Color("c08cff")
const EROSION_W := 90.0
const EROSION_FONT := 8

var game
var banner: Panel
var title_label: Label
var detail_label: Label
var erosion_label: Label
var bar: StatBar
var intro: Label
var intro_elite: Label
var intro_tween: Tween
var rift_counts: Node2D


func setup(g) -> void:
	game = g
	position = Vector2.ZERO
	size = g.WORLD_SIZE
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	banner = Panel.new()
	banner.position = BANNER_POS
	banner.size = BANNER_SIZE
	banner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	banner.modulate = Color(1, 1, 1, 0.92)
	add_child(banner)
	title_label = _label(banner, Vector2(7, 3), Vector2(80, 12), HORIZONTAL_ALIGNMENT_LEFT)
	detail_label = _label(banner, Vector2(84, 3), Vector2(BANNER_SIZE.x - 91, 12), HORIZONTAL_ALIGNMENT_RIGHT)
	# 침식 게이지: 배너 오른쪽 아래 바깥에 작게
	erosion_label = _label(banner, Vector2(BANNER_SIZE.x - EROSION_W - 4, BANNER_SIZE.y), Vector2(EROSION_W, 10), HORIZONTAL_ALIGNMENT_RIGHT)
	erosion_label.add_theme_font_override("font", g.font_s)
	erosion_label.add_theme_font_size_override("font_size", EROSION_FONT)
	erosion_label.add_theme_constant_override("outline_size", 3)
	erosion_label.add_theme_color_override("font_outline_color", g.COL_DARK)
	erosion_label.add_theme_color_override("font_color", COL_EROSION)
	bar = StatBar.new()
	bar.position = Vector2(8, 18)
	bar.size = Vector2(BANNER_SIZE.x - 16, 3)
	bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	banner.add_child(bar)

	intro = _label(self, Vector2(0, INTRO_Y), Vector2(g.WORLD_SIZE.x, 30), HORIZONTAL_ALIGNMENT_CENTER)
	intro.add_theme_font_override("font", g.font_l)
	intro.add_theme_font_size_override("font_size", 24)   # Galmuri11(12px)의 정수 2배
	intro.add_theme_constant_override("outline_size", 5)
	intro.add_theme_color_override("font_outline_color", g.COL_DARK)
	intro_elite = _label(self, Vector2(0, INTRO_Y + 30), Vector2(g.WORLD_SIZE.x, 16), HORIZONTAL_ALIGNMENT_CENTER)
	intro_elite.add_theme_font_override("font", g.font_l)
	intro_elite.add_theme_font_size_override("font_size", 12)
	intro_elite.add_theme_constant_override("outline_size", 4)
	intro_elite.add_theme_color_override("font_outline_color", g.COL_DARK)
	intro_elite.add_theme_color_override("font_color", COL_ELITE)
	intro.modulate.a = 0.0
	intro_elite.modulate.a = 0.0

	rift_counts = RiftCounts.new()
	rift_counts.game = g
	g.add_child(rift_counts)


func _label(parent: Control, p: Vector2, s: Vector2, align: int) -> Label:
	var l := Label.new()
	l.position = p
	l.size = s
	l.clip_text = true
	l.horizontal_alignment = align
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(l)
	return l


func _process(_delta: float) -> void:
	if game == null:
		return
	refresh()


## 배너 글자와 바를 지금 상태로 맞춘다 (테스트에서도 부른다).
func refresh() -> void:
	var dir = game.director
	banner.visible = not dir.is_dawn and not game.game_over
	if not banner.visible:
		return
	erosion_label.text = "침식 %d/%d" % [dir.erosion, dir.EROSION_MAX]
	if game.is_night:
		var wi: Dictionary = dir.wave_info()
		title_label.text = "%d일차 · 밤" % game.day
		if wi["resting"]:
			detail_label.text = "파도 %d/%d · 휴식 %d초 · 남은 %d / %d" % [
				wi["wave"], wi["waves"], ceili(wi["rest_left"]), wi["remaining"], wi["total"]]
			bar.set_bar(1.0 - wi["rest_left"] / dir.WAVE_REST, COL_REST_BAR)
		else:
			detail_label.text = "파도 %d/%d · 남은 마물 %d / %d" % [wi["wave"], wi["waves"], wi["remaining"], wi["total"]]
			bar.set_bar(float(wi["killed"]) / maxf(1.0, float(wi["total"])), COL_NIGHT_BAR)
	else:
		var pv: Dictionary = dir.night_preview()
		title_label.text = "%d일차 · 낮" % game.day
		if pv["offense"]:
			detail_label.text = "원정 중 · 오늘 밤: 자동 방어 (마물 %d)" % pv["total"]
		else:
			detail_label.text = "오늘 밤: 마물 %d마리%s" % [pv["total"], " (보스전)" if pv["boss"] else (" (엘리트 1)" if pv["elite"] else "")]
		bar.set_bar(1.0 - game.phase_time / game.DAY_LENGTH, COL_DAY_BAR)


## 밤 시작 연출: 가운데 큰 글씨 → 약 2초 뒤 사라진다. 시간·입력은 막지 않는다.
func night_intro() -> void:
	var wi: Dictionary = game.director.wave_info()
	intro.text = "%d일차 밤 — 마물 %d마리" % [game.day, wi["total"]]
	intro_elite.text = "보스전!" if wi["boss"] else ("엘리트 출현!" if wi["elite"] else "")
	if intro_tween and intro_tween.is_valid():
		intro_tween.kill()
	intro.modulate.a = 1.0
	intro_elite.modulate.a = 1.0
	intro_tween = create_tween()
	intro_tween.set_ignore_time_scale(true)
	intro_tween.tween_interval(INTRO_HOLD)
	intro_tween.tween_property(intro, "modulate:a", 0.0, INTRO_FADE)
	intro_tween.parallel().tween_property(intro_elite, "modulate:a", 0.0, INTRO_FADE)


## 균열마다 거기서 나온 살아 있는 마물 수 (밤에만). 맵 좌표에 그리므로 카메라를 따라 움직인다.
class RiftCounts extends Node2D:
	var game

	func _ready() -> void:
		z_index = 3

	func counts() -> Array[int]:
		var out: Array[int] = []
		out.resize(game.rifts.size())
		out.fill(0)
		for mo in game.monsters:
			if is_instance_valid(mo) and mo.has_meta("rift"):
				out[int(mo.get_meta("rift"))] += 1
		return out

	func _process(_delta: float) -> void:
		queue_redraw()

	func _draw() -> void:
		if game == null or not game.is_night:
			return
		var c := counts()
		for i in game.rifts.size():
			if c[i] <= 0:
				continue
			var text := "%d" % c[i]
			var w: float = game.font_m.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, 10).x
			# 위쪽 균열은 상단 HUD에 가리지 않게 아래에 적는다
			var dy := 34.0 if game.rifts[i].y < 60.0 else -25.0
			var p: Vector2 = (game.rifts[i] + Vector2(-w / 2.0, dy)).floor()
			draw_string_outline(game.font_m, p, text, HORIZONTAL_ALIGNMENT_LEFT, -1, 10, 3, game.COL_DARK)
			draw_string(game.font_m, p, text, HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color("e8a0ff"))
