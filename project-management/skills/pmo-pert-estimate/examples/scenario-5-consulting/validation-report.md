# Validation Report — Scenario 5: Consulting Engagement

**File:** `pert-estimate.xlsx`
**Generated:** 2026-03-19
**Scenario:** Management consulting / organisational transformation (non-IT)
**Key test:** Non-standard units — effort in HOURS, duration in WEEKS

---

## Validation Criteria

### Base Criteria (1–10)

| # | Criterion | Result | Notes |
|---|-----------|--------|-------|
| 1 | Excel file generated without errors | PASS | `Generated: ../examples/scenario-5-consulting/pert-estimate.xlsx` |
| 2 | Workbook contains expected sheets: WBS, Timeline, Resources, Risks, Summary | PASS | Sheets: `['WBS', 'Timeline', 'Resources', 'Risks', 'Summary']` |
| 3 | WBS has correct structure: 4 phases, 7 work packages, 17 leaf activities | PASS | Phase rows at 2, 10, 18, 25; 7 WP rows; 17 leaf rows; TOTAL at row 30 |
| 4 | PERT formulas present in WBS for effort (H), duration (L), sigma (M), billable (S) | PASS | H4=`=(E4+4*F4+G4)/6`, L4=`=(I4+4*J4+K4)/6`, M4=`=(K4-I4)/6`, S4=`=IF(R4="Y",H4,0)` |
| 5 | Risks sheet contains 5 risk rows (R1–R5) | PASS | 5 risk rows confirmed |
| 6 | Risks sheet has TOTAL and Management Reserve footer rows | PASS | Present after risk data rows |
| 7 | Resources sheet present with 3 roles (Partner, Senior Consultant, Junior Consultant) | PASS | Role columns D/E/F: `'Partner'`, `'Senior Consultant'`, `'Junior Consultant'` (row 2) |
| 8 | Summary sheet references WBS and Risks for KPIs | PASS | Cross-refs: `=WBS!B2`, `=Risks!L8`, `=WBS!S30`, etc. |
| 9 | Timeline sheet uses monthly period prefix "M" | PASS | Period columns: `M1`, `M2` (2 periods cover ~22 weeks of project) |
| 10 | No generation errors or Python exceptions | PASS | Clean stdout output; no tracebacks |

---

### Scenario-Specific Criteria (11–14) — Unit Label Verification

**These are the critical tests for this scenario.**

| # | Criterion | Expected | Actual | Result |
|---|-----------|----------|--------|--------|
| 11 | WBS col E header shows `(hours)` for Best Effort | `Best Effort (hours)` | `'Best Effort (hours)'` | PASS |
| 11 | WBS col F header shows `(hours)` for Likely Effort | `Likely Effort (hours)` | `'Likely Effort (hours)'` | PASS |
| 11 | WBS col G header shows `(hours)` for Worst Effort | `Worst Effort (hours)` | `'Worst Effort (hours)'` | PASS |
| 11 | WBS col H header shows `(hours)` for PERT Effort | `PERT Effort (hours)` | `'PERT Effort (hours)'` | PASS |
| 12 | WBS col I header shows `(weeks)` for Best Duration | `Best Duration (weeks)` | `'Best Duration (weeks)'` | PASS |
| 12 | WBS col J header shows `(weeks)` for Likely Duration | `Likely Duration (weeks)` | `'Likely Duration (weeks)'` | PASS |
| 12 | WBS col K header shows `(weeks)` for Worst Duration | `Worst Duration (weeks)` | `'Worst Duration (weeks)'` | PASS |
| 12 | WBS col L header shows `(weeks)` for PERT Duration | `PERT Duration (weeks)` | `'PERT Duration (weeks)'` | PASS |
| 13 | Risks col L header shows `Contingency (hours)` | `Contingency (hours)` | `'Contingency (hours)'` | PASS |
| 14 | Timeline period columns use `M` prefix (monthly) | `M1`, `M2`, … | `M1`, `M2` | PASS |

---

## Complete WBS Row 1 Header Dump

Exact values extracted via `openpyxl`:

```
Col A (1):  'ID'
Col B (2):  'Phase'
Col C (3):  'Work Package'
Col D (4):  'Activity'
Col E (5):  'Best Effort (hours)'       ← unit=hours confirmed
Col F (6):  'Likely Effort (hours)'     ← unit=hours confirmed
Col G (7):  'Worst Effort (hours)'      ← unit=hours confirmed
Col H (8):  'PERT Effort (hours)'       ← unit=hours confirmed
Col I (9):  'Best Duration (weeks)'     ← unit=weeks confirmed
Col J (10): 'Likely Duration (weeks)'   ← unit=weeks confirmed
Col K (11): 'Worst Duration (weeks)'    ← unit=weeks confirmed
Col L (12): 'PERT Duration (weeks)'     ← unit=weeks confirmed
Col M (13): 'σ Duration'
Col N (14): 'Resources'
Col O (15): 'Dependencies'
Col P (16): 'Risks'
Col Q (17): 'Notes'
Col R (18): 'Billable'
Col S (19): 'Billable PERT Effort'
```

---

## Complete Risks Row 1 Header Dump

```
Col A (1):  'ID'
Col B (2):  'Risk Description'
Col C (3):  'Category'
Col D (4):  'Affected Phases'
Col E (5):  'Probability (1-5)'
Col F (6):  'Impact (1-5)'
Col G (7):  'Risk Score'
Col H (8):  'Priority'
Col I (9):  'Strategy'
Col J (10): 'Mitigation Action'
Col K (11): 'Owner'
Col L (12): 'Contingency (hours)'       ← unit=hours confirmed
Col M (13): 'Contingency Cost'
```

---

## Summary

All 14 validation criteria pass.

The critical unit-label test (criteria 11 and 12) confirms that the `effort_unit` and `duration_unit` config fields flow correctly through the entire workbook:

- `effort_unit: "hours"` appears in all 4 effort columns (E, F, G, H) of WBS, and in the Risks contingency column (L).
- `duration_unit: "weeks"` appears in all 4 duration columns (I, J, K, L) of WBS.

No default fallback to `(pd)` or `(d)` occurred. The feature works correctly for non-standard, non-IT units.

**Overall status: PASS**
