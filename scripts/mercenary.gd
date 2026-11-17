extends Node2D
## 자유 의지 용병
## 낮에는 욕구(기력·허기·사기)와 성격으로 행동을 고르고(유틸리티 AI),
## 밤에는 성격·직업·집결 지점에 따라 싸운다.

const JOB_NAMES := ["전사", "궁수", "사제"]
## Kenney Tiny Dungeon 타일 번호: 직업별 외형 후보
const JOB_SPRITES := [[96, 97, 87, 98], [112, 88, 85], [84, 100, 111]]
const JOB_BADGE := [Color("d84a3a"), Color("3fae5a"), Color("7fd6ff")]
const NAMES := ["로웬", "카일", "미르", "세라", "브란", "테오", "리나", "도건",
	"하엘", "유나", "오린", "베스", "가람", "솔", "에단", "마루", "이든", "펠"]
## 같은 묶음 안의 특성은 함께 가질 수 없다. 빈 문자열은 '특성 없음'.
const TRAIT_GROUPS := [["근면", "게으름", ""], ["겁쟁이", "용맹", ""], ["동료애", "대식가", ""]]

const ACTION_PLACE := {"rest": "inn", "eat": "mess", "train": "training",
	"work_farm": "farm", "work_wood": "forest", "chat": "plaza"}
const ACTION_LABEL := {"rest": "휴식", "eat": "식사", "train": "훈련",
	"work_farm": "농사", "work_wood": "벌목", "chat": "수다"}

var game
var merc_name := ""
var job := 0
var traits: Array[String] = []
var friend = null

var max_hp := 100.0
var hp := 100.0
var atk := 10.0
var attack_range := 14.0
var attack_interval := 1.0
var move_speed := 42.0
var energy := 100.0
var hunger := 10.0
var morale := 70.0
var level := 1
var xp := 0.0
var downed := false

var activity := "대기"
var action := ""
var ate := false
var target_pos := Vector2.ZERO
var doing_time := 0.0
var attack_cd := 0.0
var flash_to := Vector2.ZERO
var flash_t := 0.0
var flash_color := Color.YELLOW
var sprite_index := 96
var facing := 1.0
var moving := false
var bob := 0.0
var rally_offset := Vector2.ZERO
var path := PackedVector2Array()
var path_goal := Vector2(INF, INF)
var repath_cd := 0.0


func randomize_identity(rng: RandomNumberGenerator, forced_job: int = -1, taken: Array[String] = []) -> void:
	var free_names: Array = []
	for n in NAMES:
		if not taken.has(n):
			free_names.append(n)
	if free_names.is_empty():
		free_names = NAMES.duplicate()
	merc_name = free_names[rng.randi() % free_names.size()]
	job = forced_job if forced_job >= 0 else rng.randi() % 3
	for group in TRAIT_GROUPS:
		var t: String = group[rng.randi() % group.size()]
		if t != "":
			traits.append(t)
	if traits.is_empty():
		traits.append("근면")
	match job:
		0:
			max_hp = 120.0; atk = 12.0; attack_range = 14.0; attack_interval = 1.0
		1:
			max_hp = 80.0; atk = 9.0; attack_range = 75.0; attack_interval = 1.3
		2:
			max_hp = 85.0; atk = 5.0; attack_range = 60.0; attack_interval = 1.5
	if has_trait("용맹"):
		atk *= 1.15
	hp = max_hp
	var options: Array = JOB_SPRITES[job]
	sprite_index = options[rng.randi() % options.size()]
	rally_offset = Vector2(rng.randf_range(-18, 18), rng.randf_range(-12, 12))
	target_pos = position


func has_trait(t: String) -> bool:
	return traits.has(t)


func job_name() -> String:
	return JOB_NAMES[job]


func trait_text() -> String:
	return ", ".join(PackedStringArray(traits))


func describe() -> String:
	var friend_name := "-"
	if friend != null and is_instance_valid(friend):
		friend_name = friend.merc_name
	return "%s  Lv.%d %s  [%s]\n체력 %d/%d  공격 %.0f  경험 %d/%d\n기력 %d  허기 %d  사기 %d\n행동: %s   친구: %s" % [
		merc_name, level, job_name(), trait_text(),
		int(hp), int(max_hp), atk, int(xp), 20 * level,
		int(energy), int(hunger), int(morale), activity, friend_name]


func _process(delta: float) -> void:
	if game == null or game.game_over:
		return
	bob += delta * 8.0
	attack_cd = maxf(0.0, attack_cd - delta)
	flash_t = maxf(0.0, flash_t - delta)
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

