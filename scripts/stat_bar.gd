extends Control
## 작은 픽셀 막대 하나. 육성 창 능력치 줄(stat_panel.gd)과 쪼꼬미 머리 위 HP 바(mercenary.gd)가 같이 쓴다.
## Control로 놓아 쓰거나, 다른 CanvasItem의 _draw에서 StatBar.draw_bar(self, ...)로 그린다.

const COL_BACK := Color("2a1d14")
const COL_EDGE := Color("1e140c")
const COL_TICK := Color("fff4d0")

var ratio := 0.0             # 0~1
var fill := Color.WHITE
var edge := COL_EDGE         # 테두리 (등급 색을 넣어도 된다)
var tick := -1.0             # 목표치 눈금 위치 0~1 (음수면 없음)


func set_bar(r: float, f: Color, e: Color = COL_EDGE, t: float = -1.0) -> void:
	if r == ratio and f == fill and e == edge and t == tick:
		return
	ratio = r
	fill = f
	edge = e
	tick = t
	queue_redraw()


func _draw() -> void:
	draw_bar(self, Rect2(Vector2.ZERO, size), ratio, fill, edge, tick)


## r 안쪽에 막대를 그린다. 테두리는 r 바깥 1px, 눈금은 위아래로 1px 튀어나온다.
static func draw_bar(ci: CanvasItem, r: Rect2, value_ratio: float, fill_col: Color,
		edge_col: Color = COL_EDGE, tick_ratio: float = -1.0) -> void:
	ci.draw_rect(r.grow(1.0), edge_col)
	ci.draw_rect(r, COL_BACK)
	var w := floorf(r.size.x * clampf(value_ratio, 0.0, 1.0))
	if w > 0.0:
		ci.draw_rect(Rect2(r.position, Vector2(w, r.size.y)), fill_col)
	if tick_ratio >= 0.0:
		var x := r.position.x + floorf((r.size.x - 1.0) * clampf(tick_ratio, 0.0, 1.0))
		ci.draw_rect(Rect2(x, r.position.y - 2.0, 1.0, r.size.y + 4.0), COL_TICK)


## 체력 비율에 따라 빨강 → 노랑 → 초록.
static func hp_color(r: float) -> Color:
	var red := Color("e05a4a")
	var yellow := Color("e8c547")
	var green := Color("5ad05a")
	if r < 0.5:
		return red.lerp(yellow, clampf(r / 0.5, 0.0, 1.0))
	return yellow.lerp(green, clampf((r - 0.5) / 0.5, 0.0, 1.0))
