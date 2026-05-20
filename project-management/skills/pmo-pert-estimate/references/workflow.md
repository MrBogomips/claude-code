# Workflow Reference — pmo-pert-estimate

## Pipeline Overview

```
Phase 0        Phase 1        Phase 2          Phase 3            Phase 4              Phase 5         Phase 6
First Run  --> Interactive --> Context     --> WBS + RBS      --> Risks + Estimates --> Excel      --> Validation
Setup          Setup          Analysis         (parallel)         (sequential)         Generation
[in-skill]     [in-skill]     [Opus]           [Opus + Sonnet]    [Sonnet -> Opus]     [Sonnet]        [Sonnet]
                                  |                |                    |
                                  v                v                    v
                              project-context  wbs-draft.md        risk-register.md
                              .md              rbs-draft.md        estimates-draft.md
                                                                                        |
                                                                                        v
                                                                                   pert-estimate.xlsx

Backtrack arrows:
  Phase 3 --backtrack--> Phase 2   (context incomplete)
  Phase 4 --backtrack--> Phase 3   (WBS needs restructuring after estimation)
  Phase 6 --backtrack--> Phase 5   (validation failures, max 3 iterations)
```

---

## Phase 0 — First Run Setup

| Attribute | Value |
|-----------|-------|
| **Trigger** | No `pmo-pert-estimate Configuration` section in CLAUDE.md |
| **Model** | In-skill (no agent) |
| **Inputs** | None |
| **Outputs** | Configuration block appended to CLAUDE.md |
| **User interaction** | Full — user answers all configuration questions |
| **Backtrack** | N/A |

### Steps

1. Ask output language (default: `en`)
2. Ask effort unit (`pd` / `hours` / `story_points`)
3. Ask duration unit (`days` / `weeks` / `sprints`)
4. Ask output directory (default: `docs/outbox/`)
5. Ask about custom Excel template:
   - **No** — inform about bundled template location and criteria doc
   - **Yes** — run `scripts/validate_template.py`; valid = copy to `assets/`; invalid = show errors
   - **Customize now** — copy bundled to project dir, user modifies, then validate
   - **Generate empty only** — produce base template and stop (inspection mode)
6. Save configuration to CLAUDE.md

### Error Recovery

- If template validation fails: show specific errors, offer to fall back to bundled template
- If CLAUDE.md is read-only: report error, ask user to fix permissions

---

## Phase 1 — Interactive Setup

| Attribute | Value |
|-----------|-------|
| **Trigger** | User invokes the skill |
| **Model** | In-skill (no agent) |
| **Inputs** | User responses |
| **Outputs** | Working directory `docs/pert-workspace/` created; input document path recorded |
| **User interaction** | Full — user provides all inputs |
| **Backtrack** | N/A |

### Steps

1. Ask for input document (path or pasted text)
2. Ask if a reference folder exists (SoW, contracts, previous estimates, org charts)
3. Ask interaction level: **(A)** Formative, **(B)** Collaborative, **(C)** Autonomous
4. Ask if there are expected target values for total effort and/or duration
   - If yes: record targets for reconciliation in Phase 4
5. Create working directory: `docs/pert-workspace/`

### Error Recovery

- If input document path is invalid: ask user to correct
- If workspace directory already exists: ask whether to reuse or create fresh

---

## Phase 2 — Context Analysis

| Attribute | Value |
|-----------|-------|
| **Model** | **Opus** |
| **Inputs** | Input document + reference folder contents |
| **Outputs** | `docs/pert-workspace/project-context.md` |
| **User interaction** | Validation required — user may request additions |
| **Backtrack from** | Phase 3 (if context is incomplete) |
| **Backtrack to** | N/A |

### Extraction Targets

- Scope and boundaries
- Constraints (time, budget, regulatory)
- Assumptions
- Stakeholders
- Deliverables
- Role references found in input
- Phases and milestones mentioned
- Risks already identified in input

### Error Recovery

- If input document is ambiguous: ask clarifying questions
- If reference folder files are unreadable: skip with warning, proceed with available data

---

## Phase 3 — WBS + RBS (Parallel)

| Attribute | Value |
|-----------|-------|
| **Model** | **Opus** (WBS Builder) + **Sonnet** (RBS Builder) in parallel |
| **Inputs** | `project-context.md` + interaction level |
| **Outputs** | `docs/pert-workspace/wbs-draft.md` + `docs/pert-workspace/rbs-draft.md` |
| **User interaction** | Validation of both artifacts |
| **Backtrack to** | Phase 2 (if context incomplete) |

### WBS Builder (Opus)

- Proposes hierarchical decomposition: Phase > Work Package > Activity
- Applies 8/80 rule (no package < 8h or > 80h)
- In formative mode (Level A): explains each decomposition decision
- Identifies dependencies between activities

### RBS Builder (Sonnet)

- Extracts roles from context (or asks if not found)
- Assigns roles to teams
- Defines competencies and responsibilities
- Proposes resource allocation per work package
- Marks each role as billable or non-billable

### Error Recovery

- If WBS violates 8/80 rule: flag violations, propose splits/merges
- If no roles found in context: ask user to provide role list
- If parallel agents produce inconsistent results (e.g., RBS references phases not in WBS): reconcile before presenting to user

---

## Phase 4 — Risks + Estimates (Sequential)

