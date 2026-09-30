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
| Formula injection | Always as string (e.g., `f'=(E{r}+4*F{r}+G{r})/6'`); never computed values. The figures come from `scripts/summarize.py`, which computes them from the JSON input |

---

## JSON Input Schema

`examples/sample-input.json` is a complete, valid input: copy its shape. The generator reads
only the keys below and ignores any other key. `scripts/summarize.py --input <json>` checks an
input before generation: it exits with code 1 and lists the errors (missing or mistyped keys,
inverted three-point values, a percentage written as 10 instead of 0.10) and reports as
warnings the keys the generator does not read.

### Top level

| Key | Required | Type | Meaning |
|-----|----------|------|---------|
| `config` | yes | object | Units, colors, ratios, calendar (below) |
| `roles` | yes | array | One entry per role |
| `phases` | yes | non-empty array | WBS level 1, holding work packages and activities |
| `risks` | yes | array (may be empty) | Risk register |
| `scenarios` | no | array of strings | Listed verbatim under the Summary "Sensitivity Scenarios" header |

Targets, reconciliation notes and resource allocations are not part of the input: they stay in
the markdown drafts.

### `config`

| Key | Required | Default | Meaning |
|-----|----------|---------|---------|
| `lang` | no | `"en"` | `"en"` or `"it"`: sheet names and labels |
| `effort_unit` | no | `"pd"` | Unit label of the effort columns; bands and capacity checks assume person-days |
| `duration_unit` | no | `"d"` | Unit label of the duration columns (working days) |
| `primary_color` | no | `"1B4FA5"` | Hex fill of the phase rows |
| `currency` | no | — | Not written to the workbook; used when presenting cost figures |
| `project_start_date` | no | — | ISO date of W1 in the Resource Plan calendar row. The legacy alias `start_date` is read only when this key is missing |
| `management_reserve_pct` | yes | — | Ratio (`0.10` = 10%). Without it the Risks sheet falls back to 0.10 and the Summary to 0, so the two would disagree |
| `avg_rate` | no | `null` | Daily rate; when set, the Risks sheet adds Contingency Cost formulas |
| `pm_overhead_pct` | no | `0.0` | Ratio of Tech PERT (`0.10` = +10%) |
| `devops_overhead_pct` | no | `0.0` | Ratio of Tech PERT |
| `alta_uplift_pct` | no | `0.12` | High Band uplift over the Medium Band |
| `calendar_total_weeks` | no | `null` | Explicit calendar duration in weeks; overrides the phase weeks |

### `roles[]`

| Key | Required | Meaning |
|-----|----------|---------|
| `code` | yes | Unique short code, used in `activities[].resources` and `risks[].owner` |
| `name` | no | Resource Plan label (default: the code) |
| `team` | no | Group for the Summary "Effort by Team" (default `Unassigned`) |
| `billable` | no | Resource Plan Type column, `true` by default |

### `phases[]`

| Key | Required | Meaning |
|-----|----------|---------|
| `id` | yes | WBS ID, e.g. `"1"` |
| `name` | yes | Phase name (WBS column B) |
| `description` | no | Summary phase table, column B |
| `start_week`, `end_week` | no | Both or neither. Calendar weeks of the phase: drive the Resource Plan and the Summary Calendar Duration. When absent, phases are stacked sequentially at `ceil(Σ leaf PERT duration / 5)` weeks each |
| `work_packages` | yes | Non-empty array |

Phase rows are computed from their activities; phase-level duration fields are not read.

### `phases[].work_packages[]`

| Key | Required | Meaning |
|-----|----------|---------|
| `id` | yes | WBS ID with exactly one dot, e.g. `"1.1"` (the WBS styles such rows as work packages) |
| `name` | yes | Work package name (WBS column C) |
| `activities` | yes | Non-empty array of leaf activities |

### `phases[].work_packages[].activities[]`

