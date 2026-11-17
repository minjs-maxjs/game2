extends SceneTree
## 실제 렌더링 화면을 PNG로 저장한다 (헤드리스 불가, 창이 잠깐 뜬다).
## 실행: godot --path . --script res://tests/screenshot.gd -- <출력폴더>
## 낮 화면(day.png)과 밤 전투 화면(night.png)을 남긴다.

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
	if frames == 240:
		_save("day.png")
		main._start_night()
		Engine.time_scale = 2.0
	if frames == 420:
		_save("night.png")
		quit(0)
		return true
	return false


func _save(name: String) -> void:
	var img := root.get_texture().get_image()
	img.save_png(out_dir.path_join(name))
	print("saved ", out_dir.path_join(name), " ", img.get_size())
