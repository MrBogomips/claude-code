---
name: pmo-pert-estimate
description: "Build a PMI-style PERT three-point estimate of a project and generate its Excel workbook: WBS with O/M/P effort and duration, a role × week resource plan in person-days, a risk register with contingency and Management Reserve, and a summary with Low / Medium / High effort bands and the calendar duration. Guides the user from input documents through WBS, roles, risks and estimates, then checks the workbook with a bundled script. Use when the user asks for a PERT or three-point estimate, a WBS-based effort estimate or a PMO estimation workbook, or says 'stima PERT' or 'stima progetto'. To estimate a Statement of Work and write the results back into it, use sow-estimate instead."
---

# PMO PERT Estimate — Three-point estimation workbooks

## 1. Overview

This skill produces PMI-compliant PERT three-point estimation workbooks through a multi-phase pipeline. Starting from project documents (SoW, RFP, scope descriptions), or from the extraction that `sow-estimate` hands over, it builds a WBS, the roles, a risk register and three-point estimates with the user, then generates an Excel workbook with live formulas (PERT, SUM rollups, cross-sheet references, effort bands).

Three principles shape it:

- **Progressive disclosure**: each reference document is read only when its phase begins.
- **Adaptive interaction**: three levels (Formative / Collaborative / Autonomous), chosen by the user and adjusted per phase.
- **Formulas in the workbook, figures from the script**: the generator writes formula strings and openpyxl stores no computed values, so the numbers are never read back from the workbook. `scripts/summarize.py` computes them from `excel-input.json` with the generator's own formulas and checks the generated formulas.

**Output workbook:** exactly 4 sheets in this order: `WBS`, `Resource Plan` (`Pianificazione Risorse` in IT), `Risks` (`Rischi` in IT), `Summary` (`Riepilogo` in IT). Effort cells are person-days (PD); calendar quantities are weeks.

**Bundled files:**

```
assets/pert-template.xlsx          <- reference layout (4 sheets)
examples/sample-input.json         <- complete, valid excel-input.json
scripts/
  generate_excel.py                <- JSON -> workbook (openpyxl)
  summarize.py                     <- JSON -> figures + workbook checks
  validate_template.py             <- custom template validator
  requirements-dev.txt             <- openpyxl + pytest, for the test suite
  helpers/                         <- sheet builders, figures, checks, i18n
references/
  workflow.md                      <- Phase 2 context analysis
  pmi-methodology.md               <- PMI guide (WBS, PERT, risks, reconciliation)
  interaction-levels.md            <- behaviour per level and phase
  excel-schema.md                  <- JSON input schema and sheet formulas
  template-criteria.md             <- criteria for custom templates
```

---

## 2. Configuration, folders and outputs

**Configuration section.** All project-management skills share one section in the project's `CLAUDE.md`: `## project-management Configuration`. A section named `## pmo-pert-estimate Configuration` (written by earlier versions) is read the same way; offer once to rename its heading.

**Estimate folder (working documents).** Drafts are working documents, not deliverables, so they never go under the output folder:

1. Use `WorkspaceDir` from the configuration section if it is set.
2. Otherwise use the location the project's `CLAUDE.md` declares for working documents (a "Working documents" section or similar), preferring its gitignored scratch location.
3. Otherwise ask the user where drafts should go, suggest a gitignored folder, and record the answer as `WorkspaceDir`.

Each estimate gets its own folder, `<WorkspaceDir>/pert-<estimate-slug>/`, where `<estimate-slug>` is the project name in kebab-case. Below, `<estimate>` means that folder.

**Output folder.** `OutputDir` from the configuration section. If it is not set, ask the user (suggest `docs/outbox/`) and record it.

**Versioned outputs, never overwritten.** The final workbook is `{OutputDir}/<estimate-slug>-pert-v<N>.xlsx`, where N is one more than the highest version already there (v1 for the first). An existing file is never overwritten, and input documents are never modified.

---

## 3. Phase 0 — Setup and runtime check

### 0a. First run: configuration

If the configuration section is missing, ask for these values, then write the section:

- **Language** — output language (default `en`)
- **EffortUnit** — `pd` (capacity checks and bands are person-day based)
- **DurationUnit** — `d` (working days; the Resource Plan converts to weeks at 5 days per week)
- **PrimaryColor** — hex color for Excel formatting (default `1B4FA5`)
- **Currency** — currency code (default `EUR`)
- **AvgRate** — average daily rate, used for contingency cost (optional)
- **ManagementReservePct** — management reserve percentage (default `10`)
- **OutputDir** and **WorkspaceDir** — as described in Section 2

