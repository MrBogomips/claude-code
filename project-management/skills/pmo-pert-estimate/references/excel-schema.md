# Excel Schema Reference — pmo-pert-estimate

Machine-readable reference for the Excel Generator agent. All formula templates use `{r}` for current row number.

---

## Global Conventions

| Rule | Value |
|------|-------|
| Header row | Row 1 (exception: Resources uses Row 1 for metadata, Row 2 for headers) |
| Data start row | Row 2 (exception: Resources uses Row 3) |
| TOTAL row | Last data row + 1 |
| Number format | `#,##0.00` for all numeric cells |
| Formula injection | Always as string (e.g., `f'=(E{r}+4*F{r}+G{r})/6'`), never computed values |

---

## Sheet 1: WBS

### Columns

| Col | Header | Type | Leaf Row | Rollup Row (Phase/WP) | TOTAL Row |
|-----|--------|------|----------|----------------------|-----------|
| A | ID | input | `1.1.1` | `1` or `1.1` | `"TOTAL"` |
| B | Phase | input | (empty) | Phase name (level 1 only) | (empty) |
| C | Work Package | input | (empty) | WP name (level 2 only) | (empty) |
| D | Activity | input | Activity name | (empty) | (empty) |
| E | Best Effort ({unit}) | input | numeric | `=SUM(E{first}:E{last})` | `=SUM(E{phase_rows})` |
| F | Likely Effort ({unit}) | input | numeric | `=SUM(F{first}:F{last})` | `=SUM(F{phase_rows})` |
| G | Worst Effort ({unit}) | input | numeric | `=SUM(G{first}:G{last})` | `=SUM(G{phase_rows})` |
| H | PERT Effort ({unit}) | **formula** | `=(E{r}+4*F{r}+G{r})/6` | `=(E{r}+4*F{r}+G{r})/6` | `=SUM(H{phase_rows})` |
| I | Best Duration ({unit}) | input | numeric | `=SUM(I{first}:I{last})` | `=SUM(I{phase_rows})` |
| J | Likely Duration ({unit}) | input | numeric | `=SUM(J{first}:J{last})` | `=SUM(J{phase_rows})` |
| K | Worst Duration ({unit}) | input | numeric | `=SUM(K{first}:K{last})` | `=SUM(K{phase_rows})` |
| L | PERT Duration ({unit}) | **formula** | `=(I{r}+4*J{r}+K{r})/6` | `=(I{r}+4*J{r}+K{r})/6` | `=(I{r}+4*J{r}+K{r})/6` |
| M | sigma Duration | **formula** | `=(K{r}-I{r})/6` | `=(K{r}-I{r})/6` | `=(K{r}-I{r})/6` |
| N | Resources | input | Role codes (e.g., `TL, SD`) | (empty) | (empty) |
| O | Dependencies | input | Activity IDs (e.g., `1.0.2`) | (empty) | (empty) |
| P | Risks | input | Risk refs (e.g., `R1, R2`) | (empty) | (empty) |
| Q | Notes | input | Free text | (empty) | (empty) |
| R | Billable | input | `Y` or `N` | (empty) | (empty) |
| S | Billable PERT Effort | **formula** | `=IF(R{r}="Y",H{r},0)` | `=SUM(S{first}:S{last})` | `=SUM(S{phase_rows})` |

### Row Types

| Level | ID Pattern | Filled Columns | E-G / I-K Behavior |
|-------|-----------|----------------|---------------------|
| Phase (1) | No dots: `1`, `2` | B (Phase) | `=SUM()` of children |
| Work Package (2) | One dot: `1.1`, `2.3` | C (Work Package) | `=SUM()` of leaf children |
| Activity (3) | Two dots: `1.1.1`, `2.3.4` | D (Activity) | Input values |

### SUM Range Construction

For rollup rows, `{first}` and `{last}` are the first and last child row numbers:

```python
# Phase row at row r, children from r+1 to r+n
f'=SUM(E{r+1}:E{r+n})'

# Work package row at row r, leaf children from r+1 to r+m
f'=SUM(E{r+1}:E{r+m})'

# TOTAL row: sum only phase-level rows
f'=SUM(E{phase_row_1},E{phase_row_2},...,E{phase_row_n})'
```

