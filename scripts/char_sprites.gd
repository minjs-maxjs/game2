extends RefCounted
## 미니용사 외형: Super Retro World Character Pack (Gif · Noiracide · Romi)
##
## 라이선스상 에셋을 재배포할 수 없어 저장소에 넣지 않는다(.gitignore).
## 팩 폴더가 있으면 그 그림을, 없으면 Kenney 스프라이트로 대신 그린다.
##
## 캐릭터 한 장 = 48x80. 칸 16x20, 가로 3칸(걷기 프레임), 세로 4줄(방향).

const PACK_DIR := "res://SuperRetroWorld_CharacterPack_Full/sprite_split"
const FRAME := Vector2i(16, 20)
enum Dir { DOWN, LEFT, RIGHT, UP }
const WALK := [0, 1, 2, 1]   # 걷기 프레임 순서, 서 있을 때는 1

## 캐릭터 번호 → [성별, 어울리는 직업들]. 새 캐릭터는 여기 한 줄 추가.
const CHARS := {
	1: ["남", ["gunner", "knight"]],    17: ["남", ["gunner", "knight"]],
	2: ["여", ["summoner", "healer"]],  18: ["여", ["summoner", "mage"]],
	3: ["여", ["knight", "mage"]],      19: ["여", ["knight", "mage"]],
	4: ["남", ["mage", "healer"]],      20: ["남", ["summoner", "healer"]],
	5: ["여", ["healer"]],              21: ["여", ["healer"]],
	6: ["여", ["gunner"]],              22: ["여", ["summoner", "gunner"]],
	7: ["남", ["knight"]],              23: ["남", ["knight", "gunner"]],
	8: ["남", ["knight"]],              24: ["남", ["knight"]],
	9: ["남", ["knight"]],              10: ["여", ["healer", "gunner"]],
	11: ["여", ["mage"]],               12: ["여", ["summoner", "mage"]],
	13: ["남", ["knight"]],             14: ["여", ["gunner"]],
	15: ["여", ["gunner", "knight"]],   16: ["여", ["summoner"]],
	25: ["남", ["healer"]],             26: ["여", ["healer"]],
	27: ["남", ["mage", "summoner"]],   28: ["남", ["mage", "summoner"]],
	29: ["남", ["mage", "summoner"]],   30: ["남", ["mage", "summoner"]],
	31: ["남", ["mage", "summoner"]],   32: ["남", ["mage", "summoner"]],
}

static var _cache := {}


static func path_of(id: int) -> String:
	return "%s/character_%d/character_%d_frame16x20.png" % [PACK_DIR, id, id]


static func available() -> bool:
	return FileAccess.file_exists(path_of(1))


## 직업과 성별에 맞는 캐릭터 번호. 겹치지 않게 used를 피하고, 없으면 0.
static func pick(job_id: String, gender: String, used: Array, rng: RandomNumberGenerator) -> int:
	if not available():
		return 0
	var best: Array = []
	var any: Array = []
	for id in CHARS:
		var c: Array = CHARS[id]
		if c[0] == gender and job_id in c[1]:
			any.append(id)
			if not used.has(id):
				best.append(id)
	var pool := best if not best.is_empty() else any
	return 0 if pool.is_empty() else pool[rng.randi() % pool.size()]


static func gender_of(id: int) -> String:
	return CHARS[id][0] if CHARS.has(id) else ""


## 가져올 때 import를 거치지 않도록 PNG를 직접 읽는다 (팩이 없어도 프로젝트가 열린다).
static func sheet(id: int) -> Texture2D:
	if _cache.has(id):
		return _cache[id]
	var img := Image.load_from_file(ProjectSettings.globalize_path(path_of(id)))
	var tex: Texture2D = ImageTexture.create_from_image(img) if img else null
	_cache[id] = tex
	return tex


static func frame_rect(dir: int, col: int) -> Rect2:
	return Rect2(col * FRAME.x, dir * FRAME.y, FRAME.x, FRAME.y)
