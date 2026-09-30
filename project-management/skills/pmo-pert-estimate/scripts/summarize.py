#!/usr/bin/env python3
"""Compute the PERT workbook figures from excel-input.json and check a generated workbook.

openpyxl writes formula strings without cached values, so the numbers a generated
workbook will show cannot be read back from the file. This script computes the same
figures from the JSON input with the generator's formulas and helpers, validates the
input, and with --workbook checks the generated formulas statically. With --recalc it
also recalculates a copy with LibreOffice when LibreOffice is on PATH (optional).

Usage:
    python3 summarize.py --input excel-input.json
    python3 summarize.py --input excel-input.json --workbook estimate.xlsx [--recalc]
    python3 summarize.py --input excel-input.json --output summary.json --format markdown

Exit codes: 0 = ok, 1 = input missing or invalid, 2 = workbook checks failed.
"""
from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

from helpers.figures import compute_summary, risk_priority  # noqa: F401  (re-exported)
from helpers.input_validation import validate_input  # noqa: F401  (re-exported)
from helpers.workbook_checks import check_workbook, recalc_check

EXIT_OK, EXIT_INPUT, EXIT_CHECKS = 0, 1, 2


def _load(path: Path) -> dict | None:
    if not path.exists():
        print(f"Error: input file not found: {path}", file=sys.stderr)
        return None
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as e:
        print(f"Error: invalid JSON in {path}: {e}", file=sys.stderr)
        return None


def _run_checks(workbook: Path, data: dict, summary: dict, recalc: bool) -> dict:
    if not workbook.exists():
        return {"workbook": str(workbook), "passed": False,
                "errors": [f"workbook not found: {workbook}"]}
    errors = check_workbook(workbook, data, summary)
    result = {"workbook": str(workbook), "passed": not errors, "errors": errors}
    if recalc:
        result["recalc"] = recalc_check(workbook, data, summary)
        if result["recalc"]["status"] == "failed":
            result["passed"] = False
    return result


def to_markdown(s: dict) -> str:
    """Compact human-readable summary (English labels; translate when presenting)."""
    e, u = s["effort"], s["effort_unit"].upper()
    c = s["counts"]
    lines = [
        f"Phases {c['phases']} · work packages {c['work_packages']} · activities {c['activities']}"
        f" · roles {c['roles']} · risks {c['risks']} (high, P×I ≥ 10: {len(s['high_risk_ids'])})",
        "",
        "| Figure | Value |", "|---|---|",
        f"| Tech PERT Effort ({u}) | {e['tech_pert']} |",
        f"| PM + DevOps Overhead ({u}) | {round(e['pm_overhead'] + e['devops_overhead'], 2)} |",
        f"| Contingency ({u}) | {e['contingency']} |",
        f"| Low Band ({u}) | {e['low_band']} |",
        f"| Management Reserve ({u}) | {e['management_reserve']} |",
        f"| Medium Band, recommended ({u}) | {e['medium_band']} |",
        f"| High Band ({u}) | {e['high_band']} |",
        f"| Calendar Duration (weeks) | {s['calendar_weeks']} |",
        "", "| Phase | PERT Effort | σ Duration (linear sum) |", "|---|---|---|",
    ]
    lines += [f"| {p['id']} {p['name']} | {p['pert_effort']} | {p['sigma_duration']} |" for p in s["phases"]]
    checks = s.get("checks")
    if checks:
        lines += ["", f"Workbook checks: {'passed' if checks['passed'] else 'FAILED'}"]
        lines += [f"- {err}" for err in checks["errors"]]
        if "recalc" in checks:
            lines.append(f"Recalculation: {checks['recalc']['status']}")
    lines += [f"Warning: {w}" for w in s.get("warnings", [])]
    return "\n".join(lines)


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="PERT workbook figures and checks")
    parser.add_argument("--input", required=True, help="Path to excel-input.json")
    parser.add_argument("--workbook", help="Generated .xlsx to check against the input")
    parser.add_argument("--recalc", action="store_true",
                        help="Also recalculate with LibreOffice when it is on PATH")
    parser.add_argument("--output", help="Also write the JSON summary to this file")
    parser.add_argument("--format", choices=("json", "markdown"), default="json")
    args = parser.parse_args(argv)

    data = _load(Path(args.input))
    if data is None:
        return EXIT_INPUT
    errors, warnings = validate_input(data)
    if errors:
        for err in errors:
            print(f"Error: {err}", file=sys.stderr)
        return EXIT_INPUT

    summary = compute_summary(data)
    summary["warnings"] = warnings
    if args.workbook:
        summary["checks"] = _run_checks(Path(args.workbook), data, summary, args.recalc)

    text = json.dumps(summary, indent=2, ensure_ascii=False)
    if args.output:
        Path(args.output).write_text(text + "\n", encoding="utf-8")
    print(to_markdown(summary) if args.format == "markdown" else text)
    return EXIT_CHECKS if args.workbook and not summary["checks"]["passed"] else EXIT_OK


if __name__ == "__main__":
    sys.exit(main())
