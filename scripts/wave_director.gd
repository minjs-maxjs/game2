extends Node
## 밤 파도와 휴식: 그날 밤 마물을 파도 2~3개로 나누고, 파도 사이에 쉬게 한다.
## - 밤 마물 총수 = (3 + 날짜×2) × 난이도 리듬 배율(날짜 % 3). 엘리트는 마지막 파도의 마지막 마물.
## - 파도 사이 WAVE_REST초: 마물이 나오지 않고 미니용사가 천천히 회복한다 (후퇴 중이면 기준을 넘는 대로 복귀).
## - 마지막 파도를 다 잡으면 새벽 정산: 시간이 멈추고, "낮 시작"(또는 Space)을 눌러야 다음 낮이 온다.
## - 낮에 육성 창/배치(미니용사 선택)가 열려 있어도 시간이 멈춘다. 실제 배속 조절은 deployment.gd가 한다.
## 다른 코드는 wave_info() · night_preview()로 읽기만 한다.

## - 새벽마다 턴 선택(turn_select.gd): 디펜스(기존 밤) / 오펜스(원정 · 그날 밤 자동 방어). 보스 날은 디펜스 강제.
## - 침식 게이지: 오펜스 +1, 디펜스를 마치면 -1. 디펜스 밤 마물 수에 게이지 1당 +EROSION_WAVE_MULT.

const DawnPanel = preload("res://scripts/dawn_panel.gd")
const TurnSelect = preload("res://scripts/turn_select.gd")

## 보스 날 간격: 날짜 % 이 값 == 0 이면 디펜스 강제 + 마지막 엘리트에 is_boss.
## TODO: 오메가 보스 본체는 아직 없다 (지금은 엘리트 마물에 플래그만).
const BOSS_DAY_INTERVAL := 5
## 원정 파티 최대 인원
const EXPEDITION_PARTY_MAX := 4
## 원정 임시 보상 (TODO: 실시간 탐험 맵으로 교체): 금화 = 기본 + 인원당, 마물의 잔재 = 인원당
const EXP_GOLD_BASE := 20
const EXP_GOLD_PER_MEMBER := 10
const EXP_RESIDUE_PER_MEMBER := 1
## 오펜스 날 밤 자동 방어: 위협 = 마물 수 × THREAT_PER_MONSTER, 전투력 = Σ(공격 + 방어 + 최대 체력 × POWER_HP_WEIGHT)
const THREAT_PER_MONSTER := 12.0
const POWER_HP_WEIGHT := 0.2
## 전투력이 위협에 모자라면: 영주관 피해 = 최대 HP × 이 값 × 부족분 비율
const OFFENSE_HALL_DMG_SCALE := 0.5
## 침식 게이지 상한과, 게이지 1당 디펜스 밤 마물 수 배율 증가
const EROSION_MAX := 5
const EROSION_WAVE_MULT := 0.1

## 낮 길이(초)
const DAY_LENGTH := 45.0
## true면 새벽 정산 창을 기다리지 않고 바로 낮을 시작한다 (테스트는 auto_continue를 켠다).
const AUTO_CONTINUE_DAWN := false
## 파도 사이 휴식(초)과 휴식 중 초당 회복량(최대 체력 대비)
const WAVE_REST := 12.0
const REST_HEAL_PER_SEC := 0.03
## 난이도 리듬: 날짜 % 3 → 마물 수 배율과 이름 (0 = 엘리트 밤, 1 = 쉬운 밤, 2 = 보통 밤)
const NIGHT_MULT := [1.0, 0.8, 1.0]
const NIGHT_KIND := ["엘리트 밤", "쉬운 밤", "보통 밤"]
## 마물 총수가 이보다 적으면 2파도, 같거나 많으면 3파도
const THREE_WAVE_MIN := 6
const FIRST_SPAWN_DELAY := 1.0

var game
var auto_continue := AUTO_CONTINUE_DAWN
var is_dawn := false
var report: Dictionary = {}     # 새벽 정산 내용 (enter_dawn에서 채운다)

var waves: Array[int] = []
var wave_idx := 0
var to_spawn := 0               # 이번 파도에서 아직 안 나온 마물
var spawn_timer := 0.0
var resting := false
var rest_left := 0.0
var night_total := 0
var kills := 0
var gold_earned := 0.0
var _hall_at_dusk := 0.0

var panel: DawnPanel
var turn_select: TurnSelect
var erosion := 0
var offense_today := false      # 오늘이 원정의 날인가 (밤은 자동 방어)
var party: Array = []           # 원정 중인 미니용사
var expedition: Dictionary = {} # 이번 원정 결과 (새벽 정산 report로 넘어간다)


