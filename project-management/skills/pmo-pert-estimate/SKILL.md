---
name: pmo-pert-estimate
description: "Create PMI-compliant PERT three-point estimation workbooks with WBS, resource plan (role × week PD), risks, and summary sheets. Produces fully automated Excel with live formulas, PD-everywhere effort, PMI-correct Management Reserve, configurable PM/DevOps overhead, and explicit calendar duration. Triggers: 'create PERT estimate', 'generate WBS estimate', 'PMO estimation', 'three-point estimate', 'PERT analysis', 'project estimation', 'stima PERT', 'stima progetto'"
---

# PMO PERT Estimate — Three-point estimation workbooks

## 1. Overview

This skill produces PMI-compliant PERT three-point estimation workbooks through a multi-phase agentic pipeline. Starting from project documents (SoW, RFP, scope descriptions), it interactively builds a WBS, resource breakdown, risk register, and three-point estimates, then generates a fully automated Excel workbook with live formulas (PERT, SUM rollups, cross-sheet references, effort bands). The skill follows three key principles: **progressive disclosure** of reference documents (loaded only when the relevant phase begins, never all at once), **adaptive interaction** across three levels (Formative / Collaborative / Autonomous) chosen by the user with dynamic adjustment, and **strict input/formula separation** where Excel formula cells are always injected as strings and never overwritten with computed values.

**Output workbook composition:** exactly 4 sheets in this order — `WBS`, `Resource Plan` (`Pianificazione Risorse` in IT), `Risks` (`Rischi` in IT), `Summary` (`Riepilogo` in IT). All effort cells are person-days (PD); calendar quantities are weeks. No cell ever holds a percentage that is presented as effort. The legacy `Timeline` (sequential Gantt) and `Resources` (% allocation matrix) sheets are no longer produced — both were structurally misleading and have been replaced by the single PD-based `Resource Plan`.

**Bundled assets:**

```
assets/
  pert-template.xlsx              <- bundled reference template (4 sheets)
scripts/
  generate_excel.py               <- JSON -> Excel generator (openpyxl)
  validate_template.py            <- custom template validator
  helpers/
    __init__.py
    wb_wbs.py                     <- WBS sheet logic
    wb_pianificazione_risorse.py  <- Resource Plan (role × week PD) logic
    wb_risks.py                   <- Risk register + PMI-correct MR
    wb_summary.py                 <- Summary sheet logic (bands, overhead)
    formatting.py                 <- Shared styles, colors, fonts, formats
    i18n.py                       <- en/it label tables
    config_compat.py              <- Legacy JSON detection + default backfill
references/
  workflow.md                     <- detailed agentic flow description
  pmi-methodology.md              <- PMI guide for formative mode
  template-criteria.md            <- criteria for custom templates
  excel-schema.md                 <- column/formula/cross-ref schema per sheet
  interaction-levels.md           <- description of 3 interaction levels
```

**Workspace directory:** `docs/pert-workspace/` (created during Phase 1)
**Output directory:** configurable per project (default: `docs/outbox/`)

---

## 2. Phase 0 -- First Run Setup

When running in a repository for the first time, check whether `CLAUDE.md` contains a `## pmo-pert-estimate Configuration` section. If it does not exist, guide the user through setup.

### Steps

1. **Ask** the user for project-specific values:
   - **Language** -- output language (default: `en`)
   - **EffortUnit** -- `pd` / `hours` / `story_points` (default: `pd`)
   - **DurationUnit** -- `days` / `weeks` / `sprints` (default: `d`)
   - **PrimaryColor** -- hex color for Excel formatting (default: `1B4FA5`)
   - **Currency** -- currency code (default: `EUR`)
   - **PeriodType** -- `weekly` / `biweekly` / `monthly` (default: `biweekly`)
   - **AvgRate** -- average daily rate for cost calculations (optional, default: none)
   - **ManagementReservePct** -- management reserve percentage (default: `10`)
   - **OutputDir** -- where to save generated workbooks (default: `docs/outbox/`)

2. **Ask about template**. Offer four options:
   - **Use bundled** -- inform that the base template is at `assets/pert-template.xlsx` (relative to this skill directory) and criteria are documented in `references/template-criteria.md`
   - **Use custom** -- run validation:
     ```bash
     cd <skill-dir>/scripts && python3 validate_template.py --template <user_path>
     ```
     If valid: record path. If invalid: show specific errors, offer to fall back to bundled.
   - **Customize now** -- copy bundled template to project directory for user modification, then validate
   - **Generate empty only** -- produce the base template and stop (inspection mode)

