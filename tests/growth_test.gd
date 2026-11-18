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

	# 10) 배치: 클릭 → 16px 칸에 스냅, 막힌 곳·HUD 거부, 같은 쪼꼬미 다시 클릭 → 해제
	var dep = main.deployment
	var km = null
	for o in main.mercs:
		if o.style() == "melee":
			km = o
	main.is_night = false
	main.select(km)
	var spot: Vector2 = main.buildings["hall"]["spot"] + Vector2(53, 5)
	# 고르면 육성 창이 맵 오른쪽을 가린다 → 그 자리는 창이 클릭을 받는다
	check(dep.handle_click(spot, null) and km.post_pos == null, "육성 창이 가린 곳은 배치 거부")
	main.toggle_hud()
	check(dep.handle_click(spot, null) and km.post_pos == main.cell_of(spot), "HUD를 숨기면 그 자리에 배치 (칸 %s)" % [km.post_pos])
	main.toggle_hud()
	var cell = km.post_pos
	check(dep.handle_click(Vector2(100, 10), null) and km.post_pos == cell, "HUD 윗줄(보일 때)은 배치 거부")
	check(dep.handle_click(main.buildings["hall"]["pos"], null) and km.post_pos == cell, "건물(막힌 칸)은 배치 거부")
	check(dep.handle_click(km.position, km) and km.post_pos == null, "같은 쪼꼬미를 다시 누르면 배치 해제")

	# 11) 밤: 배치된 쪼꼬미는 leash 밖으로 쫓아가지 않는다
	km.post_pos = dep._free_cell(spot, {})
	var post: Vector2 = dep.cell_center(km.post_pos)
	km.position = post
	km.hp = km.max_hp
	km.retreating = false
	km.downed = false
	main.is_night = true
	main.monsters.clear()
	var lure = preload("res://scripts/monster.gd").new()
	lure.game = main
	lure.hp = 99999.0
	main.add_child(lure)
	main.monsters.append(lure)
	# 교전 반경 안이지만 leash 밖: leash 끝까지만 나가서 싸운다
	lure.position = post + Vector2(km.leash() + km.attack_range - 4.0, 0)
	var max_out := 0.0
	for i in 360:
		km.attack_cd = 9.0
		km._night(1.0 / 60.0)
		max_out = maxf(max_out, km.position.distance_to(post))
	check(max_out <= km.leash() + 2.0, "배치 시 leash(%d) 밖으로 안 나감 (최대 %.1f)" % [int(km.leash()), max_out])
	check(max_out > km.leash() * 0.5, "leash 안쪽까지는 마물 쪽으로 나간다 (%.1f)" % max_out)
	# 교전 반경 밖의 마물: 자리를 지킨다
	km.position = post
	lure.position = post + Vector2(km.leash() + km.attack_range + 40.0, 0)
	for i in 120:
		km._night(1.0 / 60.0)
	check(km.position.distance_to(post) <= 4.0 and km.activity == "배치", "교전 반경 밖 마물은 무시하고 자리 지킴 (%s)" % km.activity)
	# 배치가 없으면 예전처럼 가장 가까운 마물에게 돌격
	km.post_pos = null
	km.position = post
	for i in 120:
		km._night(1.0 / 60.0)
	check(km.position.distance_to(post) > km.leash() + 8.0 and km.activity == "돌격", "배치 없으면 기존처럼 추격 (%.1f)" % km.position.distance_to(post))
	main.monsters.clear()
	lure.queue_free()
	main.is_night = false

	# 12) 자동 배치: 모두 다른 칸, 전열(근접)이 후열보다 영주관에서 멀다
	dep.auto_deploy()
	var cells := {}
	var all_ok := true
	var hall_spot: Vector2 = main.buildings["hall"]["spot"]
	var front := 0.0
	var back := 9999.0
	for o in main.mercs:
		if o.post_pos == null or cells.has(o.post_pos) or not dep.is_placeable(dep.cell_center(o.post_pos)):
			all_ok = false
			continue
		cells[o.post_pos] = true
		var dd: float = dep.cell_center(o.post_pos).distance_to(hall_spot)
		if dep._row_of(o) == 0:
			front = maxf(front, dd)
		elif dep._row_of(o) == 2:
			back = minf(back, dd)
	check(all_ok and cells.size() == main.mercs.size(), "자동 배치: %d명 모두 서로 다른 빈 칸" % main.mercs.size())
	check(front > back, "자동 배치: 전열이 후열보다 앞 (전열 %.0f · 후열 %.0f)" % [front, back])

	# 13) (c) 우상단: 오른쪽 메뉴 버튼 밑 칸은 HUD가 보이면 거부, 숨기면 배치. 메뉴 아래 빈 곳은 그냥 배치
	main.select(km)
	var tr_cell: Vector2i = dep._free_cell(Vector2(596, 44), {})
	var tr: Vector2 = dep.cell_center(tr_cell)
	km.post_pos = null
	check(dep.ui_blocks(tr) and dep.handle_click(tr, null) and km.post_pos == null, "우상단 메뉴 버튼 위는 거부 (%s)" % tr)
	main.toggle_hud()
	check(dep.handle_click(tr, null) and km.post_pos == tr_cell, "HUD를 숨기면 우상단 %s 배치" % tr_cell)
	main.toggle_hud()
	var free_tr: Vector2 = dep.cell_center(dep._free_cell(Vector2(600, 200), {}))
	check(not dep.ui_blocks(free_tr) and dep.handle_click(free_tr, null) and km.post_pos == main.cell_of(free_tr), "메뉴 아래 빈 곳 %s 은 HUD가 보여도 배치" % free_tr)

	# 14) (b) 밤에도 배치: 지정하면 그 칸으로 길을 찾아 간다. 고르는 동안 시간은 0.2배, 배속은 끝나면 복구
	main.is_night = true
	main.monsters.clear()
	var night_post: Vector2 = dep.cell_center(dep._free_cell(Vector2(120, 190), {}))
	check(dep.handle_click(night_post, null) and km.post_pos == main.cell_of(night_post), "밤에 배치 지정 성공")
	var d0: float = km.position.distance_to(night_post)
	for i in 240:
		km._night(1.0 / 60.0)
	check(km.position.distance_to(night_post) < d0 - 30.0, "밤 배치 칸으로 이동 (%.0f → %.0f)" % [d0, km.position.distance_to(night_post)])
	Engine.time_scale = 1.0
	dep._update_slow()
	check(is_equal_approx(Engine.time_scale, dep.NIGHT_EDIT_SPEED), "밤에 고르는 동안 0.2배속")
	main._on_speed()
	check(is_equal_approx(Engine.time_scale, dep.NIGHT_EDIT_SPEED) and is_equal_approx(dep.base_speed(), 2.0), "느린 동안 배속 버튼은 돌아갈 배속만 바꾼다")
	main.select(null)
	dep._update_slow()
	check(is_equal_approx(Engine.time_scale, 2.0), "선택을 풀면 고른 배속(x2)으로 복구")
	main._on_speed()
	Engine.time_scale = 1.0

	# 15) (a) 성 위기: 영주관 옆 마물 → 멀리 배치된 쪼꼬미가 떠나 접근, 위기가 끝나면 복귀
	km.post_pos = main.cell_of(night_post)
	km.position = night_post
	km.hp = km.max_hp
	km.defending = false
	km.mode_lock = 0.0
	var raider = preload("res://scripts/monster.gd").new()
	raider.game = main
	raider.hp = 99999.0
	main.add_child(raider)
	main.monsters.append(raider)
	raider.position = Vector2(272, 214)   # 영주관 바로 아래
	dep.last_hall_hit = -999.0
	var gap0: float = km.position.distance_to(raider.position)
	check(gap0 > km.leash() + km.attack_range, "시험 조건: 마물이 배치 교전 반경 밖 (%.0f)" % gap0)
	for i in 300:
		dep.update_crisis()
		km._night(1.0 / 60.0)
	check(dep.hall_crisis and km.defending, "영주관 가까이 마물 → 성 위기, 배치 이탈")
	check(km.position.distance_to(raider.position) < gap0 - 40.0 and km.position.distance_to(night_post) > km.leash(),
		"성 쪽으로 접근 (%.0f → %.0f)" % [gap0, km.position.distance_to(raider.position)])
	main.monsters.clear()
	raider.queue_free()
	var flips := 0
	var was: bool = km.defending
	for i in 900:
		dep.update_crisis()
		km._night(1.0 / 60.0)
		if km.defending != was:
			flips += 1
			was = km.defending
	check(not dep.hall_crisis and not km.defending and km.position.distance_to(night_post) <= 4.0,
		"위기가 끝나면 배치 칸으로 복귀 (%.1f)" % km.position.distance_to(night_post))
	check(flips == 1, "위기 해제 뒤 왔다 갔다 없음 (전환 %d번)" % flips)
	main.is_night = false

	print("RESULT %s (%d failures)" % ["PASS" if failures == 0 else "FAIL", failures])
	quit(0 if failures == 0 else 1)
	return true
