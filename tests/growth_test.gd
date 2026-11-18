extends SceneTree
## 육성 시스템 테스트: 등급 분포, 레벨업, 전직, 방출, 소환수.
## 실행: godot --headless --path . --script res://tests/growth_test.gd

const Mercenary = preload("res://scripts/mercenary.gd")
const JobData = preload("res://scripts/job_data.gd")

var failures := 0
var main
var frames := 0


func check(cond: bool, label: String) -> void:
	print("%s  %s" % ["PASS" if cond else "FAIL", label])
	if not cond:
		failures += 1


func _initialize() -> void:
	# 1) 등급 분포: 3000번 탄생
	var rng := RandomNumberGenerator.new()
	rng.seed = 42
	var grade_counts := [0, 0, 0, 0]
	var job_counts := {}
	for i in 3000:
		var m: Mercenary = Mercenary.new()
		m.roll_identity(rng)
		grade_counts[m.grade] += 1
		job_counts[m.job_id] = job_counts.get(m.job_id, 0) + 1
		m.free()
	var pct := []
	for i in grade_counts.size():
		pct.append("%s %.1f%%" % [JobData.GRADES[i]["name"], grade_counts[i] / 30.0])
	print("등급 분포: ", ", ".join(PackedStringArray(pct)))
	print("직업 분포: ", job_counts)
	check(grade_counts[0] > grade_counts[1] and grade_counts[1] > grade_counts[2] and grade_counts[2] > grade_counts[3],
		"등급이 높을수록 드물다")
	check(grade_counts[3] > 0 and grade_counts[3] < 150, "레전더리는 0~5% 사이")
	check(job_counts.size() == JobData.JOBS.size(), "모든 직업이 태어난다")

	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)


func _process(_delta: float) -> bool:
	frames += 1
	if frames < 3:
		return false
	# 2) 레벨업 → 전직
	var m = main.mercs[0]
	var atk0: float = m.atk
	var total0: float = m.stat_total()
	m.gain_xp(200.0)
	check(m.level >= 5, "경험치 200으로 Lv.5 이상 (현재 Lv.%d)" % m.level)
	check(m.stat_total() > total0, "레벨업으로 능력치 상승 (%d → %d)" % [int(total0), int(m.stat_total())])
	main.residue = 0
	check(not main.try_promote(m), "잔재가 없으면 전직 불가")
	main.residue = 20
	main.gold = 500.0
	var atk_before: float = m.atk
	check(main.try_promote(m), "조건을 채우면 전직")
	check(m.tier == 1 and m.atk > atk_before, "전직 후 단계 1, 공격력 상승 (%s, %d → %d)" % [m.title(), int(atk_before), int(m.atk)])
	check(not main.try_promote(m), "다음 단계 레벨(10) 미달이면 전직 불가")
	check(main.residue == 20 - JobData.PROMOTE_RESIDUE[1], "전직 비용 차감")

	# 3) 방출
	var n: int = main.mercs.size()
	var victim = main.mercs[1]
	main.select(victim)
	main.dismiss_merc(victim)
	check(main.mercs.size() == n - 1 and main.selected == null, "방출하면 목록에서 빠지고 선택 해제")
	for o in main.mercs:
		check(o.friend != victim, "%s의 친구 참조 정리" % o.merc_name)

	# 4) 소환사
	main.gold = 500.0
	main._spawn_merc("summoner")
	var sm = main.mercs[main.mercs.size() - 1]
	main._start_night()
	check(main.summons.size() == 1 and sm.summons.size() == 1, "소환사가 밤에 소환수 1마리")
	main.monsters.clear()
	main._start_day()
	check(main.summons.is_empty() and sm.summons.is_empty(), "새벽에 소환수 사라짐")

	print("RESULT %s (%d failures)" % ["PASS" if failures == 0 else "FAIL", failures])
	quit(0 if failures == 0 else 1)
	return true
