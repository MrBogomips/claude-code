"""Localization for pmo-pert-estimate output labels.

LABELS holds a dict per supported language. Keys are stable identifiers; values
are display strings. t() resolves a key for a given language, falling back to en.
"""
from typing import Final

LABELS: Final[dict[str, dict[str, str]]] = {
    "en": {
        # Sheet titles
        "sheet_wbs": "WBS",
        "sheet_resource_plan": "Resource Plan",
        "sheet_risks": "Risks",
        "sheet_summary": "Summary",
        # Resource Plan column headers
        "rp_role": "Role",
        "rp_code": "Code",
        "rp_type": "Type",
        "rp_billable": "billable",
        "rp_non_billable": "non-billable",
        "rp_total_pd": "TOTAL (PD)",
        "rp_week_total": "Weekly TOTAL",
        "rp_calendar_row": "Week of",
        "rp_capacity_warning": "Capacity Warnings",
        "rp_overcommit": "Overcommit: {wk} ({pd:.1f} PD vs {cap:.1f} PD capacity)",
        # Summary
        "summary_tech_pert": "Tech PERT Effort (PD)",
        "summary_pm_overhead": "PM Overhead (+{pct}%) (PD)",
        "summary_devops_overhead": "DevOps Overhead (+{pct}%) (PD)",
        "summary_subtotal": "Subtotal Tech + Overhead (PD)",
        "summary_contingency": "Contingency per-risk (PD)",
        "fascia_bassa": "Low Band",
        "summary_management_reserve": "Management Reserve ({pct}%) (PD)",
        "fascia_media": "Medium Band (recommended)",
        "fascia_alta": "High Band",
        "summary_effort_by_team": "Effort by Team (PD)",
        "summary_calendar_duration": "Calendar Duration (weeks)",
        "summary_sensitivity": "Sensitivity Scenarios",
        "summary_billable_ratio": "Billable Ratio",
        "summary_total_billable": "Total Billable Effort (PD)",
        # Generic
        "management_reserve_with_pct": "Management Reserve ({pct}%)",
        "total": "TOTAL",
    },
    "it": {
        "sheet_wbs": "WBS",
        "sheet_resource_plan": "Pianificazione Risorse",
        "sheet_risks": "Rischi",
        "sheet_summary": "Riepilogo",
        "rp_role": "Ruolo",
        "rp_code": "Codice",
        "rp_type": "Tipo",
        "rp_billable": "billable",
        "rp_non_billable": "non-billable",
        "rp_total_pd": "TOTALE (PD)",
        "rp_week_total": "TOTALE settimana",
        "rp_calendar_row": "Settimana del",
        "rp_capacity_warning": "Warning capacity",
        "rp_overcommit": "Overcommit: {wk} ({pd:.1f} PD vs {cap:.1f} PD capacity)",
        "summary_tech_pert": "Tech PERT Effort (PD)",
        "summary_pm_overhead": "PM Overhead (+{pct}%) (PD)",
        "summary_devops_overhead": "DevOps Overhead (+{pct}%) (PD)",
        "summary_subtotal": "Subtotale Tech + Overhead (PD)",
        "summary_contingency": "Contingency per-rischio (PD)",
        "fascia_bassa": "Fascia BASSA",
        "summary_management_reserve": "Management Reserve ({pct}%) (PD)",
        "fascia_media": "Fascia MEDIA (raccomandata)",
        "fascia_alta": "Fascia ALTA",
        "summary_effort_by_team": "Effort per Team (PD)",
        "summary_calendar_duration": "Durata Calendario (settimane)",
        "summary_sensitivity": "Scenari di Sensitivity",
        "summary_billable_ratio": "Quota Billable",
        "summary_total_billable": "Effort Billable Totale (PD)",
        "management_reserve_with_pct": "Management Reserve ({pct}%)",
        "total": "TOTALE",
    },
}


def t(lang: str, key: str, **fmt: object) -> str:
    """Resolve label `key` for `lang`. Falls back to en if lang is unknown.

    Raises KeyError if the key is missing in the requested language and in en.
    """
    table = LABELS.get(lang, LABELS["en"])
    if key not in table:
        if key not in LABELS["en"]:
            raise KeyError(f"Unknown label key: {key}")
        table = LABELS["en"]
    return table[key].format(**fmt) if fmt else table[key]
