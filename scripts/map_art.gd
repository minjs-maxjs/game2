extends RefCounted
## 마을 맵 그림: Super Retro World Exterior Pack (무료판, Gif · Noiracide · Romi)
##
## 재배포 금지라 저장소에 넣지 않는다(.gitignore). 팩이 없으면 main.gd가 Kenney로 그린다.
## RPG Maker VX Ace용 32px 시트를 읽어 16px로 줄여 쓴다(원본이 16px 그림을 정확히 2배 한 것).
## 분홍(#FF00FF)은 투명, 어두운 분홍은 그림자.
##
## 건물(영주관·여관·식당)은 프로젝트 자체 그림이라 assets/agra/ 에 있다.

const PACK := "res://exterior-pack-free_version/rpgmaker/VXace/tilesets"
const TILE := 16

## 오토타일 종류 → A2 시트에서 블록 왼쪽 위 칸 (16px 칸 단위, 블록은 2x3칸)
const AUTO := {
	"cobble": Vector2i(4, 0),   # 풀밭 위 돌길
	"dirt": Vector2i(2, 0),     # 풀밭 위 흙 (밭)
}
const GRASS := Vector2i(0, 0)   # A2 맨 왼쪽 위: 맨 풀

## tileset_0 (16px 칸). [x, y, 가로칸, 세로칸]
const PROPS := {
	"tree_big": [4, 2, 2, 2],
	"pine": [6, 2, 1, 2],
	"bush": [7, 3, 1, 1],
	"flower_w": [5, 4, 1, 1],
	"flower_r": [6, 4, 1, 1],
	"rock_s": [5, 5, 1, 1],
	"rock_b": [6, 5, 1, 1],
	"lamp": [7, 4, 1, 2],
	"tuft_a": [4, 7, 1, 1],
	"tuft_b": [5, 7, 1, 1],
	"fence_l": [5, 6, 1, 1],
	"fence_m": [6, 6, 1, 1],
	"fence_r": [7, 6, 1, 1],
	"post": [6, 7, 1, 1],
	"crate": [4, 8, 1, 1],
	"crate2": [5, 8, 1, 1],
	"bucket": [5, 9, 1, 1],
	"barrel": [5, 10, 1, 1],
	"bench": [2, 10, 2, 1],
	"sign": [6, 8, 1, 1],
}

static var _sheets := {}


static func available() -> bool:
	return FileAccess.file_exists(PACK + "/_srw_tileset_0.png")


## 32px 시트를 16px로 줄이고 분홍을 투명으로.
static func _sheet(file: String) -> Image:
	if _sheets.has(file):
		return _sheets[file]
	var img := Image.load_from_file(ProjectSettings.globalize_path(PACK + "/" + file))
	img.convert(Image.FORMAT_RGBA8)
	img.resize(img.get_width() / 2, img.get_height() / 2, Image.INTERPOLATE_NEAREST)
	for y in img.get_height():
		for x in img.get_width():
			var c := img.get_pixel(x, y)
			if c.g8 == 0 and c.r8 == c.b8 and c.r8 > 0:
				# 분홍 = 투명, 어두운 분홍 = 분홍 위에 그려 둔 그림자 → 반투명 검정
				img.set_pixel(x, y, Color(0.08, 0.05, 0.1, (1.0 - c.r8 / 255.0) * 1.6 if c.r8 < 255 else 0.0))
	_sheets[file] = img
	return img


## 프로젝트 자체 그림 (assets/agra). import 없이 직접 읽는다.
static func own(name: String) -> Image:
	var img := Image.load_from_file(ProjectSettings.globalize_path("res://assets/agra/%s.png" % name))
	img.convert(Image.FORMAT_RGBA8)
	return img


static func grass(img: Image, tx: int, ty: int) -> void:
	img.blit_rect(_sheet("_srw_exterior_A2.png"), Rect2i(GRASS * TILE, Vector2i(TILE, TILE)), Vector2i(tx, ty) * TILE)


## 소품 하나. (tx, ty) = 소품의 맨 아래 왼쪽 칸 (나무처럼 위로 솟는 것도 발밑 기준).
static func prop(img: Image, key: String, tx: int, ty: int) -> void:
	var p: Array = PROPS[key]
	var src := Rect2i(p[0] * TILE, p[1] * TILE, p[2] * TILE, p[3] * TILE)
	img.blend_rect(_sheet("_srw_tileset_0.png"), src, Vector2i(tx * TILE, (ty - p[3] + 1) * TILE))


## RPG Maker VX Ace A2 오토타일. cells에 들어 있는 칸들을 이어진 모양으로 그린다.
## 칸 하나를 8px 네 조각으로 나눠, 조각마다 이웃(가로·세로·대각)을 보고 블록에서 고른다.
static func autotile(img: Image, kind: String, cells: Array) -> void:
	var sheet := _sheet("_srw_exterior_A2.png")
	var base: Vector2i = AUTO[kind] * TILE
	var has := {}
	for c in cells:
		has[c] = true
	for c in has:
		for qy in 2:
			for qx in 2:
				var dx := 1 if qx == 1 else -1
				var dy := 1 if qy == 1 else -1
				var h: bool = has.has(c + Vector2i(dx, 0))
				var v: bool = has.has(c + Vector2i(0, dy))
				var d: bool = has.has(c + Vector2i(dx, dy))
				var q: Vector2i   # 블록 안의 8px 조각 좌표 (가로 0~3, 세로 0~5)
				if h and v and d:
					q = Vector2i(1 + qx, 3 + qy)       # 안쪽
				elif h and v:
					q = Vector2i(2 + qx, qy)           # 안쪽 모서리
				elif not h and not v:
					q = Vector2i(qx * 3, 2 + qy * 3)   # 바깥 모서리
				elif h:
					q = Vector2i(1 + qx, 2 + qy * 3)   # 위·아래 가장자리
				else:
					q = Vector2i(qx * 3, 3 + qy)       # 왼·오른 가장자리
				var src := Rect2i(base + q * 8, Vector2i(8, 8))
				img.blit_rect(sheet, src, c * TILE + Vector2i(qx, qy) * 8)
