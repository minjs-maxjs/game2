extends SceneTree
## 일차·웨이브 HUD 스크린샷 (창이 잠깐 뜬다).
## 실행: godot --path . --script res://tests/hud_shots.gd -- <출력폴더>
## hud_day.png(낮 배너) · hud_night_intro.png(밤 시작 연출, 엘리트 밤) · hud_night.png(밤 진행) · hud_dawn.png(새벽 정산)

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
	if frames == 2:
		main.day = 3   # 엘리트 밤 예고 확인용
		main.phase_time = 15.0
		main.deployment.auto_deploy()
	if frames == 150:
		_save("hud_day.png")
		main._start_night()
	if frames == 170:
		_save("hud_night_intro.png")
	if frames == 170:
		Engine.time_scale = 3.0
	if frames > 170 and frames < 2400 and main.is_night and main.director.wave_info()["killed"] >= 2 and not main.has_meta("night_shot"):
		main.set_meta("night_shot", true)
		_save("hud_night.png")
		for mo in main.monsters:
			mo.queue_free()
		main.monsters.clear()
		main.director.wave_idx = main.director.waves.size() - 1
		main.director.to_spawn = 0
		main.mercs[1].take_damage(99999.0)
	if main.director.is_dawn and frames < 2400:
		if not main.has_meta("dawn_wait"):
			main.set_meta("dawn_wait", frames)
		elif frames - int(main.get_meta("dawn_wait")) == 20:
			_save("hud_dawn.png")
			quit(0)
			return true
	if frames >= 2400:
		print("timeout")
		quit(1)
		return true
	return false


func _save(name: String) -> void:
	var img := root.get_texture().get_image()
	img.save_png(out_dir.path_join(name))
	print("saved ", out_dir.path_join(name), " ", img.get_size())
