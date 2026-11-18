# Graph Report - AgraChronicles  (2026-11-18)

## Corpus Check
- 11 files · ~0 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 358 nodes · 644 edges · 46 communities (10 shown, 36 thin omitted)
- Extraction: 92% EXTRACTED · 8% INFERRED · 0% AMBIGUOUS · INFERRED: 51 edges (avg confidence: 0.88)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `58c37c40`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- 마을 운영 · HUD · 육성 창 구성
- 쪼꼬미 행동 · 전투
- 기획서 · 육성 설계
- 밤 파도 · 새벽 정산 · 낮밤 순환
- 스프라이트 · 직업 데이터
- 검증 · 테스트 · 명령
- 배치 · 성 위기 · 배속
- 따라가기 카메라
- 맵 아트
- 일차·웨이브 HUD
- 프로젝트 · 스크린샷
- monster.gd: KINDS
- deployment.gd: CRISIS_TILES / CRISIS_HIT_SECS
- deployment.gd: FLAG / POLE
- deployment.gd: LEASH_TILES / LEASH_DEFAULT
- deployment.gd: NIGHT_EDIT_SPEED
- deployment.gd: ROW_DIST / ROW_OF_STYLE
- deployment.gd: TILE
- follow_cam.gd: class Overlay
- job_data.gd: STATS / STAT_NAMES
- job_data.gd: TIER_MULT / PROMOTE_RESIDUE / PROMOTE_GOLD / PROMOTE_STAT
- main.gd: buildings / hall_rect / rifts
- main.gd: COL_TEXT / COL_DARK
- main.gd: WORLD_SIZE / TILE / DAY_LENGTH / HALL_MAX_HP / RECRUIT_COST / WAGE_PER_MERC / MAX_MERCS / TRAIN_SUPPORT_COST / VACATION_COST
- main.gd: hud_root / hud_body / growth_panel / stat_panel / promote_button / dismiss_button
- main.gd: Mercenary / Monster / JobData / MapArt / Deployment / StatPanel / TOWN_TEX / DUNGEON_TEX
- main.gd: gold / food / wood / residue / day / is_night / phase_time / hall_hp
- mercenary.gd: behavior state vars (activity, retreating, defending, mode_lock, night_target)
- mercenary.gd: combat stat vars (max_hp, hp, atk, defense, energy, hunger, morale)
- mercenary.gd: identity state vars (merc_name, job_id, tier, grade, stats, traits)
- mercenary.gd: post/path state vars (post_pos, path, path_goal, repath_cd)
- mercenary.gd: preloads (JobData / Summon / CharSprites / MapArt / Deployment / StatBar)
- monster.gd: NORMAL_KINDS / ELITE_KINDS / WALK
- monster.gd: preload MapArt
- monster.gd: state vars (max_hp, hp, atk, speed, elite, body_size, path)
- stat_bar.gd: COL_BACK / COL_EDGE / COL_TICK
- stat_panel.gd: COL_TEXT / COL_PRIMARY / COL_OK / COL_LACK / COL_UP / COL_DARK
- stat_panel.gd: ROW_H / NAME_W / BAR_W / BAR_H / NUM_W / FONT_SIZE / FLASH_MS
- stat_panel.gd: preloads (StatBar / JobData)
- stat_panel.gd: state vars (_bars, _merc, _last, _up, _up_until)
- summon.gd: preload MapArt
- summon.gd: state vars (summoner, max_hp, hp, atk, speed, downed)
- wave_hud.gd: class RiftCounts

## God Nodes (most connected - your core abstractions)
1. `main.gd: add_log()` - 23 edges
2. `growth_test.gd: _process()` - 20 edges
3. `mercenary.gd: _night()` - 14 edges
4. `README: 구조` - 14 edges
5. `mercenary.gd: gain_xp()` - 11 edges
6. `screenshot.gd: _process()` - 10 edges
7. `main.gd: _start_night()` - 10 edges
8. `deployment.gd: auto_deploy()` - 10 edges
9. `mercenary.gd: roll_identity()` - 9 edges
10. `main.gd: _ready()` - 9 edges

