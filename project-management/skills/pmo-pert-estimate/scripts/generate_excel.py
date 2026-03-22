#!/usr/bin/env python3
"""Generate PERT estimation Excel workbook from structured JSON input."""
import argparse
import json
import sys
from pathlib import Path

from openpyxl import Workbook

from helpers.wb_wbs import build as build_wbs
from helpers.wb_timeline import build as build_timeline
from helpers.wb_resources import build as build_resources
from helpers.wb_risks import build as build_risks
from helpers.wb_summary import build as build_summary


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

    # Validate required keys
    required = {"config", "roles", "phases", "risks"}
    missing = required - set(data.keys())
    if missing:
        print(f"Error: missing required keys in JSON: {missing}", file=sys.stderr)
        return 1
    if not data["phases"]:
        print("Error: 'phases' array is empty — nothing to generate", file=sys.stderr)
        return 1

    wb = Workbook()
    # Remove default sheet
    wb.remove(wb.active)

    wbs_info = build_wbs(wb, data)
    timeline_info = build_timeline(wb, data, wbs_info)
    resources_info = build_resources(wb, data)
    risks_info = build_risks(wb, data)
    build_summary(wb, data, wbs_info, risks_info, resources_info)

    wb.save(output_path)
    print(f"Generated: {output_path}")
    return 0


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Generate PERT Excel workbook")
    parser.add_argument("--input", required=True, help="Path to excel-input.json")
    parser.add_argument("--output", required=True, help="Output .xlsx path")
    args = parser.parse_args()
    sys.exit(main(args.input, args.output))
