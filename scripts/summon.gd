extends Node2D
## 소환사가 밤마다 부르는 정령. 새벽이 오면 사라진다.
## 정령이라 건물을 통과해 날아다닌다. 마물의 공격 대상이 된다.

const MapArt = preload("res://scripts/map_art.gd")
## 단계가 오를수록 정령 색이 짙어진다.
const TIER_TINT := [Color(1, 1, 1, 0.9), Color(0.85, 1.0, 0.9, 0.95), Color(1.0, 0.9, 1.2, 1.0)]

var game
var summoner
var max_hp := 30.0
var hp := 30.0
var atk := 5.0
var speed := 46.0
var downed := false   # 마물의 대상 선택과 호환
var tint_base := Color.WHITE
var attack_cd := 0.0
var bob := 0.0
var facing := 1.0
var hit_t := 0.0


func setup(intel: float, level: int, tier: int) -> void:
	max_hp = 20.0 + intel * 1.5 + level * 3.0
	hp = max_hp
	atk = 3.0 + intel * 0.4 + level * 0.5 + tier * 2.0
	tint_base = TIER_TINT[mini(tier, TIER_TINT.size() - 1)]


func _process(delta: float) -> void:
	if game == null or game.game_over:
		return
	bob += delta * 6.0
	attack_cd = maxf(0.0, attack_cd - delta)
	hit_t = maxf(0.0, hit_t - delta)
	var home: Vector2 = summoner.position if is_instance_valid(summoner) else position
	var target = null
	var best := 140.0
	for mo in game.monsters:
		if not is_instance_valid(mo):
			continue
		var d: float = mo.position.distance_to(home)
		if d < best:
			best = d
			target = mo
	if target == null:
		if position.distance_to(home) > 14.0:
			_move(home + Vector2(0, 8), delta)
	else:
		var tpos: Vector2 = target.position
		if position.distance_to(tpos) > 10.0:
			_move(tpos, delta)
		elif attack_cd <= 0.0:
			attack_cd = 1.0
			target.take_damage(atk, self)
	queue_redraw()


func _move(p: Vector2, delta: float) -> void:
	if absf(p.x - position.x) > 0.5:
		facing = signf(p.x - position.x)
	position = position.move_toward(p, speed * delta)


func take_damage(amount: float) -> void:
	hp -= amount
	hit_t = 0.1
	if hp <= 0.0:
		game.summons.erase(self)
		if is_instance_valid(summoner):
			summoner.summons.erase(self)
		queue_free()


## 소환수가 잡은 마물의 경험치는 소환사에게 간다.
func gain_xp(amount: float) -> void:
	if is_instance_valid(summoner):
		summoner.gain_xp(amount)


func _draw() -> void:
	var y := floorf(sin(bob) * 2.0) - 3.0
	var tint := Color(1, 0.4, 0.4, 0.9) if hit_t > 0.0 else tint_base
	var frame := int(bob * 1.5) % 3
	draw_rect(Rect2(-4, -1, 8, 2), Color(0, 0, 0, 0.2))
	draw_set_transform(Vector2(0, y), 0.0, Vector2(facing, 1.0))
	draw_texture_rect_region(MapArt.own_tex("summon"), Rect2(-8, -20, 16, 20), Rect2(frame * 16, 0, 16, 20), tint)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	if hp < max_hp:
		draw_rect(Rect2(-5, -21 + y, 10, 1), Color(0.1, 0.1, 0.1))
		draw_rect(Rect2(-5, -21 + y, floorf(10.0 * hp / max_hp), 1), Color("6fe8d8"))
