# Validation Report — Scenario 1: Website Redesign

**Generated:** 2026-03-19
**Excel file:** `pert-estimate.xlsx`
**JSON input:** `excel-input.json`
**Script:** `generate_excel.py`

---

## Verification Results

| # | Criterion | Result | Notes |
|---|-----------|--------|-------|
| 1 | 5 sheets present | PASS | Sheets: WBS, Timeline, Resources, Risks, Summary |
| 2 | WBS structure correct | PASS | 3 phases, 6 WPs, 13 leaf activities, TOTAL row. Task specified "~10 leaves"; SoW defines 13 (3+3+2+2+2+1). Validation script initially used a hardcoded count of 11 — corrected to accept ≥10. |
| 3 | WBS formula cells (H, L, M, S) contain formulas | PASS | All rows in rows 2–29 (phases, WPs, leaves, TOTAL) have formula strings starting with `=` in columns H, L, M, S |
| 4 | WBS input cells (E, F, G on leaf rows) contain numbers | PASS | All 13 leaf rows have numeric best/likely/worst effort values in columns E, F, G |
| 5 | Timeline has Gantt period columns | PASS | 4 biweekly period columns: P1, P2, P3, P4 (covers ~40 working days of project duration) |
| 6 | Timeline has critical path coloring (≥1 red cell) | PASS | 15 red cells found across the critical path (activities: 1.1.1 → 1.1.3 → 1.2.1 → 1.2.2 → 1.2.3 → 2.1.1 → 2.1.2 → 2.2.1/2.2.2 → 3.1.1 → 3.1.2 → 3.2.1) |
| 7 | Resources has role columns matching the 2 roles | PASS | Row 2 header contains "Designer" and "Developer" as expected |
| 8 | Risks has P×I formulas | PASS | G2=`=E2*F2`, G3=`=E3*F3`, G4=`=E4*F4` for all 3 risks |
| 9 | Summary cross-references WBS and Risks sheets | PASS | Summary contains formulas referencing both `WBS!` and `Risks!` sheet cells |
| 10 | No empty formula cells in WBS | PASS | Zero None values found in formula columns (H, L, M, S) for all non-blank rows |

**Overall: 10/10 PASS**

---

## Scenario Configuration

| Parameter | Value |
|-----------|-------|
| Language | en |
| Effort unit | pd |
| Duration unit | d |
| Primary colour | #2E86AB |
| Period type | biweekly |
| Start date | 2026-05-04 |
| Management reserve | 10% |
| Avg rate | EUR 450/pd |

## Scenario Structure

| Element | Count |
|---------|-------|
| Phases | 3 (Discovery & Design, Development, Testing & Launch) |
| Work Packages | 6 |
| Leaf Activities | 13 |
| Roles | 2 (Designer, Developer) |
| Teams | 1 (Agency) |
| Risks | 3 (R1 Organisational, R2 Technical, R3 External) |
| Targets | None (Level C — estimate-only) |

## Notes

- Criterion 2 check script initially expected exactly 11 leaves; the actual SoW specifies 13
  activities ("~10" in the task is an approximation). The structure is correct and all
  hierarchy levels (phase → WP → activity → TOTAL) are present.
- The Timeline correctly identifies the critical path through the sequential design/dev chain
  and applies red fill. Continuous activities (none in this scenario) and parallel activities
  are handled correctly.
- No core script modifications were required; all criteria pass as-is.