**Template.** The generator always builds the canonical 4-sheet layout; a custom template is only checked for compatibility. Offer: use the bundled layout (`assets/pert-template.xlsx`, criteria in `references/template-criteria.md`); check a custom template with `cd <skill-dir>/scripts && python3 validate_template.py --template <user_path>` and record its path for reference only; or inspect the bundled template and stop.

```markdown
## project-management Configuration

| Field | Value |
|-------|-------|
| OutputDir | docs/outbox/ |
| WorkspaceDir | (project working-documents location) |
| Language | en |
| EffortUnit | pd |
| DurationUnit | d |
| PrimaryColor | 1B4FA5 |
| Currency | EUR |
| AvgRate | (none) |
| ManagementReservePct | 10 |
| CustomTemplate | (bundled) |
```

If the section exists, read it and go on without asking. If `CLAUDE.md` cannot be written, report it and ask the user to fix the permissions.

### 0b. Every run: Python and openpyxl

Phases 1–4 need no Python; Phases 5–6 do. Check early so the user is not surprised at the end:

```bash
python3 -c "import openpyxl; print(openpyxl.__version__)"
```

If `python3` or openpyxl is missing, say so and ask the user to choose:

- **Install openpyxl now** — only with the user's consent: `python3 -m pip install --user openpyxl`, then re-run the check.
- **Continue without it** — the skill stops after writing `excel-input.json` in Phase 5 and tells the user the two commands to run once openpyxl is installed.

---

## 4. Phase 1 — Interactive setup

This phase runs in the skill (no agent).

### Entry from sow-estimate

If `sow-estimate` invoked this skill, or the user points to an existing `sow-extraction.md`, the inputs are already collected:

- The folder that holds `sow-extraction.md` is the estimate folder. Reuse it as is; do not offer to start over there, because it holds the handoff.
- Read `sow-extraction.md`: project context, WBS draft, roles, risk register, targets and configuration hints. Do not ask again for input documents, a reference folder or targets that it already carries.
- Ask only for the interaction level (step 3 below) and for anything the extraction flags as missing.
- In the phases that follow, the extraction is the starting point: Phase 2 analyses it together with the SOW it names, Phase 3 refines its WBS and roles instead of starting from scratch, and the Risk Analyst starts from its risk register.

### Standard entry

1. Ask for the **input documents**: paths to SoW, RFP, scope description, or pasted text.
2. Ask whether a **reference folder** exists (contracts, previous estimates, org charts).
3. Ask the **interaction level**:
   - **(A) Formative** — full guidance, explains every PMI decision (for users new to PERT/PMI)
   - **(B) Collaborative** — the skill proposes, the user validates (default)
   - **(C) Autonomous** — the skill decides, the user reviews the final output (for experienced PMOs)
4. Ask for **target values** for total effort and/or duration, if any; they drive the Phase 4 reconciliation.
5. Create the estimate folder `<estimate>` (Section 2). If it already exists, ask whether to **reuse** it (continue from the drafts in it) or **start over**. To start over, first rename the existing folder to `pert-<estimate-slug>.bak-<YYYYMMDD-HHMM>/`, then create a new empty one, so nothing is lost.

Keep the choices (paths, level, targets, estimate folder) for the phase prompts.

---

## 5. How phases use agents

A dispatched agent runs once and returns; it cannot ask the user anything. So:

- Every agent prompt asks for a **draft plus a list of open questions**, and tells the agent to write only its own draft file in `<estimate>`.
- The skill itself runs each **checkpoint**: it shows the draft (or its summary at Level C), asks the open questions, and collects corrections. For a small change it edits the draft itself; for a larger one it dispatches the agent again with the user's answers and the current draft.
- At **Level A**, the WBS builder is dispatched **once per project phase**: the first dispatch covers phase 1, the checkpoint validates it, and the next dispatch covers phase 2 with the approved phases in its prompt. The other Level A agents add explanations to their drafts; the skill walks the user through them at the checkpoint.
- For Level A, read `references/interaction-levels.md` at the start of each phase for the teaching behaviour.

---

## 6. Phase 2 — Context analysis

