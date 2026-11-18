# 아그라 전기 — 코드 맵 (graphify 자동 생성)

줄 번호는 graph 생성 시점 기준. 코드를 고친 뒤에는 `/graphify --update`로 갱신할 것.

## 커뮤니티 (기능 묶음)

- **0** 마을 운영 · HUD · 육성 창 구성
- **1** 쪼꼬미 행동 · 전투
- **2** 기획서 · 육성 설계
- **3** 밤 파도 · 새벽 정산 · 낮밤 순환
- **4** 스프라이트 · 직업 데이터
- **5** 검증 · 테스트 · 명령
- **6** 배치 · 성 위기 · 배속
- **7** 따라가기 카메라
- **8** 맵 아트
- **9** 일차·웨이브 HUD
- **10** 프로젝트 · 스크린샷
- **11** mercenary.gd: clear_summons()
- **12** monster.gd: KINDS
- **13** deployment.gd: CRISIS_TILES / CRISIS_HIT_SECS
- **14** deployment.gd: FLAG / POLE
- **15** deployment.gd: LEASH_TILES / LEASH_DEFAULT
- **16** deployment.gd: NIGHT_EDIT_SPEED
- **17** deployment.gd: ROW_DIST / ROW_OF_STYLE
- **18** deployment.gd: TILE
- **19** follow_cam.gd: class Overlay
- **20** job_data.gd: STATS / STAT_NAMES
- **21** job_data.gd: TIER_MULT / PROMOTE_RESIDUE / PROMOTE_GOLD / PROMOTE_STAT
- **22** main.gd: buildings / hall_rect / rifts
- **23** main.gd: COL_TEXT / COL_DARK
- **24** main.gd: WORLD_SIZE / TILE / DAY_LENGTH / HALL_MAX_HP / RECRUIT_COST / WAGE_PER_MERC / MAX_MERCS / TRAIN_SUPPORT_COST / VACATION_COST
- **25** main.gd: hud_root / hud_body / growth_panel / stat_panel / promote_button / dismiss_button
- **26** main.gd: Mercenary / Monster / JobData / MapArt / Deployment / StatPanel / TOWN_TEX / DUNGEON_TEX
- **27** main.gd: gold / food / wood / residue / day / is_night / phase_time / hall_hp
- **28** mercenary.gd: behavior state vars (activity, retreating, defending, mode_lock, night_target)
- **29** mercenary.gd: combat stat vars (max_hp, hp, atk, defense, energy, hunger, morale)
- **30** mercenary.gd: identity state vars (merc_name, job_id, tier, grade, stats, traits)
- **31** mercenary.gd: meets_stat_req()
- **32** mercenary.gd: post/path state vars (post_pos, path, path_goal, repath_cd)
- **33** mercenary.gd: preloads (JobData / Summon / CharSprites / MapArt / Deployment / StatBar)
- **34** mercenary.gd: trait_text()
- **35** monster.gd: NORMAL_KINDS / ELITE_KINDS / WALK
- **36** monster.gd: preload MapArt
- **37** monster.gd: state vars (max_hp, hp, atk, speed, elite, body_size, path)
- **38** stat_bar.gd: COL_BACK / COL_EDGE / COL_TICK
- **39** stat_panel.gd: COL_TEXT / COL_PRIMARY / COL_OK / COL_LACK / COL_UP / COL_DARK
- **40** stat_panel.gd: ROW_H / NAME_W / BAR_W / BAR_H / NUM_W / FONT_SIZE / FLASH_MS
- **41** stat_panel.gd: preloads (StatBar / JobData)
- **42** stat_panel.gd: state vars (_bars, _merc, _last, _up, _up_until)
- **43** summon.gd: preload MapArt
- **44** summon.gd: state vars (summoner, max_hp, hp, atk, speed, downed)
- **45** wave_hud.gd: class RiftCounts

## scripts/char_sprites.gd

| 줄 | 심볼 | 묶음 | 요약 | 호출함 → / ← 호출됨 |
|---:|---|---|---|---|
| 1 | `char_sprites.gd` | 기획서 · 육성 설계 | Super Retro World 캐릭터 팩으로 쪼꼬미 외형을 고른다. |  |
| 9 | `PACK_DIR / FRAME / Dir / WALK` | 스프라이트 · 직업 데이터 | 캐릭터 팩 경로·프레임 크기·방향·걷기 순서를 정의한다. |  |
| 15 | `CHARS` | 스프라이트 · 직업 데이터 | 캐릭터 번호별 성별과 어울리는 직업을 정의한다. |  |
| 34 | `_cache` | 스프라이트 · 직업 데이터 | 읽어 둔 캐릭터 시트 텍스처 캐시를 담는다. |  |
| 37 | `path_of()` | 스프라이트 · 직업 데이터 | 캐릭터 번호로 시트 파일 경로를 만든다. | ← available(), sheet() |
| 41 | `available()` | 스프라이트 · 직업 데이터 | 캐릭터 팩이 있는지 확인한다. | → path_of() / ← pick(), roll_identity() |
| 46 | `pick()` | 스프라이트 · 직업 데이터 | 직업·성별에 맞고 겹치지 않는 캐릭터 번호를 고른다. | → available() / ← roll_identity() |
| 61 | `gender_of()` | 스프라이트 · 직업 데이터 | 캐릭터 번호의 성별을 돌려준다. |  |
| 66 | `sheet()` | 스프라이트 · 직업 데이터 | 캐릭터 시트 PNG를 직접 읽어 텍스처로 캐시한다. | → path_of() / ← _draw() |
| 75 | `frame_rect()` | 스프라이트 · 직업 데이터 | 방향·프레임으로 시트 안의 칸 영역을 계산한다. | ← _draw() |

## scripts/dawn_panel.gd

| 줄 | 심볼 | 묶음 | 요약 | 호출함 → / ← 호출됨 |
|---:|---|---|---|---|
| 1 | `dawn_panel.gd` | 밤 파도 · 새벽 정산 · 낮밤 순환 | 새벽 정산 창: 밤을 넘긴 뒤 시간이 멈춘 동안 띄운다. |  |
| 16 | `_ready()` | 밤 파도 · 새벽 정산 · 낮밤 순환 | dawn_panel.gd: _ready() | → _label() |
| 37 | `_label()` | 밤 파도 · 새벽 정산 · 낮밤 순환 | dawn_panel.gd: _label() | ← _ready() |
| 47 | `show_report()` | 밤 파도 · 새벽 정산 · 낮밤 순환 | dawn_panel.gd: show_report() | → summary_text() / ← show_dawn() |
| 54 | `summary_text()` | 밤 파도 · 새벽 정산 · 낮밤 순환 | 정산 요약: "N일차 방어 성공 — 처치 20, 금화 +XXX, 쓰러진 쪼꼬미 N명, 영주관 -N" + 임금 줄. | ← show_report() |
| 63 | `_on_start()` | 밤 파도 · 새벽 정산 · 낮밤 순환 | dawn_panel.gd: _on_start() | → continue_day() |

## scripts/deployment.gd

