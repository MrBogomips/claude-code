"""Workbook figures computed from excel-input.json, with the generator's own formulas.

openpyxl writes formula strings and no cached values, so a generated workbook cannot
be read back for numbers. This module computes the same figures the workbook shows:
rollups (same linear sums as the WBS rows), the Summary effort block and bands, the
Risks-sheet Management Reserve, the Resource Plan totals and the calendar duration.
It reuses the helpers the sheet builders use, so the two cannot drift apart silently.
"""
from __future__ import annotations

import math
from typing import Any

from helpers.config_compat import normalize_config
from helpers.wb_pianificazione_risorse import (
    ROLE_WEEKLY_CAPACITY_PD,
    _build_calendar_plan,
    _compute_phase_role_pd,
)
from helpers.wb_summary import _resolve_calendar_weeks, _team_effort_pd

#: P x I score from which a risk counts as high (HIGH or CRITICAL priority).
HIGH_RISK_SCORE = 10

_THREE_POINT = ("best", "likely", "worst")
_FIELDS = [f"{p}_{k}" for k in ("effort", "duration") for p in _THREE_POINT]


def pert(o: float, m: float, p: float) -> float:
    """PERT weighted mean, as in the workbook: (O + 4M + P) / 6."""
    return (o + 4 * m + p) / 6.0


def risk_priority(score: float) -> str:
    """Same thresholds as the Risks sheet Priority formula."""
    if score >= 15:
        return "CRITICAL"
    if score >= HIGH_RISK_SCORE:
        return "HIGH"
    if score >= 5:
        return "MEDIUM"
    return "LOW"


def _r(x: float | None, nd: int = 2) -> float | None:
    return None if x is None else round(float(x), nd)


def _rollup(activities: list[dict]) -> dict[str, float]:
    """Linear rollup, exactly like a WBS work-package or phase row."""
    s = {f: float(sum(a[f] for a in activities)) for f in _FIELDS}
    s["pert_effort"] = pert(s["best_effort"], s["likely_effort"], s["worst_effort"])
    s["pert_duration"] = pert(s["best_duration"], s["likely_duration"], s["worst_duration"])
    s["sigma_duration"] = (s["worst_duration"] - s["best_duration"]) / 6.0
    s["billable_pert_effort"] = sum(
        pert(a["best_effort"], a["likely_effort"], a["worst_effort"])
        for a in activities if a.get("billable", True)
    )
    return s


def _rounded(values: dict[str, float]) -> dict[str, float]:
    return {k: _r(v) for k, v in values.items()}


def _leaves(phase: dict) -> list[dict]:
    return [a for wp in phase.get("work_packages", []) for a in wp.get("activities", [])]


def _phase_figures(phase: dict) -> dict[str, Any]:
    wps = [
        {"id": wp["id"], "name": wp["name"], **_rounded(_rollup(wp.get("activities", [])))}
        for wp in phase.get("work_packages", [])
    ]
    return {"id": phase["id"], "name": phase["name"],
            **_rounded(_rollup(_leaves(phase))), "work_packages": wps}


def _resource_plan(phases: list[dict], config: dict) -> dict[str, Any]:
    """Role x week distribution, as the Resource Plan builder writes it."""
    plan, total_weeks = _build_calendar_plan(phases, config)
    phase_role_pd, skipped = _compute_phase_role_pd(phases)
    role_week: dict[str, dict[int, float]] = {}
    for (phase_id, role), pd in phase_role_pd.items():
        weeks = plan.get(phase_id, [])
        for w in weeks:
            role_week.setdefault(role, {}).setdefault(w, 0.0)
            role_week[role][w] += pd / len(weeks)
    written = [round(v, 2) for weeks in role_week.values() for v in weeks.values()]
    skipped_pd = sum(
        pert(a["best_effort"], a["likely_effort"], a["worst_effort"])
        for p in phases for a in _leaves(p) if a["id"] in skipped
    )
    overcommits = [
        {"role": role, "week": w, "pd": _r(v)}
        for role in sorted(role_week) for w, v in sorted(role_week[role].items())
        if v > ROLE_WEEKLY_CAPACITY_PD
    ]
    return {
        "total_weeks": total_weeks,
        "role_codes": sorted(role_week),
        "role_total_pd": {r: _r(sum(w.values())) for r, w in sorted(role_week.items())},
        "grand_total_pd": _r(sum(written)),
        "skipped_activities": skipped,
        "skipped_pd": _r(skipped_pd),
        "overcommits": overcommits,
    }


