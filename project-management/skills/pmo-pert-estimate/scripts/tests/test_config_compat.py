"""Tests for legacy JSON detection and backfill."""
from helpers.config_compat import MODERN_CONFIG_FIELDS, normalize_config


def _base_data() -> dict:
    return {
        "config": {"effort_unit": "pd"},
        "phases": [{"id": "1"}],
        "roles": [],
        "risks": [],
    }


def test_legacy_json_gets_defaults_and_warns(capsys) -> None:
    out = normalize_config(_base_data())
    cfg = out["config"]
    assert cfg["pm_overhead_pct"] == 0.0
    assert cfg["devops_overhead_pct"] == 0.0
    assert cfg["alta_uplift_pct"] == 0.12
    assert cfg["calendar_total_weeks"] is None
    err = capsys.readouterr().err
    assert "LEGACY JSON" in err


def test_modern_json_no_warning(capsys) -> None:
    data = _base_data()
    data["config"].update(
        {
            "pm_overhead_pct": 0.1,
            "devops_overhead_pct": 0.05,
            "alta_uplift_pct": 0.12,
            "calendar_total_weeks": 25,
        }
    )
    out = normalize_config(data)
    assert out["config"]["pm_overhead_pct"] == 0.1
    err = capsys.readouterr().err
    assert "LEGACY" not in err


def test_partial_modern_json_emits_warning(capsys) -> None:
    data = _base_data()
    data["config"]["pm_overhead_pct"] = 0.1
    # calendar info missing => warns
    normalize_config(data)
    err = capsys.readouterr().err
    assert "LEGACY JSON" in err


def test_phase_weeks_satisfy_calendar_requirement(capsys) -> None:
    data = _base_data()
    data["config"].update(
        {
            "pm_overhead_pct": 0.0,
            "devops_overhead_pct": 0.0,
            "alta_uplift_pct": 0.12,
            # calendar_total_weeks omitted on purpose
        }
    )
    data["phases"] = [{"id": "1", "start_week": 1, "end_week": 4}]
    normalize_config(data)
    err = capsys.readouterr().err
    # With explicit phase weeks AND modern config fields, no warning.
    assert "LEGACY" not in err


def test_normalize_does_not_mutate_input() -> None:
    data = _base_data()
    snapshot = {"config": dict(data["config"]), "phases": list(data["phases"])}
    normalize_config(data)
    assert data["config"] == snapshot["config"]
    assert data["phases"] == snapshot["phases"]


def test_modern_config_fields_constant_complete() -> None:
    # Guards against accidentally dropping a default key.
    assert set(MODERN_CONFIG_FIELDS.keys()) == {
        "pm_overhead_pct",
        "devops_overhead_pct",
        "alta_uplift_pct",
        "calendar_total_weeks",
    }
