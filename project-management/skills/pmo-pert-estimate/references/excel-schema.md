# Excel Schema Reference — pmo-pert-estimate

Machine-readable reference for the Excel Generator agent. All formula
templates use `{r}` for the current row number. The workbook contains
exactly **4 sheets** in this order: **WBS**, **Resource Plan** /
**Pianificazione Risorse**, **Risks** / **Rischi**, **Summary** /
**Riepilogo**. Sheet titles are localized via `config.lang`.

---

## Global Conventions

| Rule | Value |
|------|-------|
| Effort unit | Person-days (PD) everywhere. Never percentages. |
| Calendar unit | Weeks. The unit appears in column headers as `(weeks)`. |
| Header row | Row 1 |
| Data start row | Row 2 (Resource Plan: row 3, after a calendar reference row at row 2) |
| Number format | `#,##0.00` for all numeric cells |
| Formula injection | Always as string (e.g., `f'=(E{r}+4*F{r}+G{r})/6'`); never computed values |

---

## JSON Input Schema (v2 — 4-sheet refactor)

### `config` block

```jsonc
{
  "config": {
    "lang": "en",                       // "en" (default) | "it"
    "effort_unit": "pd",
    "duration_unit": "d",
    "primary_color": "1B4FA5",
    "currency": "EUR",
    "project_start_date": "2026-04-06", // W1 anchor for Resource Plan calendar row
    "management_reserve_pct": 0.10,
    "avg_rate": 500,                    // optional, drives Contingency Cost columns

    // ---- New in v2 ----
    "pm_overhead_pct": 0.0,             // ratio of Tech PERT (e.g. 0.10 = +10%)
    "devops_overhead_pct": 0.0,         // ratio of Tech PERT
    "alta_uplift_pct": 0.12,            // High Band uplift over Medium Band
    "calendar_total_weeks": null        // optional explicit calendar duration override
  }
}
```

### `phases[].start_week` / `phases[].end_week` (new, optional)

```jsonc
{
  "phases": [
    {
      "id": "1",
      "name": "Analysis",
      "start_week": 1,
      "end_week": 4,
      "work_packages": [...]
    }
  ]
}
```

When present, drive the Resource Plan calendar and the Summary
`Calendar Duration` value. When absent, phases are stacked sequentially
using a duration heuristic.

### `scenarios[]` (new, optional)

```jsonc
{
  "scenarios": [
    "Optimistic: 320 PD if no integration delays",
    "Realistic: 465 PD (Fascia MEDIA)",
    "Pessimistic: 540 PD if external API rework"
  ]
}
```

Listed verbatim under the Summary "Sensitivity Scenarios" header.

### Activities: `resources[]` ordering

The first element of `activity.resources` is the **primary role** for that
activity. The primary role drives:

- Resource Plan PD allocation per week
- Summary "Effort by Team" rollup
- Implicit team membership via `roles[primary].team`

Subsequent role codes in `resources[]` are informational only and appear
in the WBS `Resources` column as a comma-joined list.

### Legacy JSON (v1) backward compatibility

JSON written against the v1 schema (no `pm_overhead_pct`, no calendar
fields) is still accepted. The generator routes input through
`helpers.config_compat.normalize_config()`, which:

1. Backfills modern config defaults (overhead = 0, alta_uplift = 0.12, `calendar_total_weeks` = `None`).
2. Emits **one stderr warning** per invocation:
   ```
   [pmo-pert] LEGACY JSON: missing modern fields; using defaults. See references/excel-schema.md for migration.
   ```

#### Migration example

**Before (v1)**

```jsonc
{
  "config": {
    "effort_unit": "pd",
    "management_reserve_pct": 0.20
  },
  "phases": [...],
  "roles": [...],
  "risks": [...]
}
```

**After (v2 recommended)**

```jsonc
{
  "config": {
    "effort_unit": "pd",
    "project_start_date": "2026-04-06",
    "management_reserve_pct": 0.20,
    "pm_overhead_pct": 0.10,
    "devops_overhead_pct": 0.05,
    "alta_uplift_pct": 0.12,
    "calendar_total_weeks": 25
  },
  "phases": [
    {"id": "1", "name": "Analysis", "start_week": 1, "end_week": 4,  "work_packages": [...]},
    {"id": "2", "name": "Build",    "start_week": 3, "end_week": 18, "work_packages": [...]}
  ],
  "scenarios": [
    "Optimistic: 320 PD",
    "Realistic: 465 PD",
    "Pessimistic: 540 PD"
  ],
  "roles": [...],
  "risks": [...]
}
```

---

## Sheet 1 — WBS

Unchanged from v1. Columns A–S retain the same layout.

