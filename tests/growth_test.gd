extends SceneTree
## 육성 시스템 테스트: 등급 분포, 레벨업, 전직, 방출, 소환수.
## 실행: godot --headless --path . --script res://tests/growth_test.gd

const Mercenary = preload("res://scripts/mercenary.gd")
const JobData = preload("res://scripts/job_data.gd")
const CharSprites = preload("res://scripts/char_sprites.gd")

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
	var gender_counts := {"남": 0, "여": 0}
	var look_ok := true
	var name_ok := true
	for i in 3000:
		var m: Mercenary = Mercenary.new()
		m.roll_identity(rng)
		grade_counts[m.grade] += 1
		job_counts[m.job_id] = job_counts.get(m.job_id, 0) + 1
		gender_counts[m.gender] += 1
		if not (m.merc_name in Mercenary.NAMES[m.gender]):
			name_ok = false
		if m.char_id > 0:
			var c: Array = CharSprites.CHARS[m.char_id]
			if c[0] != m.gender or not (m.job_id in c[1]):
				look_ok = false
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
	print("성별 분포: ", gender_counts, "  캐릭터 팩: ", CharSprites.available())
	check(gender_counts["남"] > 1200 and gender_counts["여"] > 1200, "남녀가 고루 태어난다")
	check(name_ok, "이름이 성별 목록에서 나온다")
	check(look_ok, "외형이 성별·직업과 맞는다")
	if CharSprites.available():
		for job in JobData.JOBS:
			for g in ["남", "여"]:
				check(CharSprites.pick(job, g, [], rng) > 0, "%s %s 외형이 있다" % [job, g])

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

	# 5) 소환수가 마물을 잡으면 경험치는 소환사에게 (크래시 없음)
	main._start_night()
	var xp0: float = sm.xp
	var lv0: int = sm.level
	var mo = preload("res://scripts/monster.gd").new()
	mo.game = main
	mo.hp = 1.0
	main.add_child(mo)
	main.monsters.append(mo)
	mo.take_damage(5.0, main.summons[0])
	check(sm.xp > xp0 or sm.level > lv0, "소환수 막타 경험치가 소환사에게")
	main.monsters.clear()
	main._start_day()

	# 6) 전직 버튼 조건 = 실제 전직 조건
	var pm = main.mercs[0]
	pm.gain_xp(2000.0)
	main.residue = 0
	check(not main.can_promote(pm), "잔재가 모자라면 전직 버튼 꺼짐")
	main.residue = 99
	main.gold = 9999.0
	check(main.can_promote(pm), "모두 갖추면 전직 버튼 켜짐")

	# 7) 후퇴: 기준을 막 넘었다고 바로 나가지 않는다
	main.is_night = true
	var rm = main.mercs[0]
	rm.hp = rm.max_hp * 0.05
	rm._night(0.01)
	check(rm.retreating, "체력이 낮으면 후퇴")
	rm.hp = rm.max_hp * 0.5
	rm._night(0.01)
	check(rm.retreating, "절반 회복으로는 여관에 머문다")
	rm.hp = rm.max_hp * 0.75
	rm._night(0.01)
	check(not rm.retreating, "70% 넘게 회복하면 다시 나간다")
	main.is_night = false

	# 8) 식량이 없으면 식당에 가지 않는다
	main.food = 0.0
	var ate_any := false
	for i in 200:
		rm.hunger = 100.0
		rm._choose_action()
		if rm.action == "eat":
			ate_any = true
	check(not ate_any, "식량 0이면 식사를 고르지 않는다")
	main.food = 30.0

	# 9) 모든 균열에서 영주관 공격 범위까지 길이 닿는다
	for r in main.rifts:
		var pts: PackedVector2Array = main.find_path(r, main.hall_rect.get_center())
		var end: Vector2 = pts[pts.size() - 1] if pts.size() > 0 else r
		check(main.hall_rect.grow(10.0 + 6.0 * 0.5).has_point(end), "균열 %s → 영주관 공격 가능 (끝 %s)" % [r, end])

	print("RESULT %s (%d failures)" % ["PASS" if failures == 0 else "FAIL", failures])
	quit(0 if failures == 0 else 1)
	return true
