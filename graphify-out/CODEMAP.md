# 아그라 전기 — 코드 맵 (graphify 자동 생성)

줄 번호는 graph 생성 시점 기준. 코드를 고친 뒤에는 `/graphify --update`로 갱신할 것.

## 커뮤니티 (기능 묶음)

- **0** 낮밤 순환 · 웨이브 · 월드 상태
- **1** HUD · 마을 명령 버튼
- **2** 육성 창 · 전직 · 방출
- **3** 기획서 · 세계관
- **4** 마물 · 소환수 · 전투 피해
- **5** 프로젝트 설정 · 문서
- **6** 직업 · 등급 · 능력치 데이터
- **7** 길찾기 · 스모크 테스트
- **8** 맵 합성 · 렌더링

## scripts/job_data.gd

| 줄 | 심볼 | 묶음 | 요약 | 호출함 → / ← 호출됨 |
|---:|---|---|---|---|
| 1 | `job_data.gd` | 직업 · 등급 · 능력치 데이터 | Static data script (RefCounted) defining mercenary stats, grades, promotion tiers/costs and the JOBS table. |  |
| 8 | `STATS` | 직업 · 등급 · 능력치 데이터 | Const list of the five stat keys: str, dex, int, vit, wis. |  |
| 9 | `STAT_NAMES` | 직업 · 등급 · 능력치 데이터 | Const map from stat key to Korean display name (근력, 민첩, 지능, 체질, 정신). |  |
| 12 | `GRADES` | 직업 · 등급 · 능력치 데이터 | Const table of grades (노말/엘리트/히어로/레전더리) with min stat total thresholds 0/56/62/68, colors and level-up growth bonus. |  |
| 20 | `TIER_MULT` | 직업 · 등급 · 능력치 데이터 | Const per-promotion-tier power multiplier [1.0, 1.25, 1.55, 1.9]. |  |
| 21 | `PROMOTE_RESIDUE` | 직업 · 등급 · 능력치 데이터 | Const monster-residue cost per promotion tier [0, 2, 5, 10]. |  |
| 22 | `PROMOTE_GOLD` | 직업 · 등급 · 능력치 데이터 | Const gold cost per promotion tier [0, 50, 120, 250]. |  |
| 24 | `JOBS` | 기획서 · 세계관 | Const dict of jobs (knight, mage, gunner, summoner, healer) with combat style, primary stat, hp/def/range/interval, sprites, perk and 4 tier names with level gates 1/5/10/15. |  |
| 88 | `grade_for_total()` | 직업 · 등급 · 능력치 데이터 | Static func returning the highest GRADES index whose min_total is <= the given stat total. |  |

## scripts/main.gd

