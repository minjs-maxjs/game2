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
	var nt2: Dictionary = m.next_tier()   # 주 능력치 조건(16번에서 따로 검증)은 채워 둔다 — 무작위 능력치에 따라 흔들리지 않게
	if nt2.has("stat_req"):
		m.stats[nt2["stat"]] = maxf(float(m.stats[nt2["stat"]]), float(nt2["stat_req"]))
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
	main._start_dawn()
	main.director.continue_day()
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
	main._start_dawn()
	main.director.continue_day()

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

	# 16) 능력치 바 · 전직 능력치 조건 · "+n" 표시
	var qm = main.mercs[0]
	main.select(qm)
	var snt: Dictionary = qm.next_tier()
	check(not snt.is_empty() and snt.has("stat_req"), "다음 전직에 능력치 조건이 있다")
	if not snt.is_empty():
		var sid: String = snt["stat"]
		qm.level = max(qm.level, int(snt["level"]))
		main.residue = 999
		main.gold = 9999.0
		var keep: float = qm.stats[sid]
		qm.stats[sid] = float(snt["stat_req"]) - 1.0
		check(not main.can_promote(qm), "주 능력치가 모자라면 전직 버튼 꺼짐")
		qm.stats[sid] = float(snt["stat_req"])
		check(main.can_promote(qm), "주 능력치를 채우면 전직 버튼 켜짐")
		qm.stats[sid] = keep
		var bar = main.stat_panel._bars[sid]
		main._update_growth_panel()
		check(bar.tick > 0.0 and bar.tick <= 1.0, "목표 눈금이 바 안에 있다 (%.2f)" % bar.tick)
		var lvl0: int = qm.level
		qm.gain_xp(qm.xp_needed() - qm.xp + 1.0)
		main._update_growth_panel()
		check(qm.level > lvl0 and not main.stat_panel.flashing().is_empty(), "레벨업 직후 \"+n\" 표시 (%s)" % str(main.stat_panel.flashing()))
	main.select(null)

	# 17) 휴식 구간: 새벽 정지 · 낮 결정 창 정지 · 파도 분할 · 파도 사이 휴식
	var WD = preload("res://scripts/wave_director.gd")
	var dir = main.director
	check(WD.AUTO_CONTINUE_DAWN == false and dir.auto_continue == false, "기본은 새벽 정산 창에서 기다린다")
	main.select(null)
	main.monsters.clear()
	main.is_night = true
	main._start_night()
	main.monsters.clear()
	var day0: int = main.day
	main._start_dawn()
	check(dir.is_dawn and not main.is_night and dir.panel.visible, "새벽 정산 창이 뜬다")
	Engine.time_scale = 1.0
	dep._update_slow()
	check(is_equal_approx(Engine.time_scale, 0.0), "새벽 정산 중 시간 정지 (x%.1f)" % Engine.time_scale)
	var pt0: float = main.phase_time
	main._process(5.0)
	check(is_equal_approx(main.phase_time, pt0) and not main.is_night and main.day == day0, "새벽 중에는 낮 타이머가 흐르지 않는다")
	dir.panel.start_button.pressed.emit()
	check(not dir.is_dawn and not dir.panel.visible and main.day == day0 + 1, "낮 시작 버튼 → %d일째 낮" % main.day)
	dep._update_slow()
	check(is_equal_approx(Engine.time_scale, 1.0), "낮 시작 후 배속 복구 (x%.1f)" % Engine.time_scale)
	main._process(1.0)
	check(main.phase_time > 0.5, "낮 타이머 재개")
	# 낮 결정 창(육성 창·배치): 여는 동안 정지, 닫으면 고른 배속(x2)으로
	main._on_speed()
	main.select(main.mercs[0])
	dep._update_slow()
	check(is_equal_approx(Engine.time_scale, 0.0) and is_equal_approx(dep.base_speed(), 2.0), "낮에 육성 창 열면 정지 (돌아갈 배속 x2 유지)")
	main.select(null)
	dep._update_slow()
	check(is_equal_approx(Engine.time_scale, 2.0), "육성 창 닫으면 x2 복구")
	main._on_speed()
	Engine.time_scale = 1.0
	# 파도 분할: 합계 = 그날 밤 총수, 2/3파도 규칙, 배율 1.0인 날은 기존 식(3+날짜×2)과 같음
	var split_ok := true
	for d in range(1, 16):
		var ws: Array = WD.wave_sizes(d)
		var sum := 0
		for w in ws:
			sum += w
		var tot: int = WD.night_total_for(d)
		if sum != tot or ws.size() != (2 if tot < 6 else 3) or ws.min() < 1:
			split_ok = false
		if is_equal_approx(WD.NIGHT_MULT[d % 3], 1.0) and sum != 3 + d * 2:
			split_ok = false
	check(split_ok, "파도 분할 합계 = 밤 총수 (1~15일, 예: 3일 %s)" % str(WD.wave_sizes(3)))
	check(WD.night_total_for(4) == roundi((3 + 4 * 2) * 0.8), "쉬운 밤은 x0.8 (4일 %d마리)" % WD.night_total_for(4))
	# 파도 사이 휴식: 마물이 나오지 않고, 쪼꼬미는 회복하며, 후퇴 중이면 기준을 넘으면 복귀
	main.day = 3
	main._start_night()
	main.monsters.clear()
	var elite_seen := false
	var spawned := 0
	var wm = main.mercs[0]
	for wave in dir.waves.size():
		for i in 600:
			var before: int = main.monsters.size()
			dir.update_night(1.0 / 60.0)
			if main.monsters.size() > before:
				spawned += 1
				if main.monsters.back().elite:
					elite_seen = dir.is_last_wave() and dir.to_spawn == 0
			if dir.to_spawn == 0:
				break
		for wmo in main.monsters:
			wmo.queue_free()
		main.monsters.clear()
		if wave == dir.waves.size() - 1:
			break
		dir.update_night(1.0 / 60.0)
		check(dir.resting, "%d파도 뒤 휴식 시작" % (wave + 1))
		wm.downed = false
		wm.hp = wm.max_hp * 0.2
		wm.retreating = true
		var hp0: float = wm.hp
		var leak := 0
		for i in int((WD.WAVE_REST - 0.5) * 60.0):
			dir.update_night(1.0 / 60.0)
			leak += main.monsters.size()
		check(leak == 0 and dir.resting, "휴식 %.0f초 동안 마물 없음" % WD.WAVE_REST)
		check(wm.hp > hp0 + wm.max_hp * 0.2, "휴식 중 체력 회복 (%.0f → %.0f)" % [hp0, wm.hp])
		wm.hp = wm.max_hp * 0.75
		wm._night(1.0 / 60.0)
		check(not wm.retreating, "후퇴 중 쪼꼬미가 기준을 넘으면 복귀")
		for i in 60:
			dir.update_night(1.0 / 60.0)
		check(not dir.resting and dir.wave_idx == wave + 1, "휴식이 끝나면 %d파도" % (wave + 2))
	check(spawned == dir.night_total and elite_seen, "모든 파도 합계 %d마리 소환, 엘리트는 마지막 파도 끝" % spawned)
	var wi: Dictionary = dir.wave_info()
	check(wi["remaining"] == 0 and wi["wave"] == wi["waves"], "wave_info: 마지막 파도 · 남은 0")
	dir.update_night(1.0 / 60.0)
	check(dir.is_dawn, "마지막 파도를 막으면 새벽")
	dir.continue_day()
	main.is_night = false

	# 18) 일차·웨이브 HUD: 배너 글자, 클릭 통과, 밤 시작 연출, 새벽 요약
	var wh = main.wave_hud
	main.day = 3
	main.phase_time = 0.0
	wh.refresh()
	var pv: Dictionary = dir.night_preview()
	check(wh.banner.visible and wh.title_label.text == "3일차 · 낮" and wh.detail_label.text == "오늘 밤: 마물 %d마리 (엘리트 1)" % pv["total"],
		"낮 배너: %s / %s" % [wh.title_label.text, wh.detail_label.text])
	check(is_equal_approx(wh.bar.ratio, 1.0), "낮 남은 시간 바 가득")
	main.day = 4
	wh.refresh()
	check(not wh.detail_label.text.contains("엘리트"), "엘리트 없는 날은 괄호 생략 (%s)" % wh.detail_label.text)
	main.day = 3
	var bc: Vector2 = wh.banner.get_global_rect().get_center()
	check(not dep.ui_blocks(bc) and not dep.ui_blocks(wh.banner.get_global_rect().position + Vector2(2, 2)), "배너는 배치 클릭을 막지 않는다")
	check(not wh.banner.get_global_rect().intersects(Rect2(556, 0, 84, 360)), "배너가 우상단 메뉴 자리를 비운다")
	main._start_night()
	main.monsters.clear()
	wh.refresh()
	check(main.is_night and wh.title_label.text == "3일차 · 밤" and wh.detail_label.text.begins_with("파도 1/3"),
		"밤 배너: %s / %s" % [wh.title_label.text, wh.detail_label.text])
	check(wh.intro.modulate.a > 0.9 and wh.intro.text == "3일차 밤 — 마물 %d마리" % dir.night_total and wh.intro_elite.text == "엘리트 출현!",
		"밤 시작 연출: %s %s" % [wh.intro.text, wh.intro_elite.text])
	check(wh.intro.mouse_filter == Control.MOUSE_FILTER_IGNORE and not dep.ui_blocks(Vector2(320, 98)), "밤 시작 연출은 입력을 막지 않는다")
	main._start_dawn()
	wh.refresh()
	var sum_text: String = dir.panel.summary_label.text
	check(not wh.banner.visible and sum_text.begins_with("3일차 방어 성공 — 처치 ") and sum_text.contains("쓰러진 쪼꼬미") and sum_text.contains("영주관 -"),
		"새벽 요약: %s" % sum_text.replace("
", " / "))
	dir.continue_day()
	main.is_night = false

	# 19) 따라가기 카메라: 클릭 좌표 변환 · 쓰러져도 유지 · 정수 배율 · 배속 무관
	var cam = main.follow_cam
	main.is_night = false
	main.select(null)
	check(not cam.is_following() and main.world_to_screen(Vector2(123, 45)).is_equal_approx(Vector2(123, 45)), "따라가기 꺼짐 = 화면 변환 없음")
	var fm = main.mercs[0]
	var dm = main.mercs[1]
	fm.position = Vector2(120, 250)
	fm.downed = false
	main.select(fm)
	cam.toggle_from_selection()
	cam.snap()
	check(cam.is_following() and cam.target == fm and main.selected == null and cam.zoom == Vector2(2, 2), "따라가기 시작: x2, 선택(육성 창)은 닫힘")
	check(cam.view_rect().position.x >= 0.0 and cam.view_rect().position.y >= 0.0 and cam.view_rect().end.x <= 640.0 and cam.view_rect().end.y <= 360.0,
		"맵 밖이 보이지 않는다 (%s)" % str(cam.view_rect()))
	# (a) 확대 중 배치 클릭: 화면 좌표 → 맵 칸
	var wcell: Vector2 = dep.cell_center(dep._free_cell(fm.position + Vector2(-40, -20), {}))
	var sp: Vector2 = main.world_to_screen(wcell)
	check(main.screen_to_world(sp).distance_to(wcell) < 0.01 and sp.distance_to(wcell) > 20.0, "확대 중 화면↔맵 변환 (맵 %s → 화면 %s)" % [wcell, sp])
	main.select(dm)
	dm.post_pos = null
	var ev := InputEventMouseButton.new()
	ev.button_index = MOUSE_BUTTON_LEFT
	ev.pressed = true
	ev.position = sp
	main._unhandled_input(ev)
	check(sp.x < 300.0 and dm.post_pos == main.cell_of(wcell), "확대 중 클릭이 그 칸에 배치 (화면 %s → %s)" % [sp, str(dm.post_pos)])
	# 같은 맵 칸이라도 화면에서 육성 창이 덮는 곳이면 거부 (판정은 화면 기준)
	var covered: Vector2 = main.screen_to_world(Vector2(420, 150))
	dm.post_pos = null
	check(dep.ui_blocks(covered) and dep.handle_click(covered, null) and dm.post_pos == null, "확대 중 육성 창이 덮은 곳은 거부 (맵 %s)" % covered)
	# 확대 중 HUD가 가리는 판정은 화면 기준: 화면 아래 로그 패널 밑 맵 칸은 거부
	var under_log: Vector2 = main.screen_to_world(Vector2(150, 330))
	check(dep.ui_blocks(under_log) and not dep.ui_blocks(main.screen_to_world(Vector2(150, 200))), "확대 중 화면 아래 로그 패널 밑만 거부 (맵 %s)" % under_log)
	# 밤: 따라가기만으로는 배속이 바뀌지 않는다 (0.2배는 배치용 선택에만)
	main.select(null)
	main.is_night = true
	Engine.time_scale = 1.0
	dep._update_slow()
	check(is_equal_approx(Engine.time_scale, 1.0), "밤에 따라가기 중 배속 그대로 (x%.1f)" % Engine.time_scale)
	main.select(dm)
	dep._update_slow()
	check(is_equal_approx(Engine.time_scale, dep.NIGHT_EDIT_SPEED) and cam.target == fm, "따라가기 중에도 배치용 선택은 0.2배, 따라가기 유지")
	main.select(null)
	dep._update_slow()
	Engine.time_scale = 1.0
	# (b) 쓰러지거나 후퇴해도 해제되지 않는다
	fm.take_damage(999999.0)
	fm.retreating = true
	for i in 30:
		cam._process(1.0 / 60.0)
	check(fm.downed and cam.is_following() and cam.target == fm, "대상이 쓰러져도 따라가기 유지")
	fm.downed = false
	fm.hp = fm.max_hp
	fm.retreating = false
	# (c) 배율은 정수 2/3만
	var zooms_ok := true
	for z in [2.4, 2.6, 7.0, 0.0, -3.0, 3.0, 2.0]:
		cam.set_zoom_level(z)
		if cam.zoom.x != float(cam.zoom_level) or not (cam.zoom_level in [2, 3]) or cam.zoom.x != cam.zoom.y:
			zooms_ok = false
	var wheel := InputEventMouseButton.new()
	wheel.pressed = true
	for b in [MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN, MOUSE_BUTTON_WHEEL_DOWN, MOUSE_BUTTON_WHEEL_DOWN]:
		wheel.button_index = b
		cam._unhandled_input(wheel)
		if not (cam.zoom_level in [2, 3]) or cam.zoom.x != float(cam.zoom_level):
			zooms_ok = false
	check(zooms_ok and cam.zoom_level == 2, "확대 배율은 정수(2·3)로만 바뀐다")
	# Q/E 전환, Tab, 해제
	cam.cycle(1)
	check(cam.target == main.mercs[1], "E: 다음 쪼꼬미")
	cam.cycle(-1)
	check(cam.target == fm, "Q: 이전 쪼꼬미")
	main.toggle_hud()
	check(not cam.info_panel.is_visible_in_tree() and cam.is_following(), "Tab: HUD를 숨겨도 따라가기 유지")
	main.toggle_hud()
	check(cam.info_panel.is_visible_in_tree(), "Tab 다시 → 정보 패널 보임")
	cam._process(1.0 / 60.0)
	check(cam.info_label.text.begins_with(fm.merc_name) and cam.info_label.text.contains("상태:"), "정보 패널: %s" % cam.info_label.text.replace("
", " / "))
	# 성 위기 화살표: 영주관이 화면 밖 + 성 위기
	cam.set_zoom_level(3)
	fm.position = Vector2(30, 330)
	cam.snap()
	dep.last_hall_hit = main.elapsed
	dep.update_crisis()
	check(cam.hall_alert(), "영주관이 화면 밖이고 성 위기면 화살표")
	dep.last_hall_hit = -999.0
	dep.update_crisis()
	main.is_night = false
	var esc := InputEventKey.new()
	esc.keycode = KEY_ESCAPE
	esc.pressed = true
	cam._unhandled_input(esc)
	check(not cam.is_following() and cam.zoom == Vector2.ONE and main.world_to_screen(Vector2(10, 10)).is_equal_approx(Vector2(10, 10)), "Esc: 해제하면 원래 화면")

	print("RESULT %s (%d failures)" % ["PASS" if failures == 0 else "FAIL", failures])
	quit(0 if failures == 0 else 1)
	return true