### Formatting

| Row Type | Font | Background | Text Color | Border |
|----------|------|------------|------------|--------|
| Phase | Bold | Primary color (`1B4FA5`) | White (`FFFFFF`) | Standard |
| Work Package | Bold | Light gray (`D9E2F3`) | Black | Standard |
| Activity (leaf) | Normal | White | Black | Standard |
| TOTAL | Bold | Dark (`1B4FA5`) | White | Double top border |
| Formula columns (H, L, M, S) | (per row type) | Pale yellow (`FFF2CC`) | (per row type) | Standard |

---

## Sheet 2: Timeline

### Columns

| Col | Header | Type | Formula Template |
|-----|--------|------|-----------------|
| A | ID | **formula** | `=WBS!A{r}` |
| B | Phase/WP/Activity | **formula** | `=WBS!B{r}&IF(WBS!C{r}<>"", " "&WBS!C{r}, "")&IF(WBS!D{r}<>"", " "&WBS!D{r}, "")` |
| C | PERT Duration | **formula** | `=WBS!L{r}` |
| D | σ | **formula** | `=WBS!M{r}` |
| E..N+ | P1, P2, P3... | fill | Gantt bar cells (colored fill, no formula) |

### Period Columns

Generated dynamically based on `config.period_type`:

| Period Type | Column Header Pattern |
|-------------|----------------------|
| `biweekly` | `P1`, `P2`, `P3`, ... |
| `weekly` | `W1`, `W2`, `W3`, ... |
| `monthly` | `M1`, `M2`, `M3`, ... |

### Critical Path Determination

1. Build dependency graph from WBS column O
2. Forward pass: ES = max(EF of predecessors), EF = ES + PERT Duration
3. Critical path = longest path (Total Float = 0)
4. No dependencies defined: infer sequential by phase, parallel within phase

### Gantt Cell Colors

| Color | Hex | Meaning |
|-------|-----|---------|
| Red | `FF0000` | Critical path activities |
| Blue | `4472C4` | Parallel activities |
| Orange | `FFA500` | Continuous/cross-cutting activities |

Include a legend row below the Gantt.

### Summary Block (Below Gantt)

| Row Label | Content |
|-----------|---------|
| Critical Path | Phase list |
| Total PERT Duration | `=SUM(C{data_range})` for critical path phases |
| CI 68% | `PERT +/- sigma_total` |
| CI 95% | `PERT +/- 2*sigma_total` |
| Indicative Start | Config start_date (if provided) |
| Indicative End | Computed from start + PERT duration |

---

## Sheet 3: Resources

### Row Layout

| Row | Content |
|-----|---------|
| 1 | Billable metadata: `Y` or `N` in each role column |
| 2 | Header row |
| 3+ | Data rows (one per phase) |
| Last+1 | TOTAL EFFORT row |
| Last+2 | TOTAL BILLABLE row |
| Last+3.. | Per-team subtotal rows |

### Columns

| Col | Header | Type | Formula Template |
|-----|--------|------|-----------------|
| A | Phase | input | Phase name |
| B | Description | input | Brief description |
| C | Team | input | Team name |
| D..{N} | {Role1}, {Role2}, ... | input | Effort per role per phase |
| {N+1} | TOTAL EFFORT | **formula** | `=SUM(D{r}:{last_role_col}{r})` |
| {N+2} | BILLABLE EFFORT | **formula** | `=SUMPRODUCT(D{r}:{last_role_col}{r},(D$1:{last_role_col}$1="Y")*1)` |

Role columns are dynamic — generated from the RBS. The number of role columns varies per project.

### Footer Formulas

| Row | Column | Formula |
|-----|--------|---------|
| TOTAL EFFORT | TOTAL EFFORT col | `=SUM({total_effort_col}{data_start}:{total_effort_col}{data_end})` |
| TOTAL BILLABLE | BILLABLE EFFORT col | `=SUM({billable_col}{data_start}:{billable_col}{data_end})` |
| Team subtotal | TOTAL EFFORT col | `=SUMPRODUCT(({team_col}{data_start}:{team_col}{data_end}="{team_name}")*({total_col}{data_start}:{total_col}{data_end}))` |

---

## Sheet 4: Risks