| 줄 | 심볼 | 묶음 | 요약 | 호출함 → / ← 호출됨 |
|---:|---|---|---|---|
| 1 | `main.gd` | 프로젝트 설정 · 문서 | 메인 씬 스크립트: 마을 운영(자원·명령), 낮/밤 순환, 균열 웨이브 침공, HUD, 맵 합성, A* 길찾기를 관리한다. |  |
| 6 | `preload consts (Mercenary, Monster, JobData, TOWN_TEX, DUNGEON_TEX)` | HUD · 마을 명령 버튼 | 용병/마물/직업 데이터 스크립트와 Kenney 타일셋 텍스처를 preload한다. |  |
| 12 | `balance consts (WORLD_SIZE, TILE, DAY_LENGTH, HALL_MAX_HP, RECRUIT_COST, WAGE_PER_MERC, MAX_MERCS, TRAIN_SUPPORT_*, VACATION_COST)` | 낮밤 순환 · 웨이브 · 월드 상태 | 월드 크기, 타일 크기, 낮 길이, 영주관 체력, 모집/임금/훈련지원/휴가 비용 등 밸런스 상수. |  |
| 23 | `COL_TEXT / COL_DARK` | HUD · 마을 명령 버튼 | HUD 텍스트색과 어두운 외곽선/테두리 색 상수. |  |
| 26 | `resource state (gold, food, wood, residue, hall_hp, train_bonus)` | HUD · 마을 명령 버튼 | 영지 자원(금화·식량·목재·마물의 잔재), 영주관 체력, 훈련 효율 배수 상태 변수. |  |
| 30 | `cycle state (day, is_night, phase_time, to_spawn, spawn_timer, game_over, elapsed)` | 낮밤 순환 · 웨이브 · 월드 상태 | 낮/밤 순환과 웨이브 스폰 진행, 게임 오버 여부를 담는 상태 변수. |  |
| 40 | `rally/selection state (rally_point, has_rally, placing_rally, selected)` | 낮밤 순환 · 웨이브 · 월드 상태 | 집결 지점 지정 상태와 현재 선택된 용병. |  |
| 46 | `buildings table` | 낮밤 순환 · 웨이브 · 월드 상태 | 건물별 이름·중심·용병 집합 지점(spot)·분산 범위(spread)·이름표 위치 Dictionary. |  |
| 55 | `hall_rect / rifts` | 낮밤 순환 · 웨이브 · 월드 상태 | 영주관 사각형과 마물이 나오는 균열 3곳 좌표. |  |
| 58 | `entity lists (mercs, monsters, summons, log_lines)` | 낮밤 순환 · 웨이브 · 월드 상태 | 살아있는 용병·마물·소환수 목록과 로그 줄 배열. |  |
| 63 | `runtime resources (rng, dungeon_tex, nav AStarGrid2D, static_tex, font_s/m/l)` | 맵 합성 · 렌더링 | 공용 RNG, 던전 텍스처, A* 내비 그리드, 합성된 정적 맵 텍스처, 갈무리 폰트. |  |
| 71 | `HUD widget refs (modulate_node, labels, banner, buttons, growth_panel, dismiss_armed)` | HUD · 마을 명령 버튼 | HUD 라벨·배너·버튼·육성 패널 노드 참조와 방출 확인 상태. |  |
| 86 | `_ready()` | HUD · 마을 명령 버튼 | 폰트 로드, 정적 맵 합성, HUD 구성, 시작 용병 4명(기사·거너·힐러·마법사) 생성. | → _build_hud(), _compose_static(), _load_font(), _show_banner(), _spawn_merc(), add_log() |
| 103 | `_process()` | 낮밤 순환 · 웨이브 · 월드 상태 | 매 프레임 낮/밤 진행, 밤 전환 판정, 조명·HUD 갱신, 다시 그리기. | → _start_night(), _update_hud(), _update_lighting(), _update_night() |
| 118 | `_start_night()` | 낮밤 순환 · 웨이브 · 월드 상태 | 밤을 시작하고 일차에 따른 마물 수를 정해 용병들에게 밤 시작을 알린다. | → _show_banner(), add_log(), on_night_start() / ← _process(), _process(), _process() |
| 129 | `_update_night()` | 낮밤 순환 · 웨이브 · 월드 상태 | 스폰 타이머에 따라 마물(3일마다 엘리트)을 생성하고 모두 처치되면 낮으로 전환. | → _spawn_monster(), _start_day() / ← _process() |
| 140 | `_start_day()` | 낮밤 순환 · 웨이브 · 월드 상태 | 일차 증가, 임금 지급(부족 시 사기 하락), 용병 새벽 처리, 소환수 제거. | → _show_banner(), add_log(), on_dawn() / ← _process(), _update_night() |
| 162 | `_update_lighting()` | 낮밤 순환 · 웨이브 · 월드 상태 | CanvasModulate 색을 낮/노을/밤 목표색으로 보간한다. | ← _process() |
| 173 | `_spawn_merc()` | HUD · 마을 명령 버튼 | 용병 인스턴스를 광장에 생성하고 정체성을 굴린 뒤 친구를 지정해 목록에 추가. | → _show_banner(), add_log(), building_pos(), grade_info(), roll_identity(), title() / ← _on_recruit(), _process(), _process(), _ready() |
| 190 | `_spawn_monster()` | 낮밤 순환 · 웨이브 · 월드 상태 | 무작위 균열 근처에 마물(엘리트 가능)을 생성해 목록에 추가. | → add_log() / ← _update_night() |
| 202 | `on_monster_killed()` | HUD · 마을 명령 버튼 | 마물 처치 보상(금화, 잔재)을 지급하고 마물을 제거한다. | → add_log() / ← take_damage() |
| 213 | `damage_hall()` | HUD · 마을 명령 버튼 | 영주관에 피해를 주고 0이 되면 게임 오버 처리. | → _show_banner(), add_log() / ← _process() |
| 224 | `building_pos()` | 낮밤 순환 · 웨이브 · 월드 상태 | 건물 집합 지점 주변의 걸을 수 있는 무작위 위치를 반환. | → is_walkable() / ← _choose_action(), _spawn_merc() |
| 238 | `_build_nav()` | 맵 합성 · 렌더링 | 40x23 AStarGrid2D를 설정하고 길은 비용 1, 그 외 3, 장애물은 solid로 지정. | ← _compose_static() |
| 253 | `cell_of()` | 길찾기 · 스모크 테스트 | 월드 좌표를 클램프된 16px 격자 셀로 변환. | ← find_path(), is_walkable() |
| 257 | `is_walkable()` | 길찾기 · 스모크 테스트 | 좌표의 셀이 막혀있지 않은지 확인. | → cell_of() / ← _follow(), _follow(), _process(), building_pos() |
| 262 | `find_path()` | 길찾기 · 스모크 테스트 | A*로 두 지점 간 경로(현재 칸 제외)를 반환. | → cell_of() / ← _follow(), _follow() |
| 271 | `_unhandled_input()` | HUD · 마을 명령 버튼 | R 재시작, SPACE 배속, 집결 지점 지정/취소, 클릭으로 용병 선택. | → _on_speed(), add_log(), select() |
| 305 | `_on_recruit()` | HUD · 마을 명령 버튼 | 정원·금화를 확인하고 금화를 써서 무작위 용병 모집. | → _spawn_merc(), add_log() / ← _process() |
| 315 | `_on_rally()` | HUD · 마을 명령 버튼 | 집결 지점 배치 모드로 전환. | → add_log() |
| 320 | `_on_clear_rally()` | HUD · 마을 명령 버튼 | 집결 지점을 해제. | → add_log() |
| 326 | `_on_repair()` | HUD · 마을 명령 버튼 | 목재 20으로 영주관 체력 80 회복. | → add_log() / ← _process() |
| 335 | `_on_upgrade_training()` | HUD · 마을 명령 버튼 | 목재 30으로 훈련 효율 배수 +0.5. | → add_log() |
| 346 | `select()` | 육성 창 · 전직 · 방출 | 용병을 선택하고 육성 패널 표시 여부를 갱신. | ← _on_close_panel(), _process(), _process(), _unhandled_input(), _update_growth_panel(), dis |
| 355 | `train_support()` | HUD · 마을 명령 버튼 | 금화로 선택 용병에게 즉시 경험치 지원. | → add_log(), gain_xp() / ← _on_train_support() |
| 366 | `vacation()` | 낮밤 순환 · 웨이브 · 월드 상태 | 금화로 용병의 기력·사기를 회복시키는 휴가. | → add_log() / ← _on_vacation() |
| 378 | `try_promote()` | 육성 창 · 전직 · 방출 | 레벨·잔재·금화 조건 확인 후 용병 전직 실행. | → _show_banner(), add_log(), next_tier(), promote(), title() / ← _on_promote(), _process() |
| 398 | `dismiss_merc()` | 육성 창 · 전직 · 방출 | 용병을 방출하고 소환수 제거, 친구 관계 해제 및 사기 감소. | → add_log(), clear_summons(), select() / ← _on_dismiss(), _process() |
| 413 | `_on_train_support()` | HUD · 마을 명령 버튼 | 훈련 지원 버튼 콜백: 선택 용병에 train_support. | → train_support() |
| 418 | `_on_vacation()` | HUD · 마을 명령 버튼 | 휴가 버튼 콜백: 선택 용병에 vacation. | → vacation() |
| 423 | `_on_promote()` | HUD · 마을 명령 버튼 | 전직 버튼 콜백: 선택 용병에 try_promote. | → try_promote() |
| 428 | `_on_dismiss()` | 육성 창 · 전직 · 방출 | 방출 버튼 콜백: 두 번 눌러야 방출(확인 단계). | → dismiss_merc() |
| 438 | `_on_close_panel()` | HUD · 마을 명령 버튼 | 육성 패널 닫기(선택 해제). | → select() |
| 442 | `_build_growth_panel()` | HUD · 마을 명령 버튼 | 육성 패널(RichTextLabel + 훈련/휴가/전직/방출/닫기 버튼) 생성. | → _add_button(), _box() / ← _build_hud() |
| 474 | `_growth_bbcode()` | 육성 창 · 전직 · 방출 | 선택 용병의 등급·능력치·전투수치·성격·상태·다음 전직 정보를 BBCode 문자열로 생성. | → grade_info(), job(), next_tier(), stat_total(), title(), trait_text(), xp_needed() / ← _update_growth_panel() |
| 509 | `_update_growth_panel()` | 육성 창 · 전직 · 방출 | 육성 패널 텍스트와 전직/방출 버튼 상태를 갱신. | → _growth_bbcode(), next_tier(), select() / ← _update_hud() |
| 525 | `_on_speed()` | HUD · 마을 명령 버튼 | Engine.time_scale을 1배/2배로 토글. | ← _unhandled_input() |
| 532 | `add_log()` | HUD · 마을 명령 버튼 | 로그 줄을 추가하고 최근 4줄만 로그 라벨에 표시. | ← _on_clear_rally(), _on_rally(), _on_recruit(), _on_repair(), _on_upgrade_training(), _read |
| 540 | `_load_font()` | HUD · 마을 명령 버튼 | 픽셀 폰트를 안티앨리어싱 없이 로드. | ← _ready() |
| 549 | `_box()` | HUD · 마을 명령 버튼 | 배경·테두리 색으로 StyleBoxFlat 생성. | ← _build_growth_panel(), _make_theme() |
| 559 | `_make_theme()` | HUD · 마을 명령 버튼 | 버튼·라벨·RichTextLabel·패널용 UI Theme 생성. | → _box() / ← _build_hud() |
| 581 | `_build_hud()` | HUD · 마을 명령 버튼 | CanvasLayer HUD: 상하단 패널, 라벨, 배너, 명령 버튼 메뉴, 육성 패널 구성. | → _add_button(), _build_growth_panel(), _make_label(), _make_theme() / ← _ready() |
| 629 | `_make_label()` | HUD · 마을 명령 버튼 | 위치·크기 지정된 클리핑 Label 생성. | ← _build_hud() |
| 638 | `_add_button()` | HUD · 마을 명령 버튼 | 텍스트와 콜백이 연결된 Button 생성 후 부모에 추가. | ← _build_growth_panel(), _build_hud() |
| 647 | `_show_banner()` | HUD · 마을 명령 버튼 | 중앙 배너 텍스트를 표시하고(고정 아니면) 트윈으로 페이드아웃. | ← _ready(), _spawn_merc(), _start_day(), _start_night(), damage_hall(), try_promote() |
| 659 | `_update_hud()` | 육성 창 · 전직 · 방출 | 상단 자원/페이즈 라벨, 선택 용병 정보 라벨, 육성 패널 갱신. | → _update_growth_panel(), describe() / ← _process() |
| 677 | `tile_src() (static)` | 맵 합성 · 렌더링 | 12열 타일시트 인덱스를 16px 소스 Rect2i로 변환. | ← _draw(), _draw(), _draw(), _stamp() |
| 681 | `_stamp()` | 맵 합성 · 렌더링 | 타일 하나를 이미지 격자 위치에 블렌드. | → tile_src() (static) / ← _compose_static(), _stamp_block() |
| 685 | `_stamp_block()` | 맵 합성 · 렌더링 | 2차원 타일 인덱스 배열을 블록 단위로 찍는다. | → _stamp() / ← _compose_static() |
| 692 | `_compose_static()` | 맵 합성 · 렌더링 | 잔디·길·광장·밭·건물·숲을 한 장의 이미지로 합성하고 길/장애물로 내비 그리드 생성. | → _build_nav(), _stamp(), _stamp_block() / ← _ready() |
| 773 | `_draw()` | 낮밤 순환 · 웨이브 · 월드 상태 | 정적 맵, 균열 이펙트, 건물 이름표, 영주관 체력바, 집결 지점 그리기. | → _draw_text() |
| 805 | `_draw_text()` | 낮밤 순환 · 웨이브 · 월드 상태 | 가운데 정렬 외곽선 텍스트 그리기. | ← _draw() |