| 줄 | 심볼 | 묶음 | 요약 | 호출함 → / ← 호출됨 |
|---:|---|---|---|---|
| 1 | `deployment.gd` | 배치 · 성 위기 · 배속 | 쪼꼬미별 배치: 쪼꼬미마다 지킬 칸(post_pos)을 정하고, 밤에는 그 칸에서 leash 안만 싸운다. |  |
| 10 | `TILE` | deployment.gd: TILE | 격자 칸 크기(16px)다. |  |
| 12 | `LEASH_TILES / LEASH_DEFAULT` | deployment.gd: LEASH_TILES / LEASH_DEFAULT | 전투 방식별 leash 칸 수와 기본값이다. |  |
| 15 | `ROW_DIST / ROW_OF_STYLE` | deployment.gd: ROW_DIST / ROW_OF_STYLE | 자동 배치 열별 거리와 전투 방식별 열을 정한다. |  |
| 18 | `CRISIS_TILES / CRISIS_HIT_SECS` | deployment.gd: CRISIS_TILES / CRISIS_HIT_SECS | 성 위기 판정 반경과 최근 피격 시간 기준이다. |  |
| 21 | `SWITCH_HOLD` | 쪼꼬미 행동 · 전투 | 모드·목표 전환 후 최소 유지 시간이다. |  |
| 23 | `ENGAGE_PAD` | 쪼꼬미 행동 · 전투 | 성 방어 중 교전 반경 추가 거리다. |  |
| 25 | `NIGHT_EDIT_SPEED` | deployment.gd: NIGHT_EDIT_SPEED | 밤 배치 편집 중 시간 배율이다. |  |
| 26 | `FLAG / POLE` | deployment.gd: FLAG / POLE | 배치 깃발과 깃대 색이다. |  |
| 28 | `state vars (hall_crisis, last_hall_hit, _saved_speed)` | 쪼꼬미 행동 · 전투 | 성 위기 여부·마지막 피격 시각·저장된 배속 상태다. |  |
| 35 | `_ready()` | 배치 · 성 위기 · 배속 | deployment.gd: _ready() |  |
| 39 | `_process()` | 배치 · 성 위기 · 배속 | deployment.gd: _process() | → _update_slow(), update_crisis() |
| 45 | `_exit_tree()` | 배치 · 성 위기 · 배속 | deployment.gd: _exit_tree() |  |
| 52 | `note_hall_hit()` | 마을 운영 · HUD · 육성 창 구성 | deployment.gd: note_hall_hit() | ← damage_hall() |
| 56 | `update_crisis()` | 배치 · 성 위기 · 배속 | deployment.gd: update_crisis() | → hall_threat() / ← _process() |
| 61 | `hall_dist()` | 배치 · 성 위기 · 배속 | 영주관 테두리에서 p까지의 거리 (안쪽이면 0). | ← hall_threat() |
| 67 | `hall_threat()` | 배치 · 성 위기 · 배속 | 영주관 둘레 CRISIS_TILES칸 안의 마물 중 from에 가장 가까운 것. | → hall_dist() / ← _defend_hall(), update_crisis() |
| 83 | `base_speed()` | 배치 · 성 위기 · 배속 | 사용자가 고른 배속. 느리게 하는 중이면 끝난 뒤 돌아갈 값. | ← _on_speed() |
| 87 | `set_base_speed()` | 배치 · 성 위기 · 배속 | deployment.gd: set_base_speed() | ← _on_speed() |
| 94 | `is_slowed()` | 배치 · 성 위기 · 배속 | deployment.gd: is_slowed() |  |
| 101 | `speed_override()` | 배치 · 성 위기 · 배속 | 지금 덮어쓸 배속 (-1 = 사용자 배속 그대로). 새벽 정산·낮의 육성 창/배치 → 0(정지), 밤에 배치용으로 쪼꼬미를 고른 동안 → NIGHT_EDIT_SPEED. 따라가기 카메라는 game.selected를 쓰지 않으므로 여기에 걸리지 않는다. | → wants_pause() / ← _update_slow() |
| 111 | `_update_slow()` | 배치 · 성 위기 · 배속 | deployment.gd: _update_slow() | → speed_override() / ← _process() |
| 125 | `leash_px()` | 배치 · 성 위기 · 배속 | deployment.gd: leash_px() | ← _draw(), leash() |
| 129 | `cell_center()` | 배치 · 성 위기 · 배속 | deployment.gd: cell_center() | ← _draw(), _free_cell(), post_center() |
| 134 | `is_placeable()` | 배치 · 성 위기 · 배속 | 서 있을 수 있는 칸인가: 맵 안이고 막히지 않은 칸. | → is_walkable() / ← _free_cell(), handle_click() |
| 140 | `ui_blocks()` | 배치 · 성 위기 · 배속 | 맵 좌표 p를 화면에서 마우스를 받는 HUD 컨트롤이 가리는가 (보이는 것 중 mouse_filter가 IGNORE가 아닌 것). HUD는 화면 좌표라서 따라가기 카메라의 확대·이동을 반영해 바꿔서 잰다. | → _blocks(), world_to_screen() / ← handle_click() |
| 144 | `_blocks()` | 배치 · 성 위기 · 배속 | deployment.gd: _blocks() | ← ui_blocks() |
| 155 | `handle_click()` | 배치 · 성 위기 · 배속 | 왼쪽 클릭 처리. 배치로 소비했으면 true (main은 선택을 바꾸지 않는다). | → add_log(), cell_of(), is_placeable(), ui_blocks() / ← _unhandled_input() |
| 176 | `auto_deploy()` | 배치 · 성 위기 · 배속 | 직업별 열 × 균열 길을 번갈아 고르게 채운다. 쓰러진 쪼꼬미도 자리는 받는다. | → _free_cell(), _lane_points(), _row_of(), add_log() / ← _process(), _process(), _process() |
| 201 | `_row_of()` | 배치 · 성 위기 · 배속 | deployment.gd: _row_of() | ← auto_deploy() |
| 206 | `_lane_points()` | 배치 · 성 위기 · 배속 | 영주관 앞 → 균열 길에서 열별 거리 지점과 그 지점의 길 방향. | → find_path() / ← auto_deploy() |
| 226 | `_free_cell()` | 배치 · 성 위기 · 배속 | p에서 가장 가까운, 서 있을 수 있고 비어 있는 칸. | → cell_center(), cell_of(), is_placeable() / ← auto_deploy() |
| 239 | `_draw()` | 배치 · 성 위기 · 배속 | deployment.gd: _draw() | → cell_center(), leash_px() |

## scripts/follow_cam.gd

| 줄 | 심볼 | 묶음 | 요약 | 호출함 → / ← 호출됨 |
|---:|---|---|---|---|
| 1 | `follow_cam.gd` | 따라가기 카메라 | 쪼꼬미 따라가기 카메라. |  |
| 46 | `setup()` | 마을 운영 · HUD · 육성 창 구성 | follow_cam.gd: setup() | ← _ready() |
| 84 | `is_following()` | 따라가기 카메라 | follow_cam.gd: is_following() | ← _process(), _unhandled_input(), cycle(), hall_alert(), snap(), start(), toggle_from_select |
| 88 | `start()` | 따라가기 카메라 | follow_cam.gd: start() | → is_following(), set_zoom_level() / ← cycle(), toggle_from_selection() |
| 102 | `stop()` | 따라가기 카메라 | follow_cam.gd: stop() | ← _process(), _unhandled_input(), toggle_from_selection() |
| 114 | `toggle_from_selection()` | 따라가기 카메라 | 따라가기 버튼 / F: 고른 쪼꼬미를 따라가거나(선택은 닫는다), 이미 따라가는 중이면 끈다. | → is_following(), select(), start(), stop() / ← _build_growth_panel(), _unhandled_input() |
| 124 | `cycle()` | 따라가기 카메라 | Q/E: 이전/다음 쪼꼬미로 바꾼다 (쓰러진 쪼꼬미도 포함). | → is_following(), start() / ← _unhandled_input() |
| 132 | `set_zoom_level()` | 따라가기 카메라 | 배율은 ZOOM_LEVELS 안의 정수로만 바뀐다. | ← _unhandled_input(), start() |
| 140 | `_unhandled_input()` | 따라가기 카메라 | follow_cam.gd: _unhandled_input() | → cycle(), is_following(), merc_at(), screen_to_world(), set_zoom_level(), stop(), toggle_fr |
| 171 | `_process()` | 따라가기 카메라 | follow_cam.gd: _process() | → _update_bubble(), _update_info(), add_log(), clamp_center(), is_following(), stop() |
| 190 | `clamp_center()` | 따라가기 카메라 | 지금 배율에서 화면이 맵 밖을 보이지 않도록 중심을 묶는다. 정수 픽셀로 맞춘다. | ← _process(), snap() |
| 196 | `snap()` | 따라가기 카메라 | 테스트·스크린샷용: 보간 없이 대상에 바로 붙고 화면 변환을 즉시 반영한다. | → clamp_center(), is_following() |
| 204 | `view_rect()` | 따라가기 카메라 | 지금 화면에 보이는 맵 영역. | ← hall_alert() |
| 209 | `_update_bubble()` | 따라가기 카메라 | follow_cam.gd: _update_bubble() | → say() / ← _process() |
| 223 | `say()` | 따라가기 카메라 | follow_cam.gd: say() | ← _update_bubble() |
| 228 | `_update_info()` | 따라가기 카메라 | follow_cam.gd: _update_info() | ← _process() |
| 236 | `hall_alert()` | 따라가기 카메라 | 영주관이 화면 밖인데 성 위기면 true (화살표를 그린다). | → is_following(), view_rect() |
| 241 | `class Overlay` | follow_cam.gd: class Overlay | HUD 층 그림: 성 위기 화살표 + 말풍선. |  |
| 244 | `Overlay._process()` | 따라가기 카메라 | follow_cam.gd: Overlay._process() |  |
| 247 | `Overlay._draw()` | 따라가기 카메라 | follow_cam.gd: Overlay._draw() | → Overlay._draw_hall_arrow(), world_to_screen() |
| 262 | `Overlay._draw_hall_arrow()` | 따라가기 카메라 | follow_cam.gd: Overlay._draw_hall_arrow() | → world_to_screen() / ← Overlay._draw() |

