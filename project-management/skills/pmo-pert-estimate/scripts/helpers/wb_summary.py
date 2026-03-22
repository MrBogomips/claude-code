"""Summary sheet generator for pmo-pert-estimate Excel output.

Builds a 'Summary' worksheet that cross-references the WBS, Risks, and
Resources sheets, providing:
  - Phase-level PERT summary table with σ-based confidence intervals
  - Total / billable effort and billable ratio
  - Contingency and management reserve references
  - Per-team effort subtotals from the Resources sheet
"""
from __future__ import annotations

from openpyxl import Workbook
from openpyxl.styles import Alignment, Font, PatternFill
from openpyxl.utils import get_column_letter

from helpers.formatting import (
    HEADER_FONT,
    NUMBER_FMT,
    apply_column_widths,
    apply_style,
    get_formula_fill,
    get_total_style,
)

# ---------------------------------------------------------------------------
# Column layout for the Summary phase table
# (1-based indices)
# ---------------------------------------------------------------------------

# A  Phase name (cross-ref to WBS)
# B  Description (plain text)
# C  Best Effort
# D  Likely Effort
# E  Worst Effort
# F  PERT Effort
# G  Best Duration
# H  Likely Duration
# I  Worst Duration
# J  PERT Duration
# K  σ Duration

_COL_PHASE = 1       # A
_COL_DESC = 2        # B
_COL_BEST_E = 3      # C
_COL_LIKELY_E = 4    # D
_COL_WORST_E = 5     # E
_COL_PERT_E = 6      # F
_COL_BEST_D = 7      # G
_COL_LIKELY_D = 8    # H
_COL_WORST_D = 9     # I
_COL_PERT_D = 10     # J
_COL_SIGMA = 11      # K

_HEADER_ROW = 1
_DATA_START_ROW = 2

_COLUMN_WIDTHS = {
    "A": 30,
    "B": 35,
    "C": 14,
    "D": 14,
    "E": 14,
    "F": 14,
    "G": 14,
    "H": 14,
    "I": 14,
    "J": 14,
    "K": 12,
}


# ---------------------------------------------------------------------------
# Public API
# ---------------------------------------------------------------------------