func _night(delta: float) -> void:
	var flee_ratio := 0.25
	if has_trait("겁쟁이"):
		flee_ratio = 0.5
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
	if job == 2 and _try_heal(delta):
		return
	var target = _pick_target()
	if target == null:
		var guard: Vector2 = game.rally_point if game.has_rally else game.buildings["hall"]["spot"]
		activity = "집결" if game.has_rally else "경계"
		if position.distance_to(guard + rally_offset) > 4.0:
			_move_to(guard + rally_offset, delta)
		return
	var tpos: Vector2 = target.position
	var dist := position.distance_to(tpos)
	if dist > attack_range:
		activity = "돌격"
		_move_to(tpos, delta)
	elif attack_cd <= 0.0:
		activity = "전투"
		attack_cd = attack_interval
		var dmg := atk * (0.7 + morale / 200.0)
		flash_to = tpos - position
		flash_t = 0.12
		flash_color = Color.YELLOW
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
	var worst = null
	var worst_ratio := 0.7
	for m in game.mercs:
		if m.downed:
			continue
		var r: float = m.hp / m.max_hp
		var d: float = m.position.distance_to(position)
		if r < worst_ratio and d < 120.0:
			worst_ratio = r
			worst = m
	if worst == null:
		return false
	activity = "치유"
	var wpos: Vector2 = worst.position
	if position.distance_to(wpos) > attack_range:
		_move_to(wpos, delta)
	elif attack_cd <= 0.0:
		attack_cd = attack_interval
		worst.hp = minf(worst.max_hp, worst.hp + 14.0 + level * 2.0)
		flash_to = wpos - position
		flash_t = 0.2
		flash_color = Color(0.5, 1.0, 0.6)
		gain_xp(1.0)
	return true


func take_damage(amount: float) -> void:
	if downed:
		return
	hp -= amount
	morale = maxf(0.0, morale - amount * (0.4 if has_trait("겁쟁이") else 0.15))
	if hp <= 0.0:
		hp = 0.0
		downed = true
		game.add_log("%s 쓰러졌다!" % merc_name)
		for m in game.mercs:
			if m != self and m.friend == self:
				m.morale = maxf(0.0, m.morale - 15.0)


func gain_xp(amount: float) -> void:
	xp += amount
	while xp >= 20.0 * level:
		xp -= 20.0 * level
		level += 1
		max_hp += 10.0
		hp += 10.0
		atk += 1.0 if job == 2 else 2.0
		game.add_log("%s 레벨 %d 달성!" % [merc_name, level])


func on_dawn() -> void:
	if downed:
		downed = false
		hp = max_hp * 0.3
		morale = maxf(0.0, morale - 10.0)
	energy = maxf(0.0, energy - 20.0)
	action = ""


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
	if absf(next.x - position.x) > 0.5:
		facing = signf(next.x - position.x)
	position = position.move_toward(next, step)


# ------------------------------------------------------------------ 그리기
## 원점 = 발밑. 스프라이트는 16x16 (Kenney Tiny Dungeon).

func _draw() -> void:
	var tex: Texture2D = game.dungeon_tex
	var src := Rect2(game.tile_src(sprite_index))
	if downed:
		draw_set_transform(Vector2(0, -4), PI / 2.0, Vector2.ONE)
		draw_texture_rect_region(tex, Rect2(-8, -8, 16, 16), src, Color(0.55, 0.45, 0.45))
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		return
	var hop := -1.0 if moving and int(bob) % 2 == 0 else 0.0
	draw_rect(Rect2(-5, -1, 10, 2), Color(0, 0, 0, 0.25))
	draw_set_transform(Vector2(0, hop), 0.0, Vector2(facing, 1.0))
	draw_texture_rect_region(tex, Rect2(-8, -16, 16, 16), src)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	# 직업 표식 (발밑 점)
	draw_rect(Rect2(-1, 1, 2, 1), JOB_BADGE[job])
	if game.selected == self:
		draw_rect(Rect2(-9, -18, 18, 20), Color(1, 0.95, 0.4), false, 1.0)
	if hp < max_hp:
		draw_rect(Rect2(-6, -20, 12, 2), Color(0.1, 0.1, 0.1))
		draw_rect(Rect2(-6, -20, floorf(12.0 * hp / max_hp), 2), Color("5ad05a"))
	if flash_t > 0.0:
		draw_line(Vector2(0, -8), flash_to + Vector2(0, -6), flash_color, 1.0)
	# 행동 이름은 선택했을 때만, 위급 상태는 항상 표시 (겹침 방지)
	if game.selected != self and not (activity in ["후퇴", "친구 구출", "배고픔", "치유"]):
		return
	var f: Font = game.font_s
	var w := f.get_string_size(activity, HORIZONTAL_ALIGNMENT_LEFT, -1, 8).x
	var tp := Vector2(floorf(-w / 2.0), -22)
	draw_string_outline(f, tp, activity, HORIZONTAL_ALIGNMENT_LEFT, -1, 8, 2, Color(0, 0, 0, 0.8))
	draw_string(f, tp, activity, HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color(1, 1, 1, 0.9))
