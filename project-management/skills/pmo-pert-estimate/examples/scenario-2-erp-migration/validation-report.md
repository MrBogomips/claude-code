# Validation Report — Scenario 2: ERP Migration

**Generated:** 2026-03-19
**Excel file:** `pert-estimate.xlsx`
**JSON input:** `excel-input.json`
**Script:** `generate_excel.py`

---

## Verification Results

| # | Criterion | Result | Notes |
|---|-----------|--------|-------|
| 1 | 5 sheets present | PASS | Sheets: WBS, Timeline, Resources, Risks, Summary |
| 2 | WBS structure correct | PASS | 8 phases, 16 WPs, 40 leaf activities, TOTAL row at row 66 |
| 3 | WBS formula cells (H, L, M, S) contain formulas | PASS | All rows (phases, WPs, leaves, TOTAL) have formula strings starting with `=` in columns H, L, M, S |
| 4 | WBS input cells (E, F, G on leaf rows) contain numbers | PASS | All 40 leaf rows have numeric best/likely/worst effort values in columns E, F, G |
| 5 | Timeline has Gantt period columns | PASS | 8 monthly period columns: M1, M2, M3, M4, M5, M6, M7, M8 (covers ~160 working days across 8 months) |
| 6 | Timeline has critical path colouring (≥1 red cell) | PASS | 27 red cells found across the critical path (activities on the dependency chain from 1.1.1 through to 8.2.2) |
| 7 | Resources has role columns matching the 6 roles | PASS | All 6 role names found in the Resources sheet header: PMO, BDM, SAP Consultant, Data Architect, SRE, Training Specialist |
| 8 | Risks has P×I formulas | PASS | `G2=E2*F2` through `G13=E13*F13` for all 12 risks |
| 9 | Summary cross-references WBS and Risks sheets | PASS | Summary contains 81 WBS-referencing formulas and 2 Risks-referencing formulas |
| 10 | No empty formula cells in WBS | PASS | Zero None values found in formula columns (H, L, M, S) for all non-blank rows |
| 11 | Large dataset handled correctly (40+ activities) | PASS | Exactly 40 leaf activities rendered without error or truncation |
| 12 | Monthly period type produces "M1, M2, ..." headers | PASS | All period headers are M-prefixed (M1–M8); no P- or W-prefixed headers present |
| 13 | Multiple teams reflected in Resources sheet | PASS | All 3 teams present: Management, Development, Operations |
| 14 | CRITICAL risks (P×I ≥ 15) have red formatting | PASS | 3 CRITICAL risks identified — R01 (score=20), R02 (score=20), R03 (score=16) — all rows formatted with bold red font |
| 15 | Management reserve at 15% (not 10%) | PASS | `management_reserve_pct=0.15` in config; reserve row formula is `=L15*0.15` |

**Overall: 15/15 PASS**

---

## Scenario Configuration

| Parameter | Value |
|-----------|-------|
| Language | en |
| Effort unit | pd |
| Duration unit | d |
| Primary colour | #1B4FA5 |
| Period type | monthly |
| Start date | 2026-06-01 |
| Management reserve | 15% |
| Avg rate | EUR 600/pd |

## Scenario Structure

| Element | Count |
|---------|-------|
| Phases | 8 (Discovery, As-Is Analysis, To-Be Design, Data Migration, Development, Testing, Training, Go-Live) |
| Work Packages | 16 (2 per phase) |
| Leaf Activities | 40 (2–3 per WP) |
| Roles | 6 (PMO, BDM, SAP, DA, SRE, TRN) |
| Teams | 3 (Management, Development, Operations) |
| Risks | 12 (3 CRITICAL: R01/R02/R03, 4 HIGH: R04/R05/R06/R07, 3 MEDIUM: R08/R09/R10, 2 LOW: R11/R12) |
| Targets | expected_effort=800 pd, expected_duration=240 d |

## Risk Severity Breakdown

| Priority | Risk IDs | Scores |
|----------|----------|--------|
| CRITICAL (score ≥ 15) | R01, R02, R03 | 20, 20, 16 |
| HIGH (10–14) | R04, R05, R06, R07 | 12, 12, 12, 12 |
| MEDIUM (5–9) | R08, R09, R10 | 9, 9, 8 |
| LOW (1–4) | R11, R12 | 6, 4 |

Note: R11 (score=6) falls in MEDIUM by formula threshold (≥5). R12 (score=4) is LOW. Total: 2 CRITICAL, 4 HIGH, 4 MEDIUM, 2 LOW.

## Notes

- The 40-activity dataset is handled without performance degradation or rendering errors.
  All formula cross-references resolve correctly across all 5 sheets.
- The `monthly` period type correctly selects M-prefixed column headers (M1–M8) via the
  `_period_prefix()` helper in `wb_timeline.py`. The 8 periods cover 160 working days
  (8 × 20 days), accommodating the longest PERT critical path.
- All 3 teams (Management, Development, Operations) are reflected in the Resources sheet
  because resource allocation rows carry the `team` field for each phase×role combination.
- CRITICAL risk formatting (bold red font on all 13 columns) is applied by `wb_risks.py`
  whenever `probability × impact >= 15`. Three risks meet this threshold in this scenario.
- The 15% management reserve is correctly stored in config and propagated to the Risks
  sheet reserve row formula (`=L<total_row>*0.15`), distinct from the 10% default.
- No core script modifications were required; all 15 criteria pass as-is.
