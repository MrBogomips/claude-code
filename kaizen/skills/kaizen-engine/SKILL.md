---
name: kaizen-engine
description: "Recursive improvement loop engine inspired by karpathy/autoresearch. Runs 8-phase iterations (MEASURE, ANALYZE, HYPOTHESIZE, PROPOSE, APPLY, VERIFY, DECIDE, LOG) against measurable KPIs, with greedy or multi-objective ratcheting and configurable autonomy. Use when the user wants to run a kaizen, continuous-improvement, or iterative optimization loop that improves code, configuration, or processes against measurable KPIs, or names a bundled profile ('claude-code-usage', 'code-refactoring', 'process-improvement'). Not for a one-off 'improve this' edit. Optionally uses **~~sequential-thinking**."
---

# Kaizen Engine — Recursive Improvement Loop Orchestrator

## 1. Overview

The kaizen engine runs recursive improvement loops against measurable KPIs. It reads a **profile** (PROFILE.md) that defines what to improve, how to measure, and what to mutate, then executes iterative cycles until convergence, budget exhaustion, or user interrupt.

**Architecture:** Engine + Profiles. The engine is generic; profiles are domain-specific.

**Connector:** **~~sequential-thinking** is optional. When it is connected, you may record each iteration's phases as one thought chain; the loop below runs the same either way.

**Storage:** Each run lives under one **storage root**, chosen in Step 1a before anything is written and recorded in the manifest:
- Project-level improvements: `.kaizen/` at project root
- User-level improvements (personal or cross-project): `~/.kaizen/`

Paths written below as `.kaizen/runs/...` are relative to the run's storage root.

The schemas of the run files (`manifest.json`, `measurement.json`, `decision.json`, `summary.json`) are in `references/run-state.md`.

---

## 2. Pipeline

### Step 0 — Profile Resolution

Determine which profile to load:

1. If the user gives a path to a PROFILE.md, use it. If they give a name, look for `{name}/PROFILE.md` in these folders and use the first match:
   1. `.kaizen/profiles/` at the project root — custom profiles for this project
   2. `~/.kaizen/profiles/` — the user's custom profiles
   3. `profiles/` within this plugin directory — bundled profiles

   If the name exists in more than one folder, tell the user which file you loaded.
2. If no profile is specified, list the bundled profiles and any custom profiles in the two `.kaizen/profiles/` folders, and ask the user to choose. The bundled ones are:
   - **claude-code-usage** — analyze and improve Claude Code tool/skill usage patterns
   - **code-refactoring** — recursively improve code quality metrics
   - **process-improvement** — design and run kaizen loops for business processes
