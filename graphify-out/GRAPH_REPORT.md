# Graph Report - AgraChronicles  (2026-11-18)

## Corpus Check
- Corpus is ~2,765 words - fits in a single context window. You may not need a graph.

## Summary
- 176 nodes · 369 edges · 9 communities
- Extraction: 91% EXTRACTED · 9% INFERRED · 0% AMBIGUOUS · INFERRED: 35 edges (avg confidence: 0.91)
- Token cost: 219,766 input · 0 output

## Community Hubs (Navigation)
- 낮밤 순환 · 웨이브 · 월드 상태
- HUD · 마을 명령 버튼
- 육성 창 · 전직 · 방출
- 기획서 · 세계관
- 마물 · 소환수 · 전투 피해
- 프로젝트 설정 · 문서
- 직업 · 등급 · 능력치 데이터
- 길찾기 · 스모크 테스트
- 맵 합성 · 렌더링

## God Nodes (most connected - your core abstractions)
1. `기획서 v0.4 (Game Design Doc)` - 29 edges
2. `main.gd: add_log()` - 20 edges
3. `mercenary.gd: gain_xp()` - 13 edges
4. `main.gd: _spawn_merc()` - 12 edges
5. `main.gd: _build_hud()` - 12 edges
6. `_process()` - 12 edges
7. `main.gd: resource state (gold, food, wood, residue, hall_hp, train_bonus)` - 11 edges
8. `mercenary.gd: _night()` - 10 edges
9. `Jobs & Promotion Table` - 9 edges
10. `main.gd: entity lists (mercs, monsters, summons, log_lines)` - 8 edges

## Surprising Connections (you probably didn't know these)
- `TIER_MULT` --implements--> `Promotion (전직)`  [INFERRED]
  scripts/job_data.gd → docs/기획서_v0.4.md
- `PROMOTE_GOLD` --implements--> `Promotion (전직)`  [INFERRED]
  scripts/job_data.gd → docs/기획서_v0.4.md
- `_process()` --implements--> `Defeat: Lord's Hall Durability 0`  [INFERRED]
  scripts/monster.gd → docs/기획서_v0.4.md
- `_process()` --implements--> `Knight (기사)`  [INFERRED]
  scripts/monster.gd → docs/기획서_v0.4.md
- `_process()` --calls--> `main.gd: _start_night()`  [EXTRACTED]
  tests/growth_test.gd → scripts/main.gd

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **Day/Night Cycle** — scripts_main_process, scripts_main_start_night, scripts_main_update_night, scripts_main_start_day, scripts_main_update_lighting, scripts_main_spawn_monster, scripts_mercenary_on_night_start, scripts_mercenary_on_dawn, scripts_mercenary_process [EXTRACTED 1.00]
- **Growth / Promotion Flow** — scripts_main_train_support, scripts_main_try_promote, scripts_main_growth_bbcode, scripts_main_update_growth_panel, scripts_mercenary_gain_xp, scripts_mercenary_next_tier, scripts_mercenary_promote, scripts_mercenary_recalc [EXTRACTED 1.00]
- **Grid A* Pathfinding** — scripts_main_compose_static, scripts_main_build_nav, scripts_main_cell_of, scripts_main_is_walkable, scripts_main_find_path, scripts_main_building_pos, scripts_mercenary_follow, scripts_mercenary_move_to [EXTRACTED 1.00]
- **Night Combat Damage & XP Flow** — scripts_monster_process, scripts_mercenary_take_damage, scripts_summon_take_damage, scripts_main_damage_hall, scripts_summon_process, scripts_monster_take_damage, scripts_mercenary_gain_xp, scripts_main_on_monster_killed [INFERRED 0.85]
- **Job & Promotion Tier System** — scripts_job_data_jobs, scripts_job_data_tier_mult, scripts_job_data_promote_residue, scripts_job_data_promote_gold, scripts_main_try_promote, docs_design_v0_4_promotion [INFERRED 0.85]
- **Test Suite Driving main.tscn** — tests_growth_test, tests_smoke_test, tests_screenshot, scenes_main [EXTRACTED 1.00]

## Communities (9 total, 0 thin omitted)

### Community 0 - "낮밤 순환 · 웨이브 · 월드 상태"
Cohesion: 0.10
Nodes (30): main.gd: balance consts (WORLD_SIZE, TILE, DAY_LENGTH, HALL_MAX_HP, RECRUIT_COST, WAGE_PER_MERC, MAX_MERCS, TRAIN_SUPPORT_*, VACATION_COST), main.gd: building_pos(), main.gd: buildings table, main.gd: cycle state (day, is_night, phase_time, to_spawn, spawn_timer, game_over, elapsed), main.gd: _draw(), main.gd: entity lists (mercs, monsters, summons, log_lines), main.gd: hall_rect / rifts, main.gd: _process() (+22 more)

### Community 1 - "HUD · 마을 명령 버튼"
Cohesion: 0.12
Nodes (27): main.gd: _add_button(), main.gd: add_log(), main.gd: _box(), main.gd: _build_growth_panel(), main.gd: _build_hud(), main.gd: damage_hall(), main.gd: HUD widget refs (modulate_node, labels, banner, buttons, growth_panel, dismiss_armed), main.gd: _make_theme() (+19 more)