## scripts/mercenary.gd

| 줄 | 심볼 | 묶음 | 요약 | 호출함 → / ← 호출됨 |
|---:|---|---|---|---|
| 1 | `mercenary.gd` | 프로젝트 설정 · 문서 | 쪼꼬미 용병 스크립트: 탄생 시 직업·능력치·등급·성격 결정, 낮 유틸리티 AI 생활, 밤 직업별 전투, 경로 이동, 그리기. |  |
| 6 | `preload consts (JobData, Summon)` | 낮밤 순환 · 웨이브 · 월드 상태 | 직업 데이터와 소환수 스크립트 preload. |  |
| 9 | `NAMES` | 육성 창 · 전직 · 방출 | 용병 이름 후보 목록. |  |
| 13 | `TRAIT_GROUPS` | 육성 창 · 전직 · 방출 | 상호 배타 성격 특성 묶음(근면/게으름, 겁쟁이/용맹, 동료애/대식가). |  |
| 15 | `ACTION_PLACE` | 낮밤 순환 · 웨이브 · 월드 상태 | 낮 행동 → 건물 키 매핑. |  |
| 17 | `ACTION_LABEL` | 낮밤 순환 · 웨이브 · 월드 상태 | 낮 행동 → 표시 이름 매핑. |  |
| 20 | `identity state (game, merc_name, job_id, tier, grade, stats, traits, friend)` | 육성 창 · 전직 · 방출 | main 참조와 용병 정체성(이름·직업·전직 단계·등급·능력치·특성·친구). |  |
| 29 | `combat/needs state (max_hp, hp, atk, defense, attack_range, attack_interval, move_speed, heal_power, energy, hunger, morale, level, xp, downed, summons)` | 낮밤 순환 · 웨이브 · 월드 상태 | 전투 수치, 욕구(기력·허기·사기), 레벨/경험치, 쓰러짐, 보유 소환수. |  |
| 45 | `behavior/move/render state (activity, action, target_pos, doing_time, attack_cd, flash_*, splash_*, sprite_index, facing, path, repath_cd)` | 길찾기 · 스모크 테스트 | 현재 행동, 이동 목표·경로, 공격 쿨다운, 이펙트와 스프라이트 상태. |  |
| 69 | `roll_identity()` | 육성 창 · 전직 · 방출 | 이름·직업·능력치(정규분포)·등급·성격·스프라이트를 무작위로 결정하고 수치 계산. | → job(), recalc(), stat_total() / ← _initialize(), _spawn_merc() |
| 97 | `job()` | 육성 창 · 전직 · 방출 | 현재 직업의 JobData.JOBS 항목 반환. | ← _growth_bbcode(), gain_xp(), next_tier(), recalc(), roll_identity(), style(), title() |
| 101 | `style()` | 육성 창 · 전직 · 방출 | 직업 전투 방식(melee/ranged/aoe/heal/summon) 반환. | → job() / ← _attack(), _night(), _process(), on_night_start(), recalc() |
| 105 | `title()` | 육성 창 · 전직 · 방출 | 현재 전직 단계 직함 반환. | → job() / ← _growth_bbcode(), _process(), _spawn_merc(), describe(), job_name(), try_promote() |
| 109 | `job_name()` | 육성 창 · 전직 · 방출 | title()의 별칭. | → title() |
| 113 | `grade_info()` | 육성 창 · 전직 · 방출 | 등급 정보(이름·색·성장) 반환. | ← _draw(), _growth_bbcode(), _spawn_merc(), describe(), gain_xp() |
| 117 | `stat_total()` | 육성 창 · 전직 · 방출 | 능력치 합계 계산. | ← _growth_bbcode(), _process(), roll_identity() |
| 124 | `has_trait()` | 낮밤 순환 · 웨이브 · 월드 상태 | 특정 성격 특성 보유 여부. | ← _choose_action(), _day(), _night(), _pick_target(), recalc(), take_damage() |
| 128 | `trait_text()` | 육성 창 · 전직 · 방출 | 특성 목록을 쉼표 문자열로 반환. | ← _growth_bbcode() |
| 133 | `recalc()` | 육성 창 · 전직 · 방출 | 능력치·레벨·전직 배수로 체력·공격·방어·사거리·공속·이속·치유력 재계산. | → has_trait(), job(), style() / ← gain_xp(), promote(), roll_identity() |
| 153 | `xp_needed()` | 육성 창 · 전직 · 방출 | 다음 레벨까지 필요 경험치(20×레벨). | ← _growth_bbcode(), gain_xp() |
| 158 | `next_tier()` | 육성 창 · 전직 · 방출 | 다음 전직의 이름·레벨·잔재·금화 조건 반환(없으면 빈 Dictionary). | → job() / ← _growth_bbcode(), _update_growth_panel(), gain_xp(), try_promote() |
| 166 | `promote()` | 육성 창 · 전직 · 방출 | 전직 단계 증가, 수치 재계산, 체력 회복, 사기 상승. | → recalc() / ← try_promote() |
| 173 | `describe()` | 육성 창 · 전직 · 방출 | HUD 정보용 한 줄 설명. | → grade_info(), title() / ← _update_hud() |
| 179 | `_process()` | 낮밤 순환 · 웨이브 · 월드 상태 | 쿨다운·이펙트 타이머 감소 후 쓰러짐/밤/낮에 따라 행동 분기. | → _day(), _night() |
| 198 | `_day()` | 낮밤 순환 · 웨이브 · 월드 상태 | 낮 생활: 욕구 변화, 행동 선택·이동, 휴식/식사/훈련/농사/벌목/수다 효과 적용. | → _choose_action(), _move_to(), gain_xp(), has_trait() / ← _process() |
| 238 | `_choose_action()` | 낮밤 순환 · 웨이브 · 월드 상태 | 욕구·성격·자원 상황으로 행동 점수를 매겨 유틸리티 AI로 행동 선택. | → building_pos(), has_trait() / ← _day() |
| 266 | `on_night_start()` | 낮밤 순환 · 웨이브 · 월드 상태 | 소환형 직업이면 밤 시작 시 소환수를 불러낸다. | → add_log(), style() / ← _start_night() |
| 282 | `clear_summons()` | 낮밤 순환 · 웨이브 · 월드 상태 | 자신의 소환수를 모두 제거. | ← dismiss_merc(), on_dawn() |
| 290 | `_night()` | 낮밤 순환 · 웨이브 · 월드 상태 | 밤 전투: 저체력 후퇴, 힐러 치유, 목표 선택·추격·공격, 없으면 집결/경계. | → _attack(), _move_to(), _pick_target(), _try_heal(), has_trait(), style() / ← _process() |
| 324 | `_attack()` | 낮밤 순환 · 웨이브 · 월드 상태 | 직업 방식별 공격(광역 스플래시 등)과 이펙트 설정 후 피해 적용. | → style() / ← _night() |
| 348 | `_pick_target()` | 낮밤 순환 · 웨이브 · 월드 상태 | 동료애면 친구 근처 마물 우선, 아니면 집결점/자기 기준 가장 가까운 마물 선택. | → has_trait() / ← _night() |
| 367 | `_try_heal()` | 낮밤 순환 · 웨이브 · 월드 상태 | 부상 용병 중 가장 위급한 대상을 치유(2단계 이상 2명). | → _move_to(), gain_xp() / ← _night() |
| 395 | `take_damage()` | 마물 · 소환수 · 전투 피해 | 방어 감쇠 피해와 사기 하락, 쓰러짐 처리 및 친구 사기 하락. | → add_log(), has_trait() / ← _process() |
| 412 | `gain_xp()` | 육성 창 · 전직 · 방출 | 경험치 획득, 레벨업 시 등급 성장치로 능력치 상승 및 전직 가능 알림. | → add_log(), grade_info(), job(), next_tier(), recalc(), xp_needed() / ← _day(), _process(), _try_heal(), gain_xp(), take_damage(), train_support() |
| 430 | `on_dawn()` | 낮밤 순환 · 웨이브 · 월드 상태 | 새벽: 소환수 제거, 쓰러짐 부활(30% 체력), 기력 감소, 행동 초기화. | → clear_summons() / ← _start_day() |
| 442 | `_move_to()` | 낮밤 순환 · 웨이브 · 월드 상태 | 기력에 따른 속도로 목표 지점 이동. | → _follow() / ← _day(), _night(), _try_heal() |
| 449 | `_follow()` | 길찾기 · 스모크 테스트 | A* 경로를 (0.4초 간격 재탐색) 따라 이동하고 방향 갱신. | → find_path(), is_walkable() / ← _move_to() |
| 471 | `_draw()` | 맵 합성 · 렌더링 | 스프라이트·등급 그림자·전직 점·선택 테두리·체력바·공격 이펙트·행동 이름 그리기. | → grade_info(), tile_src() (static) |

