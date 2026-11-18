# 아그라 전기 — 코드 맵 (graphify 자동 생성)

줄 번호는 graph 생성 시점 기준. 코드를 고친 뒤에는 `/graphify --update`로 갱신할 것.

## 커뮤니티 (기능 묶음)

- **0** 마을 운영 · HUD · 육성 창
- **1** 쪼꼬미 생활 AI · 전투 · 이동
- **2** 기획서 · 세계관
- **3** 맵 합성 · 길찾기 · 외형 시트
- **4** 직업 · 등급 · 능력치 데이터
- **5** 에셋 크레딧 · SRW 팩 · 외형 배정
- **6** 프로젝트 설정 · 구조
- **7** 렌더링 · UI 테마 · 그림 불러오기
- **8** 헤드리스 테스트
- **9** 스크린샷 테스트
- **10** char_sprites.gd (단독)
- **11** char_sprites.gd: _cache (단독)
- **12** char_sprites.gd: PACK_DIR / FRAME / Dir  (단독)
- **13** main.gd: cycle state (day, is_night, pha (단독)
- **14** map_art.gd: PACK / TILE (단독)
- **15** map_art.gd: _sheets / _own_tex caches (단독)
- **16** mercenary.gd: combat/needs state (max_hp (단독)
- **17** mercenary.gd: identity state (game, merc (단독)
- **18** mercenary.gd: preload consts (JobData, S (단독)
- **19** monster.gd: MapArt preload (단독)
- **20** monster.gd: state vars (game, max_hp, hp (단독)
- **21** summon.gd: MapArt preload (단독)
- **22** summon.gd: state vars (game, summoner, m (단독)
- **23** growth_test.gd: CharSprites (preload) (단독)
- **24** growth_test.gd: frames (단독)
- **25** growth_test.gd: JobData (preload) (단독)
- **26** growth_test.gd: main (단독)
- **27** growth_test.gd: Mercenary (preload) (단독)
- **28** screenshot.gd: frames (단독)
- **29** screenshot.gd: main (단독)

## scripts/char_sprites.gd

| 줄 | 심볼 | 묶음 | 요약 | 호출함 → / ← 호출됨 |
|---:|---|---|---|---|
| 1 | `char_sprites.gd` | char_sprites.gd (단독) | Super Retro World 캐릭터 팩 외형을 고르고 불러오는 정적 도우미. |  |
| 9 | `PACK_DIR / FRAME / Dir / WALK` | char_sprites.gd: PACK_DIR / FRAME / Dir  (단독) | 캐릭터 팩 경로, 칸 크기, 방향 열거형, 걷기 프레임 순서. |  |
| 15 | `CHARS` | 에셋 크레딧 · SRW 팩 · 외형 배정 | 캐릭터 번호별 성별과 어울리는 직업 표. |  |
| 34 | `_cache` | char_sprites.gd: _cache (단독) | 불러온 캐릭터 시트 텍스처 캐시. |  |
| 37 | `path_of()` | 맵 합성 · 길찾기 · 외형 시트 | 캐릭터 번호의 시트 PNG 경로를 만든다. | ← available(), sheet() |
| 41 | `available()` | 에셋 크레딧 · SRW 팩 · 외형 배정 | 캐릭터 팩이 설치되어 있는지 확인한다. | → path_of() / ← _initialize(), pick(), roll_identity() |
| 46 | `pick()` | 에셋 크레딧 · SRW 팩 · 외형 배정 | 직업·성별에 맞고 겹치지 않는 캐릭터 번호를 고른다. | → available() / ← _initialize(), roll_identity() |
| 61 | `gender_of()` | 에셋 크레딧 · SRW 팩 · 외형 배정 | 캐릭터 번호의 성별을 돌려준다. |  |
| 66 | `sheet()` | 맵 합성 · 길찾기 · 외형 시트 | import 없이 PNG를 직접 읽어 캐릭터 시트 텍스처를 캐시해 돌려준다. | → path_of() / ← _draw() |
| 75 | `frame_rect()` | 맵 합성 · 길찾기 · 외형 시트 | 방향과 열로 시트 안 프레임 영역을 계산한다. | ← _draw() |

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
| 88 | `grade_for_total()` | 직업 · 등급 · 능력치 데이터 | Static func returning the highest GRADES index whose min_total is <= the given stat total. | ← roll_identity() |

## scripts/main.gd

| 줄 | 심볼 | 묶음 | 요약 | 호출함 → / ← 호출됨 |
|---:|---|---|---|---|
| 1 | `main.gd` | 프로젝트 설정 · 구조 | 마을 운영·낮밤 순환·균열 웨이브 침공을 관리하는 메인 씬 스크립트. |  |
| 6 | `preload consts (Mercenary, Monster, JobData, MapArt, TOWN_TEX, DUNGEON_TEX)` | 맵 합성 · 길찾기 · 외형 시트 | 용병·마물·직업 데이터·MapArt 스크립트와 Kenney 타일셋 텍스처를 미리 불러온다. |  |
| 13 | `balance consts (WORLD_SIZE, TILE, DAY_LENGTH, HALL_MAX_HP, RECRUIT_COST, WAGE_PER_MERC, MAX_MERCS, TRAIN_SUPPORT_*, VACATION_COST)` | 마을 운영 · HUD · 육성 창 | 월드 크기·타일 크기·낮 길이·비용 등 밸런스 상수를 정의한다. |  |
| 24 | `COL_TEXT / COL_DARK` | 렌더링 · UI 테마 · 그림 불러오기 | UI 글자색과 외곽선용 어두운 색을 정의한다. |  |
| 27 | `resource state (gold, food, wood, residue, hall_hp, train_bonus)` | 마을 운영 · HUD · 육성 창 | 금화·식량·목재·잔재·영주관 체력·훈련 보너스 자원 상태 변수. |  |
| 31 | `cycle state (day, is_night, phase_time, to_spawn, spawn_timer, game_over, elapsed)` | main.gd: cycle state (day, is_night, pha (단독) | 일차·밤 여부·경과 시간·남은 소환 수 등 낮밤 순환 상태 변수. |  |
| 41 | `rally/selection state (rally_point, has_rally, placing_rally, selected)` | 쪼꼬미 생활 AI · 전투 · 이동 | 집결 지점과 선택된 용병 상태 변수. |  |
| 47 | `buildings table` | 렌더링 · UI 테마 · 그림 불러오기 | 건물별 이름·중심·모이는 자리·범위·이름표 위치를 담은 사전. |  |
| 56 | `hall_rect / rifts` | 렌더링 · UI 테마 · 그림 불러오기 | 영주관 영역 사각형과 균열 3곳의 위치. |  |
| 59 | `entity lists (mercs, monsters, summons, log_lines)` | 마을 운영 · HUD · 육성 창 | 용병·마물·소환수 목록과 로그 줄 목록. |  |
| 64 | `runtime resources (rng, dungeon_tex, nav AStarGrid2D, static_tex, font_s/m/l)` | 맵 합성 · 길찾기 · 외형 시트 | 난수기·길찾기 격자·합성된 정적 맵 텍스처·폰트 등 실행 중 자원. |  |
| 72 | `HUD widget refs (modulate_node, labels, banner, buttons, growth_panel, dismiss_armed)` | 직업 · 등급 · 능력치 데이터 | 조명 모듈레이트·HUD 라벨·배너·버튼·육성 창 위젯 참조. |  |
| 88 | `_ready()` | 마을 운영 · HUD · 육성 창 | 폰트·맵·HUD를 준비하고 고정 편성 용병 4명을 생성한다. | → _build_hud(), _compose_static(), _load_font(), _show_banner(), _spawn_merc(), add_log() |
| 105 | `_process()` | 직업 · 등급 · 능력치 데이터 | 매 프레임 낮밤 진행·조명·HUD를 갱신하고 다시 그린다. | → _draw(), _start_night(), _update_hud(), _update_lighting(), _update_night() |
| 120 | `_start_night()` | 마을 운영 · HUD · 육성 창 | 밤으로 전환해 소환할 마물 수를 정하고 용병에게 밤 시작을 알린다. | → _show_banner(), add_log(), on_night_start() / ← _process(), _process(), _process() |
| 131 | `_update_night()` | 마을 운영 · HUD · 육성 창 | 밤 동안 간격마다 마물을 소환하고 모두 처치되면 낮을 시작한다. | → _spawn_monster(), _start_day() / ← _process() |
| 142 | `_start_day()` | 마을 운영 · HUD · 육성 창 | 새벽에 일차를 올리고 임금을 지급(체불 시 사기 하락)하며 소환수를 정리한다. | → _show_banner(), add_log(), on_dawn() / ← _process(), _update_night() |
| 164 | `_update_lighting()` | 직업 · 등급 · 능력치 데이터 | 낮·노을·밤에 맞춰 화면 색조를 부드럽게 보간한다. | ← _process() |
| 175 | `_spawn_merc()` | 마을 운영 · HUD · 육성 창 | 광장에 용병을 만들어 신원을 굴리고 친구를 정해 목록에 추가한다. | → _show_banner(), add_log(), building_pos(), grade_info(), roll_identity(), title() / ← _on_recruit(), _process(), _process(), _ready() |
| 192 | `_spawn_monster()` | 마을 운영 · HUD · 육성 창 | 무작위 균열 근처에 (엘리트) 마물을 생성한다. | → add_log(), setup() / ← _process(), _update_night() |
| 204 | `on_monster_killed()` | 마을 운영 · HUD · 육성 창 | 처치된 마물을 제거하고 금화·마물의 잔재 보상을 준다. | → add_log() / ← take_damage() |
| 215 | `damage_hall()` | 마을 운영 · HUD · 육성 창 | 영주관에 피해를 주고 0이 되면 게임 오버 처리한다. | → _show_banner(), add_log() / ← _process() |
| 226 | `building_pos()` | 쪼꼬미 생활 AI · 전투 · 이동 | 건물 모임 자리 주변에서 걸을 수 있는 무작위 위치를 고른다. | → is_walkable() / ← _choose_action(), _spawn_merc() |
| 240 | `_build_nav()` | 맵 합성 · 길찾기 · 외형 시트 | 16px 격자 A*를 구성해 길은 비용 1, 그 외 3, 막힌 칸은 solid로 설정한다. | ← _compose_srw(), _compose_static() |
| 255 | `cell_of()` | 쪼꼬미 생활 AI · 전투 · 이동 | 월드 좌표를 격자 칸 좌표로 변환한다. | ← find_path(), is_walkable() |
| 259 | `is_walkable()` | 쪼꼬미 생활 AI · 전투 · 이동 | 해당 위치의 칸이 막혀 있지 않은지 확인한다. | → cell_of() / ← _follow(), _follow(), _process(), building_pos() |
| 264 | `find_path()` | 쪼꼬미 생활 AI · 전투 · 이동 | A* 경로를 구하고 현재 칸인 첫 점을 뺀 점 목록을 돌려준다. | → cell_of() / ← _follow(), _follow(), _move_to() |
| 273 | `_unhandled_input()` | 마을 운영 · HUD · 육성 창 | 재시작·배속 키와 집결 지점 지정·용병 선택 클릭을 처리한다. | → _on_speed(), add_log(), select() |
| 307 | `_on_recruit()` | 마을 운영 · HUD · 육성 창 | 인원·금화를 확인하고 금화를 써서 새 용병을 모집한다. | → _spawn_merc(), add_log() / ← _process() |
| 317 | `_on_rally()` | 마을 운영 · HUD · 육성 창 | 집결 지점 지정 모드로 들어간다. | → add_log() |
| 322 | `_on_clear_rally()` | 마을 운영 · HUD · 육성 창 | 집결 지점을 해제한다. | → add_log() |
| 328 | `_on_repair()` | 마을 운영 · HUD · 육성 창 | 목재 20으로 영주관 내구도를 80 회복한다. | → add_log() / ← _process() |
| 337 | `_on_upgrade_training()` | 마을 운영 · HUD · 육성 창 | 목재 30으로 훈련 효율 보너스를 0.5 올린다. | → add_log() |
| 348 | `select()` | 마을 운영 · HUD · 육성 창 | 용병을 선택하고 육성 창 표시 여부를 바꾼다. | ← _on_close_panel(), _process(), _process(), _unhandled_input(), _update_growth_panel(), dis |
| 357 | `train_support()` | 마을 운영 · HUD · 육성 창 | 금화로 집중 훈련을 지원해 즉시 경험치를 준다. | → add_log(), gain_xp() / ← _on_train_support() |
| 368 | `vacation()` | 마을 운영 · HUD · 육성 창 | 금화로 휴가를 줘 기력·사기를 회복시킨다. | → add_log() / ← _on_vacation() |
| 380 | `try_promote()` | 마을 운영 · HUD · 육성 창 | 레벨·잔재·금화 조건을 확인하고 충족 시 용병을 전직시킨다. | → _show_banner(), add_log(), next_tier(), promote(), title() / ← _on_promote(), _process() |
| 400 | `dismiss_merc()` | 마을 운영 · HUD · 육성 창 | 용병을 방출하고 소환수·친구 관계를 정리한다. | → add_log(), clear_summons(), select() / ← _on_dismiss(), _process() |
| 415 | `_on_train_support()` | 마을 운영 · HUD · 육성 창 | 선택된 용병에게 훈련 지원 버튼 동작을 실행한다. | → train_support() |
| 420 | `_on_vacation()` | 마을 운영 · HUD · 육성 창 | 선택된 용병에게 휴가 버튼 동작을 실행한다. | → vacation() |
| 425 | `_on_promote()` | 마을 운영 · HUD · 육성 창 | 선택된 용병의 전직을 시도한다. | → try_promote() |
| 430 | `_on_dismiss()` | 마을 운영 · HUD · 육성 창 | 두 번 눌러 확인한 뒤 선택된 용병을 방출한다. | → dismiss_merc() |
| 440 | `_on_close_panel()` | 마을 운영 · HUD · 육성 창 | 선택을 해제해 육성 창을 닫는다. | → select() |
| 444 | `_build_growth_panel()` | 마을 운영 · HUD · 육성 창 | 자체 그림 테두리 패널에 육성 정보 텍스트와 버튼 격자를 만든다. | → _add_button(), _frame() / ← _build_hud() |
| 476 | `_growth_bbcode()` | 직업 · 등급 · 능력치 데이터 | 용병의 등급·능력치·상태·다음 전직 조건을 BBCode 문자열로 만든다. | → grade_info(), job(), next_tier(), stat_total(), title(), trait_text(), xp_needed() / ← _update_growth_panel() |
| 511 | `_update_growth_panel()` | 직업 · 등급 · 능력치 데이터 | 육성 창 텍스트가 바뀌었을 때만 갱신하고 전직·방출 버튼 상태를 맞춘다. | → _growth_bbcode(), next_tier(), select() / ← _update_hud() |
| 527 | `_on_speed()` | 마을 운영 · HUD · 육성 창 | 게임 속도를 1배/2배로 전환한다. | ← _unhandled_input() |
| 534 | `add_log()` | 마을 운영 · HUD · 육성 창 | 로그 줄을 추가하고 최근 4줄만 표시한다. | ← _on_clear_rally(), _on_rally(), _on_recruit(), _on_repair(), _on_upgrade_training(), _read |
| 542 | `_load_font()` | 마을 운영 · HUD · 육성 창 | 픽셀 폰트를 안티앨리어싱·힌팅 없이 불러온다. | ← _ready() |
| 552 | `_frame()` | 렌더링 · UI 테마 · 그림 불러오기 | 자체 그림 UI 테두리를 9칸 늘림 StyleBoxTexture로 만들고 tint를 적용한다. | → own_tex() / ← _build_growth_panel(), _make_theme() |
| 564 | `_make_theme()` | 렌더링 · UI 테마 · 그림 불러오기 | 버튼·라벨·패널·RichTextLabel용 자체 그림 테마를 만든다. | → _frame() / ← _build_hud() |
| 587 | `_build_hud()` | 마을 운영 · HUD · 육성 창 | 상·하단 패널, 자원 아이콘 줄, 로그·정보·배너 라벨, 명령 메뉴와 육성 창을 만든다. | → _add_button(), _build_growth_panel(), _make_label(), _make_theme(), own_tex() / ← _ready() |
| 649 | `_make_label()` | 마을 운영 · HUD · 육성 창 | 위치·크기를 지정한 클릭 무시 라벨을 만든다. | ← _build_hud() |
| 658 | `_add_button()` | 마을 운영 · HUD · 육성 창 | 콜백이 연결된 버튼을 만들어 부모에 붙인다. | ← _build_growth_panel(), _build_hud() |
| 667 | `_show_banner()` | 마을 운영 · HUD · 육성 창 | 화면 중앙 배너를 표시하고 sticky가 아니면 서서히 사라지게 한다. | ← _ready(), _spawn_merc(), _start_day(), _start_night(), damage_hall(), try_promote() |
| 679 | `_update_hud()` | 직업 · 등급 · 능력치 데이터 | 일차·낮밤·영주관·자원·선택 정보 HUD를 갱신한다. | → _update_growth_panel(), describe() / ← _process() |
| 700 | `tile_src() (static)` | 맵 합성 · 길찾기 · 외형 시트 | 타일셋 인덱스를 원본 이미지 영역으로 변환한다. | ← _draw(), _stamp() |
| 704 | `_stamp()` | 맵 합성 · 길찾기 · 외형 시트 | 타일 하나를 맵 이미지의 칸 위치에 합성한다. | → tile_src() (static) / ← _compose_static(), _stamp_block() |
| 708 | `_stamp_block()` | 맵 합성 · 길찾기 · 외형 시트 | 타일 인덱스 2차원 배열을 블록으로 맵에 찍는다. | → _stamp() / ← _compose_static() |
| 717 | `_place_buildings()` | 맵 합성 · 길찾기 · 외형 시트 | 영주관·여관·식당 자체 그림을 발밑 기준으로 합성하고 차지한 칸을 막는다. | → own() / ← _compose_srw(), _compose_static() |
| 731 | `_stamp_own()` | 맵 합성 · 길찾기 · 외형 시트 | 자체 그림 띠에서 한 프레임을 발밑 기준으로 맵에 찍는다. | → own() / ← _compose_srw() |
| 736 | `_road_cells()` | 맵 합성 · 길찾기 · 외형 시트 | 길찾기 비용 1인 큰길·샛길 칸 목록을 돌려준다. | ← _compose_srw(), _compose_static() |
| 755 | `_compose_srw()` | 맵 합성 · 길찾기 · 외형 시트 | Super Retro World 타일로 잔디·돌길·밭·소품·숲·건물을 합성하고 길찾기 격자를 만든다. | → _build_nav(), _place_buildings(), _road_cells(), _stamp_own(), autotile(), grass(), prop() / ← _compose_static() |
| 841 | `_compose_static()` | 맵 합성 · 길찾기 · 외형 시트 | SRW 그림이 있으면 그것으로, 없으면 Kenney 타일로 정적 맵을 합성하고 길찾기를 만든다. | → _build_nav(), _compose_srw(), _place_buildings(), _road_cells(), _stamp(), _stamp_block(), / ← _ready() |
| 905 | `_draw()` | 렌더링 · UI 테마 · 그림 불러오기 | 정적 맵·애니메이션 균열·건물 이름표·영주관 내구도·집결 지점을 그린다. | → _draw_text(), own_tex() / ← _process() |
| 937 | `_draw_text()` | 렌더링 · UI 테마 · 그림 불러오기 | 가운데 정렬된 외곽선 텍스트를 그린다. | ← _draw() |

## scripts/map_art.gd

| 줄 | 심볼 | 묶음 | 요약 | 호출함 → / ← 호출됨 |
|---:|---|---|---|---|
| 1 | `map_art.gd` | 에셋 크레딧 · SRW 팩 · 외형 배정 | Super Retro World 외부 팩과 자체 그림으로 마을 맵 이미지를 그리는 정적 도우미. |  |
| 10 | `PACK / TILE` | map_art.gd: PACK / TILE (단독) | 타일셋 팩 경로와 16px 타일 크기. |  |
| 14 | `AUTO / GRASS` | 맵 합성 · 길찾기 · 외형 시트 | 오토타일 종류별 A2 블록 위치와 맨 풀 타일 위치. |  |
| 21 | `PROPS` | 맵 합성 · 길찾기 · 외형 시트 | tileset_0에서 소품별 위치·크기 표. |  |
| 44 | `_sheets / _own_tex caches` | map_art.gd: _sheets / _own_tex caches (단독) | 축소된 시트 이미지와 자체 그림 텍스처 캐시. |  |
| 47 | `available()` | 맵 합성 · 길찾기 · 외형 시트 | 외부 타일셋 팩이 있는지 확인한다. | ← _compose_static() |
| 52 | `_sheet()` | 맵 합성 · 길찾기 · 외형 시트 | 32px 시트를 16px로 줄이고 분홍을 투명·그림자로 바꿔 캐시한다. | ← autotile(), grass(), prop() |
| 69 | `own()` | 맵 합성 · 길찾기 · 외형 시트 | assets/agra의 자체 PNG를 직접 읽어 이미지로 돌려준다. | ← _place_buildings(), _stamp_own(), own_tex() |
| 79 | `own_tex()` | 렌더링 · UI 테마 · 그림 불러오기 | 자체 그림을 텍스처로 만들어 캐시한다. | → own() / ← _build_hud(), _draw(), _draw(), _draw(), _draw_fx(), _frame() |
| 85 | `grass()` | 맵 합성 · 길찾기 · 외형 시트 | 지정 칸에 풀 타일을 찍는다. | → _sheet() / ← _compose_srw() |
| 90 | `prop()` | 맵 합성 · 길찾기 · 외형 시트 | 발밑 칸 기준으로 소품을 블렌딩해 그린다. | → _sheet() / ← _compose_srw() |
| 98 | `autotile()` | 맵 합성 · 길찾기 · 외형 시트 | VX Ace A2 오토타일 규칙으로 이웃을 보고 8px 조각을 이어 그린다. | → _sheet() / ← _compose_srw() |

## scripts/mercenary.gd

| 줄 | 심볼 | 묶음 | 요약 | 호출함 → / ← 호출됨 |
|---:|---|---|---|---|
| 1 | `mercenary.gd` | 프로젝트 설정 · 구조 | 쪼꼬미 용병 노드: 탄생 시 정체성을 정하고 낮엔 생활, 밤엔 전투를 수행한다. |  |
| 6 | `preload consts (JobData, Summon, CharSprites, MapArt)` | mercenary.gd: preload consts (JobData, S (단독) | 직업 데이터·소환수·캐릭터 스프라이트·맵 아트 스크립트를 미리 불러온다. |  |
| 12 | `FX / BOLT_TIME` | 쪼꼬미 생활 AI · 전투 · 이동 | 공격·치유 효과 그림의 파일·칸 크기·프레임 수·재생 시간과 탄환 비행 시간을 정의한다. |  |
| 21 | `NAMES` | 에셋 크레딧 · SRW 팩 · 외형 배정 | 성별(남/여)마다 따로 둔 용병 이름 목록이다. |  |
| 28 | `TRAIT_GROUPS` | 에셋 크레딧 · SRW 팩 · 외형 배정 | 함께 가질 수 없는 성격 특성 묶음을 정의한다. |  |
| 30 | `ACTION_PLACE` | 쪼꼬미 생활 AI · 전투 · 이동 | 낮 행동별로 찾아갈 건물을 매핑한다. |  |
| 32 | `ACTION_LABEL` | 쪼꼬미 생활 AI · 전투 · 이동 | 낮 행동별 한글 표시 이름을 매핑한다. |  |
| 35 | `identity state (game, merc_name, gender, job_id, tier, grade, stats, traits, friend)` | mercenary.gd: identity state (game, merc (단독) | 용병의 이름·성별·직업·전직 단계·등급·능력치·특성·친구를 저장한다. |  |
| 37 | `gender / char_id / dir identity fields` | 맵 합성 · 길찾기 · 외형 시트 | 성별과 Super Retro World 캐릭터 번호, 4방향 바라보는 방향으로 외형을 결정한다. |  |
| 45 | `combat/needs state (max_hp, hp, atk, defense, attack_range, attack_interval, move_speed, heal_power, energy, hunger, morale, level, xp, downed, summons)` | mercenary.gd: combat/needs state (max_hp (단독) | 전투 수치와 기력·배고픔·사기·레벨 등 욕구/성장 상태를 저장한다. |  |
| 61 | `behavior/move/render state (activity, action, target_pos, doing_time, attack_cd, flash_*, splash_*, sprite_index, facing, moving, bob, path, repath_cd)` | 마을 운영 · HUD · 육성 창 | 현재 행동·이동 경로·공격 쿨다운·그리기용 상태를 저장한다. |  |
| 72 | `fx/bolt effect state (fx, fx_at, fx_t, bolt_t, bolt_to)` | 쪼꼬미 생활 AI · 전투 · 이동 | 재생 중인 효과 종류·위치·남은 시간과 원거리 탄환 비행 상태를 저장한다. |  |
| 92 | `roll_identity()` | 에셋 크레딧 · SRW 팩 · 외형 배정 | 직업·성별·캐릭터 그림·이름·능력치·등급·특성을 무작위로 정하고 수치를 계산한다. | → available(), grade_for_total(), job(), pick(), recalc(), stat_total() / ← _initialize(), _spawn_merc() |
| 130 | `job()` | 쪼꼬미 생활 AI · 전투 · 이동 | 현재 직업의 JobData 항목을 돌려준다. | ← _growth_bbcode(), gain_xp(), next_tier(), recalc(), roll_identity(), style(), title() |
| 134 | `style()` | 쪼꼬미 생활 AI · 전투 · 이동 | 직업의 전투 방식 문자열을 돌려준다. | → job() / ← _attack(), _night(), _process(), on_night_start(), recalc() |
| 138 | `title()` | 마을 운영 · HUD · 육성 창 | 현재 전직 단계의 직함을 돌려준다. | → job() / ← _growth_bbcode(), _process(), _spawn_merc(), describe(), job_name(), try_promote() |
| 142 | `job_name()` | 마을 운영 · HUD · 육성 창 | 직함(title)을 직업 이름으로 돌려준다. | → title() |
| 146 | `grade_info()` | 직업 · 등급 · 능력치 데이터 | 현재 등급의 정보(이름·색·성장치)를 돌려준다. | ← _draw(), _growth_bbcode(), _spawn_merc(), describe(), gain_xp() |
| 150 | `stat_total()` | 직업 · 등급 · 능력치 데이터 | 다섯 능력치의 합을 계산한다. | ← _growth_bbcode(), _process(), roll_identity() |
| 157 | `has_trait()` | 쪼꼬미 생활 AI · 전투 · 이동 | 특정 성격 특성을 가졌는지 확인한다. | ← _choose_action(), _day(), _night(), _pick_target(), recalc(), take_damage() |
| 161 | `trait_text()` | 직업 · 등급 · 능력치 데이터 | 특성 목록을 쉼표로 이은 문자열로 만든다. | ← _growth_bbcode() |
| 166 | `recalc()` | 쪼꼬미 생활 AI · 전투 · 이동 | 능력치·레벨·전직 단계로 체력·공격·방어·사거리·속도·치유력을 다시 계산한다. | → has_trait(), job(), style() / ← gain_xp(), promote(), roll_identity() |
| 186 | `xp_needed()` | 쪼꼬미 생활 AI · 전투 · 이동 | 다음 레벨까지 필요한 경험치를 돌려준다. | ← _growth_bbcode(), gain_xp() |
| 191 | `next_tier()` | 직업 · 등급 · 능력치 데이터 | 다음 전직 단계의 이름·요구 레벨·비용을 돌려주고 없으면 빈 사전을 돌려준다. | → job() / ← _growth_bbcode(), _update_growth_panel(), gain_xp(), try_promote() |
| 199 | `promote()` | 쪼꼬미 생활 AI · 전투 · 이동 | 전직 단계를 올리고 수치를 재계산하며 체력과 사기를 회복한다. | → recalc() / ← try_promote() |
| 206 | `describe()` | 직업 · 등급 · 능력치 데이터 | 등급·이름·레벨·직함을 한 줄 설명으로 만든다. | → grade_info(), title() / ← _update_hud() |
| 212 | `_process()` | 쪼꼬미 생활 AI · 전투 · 이동 | 매 프레임 타이머를 줄이고 쓰러짐/밤/낮에 따라 행동을 분기한 뒤 다시 그린다. | → _day(), _night() |
| 233 | `_day()` | 쪼꼬미 생활 AI · 전투 · 이동 | 낮에 욕구를 갱신하고 고른 행동 장소로 이동해 휴식·식사·훈련·노동·수다를 수행한다. | → _choose_action(), _move_to(), gain_xp(), has_trait() / ← _process() |
| 273 | `_choose_action()` | 쪼꼬미 생활 AI · 전투 · 이동 | 욕구와 성격 점수에 무작위를 더해 낮 행동을 고르는 유틸리티 AI다. | → building_pos(), has_trait() / ← _day() |
| 301 | `on_night_start()` | 마을 운영 · HUD · 육성 창 | 소환사 직업이면 밤 시작 시 전직 단계에 따라 소환수를 불러낸다. | → add_log(), setup(), style() / ← _start_night() |
| 317 | `clear_summons()` | 마을 운영 · HUD · 육성 창 | 자신이 부른 소환수를 모두 제거한다. | ← dismiss_merc(), on_dawn() |
| 325 | `_night()` | 쪼꼬미 생활 AI · 전투 · 이동 | 밤에 후퇴·치유·집결/경계·돌격·공격 중 하나를 수행한다. | → _attack(), _move_to(), _pick_target(), _try_heal(), has_trait(), style() / ← _process() |
| 359 | `_attack()` | 쪼꼬미 생활 AI · 전투 · 이동 | 전투 방식별로 범위/원거리/근접 공격 효과를 재생하고 대상에게 피해를 준다. | → _play_fx(), style(), take_damage() / ← _night() |
| 389 | `_pick_target()` | 쪼꼬미 생활 AI · 전투 · 이동 | 동료애로 친구 근처 몬스터를 우선하거나 집결지/자신에 가장 가까운 몬스터를 고른다. | → has_trait() / ← _night() |
| 408 | `_try_heal()` | 쪼꼬미 생활 AI · 전투 · 이동 | 다친 동료를 찾아 다가가 치유하고 치유 효과를 재생한다. | → _move_to(), _play_fx(), gain_xp() / ← _night() |
| 437 | `take_damage()` | 쪼꼬미 생활 AI · 전투 · 이동 | 방어로 줄인 피해를 받고 사기를 깎으며 쓰러지면 기록하고 친구의 사기를 낮춘다. | → add_log(), has_trait() / ← _process() |
| 454 | `gain_xp()` | 쪼꼬미 생활 AI · 전투 · 이동 | 경험치를 얻어 레벨업하며 능력치를 성장시키고 전직 가능 여부를 알린다. | → add_log(), grade_info(), job(), next_tier(), recalc(), xp_needed() / ← _day(), _process(), _try_heal(), gain_xp(), take_damage(), train_support() |
| 472 | `on_dawn()` | 마을 운영 · HUD · 육성 창 | 새벽에 소환수를 정리하고 쓰러진 용병을 일으키며 기력을 깎는다. | → clear_summons() / ← _start_day() |
| 484 | `_move_to()` | 쪼꼬미 생활 AI · 전투 · 이동 | 기력에 따라 속도를 정해 목표로 경로 이동한다. | → _follow(), find_path() / ← _day(), _night(), _try_heal() |
| 491 | `_follow()` | 쪼꼬미 생활 AI · 전투 · 이동 | 필요할 때 길을 다시 찾아 경로를 따라 이동하고 바라보는 방향을 갱신한다. | → find_path(), is_walkable() / ← _move_to() |
| 519 | `_draw()` | 맵 합성 · 길찾기 · 외형 시트 | 캐릭터 스프라이트(팩 또는 Kenney)·그림자·체력바·효과·이름과 행동 라벨을 그린다. | → _draw_fx(), _label(), frame_rect(), grade_info(), sheet(), tile_src() (static) |
| 572 | `_play_fx()` | 쪼꼬미 생활 AI · 전투 · 이동 | 지정한 효과 종류와 위치로 효과 재생을 시작한다. | ← _attack(), _try_heal() |
| 579 | `_draw_fx()` | 쪼꼬미 생활 AI · 전투 · 이동 | 원거리 탄환 비행 또는 현재 효과의 프레임 애니메이션을 그린다. | → own_tex() / ← _draw() |
| 598 | `_label()` | 맵 합성 · 길찾기 · 외형 시트 | 외곽선이 있는 작은 글자를 가운데 정렬로 그린다. | ← _draw() |

## scripts/monster.gd

| 줄 | 심볼 | 묶음 | 요약 | 호출함 → / ← 호출됨 |
|---:|---|---|---|---|
| 1 | `monster.gd` | 프로젝트 설정 · 구조 | 균열에서 나온 마물로 용병을 공격하거나 영주관으로 진격한다. |  |
| 6 | `MapArt preload` | monster.gd: MapArt preload (단독) | 자체 그림 로드를 위해 map_art.gd를 불러온다. |  |
| 9 | `KINDS` | 렌더링 · UI 테마 · 그림 불러오기 | 마물 종류별 그림 크기와 hp·공격·속도 배율, 비행 여부 표. |  |
| 17 | `NORMAL_KINDS / ELITE_KINDS / WALK` | 렌더링 · UI 테마 · 그림 불러오기 | 일반·정예 마물 종류 목록과 걷기 프레임 순서. |  |
| 21 | `state vars (game, max_hp, hp, atk, speed, elite, reward, body_size, kind, attack_cd, bob, hit_t, facing, path, path_goal, repath_cd)` | monster.gd: state vars (game, max_hp, hp (단독) | 마물의 능력치·애니메이션·경로 상태 변수. |  |
| 39 | `setup()` | 렌더링 · UI 테마 · 그림 불러오기 | 날짜와 정예 여부로 능력치와 종류를 정하고 KINDS 배율을 적용한다. | ← _spawn_monster() |
| 60 | `_process()` | 쪼꼬미 생활 AI · 전투 · 이동 | 가까운 용병·소환수(기사 도발 우선)를 공격하고 없으면 영주관을 공격한다. | → _move_to(), damage_hall(), style(), take_damage(), take_damage() |
| 99 | `_move_to()` | 쪼꼬미 생활 AI · 전투 · 이동 | 속도에 맞춰 목표 지점으로 경로 이동한다. | → _follow() / ← _process() |
| 103 | `_follow()` | 쪼꼬미 생활 AI · 전투 · 이동 | 경로를 주기적으로 다시 찾아 따라 이동하고 방향을 갱신한다. | → find_path(), is_walkable() / ← _move_to() |
| 122 | `take_damage()` | 쪼꼬미 생활 AI · 전투 · 이동 | 피해를 받고 죽으면 공격자에게 경험치를 주고 처치를 알린다. | → gain_xp(), gain_xp(), on_monster_killed() / ← _attack(), _process() |
| 133 | `_draw()` | 렌더링 · UI 테마 · 그림 불러오기 | 자체 마물 시트에서 걷기 프레임을 그리고 체력바를 표시한다. | → own_tex() |

## scripts/summon.gd

| 줄 | 심볼 | 묶음 | 요약 | 호출함 → / ← 호출됨 |
|---:|---|---|---|---|
| 1 | `summon.gd` | 프로젝트 설정 · 구조 | 소환사가 밤마다 부르는 정령으로 새벽에 사라진다. |  |
| 5 | `MapArt preload` | summon.gd: MapArt preload (단독) | 정령 그림 로드를 위해 map_art.gd를 불러온다. |  |
| 7 | `TIER_TINT` | 마을 운영 · HUD · 육성 창 | 소환사 단계별 정령 색조 목록. |  |
| 9 | `state vars (game, summoner, max_hp, hp, atk, speed, downed, tint_base, attack_cd, bob, facing, hit_t)` | summon.gd: state vars (game, summoner, m (단독) | 정령의 능력치·소환사·애니메이션 상태 변수. |  |
| 23 | `setup()` | 마을 운영 · HUD · 육성 창 | 지능·레벨·단계로 체력·공격력·색조를 정한다. | ← on_night_start() |
| 30 | `_process()` | 쪼꼬미 생활 AI · 전투 · 이동 | 소환사 근처 마물을 찾아 공격하고 없으면 소환사 곁으로 돌아간다. | → _move(), take_damage() |
| 59 | `_move()` | 쪼꼬미 생활 AI · 전투 · 이동 | 건물을 무시하고 목표로 직선 비행한다. | ← _process() |
| 65 | `take_damage()` | 쪼꼬미 생활 AI · 전투 · 이동 | 피해를 받고 죽으면 목록에서 빠지고 사라진다. | ← _process() |
| 76 | `gain_xp()` | 쪼꼬미 생활 AI · 전투 · 이동 | 받은 경험치를 소환사에게 넘긴다. | → gain_xp() / ← take_damage() |
| 81 | `_draw()` | 렌더링 · UI 테마 · 그림 불러오기 | 자체 정령 시트에서 프레임을 그리고 체력바를 표시한다. | → own_tex() |

## tests/growth_test.gd

| 줄 | 심볼 | 묶음 | 요약 | 호출함 → / ← 호출됨 |
|---:|---|---|---|---|
| 1 | `growth_test.gd` | 헤드리스 테스트 | 육성 시스템(등급 분포, 성별·이름·외형, 레벨업, 전직, 방출, 소환수)을 헤드리스로 검증하는 SceneTree 테스트 스크립트. |  |
| 5 | `Mercenary (preload)` | growth_test.gd: Mercenary (preload) (단독) | mercenary.gd 스크립트를 미리 불러온 상수. |  |
| 6 | `JobData (preload)` | growth_test.gd: JobData (preload) (단독) | job_data.gd 직업·등급 표를 미리 불러온 상수. |  |
| 7 | `CharSprites (preload)` | growth_test.gd: CharSprites (preload) (단독) | char_sprites.gd 캐릭터 외형 배정 표를 미리 불러온 상수. |  |
| 9 | `failures` | 헤드리스 테스트 | 실패한 검사 수를 세는 변수로 종료 코드를 결정한다. |  |
| 10 | `main` | growth_test.gd: main (단독) | 인스턴스화한 main.tscn 씬 참조. |  |
| 11 | `frames` | growth_test.gd: frames (단독) | 경과 프레임 수 카운터. |  |
| 14 | `check()` | 헤드리스 테스트 | 조건을 PASS/FAIL로 출력하고 실패 시 failures를 늘린다. | ← _initialize(), _process() |
| 20 | `_initialize()` | 에셋 크레딧 · SRW 팩 · 외형 배정 | 용병 3000명을 탄생시켜 등급 희소성, 전 직업 출현, 남녀 균형, 성별 이름, 외형-성별-직업 일치, 직업·성별별 외형 존재를 검사한 뒤 main.tscn을 띄운다. | → available(), check(), pick(), roll_identity() |
| 64 | `_process()` | 마을 운영 · HUD · 육성 창 | 3프레임 후 레벨업·전직 조건과 비용, 방출 후 선택·친구 참조 정리, 소환사의 밤 소환과 새벽 소멸을 검사하고 결과로 종료한다. | → _spawn_merc(), _start_day(), _start_night(), check(), dismiss_merc(), gain_xp(), select(), |

## tests/screenshot.gd

| 줄 | 심볼 | 묶음 | 요약 | 호출함 → / ← 호출됨 |
|---:|---|---|---|---|
| 1 | `screenshot.gd` | 스크린샷 테스트 | 실제 렌더링 화면을 낮(day.png)·밤(night.png)·전투(battle.png) PNG로 저장하는 창 모드 스크립트. |  |
| 6 | `main` | screenshot.gd: main (단독) | 인스턴스화한 main.tscn 씬 참조. |  |
| 7 | `frames` | screenshot.gd: frames (단독) | 경과 프레임 수로 촬영 시점을 정한다. |  |
| 8 | `out_dir` | 프로젝트 설정 · 구조 | PNG 저장 폴더(기본 user://, 명령줄 인자로 변경). |  |
| 11 | `_initialize()` | 프로젝트 설정 · 구조 | 명령줄 인자로 출력 폴더를 받고 main.tscn을 띄운다. |  |
| 19 | `_process()` | 마을 운영 · HUD · 육성 창 | 소환사를 뽑고 용병을 선택해 낮 화면을 찍은 뒤 밤을 시작해 정예 마물을 소환하고 밤 화면, 효과가 2명 이상 터지는 전투 순간을 찍고 종료한다. | → _save(), _spawn_merc(), _spawn_monster(), _start_night(), select() |
| 46 | `_save()` | 프로젝트 설정 · 구조 | 루트 뷰포트 텍스처를 이미지로 받아 out_dir에 PNG로 저장한다. | ← _process() |

## tests/smoke_test.gd

| 줄 | 심볼 | 묶음 | 요약 | 호출함 → / ← 호출됨 |
|---:|---|---|---|---|
| 1 | `smoke_test.gd` | 헤드리스 테스트 | Headless smoke test running the main scene at 10x speed for several days, imitating a lord and checking pathfinding validity. |  |
| 5 | `TARGET_DAY` | 헤드리스 테스트 | Const day count (4) at which the smoke test ends. |  |
| 6 | `MAX_FRAMES` | 헤드리스 테스트 | Const frame cap (8000) for the smoke test. |  |
| 18 | `_initialize()` | 프로젝트 설정 · 구조 | Sets Engine.time_scale to 10 and instantiates main.tscn. |  |
| 24 | `_process()` | 헤드리스 테스트 | Auto-recruits/repairs by day, counts units standing on unwalkable tiles, and evaluates PASS criteria (>=4 mercs, night seen, monsters, day>=2, blocked<1%). | → _on_recruit(), _on_repair(), _report(), is_walkable() |
| 57 | `_report()` | 헤드리스 테스트 | Prints a status line with day/night, hall hp, resources, residue, monster count and each merc's activity/level. | ← _process() |