## scripts/job_data.gd

| 줄 | 심볼 | 묶음 | 요약 | 호출함 → / ← 호출됨 |
|---:|---|---|---|---|
| 1 | `job_data.gd` | 기획서 · 육성 설계 | 쪼꼬미 직업·등급·능력치 데이터를 담는다. |  |
| 8 | `STATS / STAT_NAMES` | job_data.gd: STATS / STAT_NAMES | 능력치 5종의 키와 한글 이름을 정의한다. |  |
| 13 | `GRADES / STAT_CAP_DEFAULT` | 스프라이트 · 직업 데이터 | 능력치 합계에 따른 등급과 성장 보너스·상한을 정의한다. |  |
| 22 | `TIER_MULT / PROMOTE_RESIDUE / PROMOTE_GOLD / PROMOTE_STAT` | job_data.gd: TIER_MULT / PROMOTE_RESIDUE / PROMOTE_GOLD / PROMOTE_STAT | 전직 단계별 배율과 비용·능력치 조건을 정의한다. |  |
| 28 | `JOBS` | 스프라이트 · 직업 데이터 | 직업별 전투 방식·배율·스프라이트·전직 단계를 정의한다. |  |
| 92 | `stat_cap()` | 스프라이트 · 직업 데이터 | 등급의 능력치 바 상한을 돌려준다. | ← show_merc() |
| 98 | `grade_for_total()` | 스프라이트 · 직업 데이터 | 능력치 합계로 등급 번호를 정한다. | ← roll_identity() |

## scripts/main.gd

