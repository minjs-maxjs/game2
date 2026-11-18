extends Camera2D
## 쪼꼬미 따라가기 카메라.
## - 쪼꼬미를 고른 상태에서 육성 창 "따라가기" 또는 F: 정수 배율(2배, 휠로 3배)로 확대해 부드럽게 따라간다.
##   따라가기를 시작하면 선택(육성 창)은 닫는다 → 낮 정지·밤 0.2배속(배치용 선택 규칙)에 걸리지 않는다.
## - 해제: 같은 버튼/F, Esc, 빈 곳 우클릭. Q/E: 이전/다음 쪼꼬미.
## - 대상이 쓰러지거나 후퇴해도 해제하지 않는다 (방출되어 사라질 때만 해제).
## - 맵 밖이 보이지 않게 중심을 맵 안으로 묶는다. 꺼져 있을 때는 배율 1·맵 중앙 = 화면 변환 없음.
## - HUD(CanvasLayer)는 확대의 영향을 받지 않는다. 대상 정보 패널, 성 위기 화살표, 말풍선도 HUD에 그린다.

const StatBar = preload("res://scripts/stat_bar.gd")

const ZOOM_LEVELS := [2, 3]          # 정수 배율만 (픽셀 번짐 방지)
const FOLLOW_SMOOTH := 8.0           # 클수록 빨리 붙는다 (실제 시간 기준, 시간 정지 중에도 동작)
const HEAD_OFFSET := Vector2(0, -8)
## 영주관 내구도가 이 비율 이하로 떨어지면 따라가기를 강제로 끝낸다 (끄려면 false)
const FORCE_EXIT_ON_LOW_HALL := true
const HALL_EXIT_RATIO := 0.25
## 성 위기 화살표가 다닐 수 있는 화면 영역 (상단 줄·배너·우상단 메뉴·하단 로그를 피한다)
const ARROW_AREA := Rect2(18, 64, 520, 212)
const BUBBLE_SECS := 1.6
## 따라가는 대상의 상태(activity)가 바뀔 때 머리 위 말풍선
const BUBBLES := {
	"배고픔": "배고프다", "식사": "배고프다", "휴식": "좀 쉬자", "훈련": "더 강해질 테야",
	"후퇴": "후퇴! 후퇴!", "쓰러짐": "으윽...", "친구 구출": "친구가 걱정돼",
	"돌격": "간다!", "전투": "덤벼라!", "성 방어": "영주관을 지켜라!", "치유": "조금만 버텨!",
}
const KILL_BUBBLE := "해치웠다!"
const FIGHT_STATES := ["전투", "돌격", "성 방어", "대기"]
const COL_CRISIS := Color("ff5a4a")

var game
var target = null
var zoom_level := 1                  # 1 = 따라가기 꺼짐
var focus := Vector2.ZERO
var bubble_text := ""
var bubble_left := 0.0
var _last_activity := ""
var _last_kills := 0
var _last_us := 0
var overlay: Control                 # 성 위기 화살표 · 말풍선 (Tab에도 남는다)
var info_panel: Panel                # 대상 이름·직업·HP·상태 (Tab으로 숨는다)
var info_label: Label
var info_hp: StatBar


func setup(g) -> void:
	game = g
	limit_left = 0
	limit_top = 0
	limit_right = int(g.WORLD_SIZE.x)
	limit_bottom = int(g.WORLD_SIZE.y)
	position = g.WORLD_SIZE / 2.0
	focus = position
	enabled = true
	make_current()
	_last_us = Time.get_ticks_usec()

	overlay = Overlay.new()
	overlay.cam = self
	overlay.size = g.WORLD_SIZE
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	g.hud_root.add_child(overlay)

	info_panel = Panel.new()
	info_panel.position = Vector2(4, 232)
	info_panel.size = Vector2(170, 58)
	info_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	info_panel.visible = false
	g.hud_body.add_child(info_panel)
	info_label = Label.new()
	info_label.position = Vector2(7, 4)
	info_label.size = Vector2(156, 50)
	info_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	info_panel.add_child(info_label)
	info_hp = StatBar.new()
	info_hp.position = Vector2(30, 21)
	info_hp.size = Vector2(70, 4)
	info_hp.mouse_filter = Control.MOUSE_FILTER_IGNORE
	info_panel.add_child(info_hp)


# ------------------------------------------------------------------ 켜고 끄기

