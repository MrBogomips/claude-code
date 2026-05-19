#!/usr/bin/env python3
"""Generate PERT estimation Excel workbook from structured JSON input.

The default output is a 4-sheet workbook:

* WBS                  — work breakdown with PERT formulas (unchanged).
* Resource Plan        — role × week PD matrix (replaces legacy Resources and
                         Timeline sheets).
* Risks                — risk register with P×I, contingency, and a
                         Management Reserve formula on the PMI-correct base.
* Summary              — phase rollup, effort bands (BASSA/MEDIA/ALTA),
                         calendar duration, effort-by-team, sensitivity.

Sheet names are localized via config.lang (default ``en``). Legacy JSON
without the modern config fields is auto-promoted by helpers.config_compat
which emits a single stderr warning.
"""
import argparse
import json
import sys
from pathlib import Path

from openpyxl import Workbook

from helpers.config_compat import normalize_config
from helpers.wb_pianificazione_risorse import build as build_resource_plan
from helpers.wb_risks import build as build_risks
from helpers.wb_summary import build as build_summary
from helpers.wb_wbs import build as build_wbs


def main(input_path: str, output_path: str) -> int:
    path = Path(input_path)
    if not path.exists():
        print(f"Error: input file not found: {input_path}", file=sys.stderr)
        return 1

    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as e:
        print(f"Error: invalid JSON: {e}", file=sys.stderr)
        return 1

    required = {"config", "roles", "phases", "risks"}
    missing = required - set(data.keys())
    if missing:
        print(f"Error: missing required keys in JSON: {missing}", file=sys.stderr)
        return 1
    if not data["phases"]:
        print("Error: 'phases' array is empty — nothing to generate", file=sys.stderr)
        return 1

    # Auto-promote legacy schemas (emits one stderr warning if applicable)
    data = normalize_config(data)

    wb = Workbook()
    wb.remove(wb.active)

    wbs_info = build_wbs(wb, data)
    rp_info = build_resource_plan(wb, data, wbs_info)
    risks_info = build_risks(wb, data, wbs_info)
    build_summary(wb, data, wbs_info, risks_info, rp_info)

    wb.save(output_path)
    print(f"Generated: {output_path}")
    return 0


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Generate PERT Excel workbook")
    parser.add_argument("--input", required=True, help="Path to excel-input.json")
    parser.add_argument("--output", required=True, help="Output .xlsx path")
    args = parser.parse_args()
    sys.exit(main(args.input, args.output))