3. **Write** the configuration section into `CLAUDE.md`:

```markdown
## pmo-pert-estimate Configuration

| Field | Value |
|-------|-------|
| Language | en |
| EffortUnit | pd |
| DurationUnit | d |
| PrimaryColor | 1B4FA5 |
| Currency | EUR |
| PeriodType | biweekly |
| AvgRate | (none) |
| ManagementReservePct | 10 |
| OutputDir | docs/outbox/ |
| CustomTemplate | (bundled) |
```

4. **Confirm** to the user that future invocations will use these values automatically.

If the section already exists, read values from it and proceed silently.

---

## 3. Phase 1 -- Interactive Setup

This phase runs in-skill (no agent call). Collect all inputs needed for subsequent phases.

### Steps

1. Ask for **input documents** -- path(s) to SoW, RFP, scope description, or pasted text
2. Ask if a **reference folder** exists with additional materials (contracts, previous estimates, org charts)
3. Ask **interaction level**:
   - **(A) Formative** -- full guidance, explains every PMI decision (for users new to PERT/PMI)
   - **(B) Collaborative** -- agent proposes, user validates (default)
   - **(C) Autonomous** -- agent decides, user reviews final output (for experienced PMOs)
4. Ask if there are **target values** for total effort and/or duration
   - If yes: record targets for reconciliation in Phase 4
5. Create working directory: `docs/pert-workspace/`
   - If it already exists: ask whether to reuse or create fresh

Store all choices (document paths, reference folder, interaction level, targets) for use in subsequent phase prompts.

---

## 4. Phase 2 -- Context Analysis

**Progressive disclosure:** `Read references/workflow.md` Phase 2 section before constructing the agent prompt.

Launch an agent to analyze the input documents and extract project context.

```
Agent(model="opus")
```

**Agent prompt must include:**
- Exact file paths to read: the input document(s) and reference folder contents collected in Phase 1
- The interaction level chosen by the user
- Instruction to extract: scope and boundaries, constraints (time/budget/regulatory), assumptions, stakeholders, deliverables, role references, phases and milestones mentioned, risks already identified in input
- For **Level A**: include methodology explanation sections in the output (what scope/constraints/assumptions mean, why they matter)
- For **Level B**: present complete context analysis, ask "Does this capture everything?"
- For **Level C**: analyze silently, present summary for acknowledgment
- Output format: structured markdown saved to `docs/pert-workspace/project-context.md`

**User validation checkpoint:** present the context analysis for review. The user may request additions or corrections.

**Error recovery:**
- If input document is ambiguous: ask clarifying questions
- If reference folder files are unreadable: skip with warning, proceed with available data

---

## 5. Phase 3 -- WBS + RBS Construction

**Progressive disclosure:** `Read references/pmi-methodology.md` before constructing agent prompts. For Level A interactions, the agents use this document to explain decomposition decisions and RACI concepts.

Launch two agents in parallel:

### WBS Builder

```
Agent(model="opus")
```

**Agent prompt must include:**
- File to read: `docs/pert-workspace/project-context.md`
- The interaction level chosen by the user
- Target values (if any) for awareness during decomposition
- Reference: `references/pmi-methodology.md` -- specifically sections on WBS, 8/80 rule, rolling wave planning, 100% rule
- Instructions:
  - Propose hierarchical decomposition: Phase > Work Package > Activity
  - Apply 8/80 rule (no work package < 8h or > 80h)
  - Identify dependencies between activities
  - For **Level A**: propose one phase at a time, explain each decomposition decision with PMI reasoning, include "Methodology Applied" section in output
  - For **Level B**: propose complete WBS in one pass, highlight 8/80 borderline cases
  - For **Level C**: generate complete WBS autonomously
- Output format: structured markdown saved to `docs/pert-workspace/wbs-draft.md`

### RBS Builder

```
Agent(model="sonnet")
```

**Agent prompt must include:**
- File to read: `docs/pert-workspace/project-context.md`
- The interaction level chosen by the user
- Reference: `references/interaction-levels.md` -- for RBS-specific behavior per level
- Instructions:
  - Extract roles from context (or ask if not found)
  - Assign roles to teams
  - Define competencies and responsibilities
  - Propose resource allocation per work package
  - Mark each role as billable or non-billable
  - For **Level A**: explain RACI concepts, discuss billable vs non-billable distinction
  - For **Level B**: propose complete RBS with team assignments
  - For **Level C**: generate complete RBS autonomously
- Output format: structured markdown saved to `docs/pert-workspace/rbs-draft.md`

