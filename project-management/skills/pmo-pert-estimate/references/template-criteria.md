# Template Criteria Reference — pmo-pert-estimate

This document defines the criteria for custom Excel templates. The bundled template at `assets/pert-template.xlsx` satisfies all criteria. Users may customize it following this guide.

---

## 1. Required Sheet Names

The workbook must contain exactly these 5 sheets (names are case-sensitive):

| Sheet | Purpose |
|-------|---------|
| `WBS` | Work Breakdown Structure with three-point estimates |
| `Timeline` | Gantt chart and critical path visualization |
| `Resources` | Resource allocation matrix with billable tracking |
| `Risks` | Risk register with P x I scoring |
| `Summary` | Executive summary with cross-references to all sheets |

**Extra sheets**: Preserved as-is. The skill will not populate them but will not remove them either.

---

## 2. Required Columns per Sheet

Column position is flexible. The validator searches the header row for matching column names. Column order does not matter.

### WBS Sheet

| Required Column | Notes |
|----------------|-------|
| ID | Hierarchical code (1, 1.1, 1.1.1) |
| Best Effort | Numeric, leaf input or rollup formula |
| Likely Effort | Numeric, leaf input or rollup formula |
| Worst Effort | Numeric, leaf input or rollup formula |
| PERT Effort | Formula column |
| Resources | Role codes |
| Billable | Y/N flag |

**Optional but expected** (created if missing):

| Column | Notes |
|--------|-------|
| Phase | Phase name |
| Work Package | Work package name |
| Activity | Leaf activity description |
| Best Duration | Duration optimistic |
| Likely Duration | Duration most likely |
| Worst Duration | Duration pessimistic |
| PERT Duration | Formula column |
| sigma Duration | Formula column |
| Dependencies | Prerequisite IDs |
| Risks | Risk register references |
| Notes | Free text |
| Billable PERT Effort | Formula column |

### Timeline Sheet

| Required Column | Notes |
|----------------|-------|
| ID | Cross-reference to WBS |
| Phase/WP/Activity | Activity name (cross-ref or text) |
| PERT Duration | Duration cross-reference |

Period columns (P1, P2, ...) are generated dynamically.

### Resources Sheet

| Required Column | Notes |
|----------------|-------|
| Phase | Phase name |
| TOTAL EFFORT | Formula: sum of role columns |
| BILLABLE EFFORT | Formula: SUMPRODUCT with billable flags |

Role columns between Phase and TOTAL EFFORT are dynamic.

**Special**: Row 1 must be the billable metadata row (Y/N per role column). Row 2 is the header row.

### Risks Sheet

| Required Column | Notes |
|----------------|-------|
| ID | Risk identifier (R1, R2, ...) |
| Probability (1-5) | Numeric 1-5 |
| Impact (1-5) | Numeric 1-5 |
| Risk Score | Formula: P x I |
| Strategy | Mitigate / Transfer / Accept / Avoid |
| Contingency | Numeric effort |

**Optional but expected**: Risk Description, Category, Affected Phases, Priority, Mitigation Action, Owner, Contingency Cost.

### Summary Sheet

| Required Column | Notes |
|----------------|-------|
| Phase | Cross-reference to WBS |
| PERT Effort | Cross-reference to WBS |
| PERT Duration | Cross-reference to WBS |

**Optional but expected**: Best/Likely/Worst Effort, Best/Likely/Worst Duration, sigma Duration, Description.

---

## 3. Required Formula Patterns

The validator checks that formula cells match these regex patterns:

| Formula Type | Regex Pattern | Example |
|-------------|---------------|---------|
| PERT | `(.+\+4\*.+\+.+)/6` | `=(E2+4*F2+G2)/6` |
| SUM rollup | `SUM\(.+:.+\)` | `=SUM(E3:E5)` |
| Sigma | `(.+-.+)/6` | `=(K2-I2)/6` |
| Risk Score | `.+\*.+` | `=E2*F2` |
| Priority IF | `IF\(.+,"CRITICAL"` | `=IF(G2>=15,"CRITICAL",...)` |
| SUMPRODUCT (billable) | `SUMPRODUCT` | `=SUMPRODUCT(D3:J3,(D$1:J$1="Y")*1)` |

**Validation behavior**: The validator scans formula cells and checks that expected patterns exist in the appropriate columns. It does not require exact formulas — only that the structural pattern is present.

---

## 4. Cross-Reference Requirements

| Source Sheet | Must Reference | Pattern |
|-------------|---------------|---------|
| Timeline | WBS | At least one cell references `WBS!` |
| Summary | WBS | At least one cell references `WBS!` |

**Validation**: The validator searches all formula cells for inter-sheet references matching these patterns.

---

## 5. Extra Columns and Sheets

| Element | Behavior |
|---------|----------|
| Extra columns on required sheets | Preserved, not populated by the skill |
| Extra sheets | Preserved, not modified |
| Missing optional columns | Created automatically by the generator |
| Reordered columns | Supported — validator builds a column map |

The validation output includes a `column_map` that maps logical column names to physical column letters, enabling the generator to work with any column order.

---

## 6. Column Map Output

After successful validation, the validator produces:

```json
{
  "valid": true,
  "column_map": {
    "WBS": {"id": "A", "best_effort": "E", "likely_effort": "F", ...},
    "Resources": {"phase": "A", "first_role_col": "D", "last_role_col": "J", ...},
    "Risks": {"id": "A", "probability": "E", "impact": "F", "risk_score": "G", ...},
    "Timeline": {"id": "A", "activity": "B", "pert_duration": "C", ...},
    "Summary": {"phase": "A", "pert_effort": "F", "pert_duration": "J", ...}
  },
  "warnings": [
    "Sheet 'Resources' has extra column 'Rate/Day' -- preserved but not populated"
  ]
}
```

---

## 7. Step-by-Step Template Customization Guide

Follow these 10 steps to customize the bundled template:

### Step 1: Copy the bundled template

```
cp .claude/skills/pmo-pert-estimate/assets/pert-template.xlsx ./my-template.xlsx
```

### Step 2: Open in Excel / LibreOffice

Open `my-template.xlsx` in your preferred spreadsheet editor.

### Step 3: Verify sheet names

Ensure all 5 required sheets exist: WBS, Timeline, Resources, Risks, Summary. Do NOT rename them.

### Step 4: Add extra columns (if needed)

You may add columns anywhere on any sheet. Place them after the required columns for clarity. The skill will preserve but not populate them.

### Step 5: Adjust formatting

Customize colors, fonts, borders, and number formats as desired. The skill will apply its own formatting to populated cells but will not override cells it does not touch.

### Step 6: Add extra sheets (if needed)

You may add sheets for custom analysis (e.g., "Cost Analysis", "Assumptions"). These will be preserved.

### Step 7: Preserve formula patterns

If you modify formula cells, ensure they still match the required regex patterns from Section 3. For example, PERT must still follow the `(O+4M+P)/6` structure.

### Step 8: Preserve the Resources metadata row

Row 1 of the Resources sheet must remain the billable metadata row (Y/N flags). Row 2 must be the header row. Do not merge these or add rows above them.

### Step 9: Validate the template

```
python .claude/skills/pmo-pert-estimate/scripts/validate_template.py my-template.xlsx
```

### Step 10: Configure in CLAUDE.md

If validation passes, update CLAUDE.md:

```markdown
| CustomTemplate | my-template.xlsx |
```

The skill will use your custom template as the base for Excel generation, mapping its columns via the column map.
