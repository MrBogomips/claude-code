# Validation Report — Scenario 3: Mobile App MVP

**Date:** 2026-03-19
**Scenario:** Mobile App MVP — Field Operations Management
**Complexity:** Medium
**Estimation Level:** A (Formative)
**Generator version:** pmo-pert-estimate v1.x
**Input file:** `excel-input.json`
**Output file:** `pert-estimate.xlsx`

---

## Summary

**Overall result: PASS — all 14 criteria satisfied.**

The Excel workbook was generated without errors. All five sheets are present and
correctly cross-referenced. PERT formulas, CI intervals, biweekly period columns,
4 roles in Resources, 5 phases in WBS, and 6 risks with a management reserve are
all verified.

---

## Criteria Results

### Base Criteria (1–10)

| # | Criterion | Expected | Observed | Result |
|---|-----------|----------|----------|--------|
| 1 | Five worksheets present | WBS, Timeline, Resources, Risks, Summary | WBS, Timeline, Resources, Risks, Summary | PASS |
| 2 | WBS leaf activities count | ~20 | 23 | PASS |
| 3 | PERT effort formulas in WBS | `=(E+4*F+G)/6` pattern | Present on every phase, WP and leaf row | PASS |
| 4 | Risk rows in Risks sheet | 6 | 6 (R1–R6) | PASS |
| 5 | Risk score formulas | `=Probability*Impact` | `=E*F` formula present on all 6 risk rows | PASS |
| 6 | Resources sheet structure | Phase × Role matrix with TOTAL EFFORT | 9 columns: Phase, Description, Team, 4 role columns, TOTAL EFFORT, BILLABLE EFFORT; 16 data rows + subtotals | PASS |
| 7 | Summary CI formulas | Cross-refs to Summary PERT/σ totals | CI 68% Lower/Upper and CI 95% Lower/Upper rows at rows 13–16 | PASS |
| 8 | Timeline period columns | Biweekly P1..Pn | P1–P6 (6 biweekly periods) | PASS |
| 9 | No target values in input | `targets` key absent | Absent from `excel-input.json` | PASS |
| 10 | Management reserve row in Risks | Row referencing `=L(total)*reserve_pct` | Row 10: `Management Reserve` with formula `=L9*0.1` | PASS |

### Scenario-Specific Criteria (11–14)

| # | Criterion | Expected | Observed | Result |
|---|-----------|----------|----------|--------|
| 11 | 4 roles reflected in Resources | Product Owner, Mobile Dev, Backend Dev, QA | Columns D–G with exactly those 4 role names | PASS |
| 12 | 5 phases in WBS | Discovery, UX Design, Backend Development, Mobile Development, Launch | Rows 2, 9, 17, 26, 34 match all 5 phase names | PASS |
| 13 | Summary CI formulas present (68% and 95%) | 4 rows: CI 68% Lower/Upper, CI 95% Lower/Upper | Rows 13–16 of Summary sheet; formulas reference `J7` (total PERT duration) and `B12` (σ total) | PASS |
| 14 | Biweekly period columns in Timeline | Columns prefixed `P` (not `W` or `M`) | `P1` through `P6` — prefix correctly set to `P` for `period_type=biweekly` | PASS |

---

## Detailed Observations

### WBS Sheet

- 39 rows total (1 header + 5 phases + 10 work packages + 23 leaf activities + 1 TOTAL).
- Phase rows aggregate all leaf efforts via `=SUM(…)` formulas referencing only leaf rows (non-contiguous where needed).
- The TOTAL row (row 39) aggregates all 5 phase rows: `=SUM(E2,E9,E17,E26,E34)`.
- PERT effort formula: `=(E+4*F+G)/6`; PERT duration formula: `=(I+4*J+K)/6`; σ formula: `=(K-I)/6`.
- 4 risk reference columns confirmed (Resources list column 14+).

### Timeline Sheet

- 50 rows, 10 columns (4 fixed + 6 period columns P1–P6).
- Gantt bars filled: 32 coloured cells across leaf activity rows.
- Summary block includes: Critical Path, Total PERT Duration, CI 68%, CI 95%, Start Date, End Date.
- Legend present with Critical (red), Parallel (blue), Continuous (orange) entries.

### Resources Sheet

- 21 rows: 1 header + 16 data rows (resource allocation entries) + team subtotals + grand total.
- Row 1 contains billable flags (`Y`) for all 4 roles.
- Row 2 is column headers.
- Team subtotals for `Product` (row 6) and `Engineering` (row 20).
- Columns `TOTAL EFFORT` (`=SUM(D:G)`) and `BILLABLE EFFORT` (`=SUMPRODUCT(…)`) present.

### Risks Sheet

- 10 rows: 1 header + 6 risk rows (R1–R6) + 1 blank + 1 TOTAL + 1 Management Reserve.
- Risk scores: R2 (4×5=20, CRITICAL), R3 (2×5=10, HIGH), R5 (4×4=16, CRITICAL) are highest severity.
- Contingency efforts: R3=10 pd, R2=8 pd, R5=6 pd, R6=4 pd, R1=3 pd, R4=2 pd.
- Total contingency: `=SUM(L2:L7)` = 33 pd.
- Management Reserve: `=L9*0.1` = 3.3 pd (10% of contingency).
- Contingency cost column uses avg_rate=550 EUR: formula `=L*550`.

### Summary Sheet

- 23 rows covering: 5 phase rows + TOTAL row + KPI block (PERT effort, billable, ratio, σ, CI 68%, CI 95%, contingency, reserve, adjusted effort) + team effort section.
- Cross-references are correctly chained: Summary → WBS (phase rows), Summary → Risks (total contingency and reserve rows), Summary → Resources (team subtotals).
- CI 68% Lower/Upper: `=J7 ± B12`
- CI 95% Lower/Upper: `=J7 ± 2*B12`

---

## Configuration Verification

| Parameter | Expected | Observed |
|-----------|----------|----------|
| `lang` | en | en |
| `effort_unit` | pd | pd (column headers contain `(pd)`) |
| `duration_unit` | d | d (column headers contain `(d)`) |
| `primary_color` | E63946 | E63946 |
| `period_type` | biweekly | biweekly (period columns prefixed `P`) |
| `start_date` | 2026-07-01 | 2026-07-01 (Timeline summary Start Date) |
| `management_reserve_pct` | 0.10 | 0.10 (formula `=L9*0.1` in Risks row 10) |
| `avg_rate` | 550 | 550 (formula `=L*550` in Risks contingency cost column) |
| `currency` | EUR | EUR |

---

## Issues Found

None. Generation completed without errors or warnings.

---

## Formative Estimate Notes (Level A)

As specified in the SoW, this is a Level A (formative) estimate. The wide uncertainty
bands are appropriate:

- Phase 3 (Backend Development): best=12d, likely=18d, worst=27d — ratio 1:1.5:2.25
- Phase 4 (Mobile Development): best=15d, likely=22d, worst=33d — ratio 1:1.47:2.2

These ratios are consistent with formative-level uncertainty. The PERT formula
compresses the distribution appropriately for planning purposes.

---

*Report generated as part of Task 16 — Validation Scenario 3.*
