"""
render ISO-14971 FMEA worksheet markdown from data/fmea.yaml

same pattern as traceability.py: YAML is the source of truth, this just keeps the renddered worksheet unders 
docs/certifications/ISO-14971/fmea/ in sync with it
"""
from __future__ import annotations

import pathlib

import yaml

ROOT = pathlib.Path(__file__).resolve().parents[2].parent # project root
DATA = ROOT / "python" / "data" / "fmea.yaml"
OUT_MD = ROOT / "docs" / "certifications" / "ISO-14971" / "fmea" / "fmea-worksheet.md"

COLUMNS = [
    "id", "module", "function", "failure-mode", "effect",
    "severity", "cause", "probability", "detection",
    "risk_control", "residual_risk",
]

def load_rows() -> list[dict]:
    data = yaml.safe_load(DATA.read_text()) or {}
    return data.get("fmea_rows", []) or []

def _cell(value) -> str:
    if value is None:
        return "TBD"
    if isinstance(value, list):
        return "; " .join(str(v) for v in value) if value else "-"
    return str(value)

def render_markdown(rows: list[dict]) -> str:
    header = "| " + " | ".join(COLUMNS) + " |"
    sep = "| " + " | ".join("---" for _ in COLUMNS) + " |"
    lines = ["# FMEA Worksheet", "", header, sep]
    for row in rows:
        cells = [_cell(row.get(col)) for col in COLUMNS]
        lines.append("| " + " | ".join(cells) + " |")
    return "\n".join(lines) + "\n"


def main() -> None:
    rows = load_rows()
    OUT_MD.parent.mkdir(parents=True, exist_ok=True)
    OUT_MD.write_text(render_markdown(rows))
    print(f"wrote {OUT_MD} ({len(rows)} row(s))")


if __name__ == "__main__":
    main()