| Attribute | Value |
|-----------|-------|
| **Model** | **Sonnet** (Risk Analyst) then **Opus** (Estimator) |
| **Inputs** | All previous `.md` artifacts + target values (if any) |
| **Outputs** | `docs/pert-workspace/risk-register.md` + `docs/pert-workspace/estimates-draft.md` |
| **User interaction** | Validation of risk register, then validation of estimates |
| **Backtrack to** | Phase 3 (if WBS needs restructuring after estimation) |

### Risk Analyst (Sonnet) — runs first

- Identifies risks per phase/activity
- Evaluates Probability (1-5) x Impact (1-5)
- Proposes strategy (Mitigate / Transfer / Accept / Avoid)
- Calculates contingency per risk
- Proposes management reserve (% of total PERT)
- User validates before proceeding to Estimator

### Estimator (Opus) — runs after risk validation

- For each leaf activity: proposes Best / Likely / Worst
- Calculates PERT and sigma per activity
- Rollup per phase and project total
- If targets provided and deviation > 20%: initiates guided reconciliation
  - Analyzes causes (scope, estimates, resources)
  - Proposes adjustments
  - Iterates until convergence or explicit acceptance
- User validates

### Error Recovery

- If estimates are wildly inconsistent: flag outliers, propose recalibration
- If reconciliation fails to converge after 3 iterations: present delta to user, ask for explicit scope/target adjustment

---

## Phase 5 — Excel Generation

| Attribute | Value |
|-----------|-------|
| **Model** | **Sonnet** |
| **Inputs** | All 5 validated `.md` artifacts |
| **Outputs** | `{OutputDir}/pert-estimate.xlsx` (4 sheets: WBS, Resource Plan, Risks, Summary) |
| **User interaction** | None (automated) |
| **Backtrack from** | Phase 6 (if validation fails) |

### Steps

1. Read all validated `.md` artifacts
2. Construct structured JSON (`excel-input.json`) honouring the modern schema:
   - `config.pm_overhead_pct`, `config.devops_overhead_pct`, `config.alta_uplift_pct`, `config.calendar_total_weeks`, `config.project_start_date`
   - Optional `phase.start_week` / `phase.end_week` per phase
   - Optional top-level `scenarios: [...]` for the Summary sensitivity block
   - Each activity's `resources` array must list the **primary role first** — that role drives the Resource Plan PD allocation and the Summary "Effort by Team" rollup
3. Invoke `python generate_excel.py --input excel-input.json --output <path>`
4. The script auto-promotes legacy JSON via `helpers.config_compat.normalize_config()` (one stderr warning per run if modern fields are missing) and generates the 4 sheets: **WBS**, **Resource Plan** (role × week PD), **Risks**, **Summary**.

### Error Recovery

1. Capture error traceback
2. If JSON malformed: re-generate JSON from artifacts, retry (max 2 attempts)
3. If openpyxl error: report specific cell/sheet causing the issue
4. If unrecoverable: present error + last valid artifacts for manual intervention

---

## Phase 6 — Validation

| Attribute | Value |
|-----------|-------|
| **Model** | **Sonnet** |
| **Inputs** | Generated `pert-estimate.xlsx` |
| **Outputs** | Validation report; corrected Excel if needed |
| **User interaction** | Final presentation of result |
| **Backtrack to** | Phase 5 (max 3 iterations) |

### Verification Checklist

- Exactly 4 sheets in order: WBS, Resource Plan (Pianificazione Risorse), Risks (Rischi), Summary (Riepilogo)
- All formula cells contain formulas (not hardcoded values)
- Cross-reference inter-sheet links resolve correctly
- Consistent formatting (font, colors, borders, number format)
- SUM rollups match actual child ranges
- PERT = `(O+4M+P)/6` present on every appropriate WBS row
- sigma = `(P-O)/6` present in the WBS σ Duration column
- No empty input cells
- Billable flags and BILLABLE EFFORT formulas correct on WBS
- Resource Plan: grand TOTAL (PD) matches `WBS!H{total}` within ±1 PD; no role-week cell holds a percentage
- Risks: MR formula uses Tech+Overhead+Contingency base (cross-refs `WBS!H{total}`), not just contingency
- Summary: Fascia BASSA / MEDIA / ALTA rows present and consistent (BASSA = Subtotal + Contingency; MEDIA = BASSA + MR; ALTA = MEDIA × (1 + alta_uplift_pct)); Calendar Duration is a single weekly number

### Error Recovery

- If errors found: correct programmatically and re-validate (max 3 iterations)
- If 3 iterations exhausted: present remaining issues to user with recommendations

---

## Artifact Chain Summary

| Step | File | Format | Produced by |
|------|------|--------|-------------|
| 1 | `project-context.md` | Markdown | Phase 2 (Opus) |
| 2 | `wbs-draft.md` | Markdown | Phase 3 (Opus) |
| 3 | `rbs-draft.md` | Markdown | Phase 3 (Sonnet) |
| 4 | `risk-register.md` | Markdown | Phase 4 (Sonnet) |
| 5 | `estimates-draft.md` | Markdown | Phase 4 (Opus) |
| 6 | `excel-input.json` | JSON | Phase 5 (Sonnet) |
| 7 | `pert-estimate.xlsx` | Excel | Phase 5 (Script) |

Each artifact is validated by the user before the next phase begins. The agent working on step N receives only artifacts 1..N-1 to keep context fresh.
