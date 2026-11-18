# 아그라 전기 — 코드 맵 (graphify 자동 생성)

줄 번호는 graph 생성 시점 기준. 코드를 고친 뒤에는 `/graphify --update`로 갱신할 것.

## 커뮤니티 (기능 묶음)

- **0** 마을 운영 · HUD · 육성 창 구성
- **1** 프로젝트 · 문서 · 테스트 · 명령
- **2** 쪼꼬미 배치 · leash · 밤 전투
- **3** 기획서 · 육성 규칙
- **4** 맵 합성 · 길찾기 · 외형 시트
- **5** 전직 조건 · 능력치 표시
- **6** 성 위기 · 밤 배치 감속
- **7** 쪼꼬미 탄생 · 등급 · 외형 배정
- **8** 낮 생활 AI · 건물 위치
- **9** deployment.gd: _exit_tree() (단독)
- **10** deployment.gd: FLAG / POLE (단독)
- **11** deployment.gd: is_slowed() (단독)
- **12** deployment.gd: _ready() (단독)
- **13** deployment.gd: TILE (단독)
- **14** job_data.gd: TIER_MULT / PROMOTE_RESIDUE (단독)
- **15** main.gd: COL_TEXT / COL_DARK (단독)
- **16** main.gd: WORLD_SIZE / TILE / DAY_LENGTH  (단독)
- **17** main.gd: hud_root / hud_body / growth_pa (단독)
- **18** mercenary.gd: behavior state vars (activ (단독)
- **19** mercenary.gd: combat stat vars (max_hp,  (단독)
- **20** mercenary.gd: identity state vars (merc_ (단독)
- **21** mercenary.gd: preloads (JobData / Summon (단독)
- **22** monster.gd: NORMAL_KINDS / ELITE_KINDS / (단독)
- **23** monster.gd: preload MapArt (단독)
- **24** monster.gd: state vars (max_hp, hp, atk, (단독)
- **25** stat_bar.gd: COL_BACK / COL_EDGE / COL_T (단독)
- **26** stat_panel.gd: COL_TEXT / COL_PRIMARY /  (단독)
- **27** stat_panel.gd: ROW_H / NAME_W / BAR_W /  (단독)
- **28** stat_panel.gd: preloads (StatBar / JobDa (단독)
- **29** stat_panel.gd: state vars (_bars, _merc, (단독)
- **30** summon.gd: preload MapArt (단독)
- **31** summon.gd: state vars (summoner, max_hp, (단독)

## scripts/char_sprites.gd

| 줄 | 심볼 | 묶음 | 요약 | 호출함 → / ← 호출됨 |
|---:|---|---|---|---|
| 1 | `char_sprites.gd` | 기획서 · 육성 규칙 | Super Retro World 캐릭터 팩으로 쪼꼬미 외형을 고른다. |  |
| 9 | `PACK_DIR / FRAME / Dir / WALK` | 맵 합성 · 길찾기 · 외형 시트 | 캐릭터 팩 경로·프레임 크기·방향·걷기 순서를 정의한다. |  |
| 15 | `CHARS` | 쪼꼬미 탄생 · 등급 · 외형 배정 | 캐릭터 번호별 성별과 어울리는 직업을 정의한다. |  |
| 34 | `_cache` | 맵 합성 · 길찾기 · 외형 시트 | 읽어 둔 캐릭터 시트 텍스처 캐시를 담는다. |  |
| 37 | `path_of()` | 맵 합성 · 길찾기 · 외형 시트 | 캐릭터 번호로 시트 파일 경로를 만든다. | ← available(), sheet() |
| 41 | `available()` | 쪼꼬미 탄생 · 등급 · 외형 배정 | 캐릭터 팩이 있는지 확인한다. | → path_of() / ← pick(), roll_identity() |
| 46 | `pick()` | 쪼꼬미 탄생 · 등급 · 외형 배정 | 직업·성별에 맞고 겹치지 않는 캐릭터 번호를 고른다. | → available() / ← roll_identity() |
| 61 | `gender_of()` | 쪼꼬미 탄생 · 등급 · 외형 배정 | 캐릭터 번호의 성별을 돌려준다. |  |
| 66 | `sheet()` | 맵 합성 · 길찾기 · 외형 시트 | 캐릭터 시트 PNG를 직접 읽어 텍스처로 캐시한다. | → path_of() / ← _draw() |
| 75 | `frame_rect()` | 맵 합성 · 길찾기 · 외형 시트 | 방향·프레임으로 시트 안의 칸 영역을 계산한다. | ← _draw() |

## scripts/deployment.gd

| 줄 | 심볼 | 묶음 | 요약 | 호출함 → / ← 호출됨 |
|---:|---|---|---|---|
| 1 | `deployment.gd` | 기획서 · 육성 규칙 | 용병별 배치 칸, 성 위기 판정, 밤 배치 중 감속을 담당한다. |  |
| 9 | `TILE` | deployment.gd: TILE (단독) | 격자 칸 크기(16px)다. |  |
| 11 | `LEASH_TILES / LEASH_DEFAULT` | 쪼꼬미 배치 · leash · 밤 전투 | 전투 방식별 leash 칸 수와 기본값이다. |  |
| 14 | `ROW_DIST / ROW_OF_STYLE` | 프로젝트 · 문서 · 테스트 · 명령 | 자동 배치 열별 거리와 전투 방식별 열을 정한다. |  |
| 17 | `CRISIS_TILES / CRISIS_HIT_SECS` | 성 위기 · 밤 배치 감속 | 성 위기 판정 반경과 최근 피격 시간 기준이다. |  |
| 20 | `SWITCH_HOLD` | 쪼꼬미 배치 · leash · 밤 전투 | 모드·목표 전환 후 최소 유지 시간이다. |  |
| 22 | `ENGAGE_PAD` | 쪼꼬미 배치 · leash · 밤 전투 | 성 방어 중 교전 반경 추가 거리다. |  |
| 24 | `NIGHT_EDIT_SPEED` | 성 위기 · 밤 배치 감속 | 밤 배치 편집 중 시간 배율이다. |  |
| 25 | `FLAG / POLE` | deployment.gd: FLAG / POLE (단독) | 배치 깃발과 깃대 색이다. |  |
| 28 | `state vars (hall_crisis, last_hall_hit, _saved_speed)` | 쪼꼬미 배치 · leash · 밤 전투 | 성 위기 여부·마지막 피격 시각·저장된 배속 상태다. |  |
| 34 | `_ready()` | deployment.gd: _ready() (단독) | 그리기 순서를 설정한다. |  |
| 38 | `_process()` | 성 위기 · 밤 배치 감속 | 매 프레임 성 위기와 느린 시간을 갱신한다. | → _update_slow(), update_crisis() |
| 44 | `_exit_tree()` | deployment.gd: _exit_tree() (단독) | 나갈 때 저장한 배속을 되돌린다. |  |
| 51 | `note_hall_hit()` | 마을 운영 · HUD · 육성 창 구성 | 영주관 피격 시각을 기록한다. | ← damage_hall() |
| 55 | `update_crisis()` | 성 위기 · 밤 배치 감속 | 밤에 영주관 근처 마물이나 최근 피격으로 성 위기를 판정한다. | → hall_threat() / ← _process() |
| 60 | `hall_dist()` | 성 위기 · 밤 배치 감속 | 영주관 테두리에서 지점까지 거리를 잰다. | ← hall_threat() |
| 66 | `hall_threat()` | 성 위기 · 밤 배치 감속 | 영주관 둘레 마물 중 기준점에 가장 가까운 것을 찾는다. | → hall_dist() / ← _defend_hall(), update_crisis() |
| 82 | `base_speed()` | 성 위기 · 밤 배치 감속 | 사용자가 고른 배속을 돌려준다. | ← _on_speed() |
| 86 | `set_base_speed()` | 성 위기 · 밤 배치 감속 | 사용자 배속을 설정한다(느린 중이면 저장값만). | ← _on_speed() |
| 93 | `is_slowed()` | deployment.gd: is_slowed() (단독) | 밤 배치 편집으로 느려진 중인지 확인한다. |  |
| 97 | `_update_slow()` | 성 위기 · 밤 배치 감속 | 밤에 용병을 고르는 동안 시간을 느리게 한다. | ← _process() |
| 110 | `leash_px()` | 쪼꼬미 배치 · leash · 밤 전투 | 전투 방식별 leash 거리를 픽셀로 돌려준다. | ← _draw(), leash() |
| 114 | `cell_center()` | 쪼꼬미 배치 · leash · 밤 전투 | 격자 칸의 중심 좌표를 돌려준다. | ← _draw(), _free_cell(), post_center() |
| 119 | `is_placeable()` | 프로젝트 · 문서 · 테스트 · 명령 | 맵 안이고 걸을 수 있는 칸인지 확인한다. | → is_walkable() / ← _free_cell(), handle_click() |
| 124 | `ui_blocks()` | 프로젝트 · 문서 · 테스트 · 명령 | 지점에 마우스를 받는 HUD가 있는지 확인한다. | → _blocks() / ← handle_click() |
| 128 | `_blocks()` | 프로젝트 · 문서 · 테스트 · 명령 | 컨트롤 트리를 재귀로 훑어 지점을 가리는지 확인한다. | ← ui_blocks() |
| 139 | `handle_click()` | 프로젝트 · 문서 · 테스트 · 명령 | 선택한 용병의 배치/해제 클릭을 처리한다. | → add_log(), cell_of(), is_placeable(), ui_blocks() / ← _unhandled_input() |
| 160 | `auto_deploy()` | 프로젝트 · 문서 · 테스트 · 명령 | 용병을 균열 길 위 전열·중열·후열로 자동 배치한다. | → _free_cell(), _lane_points(), _row_of(), add_log() |
| 185 | `_row_of()` | 프로젝트 · 문서 · 테스트 · 명령 | 용병 전투 방식으로 배치 열을 정한다. | → style() / ← auto_deploy() |
| 190 | `_lane_points()` | 프로젝트 · 문서 · 테스트 · 명령 | 영주관→균열 길에서 열별 거리 지점과 방향을 구한다. | → find_path() / ← auto_deploy() |
| 210 | `_free_cell()` | 쪼꼬미 배치 · leash · 밤 전투 | 가장 가까운 비어 있고 설 수 있는 칸을 찾는다. | → cell_center(), cell_of(), is_placeable() / ← auto_deploy() |
| 223 | `_draw()` | 쪼꼬미 배치 · leash · 밤 전투 | 배치 깃발·점선·leash 원을 그린다. | → cell_center(), leash_px(), style() |

## scripts/job_data.gd

| 줄 | 심볼 | 묶음 | 요약 | 호출함 → / ← 호출됨 |
|---:|---|---|---|---|
| 1 | `job_data.gd` | 기획서 · 육성 규칙 | 쪼꼬미 직업·등급·능력치 데이터를 담는다. |  |
| 8 | `STATS / STAT_NAMES` | 전직 조건 · 능력치 표시 | 능력치 5종의 키와 한글 이름을 정의한다. |  |
| 13 | `GRADES / STAT_CAP_DEFAULT` | 쪼꼬미 탄생 · 등급 · 외형 배정 | 능력치 합계에 따른 등급과 성장 보너스·상한을 정의한다. |  |
| 22 | `TIER_MULT / PROMOTE_RESIDUE / PROMOTE_GOLD / PROMOTE_STAT` | job_data.gd: TIER_MULT / PROMOTE_RESIDUE (단독) | 전직 단계별 배율과 비용·능력치 조건을 정의한다. |  |
| 28 | `JOBS` | 쪼꼬미 탄생 · 등급 · 외형 배정 | 직업별 전투 방식·배율·스프라이트·전직 단계를 정의한다. |  |
| 92 | `stat_cap()` | 쪼꼬미 탄생 · 등급 · 외형 배정 | 등급의 능력치 바 상한을 돌려준다. | ← show_merc() |
| 98 | `grade_for_total()` | 쪼꼬미 탄생 · 등급 · 외형 배정 | 능력치 합계로 등급 번호를 정한다. | ← roll_identity() |

## scripts/main.gd

| 줄 | 심볼 | 묶음 | 요약 | 호출함 → / ← 호출됨 |
|---:|---|---|---|---|
| 1 | `main.gd` | 기획서 · 육성 규칙 | 마을 운영·낮밤 순환·균열 침공을 총괄하는 메인 스크립트. |  |
| 6 | `Mercenary / Monster / JobData / MapArt / Deployment / StatPanel / TOWN_TEX / DUNGEON_TEX` | 기획서 · 육성 규칙 | 다른 스크립트와 타일 텍스처를 미리 불러온다. |  |
| 15 | `WORLD_SIZE / TILE / DAY_LENGTH / HALL_MAX_HP / RECRUIT_COST / WAGE_PER_MERC / MAX_MERCS / TRAIN_SUPPORT_COST / VACATION_COST` | main.gd: WORLD_SIZE / TILE / DAY_LENGTH  (단독) | 화면 크기·낮 길이·비용 등 게임 상수를 정의한다. |  |
| 26 | `COL_TEXT / COL_DARK` | main.gd: COL_TEXT / COL_DARK (단독) | UI 글자색과 외곽선색을 정의한다. |  |
| 29 | `gold / food / wood / residue / day / is_night / phase_time / hall_hp` | 전직 조건 · 능력치 표시 | 자원과 낮밤 진행 상태를 담는다. |  |
| 47 | `buildings / hall_rect / rifts` | 낮 생활 AI · 건물 위치 | 건물 위치·모이는 자리와 균열 위치를 정의한다. |  |
| 72 | `hud_root / hud_body / growth_panel / stat_panel / promote_button / dismiss_button` | main.gd: hud_root / hud_body / growth_pa (단독) | HUD와 육성 창 노드 참조를 담는다. |  |
| 92 | `_ready()` | 마을 운영 · HUD · 육성 창 구성 | 폰트·맵·HUD를 준비하고 시작 용병 넷을 만든다. | → _build_hud(), _compose_static(), _load_font(), _show_banner(), _spawn_merc(), add_log() |
| 113 | `_process()` | 마을 운영 · HUD · 육성 창 구성 | 매 프레임 낮밤 진행, 조명, HUD를 갱신한다. | → _start_night(), _update_hud(), _update_lighting(), _update_night() |
| 128 | `_start_night()` | 마을 운영 · HUD · 육성 창 구성 | 밤을 시작하고 이번 밤 마물 수를 정한다. | → _show_banner(), add_log(), on_night_start() / ← _process() |
| 139 | `_update_night()` | 마을 운영 · HUD · 육성 창 구성 | 밤 동안 마물을 차례로 소환하고 다 잡으면 낮으로 넘긴다. | → _spawn_monster(), _start_day() / ← _process() |
| 150 | `_start_day()` | 마을 운영 · HUD · 육성 창 구성 | 새 날을 시작하며 임금을 지급하고 소환수를 정리한다. | → _show_banner(), add_log(), on_dawn() / ← _update_night() |
| 172 | `_update_lighting()` | 마을 운영 · HUD · 육성 창 구성 | 시간대에 맞춰 화면 색조를 서서히 바꾼다. | ← _process() |
| 183 | `_spawn_merc()` | 마을 운영 · HUD · 육성 창 구성 | 새 용병을 만들어 정체성을 굴리고 합류시킨다. | → _show_banner(), add_log(), building_pos(), grade_info(), roll_identity(), title() / ← _on_recruit(), _ready() |
| 200 | `_spawn_monster()` | 마을 운영 · HUD · 육성 창 구성 | 균열 위치에 마물을 소환한다. | → add_log(), setup() / ← _update_night() |
| 212 | `on_monster_killed()` | 쪼꼬미 배치 · leash · 밤 전투 | 마물 처치 보상(금화·잔재)을 지급한다. | → add_log() / ← take_damage() |
| 223 | `damage_hall()` | 마을 운영 · HUD · 육성 창 구성 | 영주관에 피해를 주고 무너지면 게임을 끝낸다. | → _show_banner(), add_log(), note_hall_hit() / ← _process() |
| 235 | `building_pos()` | 낮 생활 AI · 건물 위치 | 건물 주변의 걸을 수 있는 무작위 자리를 고른다. | → is_walkable() / ← _choose_action(), _spawn_merc() |
| 249 | `_build_nav()` | 맵 합성 · 길찾기 · 외형 시트 | 길 비용과 막힌 칸으로 A* 격자를 만든다. | ← _compose_srw(), _compose_static() |
| 264 | `cell_of()` | 프로젝트 · 문서 · 테스트 · 명령 | 좌표를 격자 칸으로 바꾼다. | ← _free_cell(), find_path(), handle_click(), is_walkable() |
| 268 | `is_walkable()` | 프로젝트 · 문서 · 테스트 · 명령 | 좌표가 걸을 수 있는 칸인지 확인한다. | → cell_of() / ← _follow(), _follow(), building_pos(), is_placeable() |
| 273 | `find_path()` | 프로젝트 · 문서 · 테스트 · 명령 | 두 지점 사이 A* 경로를 돌려준다. | → cell_of() / ← _follow(), _follow(), _lane_points() |
| 282 | `_unhandled_input()` | 성 위기 · 밤 배치 감속 | 키 입력과 클릭으로 재시작·배속·선택·배치를 처리한다. | → _on_speed(), handle_click(), select(), toggle_hud() |
| 314 | `_on_recruit()` | 마을 운영 · HUD · 육성 창 구성 | 금화로 용병을 모집한다. | → _spawn_merc(), add_log() |
| 324 | `_on_repair()` | 마을 운영 · HUD · 육성 창 구성 | 목재로 영주관 방책을 수리한다. | → add_log() |
| 333 | `_on_upgrade_training()` | 마을 운영 · HUD · 육성 창 구성 | 목재로 훈련장을 강화해 훈련 효율을 높인다. | → add_log() |
| 344 | `select()` | 마을 운영 · HUD · 육성 창 구성 | 용병을 선택하고 육성 창을 보이거나 숨긴다. | ← _on_close_panel(), _unhandled_input(), _update_growth_panel(), dismiss_merc() |
| 353 | `train_support()` | 마을 운영 · HUD · 육성 창 구성 | 금화로 용병에게 즉시 경험치를 준다. | → add_log(), gain_xp() / ← _on_train_support() |
| 364 | `vacation()` | 마을 운영 · HUD · 육성 창 구성 | 금화로 용병의 기력과 사기를 회복시킨다. | → add_log() / ← _on_vacation() |
| 376 | `can_promote()` | 전직 조건 · 능력치 표시 | 전직 조건(레벨·능력치·잔재·금화)이 갖춰졌는지 판정한다. | → meets_stat_req(), next_tier() / ← _growth_bbcode(), _update_growth_panel() |
| 382 | `try_promote()` | 전직 조건 · 능력치 표시 | 조건을 확인하고 비용을 치러 용병을 전직시킨다. | → _show_banner(), add_log(), meets_stat_req(), next_tier(), promote(), title() / ← _on_promote() |
| 405 | `dismiss_merc()` | 마을 운영 · HUD · 육성 창 구성 | 용병을 영지에서 방출하고 친구 관계를 정리한다. | → add_log(), clear_summons(), select() / ← _on_dismiss() |
| 420 | `_on_train_support()` | 마을 운영 · HUD · 육성 창 구성 | 선택된 용병의 훈련 지원 버튼을 처리한다. | → train_support() |
| 425 | `_on_vacation()` | 마을 운영 · HUD · 육성 창 구성 | 선택된 용병의 휴가 버튼을 처리한다. | → vacation() |
| 430 | `_on_promote()` | 마을 운영 · HUD · 육성 창 구성 | 선택된 용병의 전직 버튼을 처리한다. | → try_promote() |
| 435 | `_on_dismiss()` | 마을 운영 · HUD · 육성 창 구성 | 두 번 눌러야 방출되는 방출 버튼을 처리한다. | → dismiss_merc() |
| 445 | `_on_close_panel()` | 마을 운영 · HUD · 육성 창 구성 | 육성 창을 닫는다. | → select() |
| 449 | `_build_growth_panel()` | 마을 운영 · HUD · 육성 창 구성 | 육성 창 패널·텍스트·능력치 바·버튼을 만든다. | → _add_button(), _frame(), setup() / ← _build_hud() |
| 490 | `_growth_bbcode()` | 전직 조건 · 능력치 표시 | 육성 창 위·아래 BBCode 텍스트를 만든다. | → can_promote(), grade_info(), job(), meets_stat_req(), next_tier(), stat_total(), title(),  / ← _update_growth_panel() |
| 529 | `_update_growth_panel()` | 전직 조건 · 능력치 표시 | 선택된 용병 정보로 육성 창을 갱신한다. | → _growth_bbcode(), can_promote(), next_tier(), select(), show_merc() / ← _update_hud() |
| 548 | `_on_speed()` | 성 위기 · 밤 배치 감속 | 게임 배속을 1배와 2배 사이로 전환한다. | → base_speed(), set_base_speed() / ← _unhandled_input() |
| 554 | `toggle_hud()` | 프로젝트 · 문서 · 테스트 · 명령 | HUD 본체를 숨기거나 보인다. | ← _unhandled_input() |
| 560 | `add_log()` | 마을 운영 · HUD · 육성 창 구성 | 로그 줄을 추가하고 최근 네 줄만 표시한다. | ← _on_recruit(), _on_repair(), _on_upgrade_training(), _ready(), _spawn_merc(), _spawn_monst |
| 568 | `_load_font()` | 마을 운영 · HUD · 육성 창 구성 | 픽셀 폰트를 안티앨리어싱 없이 불러온다. | ← _ready() |
| 578 | `_frame()` | 마을 운영 · HUD · 육성 창 구성 | 자체 UI 테두리 그림으로 9칸 스타일박스를 만든다. | → own_tex() / ← _build_growth_panel(), _make_theme() |
| 590 | `_make_theme()` | 마을 운영 · HUD · 육성 창 구성 | 버튼·라벨·패널용 HUD 테마를 만든다. | → _frame() / ← _build_hud() |
| 613 | `_build_hud()` | 마을 운영 · HUD · 육성 창 구성 | 상단 자원 줄·로그·배너·메뉴 버튼 등 HUD 전체를 만든다. | → _add_button(), _build_growth_panel(), _make_label(), _make_theme(), own_tex() / ← _ready() |
| 683 | `_make_label()` | 마을 운영 · HUD · 육성 창 구성 | 위치와 크기를 지정한 라벨을 만든다. | ← _build_hud() |
| 692 | `_add_button()` | 마을 운영 · HUD · 육성 창 구성 | 콜백이 연결된 버튼을 만들어 붙인다. | ← _build_growth_panel(), _build_hud() |
| 701 | `_show_banner()` | 마을 운영 · HUD · 육성 창 구성 | 화면 가운데 배너를 띄우고 서서히 사라지게 한다. | ← _ready(), _spawn_merc(), _start_day(), _start_night(), damage_hall(), try_promote() |
| 713 | `_update_hud()` | 전직 조건 · 능력치 표시 | HUD 텍스트(날짜·자원·정보)를 매 프레임 갱신한다. | → _update_growth_panel(), describe() / ← _process() |
| 734 | `tile_src()` | 맵 합성 · 길찾기 · 외형 시트 | 타일 번호로 Kenney 시트의 영역을 계산한다. | ← _draw(), _stamp() |
| 738 | `_stamp()` | 맵 합성 · 길찾기 · 외형 시트 | 타일 하나를 맵 이미지에 찍는다. | → tile_src() / ← _compose_static(), _stamp_block() |
| 742 | `_stamp_block()` | 맵 합성 · 길찾기 · 외형 시트 | 타일 묶음을 맵 이미지에 찍는다. | → _stamp() / ← _compose_static() |
| 751 | `_place_buildings()` | 맵 합성 · 길찾기 · 외형 시트 | 영주관·여관·식당 그림을 찍고 칸을 막는다. | → own() / ← _compose_srw(), _compose_static() |
| 765 | `_stamp_own()` | 맵 합성 · 길찾기 · 외형 시트 | 자체 그림 띠의 한 프레임을 발밑 기준으로 찍는다. | → own() / ← _compose_srw() |
| 770 | `_road_cells()` | 맵 합성 · 길찾기 · 외형 시트 | 큰길·샛길 칸 목록을 돌려준다. | ← _compose_srw(), _compose_static() |
| 789 | `_compose_srw()` | 맵 합성 · 길찾기 · 외형 시트 | Super Retro World 에셋으로 마을 정적 맵을 합성한다. | → _build_nav(), _place_buildings(), _road_cells(), _stamp_own(), autotile(), grass(), prop() / ← _compose_static() |
| 875 | `_compose_static()` | 맵 합성 · 길찾기 · 외형 시트 | 정적 맵을 합성하고 SRW가 없으면 Kenney로 그린다. | → _build_nav(), _compose_srw(), _place_buildings(), _road_cells(), _stamp(), _stamp_block(), / ← _ready() |
| 939 | `_draw()` | 낮 생활 AI · 건물 위치 | 정적 맵·균열·이름표·영주관 내구도를 그린다. | → _draw_text(), own_tex() |
| 963 | `_draw_text()` | 낮 생활 AI · 건물 위치 | 가운데 정렬 외곽선 텍스트를 그린다. | ← _draw() |

## scripts/map_art.gd

| 줄 | 심볼 | 묶음 | 요약 | 호출함 → / ← 호출됨 |
|---:|---|---|---|---|
| 1 | `map_art.gd` | 기획서 · 육성 규칙 | Super Retro World 외부 팩으로 마을 맵 그림을 그린다. |  |
| 10 | `PACK / TILE` | 맵 합성 · 길찾기 · 외형 시트 | 에셋 팩 경로와 타일 크기를 정의한다. |  |
| 14 | `AUTO / GRASS` | 맵 합성 · 길찾기 · 외형 시트 | 오토타일 종류별 시트 위치와 풀 칸을 정의한다. |  |
| 21 | `PROPS` | 맵 합성 · 길찾기 · 외형 시트 | 소품 이름별 시트 영역을 정의한다. |  |
| 44 | `_sheets / _own_tex` | 맵 합성 · 길찾기 · 외형 시트 | 읽어 둔 시트와 텍스처 캐시를 담는다. |  |
| 47 | `available()` | 맵 합성 · 길찾기 · 외형 시트 | SRW 외부 팩이 있는지 확인한다. | ← _compose_static() |
| 52 | `_sheet()` | 맵 합성 · 길찾기 · 외형 시트 | 32px 시트를 16px로 줄이고 분홍을 투명으로 바꾼다. | ← autotile(), grass(), prop() |
| 69 | `own()` | 맵 합성 · 길찾기 · 외형 시트 | assets/agra 자체 그림을 이미지로 읽는다. | ← _place_buildings(), _stamp_own(), own_tex() |
| 79 | `own_tex()` | 맵 합성 · 길찾기 · 외형 시트 | 자체 그림을 텍스처로 만들어 캐시한다. | → own() / ← _build_hud(), _draw(), _draw(), _draw(), _draw_fx(), _frame() |
| 85 | `grass()` | 맵 합성 · 길찾기 · 외형 시트 | 풀 타일 한 칸을 찍는다. | → _sheet() / ← _compose_srw() |
| 90 | `prop()` | 맵 합성 · 길찾기 · 외형 시트 | 소품 하나를 발밑 기준으로 찍는다. | → _sheet() / ← _compose_srw() |
| 98 | `autotile()` | 맵 합성 · 길찾기 · 외형 시트 | VX Ace A2 오토타일 규칙으로 이어진 지형을 그린다. | → _sheet() / ← _compose_srw() |

## scripts/mercenary.gd

| 줄 | 심볼 | 묶음 | 요약 | 호출함 → / ← 호출됨 |
|---:|---|---|---|---|
| 1 | `mercenary.gd` | 기획서 · 육성 규칙 | 쪼꼬미 용병: 탄생·낮 생활 AI·밤 전투·성장·그리기를 담당한다. |  |
| 6 | `preloads (JobData / Summon / CharSprites / MapArt / Deployment / StatBar)` | mercenary.gd: preloads (JobData / Summon (단독) | 직업·소환수·스프라이트·맵그림·배치·막대 스크립트를 미리 불러온다. |  |
| 14 | `FX / BOLT_TIME` | 맵 합성 · 길찾기 · 외형 시트 | 공격·치유 효과 그림 정보와 원거리 탄환 비행 시간을 정한다. |  |
| 22 | `RETREAT_UNTIL` | 쪼꼬미 배치 · leash · 밤 전투 | 후퇴한 용병이 여관에 머무는 체력 기준을 정한다. |  |
| 25 | `NAMES` | 쪼꼬미 탄생 · 등급 · 외형 배정 | 성별별 용병 이름 목록이다. |  |
| 32 | `TRAIT_GROUPS` | 쪼꼬미 탄생 · 등급 · 외형 배정 | 함께 가질 수 없는 성격 특성 묶음이다. |  |
| 34 | `ACTION_PLACE / ACTION_LABEL` | 낮 생활 AI · 건물 위치 | 낮 행동별 장소와 표시 이름을 정한다. |  |
| 39 | `identity state vars (merc_name, job_id, tier, grade, stats, traits)` | mercenary.gd: identity state vars (merc_ (단독) | 이름·성별·직업·단계·등급·능력치·특성 등 용병 정체성 상태다. |  |
| 49 | `combat stat vars (max_hp, hp, atk, defense, energy, hunger, morale)` | mercenary.gd: combat stat vars (max_hp,  (단독) | 체력·공격·방어·사거리·욕구·레벨 등 전투/생활 수치 상태다. |  |
| 65 | `behavior state vars (activity, retreating, defending, mode_lock, night_target)` | mercenary.gd: behavior state vars (activ (단독) | 행동·후퇴·성 방어·목표 고정·효과 재생 등 행동 상태다. |  |
| 89 | `post/path state vars (post_pos, path, path_goal, repath_cd)` | 프로젝트 · 문서 · 테스트 · 명령 | 밤에 지킬 칸과 경로 추적 상태다. |  |
| 98 | `roll_identity()` | 쪼꼬미 탄생 · 등급 · 외형 배정 | 태어날 때 직업·성별·이름·능력치·등급·특성을 무작위로 정한다. | → available(), grade_for_total(), job(), pick(), recalc(), stat_total() / ← _spawn_merc() |
| 136 | `job()` | 쪼꼬미 배치 · leash · 밤 전투 | 현재 직업 데이터를 돌려준다. | ← _draw(), _growth_bbcode(), gain_xp(), next_tier(), recalc(), roll_identity(), style(), tit |
| 140 | `style()` | 쪼꼬미 배치 · leash · 밤 전투 | 직업의 전투 방식을 돌려준다. | → job() / ← _attack(), _draw(), _night(), _process(), _row_of(), leash(), on_night_start(), recalc() |
| 144 | `title()` | 전직 조건 · 능력치 표시 | 현재 전직 단계의 직업 이름을 돌려준다. | → job() / ← _growth_bbcode(), _spawn_merc(), describe(), job_name(), try_promote() |
| 148 | `job_name()` | 전직 조건 · 능력치 표시 | 직업 이름(title)을 돌려준다. | → title() |
| 152 | `grade_info()` | 전직 조건 · 능력치 표시 | 등급 데이터를 돌려준다. | ← _draw(), _growth_bbcode(), _spawn_merc(), describe(), gain_xp(), show_merc() |
| 156 | `stat_total()` | 전직 조건 · 능력치 표시 | 능력치 합계를 계산한다. | ← _growth_bbcode(), roll_identity() |
| 163 | `has_trait()` | 쪼꼬미 배치 · leash · 밤 전투 | 특정 성격 특성을 가졌는지 확인한다. | ← _choose_action(), _day(), _night(), _pick_target(), recalc(), take_damage() |
| 167 | `trait_text()` | 전직 조건 · 능력치 표시 | 특성 목록을 쉼표 문자열로 만든다. | ← _growth_bbcode() |
| 172 | `recalc()` | 쪼꼬미 배치 · leash · 밤 전투 | 능력치·레벨·전직 단계로 전투 수치를 다시 계산한다. | → has_trait(), job(), style() / ← gain_xp(), promote(), roll_identity() |
| 192 | `xp_needed()` | 전직 조건 · 능력치 표시 | 다음 레벨까지 필요한 경험치를 돌려준다. | ← _growth_bbcode(), gain_xp() |
| 197 | `next_tier()` | 전직 조건 · 능력치 표시 | 다음 전직 조건과 비용 정보를 돌려준다. | → job() / ← _draw(), _growth_bbcode(), _update_growth_panel(), can_promote(), gain_xp(), show_merc(),  |
| 207 | `meets_stat_req()` | 전직 조건 · 능력치 표시 | 다음 전직의 능력치 조건을 채웠는지 확인한다. | ← _growth_bbcode(), can_promote(), try_promote() |
| 211 | `promote()` | 전직 조건 · 능력치 표시 | 전직 단계를 올리고 체력·사기를 회복한다. | → recalc() / ← try_promote() |
| 218 | `describe()` | 전직 조건 · 능력치 표시 | 등급·이름·레벨·직업을 한 줄 설명으로 만든다. | → grade_info(), title() / ← _update_hud() |
| 224 | `_process()` | 쪼꼬미 배치 · leash · 밤 전투 | 매 프레임 쿨다운을 줄이고 낮/밤 행동을 고른다. | → _day(), _night() |
| 246 | `_day()` | 쪼꼬미 배치 · leash · 밤 전투 | 낮에 욕구를 갱신하고 고른 생활 행동을 수행한다. | → _choose_action(), _move_to(), gain_xp(), has_trait() / ← _process() |
| 286 | `_choose_action()` | 낮 생활 AI · 건물 위치 | 욕구와 성격 점수로 다음 낮 행동을 고른다(유틸리티 AI). | → building_pos(), has_trait() / ← _day() |
| 314 | `on_night_start()` | 마을 운영 · HUD · 육성 창 구성 | 밤이 시작되면 소환사는 소환수를 불러낸다. | → add_log(), setup(), style() / ← _start_night() |
| 330 | `clear_summons()` | 마을 운영 · HUD · 육성 창 구성 | 불러낸 소환수를 모두 없앤다. | ← dismiss_merc(), on_dawn() |
| 338 | `_night()` | 쪼꼬미 배치 · leash · 밤 전투 | 밤에 후퇴·치유·성 방어·복귀·교전 중 하나를 수행한다. | → _defend_hall(), _fight(), _move_to(), _pick_target(), _try_heal(), _update_defend(), has_p / ← _process() |
| 378 | `_update_defend()` | 쪼꼬미 배치 · leash · 밤 전투 | 성 위기에 따라 배치와 성 방어 모드를 전환한다. | → has_post() / ← _night() |
| 390 | `_defend_hall()` | 쪼꼬미 배치 · leash · 밤 전투 | 성 위기 때 영주관 쪽 마물을 막으러 간다. | → _fight(), _move_to(), _nearest_monster(), hall_threat() / ← _night() |
| 407 | `_nearest_monster()` | 쪼꼬미 배치 · leash · 밤 전투 | 반경 안에서 가장 가까운 마물을 찾는다. | ← _defend_hall() |
| 418 | `_fight()` | 쪼꼬미 배치 · leash · 밤 전투 | 목표에 다가가 사거리에 들면 공격한다(leash 제한). | → _attack(), _leashed(), _move_to() / ← _defend_hall(), _night() |
| 435 | `_attack()` | 쪼꼬미 배치 · leash · 밤 전투 | 전투 방식별 효과를 내고 마물에게 피해를 준다. | → _play_fx(), style(), take_damage() / ← _fight() |
| 458 | `has_post()` | 쪼꼬미 배치 · leash · 밤 전투 | 배치 칸이 있는지 확인한다. | ← _in_zone(), _leashed(), _night(), _pick_target(), _update_defend() |
| 462 | `post_center()` | 쪼꼬미 배치 · leash · 밤 전투 | 배치 칸의 중심 좌표를 돌려준다. | → cell_center() / ← _in_zone(), _leashed(), _night(), _pick_target() |
| 466 | `leash()` | 쪼꼬미 배치 · leash · 밤 전투 | 전투 방식별 leash 거리를 돌려준다. | → leash_px(), style() / ← _in_zone(), _leashed(), _night(), _pick_target() |
| 471 | `_leashed()` | 쪼꼬미 배치 · leash · 밤 전투 | 목표 지점을 배치 칸 leash 원 안으로 끌어당긴다. | → has_post(), leash(), post_center() / ← _fight(), _try_heal() |
| 480 | `_in_zone()` | 쪼꼬미 배치 · leash · 밤 전투 | 지점이 배치 칸의 교전 구역 안인지 확인한다. | → has_post(), leash(), post_center() / ← _pick_target() |
| 484 | `_pick_target()` | 쪼꼬미 배치 · leash · 밤 전투 | 친구 구출 우선, 아니면 배치 칸 기준 가장 가까운 마물을 고른다. | → _in_zone(), has_post(), has_trait(), leash(), post_center() / ← _night() |
| 503 | `_try_heal()` | 쪼꼬미 배치 · leash · 밤 전투 | 다친 동료를 찾아 치유한다. | → _leashed(), _move_to(), _play_fx(), gain_xp() / ← _night() |
| 529 | `take_damage()` | 마을 운영 · HUD · 육성 창 구성 | 방어로 줄인 피해를 받고 사기를 깎으며 쓰러짐을 처리한다. | → add_log(), has_trait() / ← _process() |
| 546 | `gain_xp()` | 쪼꼬미 배치 · leash · 밤 전투 | 경험치를 얻고 레벨업 시 능력치를 올린다. | → add_log(), grade_info(), job(), next_tier(), recalc(), xp_needed() / ← _day(), _try_heal(), gain_xp(), take_damage(), train_support() |
| 564 | `on_dawn()` | 마을 운영 · HUD · 육성 창 구성 | 새벽에 전투 상태를 초기화하고 쓰러진 용병을 일으킨다. | → clear_summons() / ← _start_day() |
| 580 | `_move_to()` | 쪼꼬미 배치 · leash · 밤 전투 | 기력에 따라 속도를 정해 목표로 이동한다. | → _follow() / ← _day(), _defend_hall(), _fight(), _night(), _try_heal() |
| 587 | `_follow()` | 프로젝트 · 문서 · 테스트 · 명령 | 길찾기 경로를 따라 이동하고 방향을 갱신한다. | → find_path(), is_walkable() / ← _move_to() |
| 615 | `_draw()` | 맵 합성 · 길찾기 · 외형 시트 | 용병 스프라이트·등급 표시·HP 바·이름·행동을 그린다. | → _draw_fx(), _label(), draw_bar(), frame_rect(), grade_info(), hp_color(), sheet(), tile_sr |
| 669 | `_play_fx()` | 쪼꼬미 배치 · leash · 밤 전투 | 재생할 공격/치유 효과를 설정한다. | ← _attack(), _try_heal() |
| 676 | `_draw_fx()` | 맵 합성 · 길찾기 · 외형 시트 | 원거리 탄환과 효과 애니메이션을 그린다. | → own_tex() / ← _draw() |
| 695 | `_label()` | 맵 합성 · 길찾기 · 외형 시트 | 외곽선 있는 글자를 가운데 정렬로 그린다. | ← _draw() |

## scripts/monster.gd

| 줄 | 심볼 | 묶음 | 요약 | 호출함 → / ← 호출됨 |
|---:|---|---|---|---|
| 1 | `monster.gd` | 기획서 · 육성 규칙 | 균열에서 나와 용병과 영주관을 공격하는 마물이다. |  |
| 6 | `preload MapArt` | monster.gd: preload MapArt (단독) | 맵 그림 스크립트를 미리 불러온다. |  |
| 9 | `KINDS` | 마을 운영 · HUD · 육성 창 구성 | 마물 종류별 그림 크기와 능력치 배율이다. |  |
| 17 | `NORMAL_KINDS / ELITE_KINDS / WALK` | monster.gd: NORMAL_KINDS / ELITE_KINDS / (단독) | 일반·엘리트 종류 목록과 걷기 프레임이다. |  |
| 21 | `state vars (max_hp, hp, atk, speed, elite, body_size, path)` | monster.gd: state vars (max_hp, hp, atk, (단독) | 체력·공격·속도·엘리트·보상·경로 상태다. |  |
| 39 | `setup()` | 마을 운영 · HUD · 육성 창 구성 | 날짜와 엘리트 여부로 마물 능력치와 종류를 정한다. | ← _spawn_monster() |
| 60 | `_process()` | 마을 운영 · HUD · 육성 창 구성 | 가까운 용병(도발 우선)을 공격하고 없으면 영주관을 친다. | → _move_to(), damage_hall(), style(), take_damage(), take_damage() |
| 99 | `_move_to()` | 마을 운영 · HUD · 육성 창 구성 | 속도에 맞춰 목표로 이동한다. | → _follow() / ← _process() |
| 103 | `_follow()` | 프로젝트 · 문서 · 테스트 · 명령 | 길찾기 경로를 따라 이동한다. | → find_path(), is_walkable() / ← _move_to() |
| 122 | `take_damage()` | 쪼꼬미 배치 · leash · 밤 전투 | 피해를 받고 죽으면 공격자에게 경험치를 준다. | → gain_xp(), gain_xp(), on_monster_killed() / ← _attack(), _process() |
| 133 | `_draw()` | 맵 합성 · 길찾기 · 외형 시트 | 마물 그림과 HP 바를 그린다. | → own_tex() |

## scripts/stat_bar.gd

| 줄 | 심볼 | 묶음 | 요약 | 호출함 → / ← 호출됨 |
|---:|---|---|---|---|
| 1 | `stat_bar.gd` | 기획서 · 육성 규칙 | 능력치 줄과 HP 바가 함께 쓰는 작은 픽셀 막대다. |  |
| 5 | `COL_BACK / COL_EDGE / COL_TICK` | stat_bar.gd: COL_BACK / COL_EDGE / COL_T (단독) | 막대 배경·테두리·눈금 색이다. |  |
| 15 | `set_bar()` | 전직 조건 · 능력치 표시 | 막대 비율·색·테두리·눈금을 바꾸고 다시 그린다. | ← show_merc() |
| 25 | `_draw()` | 맵 합성 · 길찾기 · 외형 시트 | 자기 크기에 맞게 막대를 그린다. | → draw_bar() |
| 30 | `draw_bar()` | 맵 합성 · 길찾기 · 외형 시트 | 아무 CanvasItem에 픽셀 막대를 그린다. | ← _draw(), _draw() |
| 43 | `hp_color()` | 맵 합성 · 길찾기 · 외형 시트 | 체력 비율에 따라 빨강→노랑→초록 색을 돌려준다. | ← _draw() |

## scripts/stat_panel.gd

| 줄 | 심볼 | 묶음 | 요약 | 호출함 → / ← 호출됨 |
|---:|---|---|---|---|
| 1 | `stat_panel.gd` | 기획서 · 육성 규칙 | 육성 창의 능력치 5종 줄을 그린다. |  |
| 7 | `preloads (StatBar / JobData)` | stat_panel.gd: preloads (StatBar / JobDa (단독) | 막대와 직업 데이터 스크립트를 미리 불러온다. |  |
| 10 | `ROW_H / NAME_W / BAR_W / BAR_H / NUM_W / FONT_SIZE / FLASH_MS` | stat_panel.gd: ROW_H / NAME_W / BAR_W /  (단독) | 줄 높이·폭·글자 크기·깜빡임 시간 등 배치 상수다. |  |
| 17 | `STAT_COLORS` | 전직 조건 · 능력치 표시 | 능력치별 막대 색이다. |  |
| 21 | `COL_TEXT / COL_PRIMARY / COL_OK / COL_LACK / COL_UP / COL_DARK` | stat_panel.gd: COL_TEXT / COL_PRIMARY /  (단독) | 글자·주능력치·충족·미달·상승 색이다. |  |
| 28 | `state vars (_bars, _merc, _last, _up, _up_until)` | stat_panel.gd: state vars (_bars, _merc, (단독) | 막대·보는 용병·직전 값·상승량 기록 상태다. |  |
| 36 | `setup()` | 마을 운영 · HUD · 육성 창 구성 | 능력치마다 막대를 만들어 붙인다. | ← _build_growth_panel() |
| 51 | `show_merc()` | 전직 조건 · 능력치 표시 | 용병 능력치로 막대를 갱신하고 오른 양을 기록한다. | → _req_for(), grade_info(), next_tier(), set_bar(), stat_cap() / ← _update_growth_panel() |
| 76 | `_req_for()` | 전직 조건 · 능력치 표시 | 다음 전직에서 이 능력치 목표치를 돌려준다. | ← _draw(), show_merc() |
| 82 | `_draw()` | 전직 조건 · 능력치 표시 | 능력치 이름·숫자·목표·+n 표시를 그린다. | → _req_for(), job(), next_tier() |
| 106 | `flashing()` | 기획서 · 육성 규칙 | 지금 +n이 떠 있는 능력치를 돌려준다(테스트용). |  |

## scripts/summon.gd

| 줄 | 심볼 | 묶음 | 요약 | 호출함 → / ← 호출됨 |
|---:|---|---|---|---|
| 1 | `summon.gd` | 기획서 · 육성 규칙 | 소환사가 밤마다 부르는 정령이다. |  |
| 5 | `preload MapArt` | summon.gd: preload MapArt (단독) | 맵 그림 스크립트를 미리 불러온다. |  |
| 7 | `TIER_TINT` | 마을 운영 · HUD · 육성 창 구성 | 단계별 정령 색이다. |  |
| 9 | `state vars (summoner, max_hp, hp, atk, speed, downed)` | summon.gd: state vars (summoner, max_hp, (단독) | 소환사·체력·공격·속도 등 정령 상태다. |  |
| 23 | `setup()` | 마을 운영 · HUD · 육성 창 구성 | 지능·레벨·단계로 정령 능력치를 정한다. | ← on_night_start() |
| 30 | `_process()` | 쪼꼬미 배치 · leash · 밤 전투 | 소환사 근처 마물을 쫓아 공격하고 없으면 곁으로 돌아온다. | → _move(), take_damage() |
| 59 | `_move()` | 쪼꼬미 배치 · leash · 밤 전투 | 건물을 통과해 목표로 날아간다. | ← _process() |
| 65 | `take_damage()` | 마을 운영 · HUD · 육성 창 구성 | 피해를 받고 죽으면 목록에서 빠진다. | ← _process() |
| 76 | `gain_xp()` | 쪼꼬미 배치 · leash · 밤 전투 | 얻은 경험치를 소환사에게 넘긴다. | → gain_xp() / ← take_damage() |
| 81 | `_draw()` | 맵 합성 · 길찾기 · 외형 시트 | 정령 그림과 HP 바를 그린다. | → own_tex() |

## tests/growth_test.gd

| 줄 | 심볼 | 묶음 | 요약 | 호출함 → / ← 호출됨 |
|---:|---|---|---|---|
| 1 | `growth_test.gd` | 프로젝트 · 문서 · 테스트 · 명령 | 등급 분포·레벨업·전직·방출·소환수·배치·성 위기·능력치 바를 검증하는 헤드리스 육성 테스트. |  |
| 14 | `check()` | 프로젝트 · 문서 · 테스트 · 명령 | 조건을 PASS/FAIL로 출력하고 실패 수를 센다. | ← _initialize(), _process() |
| 20 | `_initialize()` | 프로젝트 · 문서 · 테스트 · 명령 | 3000번 탄생으로 분포를 검사한 뒤 메인 씬을 띄운다. | → check() |
| 21 | `1) 등급 분포` | 쪼꼬미 탄생 · 등급 · 외형 배정 | 3000번 탄생으로 등급·직업·성별·이름·외형 분포를 확인한다. |  |
| 64 | `_process()` | 프로젝트 · 문서 · 테스트 · 명령 | 3프레임 뒤 2~16번 시험 구역을 차례로 실행하고 종료한다. | → check() |
| 68 | `2) 레벨업 → 전직` | 전직 조건 · 능력치 표시 | 경험치로 레벨업 후 잔재·금화 조건에 따른 전직과 비용 차감을 확인한다. |  |
| 85 | `3) 방출` | 마을 운영 · HUD · 육성 창 구성 | 방출 시 목록 제거·선택 해제·친구 참조 정리를 확인한다. |  |
| 94 | `4) 소환사` | 마을 운영 · HUD · 육성 창 구성 | 소환사가 밤에 소환수를 만들고 새벽에 사라지는지 확인한다. |  |
| 104 | `5) 소환수 막타 경험치` | 쪼꼬미 배치 · leash · 밤 전투 | 소환수가 마물을 잡으면 경험치가 소환사에게 가는지 확인한다. |  |
| 118 | `6) 전직 버튼 조건` | 프로젝트 · 문서 · 테스트 · 명령 | 전직 버튼 활성 조건이 실제 전직 조건과 같은지 확인한다. |  |
| 127 | `7) 후퇴 유지` | 쪼꼬미 배치 · leash · 밤 전투 | 후퇴한 쪼꼬미가 체력 70%까지 여관에 머무는지 확인한다. |  |
| 141 | `8) 식량 없을 때 식사 안 함` | 낮 생활 AI · 건물 위치 | 식량이 0이면 식사 행동을 고르지 않는지 확인한다. |  |
| 152 | `9) 균열→영주관 경로` | 프로젝트 · 문서 · 테스트 · 명령 | 모든 균열에서 영주관 공격 범위까지 길이 닿는지 확인한다. |  |
| 158 | `10) 클릭 배치·거부·해제` | 프로젝트 · 문서 · 테스트 · 명령 | 16px 칸 스냅 배치, 육성 창·HUD·건물 거부, 재클릭 해제를 확인한다. |  |
| 177 | `11) 밤 leash` | 쪼꼬미 배치 · leash · 밤 전투 | 배치된 쪼꼬미가 leash 밖으로 쫓지 않고 미배치면 추격하는지 확인한다. |  |
| 216 | `12) 자동 배치` | 프로젝트 · 문서 · 테스트 · 명령 | 자동 배치가 서로 다른 빈 칸에 전열을 후열보다 앞에 두는지 확인한다. |  |
| 236 | `13) 우상단 메뉴 밑 배치` | 프로젝트 · 문서 · 테스트 · 명령 | 메뉴 버튼 밑 칸은 HUD가 보이면 거부하고 숨기면 배치되는지 확인한다. |  |
| 248 | `14) 밤 배치·0.2배속` | 성 위기 · 밤 배치 감속 | 밤 배치 이동, 선택 중 0.2배속, 선택 해제 시 배속 복구를 확인한다. |  |
| 268 | `15) 성 위기 출동·복귀` | 성 위기 · 밤 배치 감속 | 영주관 근처 마물로 성 위기 시 배치 이탈·접근, 해제 후 한 번만 복귀하는지 확인한다. |  |
| 304 | `16) 능력치 바·전직 능력치 조건·+n` | 전직 조건 · 능력치 표시 | 주 능력치 전직 조건, 목표 눈금, 레벨업 직후 +n 표시를 확인한다. |  |

## tests/screenshot.gd

| 줄 | 심볼 | 묶음 | 요약 | 호출함 → / ← 호출됨 |
|---:|---|---|---|---|
| 1 | `screenshot.gd` | 프로젝트 · 문서 · 테스트 · 명령 | 실제 렌더링 화면을 deploy·growth·day·hud_hidden·night·battle PNG로 저장한다. |  |
| 11 | `_initialize()` | 프로젝트 · 문서 · 테스트 · 명령 | 출력 폴더 인자를 읽고 메인 씬을 띄운다. |  |
| 19 | `_process()` | 프로젝트 · 문서 · 테스트 · 명령 | 프레임별로 장면을 연출하며 스크린샷 6장을 찍는다. | → _save() |
| 64 | `_save()` | 프로젝트 · 문서 · 테스트 · 명령 | 뷰포트 이미지를 PNG 파일로 저장한다. | ← _process() |

## tests/smoke_test.gd

| 줄 | 심볼 | 묶음 | 요약 | 호출함 → / ← 호출됨 |
|---:|---|---|---|---|
| 1 | `smoke_test.gd` | 프로젝트 · 문서 · 테스트 · 명령 | 메인 씬을 10배속으로 며칠 돌려 기본 흐름과 길찾기 막힘을 검증한다. |  |
| 18 | `_initialize()` | 프로젝트 · 문서 · 테스트 · 명령 | 10배속으로 메인 씬을 띄운다. |  |
| 24 | `_process()` | 프로젝트 · 문서 · 테스트 · 명령 | 영주를 흉내 내 모집·수리·자동 배치하고 막힘 비율과 통과 여부를 판정한다. | → _report() |
| 58 | `_report()` | 프로젝트 · 문서 · 테스트 · 명령 | 날짜·자원·마물 수·용병 상태를 한 줄로 출력한다. | ← _process() |