### Columns

| Col | Header | Type | Formula Template |
|-----|--------|------|-----------------|
| A | ID | input | `R1`, `R2`, `R3`, ... |
| B | Risk Description | input | Text |
| C | Category | input | `Technical` / `External` / `Organizational` / `PM` |
| D | Affected Phases | input | Phase ID refs |
| E | Probability (1-5) | input | Integer 1-5 |
| F | Impact (1-5) | input | Integer 1-5 |
| G | Risk Score | **formula** | `=E{r}*F{r}` |
| H | Priority | **formula** | `=IF(G{r}>=15,"CRITICAL",IF(G{r}>=10,"HIGH",IF(G{r}>=5,"MEDIUM","LOW")))` |
| I | Strategy | input | `Mitigate` / `Transfer` / `Accept` / `Avoid` |
| J | Mitigation Action | input | Text |
| K | Owner | input | Role code |
| L | Contingency ({unit}) | input | Numeric |
| M | Contingency Cost | **formula** | `=L{r}*{avg_rate}` (if avg_rate configured, else omit) |

### Footer Rows

| Row | Content | Formula |
|-----|---------|---------|
| TOTAL CONTINGENCY | Sum of contingency column | `=SUM(L{data_start}:L{data_end})` |
| MANAGEMENT RESERVE | Percentage of total PERT | `=SUM(L{data_start}:L{data_end})*{reserve_pct}` |

---

## Sheet 5: Summary

### Columns

| Col | Header | Type | Formula Template |
|-----|--------|------|-----------------|
| A | Phase | **formula** | `=WBS!B{wbs_phase_row}` |
| B | Description | input | Phase description |
| C | Best Effort | **formula** | `=WBS!E{wbs_phase_row}` |
| D | Likely Effort | **formula** | `=WBS!F{wbs_phase_row}` |
| E | Worst Effort | **formula** | `=WBS!G{wbs_phase_row}` |
| F | PERT Effort | **formula** | `=WBS!H{wbs_phase_row}` |
| G | Best Duration | **formula** | `=WBS!I{wbs_phase_row}` |
| H | Likely Duration | **formula** | `=WBS!J{wbs_phase_row}` |
| I | Worst Duration | **formula** | `=WBS!K{wbs_phase_row}` |
| J | PERT Duration | **formula** | `=WBS!L{wbs_phase_row}` |
| K | sigma Duration | **formula** | `=WBS!M{wbs_phase_row}` |

### Summary Block (Below Table)

| Row Label | Formula |
|-----------|---------|
| Total PERT Effort | `=SUM(F{data_start}:F{data_end})` |
| Total Billable Effort | `=WBS!S{wbs_total_row}` |
| Billable Ratio | `=WBS!S{wbs_total_row}/SUM(F{data_start}:F{data_end})` |
| sigma Total | `=SQRT(SUMPRODUCT(K{data_start}:K{data_end},K{data_start}:K{data_end}))` |
| CI 68% Lower | `={pert_duration_total}-{sigma_total_cell}` |
| CI 68% Upper | `={pert_duration_total}+{sigma_total_cell}` |
| CI 95% Lower | `={pert_duration_total}-2*{sigma_total_cell}` |
| CI 95% Upper | `={pert_duration_total}+2*{sigma_total_cell}` |
| Total Contingency | `=Risks!L{risks_total_row}` |
| Management Reserve | `=Risks!L{risks_reserve_row}` |
| Adjusted PERT | `={pert_effort_total}+{contingency_cell}+{reserve_cell}` |

### Effort by Team Block

Cross-references from Resources sheet per-team subtotal rows:

```
Team Core:     =Resources!{total_col}{team_core_row}
Team External: =Resources!{total_col}{team_external_row}
```

---

## Design Decisions

### No sigma for Effort

Only sigma for Duration is computed. Rationale: confidence intervals on duration are the primary scheduling concern per PMI practice. Effort uncertainty is communicated through the three-point values (O/M/P). Keeps the WBS readable.

### sigma Aggregation Independence

`sigma_total = SQRT(SUM(sigma_i^2))` assumes statistical independence (standard PERT/CLT assumption). Correlated risks are addressed by the Risk Register contingency and Management Reserve, which are additive buffers.
