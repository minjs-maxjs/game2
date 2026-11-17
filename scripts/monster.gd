extends Node2D
## 균열에서 나온 마물 — 시간의 잔재.
## 가까운 용병을 공격하고, 없으면 영주관을 향해 진격한다.
## 스프라이트: Kenney Tiny Dungeon. 엘리트는 2배 크기.

const NORMAL_SPRITES := [108, 120, 121, 122, 123, 124]
const ELITE_SPRITES := [109, 110]

var game
var max_hp := 30.0
var hp := 30.0
var atk := 6.0
var speed := 22.0
var elite := false
var reward := 8
var body_size := 6.0
var sprite_index := 108
var attack_cd := 0.0
var bob := 0.0
var hit_t := 0.0
var facing := 1.0
var path := PackedVector2Array()
var path_goal := Vector2(INF, INF)
var repath_cd := 0.0


func setup(day: int, is_elite: bool, rng: RandomNumberGenerator) -> void:
	elite = is_elite
	max_hp = 25.0 + day * 6.0
	atk = 5.0 + day * 1.2
	speed = 20.0 + rng.randf() * 8.0
	reward = 6 + day
	sprite_index = NORMAL_SPRITES[rng.randi() % NORMAL_SPRITES.size()]
	if elite:
		max_hp *= 5.0
		atk *= 2.0
		speed *= 0.7
		body_size = 12.0
		reward = 50 + day * 5
		sprite_index = ELITE_SPRITES[rng.randi() % ELITE_SPRITES.size()]
	hp = max_hp


func _process(delta: float) -> void:
	if game == null or game.game_over:
		return
	bob += delta * 6.0
	attack_cd = maxf(0.0, attack_cd - delta)
	hit_t = maxf(0.0, hit_t - delta)
	var target = null
	var best := 40.0 + body_size
	for m in game.mercs:
		if m.downed:
			continue
		var d: float = position.distance_to(m.position)
		if d < best:
			best = d
			target = m
	if target != null:
		var tpos: Vector2 = target.position
		if position.distance_to(tpos) > body_size + 5.0:
			_move_to(tpos, delta)
		elif attack_cd <= 0.0:
			attack_cd = 1.2
			target.take_damage(atk)
	else:
		var hall: Rect2 = game.hall_rect
		if not hall.grow(10.0 + body_size * 0.5).has_point(position):
			_move_to(hall.get_center(), delta)
		elif attack_cd <= 0.0:
			attack_cd = 1.2
			game.damage_hall(atk)
	queue_redraw()


func _move_to(p: Vector2, delta: float) -> void:
	_follow(p, speed * delta, delta)

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


func take_damage(amount: float, attacker = null) -> void:
	if hp <= 0.0:
		return
	hp -= amount
	hit_t = 0.1
	if hp <= 0.0:
		if attacker != null and is_instance_valid(attacker):
			attacker.gain_xp(20.0 if elite else 4.0)
		game.on_monster_killed(self)


func _draw() -> void:
	var s := 2.0 if elite else 1.0
	var src := Rect2(game.tile_src(sprite_index))
	var tint := Color(1, 0.35, 0.35) if hit_t > 0.0 else Color(0.85, 0.72, 1.0)
	var hop := -1.0 if int(bob) % 2 == 0 else 0.0
	draw_rect(Rect2(-5 * s, -1, 10 * s, 2), Color(0, 0, 0, 0.3))
	draw_set_transform(Vector2(0, hop), 0.0, Vector2(facing * s, s))
	draw_texture_rect_region(game.dungeon_tex, Rect2(-8, -16, 16, 16), src, tint)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	if hp < max_hp:
		var w := 12.0 * s
		var y := -16.0 * s - 4.0
		draw_rect(Rect2(-w / 2.0, y, w, 2), Color(0.1, 0.1, 0.1))
		draw_rect(Rect2(-w / 2.0, y, floorf(w * hp / max_hp), 2), Color("e05a4a"))
