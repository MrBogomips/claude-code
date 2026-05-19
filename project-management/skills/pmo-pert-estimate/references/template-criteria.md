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

**Removed (vs the legacy 5-sheet layout)**: `Timeline` (sequential Gantt — was
not actionable, see Issue #4 in the refactor changelog) and `Resources` (held
percentages presented as effort — Issue #1). Both responsibilities are now
covered by the single PD-based `Resource Plan`.

**Extra sheets**: Preserved as-is. The skill will not populate them but will
not remove them either.

---

## 2. Required Columns per Sheet

Column position is flexible. The validator searches the header row for
matching column names. Column order does not matter.

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

**Optional but expected** (created if missing): Phase, Work Package,
Activity, Best/Likely/Worst Duration, PERT Duration, σ Duration,
Dependencies, Risks, Notes, Billable PERT Effort.

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

**Optional but expected**: Risk Description, Category, Affected Phases,
Priority, Mitigation Action, Owner, Contingency Cost.

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
- Sensitivity Scenarios — text list (when `config.scenarios` is provided)

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

The validator scans formula cells and checks that structural patterns
exist in the appropriate columns. Exact formulas are not required.

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
| Extra columns on required sheets | Preserved, not populated by the skill |
| Extra sheets | Preserved, not modified |
| Missing optional columns | Created automatically by the generator |
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
   cp .claude/skills/pmo-pert-estimate/assets/pert-template.xlsx ./my-template.xlsx
   ```
2. **Open in Excel / LibreOffice.**
3. **Verify sheet names**: `WBS`, `Resource Plan` (or `Pianificazione Risorse`), `Risks` (or `Rischi`), `Summary` (or `Riepilogo`). Do not rename to non-matching values.
4. **Add extra columns or sheets** as needed — they are preserved but not populated.
5. **Adjust formatting** (colors, fonts, borders). The generator only restyles cells it writes; untouched cells keep your formatting.
6. **Preserve formula patterns** for PERT, σ, Risk Score, Priority IF, and Management Reserve (see Section 3).
7. **Validate**:
   ```
   python .claude/skills/pmo-pert-estimate/scripts/validate_template.py --template my-template.xlsx
   ```
8. **Configure in CLAUDE.md**:
   ```markdown
   | CustomTemplate | my-template.xlsx |
   ```