## scripts/monster.gd

| 줄 | 심볼 | 묶음 | 요약 | 호출함 → / ← 호출됨 |
|---:|---|---|---|---|
| 1 | `monster.gd` | 마물 · 소환수 · 전투 피해 | Node2D rift monster (remnant of time) that attacks nearby mercenaries/summons or marches on the lord's hall, with pathfinding and elite variants. |  |
| 6 | `NORMAL_SPRITES` | 마물 · 소환수 · 전투 피해 | Const list of Kenney Tiny Dungeon tile indices for normal monsters. |  |
| 7 | `ELITE_SPRITES` | 마물 · 소환수 · 전투 피해 | Const list of tile indices for elite monsters. |  |
| 27 | `setup()` | 마물 · 소환수 · 전투 피해 | Scales hp/atk/speed/reward by day and applies elite multipliers (x5 hp, x2 atk, x0.7 speed, 2x size) plus sprite choice. |  |
| 44 | `_process()` | 마물 · 소환수 · 전투 피해 | Per-frame AI: picks nearest merc/summon target (preferring taunting tier>=1 melee knights within 50), moves/attacks it, else attacks the lord's hall. | → _move_to(), damage_hall(), style(), take_damage(), take_damage() |
| 83 | `_move_to()` | 마물 · 소환수 · 전투 피해 | Moves toward a point at monster speed by delegating to _follow. | → _follow() / ← _process() |
| 87 | `_follow()` | 마물 · 소환수 · 전투 피해 | Path-following movement that repaths via game.find_path every 0.4s when the goal changes and avoids unwalkable targets. | → find_path(), is_walkable() / ← _move_to() |
| 106 | `take_damage()` | 마물 · 소환수 · 전투 피해 | Applies damage; on death grants XP to the attacker (20 elite / 4 normal) and notifies game.on_monster_killed. | → gain_xp(), gain_xp(), on_monster_killed() / ← _process() |
| 117 | `_draw()` | 맵 합성 · 렌더링 | Draws shadow, hop-animated tinted sprite (2x for elites) and hp bar. | → tile_src() (static) |

