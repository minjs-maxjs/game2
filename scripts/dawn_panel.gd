extends Panel
## 새벽 정산 창: 밤을 넘긴 뒤 시간이 멈춘 동안 띄운다.
## 열려 있는 동안 육성 창·배치·모집·수리·훈련장 강화는 그대로 쓸 수 있다.
## "낮 시작"(또는 Space)을 눌러야 다음 낮이 시작된다.

const POS := Vector2(146, 34)
const SIZE := Vector2(348, 80)

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
	summary_label = _label(Vector2(8, 20), Vector2(SIZE.x - 16, 36))
	summary_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	summary_label.clip_text = false
	hint_label = _label(Vector2(8, 60), Vector2(200, 14))
	hint_label.text = "정비할 시간 — 시간이 멈춰 있다"
	hint_label.modulate = Color(1, 1, 1, 0.7)
	start_button = Button.new()
	start_button.text = "낮 시작 (Space)"
	start_button.focus_mode = Control.FOCUS_NONE
	start_button.pressed.connect(_on_start)
	add_child(start_button)
	start_button.size = start_button.get_combined_minimum_size()
	start_button.position = SIZE - start_button.size - Vector2(7, 6)


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


## 정산 요약: "N일차 방어 성공 — 처치 20, 금화 +XXX, 쓰러진 미니용사 N명, 영주관 -N" + 임금 줄.
## 오펜스 날: "N일차 원정의 날 — 마을 자동 방어: …" + 임금 줄.
static func summary_text(r: Dictionary) -> String:
	var line := "%d일차 방어 성공 — 처치 %d, 금화 +%d, 쓰러진 미니용사 %d명, 영주관 -%d" % [
		int(r.get("day", 0)), int(r.get("kills", 0)), int(r.get("gold", 0)),
		int(r.get("fallen", 0)), int(r.get("hall_loss", 0))]
	if r.get("offense", false):
		line = "%d일차 원정의 날 — %s" % [int(r.get("day", 0)), str(r.get("expedition", {}).get("line", ""))]
	if r.get("wage_paid", true):
		return line + "\n임금 %d 금화 지급." % int(r.get("wage", 0))
	return line + "\n임금 체불! 사기가 떨어졌다."


func _on_start() -> void:
	if director:
		director.continue_day()