def build(
    wb: Workbook,
    data: dict,
    wbs_info: dict,
    risks_info: dict,
    resources_info: dict,
) -> None:
    """Build the Summary sheet and insert it into *wb*.

    Args:
        wb:             An openpyxl Workbook instance.
        data:           Full input dict (config, phases, roles, …).
        wbs_info:       sheet_info dict returned by wb_wbs.build().
        risks_info:     sheet_info dict returned by wb_risks.build().
        resources_info: sheet_info dict returned by wb_resources.build().
    """
    config = data["config"]
    phases = data["phases"]
    primary_color = config.get("primary_color", "1B4FA5")
    effort_unit = config.get("effort_unit", "pd")
    duration_unit = config.get("duration_unit", "d")

    ws = wb.create_sheet("Summary")

    # ------------------------------------------------------------------
    # Row 1: Headers
    # ------------------------------------------------------------------
    _write_header(ws, effort_unit, duration_unit)

    # ------------------------------------------------------------------
    # Phase data rows (one per phase)
    # ------------------------------------------------------------------
    phase_rows = wbs_info["phase_rows"]
    wbs_total_row = wbs_info["total_row"]

    for summary_offset, (phase, wbs_phase_row) in enumerate(
        zip(phases, phase_rows)
    ):
        summary_row = _DATA_START_ROW + summary_offset
        _write_phase_row(ws, summary_row, phase, wbs_phase_row)

    num_phases = len(phases)
    data_start = _DATA_START_ROW
    data_end = _DATA_START_ROW + num_phases - 1

    # ------------------------------------------------------------------
    # Total row
    # ------------------------------------------------------------------
    total_row = data_end + 1
    _write_total_row(ws, total_row, data_start, data_end)

    # ------------------------------------------------------------------
    # Summary block (blank row separator, then label/formula pairs)
    # ------------------------------------------------------------------
    # We place labels in column A and formulas in column B.
    # Column letters for the sigma total reference:
    sigma_col = get_column_letter(_COL_SIGMA)    # K
    pert_d_col = get_column_letter(_COL_PERT_D)  # J
    pert_e_col = get_column_letter(_COL_PERT_E)  # F

    sigma_total_cell = None   # will be set when we write the σ total row
    pert_effort_cell = None   # will be set when we write the PERT effort row
    contingency_cell = None   # will be set for contingency row
    reserve_cell = None       # will be set for reserve row

    block_start = total_row + 2  # +1 blank separator, +1 first block row
    current = block_start

    # --- Total PERT Effort (pd) ---
    # References the total row's PERT Effort column (F) on this sheet
    ws.cell(row=current, column=1, value=f"Total PERT Effort ({effort_unit})")
    pert_effort_ref = f"={pert_e_col}{total_row}"
    ws.cell(row=current, column=2, value=pert_effort_ref)
    pert_effort_cell_addr = f"B{current}"
    current += 1

    # --- Total Billable Effort (pd) ---
    ws.cell(row=current, column=1, value=f"Total Billable Effort ({effort_unit})")
    ws.cell(row=current, column=2, value=f"=WBS!S{wbs_total_row}")
    current += 1

    # --- Billable Ratio ---
    billable_row = current - 1
    pert_row_in_block = current - 2
    ws.cell(row=current, column=1, value="Billable Ratio")
    ws.cell(
        row=current,
        column=2,
        value=f"=B{billable_row}/B{pert_row_in_block}",
    )
    current += 1

    # --- σ Total Duration ---
    ws.cell(row=current, column=1, value="σ Total Duration")
    sigma_formula = (
        f"=SQRT(SUMPRODUCT({sigma_col}{data_start}:{sigma_col}{data_end},"
        f"{sigma_col}{data_start}:{sigma_col}{data_end}))"
    )
    ws.cell(row=current, column=2, value=sigma_formula)
    sigma_cell_addr = f"B{current}"
    current += 1

    # --- CI 68% Lower / Upper ---
    pert_d_total_ref = f"{pert_d_col}{total_row}"
    ws.cell(row=current, column=1, value="CI 68% Lower")
    ws.cell(row=current, column=2, value=f"={pert_d_total_ref}-{sigma_cell_addr}")
    current += 1

    ws.cell(row=current, column=1, value="CI 68% Upper")
    ws.cell(row=current, column=2, value=f"={pert_d_total_ref}+{sigma_cell_addr}")
    current += 1

    # --- CI 95% Lower / Upper ---
    ws.cell(row=current, column=1, value="CI 95% Lower")
    ws.cell(row=current, column=2, value=f"={pert_d_total_ref}-2*{sigma_cell_addr}")
    current += 1

    ws.cell(row=current, column=1, value="CI 95% Upper")
    ws.cell(row=current, column=2, value=f"={pert_d_total_ref}+2*{sigma_cell_addr}")
    current += 1

    # --- Total Contingency ---
    total_contingency_row = risks_info["total_contingency_row"]
    ws.cell(row=current, column=1, value="Total Contingency")
    ws.cell(row=current, column=2, value=f"=Risks!L{total_contingency_row}")
    contingency_row_here = current
    current += 1

    # --- Management Reserve ---
    reserve_row = risks_info["reserve_row"]
    ws.cell(row=current, column=1, value="Management Reserve")
    ws.cell(row=current, column=2, value=f"=Risks!L{reserve_row}")
    reserve_row_here = current
    current += 1

    # --- Adjusted PERT Effort ---
    ws.cell(row=current, column=1, value=f"Adjusted PERT Effort ({effort_unit})")
    ws.cell(
        row=current,
        column=2,
        value=(
            f"=B{block_start}"
            f"+B{contingency_row_here}"
            f"+B{reserve_row_here}"
        ),
    )
    current += 1

    # ------------------------------------------------------------------
    # Team effort section
    # ------------------------------------------------------------------
    current += 1  # blank separator
    ws.cell(row=current, column=1, value="Effort by Team")
    ws.cell(row=current, column=1).font = Font(bold=True)
    current += 1

    total_effort_col = resources_info["total_effort_col"]
    for team, team_subtotal_row in resources_info["team_subtotal_rows"].items():
        ws.cell(row=current, column=1, value=team)
        ws.cell(
            row=current,
            column=2,
            value=f"=Resources!{total_effort_col}{team_subtotal_row}",
        )
        current += 1

    # ------------------------------------------------------------------
    # Formatting
    # ------------------------------------------------------------------
    _apply_formatting(ws, primary_color, data_start, data_end, total_row)
    apply_column_widths(ws, _COLUMN_WIDTHS)