| Key | Required | Meaning |
|-----|----------|---------|
| `id` | yes | Leaf WBS ID, e.g. `"1.1.1"` |
| `name` | yes | Activity name (WBS column D) |
| `best_effort`, `likely_effort`, `worst_effort` | yes | Numbers ≥ 0 with O ≤ M ≤ P, in `effort_unit` (PD) |
| `best_duration`, `likely_duration`, `worst_duration` | yes | Numbers ≥ 0 with O ≤ M ≤ P, in working days |
| `resources` | no | Role codes, **primary role first** (see below) |
| `dependencies` | no | Activity IDs (WBS column O) |
| `risks` | no | Risk IDs (WBS column P) |
| `notes` | no | Free text (WBS column Q) |
| `billable` | no | `true` by default; `false` writes `N` in column R and excludes the activity from Billable PERT Effort |

**8/80 rule.** Each leaf activity's most-likely effort should be between 1 and 10 PD (8 to 80
hours at 8 h per PD). `summarize.py` warns about activities outside it (8–80 when
`effort_unit` is hours).

**Primary role.** The first element of `resources` is the primary role. It drives the Resource
Plan PD allocation per week, the Summary "Effort by Team" rollup and the implicit team
membership through `roles[primary].team`. The other codes are informational and appear
comma-joined in the WBS `Resources` column. An activity with empty `resources` is left out of
the Resource Plan and of Effort by Team.

### `risks[]`

| Key | Required | Meaning |
|-----|----------|---------|
| `id` | yes | `R1`, `R2`, … |
| `description` | yes | Risk text |
| `category` | yes | Technical / External / Organizational / PM |
| `affected_phases` | no | Phase IDs |
| `probability` | yes | Integer 1–5 |
| `impact` | yes | Integer 1–5 |
| `strategy` | no | Mitigate / Transfer / Accept / Avoid |
| `mitigation` | no | Mitigation action |
| `owner` | no | Role code |
| `contingency_effort` | no | PD ≥ 0, or `null` (counted as 0) |

A risk is **high** when P×I ≥ 10: Priority HIGH (10–14) or CRITICAL (≥ 15), shown in red on the
Risks sheet. The same threshold applies in the SOW skills.

### Legacy JSON backward compatibility

JSON written for earlier versions (no `pm_overhead_pct`, no calendar fields) is still accepted.
The generator routes input through `helpers.config_compat.normalize_config()`, which:

1. Backfills the defaults in the `config` table (overhead = 0, `alta_uplift_pct` = 0.12, `calendar_total_weeks` = `null`).
2. Emits **one stderr warning** per invocation:
   ```
   [pmo-pert] LEGACY JSON: missing modern fields; using defaults. See references/excel-schema.md for migration.
   ```

To migrate, add `project_start_date`, the overhead ratios, `alta_uplift_pct`, and either
`calendar_total_weeks` or `start_week`/`end_week` on each phase, as in `examples/sample-input.json`.

---

## Sheet 1 — WBS

Columns A–S.

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

**Rollup rows.** Work-package and phase rows sum the leaf three-point values (E–G, I–K) and
apply the same PERT and σ formulas to the sums. PERT effort therefore equals the sum of the
leaf PERT values. σ on a rollup row, `(ΣP − ΣO)/6`, is the **linear sum** of the leaf σ values:
it assumes the activities are fully correlated, so it is an upper bound, and it sums durations
as if every activity ran in sequence. The root-sum-square of independent activities is smaller;
the workbook does not compute it (see `pmi-methodology.md` §3).

---

## Sheet 2 — Resource Plan (Pianificazione Risorse)

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

Columns A–M.

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

### Footer rows

A blank row follows the last risk, then two footer rows (label in column A):

| Row label | Column | Formula |
|-----------|--------|---------|
| `TOTAL` | L | `=SUM(L{data_start}:L{data_end})` (total contingency) |
| `TOTAL` | M | `=SUM(M{data_start}:M{data_end})` (only when `avg_rate` is configured) |
| `Management Reserve` | L | `=(WBS!H{wbs_total}*(1+pm_overhead_pct+devops_overhead_pct)+L{total_row})*management_reserve_pct` |
| `Management Reserve` | M | same expression × `avg_rate` (only when `avg_rate` is configured) |

Rows with P×I ≥ 10 (HIGH or CRITICAL) are written in bold red.

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

Single number. No CI 68%/95% Duration block is produced: a sequential
sum of leaf durations ignores phase parallelism.