## Surprising Connections (you probably didn't know these)
- `인수인계: 검증 방법` --semantically_similar_to--> `README: 헤드리스 테스트`  [INFERRED] [semantically similar]
  docs/인수인계.md → README.md
- `기획서: 밤 후퇴 규칙` --implements--> `mercenary.gd: _night()`  [INFERRED]
  docs/기획서_v0.5.md → scripts/mercenary.gd
- `기획서: 방출` --implements--> `main.gd: dismiss_merc()`  [INFERRED]
  docs/기획서_v0.5.md → scripts/main.gd
- `README: Super Retro World 팩 넣기` --semantically_similar_to--> `인수인계: 라이선스 — 반드시 지킬 것`  [INFERRED] [semantically similar]
  README.md → docs/인수인계.md
- `기획서: 웨이브 강도 공식` --implements--> `main.gd: _spawn_monster()`  [INFERRED]
  docs/기획서_v0.5.md → scripts/main.gd

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **낮/밤 순환과 균열 침공** — scripts_main_process, scripts_main_start_night, scripts_main_update_lighting, scripts_main_spawn_monster, scripts_main_start_dawn, scripts_main_begin_day, scripts_wave_director_start_night, scripts_wave_director_update_night, scripts_wave_director_enter_dawn, scripts_wave_director_continue_day [EXTRACTED 1.00]
- **정적 맵 합성과 격자 길찾기** — scripts_main_compose_static, scripts_main_compose_srw, scripts_main_road_cells, scripts_main_place_buildings, scripts_main_build_nav, scripts_main_cell_of, scripts_main_is_walkable, scripts_main_find_path [EXTRACTED 1.00]
- **HUD/육성 창 흐름** — scripts_main_build_hud, scripts_main_build_growth_panel, scripts_main_growth_bbcode, scripts_main_update_growth_panel, scripts_main_can_promote, scripts_main_try_promote, scripts_main_select [EXTRACTED 1.00]
- **밤 배치·leash·성 위기 방어 흐름** — scripts_mercenary_night, scripts_mercenary_update_defend, scripts_mercenary_defend_hall, scripts_mercenary_fight, scripts_mercenary_leashed, scripts_mercenary_post_center, scripts_deployment_update_crisis, scripts_deployment_hall_threat, scripts_deployment_leash_px, scripts_deployment_switch_hold [EXTRACTED 1.00]
- **능력치·HP 막대 표시** — scripts_stat_panel_show_merc, scripts_stat_panel_draw, scripts_stat_bar_set_bar, scripts_stat_bar_draw_bar, scripts_stat_bar_hp_color, scripts_mercenary_draw [EXTRACTED 1.00]
- **전투 피해·경험치 흐름** — scripts_mercenary_attack, scripts_monster_take_damage, scripts_monster_process, scripts_mercenary_take_damage, scripts_summon_process, scripts_summon_take_damage, scripts_summon_gain_xp, scripts_mercenary_gain_xp [INFERRED 0.85]
- **전직 조건 (레벨·주 능력치·잔재·금화)과 능력치 바** — docs_design_v0_5_promotion_cost, docs_design_v0_5_promotion_stat_requirement, docs_design_v0_5_stat_bars, scripts_main_can_promote, scripts_main_try_promote, scripts_stat_panel, tests_growth_test_section_2, tests_growth_test_section_6, tests_growth_test_section_16 [INFERRED 0.85]
- **Super Retro World 라이선스 준수 (재배포·AI 입력 금지, Kenney 대체)** — docs_design_v0_5_srw_license_rules, docs_handoff_srw_license_rules, readme_srw_pack_install, readme_asset_credits, scripts_char_sprites, scripts_map_art [INFERRED 0.85]
- **쪼꼬미별 배치 시스템 (클릭·leash·성 위기·밤 저속·자동 배치)** — docs_design_v0_5_deployment_leash, docs_design_v0_5_castle_crisis, docs_design_v0_5_night_deploy_slowmo, docs_design_v0_5_auto_deploy, scripts_deployment_handle_click, scripts_deployment_update_crisis, scripts_deployment_auto_deploy, tests_growth_test_section_10, tests_growth_test_section_11, tests_growth_test_section_12, tests_growth_test_section_14, tests_growth_test_section_15 [INFERRED 0.95]
- **밤 파도·휴식·새벽 정산 흐름** — scripts_wave_director_wave_sizes, scripts_wave_director_begin_wave, scripts_wave_director_update_night, scripts_wave_director_wants_pause, scripts_deployment_speed_override, scripts_dawn_panel_show_report, scripts_wave_director_show_dawn, scripts_wave_hud_refresh, scripts_wave_hud_night_intro [EXTRACTED 1.00]
- **따라가기 카메라와 화면↔맵 좌표 변환** — scripts_follow_cam_start, scripts_follow_cam_stop, scripts_follow_cam_set_zoom_level, scripts_follow_cam_hall_alert, scripts_main_screen_to_world, scripts_main_world_to_screen, scripts_deployment_ui_blocks, scripts_main_merc_at [EXTRACTED 1.00]

