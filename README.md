# 아그라 전기 (Agra Chronicles)

마을 운영 + 자유 의지 AI 용병 + 균열 디펜스. Godot 4 · 탑다운 2D 픽셀.

세계의 끝 영지의 영주가 되어 마을을 꾸리고 용병을 모아, 밤마다 균열에서 쏟아지는 마물을 막아낸다.
용병들은 직접 조종하는 유닛이 아니다. 각자 성격과 욕구에 따라 살고 싸운다.

## 실행

1. [Godot 4.3+](https://godotengine.org/download)를 설치한다 (Standard 버전이면 된다).
2. Godot에서 이 폴더의 `project.godot`을 연다.
3. F5를 눌러 실행한다.

## 조작 (프로토타입)

| 입력 | 동작 |
|---|---|
| 좌클릭 (용병) | 정보 보기 |
| 오른쪽 메뉴 | 용병 모집 · 집결 지점 · 집결 해제 · 방책 수리 · 훈련장 강화 · 배속 |
| 우클릭 | 집결 지점 지정 취소 |
| SPACE | 배속 전환 |
| R | 패배 후 다시 시작 |

## 헤드리스 스모크 테스트

며칠을 10배속으로 자동 진행하며 오류와 기본 흐름(밤 침공, 날짜 진행)을 확인한다.

```
godot --headless --path . --fixed-fps 60 --script res://tests/smoke_test.gd
```

`RESULT PASS`와 종료 코드 0이면 정상이다.

## 구조

```
project.godot
scenes/main.tscn       메인 씬 (노드는 스크립트에서 생성)
scripts/main.gd        자원 · 낮/밤 · 웨이브 · HUD · 맵 그리기
scripts/mercenary.gd   자유 의지 용병 (유틸리티 AI + 성격 기반 전투)
scripts/monster.gd     균열 마물
docs/기획서_v0.3.md     게임 기획서
```

현재 그래픽은 모두 코드로 그린 임시 픽셀 도형이다. 정식 스프라이트는 다음 단계에서 넣는다.