### Effort by Team (after a blank row)

One row per team derived from `roles[primary_role].team`. Cell B is a
literal PD value (Σ PERT of activities where the team's roles are
primary), **not** a cross-reference. Sum of the team rows equals the
Tech PERT minus activities with empty `resources[]`.

### Sensitivity Scenarios (optional, after a blank row)

When top-level `scenarios` is provided, the header `Sensitivity Scenarios`
is followed by one text row per entry in column A.

---

## Design Decisions

### One unit for effort: PD

All output cells representing effort are person-days. Percentages may
only appear in input JSON under `config.*_pct` fields to declare ratios.
Mixing % allocations with effort cells produces numerically
meaningless rollups.

### Calendar duration as an explicit single number

Aggregating leaf PERT durations sequentially ignores phase parallelism
and over-estimates the calendar duration by a factor of 2–3 in projects
with overlapping phases. Calendar duration is therefore a single
declarative value.

### MR base = Tech + Overhead + Contingency

Management Reserve covers unknown unknowns on the full effort
baseline, not only on the modelled contingency. The formula puts
Tech + Overhead + Contingency into the multiplier so the displayed MR
matches the project's actual baseline.

### Primary role per activity

Each leaf activity declares an ordered `resources[]`. The first element
is the primary role and drives Resource Plan PD allocation. This is
intentionally simple and stable; if Activity X is "mostly BE with PM
oversight", `resources` must be `["BE", "PM"]`, not `["PM", "BE"]`. The
generator does not infer the primary role from notes or other signals.

### No σ-based Effort CI

Only σ for Duration is computed (column M of WBS). Effort uncertainty is
communicated through the three-point values (O/M/P) and the three bands.
No σ-total / CI 68/95 block is produced, because it would rest on a
sequential leaf sum.

---

## Figures and checks — `scripts/summarize.py`

The workbook stores formulas without computed values, so figures are never read back from
it. `summarize.py` computes them from the same JSON with the generator's helpers and formulas:

```bash
python3 summarize.py --input excel-input.json [--workbook estimate.xlsx [--recalc]] \
                     [--output summary.json] [--format json|markdown]
```

Exit codes: `0` ok, `1` input missing or invalid (errors on stderr), `2` workbook checks failed.

| Key in `summary.json` | Content |
|-----------------------|---------|
| `counts` | phases, work_packages, activities, roles, risks |
| `phases[]` | per phase (and its `work_packages[]`): the three-point sums, `pert_effort`, `pert_duration`, `sigma_duration` (linear, as in the WBS), `billable_pert_effort` |
| `totals` | the same figures for the WBS TOTAL row |
| `effort` | `tech_pert`, `pm_overhead`, `devops_overhead`, `subtotal`, `contingency`, `low_band`, `management_reserve`, `medium_band`, `high_band`, `total_billable`, `billable_ratio`, and `management_reserve_risks_sheet` (equal to `management_reserve`) |
| `calendar_weeks` | the Summary Calendar Duration value |
| `effort_by_team` | PD per team (primary role of each activity) |
| `resource_plan` | `total_weeks`, `role_codes`, `role_total_pd`, `grand_total_pd`, `skipped_activities`, `skipped_pd`, `overcommits` |
| `risks[]`, `high_risk_ids` | score, priority and `high` flag (P×I ≥ 10) per risk |
| `warnings` | 8/80 exceptions, activities without a primary role, keys the generator does not read |
| `checks` | with `--workbook`: `passed`, `errors` (`Sheet!Cell: expected …, found …`), and `recalc` with `--recalc` |

Values are rounded to 2 decimals, the precision of the workbook's `#,##0.00` format.

With `--workbook`, the static checks compare every formula cell with the patterns in this
document at the rows the JSON layout implies, and flag error tokens such as `#REF!`, empty
input cells, a wrong sheet order, and ratios or calendar values that no longer match the
JSON (a stale workbook). With `--recalc`, when LibreOffice (`soffice`) is on PATH, a copy is
recalculated headless and the WBS total, the Risks Management Reserve and the Summary bands
are compared with the computed figures; without LibreOffice the result is `skipped`.