## Communities (46 total, 36 thin omitted)

### Community 0 - "마을 운영 · HUD · 육성 창 구성"
Cohesion: 0.08
Nodes (52): 기획서: 전직 비용, deployment.gd: note_hall_hit(), follow_cam.gd: setup(), main.gd: _add_button(), main.gd: add_log(), main.gd: _begin_day(), main.gd: _build_growth_panel(), main.gd: _build_hud() (+44 more)

### Community 1 - "쪼꼬미 행동 · 전투"
Cohesion: 0.08
Nodes (38): 기획서: 낮 행동 유틸리티 AI, deployment.gd: ENGAGE_PAD, deployment.gd: state vars (hall_crisis, last_hall_hit, _saved_speed), deployment.gd: SWITCH_HOLD, main.gd: building_pos(), mercenary.gd: ACTION_PLACE / ACTION_LABEL, mercenary.gd: _attack(), mercenary.gd: _choose_action() (+30 more)

### Community 2 - "기획서 · 육성 설계"
Cohesion: 0.08
Nodes (26): 기획서: 0. 변경 사항, 기획서: 방출, 기획서: 능력치 5종, 기획서: 등급별 능력치 상한, 기획서: 등급 (노말·엘리트·히어로·레전더리), 기획서: 육성 창, 기획서: 전투 중 HP 바, 기획서: 부상과 사망 (+18 more)

### Community 3 - "밤 파도 · 새벽 정산 · 낮밤 순환"
Cohesion: 0.09
Nodes (29): 기획서: 핵심 플레이 루프 (낮/밤), 기획서: 웨이브 강도 공식, dawn_panel.gd: _label(), dawn_panel.gd: _on_start(), dawn_panel.gd: _ready(), dawn_panel.gd: show_report(), dawn_panel.gd: summary_text(), main.gd: on_monster_killed() (+21 more)

### Community 4 - "스프라이트 · 직업 데이터"
Cohesion: 0.07
Nodes (28): char_sprites.gd: available(), char_sprites.gd: _cache, char_sprites.gd: CHARS, char_sprites.gd: frame_rect(), char_sprites.gd: PACK_DIR / FRAME / Dir / WALK, char_sprites.gd: path_of(), char_sprites.gd: pick(), char_sprites.gd: sheet() (+20 more)