Read `references/workflow.md` before constructing the agent prompt.

```
Agent(model="opus")
```

**Agent prompt must include:**
- The files to read: the input documents and reference folder contents from Phase 1, or `sow-extraction.md` and the SOW it names (entry from sow-estimate)
- The interaction level
- What to extract: scope and boundaries, constraints (time/budget/regulatory), assumptions, stakeholders, deliverables, role references, phases and milestones, risks already identified, targets the input states
- For **Level A**: include short methodology notes (what scope, constraints and assumptions mean and why they matter)
- Output: `<estimate>/project-context.md`, plus open questions (ambiguities, gaps)

**Checkpoint:** present the context and ask the open questions. At Level C present a short summary for acknowledgment.

**Error recovery:** if an input is ambiguous, ask the user at the checkpoint; if reference files are unreadable, skip them with a warning and go on.

---

## 7. Phase 3 — WBS and roles

Read `references/pmi-methodology.md` (WBS, 8/80, rolling wave, 100% rule) before constructing the prompts. The two agents can run in parallel because the roles do not depend on the work packages.

### WBS Builder

```
Agent(model="opus")
```

**Agent prompt must include:**
- File to read: `<estimate>/project-context.md` (and the WBS draft in `sow-extraction.md` when entering from sow-estimate)
- The interaction level, and target values (if any) for awareness
- Instructions:
  - Decompose Phase > Work Package > Activity
  - Apply the 8/80 rule in person-days: each leaf activity's most-likely effort is between 1 and 10 PD (8 to 80 hours at 8 h per PD); flag activities outside it and propose splits or merges
  - Identify dependencies between activities
  - Level A: cover only the project phase named in the prompt and explain each decomposition decision ("Methodology Applied" section)
  - Level B: the complete WBS in one pass, highlighting 8/80 borderline cases
  - Level C: the complete WBS
- Output: `<estimate>/wbs-draft.md`, plus open questions

### Roles Builder (RBS)

```
Agent(model="sonnet")
```

**Agent prompt must include:**
- File to read: `<estimate>/project-context.md` (and the roles in `sow-extraction.md` when entering from sow-estimate)
- The interaction level; reference `references/interaction-levels.md` for RBS behaviour
- Instructions: list the roles with a short code, assign each role to a team, describe competencies and responsibilities, and mark each role billable or non-billable. Do not allocate roles to work packages: the Estimator does that per activity in Phase 4. If the context names no roles, return that as an open question with a proposed role list.
- Output: `<estimate>/rbs-draft.md`, plus open questions

**Checkpoint:** present the WBS and the roles together. If the WBS needs a skill that no role covers, raise it here. **Backtrack:** if the context is incomplete, return to Phase 2.

---

## 8. Phase 4 — Risks and estimates

Read `references/pmi-methodology.md` (Risk Management, Three-Point Estimation, Reconciliation). The Risk Analyst runs first; its checkpoint comes before the Estimator starts.

### Risk Analyst

```
Agent(model="sonnet")
```

**Agent prompt must include:**
- Files to read: `project-context.md`, `wbs-draft.md`, `rbs-draft.md` in `<estimate>` (and the risk register in `sow-extraction.md` when entering from sow-estimate)
- The interaction level
- Instructions:
  - Identify risks per phase or activity; score Probability (1–5) × Impact (1–5)
  - Treat P×I ≥ 10 as high (HIGH 10–14, CRITICAL ≥ 15): each high risk needs a mitigation action and an owner
  - Propose a strategy (Mitigate / Transfer / Accept / Avoid) and a contingency in PD per risk
  - Propose the management reserve as a % of Tech PERT + PM/DevOps overhead + total contingency (default `ManagementReservePct`)
  - Level A: explain the P×I matrix, the strategies and the contingency calculation in the draft
- Output: `<estimate>/risk-register.md`, plus open questions

**Checkpoint:** present the register, high risks first.

### Estimator

```
Agent(model="opus")
```

