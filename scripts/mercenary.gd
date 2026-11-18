extends Node2D
## 쪼꼬미 용병
## 태어날 때 직업 · 능력치(근력/민첩/지능/체질/정신) · 등급 · 성격이 정해진다.
## 낮에는 욕구와 성격으로 행동을 고르고(유틸리티 AI), 밤에는 직업의 전투 방식대로 싸운다.

const JobData = preload("res://scripts/job_data.gd")
const Summon = preload("res://scripts/summon.gd")
const CharSprites = preload("res://scripts/char_sprites.gd")

## 성별마다 이름 목록이 따로 있다. 다 쓰면 겹쳐도 된다.
const NAMES := {
	"남": ["로웬", "카일", "브란", "테오", "도건", "오린", "가람", "에단", "이든", "펠",
		"루카", "보리", "노아", "한결", "도윤", "마루", "솔", "준"],
	"여": ["세라", "리나", "하엘", "유나", "베스", "미르", "아린", "시안", "다온", "하루",
		"모모", "콩이", "별이", "소이", "라온", "나비", "윤슬", "새봄"],
}
## 같은 묶음 안의 특성은 함께 가질 수 없다. 빈 문자열은 '특성 없음'.
const TRAIT_GROUPS := [["근면", "게으름", ""], ["겁쟁이", "용맹", ""], ["동료애", "대식가", ""]]

const ACTION_PLACE := {"rest": "inn", "eat": "mess", "train": "training",
	"work_farm": "farm", "work_wood": "forest", "chat": "plaza"}
const ACTION_LABEL := {"rest": "휴식", "eat": "식사", "train": "훈련",
	"work_farm": "농사", "work_wood": "벌목", "chat": "수다"}

var game
var merc_name := ""
var gender := "남"   # "남" / "여"
var job_id := "knight"
var tier := 0
var grade := 0
var stats := {}
var traits: Array[String] = []
var friend = null

var max_hp := 0.0
var hp := 0.0
var atk := 10.0
var defense := 0.0
var attack_range := 14.0
var attack_interval := 1.0
var move_speed := 40.0
var heal_power := 10.0
var energy := 100.0
var hunger := 10.0
var morale := 70.0
var level := 1
var xp := 0.0
var downed := false
var summons: Array = []

var activity := "대기"
var action := ""
var ate := false
var target_pos := Vector2.ZERO
var doing_time := 0.0
var attack_cd := 0.0
var flash_to := Vector2.ZERO
var flash_t := 0.0
var flash_color := Color.YELLOW
var splash_at := Vector2.ZERO
var splash_t := 0.0
var sprite_index := 96          # 팩이 없을 때 쓰는 Kenney 스프라이트
var char_id := 0                # Super Retro World 캐릭터 번호 (0 = 팩 없음)
var dir := CharSprites.Dir.DOWN
var facing := 1.0
var moving := false
var bob := 0.0
var rally_offset := Vector2.ZERO
var path := PackedVector2Array()
var path_goal := Vector2(INF, INF)
var repath_cd := 0.0


# ------------------------------------------------------------------ 탄생

## 태어날 때 모든 것이 정해진다. forced_job이 비어 있으면 직업도 무작위.
func roll_identity(rng: RandomNumberGenerator, forced_job: String = "", taken: Array[String] = []) -> void:
	var ids: Array = JobData.JOBS.keys()
	job_id = forced_job if forced_job != "" else ids[rng.randi() % ids.size()]
	gender = "남" if rng.randf() < 0.5 else "여"
	var used: Array = []
	if game != null:
		for other in game.mercs:
			used.append(other.char_id)
	char_id = CharSprites.pick(job_id, gender, used, rng)
	if char_id == 0 and CharSprites.available():   # 그 성별에 맞는 그림이 없으면 반대 성별로
		gender = "여" if gender == "남" else "남"
		char_id = CharSprites.pick(job_id, gender, used, rng)
	var pool: Array = NAMES[gender]
	var free_names: Array = []
	for n in pool:
		if not taken.has(n):
			free_names.append(n)
	if free_names.is_empty():
		free_names = pool.duplicate()
	merc_name = free_names[rng.randi() % free_names.size()]
	for s in JobData.STATS:
		stats[s] = float(clampi(roundi(rng.randfn(10.0, 3.5)), 1, 25))
	stats[job()["primary"]] += 2.0   # 직업 적성
	grade = JobData.grade_for_total(stat_total())
	for group in TRAIT_GROUPS:
		var t: String = group[rng.randi() % group.size()]
		if t != "":
			traits.append(t)
	if traits.is_empty():
		traits.append("근면")
	var sprites: Array = job()["sprites"]
	sprite_index = sprites[rng.randi() % sprites.size()]
	rally_offset = Vector2(rng.randf_range(-18, 18), rng.randf_range(-12, 12))
	target_pos = position
	recalc()
	hp = max_hp


