extends Node
## 밤 파도와 휴식: 그날 밤 마물을 파도 2~3개로 나누고, 파도 사이에 쉬게 한다.
## - 밤 마물 총수 = (3 + 날짜×2) × 난이도 리듬 배율(날짜 % 3). 엘리트는 마지막 파도의 마지막 마물.
## - 파도 사이 WAVE_REST초: 마물이 나오지 않고 미니용사가 천천히 회복한다 (후퇴 중이면 기준을 넘는 대로 복귀).
## - 마지막 파도를 다 잡으면 새벽 정산: 시간이 멈추고, "낮 시작"(또는 Space)을 눌러야 다음 낮이 온다.
## - 낮에 육성 창/배치(미니용사 선택)가 열려 있어도 시간이 멈춘다. 실제 배속 조절은 deployment.gd가 한다.
## 다른 코드는 wave_info() · night_preview()로 읽기만 한다.

const DawnPanel = preload("res://scripts/dawn_panel.gd")

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


## main._build_hud() 뒤에 부른다.
func setup(g) -> void:
	game = g
	panel = DawnPanel.new()
	panel.director = self
	game.hud_root.add_child(panel)
	panel.visible = false


# ------------------------------------------------------------------ 계산식 (여기 한 곳에만 둔다)

static func base_total(d: int) -> int:
	return 3 + d * 2


static func night_total_for(d: int) -> int:
	return maxi(2, roundi(base_total(d) * float(NIGHT_MULT[d % 3])))


static func has_elite(d: int) -> bool:
	return d % 3 == 0


## 파도별 마물 수. 나머지는 뒤 파도부터 하나씩 더 얹는다 (뒤로 갈수록 세게).
static func wave_sizes(d: int) -> Array[int]:
	var total := night_total_for(d)
	var n := 2 if total < THREE_WAVE_MIN else 3
	var out: Array[int] = []
	for i in n:
		out.append(total / n)
	for i in total % n:
		out[n - 1 - i] += 1
	return out


# ------------------------------------------------------------------ 읽기용

## 오늘(또는 d일) 밤 예고: {total, elite, kind, waves}
func night_preview(d: int = -1) -> Dictionary:
	if d < 0:
		d = game.day
	return {"total": night_total_for(d), "elite": has_elite(d), "kind": NIGHT_KIND[d % 3], "waves": wave_sizes(d).size()}


## 지금 밤 진행: {wave(1부터), waves, remaining, total, killed, resting, rest_left, elite}
func wave_info() -> Dictionary:
	var unspawned := to_spawn
	for i in range(wave_idx + 1, waves.size()):
		unspawned += waves[i]
	var remaining: int = unspawned + game.monsters.size()
	return {
		"wave": wave_idx + 1, "waves": waves.size(),
		"remaining": remaining, "total": night_total, "killed": maxi(0, night_total - remaining),
		"resting": resting, "rest_left": rest_left, "elite": has_elite(game.day),
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
	waves = wave_sizes(game.day)
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
		game._spawn_monster(has_elite(game.day) and is_last_wave() and to_spawn == 0)
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
	}
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


## "낮 시작" 버튼 / Space.
func continue_day() -> void:
	if not is_dawn:
		return
	is_dawn = false
	if panel:
		panel.visible = false
	game._begin_day()