def _effort_block(tech: float, cfg: dict, contingency: float, billable: float) -> dict:
    """Summary sheet effort rows, plus the Risks sheet MR, with the workbook formulas."""
    pm = float(cfg.get("pm_overhead_pct") or 0)
    devops = float(cfg.get("devops_overhead_pct") or 0)
    alta = float(cfg.get("alta_uplift_pct") or 0)
    mr_pct = float(cfg.get("management_reserve_pct") or 0)
    subtotal = tech + tech * pm + tech * devops
    low = subtotal + contingency
    mr = low * mr_pct
    medium = low + mr
    risks_mr = (tech * (1 + pm + devops) + contingency) * float(
        cfg.get("management_reserve_pct", 0.10))
    return {
        "tech_pert": _r(tech), "pm_overhead": _r(tech * pm), "devops_overhead": _r(tech * devops),
        "subtotal": _r(subtotal), "contingency": _r(contingency), "low_band": _r(low),
        "management_reserve": _r(mr), "medium_band": _r(medium),
        "high_band": _r(medium * (1 + alta)), "total_billable": _r(billable),
        "billable_ratio": _r(billable / tech, 4) if tech else None,
        "management_reserve_risks_sheet": _r(risks_mr),
    }


def _risk_rows(risks: list[dict]) -> list[dict]:
    rows = []
    for r in risks:
        score = r["probability"] * r["impact"]
        rows.append({
            "id": r["id"], "score": score, "priority": risk_priority(score),
            "high": score >= HIGH_RISK_SCORE, "contingency_effort": r.get("contingency_effort"),
        })
    return rows


def compute_summary(data: dict) -> dict[str, Any]:
    """Return every figure the workbook shows, computed from the JSON input."""
    data = normalize_config(data)
    cfg, phases = data["config"], data["phases"]
    leaves = [a for p in phases for a in _leaves(p)]
    totals = _rollup(leaves)
    contingency = float(sum(r.get("contingency_effort") or 0 for r in data["risks"]))
    rp = _resource_plan(phases, cfg)
    risks = _risk_rows(data["risks"])
    return {
        "lang": cfg.get("lang", "en"),
        "effort_unit": cfg.get("effort_unit", "pd"),
        "counts": {
            "phases": len(phases),
            "work_packages": sum(len(p.get("work_packages", [])) for p in phases),
            "activities": len(leaves),
            "roles": len(data["roles"]),
            "risks": len(data["risks"]),
        },
        "phases": [_phase_figures(p) for p in phases],
        "totals": _rounded(totals),
        "effort": _effort_block(totals["pert_effort"], cfg, contingency,
                                totals["billable_pert_effort"]),
        "calendar_weeks": _resolve_calendar_weeks(cfg, phases, {"total_weeks": rp["total_weeks"]}),
        "effort_by_team": {k: _r(v) for k, v in sorted(_team_effort_pd(phases, data["roles"]).items())},
        "resource_plan": rp,
        "risks": risks,
        "high_risk_ids": [r["id"] for r in risks if r["high"]],
        "scenarios": list(data.get("scenarios") or []),
    }


def rule_8_80_bounds(effort_unit: str) -> tuple[float, float]:
    """8/80 hours per activity, expressed in the input's effort unit (8 h = 1 PD)."""
    if str(effort_unit).lower() in ("h", "hour", "hours"):
        return 8.0, 80.0
    return 1.0, 10.0


def is_number(v: Any) -> bool:
    return isinstance(v, (int, float)) and not isinstance(v, bool) and math.isfinite(v)