func job() -> Dictionary:
	return JobData.JOBS[job_id]


func style() -> String:
	return job()["style"]


func title() -> String:
	return job()["tiers"][tier]["name"]


func job_name() -> String:
	return title()


func grade_info() -> Dictionary:
	return JobData.GRADES[grade]


func stat_total() -> float:
	var t := 0.0
	for s in JobData.STATS:
		t += float(stats[s])
	return t


func has_trait(t: String) -> bool:
	return traits.has(t)


func trait_text() -> String:
	return ", ".join(PackedStringArray(traits))


## 능력치 · 레벨 · 전직 단계로 전투 수치를 다시 계산한다.
func recalc() -> void:
	var j := job()
	var m: float = JobData.TIER_MULT[tier]
	var lv := float(level - 1)
	var old_max := max_hp
	max_hp = (50.0 + float(stats["vit"]) * 5.0 + lv * 6.0) * float(j["hp_mult"]) * m
	atk = (4.0 + float(stats[j["primary"]]) * 0.7 + lv * 0.8) * m
	if has_trait("용맹"):
		atk *= 1.15
	defense = float(stats["vit"]) * 0.3 + float(j["def_bonus"]) + tier * 2.0
	attack_range = float(j["range"])
	if style() in ["ranged", "aoe"]:
		attack_range += tier * 8.0
	attack_interval = float(j["interval"]) / (1.0 + float(stats["dex"]) * 0.015)
	move_speed = 36.0 + float(stats["dex"]) * 0.5
	heal_power = (6.0 + float(stats["wis"]) * 0.8 + lv) * m
	if old_max > 0.0:
		hp = clampf(hp + (max_hp - old_max), 1.0, max_hp)


func xp_needed() -> float:
	return 20.0 * level


## 다음 전직 정보. 더 오를 단계가 없으면 빈 Dictionary.
func next_tier() -> Dictionary:
	var tiers: Array = job()["tiers"]
	if tier + 1 >= tiers.size():
		return {}
	return {"name": tiers[tier + 1]["name"], "level": tiers[tier + 1]["level"],
		"residue": JobData.PROMOTE_RESIDUE[tier + 1], "gold": JobData.PROMOTE_GOLD[tier + 1]}


func promote() -> void:
	tier += 1
	recalc()
	hp = max_hp
	morale = minf(100.0, morale + 20.0)


func describe() -> String:
	return "%s  %s  Lv.%d %s" % [grade_info()["name"], merc_name, level, title()]


# ------------------------------------------------------------------ 매 프레임

func _process(delta: float) -> void:
	if game == null or game.game_over:
		return
	bob += delta * 8.0
	attack_cd = maxf(0.0, attack_cd - delta)
	flash_t = maxf(0.0, flash_t - delta)
	splash_t = maxf(0.0, splash_t - delta)
	moving = false
	if downed:
		activity = "쓰러짐"
	elif game.is_night:
		_night(delta)
	else:
		_day(delta)
	queue_redraw()


# ------------------------------------------------------------------ 낮: 생활

func _day(delta: float) -> void:
	hunger = minf(100.0, hunger + delta * (1.6 if has_trait("대식가") else 1.0))
	energy = maxf(0.0, energy - delta * 0.5)
	if hunger > 75.0:
		morale = maxf(0.0, morale - delta * 2.0)
	if action == "":
		_choose_action()
	if position.distance_to(target_pos) > 2.0:
		_move_to(target_pos, delta)
		return
	doing_time -= delta
	match action:
		"rest":
			energy = minf(100.0, energy + delta * 14.0)
			hp = minf(max_hp, hp + delta * 6.0)
		"eat":
			if not ate:
				ate = true
				if game.food >= 1.0:
					game.food -= 1.0
					hunger = maxf(0.0, hunger - 70.0)
					morale = minf(100.0, morale + 5.0)
				else:
					morale = maxf(0.0, morale - 5.0)
					activity = "배고픔"
		"train":
			energy = maxf(0.0, energy - delta * 4.0)
			gain_xp(delta * 3.0 * game.train_bonus)
		"work_farm":
			energy = maxf(0.0, energy - delta * 3.0)
			game.food += delta * 0.6
		"work_wood":
			energy = maxf(0.0, energy - delta * 3.5)
			game.wood += delta * 0.5
		"chat":
			morale = minf(100.0, morale + delta * 4.0)
	if doing_time <= 0.0:
		action = ""