## main._build_hud() 뒤에 부른다.
func setup(g) -> void:
	game = g
	panel = DawnPanel.new()
	panel.director = self
	game.hud_root.add_child(panel)
	panel.visible = false
	turn_select = TurnSelect.new()
	turn_select.director = self
	game.hud_root.add_child(turn_select)


# ------------------------------------------------------------------ 계산식 (여기 한 곳에만 둔다)

static func base_total(d: int) -> int:
	return 3 + d * 2


## ero: 침식 게이지 (디펜스 밤에만 넘긴다)
static func night_total_for(d: int, ero: int = 0) -> int:
	return maxi(2, roundi(base_total(d) * float(NIGHT_MULT[d % 3]) * (1.0 + EROSION_WAVE_MULT * ero)))


static func is_boss_day(d: int) -> bool:
	return d > 0 and d % BOSS_DAY_INTERVAL == 0


static func has_elite(d: int) -> bool:
	return d % 3 == 0 or is_boss_day(d)


## 파도별 마물 수. 나머지는 뒤 파도부터 하나씩 더 얹는다 (뒤로 갈수록 세게).
static func wave_sizes(d: int, ero: int = 0) -> Array[int]:
	var total := night_total_for(d, ero)
	var n := 2 if total < THREE_WAVE_MIN else 3
	var out: Array[int] = []
	for i in n:
		out.append(total / n)
	for i in total % n:
		out[n - 1 - i] += 1
	return out


# ------------------------------------------------------------------ 읽기용

## 오늘(또는 d일) 밤 예고: {total, elite, boss, offense, erosion, kind, waves}
## 오펜스 날이면 침식을 더하지 않는다 (침식은 다음 디펜스 밤에 붙는다).
func night_preview(d: int = -1) -> Dictionary:
	if d < 0:
		d = game.day
	var ero := 0 if offense_today else erosion
	return {
		"total": night_total_for(d, ero), "elite": has_elite(d), "boss": is_boss_day(d),
		"offense": offense_today, "erosion": erosion,
		"kind": "보스 밤" if is_boss_day(d) else NIGHT_KIND[d % 3], "waves": wave_sizes(d, ero).size(),
	}


## 지금 밤 진행: {wave(1부터), waves, remaining, total, killed, resting, rest_left, elite}
func wave_info() -> Dictionary:
	var unspawned := to_spawn
	for i in range(wave_idx + 1, waves.size()):
		unspawned += waves[i]
	var remaining: int = unspawned + game.monsters.size()
	return {
		"wave": wave_idx + 1, "waves": waves.size(),
		"remaining": remaining, "total": night_total, "killed": maxi(0, night_total - remaining),
		"resting": resting, "rest_left": rest_left, "elite": has_elite(game.day), "boss": is_boss_day(game.day),
	}


func is_last_wave() -> bool:
	return wave_idx >= waves.size() - 1


## 시간을 멈춰야 하는가: 새벽 정산 중, 또는 낮에 육성 창/배치(미니용사 선택)가 열려 있는 동안.
func wants_pause() -> bool:
	if game.game_over:
		return false
	if is_dawn:
		return true
	return not game.is_night and game.selected != null and is_instance_valid(game.selected)


# ------------------------------------------------------------------ 밤

func start_night() -> void:
	waves = wave_sizes(game.day, erosion)
	night_total = 0
	for w in waves:
		night_total += w
	kills = 0
	gold_earned = 0.0
	_hall_at_dusk = game.hall_hp
	_begin_wave(0)


func _begin_wave(i: int) -> void:
	wave_idx = i
	to_spawn = waves[i]
	spawn_timer = FIRST_SPAWN_DELAY
	resting = false
	rest_left = 0.0
	if i > 0:
		game.add_log("%d번째 파도! (%d/%d · %d마리)" % [i + 1, i + 1, waves.size(), waves[i]])


func update_night(delta: float) -> void:
	if resting:
		rest_left -= delta
		for m in game.mercs:
			if not m.downed:
				m.hp = minf(m.max_hp, m.hp + m.max_hp * REST_HEAL_PER_SEC * delta)
		if rest_left <= 0.0:
			_begin_wave(wave_idx + 1)
		return
	spawn_timer -= delta
	if to_spawn > 0 and spawn_timer <= 0.0:
		spawn_timer = maxf(0.6, 2.0 - game.day * 0.15)
		to_spawn -= 1
		var elite := has_elite(game.day) and is_last_wave() and to_spawn == 0
		game._spawn_monster(elite, elite and is_boss_day(game.day))
	if to_spawn <= 0 and game.monsters.is_empty():
		if is_last_wave():
			game._start_dawn()
		else:
			resting = true
			rest_left = WAVE_REST
			game.add_log("파도를 막아냈다. %d초 숨 돌린다 — 재배치할 수 있다." % int(WAVE_REST))


