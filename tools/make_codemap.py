"""graphify-out/graph.json → graphify-out/CODEMAP.md

파일별로 함수·상수·상태 묶음을 줄 번호 순으로 나열하고, 한 줄 요약과 소속 커뮤니티,
주요 호출 관계를 붙인다. 코드를 통째로 읽지 않고 고칠 곳을 바로 찾기 위한 색인.

실행: python tools/make_codemap.py   (프로젝트 루트에서)
"""
import json
from collections import defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "graphify-out"
graph = json.loads((OUT / "graph.json").read_text(encoding="utf-8"))
labels_path = OUT / ".graphify_labels.json"
community_names = json.loads(labels_path.read_text(encoding="utf-8")) if labels_path.exists() else {}

nodes = {n["id"]: n for n in graph["nodes"]}
links = graph.get("links") or graph.get("edges") or []
calls_out, calls_in = defaultdict(set), defaultdict(set)
for e in links:
    if e.get("relation") == "calls":
        calls_out[e["source"]].add(e["target"])
        calls_in[e["target"]].add(e["source"])


def rel(path: str) -> str:
    p = Path(path)
    try:
        return p.resolve().relative_to(ROOT).as_posix()
    except ValueError:
        return p.as_posix()


def line_of(n) -> int:
    loc = str(n.get("source_location") or "")
    try:
        return int(loc[1:].split("-")[0]) if loc.startswith("L") else 0
    except ValueError:
        return 0


def short(nid: str) -> str:
    n = nodes.get(nid)
    if not n:
        return nid
    lab = n.get("label", nid)
    return lab.split(": ", 1)[1] if ": " in lab else lab


by_file = defaultdict(list)
for n in nodes.values():
    src = n.get("source_file")
    if src and str(src).endswith(".gd"):
        by_file[rel(src)].append(n)

lines = ["# 아그라 전기 — 코드 맵 (graphify 자동 생성)", "",
         "줄 번호는 graph 생성 시점 기준. 코드를 고친 뒤에는 `/graphify --update`로 갱신할 것.", "",
         "## 커뮤니티 (기능 묶음)", ""]
for cid, name in sorted(community_names.items(), key=lambda kv: int(kv[0])):
    lines.append(f"- **{cid}** {name}")
lines.append("")

for f in sorted(by_file):
    lines += [f"## {f}", "", "| 줄 | 심볼 | 묶음 | 요약 | 호출함 → / ← 호출됨 |", "|---:|---|---|---|---|"]
    for n in sorted(by_file[f], key=line_of):
        ln = line_of(n)
        cid = str(n.get("community", ""))
        cname = community_names.get(cid, cid)
        outs = ", ".join(sorted(short(t) for t in calls_out[n["id"]]))[:90]
        ins = ", ".join(sorted(short(s) for s in calls_in[n["id"]]))[:90]
        rel_txt = (f"→ {outs}" if outs else "") + (" / " if outs and ins else "") + (f"← {ins}" if ins else "")
        summary = (n.get("summary") or "").replace("|", "/").replace("\n", " ")
        lines.append(f"| {ln or ''} | `{short(n['id'])}` | {cname} | {summary} | {rel_txt} |")
    lines.append("")

(OUT / "CODEMAP.md").write_text("\n".join(lines), encoding="utf-8")
print(f"CODEMAP.md: {sum(len(v) for v in by_file.values())} symbols in {len(by_file)} files")