**Agent prompt must include:**
- Files to read: all four drafts in `<estimate>`
- The interaction level and the targets (if any)
- Instructions:
  - For each leaf activity: Best (O) / Most Likely (M) / Worst (P) effort in PD and duration in days
  - PERT = (O + 4M + P) / 6 and σ = (P − O) / 6 per activity; rollups per phase and project, summed the way the workbook sums them (linear σ; see `references/pmi-methodology.md` §3)
  - Assign roles per activity, primary role first (it drives the Resource Plan)
  - Level A: calibration questions, PERT derivation, what σ means, and that the workbook quotes effort bands rather than a confidence interval
  - Level B: O/M/P for all activities, PERT totals per phase and a preview of the effort bands (the final figures come from `summarize.py` in Phase 6)
  - If targets exist and the deviation is over 20%: return the delta, its causes (scope, estimates, resources, dependencies) and proposed adjustments as open questions
- Output: `<estimate>/estimates-draft.md`, plus open questions

**Checkpoint and reconciliation:** present the estimates. When the delta exceeds 20%, ask the user which adjustments to accept, then dispatch the Estimator again with the decisions. Repeat until the delta is within 20% or the user accepts it, at most 3 rounds; then present the delta and ask for an explicit scope or target change. At Level C, reconcile silently when the delta is ≤ 20% and stop only when it is larger. Record the reconciliation log in `estimates-draft.md`.

**Backtrack:** if estimation shows the WBS needs restructuring, return to Phase 3.

---

## 9. Phase 5 — Excel generation

Read `references/excel-schema.md`: it documents every JSON key the generator reads (config, roles, phases, work packages, activities, risks, scenarios). `examples/sample-input.json` is a complete, valid example to copy the shape from.

```
Agent(model="sonnet")
```

**Agent prompt must include:**
- Files to read: the five drafts in `<estimate>`
- The configuration values (lang, effort_unit, duration_unit, primary_color, currency, avg_rate, management_reserve_pct as a ratio: 10 → 0.10)
- References: `references/excel-schema.md` and `examples/sample-input.json`
- Instructions:
  1. Write `<estimate>/excel-input.json` with the keys `config`, `roles`, `phases` (with `work_packages` and `activities`), `risks` and optionally `scenarios`. Targets and reconciliation notes stay in the markdown drafts: the generator reads no other keys.
  2. Validate it: `cd <skill-dir>/scripts && python3 summarize.py --input <estimate>/excel-input.json > /dev/null`. Exit code 1 lists the input errors on stderr; fix them and re-run.
  3. Generate: `cd <skill-dir>/scripts && python3 generate_excel.py --input <estimate>/excel-input.json --output <estimate>/pert-estimate.xlsx`
  4. Return the result, or the traceback after 2 failed retries

If openpyxl is unavailable and the user chose to continue without it (Phase 0b), stop after step 1 and give the user the commands of steps 2–3 and of Phase 6.

**Error recovery:** read the traceback; fix a missing field or a wrong type in the JSON (the validation in step 2 names them); retry at most twice; if still failing, report the traceback, the last valid drafts and the cell or sheet involved.

---

## 10. Phase 6 — Checks and figures

This phase runs in the skill: the checks are a script, so no agent is needed.

```bash
cd <skill-dir>/scripts && python3 summarize.py \
  --input <estimate>/excel-input.json \
  --workbook <estimate>/pert-estimate.xlsx \
  --output <estimate>/summary.json
```

If `command -v soffice` (or `libreoffice`) finds LibreOffice, add `--recalc`: the script then recalculates a copy and compares the band values with its own figures. Without LibreOffice the static checks are enough.

- **Exit 0** — the checks passed. They cover the sheet order, formula cells holding the documented formulas at the rows the input implies (PERT, σ, billable, rollup ranges, TOTAL row), no `#REF!` or other error token, input cells filled, the Risks Management Reserve built on `WBS!H{total}`, the Summary bands (Low = Subtotal + Contingency, MR = Low × MR%, Medium = Low + MR, High = Medium × (1 + uplift)), the calendar duration value, and Resource Plan cells summing to the Tech PERT within ±1 PD.
- **Exit 2** — each error names `Sheet!Cell`, what was expected and what was found. Fix the cause in `excel-input.json`, never by editing the workbook, regenerate (Phase 5 step 3) and re-run, at most 3 times; then present the remaining errors with recommendations.
- **Warnings** in `summary.json` (activities outside the 8/80 rule, activities without a primary role, keys the generator does not read) do not fail the run; show them to the user.

When the checks pass, copy the workbook to `{OutputDir}/<estimate-slug>-pert-v<N>.xlsx` (Section 2).

