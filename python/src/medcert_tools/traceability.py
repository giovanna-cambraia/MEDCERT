"""Render traceability/matrix.md (+ .csv) from data/requirements.yaml.

YAML is the source of truth; this script only keeps the rendered
matrix in sync with it.
"""
from __future__ import annotations

import csv
import pathlib

import yaml

ROOT = pathlib.Path(__file__).resolve().parents[2].parent  # project root
DATA = ROOT / "python" / "data" / "requirements.yaml"
OUT_MD = ROOT / "traceability" / "matrix.md"
OUT_CSV = ROOT / "traceability" / "matrix.csv"

COLUMNS = ["id", "standard", "module", "text", "code_refs", "test_refs", "status"]


def load_requirements() -> list[dict]:
    data = yaml.safe_load(DATA.read_text(encoding="utf-8")) or {}
    return data.get("requirements", []) or []


def _cell(value) -> str:
    if value is None:
        return "TBD"
    if isinstance(value, list):
        return "; ".join(str(v) for v in value) if value else "-"
    return " ".join(str(value).split())  # collapse folded-YAML newlines


def render_markdown(rows: list[dict]) -> str:
    header = "| " + " | ".join(COLUMNS) + " |"
    sep = "| " + " | ".join("---" for _ in COLUMNS) + " |"
    lines = [header, sep]
    for row in rows:
        cells = [_cell(row.get(col)) for col in COLUMNS]
        lines.append("| " + " | ".join(cells) + " |")
    return "\n".join(lines) + "\n"


def render_csv(rows: list[dict]) -> None:
    with OUT_CSV.open("w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=COLUMNS)
        writer.writeheader()
        for row in rows:
            writer.writerow({col: _cell(row.get(col)) for col in COLUMNS})


def main() -> None:
    rows = load_requirements()
    OUT_MD.parent.mkdir(parents=True, exist_ok=True)
    OUT_MD.write_text(render_markdown(rows), encoding="utf-8")
    render_csv(rows)
    print(f"wrote {OUT_MD} and {OUT_CSV} ({len(rows)} requirement(s))")


if __name__ == "__main__":
    main()