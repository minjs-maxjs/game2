extends Control
## 턴 선택 창: 새벽 정산 창 아래에 뜬다. [디펜스] [오펜스] 중 하나를 골라야 다음 낮이 온다 (그동안 시간 정지).
## - 디펜스 = 정산 창 "낮 시작" / Space와 같다 (director.continue_day()).
## - 오펜스 = 생존 미니용사 중 최대 EXPEDITION_PARTY_MAX명을 체크 → "출발" → director.start_offense(party).
## - 보스 날(다음 날이 BOSS_DAY_INTERVAL의 배수)은 디펜스 강제: 오펜스 버튼 비활성 + "보스전" 표시.
## - 원정이 있었던 새벽에는 먼저 "원정 결과(임시)" 창을 띄운다 (확인 → 선택 창).
## 클릭 규칙은 정산 창과 같다: 이 Control 자체는 클릭을 통과시키고 안의 Panel만 받는다.
## hud_root에 붙으므로 Tab(hud_body 숨김)으로는 숨지 않는다.
## TODO: 오펜스 본체(실시간 탐험 맵)로 교체. 지금은 임시 결과만 낸다.

const POS := Vector2(146, 118)
const W := 348.0
const CHOICE_H := 40.0
const RESULT_H := 52.0
const HEAD_H := 18.0
const ROW_H := 14.0
const FOOT_H := 24.0
const COLS := 2

var director
var choice_panel: Panel
var choice_label: Label
var defense_button: Button
var offense_button: Button
var party_panel: Panel
var party_label: Label
var party_box: Control
var go_button: Button
var back_button: Button
var result_panel: Panel
var result_label: Label
var ok_button: Button
var checks: Array[CheckBox] = []
var check_mercs: Array = []


func _ready() -> void:
	position = POS
	size = Vector2(W, CHOICE_H)
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	choice_panel = _panel(CHOICE_H)
	choice_label = _label(choice_panel, Vector2(8, 5), Vector2(W - 150, 30))
	choice_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	choice_label.clip_text = false
	offense_button = _button(choice_panel, "오펜스", _on_offense)
	defense_button = _button(choice_panel, "디펜스 (Space)", _on_defense)
	defense_button.position = Vector2(W - defense_button.size.x - 7, 7)
	offense_button.position = Vector2(defense_button.position.x - offense_button.size.x - 6, 7)

	party_panel = _panel(HEAD_H + FOOT_H)
	party_label = _label(party_panel, Vector2(8, 4), Vector2(W - 16, 12))
	party_box = Control.new()
	party_box.position = Vector2(8, HEAD_H)
	party_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	party_panel.add_child(party_box)
	go_button = _button(party_panel, "출발", _on_go)
	back_button = _button(party_panel, "취소", _on_back)

	result_panel = _panel(RESULT_H)
	var title := _label(result_panel, Vector2(8, 4), Vector2(W - 16, 12))
	title.text = "원정 결과(임시)"
	result_label = _label(result_panel, Vector2(8, 18), Vector2(W - 70, 30))
	result_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	result_label.clip_text = false
	ok_button = _button(result_panel, "확인", _on_ok)
	ok_button.position = Vector2(W, RESULT_H) - ok_button.size - Vector2(7, 6)
	close()


func _panel(h: float) -> Panel:
	var p := Panel.new()
	p.size = Vector2(W, h)
	p.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(p)
	return p


func _label(parent: Control, p: Vector2, s: Vector2) -> Label:
	var l := Label.new()
	l.position = p
	l.size = s
	l.clip_text = true
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(l)
	return l


func _button(parent: Control, text: String, cb: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.focus_mode = Control.FOCUS_NONE
	b.pressed.connect(cb)
	parent.add_child(b)
	b.size = b.get_combined_minimum_size()
	return b


# ------------------------------------------------------------------ 열기/닫기

## 새벽 정산 직후 (director.show_dawn). 원정이 있었으면 결과 창부터.
func open(report: Dictionary) -> void:
	visible = true
	var ex: Dictionary = report.get("expedition", {})
	if not ex.is_empty():
		_show_only(result_panel)
		result_label.text = result_text(ex)
	else:
		show_choice()


func close() -> void:
	visible = false
	_show_only(null)


func _show_only(p: Panel) -> void:
	for x in [choice_panel, party_panel, result_panel]:
		x.visible = x == p


static func result_text(ex: Dictionary) -> String:
	return "%s — 금화 +%d, 마물의 잔재 +%d\n%s" % [
		", ".join(PackedStringArray(ex.get("members", []))), int(ex.get("gold", 0)),
		int(ex.get("residue", 0)), str(ex.get("line", ""))]


## 다음 날(game.day + 1)을 기준으로 선택지를 맞춘다.
func show_choice() -> void:
	visible = true
	_show_only(choice_panel)
	var next_day: int = director.game.day + 1
	var boss: bool = director.is_boss_day(next_day)
	if boss:
		choice_label.text = "%d일차 — 보스전! 디펜스만 가능" % next_day
	else:
		choice_label.text = "%d일차 — 무엇을 할까?  침식 %d/%d" % [next_day, director.erosion, director.EROSION_MAX]
	offense_button.disabled = boss or director.alive_home_mercs().is_empty()


# ------------------------------------------------------------------ 파티 고르기

func show_party() -> void:
	_show_only(party_panel)
	for c in checks:
		c.queue_free()
	checks.clear()
	check_mercs = director.alive_home_mercs()
	for i in check_mercs.size():
		var m = check_mercs[i]
		var c := CheckBox.new()
		c.text = "%s (%s)" % [m.merc_name, m.title()]
		c.focus_mode = Control.FOCUS_NONE
		c.position = Vector2((i % COLS) * (W - 16) / COLS, (i / COLS) * ROW_H)
		c.size = Vector2((W - 16) / COLS, ROW_H)
		c.toggled.connect(_on_check.bind(c))
		party_box.add_child(c)
		checks.append(c)
	var rows := ceili(check_mercs.size() / float(COLS))
	var h := HEAD_H + rows * ROW_H + FOOT_H
	party_panel.size = Vector2(W, h)
	go_button.position = Vector2(W, h) - go_button.size - Vector2(7, 5)
	back_button.position = go_button.position - Vector2(back_button.size.x + 6, 0)
	_refresh_party()


func selected_party() -> Array:
	var out: Array = []
	for i in checks.size():
		if checks[i].button_pressed:
			out.append(check_mercs[i])
	return out


## 상한을 넘는 체크는 되돌리고, 꽉 차면 나머지 칸을 잠근다.
func _on_check(on: bool, c: CheckBox) -> void:
	if on and selected_party().size() > director.EXPEDITION_PARTY_MAX:
		c.set_pressed_no_signal(false)
	_refresh_party()


func _refresh_party() -> void:
	var n := selected_party().size()
	for c in checks:
		c.disabled = not c.button_pressed and n >= director.EXPEDITION_PARTY_MAX
	party_label.text = "원정 파티 (%d/%d) — 하루를 쓰고, 그날 밤 마을은 자동 방어" % [n, director.EXPEDITION_PARTY_MAX]
	go_button.disabled = n == 0


# ------------------------------------------------------------------ 버튼

func _on_defense() -> void:
	director.continue_day()


func _on_offense() -> void:
	if not offense_button.disabled:
		show_party()


func _on_go() -> void:
	director.start_offense(selected_party())


func _on_back() -> void:
	show_choice()


func _on_ok() -> void:
	show_choice()
