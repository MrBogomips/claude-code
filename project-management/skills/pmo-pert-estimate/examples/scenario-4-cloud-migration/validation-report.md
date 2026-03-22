# Validation Report — Scenario 4: Cloud Migration

**Scenario:** High complexity, custom template, unrealistic target
**Input:** `excel-input.json`
**Output:** `pert-estimate.xlsx`
**Generated:** 2026-03-19

---

## Summary

All 14 validation criteria pass. The scenario successfully demonstrates the tool's handling of
a large, high-risk cloud migration workbook (44 leaf activities, 15 risks, 7 phases) and correctly
surfaces the gap between the client's unrealistic target (100 pd / 40 d) and the PERT-derived
estimate (~323 pd likely effort).

---

## Criteria Checklist

### Base Criteria (10)

| # | Criterion | Expected | Actual | Status |
|---|-----------|----------|--------|--------|
| 1 | Excel file generated without errors | Exit code 0, `.xlsx` created | `Generated: ../examples/scenario-4-cloud-migration/pert-estimate.xlsx` — file exists | PASS |
| 2 | All 5 required sheets present | WBS, Timeline, Resources, Risks, Summary | Sheets: WBS, Timeline, Resources, Risks, Summary | PASS |
| 3 | WBS sheet contains all phases and activities | 7 phases, 44 leaf activities | 67 rows in WBS sheet; leaf activity IDs with `x.y.z` pattern count = 44 | PASS |
| 4 | PERT formula applied correctly | E = (O + 4M + P) / 6 | WBS column H contains formula `=(E+4*F+G)/6` pattern for each activity row | PASS |
| 5 | Timeline sheet populated with period columns | biweekly periods from 2026-09-01 | Timeline sheet has 78 rows; period headers generated from start date | PASS |
| 6 | Resources sheet populated with all roles | 5 roles (CA, DE, SE, DEV, PM) | Resources sheet reflects all 5 roles and 7-phase resource allocation | PASS |
| 7 | Risks sheet populated with all risk records | 15 risks (R01–R15) | 15 risk data rows present; R01 through R15 all listed | PASS |
| 8 | Summary sheet aggregates PERT effort per phase | 7 phase rows + TOTAL | Summary has 7 phase rows with `=WBS!Hx` references, TOTAL row with `=SUM(...)` | PASS |
| 9 | Primary color applied | `457B9D` | Headers and styled cells use the configured primary color | PASS |
| 10 | Target reconciliation visible | expected_effort=100, expected_duration=40 | Summary shows Total PERT Effort vs targets; gap is quantifiable from the sheet | PASS |

### Extended Criteria (4)

| # | Criterion | Expected | Actual | Status |
|---|-----------|----------|--------|--------|
| 11 | Large dataset (35+ activities) handled correctly | ≥ 35 leaf activities, no truncation or error | 44 leaf activities rendered across all 7 phases; no overflow or row collision observed | PASS |
| 12 | All 15 risks present in Risks sheet | 15 rows with IDs R01–R15 | Confirmed: 15 risk data rows, IDs R01–R15, all descriptions, categories and fields present | PASS |
| 13 | Management reserve calculated at 20% | `management_reserve_pct = 0.20`; formula `=TOTAL*0.20` | Risks sheet row 19: `=L18*0.2` (contingency pd) and `=M18*0.2` (contingency cost EUR) | PASS |
| 14 | Contingency cost formulas use avg_rate = 650 EUR/pd | `=contingency_effort * 650` for each risk | All 15 risk rows in column M contain `=Lx*650`; confirmed in rows 2–16 and total row | PASS |

---

## Key Observations

### Unrealistic Target Gap
- **PERT likely effort (leaf activities):** ~323 pd
- **Client target effort:** 100 pd
- **Gap:** +223 pd (+223% over target)
- **Client target duration:** 40 d
- **Summed likely phase durations:** 180+ d (sequential)
- **Conclusion:** The target is approximately 3.2× below the PERT estimate. This scenario validates
  that the tool correctly computes realistic estimates regardless of target inputs, enabling PMs to
  present a data-driven re-scoping case.

### High-Risk Project Indicators
- 15 risks registered, including 2 at probability × impact ≥ 16 (R02: 20, R03: 20, R04: 16)
- Total contingency effort across all risks: 213 pd
- Management reserve (20%): ~42 pd on top of contingency
- Adjusted PERT effort (PERT + contingency + management reserve): materially higher than 100 pd

### Configuration Validation
- `lang=en` — all labels in English
- `effort_unit=pd`, `duration_unit=d` — correct unit labels in column headers
- `primary_color=457B9D` — header cells styled with steel-blue theme
- `period_type=biweekly` — Timeline sheet uses 2-week period columns
- `start_date=2026-09-01` — first period column starts at 2026-09-01
- `avg_rate=650 EUR/pd` — used consistently in Risks sheet column M formulas
- `management_reserve_pct=0.20` — correctly reflected as `*0.2` in Risks sheet totals row

---

## File Sizes and Artefacts

| File | Description |
|------|-------------|
| `input-sow.md` | Statement of Work narrative with 7 phases, 35+ activities, 15 risks, unrealistic target rationale |
| `excel-input.json` | Structured JSON input — 44 activities, 15 risks, 5 roles, 2 teams, targets: 100 pd / 40 d |
| `pert-estimate.xlsx` | Generated workbook — 5 sheets, 67 WBS rows, 19 Risks rows, full Summary and Timeline |
| `validation-report.md` | This file |
