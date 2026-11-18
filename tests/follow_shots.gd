extends SceneTree
## 따라가기 카메라 스크린샷 (창이 잠깐 뜬다).
## 실행: godot --path . --script res://tests/follow_shots.gd -- <출력폴더>
## follow_day.png(낮 따라가기 x2 + 정보 패널 + 말풍선) · follow_night.png(밤 따라가기 x3, 쓰러진 대상, 성 위기 화살표)

var main
var frames := 0
var out_dir := "user://"


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() > 0:
		out_dir = args[0]
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)


func _process(_delta: float) -> bool:
	frames += 1
	var cam = main.follow_cam
	if frames == 30:
		main.select(main.mercs[0])
		cam.toggle_from_selection()   # 육성 창 "따라가기"와 같은 동작
	if frames == 110:
		cam.say("배고프다")
	if frames == 120:
		_save("follow_day.png")
		main.deployment.auto_deploy()
		main._start_night()
		var t = main.mercs[1]
		cam.start(t)
		cam.set_zoom_level(3)
		t.position = Vector2(40, 320)
		t.take_damage(999999.0)   # 쓰러져도 따라가기는 유지된다
		var raider = preload("res://scripts/monster.gd").new()
		raider.game = main
		raider.position = Vector2(272, 216)
		main.add_child(raider)
		raider.setup(main.day, true, main.rng)
		raider.hp = 99999.0
		main.monsters.append(raider)
	if frames == 200:
		_save("follow_night.png")
		print("following=", cam.is_following(), " target_downed=", cam.target.downed, " alert=", cam.hall_alert(), " zoom=", cam.zoom)
		quit(0)
		return true
	return false


func _save(name: String) -> void:
	var img := root.get_texture().get_image()
	img.save_png(out_dir.path_join(name))
	print("saved ", out_dir.path_join(name), " ", img.get_size())
