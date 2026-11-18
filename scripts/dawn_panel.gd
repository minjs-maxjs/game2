extends Panel
## 새벽 정산 창: 밤을 넘긴 뒤 시간이 멈춘 동안 띄운다.
## 열려 있는 동안 육성 창·배치·모집·수리·훈련장 강화는 그대로 쓸 수 있다.
## "낮 시작"(또는 Space)을 눌러야 다음 낮이 시작된다.

const POS := Vector2(180, 34)
const SIZE := Vector2(280, 74)

var director
var title_label: Label
var summary_label: Label
var hint_label: Label
var start_button: Button


func _ready() -> void:
	position = POS
	size = SIZE
	mouse_filter = Control.MOUSE_FILTER_STOP
	title_label = _label(Vector2(8, 5), Vector2(SIZE.x - 16, 14))
	title_label.add_theme_font_size_override("font_size", 11)
	summary_label = _label(Vector2(8, 21), Vector2(SIZE.x - 16, 26))
	summary_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	summary_label.clip_text = false
	hint_label = _label(Vector2(8, 52), Vector2(170, 14))
	hint_label.text = "정비할 시간 — 시간이 멈춰 있다"
	hint_label.modulate = Color(1, 1, 1, 0.7)
	start_button = Button.new()
	start_button.text = "낮 시작 (Space)"
	start_button.focus_mode = Control.FOCUS_NONE
	start_button.position = Vector2(SIZE.x - 96, 48)
	start_button.size = Vector2(88, 20)
	start_button.pressed.connect(_on_start)
	add_child(start_button)


func _label(p: Vector2, s: Vector2) -> Label:
	var l := Label.new()
	l.position = p
	l.size = s
	l.clip_text = true
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(l)
	return l


func show_report(r: Dictionary) -> void:
	title_label.text = "%d일차 새벽 — 정산" % int(r.get("day", 0))
	summary_label.text = summary_text(r)
	visible = true


## 정산 한 줄. B 단계에서 처치·금화·쓰러짐·내구도 요약으로 채운다.
func summary_text(r: Dictionary) -> String:
	if r.get("wage_paid", true):
		return "임금 %d 금화 지급." % int(r.get("wage", 0))
	return "임금 체불! 사기가 떨어졌다."


func _on_start() -> void:
	if director:
		director.continue_day()