func _choose_action() -> void:
	var lazy := has_trait("게으름")
	var diligent := has_trait("근면")
	var e := energy / 100.0
	var scores := {
		"rest": (100.0 - energy) * (1.6 if lazy else 1.0) + (15.0 if lazy else 0.0),
		"eat": hunger * 1.3 if game.food >= 1.0 else hunger * 0.3,
		"train": (25.0 + (40.0 if diligent else 0.0)) * e,
		"work_farm": (30.0 + (25.0 if diligent else 0.0) + (25.0 if game.food < 15.0 else 0.0)) * e,
		"work_wood": (30.0 + (20.0 if diligent else 0.0) + (20.0 if game.wood < 30.0 else 0.0)) * e,
		"chat": 15.0 + (100.0 - morale) * 0.4,
	}
	var best := "chat"
	var best_score := -1.0
	for k in scores:
		var s: float = scores[k] + game.rng.randf_range(0.0, 15.0)
		if s > best_score:
			best_score = s
			best = k
	action = best
	ate = false
	doing_time = game.rng.randf_range(4.0, 7.0)
	target_pos = game.building_pos(ACTION_PLACE[action])
	activity = ACTION_LABEL[action]


# ------------------------------------------------------------------ 밤: 전투

func on_night_start() -> void:
	if style() != "summon" or downed:
		return
	var count := mini(tier + 1, 3)
	for i in count:
		var s: Summon = Summon.new()
		s.game = game
		s.summoner = self
		s.position = position + Vector2(game.rng.randf_range(-12, 12), game.rng.randf_range(4, 12))
		s.setup(float(stats["int"]), level, tier)
		game.add_child(s)
		game.summons.append(s)
		summons.append(s)
	game.add_log("%s: 소환수 %d마리를 불렀다." % [merc_name, count])


func clear_summons() -> void:
	for s in summons:
		if is_instance_valid(s):
			game.summons.erase(s)
			s.queue_free()
	summons.clear()


func _night(delta: float) -> void:
	# 정신이 높을수록 덜 도망친다
	var flee_ratio := 0.25 - float(stats["wis"]) * 0.005
	if has_trait("겁쟁이"):
		flee_ratio += 0.25
	elif has_trait("용맹"):
		flee_ratio = 0.1
	if hp < max_hp * flee_ratio:
		activity = "후퇴"
		var safe: Vector2 = game.buildings["inn"]["spot"]
		if position.distance_to(safe) > 6.0:
			_move_to(safe, delta)
		else:
			hp = minf(max_hp, hp + delta * 4.0)
		return
	if style() == "heal" and _try_heal(delta):
		return
	var target = _pick_target()
	if target == null:
		var guard: Vector2 = game.rally_point if game.has_rally else game.buildings["hall"]["spot"]
		activity = "집결" if game.has_rally else "경계"
		if position.distance_to(guard + rally_offset) > 4.0:
			_move_to(guard + rally_offset, delta)
		return
	var tpos: Vector2 = target.position
	if position.distance_to(tpos) > attack_range:
		activity = "돌격"
		_move_to(tpos, delta)
	elif attack_cd <= 0.0:
		activity = "전투"
		attack_cd = attack_interval
		_attack(target, tpos)


func _attack(target, tpos: Vector2) -> void:
	var dmg := atk * (0.7 + morale / 200.0)
	flash_to = tpos - position
	flash_t = 0.12
	match style():
		"aoe":
			flash_color = Color("c9a0ff")
			var radius := 18.0 + tier * 5.0
			splash_at = flash_to
			splash_t = 0.2
			for mo in game.monsters.duplicate():
				if is_instance_valid(mo) and mo != target and mo.position.distance_to(tpos) < radius:
					mo.take_damage(dmg * 0.6, self)
		"ranged":
			flash_color = Color("ffe08a")
		"heal", "summon":
			dmg *= 0.5
			flash_color = Color("a0ffe0")
		_:
			flash_color = Color.WHITE
	if is_instance_valid(target):
		target.take_damage(dmg, self)


