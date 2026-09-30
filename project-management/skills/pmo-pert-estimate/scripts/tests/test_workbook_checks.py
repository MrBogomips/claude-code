"""Tests for the static workbook checks run by `summarize.py --workbook`.

A freshly generated workbook must pass. Tampered copies (a formula replaced by a
number, a broken reference, a wrong rollup range, a renamed sheet) must fail with
an error that names the sheet and cell.
"""
import copy
import importlib.util
import json
import shutil
import subprocess
import sys
from pathlib import Path

import pytest
from openpyxl import load_workbook

SCRIPTS_DIR = Path(__file__).resolve().parent.parent


def _load(name: str):
    spec = importlib.util.spec_from_file_location(name, SCRIPTS_DIR / f"{name}.py")
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


@pytest.fixture
def gen():
    return _load("generate_excel")


@pytest.fixture
def checks():
    from helpers import workbook_checks
    return workbook_checks


@pytest.fixture
def workbook(gen, input_json_path, tmp_path):
    out = tmp_path / "estimate.xlsx"
    assert gen.main(str(input_json_path), str(out)) == 0
    return out


def _tamper(path: Path, sheet: str, cell: str, value) -> Path:
    wb = load_workbook(path)
    wb[sheet][cell] = value
    wb.save(path)
    return path


class TestStaticChecks:
    def test_generated_workbook_passes(self, checks, workbook, full_input_data):
        assert checks.check_workbook(workbook, full_input_data) == []

    def test_italian_workbook_passes(self, gen, checks, full_input_data, tmp_path):
        data = copy.deepcopy(full_input_data)
        data["config"]["lang"] = "it"
        src = tmp_path / "it.json"
        src.write_text(json.dumps(data), encoding="utf-8")
        out = tmp_path / "it.xlsx"
        assert gen.main(str(src), str(out)) == 0
        assert checks.check_workbook(out, data) == []

    def test_hardcoded_pert_value_fails(self, checks, workbook, full_input_data):
        _tamper(workbook, "WBS", "H4", 3.17)
        errors = checks.check_workbook(workbook, full_input_data)
        assert any("WBS!H4" in e for e in errors)

    def test_ref_error_fails(self, checks, workbook, full_input_data):
        _tamper(workbook, "Summary", "F2", "=#REF!")
        errors = checks.check_workbook(workbook, full_input_data)
        assert any("#REF!" in e for e in errors)

    def test_wrong_rollup_range_fails(self, checks, workbook, full_input_data):
        # WP 1.1 sits on row 3 with leaves on rows 4-5.
        _tamper(workbook, "WBS", "E3", "=SUM(E4:E4)")
        errors = checks.check_workbook(workbook, full_input_data)
        assert any("WBS!E3" in e for e in errors)

    def test_empty_leaf_input_fails(self, checks, workbook, full_input_data):
        _tamper(workbook, "WBS", "F5", None)
        errors = checks.check_workbook(workbook, full_input_data)
        assert any("WBS!F5" in e for e in errors)

    def test_band_formula_edit_fails(self, checks, workbook, full_input_data):
        wb = load_workbook(workbook)
        ws = wb["Summary"]
        row = next(r for r in range(1, ws.max_row + 1) if ws.cell(r, 1).value == "Medium Band (recommended)")
        ws.cell(row, 2).value = 100
        wb.save(workbook)
        errors = checks.check_workbook(workbook, full_input_data)
        assert any(f"Summary!B{row}" in e for e in errors)

    def test_reserve_formula_without_wbs_base_fails(self, checks, workbook, full_input_data):
        # 2 risks on rows 2-3, blank row 4, TOTAL row 5, Management Reserve row 6.
        _tamper(workbook, "Risks", "L6", "=L5*0.1")
        errors = checks.check_workbook(workbook, full_input_data)
        assert any("Risks!L6" in e for e in errors)

    def test_wrong_sheet_order_fails(self, checks, workbook, full_input_data):
        wb = load_workbook(workbook)
        wb.move_sheet("Summary", offset=-3)
        wb.save(workbook)
        errors = checks.check_workbook(workbook, full_input_data)
        assert any("sheet" in e.lower() for e in errors)

    def test_stale_calendar_value_fails(self, checks, workbook, full_input_data):
        wb = load_workbook(workbook)
        ws = wb["Summary"]
        row = next(r for r in range(1, ws.max_row + 1) if ws.cell(r, 1).value == "Calendar Duration (weeks)")
        ws.cell(row, 2).value = 99
        wb.save(workbook)
        errors = checks.check_workbook(workbook, full_input_data)
        assert any(f"Summary!B{row}" in e for e in errors)


class TestCliWithWorkbook:
    def _run(self, *args):
        return subprocess.run(
            [sys.executable, str(SCRIPTS_DIR / "summarize.py"), *args],
            capture_output=True, text=True, cwd=str(SCRIPTS_DIR),
        )

    def test_passing_workbook_exit_0(self, input_json_path, workbook):
        res = self._run("--input", str(input_json_path), "--workbook", str(workbook))
        assert res.returncode == 0, res.stderr
        out = json.loads(res.stdout)
        assert out["checks"]["passed"] is True
        assert out["checks"]["errors"] == []

    def test_failing_workbook_exit_2(self, input_json_path, workbook):
        _tamper(workbook, "WBS", "H4", 3.17)
        res = self._run("--input", str(input_json_path), "--workbook", str(workbook))
        assert res.returncode == 2
        out = json.loads(res.stdout)
        assert out["checks"]["passed"] is False

    def test_recalc_skipped_or_run(self, input_json_path, workbook):
        res = self._run("--input", str(input_json_path), "--workbook", str(workbook), "--recalc")
        out = json.loads(res.stdout)
        status = out["checks"]["recalc"]["status"]
        if shutil.which("soffice") or shutil.which("libreoffice"):
            assert status == "passed", out["checks"]
            assert res.returncode == 0
        else:
            assert status == "skipped"
            assert res.returncode == 0


@pytest.mark.skipif(
    not (shutil.which("soffice") or shutil.which("libreoffice")),
    reason="LibreOffice not installed",
)
class TestRecalc:
    def test_recalculated_values_match_summary(self, checks, workbook, full_input_data):
        summ = _load("summarize")
        summary = summ.compute_summary(full_input_data)
        result = checks.recalc_check(workbook, full_input_data, summary)
        assert result["status"] == "passed", result