func on_kill(mo) -> void:
	kills += 1
	gold_earned += float(mo.reward)


# ------------------------------------------------------------------ 새벽

## main._start_dawn()이 임금·부활 처리 전에 부른다 (쓰러진 수를 세려고).
func enter_dawn() -> void:
	var fallen := 0
	for m in game.mercs:
		if m.downed:
			fallen += 1
	report = {
		"day": game.day, "kills": kills, "gold": int(gold_earned), "fallen": fallen,
		"hall_loss": int(maxf(0.0, _hall_at_dusk - game.hall_hp)), "wage": 0, "wage_paid": true,
		"offense": offense_today, "expedition": expedition if offense_today else {},
	}
	if not offense_today:
		erosion = maxi(0, erosion - 1)   # 디펜스를 마쳤다
	offense_today = false
	expedition = {}
	waves.clear()
	wave_idx = 0
	to_spawn = 0
	resting = false
	is_dawn = true


## main._start_dawn()이 임금 처리까지 끝낸 뒤 부른다.
func show_dawn() -> void:
	if auto_continue:
		continue_day()
		return
	if panel:
		panel.show_report(report)
		panel.start_button.visible = turn_select == null   # 턴 선택 창의 [디펜스]가 대신한다
	if turn_select:
		turn_select.open(report)


## 디펜스: "낮 시작" 버튼 / 턴 선택 [디펜스] / Space.
func continue_day() -> void:
	if not is_dawn:
		return
	is_dawn = false
	offense_today = false
	if panel:
		panel.visible = false
	if turn_select:
		turn_select.close()
	game._begin_day()


# ------------------------------------------------------------------ 오펜스 (스텁)

## 원정에 고를 수 있는 미니용사: 마을에 있고 쓰러지지 않은 이.
func alive_home_mercs() -> Array:
	return game.mercs.filter(func(m): return not m.downed and not m.away)


## 턴 선택 [출발]. 보스 날이 다음 날이면 거부한다. 성공하면 하루가 시작된다.
func start_offense(p: Array) -> bool:
	if not is_dawn or is_boss_day(game.day + 1) or p.is_empty():
		return false
	party = p.slice(0, EXPEDITION_PARTY_MAX)
	erosion = mini(EROSION_MAX, erosion + 1)
	var names: PackedStringArray = []
	for m in party:
		game.send_away(m)
		names.append(m.merc_name)
	continue_day()
	offense_today = true
	game.add_log("원정 출발: %s (침식 %d/%d)" % [", ".join(names), erosion, EROSION_MAX])
	return true


## 마을에 남은 인원의 전투력 합.
func home_power() -> float:
	var s := 0.0
	for m in game.mercs:
		if not m.away and not m.downed:
			s += m.atk + m.defense + m.max_hp * POWER_HP_WEIGHT
	return s


static func offense_threat(d: int) -> float:
	return night_total_for(d) * THREAT_PER_MONSTER


## 오펜스 날 해질녘 (main._start_night 대신): 전투 장면 없이 결과 한 줄 → 원정 귀환 → 새벽.
## TODO: 실시간 탐험 맵이 생기면 원정 결과는 거기서 받는다.
func resolve_offense_night() -> String:
	_hall_at_dusk = game.hall_hp
	kills = 0
	gold_earned = 0.0
	var power := home_power()
	var threat := offense_threat(game.day)
	var lack := clampf((threat - power) / threat, 0.0, 1.0)
	var dmg := float(game.HALL_MAX_HP) * OFFENSE_HALL_DMG_SCALE * lack
	var line := "마을 자동 방어: 전투력 %d / 위협 %d → %s" % [
		int(power), int(threat), "피해 없음" if dmg <= 0.0 else "영주관 -%d" % ceili(dmg)]
	var g_reward := EXP_GOLD_BASE + EXP_GOLD_PER_MEMBER * party.size()
	var r_reward := EXP_RESIDUE_PER_MEMBER * party.size()
	game.gold += g_reward
	game.residue += r_reward
	var names: Array = []
	for m in party:
		names.append(m.merc_name)
		game.return_home(m)
	party.clear()
	expedition = {"members": names, "gold": g_reward, "residue": r_reward, "line": line}
	game.add_log(line)
	# 성 위기 판정은 건드리지 않는다 (전투 장면이 없으므로). 무너질 때만 damage_hall로 게임 오버 처리.
	if dmg >= game.hall_hp:
		game.damage_hall(dmg)
	else:
		game.hall_hp -= dmg
	if not game.game_over:
		game._start_dawn()
	return line