func is_following() -> bool:
	return target != null and is_instance_valid(target)


func start(m) -> void:
	if m == null or not is_instance_valid(m):
		return
	if not is_following():
		focus = get_screen_center_position()
	target = m
	if zoom_level < ZOOM_LEVELS[0]:
		set_zoom_level(ZOOM_LEVELS[0])
	_last_activity = m.activity
	_last_kills = game.director.kills
	bubble_left = 0.0
	info_panel.visible = true


func stop() -> void:
	target = null
	zoom_level = 1
	zoom = Vector2.ONE
	position = game.WORLD_SIZE / 2.0
	focus = position
	bubble_left = 0.0
	info_panel.visible = false
	force_update_scroll()


## 따라가기 버튼 / F: 고른 쪼꼬미를 따라가거나(선택은 닫는다), 이미 따라가는 중이면 끈다.
func toggle_from_selection() -> void:
	var sel = game.selected
	if sel != null and is_instance_valid(sel) and sel != target:
		start(sel)
		game.select(null)
	elif is_following():
		stop()


## Q/E: 이전/다음 쪼꼬미로 바꾼다 (쓰러진 쪼꼬미도 포함).
func cycle(step: int) -> void:
	if not is_following() or game.mercs.is_empty():
		return
	var i: int = game.mercs.find(target)
	start(game.mercs[posmod(i + step, game.mercs.size())])


## 배율은 ZOOM_LEVELS 안의 정수로만 바뀐다.
func set_zoom_level(z: float) -> void:
	var zi := clampi(roundi(z), int(ZOOM_LEVELS[0]), int(ZOOM_LEVELS[ZOOM_LEVELS.size() - 1]))
	zoom_level = zi
	zoom = Vector2(zi, zi)


# ------------------------------------------------------------------ 입력

func _unhandled_input(event: InputEvent) -> void:
	var key := event as InputEventKey
	if key and key.pressed and not key.echo:
		match key.keycode:
			KEY_F:
				toggle_from_selection()
				get_viewport().set_input_as_handled()
			KEY_ESCAPE:
				if is_following():
					stop()
					get_viewport().set_input_as_handled()
			KEY_Q, KEY_E:
				if is_following():
					cycle(-1 if key.keycode == KEY_Q else 1)
					get_viewport().set_input_as_handled()
		return
	var mb := event as InputEventMouseButton
	if mb == null or not mb.pressed or not is_following():
		return
	if mb.button_index == MOUSE_BUTTON_WHEEL_UP:
		set_zoom_level(zoom_level + 1)
		get_viewport().set_input_as_handled()
	elif mb.button_index == MOUSE_BUTTON_WHEEL_DOWN:
		set_zoom_level(zoom_level - 1)
		get_viewport().set_input_as_handled()
	elif mb.button_index == MOUSE_BUTTON_RIGHT and game.merc_at(game.screen_to_world(mb.position)) == null:
		stop()   # 빈 곳 우클릭: 해제 (main은 선택 해제를 이어서 처리한다)


# ------------------------------------------------------------------ 매 프레임

func _process(_delta: float) -> void:
	var now := Time.get_ticks_usec()
	var dt := clampf(float(now - _last_us) / 1000000.0, 0.0, 0.1)   # 배속·정지와 무관한 실제 시간
	_last_us = now
	if target != null and not is_instance_valid(target):
		stop()
	if not is_following():
		return
	if FORCE_EXIT_ON_LOW_HALL and game.hall_hp <= game.HALL_MAX_HP * HALL_EXIT_RATIO:
		game.add_log("영주관이 위험하다! 따라가기를 멈춘다.")
		stop()
		return
	focus = focus.lerp(target.position + HEAD_OFFSET, 1.0 - exp(-FOLLOW_SMOOTH * dt))
	position = clamp_center(focus)
	_update_bubble(dt)
	_update_info()


## 지금 배율에서 화면이 맵 밖을 보이지 않도록 중심을 묶는다. 정수 픽셀로 맞춘다.
func clamp_center(p: Vector2) -> Vector2:
	var half: Vector2 = game.WORLD_SIZE / (2.0 * zoom.x)
	return p.clamp(half, game.WORLD_SIZE - half).round()


