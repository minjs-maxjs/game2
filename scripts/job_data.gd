extends RefCounted
## 쪼꼬미 직업 · 등급 · 능력치 데이터
## 새 직업은 JOBS에 항목 하나를 추가하면 된다. 전투 방식(style)은 아래 다섯 가지 중 하나:
##   melee  근접 공격          ranged 원거리 단일 공격
##   aoe    원거리 광역 공격   heal   아군 치유 (치유할 대상이 없으면 약한 공격)
##   summon 밤마다 소환수를 부른다

const STATS := ["str", "dex", "int", "vit", "wis"]
const STAT_NAMES := {"str": "근력", "dex": "민첩", "int": "지능", "vit": "체질", "wis": "정신"}

## 등급은 태어날 때 굴린 능력치 합계로 정해진다. growth = 레벨업 때 능력치 성장 보너스.
## stat_cap = 육성 창 능력치 바의 상한 (값이 넘어도 바만 꽉 찬다).
const GRADES := [
	{"name": "노말", "min_total": 0, "color": Color("c8c8c8"), "growth": 0.0, "stat_cap": 30},
	{"name": "엘리트", "min_total": 56, "color": Color("5aa8ff"), "growth": 0.25, "stat_cap": 36},
	{"name": "히어로", "min_total": 62, "color": Color("c070ff"), "growth": 0.5, "stat_cap": 42},
	{"name": "레전더리", "min_total": 68, "color": Color("ffc23a"), "growth": 0.8, "stat_cap": 50},
]
const STAT_CAP_DEFAULT := 30

## 전직 단계별 능력 배율과 비용 (index = 단계, 0은 기본 직업)
const TIER_MULT := [1.0, 1.25, 1.55, 1.9]
const PROMOTE_RESIDUE := [0, 2, 5, 10]
const PROMOTE_GOLD := [0, 50, 120, 250]
## 전직할 때 필요한 주 능력치 (0이면 조건 없음)
const PROMOTE_STAT := [0, 14, 19, 24]

const JOBS := {
	"knight": {
		"name": "기사", "role": "근접 · 방어", "style": "melee", "primary": "str",
		"hp_mult": 1.4, "def_bonus": 6.0, "range": 14.0, "interval": 1.0,
		"sprites": [96, 97], "color": Color("d84a3a"),
		"perk": "2단계부터 주변 마물을 도발해 공격을 받아낸다",
		"tiers": [
			{"name": "기사", "level": 1},
			{"name": "근위기사", "level": 5},
			{"name": "성기사", "level": 10},
			{"name": "천공의 수호자", "level": 15},
		],
	},
	"mage": {
		"name": "마법사", "role": "원거리 · 광역", "style": "aoe", "primary": "int",
		"hp_mult": 0.85, "def_bonus": 0.0, "range": 65.0, "interval": 1.6,
		"sprites": [84], "color": Color("9b6bff"),
		"perk": "대상 주변까지 피해. 단계가 오를수록 범위와 사거리 증가",
		"tiers": [
			{"name": "마법사", "level": 1},
			{"name": "원소술사", "level": 5},
			{"name": "대마법사", "level": 10},
			{"name": "시간술사", "level": 15},
		],
	},
	"gunner": {
		"name": "거너", "role": "원거리 · 단일", "style": "ranged", "primary": "dex",
		"hp_mult": 0.9, "def_bonus": 1.0, "range": 85.0, "interval": 1.1,
		"sprites": [112, 88], "color": Color("3fae5a"),
		"perk": "가장 긴 사거리. 단계가 오를수록 사거리 증가",
		"tiers": [
			{"name": "거너", "level": 1},
			{"name": "저격수", "level": 5},
			{"name": "화포장", "level": 10},
			{"name": "마탄의 사수", "level": 15},
		],
	},
	"summoner": {
		"name": "소환사", "role": "소환 · 물량", "style": "summon", "primary": "int",
		"hp_mult": 0.85, "def_bonus": 0.0, "range": 55.0, "interval": 1.8,
		"sprites": [111], "color": Color("4fd1c5"),
		"perk": "밤마다 소환수를 부른다 (단계+1마리, 최대 3)",
		"tiers": [
			{"name": "소환사", "level": 1},
			{"name": "정령술사", "level": 5},
			{"name": "군주소환사", "level": 10},
			{"name": "심연의 계약자", "level": 15},
		],
	},
	"healer": {
		"name": "힐러", "role": "치유 · 지원", "style": "heal", "primary": "wis",
		"hp_mult": 0.9, "def_bonus": 1.0, "range": 60.0, "interval": 1.4,
		"sprites": [99, 100], "color": Color("7fd6ff"),
		"perk": "체력 낮은 아군 치유. 3단계부터 둘을 동시에 치유",
		"tiers": [
			{"name": "힐러", "level": 1},
			{"name": "사제", "level": 5},
			{"name": "대사제", "level": 10},
			{"name": "빛의 대행자", "level": 15},
		],
	},
}


static func stat_cap(grade: int) -> float:
	if grade < 0 or grade >= GRADES.size():
		return float(STAT_CAP_DEFAULT)
	return float(GRADES[grade].get("stat_cap", STAT_CAP_DEFAULT))


static func grade_for_total(total: float) -> int:
	for i in range(GRADES.size() - 1, -1, -1):
		if total >= float(GRADES[i]["min_total"]):
			return i
	return 0