| 줄 | 심볼 | 묶음 | 요약 | 호출함 → / ← 호출됨 |
|---:|---|---|---|---|
| 1 | `main.gd` | 마을 운영 · HUD · 육성 창 구성 | 아그라 전기 - 프로토타입 메인 |  |
| 6 | `Mercenary / Monster / JobData / MapArt / Deployment / StatPanel / TOWN_TEX / DUNGEON_TEX` | main.gd: Mercenary / Monster / JobData / MapArt / Deployment / StatPanel / TOWN_TEX / DUNGEON_TEX | 다른 스크립트와 타일 텍스처를 미리 불러온다. |  |
| 18 | `WORLD_SIZE / TILE / DAY_LENGTH / HALL_MAX_HP / RECRUIT_COST / WAGE_PER_MERC / MAX_MERCS / TRAIN_SUPPORT_COST / VACATION_COST` | main.gd: WORLD_SIZE / TILE / DAY_LENGTH / HALL_MAX_HP / RECRUIT_COST / WAGE_PER_MERC / MAX_MERCS / TRAIN_SUPPORT_COST / VACATION_COST | 화면 크기·낮 길이·비용 등 게임 상수를 정의한다. |  |
| 29 | `COL_TEXT / COL_DARK` | main.gd: COL_TEXT / COL_DARK | UI 글자색과 외곽선색을 정의한다. |  |
| 29 | `gold / food / wood / residue / day / is_night / phase_time / hall_hp` | main.gd: gold / food / wood / residue / day / is_night / phase_time / hall_hp | 자원과 낮밤 진행 상태를 담는다. |  |
| 47 | `buildings / hall_rect / rifts` | main.gd: buildings / hall_rect / rifts | 건물 위치·모이는 자리와 균열 위치를 정의한다. |  |
| 72 | `hud_root / hud_body / growth_panel / stat_panel / promote_button / dismiss_button` | main.gd: hud_root / hud_body / growth_panel / stat_panel / promote_button / dismiss_button | HUD와 육성 창 노드 참조를 담는다. |  |
| 96 | `_ready()` | 마을 운영 · HUD · 육성 창 구성 | main.gd: _ready() | → _build_hud(), _compose_static(), _load_font(), _show_banner(), _spawn_merc(), add_log(), s |
| 123 | `_process()` | 마을 운영 · HUD · 육성 창 구성 | main.gd: _process() | → _start_night(), _update_hud(), _update_lighting(), update_night() / ← _process() |
| 140 | `_start_night()` | 밤 파도 · 새벽 정산 · 낮밤 순환 | main.gd: _start_night() | → add_log(), night_intro(), start_night() / ← _process(), _process(), _process(), _process() |
| 151 | `_start_dawn()` | 밤 파도 · 새벽 정산 · 낮밤 순환 | 마지막 파도를 막으면: 임금·부활·소환수 정리 후 새벽 정산 창 (시간 정지). | → add_log(), enter_dawn(), show_dawn() / ← _process(), on_kill(), update_night() |
| 176 | `_begin_day()` | 마을 운영 · HUD · 육성 창 구성 | 새벽 정산 창에서 "낮 시작"을 누르면 다음 낮이 온다. | → _show_banner() / ← continue_day() |
| 182 | `_update_lighting()` | 마을 운영 · HUD · 육성 창 구성 | main.gd: _update_lighting() | ← _process() |
| 195 | `_spawn_merc()` | 마을 운영 · HUD · 육성 창 구성 | main.gd: _spawn_merc() | → _show_banner(), add_log(), building_pos() / ← _on_recruit(), _process(), _ready() |
| 212 | `_spawn_monster()` | 밤 파도 · 새벽 정산 · 낮밤 순환 | main.gd: _spawn_monster() | → add_log() / ← update_night() |
| 226 | `on_monster_killed()` | 밤 파도 · 새벽 정산 · 낮밤 순환 | main.gd: on_monster_killed() | → add_log(), on_kill() / ← take_damage() |
| 238 | `damage_hall()` | 마을 운영 · HUD · 육성 창 구성 | main.gd: damage_hall() | → _show_banner(), add_log(), note_hall_hit() / ← _process() |
| 250 | `building_pos()` | 쪼꼬미 행동 · 전투 | main.gd: building_pos() | → is_walkable() / ← _choose_action(), _spawn_merc() |
| 264 | `_build_nav()` | 마을 운영 · HUD · 육성 창 구성 | main.gd: _build_nav() | ← _compose_srw(), _compose_static() |
| 279 | `cell_of()` | 배치 · 성 위기 · 배속 | main.gd: cell_of() | ← _free_cell(), _process(), find_path(), handle_click(), is_walkable() |
| 283 | `is_walkable()` | 배치 · 성 위기 · 배속 | main.gd: is_walkable() | → cell_of() / ← _follow(), _follow(), _process(), building_pos(), is_placeable() |
| 288 | `find_path()` | 배치 · 성 위기 · 배속 | 목적지가 막혀 있으면 가장 가까운 칸까지의 경로를 돌려준다. 첫 점(현재 칸)은 뺀다. | → cell_of() / ← _follow(), _follow(), _lane_points(), _process() |
| 297 | `_unhandled_input()` | 마을 운영 · HUD · 육성 창 구성 | main.gd: _unhandled_input() | → _on_speed(), continue_day(), handle_click(), merc_at(), screen_to_world(), select(), toggl / ← _process() |
| 327 | `screen_to_world()` | 마을 운영 · HUD · 육성 창 구성 | 화면(뷰포트) 좌표 ↔ 맵 좌표. 따라가기 카메라의 확대·이동을 반영한다 (클릭 변환은 모두 여기로). | ← _process(), _unhandled_input(), _unhandled_input() |
| 331 | `world_to_screen()` | 따라가기 카메라 | main.gd: world_to_screen() | ← Overlay._draw(), Overlay._draw_hall_arrow(), _process(), ui_blocks() |
| 336 | `merc_at()` | 마을 운영 · HUD · 육성 창 구성 | 맵 좌표 p에서 클릭으로 고를 쪼꼬미 (없으면 null). | ← _unhandled_input(), _unhandled_input() |
| 347 | `_on_recruit()` | 마을 운영 · HUD · 육성 창 구성 | main.gd: _on_recruit() | → _spawn_merc(), add_log() / ← _process() |
| 357 | `_on_repair()` | 검증 · 테스트 · 명령 | main.gd: _on_repair() | → add_log() / ← _process() |
| 366 | `_on_upgrade_training()` | 마을 운영 · HUD · 육성 창 구성 | main.gd: _on_upgrade_training() | → add_log() |
| 377 | `select()` | 마을 운영 · HUD · 육성 창 구성 | main.gd: select() | ← _on_close_panel(), _process(), _process(), _unhandled_input(), _update_growth_panel(), dis |
| 386 | `train_support()` | 마을 운영 · HUD · 육성 창 구성 | 금화로 집중 훈련을 지원한다: 즉시 경험치. | → add_log() / ← _on_train_support() |
| 397 | `vacation()` | 마을 운영 · HUD · 육성 창 구성 | 휴가: 기력 · 사기 회복. | → add_log() / ← _on_vacation() |
| 409 | `can_promote()` | 마을 운영 · HUD · 육성 창 구성 | 레벨·잔재·금화가 모두 갖춰졌는가 (전직 버튼 활성화에 쓴다). | ← _growth_bbcode(), _process(), _update_growth_panel() |
| 415 | `try_promote()` | 마을 운영 · HUD · 육성 창 구성 | 전직: 레벨 조건 + 마물의 잔재 + 금화. | → _show_banner(), add_log() / ← _on_promote(), _process() |
| 438 | `dismiss_merc()` | 마을 운영 · HUD · 육성 창 구성 | 방출: 쪼꼬미를 영지에서 내보낸다. 되돌릴 수 없다. | → add_log(), select() / ← _on_dismiss(), _process() |
| 453 | `_on_train_support()` | 마을 운영 · HUD · 육성 창 구성 | main.gd: _on_train_support() | → train_support() |
| 458 | `_on_vacation()` | 마을 운영 · HUD · 육성 창 구성 | main.gd: _on_vacation() | → vacation() |
| 463 | `_on_promote()` | 마을 운영 · HUD · 육성 창 구성 | main.gd: _on_promote() | → try_promote() |
| 468 | `_on_dismiss()` | 마을 운영 · HUD · 육성 창 구성 | main.gd: _on_dismiss() | → dismiss_merc() |
| 478 | `_on_close_panel()` | 마을 운영 · HUD · 육성 창 구성 | main.gd: _on_close_panel() | → select() |
| 482 | `_build_growth_panel()` | 마을 운영 · HUD · 육성 창 구성 | main.gd: _build_growth_panel() | → _add_button(), _frame(), setup(), toggle_from_selection() / ← _build_hud() |
| 524 | `_growth_bbcode()` | 마을 운영 · HUD · 육성 창 구성 | 육성 창 글: [위, 아래]. 능력치 5종은 그 사이의 stat_panel이 바로 그린다. | → can_promote() / ← _update_growth_panel() |
| 563 | `_update_growth_panel()` | 마을 운영 · HUD · 육성 창 구성 | main.gd: _update_growth_panel() | → _growth_bbcode(), can_promote(), select(), show_merc() / ← _process(), _update_hud() |
| 582 | `_on_speed()` | 배치 · 성 위기 · 배속 | main.gd: _on_speed() | → base_speed(), set_base_speed() / ← _process(), _unhandled_input() |
| 588 | `toggle_hud()` | 마을 운영 · HUD · 육성 창 구성 | Tab: HUD를 숨기면 맵 전체가 보이고 클릭된다 (선택은 유지되어 배치할 수 있다). | ← _process(), _unhandled_input() |
| 594 | `add_log()` | 마을 운영 · HUD · 육성 창 구성 | main.gd: add_log() | ← _begin_wave(), _on_recruit(), _on_repair(), _on_upgrade_training(), _process(), _ready(),  |
| 602 | `_load_font()` | 마을 운영 · HUD · 육성 창 구성 | main.gd: _load_font() | ← _ready() |
| 612 | `_frame()` | 마을 운영 · HUD · 육성 창 구성 | 자체 그림 테두리(assets/agra/ui_*.png)를 9칸으로 늘려 쓰는 스타일. tint로 눌림·비활성 표현. | ← _build_growth_panel(), _make_theme() |
| 624 | `_make_theme()` | 마을 운영 · HUD · 육성 창 구성 | main.gd: _make_theme() | → _frame() / ← _build_hud() |
| 647 | `_build_hud()` | 마을 운영 · HUD · 육성 창 구성 | main.gd: _build_hud() | → _add_button(), _build_growth_panel(), _make_label(), _make_theme(), setup() / ← _ready() |
| 720 | `_make_label()` | 마을 운영 · HUD · 육성 창 구성 | main.gd: _make_label() | ← _build_hud() |
| 729 | `_add_button()` | 마을 운영 · HUD · 육성 창 구성 | main.gd: _add_button() | ← _build_growth_panel(), _build_hud() |
| 738 | `_show_banner()` | 마을 운영 · HUD · 육성 창 구성 | main.gd: _show_banner() | ← _begin_day(), _ready(), _spawn_merc(), damage_hall(), try_promote() |
| 751 | `_update_hud()` | 마을 운영 · HUD · 육성 창 구성 | main.gd: _update_hud() | → _update_growth_panel() / ← _process() |
| 767 | `tile_src()` | 마을 운영 · HUD · 육성 창 구성 | main.gd: tile_src() | ← _draw(), _stamp() |
| 771 | `_stamp()` | 마을 운영 · HUD · 육성 창 구성 | main.gd: _stamp() | → tile_src() / ← _compose_static(), _stamp_block() |
| 775 | `_stamp_block()` | 마을 운영 · HUD · 육성 창 구성 | main.gd: _stamp_block() | → _stamp() / ← _compose_static() |
| 784 | `_place_buildings()` | 마을 운영 · HUD · 육성 창 구성 | 영주관·여관·식당 (assets/agra, 자체 그림). 발밑 가운데를 건물 칸 묶음의 아래 가운데에 맞춘다. 영주관은 성벽이 한 줄 위로 솟아서 그 줄도 막는다. | ← _compose_srw(), _compose_static() |
| 798 | `_stamp_own()` | 마을 운영 · HUD · 육성 창 구성 | 자체 그림 띠에서 한 프레임을 발밑(foot) 기준으로 맵에 찍는다. | ← _compose_srw() |
| 803 | `_road_cells()` | 마을 운영 · HUD · 육성 창 구성 | 큰길·샛길 칸 (길찾기 비용 1). 그림과 상관없이 같은 배치. | ← _compose_srw(), _compose_static() |
| 822 | `_compose_srw()` | 마을 운영 · HUD · 육성 창 구성 | Super Retro World 무료판으로 마을을 그린다. 배치는 Kenney판과 같다. | → _build_nav(), _place_buildings(), _road_cells(), _stamp_own() / ← _compose_static() |
| 908 | `_compose_static()` | 마을 운영 · HUD · 육성 창 구성 | main.gd: _compose_static() | → _build_nav(), _compose_srw(), _place_buildings(), _road_cells(), _stamp(), _stamp_block() / ← _ready() |
| 972 | `_draw()` | 마을 운영 · HUD · 육성 창 구성 | main.gd: _draw() | → _draw_text() |
| 996 | `_draw_text()` | 마을 운영 · HUD · 육성 창 구성 | 가운데 정렬 + 외곽선 텍스트 | ← _draw() |

## scripts/map_art.gd