### Community 5 - "검증 · 테스트 · 명령"
Cohesion: 0.08
Nodes (30): 기획서: 자동 배치, 기획서: 쪼꼬미별 배치·leash, 기획서: 밤 배치 0.2배속, 기획서: 밤 후퇴 규칙, 기획서: 플레이어 명령 (지시형), 기획서: 전직 능력치 조건, 기획서: Tab HUD 숨김, 인수인계: 검증 방법 (+22 more)

### Community 6 - "배치 · 성 위기 · 배속"
Cohesion: 0.11
Nodes (28): 기획서: 성 위기, deployment.gd: auto_deploy(), deployment.gd: base_speed(), deployment.gd: _blocks(), deployment.gd: cell_center(), deployment.gd: _draw(), deployment.gd: _free_cell(), deployment.gd: hall_dist() (+20 more)

### Community 7 - "따라가기 카메라"
Cohesion: 0.23
Nodes (18): follow_cam.gd: clamp_center(), follow_cam.gd: cycle(), follow_cam.gd: hall_alert(), follow_cam.gd: is_following(), follow_cam.gd: Overlay._draw(), follow_cam.gd: Overlay._draw_hall_arrow(), follow_cam.gd: _process(), follow_cam.gd: say() (+10 more)

### Community 8 - "맵 아트"
Cohesion: 0.18
Nodes (12): map_art.gd: AUTO / GRASS, map_art.gd: autotile(), map_art.gd: grass(), map_art.gd: own_tex(), map_art.gd: prop(), map_art.gd: PROPS, map_art.gd: _sheet(), map_art.gd: _sheets / _own_tex (+4 more)

### Community 9 - "일차·웨이브 HUD"
Cohesion: 0.31
Nodes (6): wave_hud.gd: _label(), wave_hud.gd: _process(), wave_hud.gd: refresh(), wave_hud.gd: RiftCounts._draw(), wave_hud.gd: RiftCounts.counts(), wave_hud.gd: setup()

## Knowledge Gaps
- **59 isolated node(s):** `monster.gd: KINDS`, `summon.gd: TIER_TINT`, `mercenary.gd: post/path state vars (post_pos, path, path_goal, repath_cd)`, `README: 에셋 출처`, `job_data.gd: TIER_MULT / PROMOTE_RESIDUE / PROMOTE_GOLD / PROMOTE_STAT` (+54 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 89 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **36 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `main.gd: add_log()` connect `마을 운영 · HUD · 육성 창 구성` to `쪼꼬미 행동 · 전투`, `밤 파도 · 새벽 정산 · 낮밤 순환`, `검증 · 테스트 · 명령`, `배치 · 성 위기 · 배속`, `따라가기 카메라`?**
  _High betweenness centrality (0.140) - this node is a cross-community bridge._
- **What connects `monster.gd: KINDS`, `summon.gd: TIER_TINT`, `mercenary.gd: post/path state vars (post_pos, path, path_goal, repath_cd)` to the rest of the system?**
  _59 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `마을 운영 · HUD · 육성 창 구성` be split into smaller, more focused modules?**
  _Cohesion score 0.08385744234800839 - nodes in this community are weakly interconnected._
- **Why does `README: 구조` connect `기획서 · 육성 설계` to `마을 운영 · HUD · 육성 창 구성`, `프로젝트 · 스크린샷`, `배치 · 성 위기 · 배속`?**
  _High betweenness centrality (0.103) - this node is a cross-community bridge._
- **Should `쪼꼬미 행동 · 전투` be split into smaller, more focused modules?**
  _Cohesion score 0.07751937984496124 - nodes in this community are weakly interconnected._
- **Why does `mercenary.gd: gain_xp()` connect `쪼꼬미 행동 · 전투` to `마을 운영 · HUD · 육성 창 구성`, `프로젝트 · 스크린샷`, `스프라이트 · 직업 데이터`?**
  _High betweenness centrality (0.094) - this node is a cross-community bridge._
- **Should `기획서 · 육성 설계` be split into smaller, more focused modules?**
  _Cohesion score 0.08414634146341464 - nodes in this community are weakly interconnected._