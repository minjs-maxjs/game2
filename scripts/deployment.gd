extends Node2D
## 쪼꼬미별 배치: 낮 동안 쪼꼬미마다 지킬 칸(post_pos)을 정하고, 밤에는 그 칸에서 leash 안만 싸운다.
## - 수동 배치: 쪼꼬미를 고른 뒤 맵을 클릭 → 그 칸(16px 격자)에 배치. 같은 쪼꼬미를 다시 클릭하면 해제.
## - 자동 배치: 균열 → 영주관 길 위에 전열(근접) · 중열(소환) · 후열(원거리·광역·치유)로 고르게 나눈다.
## 마커(깃발 + 점선)는 낮 동안 모두, 밤에는 선택한 쪼꼬미 것만 보인다.

const TILE := 16
## 담당 칸에서 이 칸 수보다 멀리는 쫓아가지 않는다.
const LEASH_TILES := {"melee": 4}
const LEASH_DEFAULT := 6
## 영주관 앞에서 균열 쪽으로 잰 열별 거리(px): 전열 · 중열 · 후열
const ROW_DIST := [112.0, 80.0, 48.0]
const ROW_OF_STYLE := {"melee": 0, "summon": 1}   # 나머지(ranged, aoe, heal)는 후열(2)
const FLAG := Color("e8c547")
const POLE := Color("5a3a20")

var game


func _ready() -> void:
	z_index = 1


func _process(_delta: float) -> void:
	queue_redraw()


static func leash_px(style: String) -> float:
	return float(LEASH_TILES.get(style, LEASH_DEFAULT) * TILE)


static func cell_center(cell: Vector2i) -> Vector2:
	return Vector2(cell * TILE) + Vector2(TILE, TILE) * 0.5


## 서 있을 수 있는 칸인가: HUD 띠·맵 밖·막힌 칸은 안 된다.
func is_placeable(p: Vector2) -> bool:
	return p.y >= 27.0 and p.y <= 294.0 and Rect2(Vector2.ZERO, game.WORLD_SIZE).has_point(p) and game.is_walkable(p)


## 왼쪽 클릭 처리. 배치로 소비했으면 true (main은 선택을 바꾸지 않는다).
func handle_click(p: Vector2, picked) -> bool:
	var sel = game.selected
	if game.is_night or sel == null or not is_instance_valid(sel):
		return false
	if picked == sel:
		if sel.post_pos == null:
			return false
		sel.post_pos = null
		game.add_log("%s 배치 해제." % sel.merc_name)
		return true
	if picked != null:
		return false   # 다른 쪼꼬미를 누르면 선택만 바뀐다
	if not is_placeable(p):
		game.add_log("그곳에는 배치할 수 없다.")
		return true
	sel.post_pos = game.cell_of(p)
	game.add_log("%s 배치. 밤에 이 자리를 지킨다." % sel.merc_name)
	return true


## 직업별 열 × 균열 길을 번갈아 고르게 채운다. 쓰러진 쪼꼬미도 자리는 받는다.
func auto_deploy() -> void:
	if game.is_night:
		game.add_log("밤에는 배치를 바꿀 수 없다.")
		return
	var lanes: Array = []
	for r in game.rifts:
		lanes.append(_lane_points(r))
	var order: Array = game.mercs.duplicate()
	order.sort_custom(func(a, b): return _row_of(a) < _row_of(b))
	var taken := {}
	var per_slot := {}
	for i in order.size():
		var m = order[i]
		var row := _row_of(m)
		var lane := i % lanes.size()
		var key := Vector2i(row, lane)
		var k: int = per_slot.get(key, 0)
		per_slot[key] = k + 1
		var at: Array = lanes[lane][row]   # [위치, 길 방향]
		# 같은 칸에 여럿이면 길과 수직으로 한 칸씩 번갈아 벌린다 (0, +1, -1, +2, ...)
		var side := Vector2(-at[1].y, at[1].x)
		var shift := floorf((k + 1) / 2.0) * (1.0 if k % 2 == 1 else -1.0)
		var cell := _free_cell(at[0] + side * shift * TILE, taken)
		taken[cell] = true
		m.post_pos = cell
	game.add_log("자동 배치: %d명을 전열·중열·후열로 나눴다." % order.size())


func _row_of(m) -> int:
	return ROW_OF_STYLE.get(m.style(), 2)


## 영주관 앞 → 균열 길에서 열별 거리 지점과 그 지점의 길 방향.
func _lane_points(rift: Vector2) -> Array:
	var start: Vector2 = game.buildings["hall"]["spot"]
	var pts: PackedVector2Array = game.find_path(start, rift)
	pts.insert(0, start)
	var out: Array = []
	for want in ROW_DIST:
		var walked := 0.0
		var found := [pts[pts.size() - 1], (rift - start).normalized()]
		for j in range(1, pts.size()):
			var seg: float = pts[j - 1].distance_to(pts[j])
			if walked + seg >= want:
				var t: float = (want - walked) / maxf(seg, 0.001)
				found = [pts[j - 1].lerp(pts[j], t), (pts[j] - pts[j - 1]).normalized()]
				break
			walked += seg
		out.append(found)
	return out


## p에서 가장 가까운, 서 있을 수 있고 비어 있는 칸.
func _free_cell(p: Vector2, taken: Dictionary) -> Vector2i:
	var base: Vector2i = game.cell_of(p)
	for r in 4:
		for dy in range(-r, r + 1):
			for dx in range(-r, r + 1):
				if maxi(absi(dx), absi(dy)) != r:
					continue
				var c := base + Vector2i(dx, dy)
				if not taken.has(c) and is_placeable(cell_center(c)):
					return c
	return base


func _draw() -> void:
	for m in game.mercs:
		if not is_instance_valid(m) or m.post_pos == null:
			continue
		var is_sel: bool = game.selected == m
		if game.is_night and not is_sel:
			continue
		var c := cell_center(m.post_pos)
		# 쪼꼬미 발밑 → 깃발 점선
		var from: Vector2 = m.position
		var dist := from.distance_to(c)
		if dist > 6.0:
			var step := (c - from) / dist
			var s := 0.0
			while s < dist - 3.0:
				draw_rect(Rect2((from + step * s).floor(), Vector2(1, 1)), Color(FLAG, 0.7))
				s += 4.0
		if is_sel:
			draw_arc(c, leash_px(m.style()), 0.0, TAU, 40, Color(FLAG, 0.35), 1.0)
		var base := c.floor() + Vector2(-3, 4)
		draw_rect(Rect2(base + Vector2(0, -12), Vector2(1, 12)), POLE)
		draw_rect(Rect2(base + Vector2(1, -12), Vector2(6, 4)), FLAG if is_sel else Color(FLAG, 0.8))