func _pick_target():
	if has_trait("동료애") and friend != null and is_instance_valid(friend) and not friend.downed:
		for mo in game.monsters:
			if is_instance_valid(mo) and mo.position.distance_to(friend.position) < 40.0:
				activity = "친구 구출"
				return mo
	var anchor: Vector2 = game.rally_point if game.has_rally else position
	var best_d := 90.0 if game.has_rally else 99999.0
	var best = null
	for mo in game.monsters:
		if not is_instance_valid(mo):
			continue
		var d: float = mo.position.distance_to(anchor)
		if d < best_d:
			best_d = d
			best = mo
	return best


func _try_heal(delta: float) -> bool:
	var hurt: Array = []
	for m in game.mercs:
		if m.downed:
			continue
		var r: float = m.hp / m.max_hp
		if r < 0.7 and m.position.distance_to(position) < 120.0:
			hurt.append(m)
	if hurt.is_empty():
		return false
	hurt.sort_custom(func(a, b): return a.hp / a.max_hp < b.hp / b.max_hp)
	var worst = hurt[0]
	activity = "치유"
	var wpos: Vector2 = worst.position
	if position.distance_to(wpos) > attack_range:
		_move_to(wpos, delta)
	elif attack_cd <= 0.0:
		attack_cd = attack_interval
		var targets := hurt.slice(0, 2 if tier >= 2 else 1)
		for t in targets:
			t.hp = minf(t.max_hp, t.hp + heal_power)
		flash_to = wpos - position
		flash_t = 0.2
		flash_color = Color(0.5, 1.0, 0.6)
		gain_xp(1.0)
	return true


func take_damage(amount: float) -> void:
	if downed:
		return
	var reduced := amount * 30.0 / (30.0 + defense)
	hp -= reduced
	var fear := 0.4 if has_trait("겁쟁이") else 0.15
	morale = maxf(0.0, morale - reduced * fear * (1.0 - float(stats["wis"]) * 0.02))
	if hp <= 0.0:
		hp = 0.0
		downed = true
		game.add_log("%s 쓰러졌다!" % merc_name)
		for m in game.mercs:
			if m != self and m.friend == self:
				m.morale = maxf(0.0, m.morale - 15.0)


## 레벨업 때 모든 능력치가 조금씩 오른다. 등급이 높을수록, 주 능력치일수록 더 많이.
func gain_xp(amount: float) -> void:
	xp += amount
	while xp >= xp_needed():
		xp -= xp_needed()
		level += 1
		var growth: float = grade_info()["growth"]
		for s in JobData.STATS:
			var g: float = game.rng.randf_range(0.0, 1.0) + growth
			if s == job()["primary"]:
				g += 0.5
			stats[s] = float(stats[s]) + snappedf(g, 0.1)
		recalc()
		game.add_log("%s 레벨 %d 달성!" % [merc_name, level])
		var nt := next_tier()
		if not nt.is_empty() and level == int(nt["level"]):
			game.add_log("%s: %s 전직 가능!" % [merc_name, nt["name"]])


func on_dawn() -> void:
	clear_summons()
	if downed:
		downed = false
		hp = max_hp * 0.3
		morale = maxf(0.0, morale - 10.0)
	energy = maxf(0.0, energy - 20.0)
	action = ""


# ------------------------------------------------------------------ 이동

func _move_to(p: Vector2, delta: float) -> void:
	var spd := move_speed * (0.6 if energy < 20.0 else 1.0)
	_follow(p, spd * delta, delta)
	moving = true


## 경로를 따라 p로 이동한다. 목표가 크게 바뀌면 0.4초 간격으로 다시 길을 찾는다.
func _follow(p: Vector2, step: float, delta: float) -> void:
	repath_cd -= delta
	var far := position.distance_to(p) > 20.0
	if repath_cd <= 0.0 and (path_goal.distance_to(p) > 12.0 or (path.is_empty() and far)):
		path = game.find_path(position, p)
		path_goal = p
		repath_cd = 0.4
	while path.size() > 0 and position.distance_to(path[0]) < 1.5:
		path.remove_at(0)
	var next := p
	if path.size() > 0:
		next = path[0]
	elif not game.is_walkable(p) and game.is_walkable(position):
		return
	var d := next - position
	if absf(d.x) > 0.5:
		facing = signf(d.x)
	if d.length() > 0.5:
		if absf(d.x) > absf(d.y):
			dir = CharSprites.Dir.RIGHT if d.x > 0 else CharSprites.Dir.LEFT
		else:
			dir = CharSprites.Dir.DOWN if d.y > 0 else CharSprites.Dir.UP
	position = position.move_toward(next, step)


