# Graph Report - AgraChronicles  (2026-11-18)

## Corpus Check
- 15 files · ~0 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 228 nodes · 392 edges · 30 communities (9 shown, 21 thin omitted)
- Extraction: 89% EXTRACTED · 11% INFERRED · 0% AMBIGUOUS · INFERRED: 42 edges (avg confidence: 0.87)
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- 마을 운영 · HUD · 육성 창
- 쪼꼬미 생활 AI · 전투 · 이동
- 기획서 · 세계관
- 맵 합성 · 길찾기 · 외형 시트
- 직업 · 등급 · 능력치 데이터
- 에셋 크레딧 · SRW 팩 · 외형 배정
- 프로젝트 설정 · 구조
- 렌더링 · UI 테마 · 그림 불러오기
- 헤드리스 테스트
- 스크린샷 테스트
- char_sprites.gd: _cache (단독)
- char_sprites.gd: PACK_DIR / FRAME / Dir  (단독)
- main.gd: cycle state (day, is_night, pha (단독)
- map_art.gd: PACK / TILE (단독)
- map_art.gd: _sheets / _own_tex caches (단독)
- mercenary.gd: combat/needs state (max_hp (단독)
- mercenary.gd: identity state (game, merc (단독)
- mercenary.gd: preload consts (JobData, S (단독)
- monster.gd: MapArt preload (단독)
- monster.gd: state vars (game, max_hp, hp (단독)
- summon.gd: MapArt preload (단독)
- summon.gd: state vars (game, summoner, m (단독)
- growth_test.gd: CharSprites (preload) (단독)
- growth_test.gd: frames (단독)
- growth_test.gd: JobData (preload) (단독)
- growth_test.gd: main (단독)
- growth_test.gd: Mercenary (preload) (단독)
- screenshot.gd: frames (단독)
- screenshot.gd: main (단독)

## God Nodes (most connected - your core abstractions)
1. `기획서 v0.4 (Game Design Doc)` - 29 edges
2. `main.gd: add_log()` - 20 edges
3. `main.gd: _build_hud()` - 13 edges
4. `mercenary.gd: roll_identity()` - 13 edges
5. `mercenary.gd: gain_xp()` - 13 edges
6. `growth_test.gd: _process()` - 13 edges
7. `main.gd: _spawn_merc()` - 12 edges
8. `JOBS` - 10 edges
9. `main.gd: _growth_bbcode()` - 10 edges
10. `Jobs & Promotion Table` - 9 edges

## Surprising Connections (you probably didn't know these)
- `Prototype Controls` --references--> `main.gd: _unhandled_input()`  [INFERRED]
  README.md → scripts/main.gd
- `Prototype Controls` --references--> `main.gd: _build_growth_panel()`  [INFERRED]
  README.md → scripts/main.gd
- `screenshot.gd: _process()` --shares_data_with--> `mercenary.gd: behavior/move/render state (activity, action, target_pos, doing_time, attack_cd, flash_*, splash_*, sprite_index, facing, moving, bob, path, repath_cd)`  [INFERRED]
  tests/screenshot.gd → scripts/mercenary.gd
- `Kenney Fallback Art` --conceptually_related_to--> `char_sprites.gd: available()`  [INFERRED]
  README.md → scripts/char_sprites.gd
- `char_sprites.gd: available()` --semantically_similar_to--> `map_art.gd: available()`  [INFERRED] [semantically similar]
  scripts/char_sprites.gd → scripts/map_art.gd

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **Job & Promotion Tier System** — scripts_job_data_jobs, scripts_job_data_tier_mult, scripts_job_data_promote_residue, scripts_job_data_promote_gold, scripts_main_try_promote, docs_design_v0_4_promotion [INFERRED 0.85]
- **Day/Night Cycle** — scripts_main_process, scripts_main_start_night, scripts_main_update_night, scripts_main_start_day, scripts_main_update_lighting, scripts_main_spawn_monster, scripts_mercenary_on_night_start, scripts_mercenary_on_dawn, scripts_mercenary_process [EXTRACTED 1.00]
- **Grid Pathfinding (static map + AStarGrid2D)** — scripts_main_compose_static, scripts_main_compose_srw, scripts_main_road_cells, scripts_main_place_buildings, scripts_main_build_nav, scripts_main_cell_of, scripts_main_is_walkable, scripts_main_find_path, scripts_main_building_pos, scripts_mercenary_follow, scripts_mercenary_move_to [INFERRED 0.85]
- **Growth & Promotion Flow** — scripts_main_train_support, scripts_main_try_promote, scripts_main_growth_bbcode, scripts_main_update_growth_panel, scripts_mercenary_gain_xp, scripts_mercenary_next_tier, scripts_mercenary_promote, scripts_mercenary_recalc [INFERRED 0.85]
- **Mercenary attack/heal visual effects** — scripts_mercenary_attack, scripts_mercenary_try_heal, scripts_mercenary_play_fx, scripts_mercenary_draw_fx, scripts_mercenary_fx_table, scripts_mercenary_fx_state [EXTRACTED 1.00]
- **Combat damage flow** — scripts_monster_process, scripts_mercenary_take_damage, scripts_summon_take_damage, scripts_main_damage_hall, scripts_summon_process, scripts_monster_take_damage, scripts_mercenary_gain_xp, scripts_summon_gain_xp, scripts_main_on_monster_killed [INFERRED 0.85]
- **Sprite & map art loading** — scripts_map_art_own, scripts_map_art_own_tex, scripts_map_art_available, scripts_map_art_sheet, scripts_map_art_autotile, scripts_map_art_prop, scripts_char_sprites_available, scripts_char_sprites_pick, scripts_char_sprites_sheet, scripts_monster_draw, scripts_summon_draw, scripts_main_compose_static, scripts_mercenary_draw [INFERRED 0.85]
- **Test Suite Driving main.tscn** — tests_growth_test, tests_smoke_test, tests_screenshot, scenes_main [INFERRED 0.85]
- **Super Retro World Optional Asset Pipeline** — readme_super_retro_world_packs, readme_no_redistribution_rule, readme_kenney_fallback, scripts_char_sprites_chars, scripts_map_art [INFERRED 0.75]

## Communities (30 total, 21 thin omitted)

### Community 0 - "마을 운영 · HUD · 육성 창"
Cohesion: 0.08
Nodes (43): Prototype Controls, main.gd: _add_button(), main.gd: add_log(), main.gd: balance consts (WORLD_SIZE, TILE, DAY_LENGTH, HALL_MAX_HP, RECRUIT_COST, WAGE_PER_MERC, MAX_MERCS, TRAIN_SUPPORT_*, VACATION_COST), main.gd: _build_growth_panel(), main.gd: _build_hud(), main.gd: damage_hall(), main.gd: dismiss_merc() (+35 more)

### Community 1 - "쪼꼬미 생활 AI · 전투 · 이동"
Cohesion: 0.09
Nodes (35): main.gd: building_pos(), main.gd: cell_of(), main.gd: find_path(), main.gd: is_walkable(), main.gd: rally/selection state (rally_point, has_rally, placing_rally, selected), mercenary.gd: ACTION_LABEL, mercenary.gd: ACTION_PLACE, mercenary.gd: _attack() (+27 more)

### Community 2 - "기획서 · 세계관"
Cohesion: 0.13
Nodes (25): 기획서 v0.4 (Game Design Doc), '아그라' Name (TBD), 흑의 세계 (Black World), Day/Night Core Loop, Defeat: Lord's Hall Durability 0, Gunner (거너), Healer (힐러), Injury & Downing (+17 more)

### Community 3 - "맵 합성 · 길찾기 · 외형 시트"
Cohesion: 0.11
Nodes (23): char_sprites.gd: path_of(), char_sprites.gd: sheet(), main.gd: _build_nav(), main.gd: _compose_srw(), main.gd: _compose_static(), main.gd: _place_buildings(), main.gd: preload consts (Mercenary, Monster, JobData, MapArt, TOWN_TEX, DUNGEON_TEX), main.gd: _road_cells() (+15 more)

### Community 4 - "직업 · 등급 · 능력치 데이터"
Cohesion: 0.14
Nodes (20): Mercenary Birth (쪼꼬미의 탄생), Grades (노말/엘리트/히어로/레전더리), Promotion (전직), Five Stats (능력치 5종), grade_for_total(), GRADES, PROMOTE_GOLD, PROMOTE_RESIDUE (+12 more)

### Community 5 - "에셋 크레딧 · SRW 팩 · 외형 배정"
Cohesion: 0.19
Nodes (11): Own Art (assets/agra), Asset Credits, Installing Super Retro World Packs, Super Retro World Packs, char_sprites.gd: available(), char_sprites.gd: CHARS, char_sprites.gd: pick(), mercenary.gd: NAMES (+3 more)

### Community 6 - "프로젝트 설정 · 구조"
Cohesion: 0.18
Nodes (7): Graphics & Screen (640x360 pixel), Project Structure, Running (실행), screenshot.gd: _initialize(), screenshot.gd: out_dir, screenshot.gd: _save(), _initialize()

### Community 7 - "렌더링 · UI 테마 · 그림 불러오기"
Cohesion: 0.17
Nodes (12): main.gd: buildings table, main.gd: _draw(), main.gd: _draw_text(), main.gd: _frame(), main.gd: _make_theme(), main.gd: hall_rect / rifts, main.gd: COL_TEXT / COL_DARK, map_art.gd: own_tex() (+4 more)

### Community 8 - "헤드리스 테스트"
Cohesion: 0.31
Nodes (7): Headless Tests, growth_test.gd: check(), growth_test.gd: failures, MAX_FRAMES, _process(), _report(), TARGET_DAY

## Knowledge Gaps
- **38 isolated node(s):** `'아그라' Name (TBD)`, `Personality Traits`, `1st Prototype Scope`, `Resources`, `Day Utility AI` (+33 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 56 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **21 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `main.gd: _spawn_merc()` connect `마을 운영 · HUD · 육성 창` to `쪼꼬미 생활 AI · 전투 · 이동`, `직업 · 등급 · 능력치 데이터`, `에셋 크레딧 · SRW 팩 · 외형 배정`?**
  _High betweenness centrality (0.150) - this node is a cross-community bridge._
- **Are the 2 inferred relationships involving `mercenary.gd: gain_xp()` (e.g. with `monster.gd: take_damage()` and `summon.gd: gain_xp()`) actually correct?**
  _`mercenary.gd: gain_xp()` has 2 INFERRED edges - model-reasoned connections that need verification._
- **What connects `'아그라' Name (TBD)`, `Personality Traits`, `1st Prototype Scope` to the rest of the system?**
  _38 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `마을 운영 · HUD · 육성 창` be split into smaller, more focused modules?**
  _Cohesion score 0.08019323671497584 - nodes in this community are weakly interconnected._
- **Why does `main.gd: add_log()` connect `마을 운영 · HUD · 육성 창` to `쪼꼬미 생활 AI · 전투 · 이동`?**
  _High betweenness centrality (0.149) - this node is a cross-community bridge._
- **Should `쪼꼬미 생활 AI · 전투 · 이동` be split into smaller, more focused modules?**
  _Cohesion score 0.09206349206349207 - nodes in this community are weakly interconnected._
- **Why does `기획서 v0.4 (Game Design Doc)` connect `기획서 · 세계관` to `직업 · 등급 · 능력치 데이터`, `프로젝트 설정 · 구조`?**
  _High betweenness centrality (0.145) - this node is a cross-community bridge._