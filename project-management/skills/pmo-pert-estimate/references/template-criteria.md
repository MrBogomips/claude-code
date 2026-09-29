# Template Criteria Reference — pmo-pert-estimate

This document defines the criteria for custom Excel templates. The bundled
template at `assets/pert-template.xlsx` satisfies all criteria. Users may
customize it following this guide.

---

## 1. Required Sheet Names

The workbook must contain exactly these 4 sheets. The validator accepts the
English canonical name **or** the Italian translation produced when
`config.lang = "it"`:

| Canonical (en) | Italian | Purpose |
|----------------|---------|---------|
| `WBS` | `WBS` | Work Breakdown Structure with three-point estimates |
| `Resource Plan` | `Pianificazione Risorse` | Role × week PD allocation matrix |
| `Risks` | `Rischi` | Risk register with P×I scoring and Management Reserve |
| `Summary` | `Riepilogo` | Phase rollup, effort bands, calendar duration |

**Extra sheets**: Accepted by the validator. Generated workbooks contain only
the 4 sheets above.

---

## 2. Required Columns per Sheet

The validator locates required columns by header text (partial,
case-insensitive match). The PERT formula check reads column H, so keep
PERT Effort in column H.

### WBS Sheet

| Required Column | Notes |
|----------------|-------|
| ID | Hierarchical code (1, 1.1, 1.1.1) |
| Best Effort | Numeric, leaf input or rollup formula |
| Likely Effort | Numeric, leaf input or rollup formula |
| Worst Effort | Numeric, leaf input or rollup formula |
| PERT Effort | Formula column |
| Resources | Role codes. **Order matters**: the first element is the activity's primary role and drives Resource Plan / Effort by Team rollups. |
| Billable | Y/N flag |

**Also required by the validator**: Phase, Work Package, Activity,
Best/Likely/Worst Duration, PERT Duration, σ Duration, Dependencies, Risks,
Notes, Billable PERT Effort.

### Resource Plan Sheet

| Required Column | Notes |
|----------------|-------|
| Role / Ruolo | Role display name |
| Code / Codice | Role short code |
| Type / Tipo | `billable` / `non-billable` |
| `W1`..`Wn` | One column per project week; cells hold PD numerics |
| TOTAL / TOTALE | `=SUM(...)` across the week columns |

**Numerical invariant**: Σ (all role-week cells) must equal `WBS!H{total}`
within ±1 PD (rounding tolerance).

### Risks Sheet

| Required Column | Notes |
|----------------|-------|
| ID | Risk identifier (R1, R2, ...) |
| Probability (1-5) | Numeric 1-5 |
| Impact (1-5) | Numeric 1-5 |
| Risk Score | Formula: `=E*F` |
| Strategy | Mitigate / Transfer / Accept / Avoid |
| Contingency | Numeric effort (PD) |

**Also required by the validator**: Risk Description, Category, Affected
Phases, Priority, Mitigation Action, Owner. Optional: Contingency Cost.

**Footer rows**: `TOTAL CONTINGENCY` and `MANAGEMENT RESERVE`. The MR cell
formula uses the PMI-correct base: `=(WBS!H{total}*(1+pm_pct+devops_pct)+L{contingency_total})*mr_pct`.

### Summary Sheet

| Required Column | Notes |
|----------------|-------|
| Phase | Cross-reference to WBS |
| Description | Phase description text |

The Summary is followed by a single-column key/value block listing:

- Tech PERT Effort (PD)
- PM Overhead (+pm_overhead_pct%) (PD)
- DevOps Overhead (+devops_overhead_pct%) (PD)
- Subtotal Tech + Overhead (PD)
- Contingency per-risk (PD)
- **Low Band (Fascia BASSA)** (PD)
- Management Reserve (mr_pct%) (PD)
- **Medium Band (Fascia MEDIA, recommended)** (PD)
- **High Band (Fascia ALTA)** (PD)
- Total Billable Effort (PD), Billable Ratio
- Calendar Duration (weeks) — single number
- Effort by Team (PD) — real PD totals derived from WBS primary roles
- Sensitivity Scenarios — text list (when top-level `scenarios` is provided)

---

## 3. Required Formula Patterns

| Formula Type | Regex Pattern | Example |
|-------------|---------------|---------|
| PERT | `(.+\+4\*.+\+.+)/6` | `=(E2+4*F2+G2)/6` |
| SUM rollup | `SUM\(.+:.+\)` | `=SUM(E3:E5)` |
| Sigma | `(.+-.+)/6` | `=(K2-I2)/6` |
| Risk Score | `.+\*.+` | `=E2*F2` |
| Priority IF | `IF\(.+,"CRITICAL"` | `=IF(G2>=15,"CRITICAL",...)` |
| Management Reserve | `=\(WBS!H\d+\*\(1\+.*\).+\)\*\d` | `=(WBS!H10*(1+0.1+0.05)+L7)*0.2` |

The validator checks only the WBS PERT Effort column (H): each formula
there must be `=(E{n}+4*F{n}+G{n})/6` or a `SUM(...)`. The other patterns
above, and the cross-references in Section 4, describe what the generator
writes; the validator does not check them.

---

## 4. Cross-Reference Requirements

| Source Sheet | Must Reference | Pattern |
|-------------|----------------|---------|
| Risks | WBS | At least one cell references `WBS!` (the MR formula) |
| Summary | WBS | At least one cell references `WBS!` (phase rollups) |
| Summary | Risks | Contingency per-risk cell references the Risks sheet |

---

## 5. Extra Columns and Sheets

| Element | Behavior |
|---------|----------|
| Extra columns on required sheets | Accepted by the validator (reported as warnings); not carried into generated workbooks |
| Extra sheets | Accepted by the validator; not carried into generated workbooks |
| Missing required columns | Reported as validation errors |
| Reordered columns | Supported — validator builds a column map |

---

## 6. Column Map Output

After successful validation, the validator produces:

```json
{
  "valid": true,
  "column_map": {
    "WBS":           {"ID": "A", "Phase": "B", ...},
    "Resource Plan": {"Role": "A", "Code": "B", "Type": "C", "W1": "D", ...},
    "Risks":         {"ID": "A", "Probability (1-5)": "E", ...},
    "Summary":       {"Phase": "A", "Description": "B"}
  },
  "errors": [],
  "warnings": []
}
```

---

## 7. Step-by-Step Template Customization Guide

1. **Copy the bundled template**
   ```
   cp <skill-dir>/assets/pert-template.xlsx ./my-template.xlsx
   ```
2. **Open in Excel / LibreOffice.**
3. **Verify sheet names**: `WBS`, `Resource Plan` (or `Pianificazione Risorse`), `Risks` (or `Rischi`), `Summary` (or `Riepilogo`). Do not rename to non-matching values.
4. **Add extra columns or sheets** as needed — the validator accepts them, but generated workbooks do not include them.
5. **Adjust formatting** (colors, fonts, borders) for your own copy. The generator builds each workbook from scratch and does not read the template, so template formatting does not carry into generated output.
6. **Preserve formula patterns** for PERT, σ, Risk Score, Priority IF, and Management Reserve (see Section 3).
7. **Validate**:
   ```
   cd <skill-dir>/scripts && python3 validate_template.py --template <path>/my-template.xlsx
   ```
8. **Configure in CLAUDE.md**:
   ```markdown
   | CustomTemplate | my-template.xlsx |
   ```