# ---------------------------------------------------------------------------
# Private helpers
# ---------------------------------------------------------------------------

def _write_header(ws, effort_unit: str, duration_unit: str) -> None:
    headers = [
        "Phase",
        "Description",
        f"Best Effort ({effort_unit})",
        f"Likely Effort ({effort_unit})",
        f"Worst Effort ({effort_unit})",
        f"PERT Effort ({effort_unit})",
        f"Best Duration ({duration_unit})",
        f"Likely Duration ({duration_unit})",
        f"Worst Duration ({duration_unit})",
        f"PERT Duration ({duration_unit})",
        "\u03c3 Duration",
    ]
    for col_idx, header in enumerate(headers, start=1):
        cell = ws.cell(row=_HEADER_ROW, column=col_idx, value=header)
        cell.font = HEADER_FONT


def _write_phase_row(ws, summary_row: int, phase: dict, wbs_phase_row: int) -> None:
    # Col A: cross-reference to WBS phase name
    ws.cell(row=summary_row, column=_COL_PHASE, value=f"=WBS!B{wbs_phase_row}")
    # Col B: description (plain text)
    ws.cell(row=summary_row, column=_COL_DESC, value=phase.get("description", ""))
    # Cols C-E: effort (Best, Likely, Worst) from WBS phase row columns E, F, G
    ws.cell(row=summary_row, column=_COL_BEST_E, value=f"=WBS!E{wbs_phase_row}")
    ws.cell(row=summary_row, column=_COL_LIKELY_E, value=f"=WBS!F{wbs_phase_row}")
    ws.cell(row=summary_row, column=_COL_WORST_E, value=f"=WBS!G{wbs_phase_row}")
    # Col F: PERT Effort from WBS col H
    ws.cell(row=summary_row, column=_COL_PERT_E, value=f"=WBS!H{wbs_phase_row}")
    # Cols G-I: duration (Best, Likely, Worst) from WBS cols I, J, K
    ws.cell(row=summary_row, column=_COL_BEST_D, value=f"=WBS!I{wbs_phase_row}")
    ws.cell(row=summary_row, column=_COL_LIKELY_D, value=f"=WBS!J{wbs_phase_row}")
    ws.cell(row=summary_row, column=_COL_WORST_D, value=f"=WBS!K{wbs_phase_row}")
    # Col J: PERT Duration from WBS col L
    ws.cell(row=summary_row, column=_COL_PERT_D, value=f"=WBS!L{wbs_phase_row}")
    # Col K: σ Duration from WBS col M
    ws.cell(row=summary_row, column=_COL_SIGMA, value=f"=WBS!M{wbs_phase_row}")


def _write_total_row(ws, total_row: int, data_start: int, data_end: int) -> None:
    ws.cell(row=total_row, column=_COL_PHASE, value="TOTAL")
    for col_idx in range(_COL_BEST_E, _COL_SIGMA + 1):
        col_letter = get_column_letter(col_idx)
        ws.cell(
            row=total_row,
            column=col_idx,
            value=f"=SUM({col_letter}{data_start}:{col_letter}{data_end})",
        )
    style = get_total_style()
    for col_idx in range(1, _COL_SIGMA + 1):
        apply_style(ws.cell(row=total_row, column=col_idx), style)


def _apply_formatting(
    ws,
    primary_color: str,
    data_start: int,
    data_end: int,
    total_row: int,
) -> None:
    """Apply styles and number formats to the phase table area."""
    from helpers.formatting import get_phase_style

    phase_style = get_phase_style(primary_color)
    formula_fill = get_formula_fill()

    # Phase data rows: apply phase style
    for r in range(data_start, data_end + 1):
        for col_idx in range(1, _COL_SIGMA + 1):
            apply_style(ws.cell(row=r, column=col_idx), phase_style)

    # Formula fill for computed columns (C–K, i.e. cols 3–11 except B which is text)
    for r in range(data_start, total_row + 1):
        for col_idx in range(_COL_BEST_E, _COL_SIGMA + 1):
            ws.cell(row=r, column=col_idx).fill = formula_fill

    # Number format for numeric columns
    for r in range(data_start, total_row + 1):
        for col_idx in range(_COL_BEST_E, _COL_SIGMA + 1):
            ws.cell(row=r, column=col_idx).number_format = NUMBER_FMT