### Community 2 - "육성 창 · 전직 · 방출"
Cohesion: 0.15
Nodes (23): main.gd: dismiss_merc(), main.gd: _growth_bbcode(), main.gd: _on_dismiss(), main.gd: select(), main.gd: try_promote(), main.gd: _update_growth_panel(), main.gd: _update_hud(), mercenary.gd: describe() (+15 more)

### Community 3 - "기획서 · 세계관"
Cohesion: 0.16
Nodes (22): 기획서 v0.4 (Game Design Doc), '아그라' Name (TBD), Day/Night Core Loop, Defeat: Lord's Hall Durability 0, Gunner (거너), Healer (힐러), Injury & Downing, Jobs & Promotion Table (+14 more)

### Community 4 - "마물 · 소환수 · 전투 피해"
Cohesion: 0.18
Nodes (16): 흑의 세계 (Black World), Rift Monsters & Waves, mercenary.gd: take_damage(), ELITE_SPRITES, _follow(), _move_to(), NORMAL_SPRITES, _process() (+8 more)

### Community 5 - "프로젝트 설정 · 문서"
Cohesion: 0.17
Nodes (10): Graphics & Screen (640x360 pixel), Growth Window (육성 창), Asset Credits, Prototype Controls, Headless Tests, Project Structure, _initialize(), _process() (+2 more)

### Community 6 - "직업 · 등급 · 능력치 데이터"
Cohesion: 0.23
Nodes (13): Mercenary Birth (쪼꼬미의 탄생), Grades (노말/엘리트/히어로/레전더리), Promotion (전직), Five Stats (능력치 5종), grade_for_total(), GRADES, PROMOTE_GOLD, PROMOTE_RESIDUE (+5 more)

### Community 7 - "길찾기 · 스모크 테스트"
Cohesion: 0.29
Nodes (9): main.gd: cell_of(), main.gd: find_path(), main.gd: is_walkable(), mercenary.gd: behavior/move/render state (activity, action, target_pos, doing_time, attack_cd, flash_*, splash_*, sprite_index, facing, path, repath_cd), mercenary.gd: _follow(), MAX_FRAMES, _process(), _report() (+1 more)

### Community 8 - "맵 합성 · 렌더링"
Cohesion: 0.31
Nodes (9): main.gd: _build_nav(), main.gd: _compose_static(), main.gd: runtime resources (rng, dungeon_tex, nav AStarGrid2D, static_tex, font_s/m/l), main.gd: _stamp(), main.gd: _stamp_block(), main.gd: tile_src() (static), mercenary.gd: _draw(), _draw() (+1 more)

## Knowledge Gaps
- **14 isolated node(s):** `main.gd: balance consts (WORLD_SIZE, TILE, DAY_LENGTH, HALL_MAX_HP, RECRUIT_COST, WAGE_PER_MERC, MAX_MERCS, TRAIN_SUPPORT_*, VACATION_COST)`, `main.gd: COL_TEXT / COL_DARK`, `main.gd: HUD widget refs (modulate_node, labels, banner, buttons, growth_panel, dismiss_armed)`, `mercenary.gd: preload consts (JobData, Summon)`, `mercenary.gd: NAMES` (+9 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 20 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `기획서 v0.4 (Game Design Doc)` connect `기획서 · 세계관` to `마물 · 소환수 · 전투 피해`, `프로젝트 설정 · 문서`, `직업 · 등급 · 능력치 데이터`?**
  _High betweenness centrality (0.196) - this node is a cross-community bridge._
- **Are the 2 inferred relationships involving `mercenary.gd: gain_xp()` (e.g. with `take_damage()` and `gain_xp()`) actually correct?**
  _`mercenary.gd: gain_xp()` has 2 INFERRED edges - model-reasoned connections that need verification._
- **What connects `main.gd: balance consts (WORLD_SIZE, TILE, DAY_LENGTH, HALL_MAX_HP, RECRUIT_COST, WAGE_PER_MERC, MAX_MERCS, TRAIN_SUPPORT_*, VACATION_COST)`, `main.gd: COL_TEXT / COL_DARK`, `main.gd: HUD widget refs (modulate_node, labels, banner, buttons, growth_panel, dismiss_armed)` to the rest of the system?**
  _14 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `낮밤 순환 · 웨이브 · 월드 상태` be split into smaller, more focused modules?**
  _Cohesion score 0.0967741935483871 - nodes in this community are weakly interconnected._
- **Why does `_process()` connect `육성 창 · 전직 · 방출` to `낮밤 순환 · 웨이브 · 월드 상태`, `HUD · 마을 명령 버튼`, `직업 · 등급 · 능력치 데이터`?**
  _High betweenness centrality (0.163) - this node is a cross-community bridge._
- **Should `HUD · 마을 명령 버튼` be split into smaller, more focused modules?**
  _Cohesion score 0.11576354679802955 - nodes in this community are weakly interconnected._
- **Why does `main.gd: add_log()` connect `HUD · 마을 명령 버튼` to `낮밤 순환 · 웨이브 · 월드 상태`, `육성 창 · 전직 · 방출`, `마물 · 소환수 · 전투 피해`?**
  _High betweenness centrality (0.155) - this node is a cross-community bridge._