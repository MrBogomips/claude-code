"""Checks on excel-input.json before the workbook is generated.

Errors are inputs the generator would crash on or turn into a wrong workbook
(missing fields, inverted three-point values, a percentage given as 10 instead of
0.10, a work package with no activities). Warnings are inputs that generate but
deserve a look: keys the generator never reads, activities outside the 8/80 rule,
activities with no primary role.
"""
from __future__ import annotations

from typing import Any

from helpers.figures import is_number, rule_8_80_bounds

REQUIRED_TOP = ("config", "roles", "phases", "risks")
KNOWN_TOP = set(REQUIRED_TOP) | {"scenarios"}
KNOWN_CONFIG = {
    "lang", "effort_unit", "duration_unit", "primary_color", "currency",
    "project_start_date", "start_date", "management_reserve_pct", "avg_rate",
    "pm_overhead_pct", "devops_overhead_pct", "alta_uplift_pct", "calendar_total_weeks",
}
RATIO_KEYS = ("management_reserve_pct", "pm_overhead_pct", "devops_overhead_pct", "alta_uplift_pct")
PHASE_KEYS_NOT_READ = ("best_duration", "likely_duration", "worst_duration")
ACTIVITY_NUMBERS = [f"{p}_{k}" for k in ("effort", "duration") for p in ("best", "likely", "worst")]


def validate_input(data: Any) -> tuple[list[str], list[str]]:
    """Return (errors, warnings) for an excel-input.json document."""
    errors: list[str] = []
    warnings: list[str] = []
    if not isinstance(data, dict):
        return ["the input must be a JSON object"], warnings
    missing = [k for k in REQUIRED_TOP if k not in data]
    if missing:
        return [f"missing required top-level key(s): {', '.join(missing)}"], warnings
    for key in sorted(set(data) - KNOWN_TOP):
        warnings.append(f"top-level key '{key}' is not read by the generator")
    _check_config(data["config"], errors, warnings)
    role_codes = _check_roles(data["roles"], errors)
    phase_ids = _check_phases(data["phases"], data["config"], role_codes, errors, warnings)
    _check_risks(data["risks"], phase_ids, errors, warnings)
    scenarios = data.get("scenarios")
    if scenarios is not None and not (isinstance(scenarios, list) and all(isinstance(s, str) for s in scenarios)):
        errors.append("scenarios must be a list of strings")
    return errors, warnings


def _check_config(cfg: Any, errors: list[str], warnings: list[str]) -> None:
    if not isinstance(cfg, dict):
        errors.append("config must be an object")
        return
    for key in sorted(set(cfg) - KNOWN_CONFIG):
        warnings.append(f"config.{key} is not read by the generator")
    if "start_date" in cfg:
        if "project_start_date" in cfg:
            warnings.append("config.start_date is not read by the generator (project_start_date is set)")
        else:
            warnings.append("config.start_date is a legacy alias: rename it to project_start_date")
    if "management_reserve_pct" not in cfg:
        errors.append("config.management_reserve_pct is required (e.g. 0.10 for 10%)")
    elif cfg["management_reserve_pct"] is None:
        # null would reach the Risks-sheet reserve formula as "*None" while the Summary uses 0.
        errors.append("config.management_reserve_pct must be a number >= 0 (e.g. 0.10 for 10%), not null")
    for key in RATIO_KEYS:
        if key in cfg and cfg[key] is not None:
            v = cfg[key]
            if not is_number(v) or v < 0:
                errors.append(f"config.{key} must be a number >= 0")
            elif v > 1:
                errors.append(f"config.{key} is a ratio: write {v / 100:g} for {v:g}%, not {v:g}")
    weeks = cfg.get("calendar_total_weeks")
    if weeks is not None and not (is_number(weeks) and weeks > 0):
        errors.append("config.calendar_total_weeks must be a positive number or null")
    if cfg.get("avg_rate") is not None and not is_number(cfg["avg_rate"]):
        errors.append("config.avg_rate must be a number or null")


def _check_roles(roles: Any, errors: list[str]) -> set[str]:
    if not isinstance(roles, list):
        errors.append("roles must be a list")
        return set()
    codes: set[str] = set()
    for i, role in enumerate(roles):
        code = role.get("code") if isinstance(role, dict) else None
        if not code:
            errors.append(f"roles[{i}] has no code")
            continue
        if code in codes:
            errors.append(f"role code '{code}' is used twice")
        codes.add(code)
    return codes


