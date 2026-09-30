"""Tests for summarize.py — the figures and input checks computed from excel-input.json.

The expected numbers are worked out by hand from the conftest fixture with the same
formulas the workbook uses (see references/excel-schema.md).
"""
import copy
import importlib.util
import json
import subprocess
import sys
from pathlib import Path

import pytest

SCRIPTS_DIR = Path(__file__).resolve().parent.parent


def _load(name: str):
    spec = importlib.util.spec_from_file_location(name, SCRIPTS_DIR / f"{name}.py")
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


@pytest.fixture
def summ():
    return _load("summarize")


@pytest.fixture
def summary(summ, full_input_data):
    return summ.compute_summary(full_input_data)


# ---------------------------------------------------------------------------
# Rollups
# ---------------------------------------------------------------------------

class TestRollups:
    def test_counts(self, summary):
        assert summary["counts"] == {
            "phases": 2, "work_packages": 2, "activities": 4, "roles": 2, "risks": 2,
        }

    def test_phase_pert_effort_is_linear_rollup(self, summary):
        p1, p2 = summary["phases"]
        assert p1["id"] == "1" and p2["id"] == "2"
        assert p1["pert_effort"] == pytest.approx(32 / 6, abs=0.01)
        assert p2["pert_effort"] == pytest.approx(68 / 6, abs=0.01)

    def test_phase_three_points_are_sums_of_leaves(self, summary):
        p1 = summary["phases"][0]
        assert (p1["best_effort"], p1["likely_effort"], p1["worst_effort"]) == (3, 5, 9)
        assert (p1["best_duration"], p1["likely_duration"], p1["worst_duration"]) == (3, 5, 8)

    def test_phase_sigma_is_linear_like_the_workbook(self, summary):
        # Workbook: sigma on a rollup row = (sum(P) - sum(O)) / 6, i.e. the linear sum of sigmas.
        p2 = summary["phases"][1]
        assert p2["sigma_duration"] == pytest.approx((30 - 15) / 6, abs=0.01)

    def test_totals(self, summary):
        tot = summary["totals"]
        assert tot["pert_effort"] == pytest.approx(100 / 6, abs=0.01)
        assert tot["pert_duration"] == pytest.approx(160 / 6, abs=0.01)
        assert tot["sigma_duration"] == pytest.approx(20 / 6, abs=0.01)
        assert tot["billable_pert_effort"] == pytest.approx(13.5, abs=0.01)

    def test_work_package_rollup(self, summary):
        wp = summary["phases"][0]["work_packages"][0]
        assert wp["id"] == "1.1"
        assert wp["pert_effort"] == pytest.approx(32 / 6, abs=0.01)


# ---------------------------------------------------------------------------
# Effort breakdown and bands
# ---------------------------------------------------------------------------

class TestBands:
    def test_bands_without_overhead(self, summary):
        e = summary["effort"]
        assert e["tech_pert"] == pytest.approx(16.67, abs=0.01)
        assert e["pm_overhead"] == 0
        assert e["devops_overhead"] == 0
        assert e["subtotal"] == pytest.approx(16.67, abs=0.01)
        assert e["contingency"] == 8
        assert e["low_band"] == pytest.approx(24.67, abs=0.01)
        assert e["management_reserve"] == pytest.approx(2.47, abs=0.01)
        assert e["medium_band"] == pytest.approx(27.13, abs=0.01)
        assert e["high_band"] == pytest.approx(27.1333 * 1.12, abs=0.01)
        assert e["billable_ratio"] == pytest.approx(0.81, abs=0.001)

    def test_bands_with_overhead(self, summ, full_input_data):
        data = copy.deepcopy(full_input_data)
        data["config"].update(
            {"pm_overhead_pct": 0.10, "devops_overhead_pct": 0.05, "alta_uplift_pct": 0.20,
             "management_reserve_pct": 0.20}
        )
        e = summ.compute_summary(data)["effort"]
        tech = 100 / 6
        subtotal = tech * 1.15
        low = subtotal + 8
        assert e["pm_overhead"] == pytest.approx(tech * 0.10, abs=0.01)
        assert e["devops_overhead"] == pytest.approx(tech * 0.05, abs=0.01)
        assert e["low_band"] == pytest.approx(low, abs=0.01)
        assert e["management_reserve"] == pytest.approx(low * 0.20, abs=0.01)
        assert e["medium_band"] == pytest.approx(low * 1.20, abs=0.01)
        assert e["high_band"] == pytest.approx(low * 1.20 * 1.20, abs=0.01)

    def test_risks_sheet_reserve_equals_summary_reserve(self, summary):
        e = summary["effort"]
        assert e["management_reserve_risks_sheet"] == pytest.approx(
            e["management_reserve"], abs=0.01
        )

    def test_missing_contingency_counts_as_zero(self, summ, full_input_data):
        data = copy.deepcopy(full_input_data)
        data["risks"][0]["contingency_effort"] = None
        assert summ.compute_summary(data)["effort"]["contingency"] == 5