| 줄 | 심볼 | 묶음 | 요약 | 호출함 → / ← 호출됨 |
|---:|---|---|---|---|
| 1 | `map_art.gd` | 기획서 · 육성 설계 | Super Retro World 외부 팩으로 마을 맵 그림을 그린다. |  |
| 10 | `PACK / TILE` | 스프라이트 · 직업 데이터 | 에셋 팩 경로와 타일 크기를 정의한다. |  |
| 14 | `AUTO / GRASS` | 맵 아트 | 오토타일 종류별 시트 위치와 풀 칸을 정의한다. |  |
| 21 | `PROPS` | 맵 아트 | 소품 이름별 시트 영역을 정의한다. |  |
| 44 | `_sheets / _own_tex` | 맵 아트 | 읽어 둔 시트와 텍스처 캐시를 담는다. |  |
| 47 | `available()` | 스프라이트 · 직업 데이터 | SRW 외부 팩이 있는지 확인한다. |  |
| 52 | `_sheet()` | 맵 아트 | 32px 시트를 16px로 줄이고 분홍을 투명으로 바꾼다. | ← autotile(), grass(), prop() |
| 69 | `own()` | 맵 아트 | assets/agra 자체 그림을 이미지로 읽는다. | ← own_tex() |
| 79 | `own_tex()` | 맵 아트 | 자체 그림을 텍스처로 만들어 캐시한다. | → own() / ← _draw(), _draw(), _draw_fx() |
| 85 | `grass()` | 맵 아트 | 풀 타일 한 칸을 찍는다. | → _sheet() |
| 90 | `prop()` | 맵 아트 | 소품 하나를 발밑 기준으로 찍는다. | → _sheet() |
| 98 | `autotile()` | 맵 아트 | VX Ace A2 오토타일 규칙으로 이어진 지형을 그린다. | → _sheet() |

## scripts/mercenary.gd

| 줄 | 심볼 | 묶음 | 요약 | 호출함 → / ← 호출됨 |
|---:|---|---|---|---|
| 1 | `mercenary.gd` | 기획서 · 육성 설계 | 쪼꼬미 용병: 탄생·낮 생활 AI·밤 전투·성장·그리기를 담당한다. |  |
| 6 | `preloads (JobData / Summon / CharSprites / MapArt / Deployment / StatBar)` | mercenary.gd: preloads (JobData / Summon / CharSprites / MapArt / Deployment / StatBar) | 직업·소환수·스프라이트·맵그림·배치·막대 스크립트를 미리 불러온다. |  |
| 14 | `FX / BOLT_TIME` | 맵 아트 | 공격·치유 효과 그림 정보와 원거리 탄환 비행 시간을 정한다. |  |
| 22 | `RETREAT_UNTIL` | 쪼꼬미 행동 · 전투 | 후퇴한 용병이 여관에 머무는 체력 기준을 정한다. |  |
| 25 | `NAMES` | 스프라이트 · 직업 데이터 | 성별별 용병 이름 목록이다. |  |
| 32 | `TRAIT_GROUPS` | 스프라이트 · 직업 데이터 | 함께 가질 수 없는 성격 특성 묶음이다. |  |
| 34 | `ACTION_PLACE / ACTION_LABEL` | 쪼꼬미 행동 · 전투 | 낮 행동별 장소와 표시 이름을 정한다. |  |
| 39 | `identity state vars (merc_name, job_id, tier, grade, stats, traits)` | mercenary.gd: identity state vars (merc_name, job_id, tier, grade, stats, traits) | 이름·성별·직업·단계·등급·능력치·특성 등 용병 정체성 상태다. |  |
| 49 | `combat stat vars (max_hp, hp, atk, defense, energy, hunger, morale)` | mercenary.gd: combat stat vars (max_hp, hp, atk, defense, energy, hunger, morale) | 체력·공격·방어·사거리·욕구·레벨 등 전투/생활 수치 상태다. |  |
| 65 | `behavior state vars (activity, retreating, defending, mode_lock, night_target)` | mercenary.gd: behavior state vars (activity, retreating, defending, mode_lock, night_target) | 행동·후퇴·성 방어·목표 고정·효과 재생 등 행동 상태다. |  |
| 89 | `post/path state vars (post_pos, path, path_goal, repath_cd)` | mercenary.gd: post/path state vars (post_pos, path, path_goal, repath_cd) | 밤에 지킬 칸과 경로 추적 상태다. |  |
| 98 | `roll_identity()` | 스프라이트 · 직업 데이터 | 태어날 때 직업·성별·이름·능력치·등급·특성을 무작위로 정한다. | → available(), grade_for_total(), job(), pick(), recalc(), stat_total() |
| 136 | `job()` | 스프라이트 · 직업 데이터 | 현재 직업 데이터를 돌려준다. | ← _draw(), gain_xp(), next_tier(), recalc(), roll_identity(), style(), title() |
| 140 | `style()` | 쪼꼬미 행동 · 전투 | 직업의 전투 방식을 돌려준다. | → job() / ← _attack(), _night(), _process(), leash(), on_night_start(), recalc() |
| 144 | `title()` | 스프라이트 · 직업 데이터 | 현재 전직 단계의 직업 이름을 돌려준다. | → job() / ← describe(), job_name() |
| 148 | `job_name()` | 스프라이트 · 직업 데이터 | 직업 이름(title)을 돌려준다. | → title() |
| 152 | `grade_info()` | 스프라이트 · 직업 데이터 | 등급 데이터를 돌려준다. | ← _draw(), describe(), gain_xp(), show_merc() |
| 156 | `stat_total()` | 스프라이트 · 직업 데이터 | 능력치 합계를 계산한다. | ← roll_identity() |
| 163 | `has_trait()` | 쪼꼬미 행동 · 전투 | 특정 성격 특성을 가졌는지 확인한다. | ← _choose_action(), _day(), _night(), _pick_target(), recalc(), take_damage() |
| 167 | `trait_text()` | mercenary.gd: trait_text() | 특성 목록을 쉼표 문자열로 만든다. |  |
| 172 | `recalc()` | 쪼꼬미 행동 · 전투 | 능력치·레벨·전직 단계로 전투 수치를 다시 계산한다. | → has_trait(), job(), style() / ← gain_xp(), promote(), roll_identity() |
| 192 | `xp_needed()` | 쪼꼬미 행동 · 전투 | 다음 레벨까지 필요한 경험치를 돌려준다. | ← gain_xp() |
| 197 | `next_tier()` | 스프라이트 · 직업 데이터 | 다음 전직 조건과 비용 정보를 돌려준다. | → job() / ← _draw(), gain_xp(), show_merc() |
| 207 | `meets_stat_req()` | mercenary.gd: meets_stat_req() | 다음 전직의 능력치 조건을 채웠는지 확인한다. |  |
| 211 | `promote()` | 쪼꼬미 행동 · 전투 | 전직 단계를 올리고 체력·사기를 회복한다. | → recalc() |
| 218 | `describe()` | 스프라이트 · 직업 데이터 | 등급·이름·레벨·직업을 한 줄 설명으로 만든다. | → grade_info(), title() |
| 224 | `_process()` | 쪼꼬미 행동 · 전투 | 매 프레임 쿨다운을 줄이고 낮/밤 행동을 고른다. | → _day(), _night() |
| 246 | `_day()` | 쪼꼬미 행동 · 전투 | 낮에 욕구를 갱신하고 고른 생활 행동을 수행한다. | → _choose_action(), _move_to(), gain_xp(), has_trait() / ← _process() |
| 286 | `_choose_action()` | 쪼꼬미 행동 · 전투 | 욕구와 성격 점수로 다음 낮 행동을 고른다(유틸리티 AI). | → building_pos(), has_trait() / ← _day() |
| 314 | `on_night_start()` | 쪼꼬미 행동 · 전투 | 밤이 시작되면 소환사는 소환수를 불러낸다. | → add_log(), setup(), style() |
| 330 | `clear_summons()` | mercenary.gd: clear_summons() | 불러낸 소환수를 모두 없앤다. | ← on_dawn() |
| 338 | `_night()` | 쪼꼬미 행동 · 전투 | 밤에 후퇴·치유·성 방어·복귀·교전 중 하나를 수행한다. | → _defend_hall(), _fight(), _move_to(), _pick_target(), _try_heal(), _update_defend(), has_p / ← _process() |
| 378 | `_update_defend()` | 쪼꼬미 행동 · 전투 | 성 위기에 따라 배치와 성 방어 모드를 전환한다. | → has_post() / ← _night() |
| 390 | `_defend_hall()` | 쪼꼬미 행동 · 전투 | 성 위기 때 영주관 쪽 마물을 막으러 간다. | → _fight(), _move_to(), _nearest_monster(), hall_threat() / ← _night() |
| 407 | `_nearest_monster()` | 쪼꼬미 행동 · 전투 | 반경 안에서 가장 가까운 마물을 찾는다. | ← _defend_hall() |
| 418 | `_fight()` | 쪼꼬미 행동 · 전투 | 목표에 다가가 사거리에 들면 공격한다(leash 제한). | → _attack(), _leashed(), _move_to() / ← _defend_hall(), _night() |
| 435 | `_attack()` | 쪼꼬미 행동 · 전투 | 전투 방식별 효과를 내고 마물에게 피해를 준다. | → _play_fx(), style(), take_damage() / ← _fight() |
| 458 | `has_post()` | 쪼꼬미 행동 · 전투 | 배치 칸이 있는지 확인한다. | ← _in_zone(), _leashed(), _night(), _pick_target(), _update_defend() |
| 462 | `post_center()` | 쪼꼬미 행동 · 전투 | 배치 칸의 중심 좌표를 돌려준다. | → cell_center() / ← _in_zone(), _leashed(), _night(), _pick_target() |
| 466 | `leash()` | 쪼꼬미 행동 · 전투 | 전투 방식별 leash 거리를 돌려준다. | → leash_px(), style() / ← _in_zone(), _leashed(), _night(), _pick_target() |
| 471 | `_leashed()` | 쪼꼬미 행동 · 전투 | 목표 지점을 배치 칸 leash 원 안으로 끌어당긴다. | → has_post(), leash(), post_center() / ← _fight(), _try_heal() |
| 480 | `_in_zone()` | 쪼꼬미 행동 · 전투 | 지점이 배치 칸의 교전 구역 안인지 확인한다. | → has_post(), leash(), post_center() / ← _pick_target() |
| 484 | `_pick_target()` | 쪼꼬미 행동 · 전투 | 친구 구출 우선, 아니면 배치 칸 기준 가장 가까운 마물을 고른다. | → _in_zone(), has_post(), has_trait(), leash(), post_center() / ← _night() |
| 503 | `_try_heal()` | 쪼꼬미 행동 · 전투 | 다친 동료를 찾아 치유한다. | → _leashed(), _move_to(), _play_fx(), gain_xp() / ← _night() |
| 529 | `take_damage()` | 쪼꼬미 행동 · 전투 | 방어로 줄인 피해를 받고 사기를 깎으며 쓰러짐을 처리한다. | → add_log(), has_trait() / ← _process() |
| 546 | `gain_xp()` | 쪼꼬미 행동 · 전투 | 경험치를 얻고 레벨업 시 능력치를 올린다. | → add_log(), grade_info(), job(), next_tier(), recalc(), xp_needed() / ← _day(), _try_heal(), gain_xp(), take_damage() |
| 564 | `on_dawn()` | mercenary.gd: clear_summons() | 새벽에 전투 상태를 초기화하고 쓰러진 용병을 일으킨다. | → clear_summons() |
| 580 | `_move_to()` | 쪼꼬미 행동 · 전투 | 기력에 따라 속도를 정해 목표로 이동한다. | → _follow() / ← _day(), _defend_hall(), _fight(), _night(), _try_heal() |
| 587 | `_follow()` | 배치 · 성 위기 · 배속 | 길찾기 경로를 따라 이동하고 방향을 갱신한다. | → find_path(), is_walkable() / ← _move_to() |
| 615 | `_draw()` | 스프라이트 · 직업 데이터 | 용병 스프라이트·등급 표시·HP 바·이름·행동을 그린다. | → _draw_fx(), _label(), draw_bar(), frame_rect(), grade_info(), hp_color(), sheet(), tile_sr |
| 669 | `_play_fx()` | 쪼꼬미 행동 · 전투 | 재생할 공격/치유 효과를 설정한다. | ← _attack(), _try_heal() |
| 676 | `_draw_fx()` | 맵 아트 | 원거리 탄환과 효과 애니메이션을 그린다. | → own_tex() / ← _draw() |
| 695 | `_label()` | 스프라이트 · 직업 데이터 | 외곽선 있는 글자를 가운데 정렬로 그린다. | ← _draw() |

