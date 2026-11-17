extends Node2D
## 균열에서 나온 마물 — 시간의 잔재.
## 가까운 용병을 공격하고, 없으면 영주관을 향해 진격한다.

var game
var max_hp := 30.0
var hp := 30.0
var atk := 6.0
var speed := 22.0
var elite := false
var reward := 8
var body_size := 5.0
var attack_cd := 0.0
var bob := 0.0
var hit_t := 0.0


func setup(day: int, is_elite: bool) -> void:
	elite = is_elite
	max_hp = 25.0 + day * 6.0
	atk = 5.0 + day * 1.2
	speed = 20.0 + randf() * 8.0
	reward = 6 + day
	if elite:
		max_hp *= 5.0
		atk *= 2.0
		speed *= 0.7
		body_size = 11.0
		reward = 50 + day * 5
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
			position = position.move_toward(tpos, speed * delta)
		elif attack_cd <= 0.0:
			attack_cd = 1.2
			target.take_damage(atk)
	else:
		var hall: Vector2 = game.buildings["hall"]["pos"]
		if position.distance_to(hall) > 24.0 + body_size:
			position = position.move_toward(hall, speed * delta)
		elif attack_cd <= 0.0:
			attack_cd = 1.2
			game.damage_hall(atk)
	queue_redraw()


func take_damage(amount: float, attacker = null) -> void:
	if hp <= 0.0:
		return
	hp -= amount
	hit_t = 0.08
	if hp <= 0.0:
		if attacker != null and is_instance_valid(attacker):
			attacker.gain_xp(20.0 if elite else 4.0)
		game.on_monster_killed(self)


func _draw() -> void:
	var c := Color("2a1633") if not elite else Color("4a0f1f")
	if hit_t > 0.0:
		c = Color.WHITE
	var y := sin(bob) * 1.0
	draw_circle(Vector2(0, body_size * 0.4), body_size * 0.9, Color(0, 0, 0, 0.3))
	draw_circle(Vector2(0, y), body_size, c)
	draw_circle(Vector2(0, y - body_size * 0.3), body_size * 0.6, c.lightened(0.12))
	var eye := maxf(1.0, body_size * 0.2)
	draw_rect(Rect2(-body_size * 0.5, -body_size * 0.4 + y, eye, eye), Color("ff3030"))
	draw_rect(Rect2(body_size * 0.5 - eye, -body_size * 0.4 + y, eye, eye), Color("ff3030"))
	if elite:
		draw_line(Vector2(-6, -8 + y), Vector2(-10, -15 + y), Color("d8c8a8"), 2.0)
		draw_line(Vector2(6, -8 + y), Vector2(10, -15 + y), Color("d8c8a8"), 2.0)
	if hp < max_hp:
		var w := body_size * 2.0
		draw_rect(Rect2(-w / 2.0, -body_size - 5, w, 1.5), Color(0.1, 0.1, 0.1))
		draw_rect(Rect2(-w / 2.0, -body_size - 5, w * hp / max_hp, 1.5), Color("e05a4a"))