# ---------------------------------------------------------------------------
# Calendar, teams, roles
# ---------------------------------------------------------------------------

class TestCalendarAndTeams:
    def test_calendar_from_resource_plan_fallback(self, summary):
        # No explicit weeks: phase 1 = ceil(5.17/5) = 2 weeks, phase 2 = ceil(21.5/5) = 5 weeks.
        assert summary["calendar_weeks"] == 7

    def test_calendar_from_phase_weeks(self, summ, full_input_data):
        data = copy.deepcopy(full_input_data)
        data["phases"][0].update({"start_week": 1, "end_week": 3})
        data["phases"][1].update({"start_week": 3, "end_week": 10})
        assert summ.compute_summary(data)["calendar_weeks"] == 10

    def test_calendar_explicit_override(self, summ, full_input_data):
        data = copy.deepcopy(full_input_data)
        data["config"]["calendar_total_weeks"] = 25
        assert summ.compute_summary(data)["calendar_weeks"] == 25

    def test_effort_by_team(self, summary):
        teams = summary["effort_by_team"]
        assert teams["Dev"] == pytest.approx(13.5, abs=0.01)
        assert teams["Client"] == pytest.approx(19 / 6, abs=0.01)

    def test_resource_plan_totals(self, summary):
        rp = summary["resource_plan"]
        assert rp["role_total_pd"]["SD"] == pytest.approx(13.5, abs=0.01)
        assert rp["role_total_pd"]["DEC"] == pytest.approx(19 / 6, abs=0.01)
        assert rp["grand_total_pd"] == pytest.approx(100 / 6, abs=1.0)
        assert rp["skipped_activities"] == []


# ---------------------------------------------------------------------------
# Risks: P x I >= 10 is high
# ---------------------------------------------------------------------------

class TestRiskClassification:
    @pytest.mark.parametrize(
        "p,i,priority",
        [(1, 4, "LOW"), (1, 5, "MEDIUM"), (3, 3, "MEDIUM"), (2, 5, "HIGH"),
         (3, 4, "HIGH"), (3, 5, "CRITICAL"), (5, 5, "CRITICAL")],
    )
    def test_priority_matches_workbook_formula(self, summ, p, i, priority):
        assert summ.risk_priority(p * i) == priority

    def test_high_risks_are_score_ten_or_more(self, summ, full_input_data):
        data = copy.deepcopy(full_input_data)
        data["risks"][0].update({"probability": 2, "impact": 5})   # 10 -> high
        data["risks"][1].update({"probability": 3, "impact": 3})   # 9 -> not high
        s = summ.compute_summary(data)
        assert [r["id"] for r in s["risks"] if r["high"]] == ["R1"]
        assert s["high_risk_ids"] == ["R1"]


# ---------------------------------------------------------------------------
# Input validation
# ---------------------------------------------------------------------------