**User validation checkpoint:** present both WBS and RBS for review. If the two artifacts are inconsistent (e.g., RBS references phases not in WBS), reconcile before presenting.

**Backtrack:** if context is incomplete, return to Phase 2 for additions.

---

## 6. Phase 4 -- Risks + Estimates

**Progressive disclosure:** `Read references/pmi-methodology.md` sections on Risk Management and Three-Point Estimation. `Read references/interaction-levels.md` for phase-specific behavior guidance.

Launch two agents sequentially (Risk Analyst must complete before Estimator begins).

### Risk Analyst

```
Agent(model="sonnet")
```

**Agent prompt must include:**
- Files to read: `docs/pert-workspace/project-context.md`, `docs/pert-workspace/wbs-draft.md`, `docs/pert-workspace/rbs-draft.md`
- The interaction level chosen by the user
- Reference: `references/pmi-methodology.md` -- sections on Risk Identification, P x I Matrix, Response Strategies, Contingency vs Management Reserve
- Instructions:
  - Identify risks per phase/activity
  - Evaluate Probability (1-5) x Impact (1-5)
  - Propose strategy: Mitigate / Transfer / Accept / Avoid
  - Calculate contingency per risk
  - Propose management reserve (% of total PERT, default from config `ManagementReservePct`)
  - For **Level A**: introduce P x I matrix with examples, explain each response strategy, walk through contingency calculation
  - For **Level B**: propose complete risk register, highlight highest-priority risks
  - For **Level C**: generate complete risk register autonomously
- Output format: structured markdown saved to `docs/pert-workspace/risk-register.md`

**User validation checkpoint:** present risk register for review before proceeding to Estimator.

### Estimator

```
Agent(model="opus")
```

**Agent prompt must include:**
- Files to read: `docs/pert-workspace/project-context.md`, `docs/pert-workspace/wbs-draft.md`, `docs/pert-workspace/rbs-draft.md`, `docs/pert-workspace/risk-register.md`
- The interaction level chosen by the user
- Target values (if any) for effort and/or duration
- Reference: `references/pmi-methodology.md` -- sections on Three-Point Estimation (PERT), Calibration Questions, Common Estimation Pitfalls, Statistical Confidence Intervals, Top-Down/Bottom-Up Reconciliation
- Instructions:
  - For each leaf activity: propose Best (O) / Most Likely (M) / Worst (P) estimates
  - Calculate PERT = (O + 4M + P) / 6 and sigma = (P - O) / 6 per activity
  - Rollup per phase and project total
  - Resource assignment per activity (role codes from RBS)
  - If targets provided and deviation > 20%: initiate guided reconciliation
    - Analyze causes (scope, estimates, resources, dependencies)
    - Propose adjustments (scope deferral, estimate recalibration, resource reallocation, risk reassessment)
    - Iterate until convergence or explicit user acceptance
    - Document reconciliation log
  - For **Level A**: explain three-point calibration using calibration questions from methodology reference, show PERT formula derivation, explain sigma and confidence intervals
  - For **Level B**: propose O/M/P ranges for all activities, show PERT totals and CI, ask "Any estimates you'd like to adjust?"
  - For **Level C**: generate all estimates autonomously, auto-reconcile if delta <= 20%, flag only if delta > 20%
- Output format: structured markdown saved to `docs/pert-workspace/estimates-draft.md`

**User validation checkpoint:** present estimates for review. Include reconciliation analysis (if targets were provided) showing delta and adjustment rationale.

**Backtrack:** if WBS needs restructuring after estimation (e.g., discovered missing activities), return to Phase 3.

---

## 7. Phase 5 -- Excel Generation

**Progressive disclosure:** `Read references/excel-schema.md` before constructing the agent prompt. This is the machine-readable reference for the JSON structure and Excel column/formula schema.

```
Agent(model="sonnet")
```

**Agent prompt must include:**
- Files to read: all validated markdown artifacts:
  - `docs/pert-workspace/project-context.md`
  - `docs/pert-workspace/wbs-draft.md`
  - `docs/pert-workspace/rbs-draft.md`
  - `docs/pert-workspace/risk-register.md`
  - `docs/pert-workspace/estimates-draft.md`
