extends Control
## 육성 창의 능력치 5종: "이름  [바]  숫자  +n" 한 줄씩.
## - 바 = 현재 값 / 등급별 능력치 상한 (JobData.stat_cap), 테두리는 등급 색
## - 다음 전직에 조건이 있는 능력치는 바 위에 목표 눈금, 숫자는 미달 빨강 · 충족 초록
## - 같은 쪼꼬미를 보고 있는 동안 값이 오르면 "+n"을 잠깐 띄운다

const StatBar = preload("res://scripts/stat_bar.gd")
const JobData = preload("res://scripts/job_data.gd")

const ROW_H := 10
const NAME_W := 26
const BAR_W := 150
const BAR_H := 4
const NUM_W := 22
const FONT_SIZE := 8
const FLASH_MS := 1500
const STAT_COLORS := {
	"str": Color("e0604a"), "dex": Color("6fcf5a"), "int": Color("5a9cff"),
	"vit": Color("e8a040"), "wis": Color("b07aff"),
}
const COL_TEXT := Color("f4e6c8")
const COL_PRIMARY := Color("ffd84a")
const COL_OK := Color("7fe07f")
const COL_LACK := Color("e07a6a")
const COL_UP := Color("ffd84a")
const COL_DARK := Color("1e140c")

var font: Font
var _bars := {}
var _merc = null
var _last := {}           # 능력치 → 직전에 본 값
var _up := {}             # 능력치 → 최근 오른 양
var _up_until := {}       # 능력치 → "+n"을 지울 시각 (ms, 실제 시간이라 배속과 무관)


func setup(f: Font) -> void:
	font = f
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size = Vector2(NAME_W + BAR_W + NUM_W + 40, ROW_H * JobData.STATS.size())
	size = custom_minimum_size
	for i in JobData.STATS.size():
		var b: StatBar = StatBar.new()
		b.mouse_filter = Control.MOUSE_FILTER_IGNORE
		b.position = Vector2(NAME_W, i * ROW_H + 3)
		b.size = Vector2(BAR_W, BAR_H)
		add_child(b)
		_bars[JobData.STATS[i]] = b


## 매 프레임 불러도 된다. 다른 쪼꼬미로 바뀌면 "+n" 기록을 지운다.
func show_merc(m) -> void:
	if m != _merc:
		_merc = m
		_last.clear()
		_up.clear()
		_up_until.clear()
	if m == null:
		return
	var now := Time.get_ticks_msec()
	var cap := JobData.stat_cap(m.grade)
	var edge: Color = m.grade_info()["color"] if m.grade > 0 else StatBar.COL_EDGE
	var nt: Dictionary = m.next_tier()
	for sid in JobData.STATS:
		var v: float = m.stats[sid]
		if _last.has(sid) and v > float(_last[sid]) + 0.01:
			var fresh: bool = now < int(_up_until.get(sid, 0))
			_up[sid] = (float(_up.get(sid, 0.0)) if fresh else 0.0) + v - float(_last[sid])
			_up_until[sid] = now + FLASH_MS
		_last[sid] = v
		var req := _req_for(nt, sid)
		_bars[sid].set_bar(v / cap, STAT_COLORS[sid], edge, req / cap if req > 0.0 else -1.0)
	queue_redraw()


## 다음 전직에서 이 능력치에 걸린 목표치 (없으면 0).
func _req_for(nt: Dictionary, sid: String) -> float:
	if nt.is_empty() or nt.get("stat", "") != sid:
		return 0.0
	return float(nt.get("stat_req", 0))


func _draw() -> void:
	if _merc == null or not is_instance_valid(_merc) or font == null:
		return
	var now := Time.get_ticks_msec()
	var nt: Dictionary = _merc.next_tier()
	var primary: String = _merc.job()["primary"]
	for i in JobData.STATS.size():
		var sid: String = JobData.STATS[i]
		var base := float(i * ROW_H + 8)
		var name_col := COL_PRIMARY if sid == primary else COL_TEXT
		draw_string(font, Vector2(0, base), JobData.STAT_NAMES[sid], HORIZONTAL_ALIGNMENT_LEFT, -1, FONT_SIZE, name_col)
		var v: float = _merc.stats[sid]
		var req := _req_for(nt, sid)
		var num_col := COL_TEXT
		if req > 0.0:
			num_col = COL_OK if v >= req else COL_LACK
		var num := str(int(v)) if req <= 0.0 else "%d/%d" % [int(v), int(req)]
		draw_string(font, Vector2(NAME_W + BAR_W + 4, base), num, HORIZONTAL_ALIGNMENT_LEFT, -1, FONT_SIZE, num_col)
		if now < int(_up_until.get(sid, 0)):
			draw_string(font, Vector2(NAME_W + BAR_W + 4 + NUM_W + 8, base), "+%.1f" % float(_up[sid]),
				HORIZONTAL_ALIGNMENT_LEFT, -1, FONT_SIZE, COL_UP)


## 테스트용: 지금 "+n"이 떠 있는 능력치와 그 양.
func flashing() -> Dictionary:
	var now := Time.get_ticks_msec()
	var out := {}
	for sid in _up_until:
		if now < int(_up_until[sid]):
			out[sid] = _up[sid]
	return out
