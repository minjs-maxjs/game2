extends SceneTree
## 헤드리스 스모크 테스트: 메인 씬을 띄우고 며칠을 빠르게 돌려 본다.
## 실행: godot --headless --path . --fixed-fps 60 --script res://tests/smoke_test.gd

const TARGET_DAY := 4
const MAX_FRAMES := 8000

var main
var frames := 0
var saw_night := false
var max_monsters := 0
var kills_seen := 0
var prev_monsters := 0
var blocked_hits := 0
var unit_frames := 0


func _initialize() -> void:
	Engine.time_scale = 10.0
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)


func _process(_delta: float) -> bool:
	frames += 1
	if main.is_night:
		saw_night = true
	# 영주 흉내: 낮에 금화가 남으면 모집, 목재가 남으면 수리
	if not main.is_night and frames % 120 == 0:
		if main.gold >= main.RECRUIT_COST + 40 and main.mercs.size() < main.MAX_MERCS:
			main._on_recruit()
		if main.wood >= 20 and main.hall_hp < main.HALL_MAX_HP - 80:
			main._on_repair()
	# 건물·나무 안에 서 있는 유닛 수 (길찾기 검증)
	for u in main.mercs + main.monsters:
		if is_instance_valid(u):
			unit_frames += 1
			if not main.is_walkable(u.position):
				blocked_hits += 1
	var n: int = main.monsters.size()
	max_monsters = maxi(max_monsters, n)
	if frames % 600 == 0:
		_report()
	if main.day >= TARGET_DAY or main.game_over or frames >= MAX_FRAMES:
		_report()
		var blocked_ratio := float(blocked_hits) / maxf(1.0, float(unit_frames))
		print("blocked unit-frames: %d / %d (%.2f%%)" % [blocked_hits, unit_frames, blocked_ratio * 100.0])
		var ok: bool = main.mercs.size() >= 4 and saw_night and max_monsters > 0 and main.day >= 2 and blocked_ratio < 0.01 \
			and not main.is_walkable(main.buildings["hall"]["pos"]) and not main.is_walkable(main.buildings["inn"]["pos"])
		print("RESULT %s  day=%d game_over=%s max_monsters=%d frames=%d" % [
			"PASS" if ok else "FAIL", main.day, main.game_over, max_monsters, frames])
		quit(0 if ok else 1)
		return true
	return false


func _report() -> void:
	var lv := []
	for m in main.mercs:
		lv.append("%s/%s/Lv%d" % [m.merc_name, m.activity, m.level])
	print("f%d day%d %s hall=%d gold=%d food=%d wood=%d residue=%d monsters=%d | %s" % [
		frames, main.day, "밤" if main.is_night else "낮", int(main.hall_hp), int(main.gold),
		int(main.food), int(main.wood), main.residue, main.monsters.size(), ", ".join(PackedStringArray(lv))])