- The pmo-pert-estimate configuration from CLAUDE.md (effort_unit, duration_unit, primary_color, currency, period_type, avg_rate, management_reserve_pct)
- Target values (if any)
- Reference: `references/excel-schema.md` -- the complete JSON input schema and column/formula definitions per sheet
- Instructions:
  - Construct the structured JSON matching the schema in `references/excel-schema.md` (config, roles, phases with work_packages and activities, resource_allocation, risks, targets)
  - Save JSON to `docs/pert-workspace/excel-input.json`
  - Invoke the generator script:
    ```bash
    cd <skill-dir>/scripts && python3 generate_excel.py --input <json_path> --output <output_path>
    ```
  - The output path is `{OutputDir}/pert-estimate.xlsx` (from config)
- Output: the generated Excel workbook

### Error Recovery Protocol

If the Python script fails during execution:

1. **Capture** the full Python traceback
2. **Analyze** root cause:
   - Missing field in JSON: identify which field, add it with appropriate value
   - Wrong type (e.g., string where number expected): fix the type in JSON
   - Formula error: check against `references/excel-schema.md` patterns
   - openpyxl API error: report the specific cell/sheet causing the issue
3. **Re-generate** the JSON with fixes and retry (maximum 2 attempts)
4. **If unrecoverable** after 2 retries: report the error to the user with full context (traceback, last valid artifacts, specific cell/sheet if known) for manual intervention

---

## 8. Phase 6 -- Validation

```
Agent(model="sonnet")
```

**Agent prompt must include:**
- File to read: the generated Excel workbook at `{OutputDir}/pert-estimate.xlsx`
- Reference: `references/excel-schema.md` for expected formula patterns and cross-references
- Reference: `references/template-criteria.md` for structural requirements
- Instructions:
  - Open the workbook with openpyxl
  - Run the verification checklist:
    - [ ] Exactly 4 sheets present in this order: `WBS`, `Resource Plan` / `Pianificazione Risorse`, `Risks` / `Rischi`, `Summary` / `Riepilogo`
    - [ ] Formula cells contain formulas, not hardcoded values
    - [ ] Cross-reference inter-sheet links resolve correctly (no `#REF!` errors)
    - [ ] Consistent formatting (font, colors, borders, number format per row type)
    - [ ] SUM rollups match actual child ranges
    - [ ] PERT = `(O+4M+P)/6` present on every appropriate row
    - [ ] sigma = `(P-O)/6` present in the WBS σ Duration column
    - [ ] No empty input cells (all leaf activities have O/M/P values)
    - [ ] Resource Plan: TOTAL (PD) per role equals Σ PERT of activities where the role is primary; grand total within ±1 PD of `WBS!H{total}`
    - [ ] Risks: Management Reserve formula uses the Tech+Overhead+Contingency base (cross-references `WBS!H{total}`), not just the contingency total
    - [ ] Summary: Fascia BASSA = Subtotal + Contingency; MR is `Fascia BASSA × management_reserve_pct`; Fascia MEDIA = BASSA + MR; Fascia ALTA = MEDIA × (1 + alta_uplift_pct)
    - [ ] Summary: Calendar Duration cell is a single weekly number (not a sum of leaf durations)
    - [ ] TOTAL row has global SUMs for effort and billable effort
  - If issues found: fix programmatically and re-validate (maximum 3 iterations)
  - If 3 iterations exhausted with remaining issues: present the issues to the user with recommendations
- Output: validation report + corrected Excel (if fixes were applied)

**Present final workbook** to user with summary statistics (total phases, activities, PERT effort, PERT duration, CI ranges, number of risks, contingency, adjusted estimate).

---

## 9. Progressive Disclosure Rules

Reference documents are loaded ONLY when entering the relevant phase. This keeps agent context fresh and focused.

| Phase | Documents to Read |
|-------|-------------------|
| Phase 0 | (none -- in-skill setup) |
| Phase 1 | (none -- in-skill setup) |
| Phase 2 | `references/workflow.md` Phase 2 section |
| Phase 3 | `references/pmi-methodology.md` (WBS, 8/80, rolling wave sections) |
| Phase 4 | `references/pmi-methodology.md` (Risk, PERT, Reconciliation sections) |
| Phase 5 | `references/excel-schema.md` (full document) |
| Phase 6 | `references/excel-schema.md` + `references/template-criteria.md` |

For Level A interactions, additionally read `references/interaction-levels.md` at the start of each phase to retrieve phase-specific formative behavior guidance.

**Never load all reference documents at the beginning of the workflow.**

---

## 10. Dynamic Adaptation

The interaction level is not rigid. Monitor user behavior and adapt per-phase.

### Upward Shift (toward more guidance)