**Present the result** from `summary.json`, never from the workbook: phases, work packages and activities (`counts`), Tech PERT effort, Low / Medium / High Band, Calendar Duration in weeks, number of risks and of high risks (`high_risk_ids`, P×I ≥ 10), total contingency and Management Reserve, and the output path. `summarize.py --format markdown` prints the same figures as a table.

---

## 11. Progressive disclosure

| Phase | Documents to read |
|-------|-------------------|
| Phase 0 | `references/template-criteria.md` only when checking a custom template |
| Phase 1 | `sow-extraction.md` when entering from sow-estimate |
| Phase 2 | `references/workflow.md` |
| Phase 3 | `references/pmi-methodology.md` (WBS, 8/80, rolling wave) |
| Phase 4 | `references/pmi-methodology.md` (Risk, PERT, Reconciliation) |
| Phase 5 | `references/excel-schema.md`, `examples/sample-input.json` |
| Phase 6 | (none; `references/excel-schema.md` if an error needs explaining) |

For Level A, also read `references/interaction-levels.md` at the start of each phase. Loading every reference at the start would crowd the context the later phases need.

---

## 12. Dynamic adaptation

The interaction level adapts per phase.

| Trigger | Action |
|---------|--------|
| Level B/C user asks "why?" or "what does X mean?" | Explain at Level A depth for that topic; ask: "Would you like full guidance for this phase?" |
| Level B/C user asks for methodology | Give the PMBOK context from `references/pmi-methodology.md`; offer to stay at Level A |
| Level B/C user is unsure about estimates | Use the calibration questions from `references/pmi-methodology.md` Section 2 |
| Level A user keeps answering "ok" / "looks good" | Suggest: "You seem comfortable — want complete drafts instead of step-by-step?" |
| Level A user edits estimates confidently | Reduce explanation density |
| User asks for a faster pace | Switch to the requested level |

Never lower the level without suggesting it first; adding explanation when asked needs no announcement.

---

## 13. Error recovery summary

- Invalid input path: ask the user to correct it.
- Estimate folder already exists: reuse, or back it up and start over (Section 4); after entry from sow-estimate, reuse.
- Template validation fails: show the errors and offer the bundled layout.
- `CLAUDE.md` read-only: report it and ask the user to fix permissions.
- openpyxl missing: Phase 0b.
- WBS outside the 8/80 rule: flag the activities and propose splits or merges.
- No roles in the context: ask for the role list at the Phase 3 checkpoint.
- Reconciliation not converging after 3 rounds: present the delta and ask for a scope or target change.
- Generation or checks failing: Phase 5 and Phase 6 limits (2 and 3 retries), then report.

---

## 14. Artifact chain

Each artifact is validated at a checkpoint before it feeds the next phase; the agent of step N receives only artifacts 1..N−1.

| Step | File | Produced by |
|------|------|-------------|
| 0 | `<estimate>/sow-extraction.md` (entry from sow-estimate only) | sow-estimate |
| 1 | `<estimate>/project-context.md` | Phase 2 |
| 2 | `<estimate>/wbs-draft.md` | Phase 3 |
| 3 | `<estimate>/rbs-draft.md` | Phase 3 |
| 4 | `<estimate>/risk-register.md` | Phase 4 |
| 5 | `<estimate>/estimates-draft.md` | Phase 4 |
| 6 | `<estimate>/excel-input.json` | Phase 5 |
| 7 | `<estimate>/pert-estimate.xlsx` (working copy) | Phase 5 (script) |
| 8 | `<estimate>/summary.json` | Phase 6 (script) |
| 9 | `{OutputDir}/<estimate-slug>-pert-v<N>.xlsx` | Phase 6 |

---

## 15. Final checklist

- [ ] `summarize.py --workbook` exited 0 (and `--recalc` passed or was skipped for lack of LibreOffice)
- [ ] The warnings in `summary.json` were shown to the user
- [ ] 8/80 rule respected (1–10 PD most-likely per leaf activity), or each exception accepted by the user
- [ ] Each high risk (P×I ≥ 10) has a mitigation action and an owner
- [ ] Reconciliation executed if targets were given and the delta exceeded 20%
- [ ] Drafts, `excel-input.json` and `summary.json` are in `<estimate>`; nothing was written to the output folder except the versioned workbook
- [ ] The workbook was saved under a new version number; no existing file was overwritten
- [ ] Figures presented to the user come from `summary.json`
- [ ] The interaction level was respected throughout
