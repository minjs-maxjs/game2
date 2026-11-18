# 아그라 전기 — 작업 지침

Godot 4.7 / GDScript 탑다운 픽셀 게임. 기획은 `docs/기획서_v0.5.md`.
**새 세션은 `docs/인수인계.md`부터 읽는다** (진척 현황, 검증, 라이선스, 다음 작업).
답변은 한국어로. 단계마다 커밋하고 `main`에 push한다 (원격 `minjs-maxjs/game2`).

## 코드 찾기: 전체를 훑지 말고 지도부터

1. **`graphify-out/CODEMAP.md`** 를 먼저 본다. 파일별로 함수·상수의 줄 번호, 한 줄 요약, 기능 묶음, 호출 관계가 있다.
   고칠 심볼을 찾으면 그 줄 주변만 `Read`(offset/limit)로 읽는다.
2. 기능이 여러 파일에 걸치면 **`graphify-out/GRAPH_REPORT.md`** 의 Hyperedges(낮밤 순환, 육성/전직, 길찾기, 전투 피해 흐름)를 본다.
3. 연결 관계를 따라가야 하면 `graphify query "<질문>"` 또는 `graphify path "A" "B"` (프로젝트 루트에서).

기능 묶음 → 주로 볼 파일:
| 묶음 | 위치 |
|---|---|
| 낮밤 순환 · 웨이브 · 자원 | `scripts/main.gd` (_process, _start_night, _update_night, _start_day) |
| HUD · 마을 명령 버튼 | `scripts/main.gd` (_build_hud, _on_* 콜백, add_log) |
| 육성 창 · 전직 · 방출 | `scripts/main.gd` (select, try_promote, can_promote, dismiss_merc, _growth_bbcode, _build_growth_panel) + `scripts/mercenary.gd` (gain_xp, promote, recalc, next_tier, meets_stat_req) |
| 능력치 바 · HP 바 | `scripts/stat_panel.gd` (show_merc, _draw) + `scripts/stat_bar.gd` (draw_bar, hp_color) · 상한/조건은 `job_data.gd` (stat_cap, PROMOTE_STAT) |
| 직업 · 등급 · 능력치 표 | `scripts/job_data.gd` (새 직업은 JOBS에 한 줄 추가) |
| 쪼꼬미 생활 AI · 전투 | `scripts/mercenary.gd` (_day, _choose_action, _night, _attack, _try_heal) |
| 마물 · 소환수 | `scripts/monster.gd`, `scripts/summon.gd` |
| 쪼꼬미별 배치 · 자동 배치 · 성 위기 · 밤 배치 감속 | `scripts/deployment.gd` (handle_click, ui_blocks, auto_deploy, update_crisis, 상단 const) + `mercenary.gd` (_night, _update_defend, _defend_hall, _fight, _leashed) |
| 맵 · 길찾기 | `scripts/main.gd` (_compose_static, _compose_srw, _road_cells, _place_buildings, _build_nav, find_path, is_walkable) |
| 그림 불러오기 · 맵 타일 | `scripts/map_art.gd` (own_tex, autotile, prop) · 자체 그림은 `assets/agra/` |
| 쪼꼬미 외형 (성별·직업별) | `scripts/char_sprites.gd` (CHARS, pick, sheet) |
| 공격 · 치유 효과 | `scripts/mercenary.gd` (FX, _play_fx, _draw_fx) |
| UI 테두리 · 버튼 | `scripts/main.gd` (_frame, _make_theme) |

Super Retro World 팩(`SuperRetroWorld_CharacterPack_Full/`, `exterior-pack-free_version/`)은 재배포 금지라 .gitignore에 있다.
없으면 Kenney 그림으로 대신 그린다. 절대 커밋하지 말 것. AI 이미지 생성에 이 팩 그림을 넣는 것도 라이선스 위반.

## 그래프 갱신 (코드를 고친 뒤)

graphify에는 GDScript 파서가 없다. `.gd`는 detect 단계에서 자동으로 잡히지 않으므로,
`/graphify --update` 를 돌릴 때 corpus를 직접 지정해야 한다:
`scripts/*.gd`, `tests/*.gd`, `README.md`, `docs/*.md`, `project.godot`, `scenes/main.tscn`
(이미지·라이선스 파일은 제외). `.gd`는 문서로 취급되어 서브에이전트가 읽고, 함수마다 `L<줄>` 위치를 기록한다.
갱신 후 `python tools/make_codemap.py` 로 CODEMAP.md를 다시 만든다.

줄 번호가 몇 줄 어긋난 정도라면 그래프를 다시 만들지 말고 `Grep`으로 `func 이름`을 찾으면 된다.
그래프는 자동 갱신되지 않는다. 마지막 갱신 커밋은 `docs/인수인계.md` 6장에 적어 둔다.

## 검증

```
godot --headless --path . --script res://tests/growth_test.gd
godot --headless --path . --fixed-fps 60 --script res://tests/smoke_test.gd
godot --path . --script res://tests/screenshot.gd -- <출력폴더>
```
이 PC의 Godot: `D:\PYthon프로그램들\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe`
