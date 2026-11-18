# Graph Report - AgraChronicles  (2026-11-18)

## Corpus Check
- 18 files · ~17,564 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 288 nodes · 530 edges · 32 communities (9 shown, 23 thin omitted)
- Extraction: 89% EXTRACTED · 11% INFERRED · 0% AMBIGUOUS · INFERRED: 59 edges (avg confidence: 0.89)
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- 마을 운영 · HUD · 육성 창 구성
- 프로젝트 · 문서 · 테스트 · 명령
- 쪼꼬미 배치 · leash · 밤 전투
- 기획서 · 육성 규칙
- 맵 합성 · 길찾기 · 외형 시트
- 전직 조건 · 능력치 표시
- 성 위기 · 밤 배치 감속
- 쪼꼬미 탄생 · 등급 · 외형 배정
- 낮 생활 AI · 건물 위치
- deployment.gd: FLAG / POLE (단독)
- deployment.gd: TILE (단독)
- job_data.gd: TIER_MULT / PROMOTE_RESIDUE (단독)
- main.gd: COL_TEXT / COL_DARK (단독)
- main.gd: WORLD_SIZE / TILE / DAY_LENGTH  (단독)
- main.gd: hud_root / hud_body / growth_pa (단독)
- mercenary.gd: behavior state vars (activ (단독)
- mercenary.gd: combat stat vars (max_hp,  (단독)
- mercenary.gd: identity state vars (merc_ (단독)
- mercenary.gd: preloads (JobData / Summon (단독)
- monster.gd: NORMAL_KINDS / ELITE_KINDS / (단독)
- monster.gd: preload MapArt (단독)
- monster.gd: state vars (max_hp, hp, atk, (단독)
- stat_bar.gd: COL_BACK / COL_EDGE / COL_T (단독)
- stat_panel.gd: COL_TEXT / COL_PRIMARY /  (단독)
- stat_panel.gd: ROW_H / NAME_W / BAR_W /  (단독)
- stat_panel.gd: preloads (StatBar / JobDa (단독)
- stat_panel.gd: state vars (_bars, _merc, (단독)
- summon.gd: preload MapArt (단독)
- summon.gd: state vars (summoner, max_hp, (단독)

## God Nodes (most connected - your core abstractions)
1. `main.gd: add_log()` - 19 edges
2. `mercenary.gd: _night()` - 17 edges
3. `growth_test.gd: _process()` - 17 edges
4. `mercenary.gd: gain_xp()` - 14 edges
5. `README: 구조` - 14 edges
6. `main.gd: _build_hud()` - 12 edges
7. `deployment.gd: handle_click()` - 12 edges
8. `main.gd: _spawn_merc()` - 11 edges
9. `main.gd: try_promote()` - 11 edges
10. `main.gd: _growth_bbcode()` - 11 edges

## Surprising Connections (you probably didn't know these)
- `기획서: 방출` --implements--> `main.gd: dismiss_merc()`  [INFERRED]
  docs/기획서_v0.5.md → scripts/main.gd
- `인수인계: 검증 방법` --semantically_similar_to--> `README: 헤드리스 테스트`  [INFERRED] [semantically similar]
  docs/인수인계.md → README.md
- `README: Super Retro World 팩 넣기` --semantically_similar_to--> `인수인계: 라이선스 — 반드시 지킬 것`  [INFERRED] [semantically similar]
  README.md → docs/인수인계.md
- `기획서: 웨이브 강도 공식` --implements--> `main.gd: _spawn_monster()`  [INFERRED]
  docs/기획서_v0.5.md → scripts/main.gd
- `growth_test.gd: 6) 전직 버튼 조건` --references--> `main.gd: can_promote()`  [EXTRACTED]
  tests/growth_test.gd → scripts/main.gd

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **낮/밤 순환과 균열 침공** — scripts_main_process, scripts_main_start_night, scripts_main_update_night, scripts_main_start_day, scripts_main_update_lighting, scripts_main_spawn_monster [EXTRACTED 1.00]
- **HUD/육성 창 흐름** — scripts_main_build_hud, scripts_main_build_growth_panel, scripts_main_growth_bbcode, scripts_main_update_growth_panel, scripts_main_can_promote, scripts_main_try_promote, scripts_main_select [EXTRACTED 1.00]
- **정적 맵 합성과 격자 길찾기** — scripts_main_compose_static, scripts_main_compose_srw, scripts_main_road_cells, scripts_main_place_buildings, scripts_main_build_nav, scripts_main_cell_of, scripts_main_is_walkable, scripts_main_find_path [EXTRACTED 1.00]
- **밤 배치·leash·성 위기 방어 흐름** — scripts_mercenary_night, scripts_mercenary_update_defend, scripts_mercenary_defend_hall, scripts_mercenary_fight, scripts_mercenary_leashed, scripts_mercenary_post_center, scripts_deployment_update_crisis, scripts_deployment_hall_threat, scripts_deployment_leash_px, scripts_deployment_switch_hold [EXTRACTED 1.00]
- **능력치·HP 막대 표시** — scripts_stat_panel_show_merc, scripts_stat_panel_draw, scripts_stat_bar_set_bar, scripts_stat_bar_draw_bar, scripts_stat_bar_hp_color, scripts_mercenary_draw [EXTRACTED 1.00]
- **전투 피해·경험치 흐름** — scripts_mercenary_attack, scripts_monster_take_damage, scripts_monster_process, scripts_mercenary_take_damage, scripts_summon_process, scripts_summon_take_damage, scripts_summon_gain_xp, scripts_mercenary_gain_xp [INFERRED 0.85]
- **쪼꼬미별 배치 시스템 (클릭·leash·성 위기·밤 저속·자동 배치)** — docs_design_v0_5_deployment_leash, docs_design_v0_5_castle_crisis, docs_design_v0_5_night_deploy_slowmo, docs_design_v0_5_auto_deploy, scripts_deployment_handle_click, scripts_deployment_update_crisis, scripts_deployment_auto_deploy, tests_growth_test_section_10, tests_growth_test_section_11, tests_growth_test_section_12, tests_growth_test_section_14, tests_growth_test_section_15 [INFERRED 0.95]
- **전직 조건 (레벨·주 능력치·잔재·금화)과 능력치 바** — docs_design_v0_5_promotion_cost, docs_design_v0_5_promotion_stat_requirement, docs_design_v0_5_stat_bars, scripts_main_can_promote, scripts_main_try_promote, scripts_stat_panel, tests_growth_test_section_2, tests_growth_test_section_6, tests_growth_test_section_16 [INFERRED 0.85]
- **Super Retro World 라이선스 준수 (재배포·AI 입력 금지, Kenney 대체)** — docs_design_v0_5_srw_license_rules, docs_handoff_srw_license_rules, readme_srw_pack_install, readme_asset_credits, scripts_char_sprites, scripts_map_art [INFERRED 0.85]

## Communities (32 total, 23 thin omitted)

### Community 0 - "마을 운영 · HUD · 육성 창 구성"
Cohesion: 0.07
Nodes (41): 기획서: 핵심 플레이 루프 (낮/밤), 기획서: 웨이브 강도 공식, main.gd: _add_button(), main.gd: add_log(), main.gd: _build_growth_panel(), main.gd: _build_hud(), main.gd: damage_hall(), main.gd: dismiss_merc() (+33 more)

### Community 1 - "프로젝트 · 문서 · 테스트 · 명령"
Cohesion: 0.09
Nodes (33): 기획서: 자동 배치, 기획서: 플레이어 명령 (지시형), 기획서: Tab HUD 숨김, 인수인계: 검증 방법, README: 에셋 출처, README: 조작 (프로토타입), README: 헤드리스 테스트, deployment.gd: auto_deploy() (+25 more)

### Community 2 - "쪼꼬미 배치 · leash · 밤 전투"
Cohesion: 0.09
Nodes (39): 기획서: 쪼꼬미별 배치·leash, 기획서: 밤 후퇴 규칙, deployment.gd: cell_center(), deployment.gd: _draw(), deployment.gd: ENGAGE_PAD, deployment.gd: _free_cell(), deployment.gd: leash_px(), deployment.gd: LEASH_TILES / LEASH_DEFAULT (+31 more)

### Community 3 - "기획서 · 육성 규칙"
Cohesion: 0.11
Nodes (21): 기획서: 0. 변경 사항, 기획서: 방출, 기획서: 등급별 능력치 상한, 기획서: 육성 창, 기획서: 전투 중 HP 바, 기획서: 부상과 사망, 기획서: 직업과 4단계 전직, 기획서: 다음 결정 사항 (+13 more)

### Community 4 - "맵 합성 · 길찾기 · 외형 시트"
Cohesion: 0.08
Nodes (31): char_sprites.gd: _cache, char_sprites.gd: frame_rect(), char_sprites.gd: PACK_DIR / FRAME / Dir / WALK, char_sprites.gd: path_of(), char_sprites.gd: sheet(), main.gd: _build_nav(), main.gd: _compose_srw(), main.gd: _compose_static() (+23 more)

### Community 5 - "전직 조건 · 능력치 표시"
Cohesion: 0.14
Nodes (23): 기획서: 전직 비용, 기획서: 전직 능력치 조건, job_data.gd: STATS / STAT_NAMES, main.gd: can_promote(), main.gd: _growth_bbcode(), main.gd: gold / food / wood / residue / day / is_night / phase_time / hall_hp, main.gd: try_promote(), main.gd: _update_growth_panel() (+15 more)

### Community 6 - "성 위기 · 밤 배치 감속"
Cohesion: 0.17
Nodes (13): 기획서: 성 위기, 기획서: 밤 배치 0.2배속, deployment.gd: base_speed(), deployment.gd: CRISIS_TILES / CRISIS_HIT_SECS, deployment.gd: hall_threat(), deployment.gd: NIGHT_EDIT_SPEED, deployment.gd: _process(), deployment.gd: update_crisis() (+5 more)

### Community 7 - "쪼꼬미 탄생 · 등급 · 외형 배정"
Cohesion: 0.17
Nodes (14): 기획서: 능력치 5종, 기획서: 등급 (노말·엘리트·히어로·레전더리), 기획서: 쪼꼬미의 탄생, char_sprites.gd: available(), char_sprites.gd: CHARS, char_sprites.gd: pick(), job_data.gd: grade_for_total(), job_data.gd: GRADES / STAT_CAP_DEFAULT (+6 more)

### Community 8 - "낮 생활 AI · 건물 위치"
Cohesion: 0.29
Nodes (7): 기획서: 낮 행동 유틸리티 AI, main.gd: building_pos(), main.gd: buildings / hall_rect / rifts, main.gd: _draw(), mercenary.gd: ACTION_PLACE / ACTION_LABEL, mercenary.gd: _choose_action(), growth_test.gd: 8) 식량 없을 때 식사 안 함

## Knowledge Gaps
- **42 isolated node(s):** `main.gd: WORLD_SIZE / TILE / DAY_LENGTH / HALL_MAX_HP / RECRUIT_COST / WAGE_PER_MERC / MAX_MERCS / TRAIN_SUPPORT_COST / VACATION_COST`, `main.gd: COL_TEXT / COL_DARK`, `main.gd: hud_root / hud_body / growth_panel / stat_panel / promote_button / dismiss_button`, `job_data.gd: TIER_MULT / PROMOTE_RESIDUE / PROMOTE_GOLD / PROMOTE_STAT`, `job_data.gd: JOBS` (+37 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 67 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **23 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `main.gd: add_log()` connect `마을 운영 · HUD · 육성 창 구성` to `프로젝트 · 문서 · 테스트 · 명령`, `쪼꼬미 배치 · leash · 밤 전투`, `전직 조건 · 능력치 표시`?**
  _High betweenness centrality (0.148) - this node is a cross-community bridge._
- **What connects `main.gd: WORLD_SIZE / TILE / DAY_LENGTH / HALL_MAX_HP / RECRUIT_COST / WAGE_PER_MERC / MAX_MERCS / TRAIN_SUPPORT_COST / VACATION_COST`, `main.gd: COL_TEXT / COL_DARK`, `main.gd: hud_root / hud_body / growth_panel / stat_panel / promote_button / dismiss_button` to the rest of the system?**
  _42 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `마을 운영 · HUD · 육성 창 구성` be split into smaller, more focused modules?**
  _Cohesion score 0.06567992599444958 - nodes in this community are weakly interconnected._
- **Why does `growth_test.gd: _process()` connect `프로젝트 · 문서 · 테스트 · 명령` to `마을 운영 · HUD · 육성 창 구성`, `쪼꼬미 배치 · leash · 밤 전투`, `전직 조건 · 능력치 표시`, `성 위기 · 밤 배치 감속`, `낮 생활 AI · 건물 위치`?**
  _High betweenness centrality (0.125) - this node is a cross-community bridge._
- **Should `프로젝트 · 문서 · 테스트 · 명령` be split into smaller, more focused modules?**
  _Cohesion score 0.08710801393728224 - nodes in this community are weakly interconnected._
- **Why does `mercenary.gd: gain_xp()` connect `쪼꼬미 배치 · leash · 밤 전투` to `마을 운영 · HUD · 육성 창 구성`, `프로젝트 · 문서 · 테스트 · 명령`, `전직 조건 · 능력치 표시`?**
  _High betweenness centrality (0.109) - this node is a cross-community bridge._
- **Should `쪼꼬미 배치 · leash · 밤 전투` be split into smaller, more focused modules?**
  _Cohesion score 0.09146341463414634 - nodes in this community are weakly interconnected._