## scripts/monster.gd

| 줄 | 심볼 | 묶음 | 요약 | 호출함 → / ← 호출됨 |
|---:|---|---|---|---|
| 1 | `monster.gd` | 기획서 · 육성 설계 | 균열에서 나와 용병과 영주관을 공격하는 마물이다. |  |
| 6 | `preload MapArt` | monster.gd: preload MapArt | 맵 그림 스크립트를 미리 불러온다. |  |
| 9 | `KINDS` | monster.gd: KINDS | 마물 종류별 그림 크기와 능력치 배율이다. |  |
| 17 | `NORMAL_KINDS / ELITE_KINDS / WALK` | monster.gd: NORMAL_KINDS / ELITE_KINDS / WALK | 일반·엘리트 종류 목록과 걷기 프레임이다. |  |
| 21 | `state vars (max_hp, hp, atk, speed, elite, body_size, path)` | monster.gd: state vars (max_hp, hp, atk, speed, elite, body_size, path) | 체력·공격·속도·엘리트·보상·경로 상태다. |  |
| 39 | `setup()` | monster.gd: KINDS | 날짜와 엘리트 여부로 마물 능력치와 종류를 정한다. |  |
| 60 | `_process()` | 쪼꼬미 행동 · 전투 | 가까운 용병(도발 우선)을 공격하고 없으면 영주관을 친다. | → _move_to(), damage_hall(), style(), take_damage(), take_damage() |
| 99 | `_move_to()` | 쪼꼬미 행동 · 전투 | 속도에 맞춰 목표로 이동한다. | → _follow() / ← _process() |
| 103 | `_follow()` | 배치 · 성 위기 · 배속 | 길찾기 경로를 따라 이동한다. | → find_path(), is_walkable() / ← _move_to() |
| 122 | `take_damage()` | 쪼꼬미 행동 · 전투 | 피해를 받고 죽으면 공격자에게 경험치를 준다. | → gain_xp(), gain_xp(), on_monster_killed() / ← _attack(), _process() |
| 133 | `_draw()` | 맵 아트 | 마물 그림과 HP 바를 그린다. | → own_tex() |

## scripts/stat_bar.gd

| 줄 | 심볼 | 묶음 | 요약 | 호출함 → / ← 호출됨 |
|---:|---|---|---|---|
| 1 | `stat_bar.gd` | 기획서 · 육성 설계 | 능력치 줄과 HP 바가 함께 쓰는 작은 픽셀 막대다. |  |
| 5 | `COL_BACK / COL_EDGE / COL_TICK` | stat_bar.gd: COL_BACK / COL_EDGE / COL_TICK | 막대 배경·테두리·눈금 색이다. |  |
| 15 | `set_bar()` | 스프라이트 · 직업 데이터 | 막대 비율·색·테두리·눈금을 바꾸고 다시 그린다. | ← show_merc() |
| 25 | `_draw()` | 스프라이트 · 직업 데이터 | 자기 크기에 맞게 막대를 그린다. | → draw_bar() |
| 30 | `draw_bar()` | 스프라이트 · 직업 데이터 | 아무 CanvasItem에 픽셀 막대를 그린다. | ← _draw(), _draw() |
| 43 | `hp_color()` | 스프라이트 · 직업 데이터 | 체력 비율에 따라 빨강→노랑→초록 색을 돌려준다. | ← _draw() |

## scripts/stat_panel.gd