| Trigger | Action |
|---------|--------|
| Level B/C user asks "why?" or "what does X mean?" | Switch to Level A explanations for that topic. Ask: "Would you like me to switch to full guidance mode for this phase?" |
| Level B/C user requests methodology explanation | Provide PMBOK context from `references/pmi-methodology.md`, offer to stay at Level A |
| Level B/C user expresses uncertainty about estimates | Use calibration questions from `references/pmi-methodology.md` Section 2 |

### Downward Shift (toward less guidance)

| Trigger | Action |
|---------|--------|
| Level A user consistently responds "ok" / "looks good" without engagement | Suggest: "You seem comfortable -- want me to propose complete artifacts instead of step-by-step?" |
| Level A user modifies estimates confidently | Reduce explanation density |
| User explicitly requests faster pace | Switch to requested level |

Adaptation is **per-phase**, not global. The agent never downgrades without suggesting it first. The agent may upgrade silently (providing more context when asked) without formally announcing a level change.

---

## 11. Error Recovery Summary

### Phase 5 -- Excel Generation Errors

1. Capture Python traceback
2. Analyze root cause (missing field, wrong type, formula error, openpyxl API issue)
3. Re-generate JSON with fixes (maximum 2 retries)
4. If unrecoverable: report to user with full context

### Phase 6 -- Validation Errors

1. Identify failing checks from verification checklist
2. Apply programmatic fixes (correct formula, fix cross-reference, add missing value)
3. Re-validate (maximum 3 iterations)
4. If unresolved: present remaining issues with recommendations

### General Error Recovery

- If input document path is invalid: ask user to correct
- If workspace directory already exists: ask whether to reuse or create fresh
- If template validation fails: show specific errors, offer fallback to bundled template
- If CLAUDE.md is read-only: report error, ask user to fix permissions
- If WBS violates 8/80 rule: flag violations, propose splits/merges
- If no roles found in context: ask user to provide role list
- If reconciliation fails to converge after 3 iterations: present delta to user, ask for explicit scope/target adjustment

---

## 12. Artifact Chain

Each artifact is produced, validated by the user, and then passed as input to the next phase. The agent working on step N receives only artifacts 1..N-1 to keep context fresh.

| Step | File | Format | Produced by |
|------|------|--------|-------------|
| 1 | `docs/pert-workspace/project-context.md` | Markdown | Phase 2 (Opus) |
| 2 | `docs/pert-workspace/wbs-draft.md` | Markdown | Phase 3 (Opus) |
| 3 | `docs/pert-workspace/rbs-draft.md` | Markdown | Phase 3 (Sonnet) |
| 4 | `docs/pert-workspace/risk-register.md` | Markdown | Phase 4 (Sonnet) |
| 5 | `docs/pert-workspace/estimates-draft.md` | Markdown | Phase 4 (Opus) |
| 6 | `docs/pert-workspace/excel-input.json` | JSON | Phase 5 (Sonnet) |
| 7 | `{OutputDir}/pert-estimate.xlsx` | Excel | Phase 5 (Script) |

---

## 13. Final Checklist

Before considering the estimation complete, verify:

- [ ] All 4 Excel sheets present in order: `WBS`, `Resource Plan` (`Pianificazione Risorse`), `Risks` (`Rischi`), `Summary` (`Riepilogo`)
- [ ] PERT formulas `=(O+4M+P)/6` on every appropriate WBS row
- [ ] SUM rollups correct (exact child ranges)
- [ ] sigma = `(P-O)/6` present in the WBS σ Duration column
- [ ] Cross-sheet references resolve (no `#REF!` errors)
- [ ] Input columns have values, formula columns have formulas (never inverted)
- [ ] Consistent formatting (phase/WP/leaf/total row styles)
- [ ] Billable flags correct, BILLABLE EFFORT calculated on the WBS sheet
- [ ] Resource Plan: PD per role × week with TOTAL (PD) column equal to Σ PERT of activities where the role is primary; cells over capacity (`>5 PD/week`) flagged red
- [ ] Risk register with P×I formula, priority IF, contingency, and a Management Reserve cell whose formula cross-references `WBS!H{total}` (PMI-correct base)
- [ ] Summary with Tech PERT, PM/DevOps overhead, Subtotal, Contingency, Fascia BASSA/MEDIA/ALTA, Management Reserve, Calendar Duration, Effort by Team (real PD), and Sensitivity Scenarios (if provided)
- [ ] TOTAL row with global SUMs for effort and billable effort
- [ ] 8/80 rule respected in WBS decomposition
- [ ] All intermediate `.md` artifacts saved in `docs/pert-workspace/`
- [ ] Interaction level respected throughout the workflow
- [ ] Reconciliation executed if targets were provided and delta > 20%