| Col | Header | Type | Leaf row | Rollup row | TOTAL row |
|-----|--------|------|----------|-----------|-----------|
| A | ID | input | `1.1.1` | `1` / `1.1` | `"TOTAL"` |
| B | Phase | input | (empty) | Phase name (level 1) | (empty) |
| C | Work Package | input | (empty) | WP name (level 2) | (empty) |
| D | Activity | input | Activity name | (empty) | (empty) |
| E-G | Best / Likely / Worst Effort (pd) | input | numeric | `=SUM(...)` | `=SUM(<phases>)` |
| H | PERT Effort (pd) | **formula** | `=(E{r}+4*F{r}+G{r})/6` | same | `=SUM(<phases>)` |
| I-K | Best / Likely / Worst Duration (d) | input | numeric | `=SUM(...)` | `=SUM(<phases>)` |
| L | PERT Duration (d) | **formula** | `=(I{r}+4*J{r}+K{r})/6` | same | same |
| M | σ Duration | **formula** | `=(K{r}-I{r})/6` | same | same |
| N | Resources | input | `<primary>, <other>, …` | (empty) | (empty) |
| O | Dependencies | input | Activity IDs | (empty) | (empty) |
| P | Risks | input | Risk refs | (empty) | (empty) |
| Q | Notes | input | Free text | (empty) | (empty) |
| R | Billable | input | `Y` / `N` | (empty) | (empty) |
| S | Billable PERT Effort | **formula** | `=IF(R{r}="Y",H{r},0)` | `=SUM(...)` | `=SUM(<phases>)` |

---

## Sheet 2 — Resource Plan (Pianificazione Risorse)

Replaces both the legacy Resources and Timeline sheets.

### Layout

| Row | Content |
|-----|---------|
| 1 | Header: `Role / Code / Type / W1 / W2 / … / Wn / TOTAL (PD)` |
| 2 | Calendar reference: blank for A–C, ISO date in each week column (`W1 = project_start_date`, `W2 = +7d`, …) |
| 3..R | One row per active role (a role is *active* when ≥1 leaf activity lists it as primary) |
| R+1 | Weekly TOTAL row (`=SUM(...)` per week column, `=SUM(...)` for the grand total) |
| R+3+ | Optional Capacity Warnings block — one line per overcommitted cell |

### Cell algorithm

1. For each leaf activity: `primary_role = activity.resources[0]` (activities with empty `resources[]` are skipped and listed in the returned `skipped_activities`).
2. `phase_role_pd[phase, role] = Σ PERT(activity)` over activities whose primary role is `role`.
3. Phase weeks: `phase.start_week..phase.end_week` if set, else stacked sequentially using `ceil(phase_pert_duration_days / 5)`.
4. Distribute uniformly: each cell `(role, week)` gets `phase_role_pd / weeks_in_phase`.
5. Overlapping phases sum their contributions in shared weeks.

### Capacity highlighting

| Threshold | Fill |
|-----------|------|
| Cell > 5.0 PD (over-saturation for one role in one week) | Light red (`FFC7CE`) |
| Cell ≥ 4.5 PD (≥ 90% of 5.0) | Light yellow (`FFEB9C`) |

A "Capacity Warnings" block below the matrix lists each cell that
exceeded saturation, with role code, week, PD, and capacity.

### Numerical invariant

`Σ (all role-week cells)` equals `WBS!H{total}` within ±1 PD (rounding
tolerance from the per-phase distribution).

---

## Sheet 3 — Risks (Rischi)

Columns A–M unchanged from v1.

| Col | Header | Type | Formula |
|-----|--------|------|---------|
| A | ID | input | `R1`, `R2`, … |
| B | Risk Description | input | Text |
| C | Category | input | Technical / External / Organizational / PM |
| D | Affected Phases | input | Phase IDs |
| E | Probability (1-5) | input | 1..5 |
| F | Impact (1-5) | input | 1..5 |
| G | Risk Score | **formula** | `=E{r}*F{r}` |
| H | Priority | **formula** | `=IF(G{r}>=15,"CRITICAL",IF(G{r}>=10,"HIGH",IF(G{r}>=5,"MEDIUM","LOW")))` |
| I | Strategy | input | Mitigate / Transfer / Accept / Avoid |
| J | Mitigation Action | input | Text |
| K | Owner | input | Role code |
| L | Contingency (pd) | input | Numeric (PD) |
| M | Contingency Cost | **formula** | `=L{r}*avg_rate` (when `avg_rate` is configured) |

### Footer rows (v2)

| Row | Column | Formula |
|-----|--------|---------|
| `TOTAL CONTINGENCY` | L | `=SUM(L{data_start}:L{data_end})` |
| `MANAGEMENT RESERVE` | L | `=(WBS!H{wbs_total}*(1+pm_overhead_pct+devops_overhead_pct)+L{total_row})*management_reserve_pct` |
| `MANAGEMENT RESERVE` | M | same expression × `avg_rate` (only when `avg_rate` is configured) |