## scripts/summon.gd

| 줄 | 심볼 | 묶음 | 요약 | 호출함 → / ← 호출됨 |
|---:|---|---|---|---|
| 1 | `summon.gd` | 마물 · 소환수 · 전투 피해 | Node2D spirit summoned nightly by a summoner; flies through buildings, fights monsters near its summoner, vanishes at dawn. |  |
| 5 | `SPRITES` | 마물 · 소환수 · 전투 피해 | Const tile indices for summon sprites, chosen by summoner tier. |  |
| 21 | `setup()` | 마물 · 소환수 · 전투 피해 | Sets summon hp/atk from summoner intelligence, level and tier and picks the tier sprite. |  |
| 28 | `_process()` | 마물 · 소환수 · 전투 피해 | Per-frame AI: targets nearest monster within 140 of the summoner, moves to and attacks it, else returns home. | → _move(), take_damage() |
| 57 | `_move()` | 마물 · 소환수 · 전투 피해 | Straight-line movement (no pathfinding) toward a point, updating facing. | ← _process() |
| 63 | `take_damage()` | 마물 · 소환수 · 전투 피해 | Applies damage; on death removes itself from game.summons and the summoner's list and frees itself. | ← _process() |
| 74 | `gain_xp()` | 마물 · 소환수 · 전투 피해 | Forwards XP earned from kills to the owning summoner. | → gain_xp() / ← take_damage() |
| 79 | `_draw()` | 맵 합성 · 렌더링 | Draws the floating translucent spirit sprite and hp bar. | → tile_src() (static) |