class TestValidation:
    def test_valid_fixture_has_no_errors(self, summ, full_input_data):
        errors, _ = summ.validate_input(full_input_data)
        assert errors == []

    def test_missing_top_level_key(self, summ, full_input_data):
        data = copy.deepcopy(full_input_data)
        del data["risks"]
        errors, _ = summ.validate_input(data)
        assert any("risks" in e for e in errors)

    def test_missing_activity_field(self, summ, full_input_data):
        data = copy.deepcopy(full_input_data)
        del data["phases"][0]["work_packages"][0]["activities"][0]["likely_effort"]
        errors, _ = summ.validate_input(data)
        assert any("1.1.1" in e and "likely_effort" in e for e in errors)

    def test_inverted_three_points(self, summ, full_input_data):
        data = copy.deepcopy(full_input_data)
        act = data["phases"][0]["work_packages"][0]["activities"][0]
        act.update({"best_effort": 6, "likely_effort": 3, "worst_effort": 5})
        errors, _ = summ.validate_input(data)
        assert any("1.1.1" in e and "best" in e for e in errors)

    @pytest.mark.parametrize("value", [None, True, "0.10", -0.1])
    def test_management_reserve_must_be_a_number(self, summ, full_input_data, value):
        # null would crash the figures and write "*None" into the Risks-sheet reserve formula.
        data = copy.deepcopy(full_input_data)
        data["config"]["management_reserve_pct"] = value
        errors, _ = summ.validate_input(data)
        assert any("management_reserve_pct" in e and "number >= 0" in e for e in errors), errors

    def test_probability_out_of_range(self, summ, full_input_data):
        data = copy.deepcopy(full_input_data)
        data["risks"][0]["probability"] = 6
        errors, _ = summ.validate_input(data)
        assert any("R1" in e and "probability" in e for e in errors)

    def test_rule_8_80_in_person_days(self, summ, full_input_data):
        data = copy.deepcopy(full_input_data)
        act = data["phases"][1]["work_packages"][0]["activities"][0]
        act.update({"best_effort": 10, "likely_effort": 12, "worst_effort": 16})
        _, warnings = summ.validate_input(data)
        assert any("2.1.1" in w and "8/80" in w for w in warnings)

    def test_rule_8_80_in_hours(self, summ, full_input_data):
        data = copy.deepcopy(full_input_data)
        data["config"]["effort_unit"] = "hours"
        for p in data["phases"]:
            for wp in p["work_packages"]:
                for a in wp["activities"]:
                    a.update({"best_effort": 16, "likely_effort": 24, "worst_effort": 40})
        _, warnings = summ.validate_input(data)
        assert not any("8/80" in w for w in warnings)

    def test_unknown_primary_role_warns(self, summ, full_input_data):
        data = copy.deepcopy(full_input_data)
        data["phases"][0]["work_packages"][0]["activities"][0]["resources"] = ["XX"]
        _, warnings = summ.validate_input(data)
        assert any("1.1.1" in w and "XX" in w for w in warnings)

    def test_ignored_keys_are_reported(self, summ, full_input_data):
        # The fixture carries resource_allocation, targets, period_type: the generator reads none.
        _, warnings = summ.validate_input(full_input_data)
        joined = " ".join(warnings)
        assert "resource_allocation" in joined
        assert "targets" in joined
        assert "period_type" in joined


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

class TestCli:
    def _run(self, *args):
        return subprocess.run(
            [sys.executable, str(SCRIPTS_DIR / "summarize.py"), *args],
            capture_output=True, text=True, cwd=str(SCRIPTS_DIR),
        )

    def test_json_to_stdout_and_file(self, input_json_path, tmp_path):
        out = tmp_path / "summary.json"
        res = self._run("--input", str(input_json_path), "--output", str(out))
        assert res.returncode == 0, res.stderr
        printed = json.loads(res.stdout)
        saved = json.loads(out.read_text(encoding="utf-8"))
        assert printed == saved
        assert saved["effort"]["medium_band"] == pytest.approx(27.13, abs=0.01)

    def test_missing_input_exits_1(self, tmp_path):
        res = self._run("--input", str(tmp_path / "nope.json"))
        assert res.returncode == 1
        assert "not found" in res.stderr

    def test_invalid_input_exits_1(self, tmp_path, full_input_data):
        data = copy.deepcopy(full_input_data)
        data["risks"][0]["impact"] = 0
        p = tmp_path / "bad.json"
        p.write_text(json.dumps(data), encoding="utf-8")
        res = self._run("--input", str(p))
        assert res.returncode == 1
        assert "impact" in res.stderr

    def test_null_management_reserve_exits_1(self, tmp_path, full_input_data):
        data = copy.deepcopy(full_input_data)
        data["config"]["management_reserve_pct"] = None
        p = tmp_path / "null-mr.json"
        p.write_text(json.dumps(data), encoding="utf-8")
        res = self._run("--input", str(p))
        assert res.returncode == 1, res.stderr
        assert "management_reserve_pct" in res.stderr
        assert "Traceback" not in res.stderr

    def test_markdown_output(self, input_json_path):
        res = self._run("--input", str(input_json_path), "--format", "markdown")
        assert res.returncode == 0, res.stderr
        assert "Medium Band" in res.stdout
        assert "Calendar Duration" in res.stdout