| 줄 | 심볼 | 묶음 | 요약 | 호출함 → / ← 호출됨 |
|---:|---|---|---|---|
| 1 | `stat_panel.gd` | 기획서 · 육성 설계 | 육성 창의 능력치 5종 줄을 그린다. |  |
| 7 | `preloads (StatBar / JobData)` | stat_panel.gd: preloads (StatBar / JobData) | 막대와 직업 데이터 스크립트를 미리 불러온다. |  |
| 10 | `ROW_H / NAME_W / BAR_W / BAR_H / NUM_W / FONT_SIZE / FLASH_MS` | stat_panel.gd: ROW_H / NAME_W / BAR_W / BAR_H / NUM_W / FONT_SIZE / FLASH_MS | 줄 높이·폭·글자 크기·깜빡임 시간 등 배치 상수다. |  |
| 17 | `STAT_COLORS` | 스프라이트 · 직업 데이터 | 능력치별 막대 색이다. |  |
| 21 | `COL_TEXT / COL_PRIMARY / COL_OK / COL_LACK / COL_UP / COL_DARK` | stat_panel.gd: COL_TEXT / COL_PRIMARY / COL_OK / COL_LACK / COL_UP / COL_DARK | 글자·주능력치·충족·미달·상승 색이다. |  |
| 28 | `state vars (_bars, _merc, _last, _up, _up_until)` | stat_panel.gd: state vars (_bars, _merc, _last, _up, _up_until) | 막대·보는 용병·직전 값·상승량 기록 상태다. |  |
| 36 | `setup()` | 마을 운영 · HUD · 육성 창 구성 | 능력치마다 막대를 만들어 붙인다. | ← _build_growth_panel() |
| 51 | `show_merc()` | 스프라이트 · 직업 데이터 | 용병 능력치로 막대를 갱신하고 오른 양을 기록한다. | → _req_for(), grade_info(), next_tier(), set_bar(), stat_cap() / ← _update_growth_panel() |
| 76 | `_req_for()` | 스프라이트 · 직업 데이터 | 다음 전직에서 이 능력치 목표치를 돌려준다. | ← _draw(), show_merc() |
| 82 | `_draw()` | 스프라이트 · 직업 데이터 | 능력치 이름·숫자·목표·+n 표시를 그린다. | → _req_for(), job(), next_tier() |
| 106 | `flashing()` | 기획서 · 육성 설계 | 지금 +n이 떠 있는 능력치를 돌려준다(테스트용). | ← _process() |

## scripts/summon.gd

| 줄 | 심볼 | 묶음 | 요약 | 호출함 → / ← 호출됨 |
|---:|---|---|---|---|
| 1 | `summon.gd` | 기획서 · 육성 설계 | 소환사가 밤마다 부르는 정령이다. |  |
| 5 | `preload MapArt` | summon.gd: preload MapArt | 맵 그림 스크립트를 미리 불러온다. |  |
| 7 | `TIER_TINT` | 쪼꼬미 행동 · 전투 | 단계별 정령 색이다. |  |
| 9 | `state vars (summoner, max_hp, hp, atk, speed, downed)` | summon.gd: state vars (summoner, max_hp, hp, atk, speed, downed) | 소환사·체력·공격·속도 등 정령 상태다. |  |
| 23 | `setup()` | 쪼꼬미 행동 · 전투 | 지능·레벨·단계로 정령 능력치를 정한다. | ← on_night_start() |
| 30 | `_process()` | 쪼꼬미 행동 · 전투 | 소환사 근처 마물을 쫓아 공격하고 없으면 곁으로 돌아온다. | → _move(), take_damage() |
| 59 | `_move()` | 쪼꼬미 행동 · 전투 | 건물을 통과해 목표로 날아간다. | ← _process() |
| 65 | `take_damage()` | 쪼꼬미 행동 · 전투 | 피해를 받고 죽으면 목록에서 빠진다. | ← _process() |
| 76 | `gain_xp()` | 쪼꼬미 행동 · 전투 | 얻은 경험치를 소환사에게 넘긴다. | → gain_xp() / ← take_damage() |
| 81 | `_draw()` | 맵 아트 | 정령 그림과 HP 바를 그린다. | → own_tex() |

## scripts/wave_director.gd

| 줄 | 심볼 | 묶음 | 요약 | 호출함 → / ← 호출됨 |
|---:|---|---|---|---|
| 1 | `wave_director.gd` | 밤 파도 · 새벽 정산 · 낮밤 순환 | 밤 파도와 휴식: 그날 밤 마물을 파도 2~3개로 나누고, 파도 사이에 쉬게 한다. |  |
| 45 | `setup()` | 마을 운영 · HUD · 육성 창 구성 | main._build_hud() 뒤에 부른다. | ← _ready() |
| 55 | `base_total()` | 밤 파도 · 새벽 정산 · 낮밤 순환 | wave_director.gd: base_total() | ← night_total_for() |
| 59 | `night_total_for()` | 밤 파도 · 새벽 정산 · 낮밤 순환 | wave_director.gd: night_total_for() | → base_total() / ← night_preview(), wave_sizes() |
| 63 | `has_elite()` | 밤 파도 · 새벽 정산 · 낮밤 순환 | wave_director.gd: has_elite() | ← night_preview(), update_night(), wave_info() |
| 68 | `wave_sizes()` | 밤 파도 · 새벽 정산 · 낮밤 순환 | 파도별 마물 수. 나머지는 뒤 파도부터 하나씩 더 얹는다 (뒤로 갈수록 세게). | → night_total_for() / ← night_preview(), start_night() |
| 82 | `night_preview()` | 밤 파도 · 새벽 정산 · 낮밤 순환 | 오늘(또는 d일) 밤 예고: {total, elite, kind, waves} | → has_elite(), night_total_for(), wave_sizes() |
| 89 | `wave_info()` | 밤 파도 · 새벽 정산 · 낮밤 순환 | 지금 밤 진행: {wave(1부터), waves, remaining, total, killed, resting, rest_left, elite} | → has_elite() / ← _process(), night_intro() |
| 101 | `is_last_wave()` | 밤 파도 · 새벽 정산 · 낮밤 순환 | wave_director.gd: is_last_wave() | ← update_night() |
| 106 | `wants_pause()` | 배치 · 성 위기 · 배속 | 시간을 멈춰야 하는가: 새벽 정산 중, 또는 낮에 육성 창/배치(쪼꼬미 선택)가 열려 있는 동안. | ← speed_override() |
| 116 | `start_night()` | 밤 파도 · 새벽 정산 · 낮밤 순환 | wave_director.gd: start_night() | → _begin_wave(), wave_sizes() / ← _start_night() |
| 127 | `_begin_wave()` | 밤 파도 · 새벽 정산 · 낮밤 순환 | wave_director.gd: _begin_wave() | → add_log() / ← start_night(), update_night() |
| 137 | `update_night()` | 밤 파도 · 새벽 정산 · 낮밤 순환 | wave_director.gd: update_night() | → _begin_wave(), _spawn_monster(), _start_dawn(), add_log(), has_elite(), is_last_wave() / ← _process() |
| 160 | `on_kill()` | 밤 파도 · 새벽 정산 · 낮밤 순환 | wave_director.gd: on_kill() | → _start_dawn() / ← on_monster_killed() |
| 168 | `enter_dawn()` | 밤 파도 · 새벽 정산 · 낮밤 순환 | main._start_dawn()이 임금·부활 처리 전에 부른다 (쓰러진 수를 세려고). | ← _start_dawn() |
| 185 | `show_dawn()` | 밤 파도 · 새벽 정산 · 낮밤 순환 | main._start_dawn()이 임금 처리까지 끝낸 뒤 부른다. | → continue_day(), show_report() / ← _start_dawn() |
| 194 | `continue_day()` | 마을 운영 · HUD · 육성 창 구성 | "낮 시작" 버튼 / Space. | → _begin_day() / ← _on_start(), _process(), _unhandled_input(), show_dawn() |

## scripts/wave_hud.gd

| 줄 | 심볼 | 묶음 | 요약 | 호출함 → / ← 호출됨 |
|---:|---|---|---|---|
| 1 | `wave_hud.gd` | 일차·웨이브 HUD | 일차·웨이브 HUD: 상단 중앙 배너 + 밤 시작 연출 + 균열 위 남은 마물 수. |  |
| 32 | `setup()` | 일차·웨이브 HUD | wave_hud.gd: setup() | → _label() / ← _build_hud() |
| 71 | `_label()` | 일차·웨이브 HUD | wave_hud.gd: _label() | ← setup() |
| 82 | `_process()` | 일차·웨이브 HUD | wave_hud.gd: _process() | → refresh() |
| 89 | `refresh()` | 일차·웨이브 HUD | 배너 글자와 바를 지금 상태로 맞춘다 (테스트에서도 부른다). | ← _process() |
| 112 | `night_intro()` | 밤 파도 · 새벽 정산 · 낮밤 순환 | 밤 시작 연출: 가운데 큰 글씨 → 약 2초 뒤 사라진다. 시간·입력은 막지 않는다. | → wave_info() / ← _start_night() |
| 128 | `class RiftCounts` | wave_hud.gd: class RiftCounts | 균열마다 거기서 나온 살아 있는 마물 수 (밤에만). 맵 좌표에 그리므로 카메라를 따라 움직인다. |  |
| 131 | `RiftCounts._ready()` | 일차·웨이브 HUD | wave_hud.gd: RiftCounts._ready() |  |
| 134 | `RiftCounts.counts()` | 일차·웨이브 HUD | wave_hud.gd: RiftCounts.counts() | ← RiftCounts._draw() |
| 143 | `RiftCounts._process()` | 일차·웨이브 HUD | wave_hud.gd: RiftCounts._process() |  |
| 146 | `RiftCounts._draw()` | 일차·웨이브 HUD | wave_hud.gd: RiftCounts._draw() | → RiftCounts.counts() |