## tests/growth_test.gd

| 줄 | 심볼 | 묶음 | 요약 | 호출함 → / ← 호출됨 |
|---:|---|---|---|---|
| 1 | `growth_test.gd` | 직업 · 등급 · 능력치 데이터 | Headless SceneTree test for the growth system: grade distribution, level-up, promotion, dismissal, summons. |  |
| 13 | `check()` | 직업 · 등급 · 능력치 데이터 | Prints PASS/FAIL for a condition and counts failures. | ← _initialize(), _process() |
| 19 | `_initialize()` | 직업 · 등급 · 능력치 데이터 | Rolls 3000 mercenary identities to verify grade rarity and job coverage, then instantiates main.tscn. | → check(), roll_identity() |
| 45 | `_process()` | 육성 창 · 전직 · 방출 | After 3 frames tests level-up via XP, promotion gating/costs, dismissal cleanup, and summoner summons across night/day. | → _spawn_merc(), _start_day(), _start_night(), check(), dismiss_merc(), gain_xp(), select(), |

## tests/screenshot.gd

| 줄 | 심볼 | 묶음 | 요약 | 호출함 → / ← 호출됨 |
|---:|---|---|---|---|
| 1 | `screenshot.gd` | 프로젝트 설정 · 문서 | Windowed SceneTree script that renders the game and saves day.png and night.png to an output folder. |  |
| 11 | `_initialize()` | 프로젝트 설정 · 문서 | Reads output dir from user cmdline args and instantiates main.tscn. |  |
| 19 | `_process()` | 프로젝트 설정 · 문서 | Frame-scripted scenario: spawns a summoner, selects a merc, saves day shot, starts night at 2x speed, saves night shot, quits. | → _save(), _spawn_merc(), _start_night(), select() |
| 38 | `_save()` | 프로젝트 설정 · 문서 | Captures the root viewport image and saves it as PNG. | ← _process() |

## tests/smoke_test.gd

| 줄 | 심볼 | 묶음 | 요약 | 호출함 → / ← 호출됨 |
|---:|---|---|---|---|
| 1 | `smoke_test.gd` | 길찾기 · 스모크 테스트 | Headless smoke test running the main scene at 10x speed for several days, imitating a lord and checking pathfinding validity. |  |
| 5 | `TARGET_DAY` | 길찾기 · 스모크 테스트 | Const day count (4) at which the smoke test ends. |  |
| 6 | `MAX_FRAMES` | 길찾기 · 스모크 테스트 | Const frame cap (8000) for the smoke test. |  |
| 18 | `_initialize()` | 프로젝트 설정 · 문서 | Sets Engine.time_scale to 10 and instantiates main.tscn. |  |
| 24 | `_process()` | 길찾기 · 스모크 테스트 | Auto-recruits/repairs by day, counts units standing on unwalkable tiles, and evaluates PASS criteria (>=4 mercs, night seen, monsters, day>=2, blocked<1%). | → _on_recruit(), _on_repair(), _report(), is_walkable() |
| 57 | `_report()` | 길찾기 · 스모크 테스트 | Prints a status line with day/night, hall hp, resources, residue, monster count and each merc's activity/level. | ← _process() |
