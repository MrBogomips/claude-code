"""Detect legacy JSON input and backfill modern defaults.

The skill schema evolved to include PM/DevOps overhead, the high-band uplift,
and calendar-aware durations. JSON written against the old schema is still
accepted: this module backfills sane defaults and emits a single stderr
warning per generator invocation so the user knows they're on the old format.
"""
import copy
import sys
from typing import Any, Final

#: Modern config fields, with their default value when absent from input.
MODERN_CONFIG_FIELDS: Final[dict[str, object]] = {
    "pm_overhead_pct": 0.0,
    "devops_overhead_pct": 0.0,
    "alta_uplift_pct": 0.12,
    "calendar_total_weeks": None,
}


def _has_calendar_info(data: dict[str, Any]) -> bool:
    """True if the data carries enough calendar info to skip the legacy warning."""
    cfg = data.get("config", {})
    if cfg.get("calendar_total_weeks") is not None:
        return True
    return any(
        "start_week" in p or "end_week" in p for p in data.get("phases", [])
    )


def normalize_config(data: dict[str, Any]) -> dict[str, Any]:
    """Return a deep copy of *data* with modern config fields backfilled.

    Emits a one-line stderr warning when the input lacks modern fields. The
    warning fires if any of pm_overhead_pct / devops_overhead_pct /
    alta_uplift_pct is missing, OR if no calendar info is present
    (config.calendar_total_weeks set, or any phase carries start_week/end_week).
    """
    out = copy.deepcopy(data)
    cfg = out.setdefault("config", {})

    overhead_keys = ("pm_overhead_pct", "devops_overhead_pct", "alta_uplift_pct")
    missing_overhead = [k for k in overhead_keys if k not in cfg]
    needs_warning = bool(missing_overhead) or not _has_calendar_info(out)

    if needs_warning:
        print(
            "[pmo-pert] LEGACY JSON: missing modern fields; using defaults. "
            "See references/excel-schema.md for migration.",
            file=sys.stderr,
        )

    for k, v in MODERN_CONFIG_FIELDS.items():
        cfg.setdefault(k, v)
    return out