## tests/follow_shots.gd

| 줄 | 심볼 | 묶음 | 요약 | 호출함 → / ← 호출됨 |
|---:|---|---|---|---|
| 1 | `follow_shots.gd` | 밤 파도 · 새벽 정산 · 낮밤 순환 | 따라가기 카메라 스크린샷 (창이 잠깐 뜬다). |  |
| 11 | `_initialize()` | 밤 파도 · 새벽 정산 · 낮밤 순환 | follow_shots.gd: _initialize() |  |
| 19 | `_process()` | 밤 파도 · 새벽 정산 · 낮밤 순환 | follow_shots.gd: _process() | → _save(), _start_night(), auto_deploy(), select() |
| 51 | `_save()` | 밤 파도 · 새벽 정산 · 낮밤 순환 | follow_shots.gd: _save() | ← _process() |

## tests/growth_test.gd

| 줄 | 심볼 | 묶음 | 요약 | 호출함 → / ← 호출됨 |
|---:|---|---|---|---|
| 1 | `growth_test.gd` | 검증 · 테스트 · 명령 | 육성 시스템 테스트: 등급 분포, 레벨업, 전직, 방출, 소환수. |  |
| 14 | `check()` | 검증 · 테스트 · 명령 | growth_test.gd: check() | ← _initialize(), _process() |
| 20 | `_initialize()` | 검증 · 테스트 · 명령 | growth_test.gd: _initialize() | → check() |
| 21 | `구역 1` | 기획서 · 육성 설계 | 등급 분포: 3000번 탄생 |  |
| 64 | `_process()` | 마을 운영 · HUD · 육성 창 구성 | growth_test.gd: _process() | → _on_speed(), _process(), _spawn_merc(), _start_dawn(), _start_night(), _unhandled_input(), |
| 68 | `구역 2` | 검증 · 테스트 · 명령 | 레벨업 → 전직 |  |
| 88 | `구역 3` | 검증 · 테스트 · 명령 | 방출 |  |
| 97 | `구역 4` | 검증 · 테스트 · 명령 | 소환사 |  |
| 108 | `구역 5` | 검증 · 테스트 · 명령 | 소환수가 마물을 잡으면 경험치는 소환사에게 (크래시 없음) |  |
| 123 | `구역 6` | 검증 · 테스트 · 명령 | 전직 버튼 조건 = 실제 전직 조건 |  |
| 132 | `구역 7` | 검증 · 테스트 · 명령 | 후퇴: 기준을 막 넘었다고 바로 나가지 않는다 |  |
| 146 | `구역 8` | 쪼꼬미 행동 · 전투 | 식량이 없으면 식당에 가지 않는다 |  |
| 157 | `구역 9` | 검증 · 테스트 · 명령 | 모든 균열에서 영주관 공격 범위까지 길이 닿는다 |  |
| 163 | `구역 10` | 검증 · 테스트 · 명령 | 배치: 클릭 → 16px 칸에 스냅, 막힌 곳·HUD 거부, 같은 쪼꼬미 다시 클릭 → 해제 |  |
| 182 | `구역 11` | 검증 · 테스트 · 명령 | 밤: 배치된 쪼꼬미는 leash 밖으로 쫓아가지 않는다 |  |
| 221 | `구역 12` | 검증 · 테스트 · 명령 | 자동 배치: 모두 다른 칸, 전열(근접)이 후열보다 영주관에서 멀다 |  |
| 241 | `구역 13` | 검증 · 테스트 · 명령 | (c) 우상단: 오른쪽 메뉴 버튼 밑 칸은 HUD가 보이면 거부, 숨기면 배치. 메뉴 아래 빈 곳은 그냥 배치 |  |
| 253 | `구역 14` | 검증 · 테스트 · 명령 | (b) 밤에도 배치: 지정하면 그 칸으로 길을 찾아 간다. 고르는 동안 시간은 0.2배, 배속은 끝나면 복구 |  |
| 273 | `구역 15` | 배치 · 성 위기 · 배속 | (a) 성 위기: 영주관 옆 마물 → 멀리 배치된 쪼꼬미가 떠나 접근, 위기가 끝나면 복귀 |  |
| 309 | `구역 16` | 검증 · 테스트 · 명령 | 능력치 바 · 전직 능력치 조건 · "+n" 표시 |  |
| 334 | `구역 17` | 검증 · 테스트 · 명령 | 휴식 구간: 새벽 정지 · 낮 결정 창 정지 · 파도 분할 · 파도 사이 휴식 |  |
| 430 | `구역 18` | 검증 · 테스트 · 명령 | 일차·웨이브 HUD: 배너 글자, 클릭 통과, 밤 시작 연출, 새벽 요약 |  |
| 463 | `구역 19` | 검증 · 테스트 · 명령 | 따라가기 카메라: 클릭 좌표 변환 · 쓰러져도 유지 · 정수 배율 · 배속 무관 |  |

## tests/hud_shots.gd

| 줄 | 심볼 | 묶음 | 요약 | 호출함 → / ← 호출됨 |
|---:|---|---|---|---|
| 1 | `hud_shots.gd` | 밤 파도 · 새벽 정산 · 낮밤 순환 | 일차·웨이브 HUD 스크린샷 (창이 잠깐 뜬다). |  |
| 11 | `_initialize()` | 밤 파도 · 새벽 정산 · 낮밤 순환 | hud_shots.gd: _initialize() |  |
| 19 | `_process()` | 밤 파도 · 새벽 정산 · 낮밤 순환 | hud_shots.gd: _process() | → _save(), _start_night(), auto_deploy(), wave_info() |
| 55 | `_save()` | 밤 파도 · 새벽 정산 · 낮밤 순환 | hud_shots.gd: _save() | ← _process() |

## tests/screenshot.gd

| 줄 | 심볼 | 묶음 | 요약 | 호출함 → / ← 호출됨 |
|---:|---|---|---|---|
| 1 | `screenshot.gd` | 프로젝트 · 스크린샷 | 실제 렌더링 화면을 deploy·growth·day·hud_hidden·night·battle PNG로 저장한다. |  |
| 11 | `_initialize()` | 프로젝트 · 스크린샷 | 출력 폴더 인자를 읽고 메인 씬을 띄운다. |  |
| 19 | `_process()` | 프로젝트 · 스크린샷 | 프레임별로 장면을 연출하며 스크린샷 6장을 찍는다. | → _save() |
| 64 | `_save()` | 프로젝트 · 스크린샷 | 뷰포트 이미지를 PNG 파일로 저장한다. | ← _process() |

## tests/smoke_test.gd

| 줄 | 심볼 | 묶음 | 요약 | 호출함 → / ← 호출됨 |
|---:|---|---|---|---|
| 1 | `smoke_test.gd` | 검증 · 테스트 · 명령 | 헤드리스 스모크 테스트: 메인 씬을 띄우고 며칠을 빠르게 돌려 본다. |  |
| 18 | `_initialize()` | 검증 · 테스트 · 명령 | smoke_test.gd: _initialize() |  |
| 24 | `_process()` | 검증 · 테스트 · 명령 | smoke_test.gd: _process() | → _on_recruit(), _on_repair(), _report(), auto_deploy(), is_walkable() |
| 60 | `_report()` | 검증 · 테스트 · 명령 | smoke_test.gd: _report() | ← _process() |