## 테스트·스크린샷용: 보간 없이 대상에 바로 붙고 화면 변환을 즉시 반영한다.
func snap() -> void:
	if is_following():
		focus = target.position + HEAD_OFFSET
		position = clamp_center(focus)
	force_update_scroll()


## 지금 화면에 보이는 맵 영역.
func view_rect() -> Rect2:
	var sz: Vector2 = game.WORLD_SIZE / zoom.x
	return Rect2(get_screen_center_position() - sz / 2.0, sz)


func _update_bubble(dt: float) -> void:
	bubble_left = maxf(0.0, bubble_left - dt)
	var act: String = target.activity
	if act != _last_activity:
		_last_activity = act
		if BUBBLES.has(act):
			say(BUBBLES[act])
	var k: int = game.director.kills
	if k > _last_kills:
		if act in FIGHT_STATES:
			say(KILL_BUBBLE)
		_last_kills = k


func say(text: String) -> void:
	bubble_text = text
	bubble_left = BUBBLE_SECS


func _update_info() -> void:
	var t = target
	info_label.text = "%s · %s Lv%d\nHP\n상태: %s   x%d · Q/E 전환 · F 해제" % [
		t.merc_name, t.title(), t.level, t.activity, zoom_level]
	info_hp.set_bar(t.hp / maxf(1.0, t.max_hp), StatBar.hp_color(t.hp / maxf(1.0, t.max_hp)))


## 영주관이 화면 밖인데 성 위기면 true (화살표를 그린다).
func hall_alert() -> bool:
	return is_following() and game.deployment.hall_crisis and not view_rect().intersects(game.hall_rect)


## HUD 층 그림: 성 위기 화살표 + 말풍선.
class Overlay extends Control:
	var cam

	func _process(_delta: float) -> void:
		queue_redraw()

	func _draw() -> void:
		if cam == null or not cam.is_following():
			return
		var g = cam.game
		if cam.bubble_left > 0.0:
			var head: Vector2 = g.world_to_screen(cam.target.position + Vector2(0, -24))
			var w: float = g.font_m.get_string_size(cam.bubble_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 10).x
			var box := Rect2((head - Vector2(w / 2.0 + 4.0, 13.0)).floor(), Vector2(w + 8.0, 14.0))
			draw_rect(box.grow(1.0), g.COL_DARK)
			draw_rect(box, Color("f4e6c8"))
			draw_rect(Rect2(Vector2(floorf(head.x) - 1.0, box.end.y), Vector2(3, 2)), Color("f4e6c8"))
			draw_string(g.font_m, box.position + Vector2(4, 11), cam.bubble_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 10, g.COL_DARK)
		if cam.hall_alert():
			_draw_hall_arrow(g)

	func _draw_hall_arrow(g) -> void:
		var inner: Rect2 = cam.ARROW_AREA
		var center: Vector2 = inner.get_center()
		var hall: Vector2 = g.world_to_screen(g.hall_rect.get_center())
		var d := (hall - center).normalized()
		# 화면 중앙→영주관 방향 직선이 안쪽 사각형 테두리와 만나는 점
		var tx: float = INF if is_zero_approx(d.x) else ((inner.end.x if d.x > 0 else inner.position.x) - center.x) / d.x
		var ty: float = INF if is_zero_approx(d.y) else ((inner.end.y if d.y > 0 else inner.position.y) - center.y) / d.y
		var tip: Vector2 = (center + d * minf(tx, ty)).floor()
		var blink := 0.55 + 0.45 * absf(sin(Time.get_ticks_msec() / 160.0))
		var col := Color(cam.COL_CRISIS, blink)
		var side := Vector2(-d.y, d.x)
		draw_colored_polygon(PackedVector2Array([tip + d * 8.0, tip - d * 4.0 + side * 7.0, tip - d * 4.0 - side * 7.0]), col)
		var text := "영주관 위기!"
		var w: float = g.font_m.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, 10).x
		var tp := (tip - d * 16.0 - Vector2(w / 2.0, -4.0)).floor()
		tp.x = clampf(tp.x, inner.position.x, inner.end.x - w)
		tp.y = clampf(tp.y, inner.position.y + 10.0, inner.end.y)
		draw_string_outline(g.font_m, tp, text, HORIZONTAL_ALIGNMENT_LEFT, -1, 10, 3, g.COL_DARK)
		draw_string(g.font_m, tp, text, HORIZONTAL_ALIGNMENT_LEFT, -1, 10, col)