# ------------------------------------------------------------------ 그리기
## 원점 = 발밑. 팩이 있으면 16x20 캐릭터(4방향 걷기), 없으면 16x16 Kenney.

func _draw() -> void:
	var gcol: Color = grade_info()["color"]
	var sheet: Texture2D = CharSprites.sheet(char_id) if char_id > 0 else null
	var h := 20.0 if sheet else 16.0
	if downed:
		draw_set_transform(Vector2(0, -4), PI / 2.0, Vector2.ONE)
		if sheet:
			draw_texture_rect_region(sheet, Rect2(-8, -10, 16, 20), CharSprites.frame_rect(CharSprites.Dir.DOWN, 1), Color(0.55, 0.45, 0.45))
		else:
			draw_texture_rect_region(game.dungeon_tex, Rect2(-8, -8, 16, 16), Rect2(game.tile_src(sprite_index)), Color(0.55, 0.45, 0.45))
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		return
	# 발밑 그림자 (등급 색, 노말은 검정)
	draw_rect(Rect2(-5, -1, 10, 2), Color(gcol, 0.6) if grade > 0 else Color(0, 0, 0, 0.25))
	if sheet:
		var col: int = CharSprites.WALK[int(bob * 0.75) % 4] if moving else 1
		draw_texture_rect_region(sheet, Rect2(-8, -20, 16, 20), CharSprites.frame_rect(dir, col))
	else:
		var hop := -1.0 if moving and int(bob) % 2 == 0 else 0.0
		draw_set_transform(Vector2(0, hop), 0.0, Vector2(facing, 1.0))
		draw_texture_rect_region(game.dungeon_tex, Rect2(-8, -16, 16, 16), Rect2(game.tile_src(sprite_index)))
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	var top := -h   # 머리 꼭대기
	# 전직 단계 표시 (발밑 금색 점)
	for i in tier:
		draw_rect(Rect2(-3 + i * 2, 2, 1, 1), Color("ffd84a"))
	# 레전더리 반짝임
	if grade == 3 and int(bob * 0.5) % 4 == 0:
		draw_rect(Rect2(6, top + 1, 1, 1), Color.WHITE)
		draw_rect(Rect2(-7, top + 6, 1, 1), gcol)
	if game.selected == self:
		draw_rect(Rect2(-9, top - 2, 18, h + 4), Color(1, 0.95, 0.4), false, 1.0)
	if hp < max_hp:
		draw_rect(Rect2(-6, top - 4, 12, 2), Color(0.1, 0.1, 0.1))
		draw_rect(Rect2(-6, top - 4, floorf(12.0 * hp / max_hp), 2), Color("5ad05a"))
	if flash_t > 0.0:
		draw_line(Vector2(0, -8), flash_to + Vector2(0, -6), flash_color, 1.0)
	if splash_t > 0.0:
		draw_arc(splash_at + Vector2(0, -6), 18.0 + tier * 5.0, 0.0, TAU, 20, Color(0.8, 0.6, 1.0, 0.7), 1.0)
	var f: Font = game.font_s
	# 이름은 항상 머리 위에 (등급 색). 체력바 바로 위.
	var name_col: Color = gcol if grade > 0 else Color(0.95, 0.92, 0.85)
	# 가까이 붙은 동료가 앞에 있으면 이름을 한 칸씩 위로 쌓는다
	var stack := 0
	for other in game.mercs:
		if other == self:
			break
		if not other.downed and absf(other.position.x - position.x) < 22.0 and absf(other.position.y - position.y) < 10.0:
			stack += 1
	top -= mini(stack, 3) * 8
	_label(f, merc_name, top - 5, name_col)
	# 행동 이름은 선택했을 때와 위급 상태일 때만, 이름 위에 (겹침 방지)
	if game.selected == self or activity in ["후퇴", "친구 구출", "배고픔", "치유"]:
		_label(f, activity, top - 13, Color(1, 1, 1, 0.85))


func _label(f: Font, text: String, y: float, col: Color) -> void:
	var w := f.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, 8).x
	var tp := Vector2(floorf(-w / 2.0), y)
	draw_string_outline(f, tp, text, HORIZONTAL_ALIGNMENT_LEFT, -1, 8, 2, Color(0, 0, 0, 0.85))
	draw_string(f, tp, text, HORIZONTAL_ALIGNMENT_LEFT, -1, 8, col)