3. The **profile directory** is the folder that holds the PROFILE.md. Every `references/...` path a profile names resolves against the profile directory, not against this skill.
4. Parse the PROFILE.md YAML frontmatter to extract configuration:
   - `name`, `version`, `strategy`, `autonomy`
   - `kpis[]` — name, description, direction, unit, measurement_method, formula, and the optional `epsilon` (in the KPI's own unit) and `observational` flag
   - `initial_state.sources[]` — data sources for baseline capture
   - `mutation_targets.defaults[]` and `mutation_targets.immutable[]`
   - `convergence.epsilon` (the fallback for KPIs without their own `epsilon`), `convergence.patience`
   - `iteration_budget`
   - `measurement.tool_generation`, `measurement.language`
5. Ask the user for any **scope overrides**:
   - Narrow or expand mutation targets
   - Adjust iteration budget
   - Override autonomy level for this run

**Output:** Resolved profile configuration ready for BOOTSTRAP.

### Step 1 — BOOTSTRAP

Prepare the improvement environment before the first iteration. `Read references/run-state.md` for the resume and git-check details and the manifest schema.

#### 1a. Storage Root, Resume or New Run

Look for open runs of this profile in both storage roots, `.kaizen/runs/` at the project root and `~/.kaizen/runs/`. The latest run of the profile in a root is open if it has a `manifest.json` and its `summary.json` is missing or has `convergence_reason: null`: it stopped before finishing, as a process-improvement run whose iterations span weeks does between sessions. Offer to resume each open run found, naming its root:
- **Resume:** the run keeps its storage root. Follow `references/run-state.md` → Resume: rebuild context from the run's files, restore an iteration that stopped partway through APPLY, run the git check (1d) again because the tree may have changed, and continue where the run stopped.
- **New run:** if the open run stopped partway through APPLY, restore that iteration from its backup first (same rule as Resume) and tell the user, so the new run does not start from half-edited files. Then record `convergence_reason: "user_stopped"` in the old run's `summary.json` (create the file if needed) so it is not offered again, and continue below.

For a new run, settle the storage root first. Use the project's `.kaizen/` when every default mutation target is inside the project. When a target lies outside the project, or is not known yet (an empty path, as in process-improvement, whose targets are settled in its BOOTSTRAP section), ask the user: the project's `.kaizen/` for an improvement to this project, `~/.kaizen/` for a personal or cross-project one. The previous-run lookups in 1b and 1e and the run-ID sequence below use this root.

Then generate a unique run ID: `YYYY-MM-DD-{profile-name}-{NNN}`
- Date: today's date
- Profile name: from the profile's `name` field
- Sequence: zero-padded 3-digit number, incremented from the highest existing run for this profile in the root's `runs/` directory. Start at `001` if no previous runs exist.

Create the run directory: `.kaizen/runs/{run-id}/` under the storage root.

#### 1b. Profile BOOTSTRAP Section and Continuity

If the profile body has a section whose heading starts with `## BOOTSTRAP`, read it and follow it now. Such a section may settle KPIs, epsilons, mutation targets or verify checks with the user (process-improvement does). The values it settles replace the frontmatter placeholders for this run.

Then look for the previous run of the same profile. If it has a `summary.json`, keep its `current` KPIs as `previous_final` for the manifest. This run's baseline is still measured fresh in 1e, because the target may have changed between runs; `previous_final` only lets reports connect the runs.

#### 1c. Source Collection

For each source declared in `initial_state.sources`:

| Source type | Collection method |
|-------------|-------------------|
| `session_transcripts` | `Read` files matching the `path` glob pattern |
| `config` | `Read` files in the declared path |
| `git_history` | Execute the declared `command` via `Bash` |
| `memory` | `Read` memory files matching the `path` glob |
| `user_provided` | Ask the user to provide or point to the data |

Collect and summarize findings. Do NOT load entire transcript contents into context — extract relevant statistics and patterns only.

#### 1d. Git Check

The mutation targets are final now, after overrides and the profile's BOOTSTRAP section. If they are inside a git work tree:

1. Run `git status --porcelain -- <each default target>`.
2. If it lists any file, show the list and ask the user to either commit or stash those changes (then re-check), or run without commits, in which case KEEP leaves each kept change in the working tree. Stage and commit nothing until the user answers. KEEP stages whole files, so a target holding the user's own uncommitted edits would carry them into a kaizen commit.
3. Offer a branch `kaizen/{run-id}`, so kept iterations stay off the user's current branch. Create and switch to it only if the user accepts.

Record the answers in the manifest's `git` block. Targets outside git are never committed.

#### 1e. Measurement Tool, Baseline and Verify Checks

If `measurement.tool_generation` is `true` in the profile:

1. Read the profile's `## MEASURE Phase` section and every `references/` file it names (profile-relative, see Step 0). `Read references/tool-scaffolding.md` for the interface contract.
2. **Reuse:** if the previous run of this profile has a measure script, its `manifest.json` has the same `profile_version` and the same KPI names, and its `adversarial_review` is not `flagged`, copy that script into this run directory. The same tool keeps cross-run numbers comparable.
3. Otherwise generate a measurement script in the declared `language` (Python or TypeScript). It MUST follow the interface contract: no arguments, settings read from `config.json` beside it, KPI JSON on stdout, errors as JSON on stderr with exit code 1, standard library only.
4. Write the script to `.kaizen/runs/{run-id}/measure.{py|ts}` and its `config.json` beside it.
5. Run it as in Phase 1 (MEASURE), checking the output against the resolved KPIs, and write the result to `.kaizen/runs/{run-id}/baseline.json`.

If `measurement.tool_generation` is `false`, measure inline during MEASURE (for `user-reported` or simple metrics) and write the first values to `baseline.json`.

**Verify checks:** turn each check in the profile's `## VERIFY Phase` section that a command can perform (build, tests, lint) into a command, confirm the list with the user, and run each once now. Record the checks that pass as `verify_checks` in the manifest. Report a check that already fails and leave it out: it cannot tell a good iteration from a bad one.

#### 1f. Adversarial Tool Review

Only when 1e generated a new script (a reused script was reviewed in its own run). Dispatch the **kaizen-reviewer** agent to validate it:

**Context to pass:**
- The resolved KPI definitions (names, formulas, directions)
- The generated measurement script source code
- The baseline output

**Review criteria:**
- Does the tool actually measure what the KPI formulas describe?
- Are there edge cases where the tool could produce misleading values?
- Is the output format compliant with the interface contract?
- Could the tool be gamed by trivial changes (e.g., renaming a file to change a count)?

Write the review to `.kaizen/runs/{run-id}/tool-review.md`. If the reviewer flags CRITICAL issues, fix and re-scaffold. If MEDIUM issues, note them and proceed with caution.

#### 1g. Manifest

Write `.kaizen/runs/{run-id}/manifest.json` with the fields listed in `references/run-state.md`. It holds the resolved configuration: `storage_root`, strategy, autonomy, budget, convergence, the resolved `kpis` (each with its effective `epsilon`), `mutation_targets`, `verify_checks`, `git`, `measure_script`, `profile_path`, `previous_run` and `previous_final`.

From here on the manifest, not the PROFILE.md frontmatter, is the source for KPIs, epsilons, targets and checks. Values settled with the user at BOOTSTRAP exist only there.

**Output:** Bootstrap complete. Environment ready for iteration loop.

### Step 2 — Iteration Loop

Each iteration runs the 8 phases below, in order.

Before each iteration, reconstruct optimal context:
- `manifest.json` — resolved KPIs, epsilons, targets, verify checks, strategy, autonomy
- The profile body section for the active phase, read from the manifest's `profile_path`
- Most recent `summary.json` or `baseline.json`
- Previous iteration's `decision.json` (if any)
- Current iteration number and remaining budget

**Do NOT carry forward full analysis text from previous iterations.** Each iteration starts clean.

---

#### Phase 1: MEASURE

Collect current KPI values:

- If a measurement script exists, run it yourself with `Bash` from the project root: `python3 {script}` or `npx tsx {script}`, with the Bash tool's timeout set to 60000 ms. Validate the output yourself: exit code 0, stdout parses as JSON, `kpis` is an object, and every automated KPI in the manifest has a numeric value. `references/tool-scaffolding.md` → Running the Tool has the checks and what to do when one fails.
- If `user-reported` KPIs: ask the user for current values
- If `hybrid`: run the script and ask the user for the non-automatable metrics

Write results to `.kaizen/runs/{run-id}/iterations/{NNN}/measurement.json` (schema in `references/run-state.md`).

**Failure mode:** If measurement tool crashes, log the error. If recoverable (typo, missing file), fix and retry once. If fundamental (missing runtime, permissions), abort the iteration and report to user.

---

#### Phase 2: ANALYZE

Dispatch **kaizen-analyzer** agent to interpret measurements:

**Context to pass:**
- Current measurement.json
- Baseline or previous iteration's measurement
- The resolved KPI definitions and directions, each with its epsilon and observational flag
- The relevant section from the profile's markdown body (## ANALYZE Phase)

**Expected output:**
- Per-KPI delta from baseline and from previous iteration
- Trend direction (improving, plateauing, regressing)
- Identification of the KPI with the most room for improvement
- Any anomalies or unexpected patterns

Write to `.kaizen/runs/{run-id}/iterations/{NNN}/analysis.md`

**Failure mode:** If analysis is inconclusive, note uncertainty and proceed. The DECIDE phase will handle ambiguity.

---

#### Phase 3: HYPOTHESIZE

Based on the analysis, form hypotheses about:
- **Root causes** — why are specific KPIs at their current levels?
- **Opportunities** — what changes would most likely improve the target KPIs?
- **Risks** — what could go wrong with potential changes?

Read the profile's `## HYPOTHESIZE Phase` section for domain-specific guidance.

This phase is inline (no subagent dispatch).

Write hypotheses to `.kaizen/runs/{run-id}/iterations/{NNN}/analysis.md` (append to analysis).

---

#### Phase 4: PROPOSE

Dispatch **kaizen-proposer** agent to generate a concrete change proposal:

**Context to pass:**
- Analysis and hypotheses from Phases 2-3
- Mutation targets from the manifest (defaults + any user overrides)
- The immutable list (MUST NOT be touched)
- Profile's `## PROPOSE Phase` section
- One line for every proposal reverted or rejected earlier in this run (`summary.json` → `reverted_proposals`), so that none is repeated, plus the user's note if the previous proposal was rejected

**Expected output:**
- A specific, minimal change plan
- Which files/assets to modify
- What the modification is (described precisely)
- Expected impact on KPIs (with reasoning)
- Confidence level (high/medium/low)

Write to `.kaizen/runs/{run-id}/iterations/{NNN}/proposal.md`

**Autonomy gate:** If autonomy is `supervised`, present the proposal to the user and wait for approval. If `hybrid(N)` and iteration count > N, also pause for approval. If `autonomous`, proceed directly.

**Rejected proposal:** if the user rejects it, skip APPLY and VERIFY and go to DECIDE with `no_proposal: true` and the user's reason in `user_note`. The note goes to the next proposer, and the rejected proposal joins the do-not-repeat list.

**Failure mode:** If the proposer cannot find a viable change, log "no viable proposal" and proceed to DECIDE (which will trigger the patience counter).

---

#### Phase 5: APPLY

Apply the proposed changes:

1. **Backup** — before any mutation, copy every file the proposal will modify into `.kaizen/runs/{run-id}/iterations/{NNN}/backup/`, preserving relative paths, and record in `backup/created.txt` every file the proposal will create. Never overwrite a backup copy that already exists, and never drop an entry from `created.txt`: in a resumed iteration they hold the only record of the pre-iteration state.

2. **Record outside edits** — if the manifest's `git.commits` is `true`, run `git status --porcelain -- <each file the proposal will modify or create>` and write every file it lists to `iterations/{NNN}/dirty-before-apply.txt` (empty if none; DECIDE copies it into decision.json as `dirty_before_apply`). Such a file holds edits this iteration did not make, so KEEP will not commit it.

3. **Verify immutability** — double-check that no proposed change touches files matching `mutation_targets.immutable` patterns. If a violation is detected, ABORT the iteration and flag to the user.

4. **Apply changes** — execute the mutations described in the proposal using `Edit` or `Write` tools. For each change:
   - Read the current file
   - Apply the modification
   - Verify the file is syntactically valid (if applicable — e.g., JSON, YAML)

5. **Generate diff** — diff each modified file against its backup copy, include each created file in full, and save the result as `.kaizen/runs/{run-id}/iterations/{NNN}/diff.patch`.

**Failure mode:** If any mutation fails partway through:
1. Restore every backed-up file and delete each file listed in `backup/created.txt` (full revert)
2. Log the failure
3. Proceed to DECIDE with `apply_failed: true`

---

#### Phase 6: VERIFY

1. Re-measure KPIs with the same method as Phase 1 and write `.kaizen/runs/{run-id}/iterations/{NNN}/verification.json` (same schema as measurement.json).
2. Run every command in the manifest's `verify_checks` with `Bash` (timeout 600000 ms), and perform the profile's `## VERIFY Phase` checks that need no command, such as the syntax validity of an edited config file.
3. If any check fails or times out, or a decision KPI is missing from the verification, the iteration fails verification: DECIDE records `verify_failed: true` and the check that failed, and REVERTs whatever the KPIs say. A KPI gain that breaks the build is not an improvement, and in `hybrid` or `autonomous` runs nobody else is watching.

**Failure mode:** If verification measurement fails, treat the iteration as inconclusive and revert (fail-safe).

---

#### Phase 7: DECIDE

`Read references/ratchet-strategies.md`

Compare verification KPIs against the pre-iteration measurement. Two rules apply to both strategies:
- **Decision KPIs only.** A KPI marked `observational: true` is measured, logged and reported, but never used to keep, revert or escalate.
- **Per-KPI epsilon.** Each KPI is judged against its own `epsilon` from the manifest, in the KPI's own unit; a KPI without one uses `convergence.epsilon`.

**Forced outcomes:** `apply_failed`, `verify_failed` or an immutable violation → **REVERT** without comparing KPIs. `no_proposal` → nothing was applied; record `revert`, which counts toward patience.

**Greedy strategy (single KPI):**
- If the target KPI moved in its desired direction by at least its epsilon: **KEEP**
- Otherwise: **REVERT**

**Multi-objective strategy:**
Apply the Pareto dominance check in `references/ratchet-strategies.md`:
- **KEEP** if: no decision KPI regressed by its epsilon or more AND at least one improved by at least its epsilon
- **ESCALATE** if: autonomy is not `autonomous`, at least one decision KPI improved by at least its epsilon, and another regressed by its epsilon or more. Present the trade-off, then record the user's answer as the decision, `keep` or `revert`, with `escalated: true`, and act on it as below
- **REVERT** otherwise

**Decision record:** write `.kaizen/runs/{run-id}/iterations/{NNN}/decision.json` (schema in `references/run-state.md`). Its `decision` is always `keep` or `revert`; an escalation is recorded by `escalated: true`.

**If REVERT:**
- Restore every modified file from `.kaizen/runs/{run-id}/iterations/{NNN}/backup/` and delete each file listed in `backup/created.txt` (after `no_proposal` there is nothing to restore). The backup holds the pre-iteration state, including uncommitted edits, so do not run `git checkout` on these files.
- If there was a proposal, including one the user rejected, add a one-line summary of it (target and change) to `reverted_proposals` in summary.json
- Increment the patience counter

**If KEEP:**
- If the manifest's `git.commits` is `true` and `dirty-before-apply.txt` is empty: stage only the files this iteration modified or created (`git add -- <files>`) and commit with message `kaizen({profile}): iteration {N} — {brief description}`. Record the commit hash.
- If a file was dirty before APPLY, do not commit: leave the change in the working tree, set `commit_skipped` in decision.json and tell the user. KEEP never commits an edit this iteration did not make.
- Reset the patience counter

---

#### Phase 8: LOG

Update the run's aggregate state:

1. Update `.kaizen/runs/{run-id}/summary.json` (create if first iteration; schema in `references/run-state.md`).

2. Present a brief iteration summary to the user:
   - Iteration N of M (budget)
   - Decision: kept/reverted
   - Current KPIs vs baseline (with improvement percentages), observational KPIs marked as such
   - Patience counter status

---

#### Loop Control

After LOG, evaluate stopping conditions:

| Condition | Trigger | Action |
|-----------|---------|--------|
| Convergence | patience counter >= `convergence.patience` | Stop — improvement has plateaued |
| Budget | iteration count >= `iteration_budget` | Stop — budget exhausted |
| User interrupt | User requests stop | Stop — graceful exit |
| Adversarial flag | Reviewer flags measurement integrity | Stop — investigation needed |
| No budget limit | `iteration_budget` is 0 | Continue indefinitely until convergence or interrupt |

If no stopping condition is met: **loop back to Phase 1** (MEASURE) for the next iteration. Reconstruct context before starting.

---

### Step 3 — Final Review Gate

When the loop stops (for any reason):

1. Dispatch **kaizen-reviewer** agent for adversarial review:

   **Context to pass:**
   - Profile's mission (name, description) and the resolved KPI definitions from the manifest
   - The path of the measurement script and its source code
   - summary.json (baseline → final KPIs)
   - The run directory path and the list of kept iterations, each with its `diff.patch` path
   - A sample of 2-3 iteration decision records (first, best, last)

   **Review criteria:**
   - Are the reported improvements genuine or measurement artifacts?
   - Do the applied changes align with the profile's stated mission?
   - Could any improvement be attributed to the measurement tool being gamed?
   - Were any immutable boundaries violated?

2. Write review to `.kaizen/runs/{run-id}/adversarial-review.md`

3. Update summary.json with `"adversarial_review": "passed|flagged"` and `"convergence_reason"`.

### Step 4 — Final Report

Present a comprehensive summary to the user:

- **Profile**: name and version
- **Run ID**: for future reference
- **Iterations**: completed / kept / reverted
- **KPI Results Table**:

  | KPI | Baseline | Final | Delta | Improvement |
  |-----|----------|-------|-------|-------------|
  | ... | ... | ... | ... | ... |

- **Convergence reason**: why the loop stopped
- **Adversarial review**: passed or flagged (with details if flagged)
- **Audit trail**: path to `.kaizen/runs/{run-id}/` for detailed inspection
- **Uncommitted changes**: kept iterations left in the working tree (run without commits, or `commit_skipped`)
- **Recommendations**: based on the adversarial review, suggest next steps (re-run with different focus, manual review of specific changes, schedule next run)

---

## 3. Progressive Disclosure

| Step | Documents to Read |
|------|-------------------|
| Step 0 | Profile's PROFILE.md (frontmatter only for config) |
| Step 1 | `references/run-state.md`; the profile's `## BOOTSTRAP` section, if any |
| Step 1b | Previous run's summary.json and manifest.json (if any) |
| Step 1e | Profile's MEASURE section and the `references/` it names (profile-relative); `references/tool-scaffolding.md`; profile's VERIFY section |
| Phase 4 (PROPOSE) | Profile's PROPOSE section from markdown body |
| Phase 6 (VERIFY) | Profile's VERIFY section |
| Phase 7 (DECIDE) | `references/ratchet-strategies.md` |
| Step 3 | (no additional — reviewer agent is self-contained) |

---

## 4. Subagent Dispatch Reference

| Phase | Agent | Model | Context Package |
|-------|-------|-------|-----------------|
| BOOTSTRAP (1f) | kaizen-reviewer | opus | KPI defs + tool source + baseline output |
| ANALYZE (2) | kaizen-analyzer | sonnet | Measurements + baseline + KPI defs with epsilons + profile ANALYZE section |
| PROPOSE (4) | kaizen-proposer | sonnet | Analysis + mutation targets + immutable list + profile PROPOSE section + reverted proposals |
| Final review (3) | kaizen-reviewer | opus | Profile mission + tool source + summary + run directory + kept iterations + sample decisions |

MEASURE and VERIFY run inline: the engine executes the script through `Bash` and checks its JSON, because the result is fully determined by the script. See `references/subagent-dispatch.md` for detailed context packaging instructions per agent.

---

## 5. Context Management Protocol

**Between iterations:** After Phase 8 (LOG), before the next Phase 1 (MEASURE):

1. The current iteration's detailed analysis, proposals, and reasoning are written to disk (the audit trail).
2. The next iteration starts with **reconstructed minimal context**:
   - `manifest.json` — the resolved configuration, including values settled with the user at BOOTSTRAP
   - Current summary.json (aggregate state, including `reverted_proposals`)
   - Previous iteration's decision.json
   - Current iteration number and remaining budget
3. Full history is available on disk but NOT loaded into context unless specifically needed.

This ensures the engine can run many iterations without context exhaustion.

---

## 6. Error Recovery

| Failure | Recovery |
|---------|----------|
| Measurement tool crash (recoverable) | Fix typo/path, retry once |
| Measurement tool crash (fundamental) | Abort iteration, report to user |
| Measurement tool hangs (> 60 s) | The Bash timeout stops it; abort the iteration and report to user |
| Partial KPI output (some missing) | Log a warning and proceed with the KPIs present; in VERIFY a missing decision KPI fails verification |
| Partial APPLY failure | Full revert from backup |
| Session ended during APPLY | On resume, restore from `backup/` and delete the files in `created.txt`, then run APPLY again (`references/run-state.md` → Resume) |
| Verify check fails or times out | REVERT with `verify_failed: true` |
| Subagent dispatch failure | Retry once, then run phase inline |
| Target file dirty before APPLY | KEEP leaves the change uncommitted and sets `commit_skipped` |
| Git commit fails on KEEP | Leave the change in the working tree, note it in decision.json, and tell the user |
| summary.json corrupted | Rebuild from iteration records |

---

## 7. Integration

This skill is the core of the kaizen plugin. It is invoked by:
- `/kaizen` command — primary entry point
- Direct skill activation via trigger phrases

Its output (audit trail in `.kaizen/runs/`) is consumed by:
- **kaizen-report** — reads summary.json files to show trends and history
- **kaizen-profile-designer** — uses the profile-template.md reference
