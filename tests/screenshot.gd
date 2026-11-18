extends SceneTree
## 실제 렌더링 화면을 PNG로 저장한다 (헤드리스 불가, 창이 잠깐 뜬다).
## 실행: godot --path . --script res://tests/screenshot.gd -- <출력폴더>
## 낮 화면(day.png), 밤 화면(night.png), 효과가 터지는 전투 순간(battle.png)을 남긴다.

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
		main._spawn_merc("summoner")
		main.gold = 120.0
	if frames == 230:
		main.select(main.mercs[0])
	if frames == 240:
		_save("day.png")
		main.select(null)
		main._start_night()
		main._spawn_monster(true)   # 정예 그림 확인용
		Engine.time_scale = 2.0
	if frames == 420:
		_save("night.png")
	if frames > 420:
		var busy := 0
		for m in main.mercs:
			if m.fx_t > 0.0 or m.bolt_t > 0.0:
				busy += 1
		if busy >= 2 or frames >= 1500:
			_save("battle.png")
			quit(0)
			return true
	return false


func _save(name: String) -> void:
	var img := root.get_texture().get_image()
	img.save_png(out_dir.path_join(name))
	print("saved ", out_dir.path_join(name), " ", img.get_size())