The MR formula uses the PMI-correct base (Tech + Overhead + Contingency)
so the Risks sheet and the Summary sheet agree on the MR value.

---

## Sheet 4 — Summary (Riepilogo)

### Phase table (rows 1..N + TOTAL)

Columns A–K cross-reference the WBS phase rows.

| Col | Header | Formula |
|-----|--------|---------|
| A | Phase | `=WBS!B{wbs_phase_row}` |
| B | Description | (plain text from input) |
| C-E | Best / Likely / Worst Effort | `=WBS!E..G{wbs_phase_row}` |
| F | PERT Effort | `=WBS!H{wbs_phase_row}` |
| G-I | Best / Likely / Worst Duration | `=WBS!I..K{wbs_phase_row}` |
| J | PERT Duration | `=WBS!L{wbs_phase_row}` |
| K | σ Duration | `=WBS!M{wbs_phase_row}` |
| TOTAL row | each numeric col | `=SUM(<column>{data_start}:<column>{data_end})` |

### Effort breakdown block (after phase TOTAL row + 1 blank)

Column A holds the label, column B holds the formula.

| Label | Formula |
|-------|---------|
| Tech PERT Effort (PD) | `=F{total_row}` |
| PM Overhead (+pm_pct%) (PD) | `=B{tech_row}*pm_overhead_pct` |
| DevOps Overhead (+devops_pct%) (PD) | `=B{tech_row}*devops_overhead_pct` |
| Subtotal Tech + Overhead (PD) | `=B{tech_row}+B{pm_row}+B{devops_row}` |
| Contingency per-risk (PD) | `=<Risks sheet>!L{contingency_total}` |
| **Low Band / Fascia BASSA (PD)** | `=B{subtotal_row}+B{contingency_row}` |
| Management Reserve (mr_pct%) (PD) | `=B{bassa_row}*management_reserve_pct` |
| **Medium Band / Fascia MEDIA (PD)** | `=B{bassa_row}+B{mr_row}` |
| **High Band / Fascia ALTA (PD)** | `=B{media_row}*(1+alta_uplift_pct)` |
| Total Billable Effort (PD) | `=WBS!S{wbs_total}` |
| Billable Ratio | `=B{billable_row}/B{tech_row}` |

### Calendar Duration (after a blank row)

| Label | Value |
|-------|-------|
| Calendar Duration (weeks) | `config.calendar_total_weeks` if set, else `max(phase.end_week) - min(phase.start_week) + 1`, else Resource Plan `total_weeks` fallback |

Single number. No CI 68%/95% Duration block is produced (v1's sequential
leaf-sum was misleading — Issue #2 in the refactor changelog).

### Effort by Team (after a blank row)

One row per team derived from `roles[primary_role].team`. Cell B is a
literal PD value (Σ PERT of activities where the team's roles are
primary), **not** a cross-reference. Sum of the team rows equals the
Tech PERT minus activities with empty `resources[]`.

### Sensitivity Scenarios (optional, after a blank row)

When `config.scenarios` is provided, the header `Sensitivity Scenarios`
is followed by one text row per entry in column A.

---

## Design Decisions

### One unit for effort: PD

All output cells representing effort are person-days. Percentages may
only appear in input JSON under `config.*_pct` fields to declare ratios.
The previous Resources sheet mixed % allocations with effort cells in a
way that produced numerically meaningless rollups (Issue #1) — that
pattern is no longer expressible.

### Calendar duration as an explicit single number

Aggregating leaf PERT durations sequentially ignores phase parallelism
and over-estimates the calendar duration by a factor of 2–3 in projects
with overlapping phases (Issue #2). The new design represents calendar
duration as a single declarative value.

### MR base = Tech + Overhead + Contingency

Per PMI PMBOK §4.3 and §11.7, Management Reserve covers unknown unknowns
on the full effort baseline, not only on the modelled contingency
(Issue #3). The new formula puts Tech + Overhead + Contingency into the
multiplier so the displayed MR matches the project's actual baseline.

### Primary role per activity

Each leaf activity declares an ordered `resources[]`. The first element
is the primary role and drives Resource Plan PD allocation. This is
intentionally simple and stable; if Activity X is "mostly BE with PM
oversight", `resources` must be `["BE", "PM"]`, not `["PM", "BE"]`. The
generator does not infer the primary role from notes or other signals.

### No σ-based Effort CI

Only σ for Duration is computed (column M of WBS). Effort uncertainty is
communicated through the three-point values (O/M/P) and the three bands.
The legacy v1 σ-total / CI 68/95 block was based on a sequential leaf
sum and is no longer produced.