def _check_phases(phases: Any, cfg: dict, role_codes: set[str],
                  errors: list[str], warnings: list[str]) -> set[str]:
    if not isinstance(phases, list) or not phases:
        errors.append("phases must be a non-empty list")
        return set()
    ids: set[str] = set()
    lo, hi = rule_8_80_bounds(cfg.get("effort_unit", "pd") if isinstance(cfg, dict) else "pd")
    unit = cfg.get("effort_unit", "pd") if isinstance(cfg, dict) else "pd"
    for i, phase in enumerate(phases):
        if not isinstance(phase, dict) or not phase.get("id") or not phase.get("name"):
            errors.append(f"phases[{i}] needs an id and a name")
            continue
        pid = phase["id"]
        ids.add(pid)
        for key in PHASE_KEYS_NOT_READ:
            if key in phase:
                warnings.append(f"phase {pid}: {key} is not read by the generator "
                                "(phase rollups are computed from the activities)")
        if ("start_week" in phase) != ("end_week" in phase):
            warnings.append(f"phase {pid}: start_week and end_week are used only together")
        wps = phase.get("work_packages")
        if not isinstance(wps, list) or not wps:
            errors.append(f"phase {pid} has no work_packages")
            continue
        for wp in wps:
            _check_work_package(pid, wp, role_codes, (lo, hi, unit), errors, warnings)
    return ids


def _check_work_package(pid: str, wp: Any, role_codes: set[str], rule: tuple,
                        errors: list[str], warnings: list[str]) -> None:
    if not isinstance(wp, dict) or not wp.get("id") or not wp.get("name"):
        errors.append(f"phase {pid}: every work package needs an id and a name")
        return
    acts = wp.get("activities")
    if not isinstance(acts, list) or not acts:
        errors.append(f"work package {wp['id']} has no activities")
        return
    for act in acts:
        _check_activity(act, role_codes, rule, errors, warnings)


def _check_activity(act: Any, role_codes: set[str], rule: tuple,
                    errors: list[str], warnings: list[str]) -> None:
    if not isinstance(act, dict) or not act.get("id") or not act.get("name"):
        errors.append("every activity needs an id and a name")
        return
    aid = act["id"]
    bad = [k for k in ACTIVITY_NUMBERS if not (is_number(act.get(k)) and act.get(k) >= 0)]
    if bad:
        errors.append(f"activity {aid}: {', '.join(bad)} must be numbers >= 0")
        return
    for kind in ("effort", "duration"):
        o, m, p = (act[f"{x}_{kind}"] for x in ("best", "likely", "worst"))
        if not o <= m <= p:
            errors.append(f"activity {aid}: best <= likely <= worst {kind} is required, found {o}/{m}/{p}")
    lo, hi, unit = rule
    if not lo <= act["likely_effort"] <= hi:
        warnings.append(f"activity {aid}: most-likely effort {act['likely_effort']:g} {unit} is outside "
                        f"the 8/80 rule ({lo:g}-{hi:g} {unit}); split or merge it")
    resources = act.get("resources") or []
    if not resources:
        warnings.append(f"activity {aid}: no resources, so it is left out of the Resource Plan "
                        "and of Effort by Team")
    elif role_codes and resources[0] not in role_codes:
        warnings.append(f"activity {aid}: primary role {resources[0]} is not in roles "
                        "(its effort goes to team 'Unassigned')")


def _check_risks(risks: Any, phase_ids: set[str], errors: list[str], warnings: list[str]) -> None:
    if not isinstance(risks, list):
        errors.append("risks must be a list")
        return
    for i, risk in enumerate(risks):
        if not isinstance(risk, dict):
            errors.append(f"risks[{i}] must be an object")
            continue
        rid = risk.get("id") or f"risks[{i}]"
        for key in ("id", "description", "category"):
            if not risk.get(key):
                errors.append(f"risk {rid}: {key} is required")
        for key in ("probability", "impact"):
            v = risk.get(key)
            if not (isinstance(v, int) and not isinstance(v, bool) and 1 <= v <= 5):
                errors.append(f"risk {rid}: {key} must be an integer from 1 to 5")
        ce = risk.get("contingency_effort")
        if ce is not None and not (is_number(ce) and ce >= 0):
            errors.append(f"risk {rid}: contingency_effort must be a number >= 0 or null")
        unknown = [p for p in risk.get("affected_phases", []) if phase_ids and p not in phase_ids]
        if unknown:
            warnings.append(f"risk {rid}: affected_phases {', '.join(unknown)} are not phase ids")
