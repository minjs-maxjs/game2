extends Node2D
## 쪼꼬미별 배치: 쪼꼬미마다 지킬 칸(post_pos)을 정하고, 밤에는 그 칸에서 leash 안만 싸운다.
## - 낮·밤 언제든 배치할 수 있다. 밤에 쪼꼬미를 고르고 있는 동안은 시간이 NIGHT_EDIT_SPEED로 느려지고,
##   낮(육성 창·배치)과 새벽 정산 중에는 멈춘다 (speed_override).
## - 성 위기(영주관 가까이 마물, 또는 최근 피격)에는 배치를 잠시 떠나 영주관을 지킨다.
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
## 성 위기: 영주관 둘레 CRISIS_TILES칸 안에 마물이 있거나, 최근 CRISIS_HIT_SECS초 안에 영주관이 맞았다.
const CRISIS_TILES := 5
const CRISIS_HIT_SECS := 3.0
## 배치↔성 방어 전환, 성 방어 목표를 바꾼 뒤 최소 유지 시간 (왔다 갔다 방지)
const SWITCH_HOLD := 1.5
## 성 방어 중 "내 교전 반경" = 사거리 + 이만큼
const ENGAGE_PAD := 16.0
## 밤에 배치를 고치는 동안의 시간 배율
const NIGHT_EDIT_SPEED := 0.2
const FLAG := Color("e8c547")
const POLE := Color("5a3a20")

var game
var hall_crisis := false
var last_hall_hit := -999.0
var _saved_speed := -1.0   # 느리게 하기 전 배속 (-1 = 느리게 하는 중 아님)


func _ready() -> void:
	z_index = 1


func _process(_delta: float) -> void:
	update_crisis()
	_update_slow()
	queue_redraw()


func _exit_tree() -> void:
	if _saved_speed >= 0.0:
		Engine.time_scale = _saved_speed


# ------------------------------------------------------------------ 성 위기

func note_hall_hit() -> void:
	last_hall_hit = game.elapsed


func update_crisis() -> void:
	hall_crisis = game.is_night and (game.elapsed - last_hall_hit < CRISIS_HIT_SECS 		or hall_threat(game.hall_rect.get_center()) != null)


## 영주관 테두리에서 p까지의 거리 (안쪽이면 0).
func hall_dist(p: Vector2) -> float:
	var r: Rect2 = game.hall_rect
	return p.distance_to(p.clamp(r.position, r.end))


## 영주관 둘레 CRISIS_TILES칸 안의 마물 중 from에 가장 가까운 것.
func hall_threat(from: Vector2):
	var best = null
	var best_d := INF
	for mo in game.monsters:
		if not is_instance_valid(mo) or hall_dist(mo.position) > CRISIS_TILES * TILE:
			continue
		var d: float = mo.position.distance_to(from)
		if d < best_d:
			best_d = d
			best = mo
	return best


# ------------------------------------------------------------------ 배속 (밤 배치 중 느리게)

## 사용자가 고른 배속. 느리게 하는 중이면 끝난 뒤 돌아갈 값.
func base_speed() -> float:
	return _saved_speed if _saved_speed >= 0.0 else Engine.time_scale


func set_base_speed(v: float) -> void:
	if _saved_speed >= 0.0:
		_saved_speed = v
	else:
		Engine.time_scale = v


func is_slowed() -> bool:
	return _saved_speed >= 0.0


## 지금 덮어쓸 배속 (-1 = 사용자 배속 그대로).
## 새벽 정산·낮의 육성 창/배치 → 0(정지), 밤에 배치용으로 쪼꼬미를 고른 동안 → NIGHT_EDIT_SPEED.
## 따라가기 카메라는 game.selected를 쓰지 않으므로 여기에 걸리지 않는다.
func speed_override() -> float:
	if game.game_over:
		return -1.0
	if game.director != null and game.director.wants_pause():
		return 0.0
	if game.is_night and game.selected != null and is_instance_valid(game.selected):
		return NIGHT_EDIT_SPEED
	return -1.0


func _update_slow() -> void:
	var want := speed_override()
	if want >= 0.0:
		if _saved_speed < 0.0:
			_saved_speed = Engine.time_scale
		Engine.time_scale = want
	elif _saved_speed >= 0.0:
		Engine.time_scale = _saved_speed
		_saved_speed = -1.0


# ------------------------------------------------------------------ 배치


static func leash_px(style: String) -> float:
	return float(LEASH_TILES.get(style, LEASH_DEFAULT) * TILE)


static func cell_center(cell: Vector2i) -> Vector2:
	return Vector2(cell * TILE) + Vector2(TILE, TILE) * 0.5


## 서 있을 수 있는 칸인가: 맵 안이고 막히지 않은 칸.
func is_placeable(p: Vector2) -> bool:
	return Rect2(Vector2.ZERO, game.WORLD_SIZE).has_point(p) and game.is_walkable(p)


## p에 마우스를 받는 HUD 컨트롤이 있는가 (보이는 것 중 mouse_filter가 IGNORE가 아닌 것).
func ui_blocks(p: Vector2) -> bool:
	return game.hud_root != null and _blocks(game.hud_root, p)


func _blocks(c: Control, p: Vector2) -> bool:
	for ch in c.get_children():
		if ch is Control and ch.is_visible_in_tree():
			if ch.mouse_filter != Control.MOUSE_FILTER_IGNORE and ch.get_global_rect().has_point(p):
				return true
			if _blocks(ch, p):
				return true
	return false


## 왼쪽 클릭 처리. 배치로 소비했으면 true (main은 선택을 바꾸지 않는다).
func handle_click(p: Vector2, picked) -> bool:
	var sel = game.selected
	if sel == null or not is_instance_valid(sel):
		return false
	if picked == sel:
		if sel.post_pos == null:
			return false
		sel.post_pos = null
		game.add_log("%s 배치 해제." % sel.merc_name)
		return true
	if picked != null:
		return false   # 다른 쪼꼬미를 누르면 선택만 바뀐다
	if ui_blocks(p) or not is_placeable(p):
		game.add_log("그곳에는 배치할 수 없다.")
		return true
	sel.post_pos = game.cell_of(p)
	game.add_log("%s 배치. %s" % [sel.merc_name, "곧바로 그 자리로 간다." if game.is_night else "밤에 이 자리를 지킨다."])
	return true


## 직업별 열 × 균열 길을 번갈아 고르게 채운다. 쓰러진 쪼꼬미도 자리는 받는다.
func auto_deploy() -> void:
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
