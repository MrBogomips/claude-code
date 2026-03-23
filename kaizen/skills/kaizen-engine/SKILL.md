---
name: kaizen-engine
description: "Recursive improvement loop engine inspired by karpathy/autoresearch. Orchestrates continuous improvement via Sequential Thinking MCP with 8-phase iterations (MEASURE, ANALYZE, HYPOTHESIZE, PROPOSE, APPLY, VERIFY, DECIDE, LOG). Supports greedy and multi-objective ratcheting strategies with configurable autonomy levels. Use when the user says 'run kaizen', 'kaizen loop', 'improve', 'optimization loop', 'continuous improvement', 'recursive improvement', 'iterative optimization', 'run improvement profile', or wants to iteratively improve code, configuration, or processes against measurable KPIs. Also activates when user references a specific profile name like 'claude-code-usage', 'code-refactoring', or 'process-improvement'. Requires **~~sequential-thinking** connector."
---

# Kaizen Engine — Recursive Improvement Loop Orchestrator

## 1. Overview

The kaizen engine runs recursive improvement loops against measurable KPIs. It reads a **profile** (PROFILE.md) that defines what to improve, how to measure, and what to mutate, then executes iterative cycles until convergence, budget exhaustion, or user interrupt.

**Architecture:** Engine + Profiles. The engine is generic; profiles are domain-specific.

**Connector requirement:** This skill requires **~~sequential-thinking** for loop orchestration. Without it, the skill cannot function. Direct the user to the README for setup instructions.

**Storage:** Audit logs are written to `.kaizen/runs/` at the improvement target location:
- Project-level improvements: `.kaizen/` at project root
- User-level improvements: `~/.kaizen/`

---

## 2. Pipeline

### Step 0 — Profile Resolution

Determine which profile to load:

1. If the user specifies a profile name (e.g., `claude-code-usage`), look for it in:
   - `profiles/{name}/PROFILE.md` within this plugin directory
   - A custom path provided by the user
2. If no profile is specified, present the available bundled profiles and ask the user to choose:
   - **claude-code-usage** — analyze and improve Claude Code tool/skill usage patterns
   - **code-refactoring** — recursively improve code quality metrics
   - **process-improvement** — design and run kaizen loops for business processes
3. Parse the PROFILE.md YAML frontmatter to extract configuration:
   - `name`, `version`, `strategy`, `autonomy`
   - `kpis[]` — name, description, direction, unit, measurement_method, formula
   - `initial_state.sources[]` — data sources for baseline capture
   - `mutation_targets.defaults[]` and `mutation_targets.immutable[]`
   - `convergence.epsilon`, `convergence.patience`
   - `iteration_budget`
   - `measurement.tool_generation`, `measurement.language`
4. Ask the user for any **scope overrides**:
   - Narrow or expand mutation targets
   - Adjust iteration budget
   - Override autonomy level for this run

**Output:** Resolved profile configuration ready for BOOTSTRAP.

### Step 1 — BOOTSTRAP

Prepare the improvement environment before the first iteration.

#### 1a. Run ID Generation

Generate a unique run ID: `YYYY-MM-DD-{profile-name}-{NNN}`
- Date: today's date
- Profile name: from the profile's `name` field
- Sequence: zero-padded 3-digit number, incremented from the highest existing run for this profile in the `.kaizen/runs/` directory. Start at `001` if no previous runs exist.

Create the run directory: `.kaizen/runs/{run-id}/`

#### 1b. Continuity Check

Look for previous runs of the same profile in `.kaizen/runs/`:
- If a previous `summary.json` exists, read it. The `final` KPIs from the most recent run become the **inherited baseline**. Skip fresh source collection — we already know the previous state.
- If no previous runs exist, proceed to fresh source collection.

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

#### 1d. Measurement Tool Scaffolding

If `measurement.tool_generation` is `true` in the profile:

1. `Read references/tool-scaffolding.md` for the generation template and interface contract
2. Generate a measurement script in the declared `language` (Python or TypeScript)
3. The script MUST:
   - Accept no arguments (reads its own config from the run directory)
   - Output JSON to stdout: `{"kpis": {"kpi_name": numeric_value, ...}, "metadata": {"timestamp": "ISO-8601", "profile": "name", "details": {...}}}`
   - Handle errors gracefully (exit code 1 + JSON error message to stderr)
   - Be self-contained (no external dependencies beyond the standard library and common tools like `git`)
4. Write the script to `.kaizen/runs/{run-id}/measure.{py|ts}`
5. Run it to capture the **baseline snapshot**
6. Write baseline to `.kaizen/runs/{run-id}/baseline.json`

If `measurement.tool_generation` is `false`, measurement is handled inline by the engine during the MEASURE phase (for `user-reported` or simple metrics).

#### 1e. Adversarial Tool Review

Dispatch the **kaizen-reviewer** agent to validate the generated measurement tool:

**Context to pass:**
- The profile's KPI definitions (names, formulas, directions)
- The generated measurement script source code
- The baseline output

**Review criteria:**
- Does the tool actually measure what the KPI formulas describe?
- Are there edge cases where the tool could produce misleading values?
- Is the output format compliant with the interface contract?
- Could the tool be gamed by trivial changes (e.g., renaming a file to change a count)?

If the reviewer flags CRITICAL issues, fix and re-scaffold. If MEDIUM issues, note them and proceed with caution.

#### 1f. Manifest

Write `.kaizen/runs/{run-id}/manifest.json`:
```json
{
  "run_id": "{run-id}",
  "profile": "{profile-name}",
  "profile_version": "{version}",
  "started_at": "ISO-8601",
  "strategy": "greedy|multi-objective",
  "autonomy": "autonomous|supervised|hybrid(N)",
  "iteration_budget": N,
  "convergence": {"epsilon": 0.02, "patience": 3},
  "scope_overrides": {...},
  "inherited_baseline": true|false,
  "previous_run": "{run-id}"|null
}
```

**Output:** Bootstrap complete. Environment ready for iteration loop.

### Step 2 — Iteration Loop

Each iteration is orchestrated as a **Sequential Thinking chain** via `~~sequential-thinking`. The chain comprises 8 thoughts, one per phase.

Before each iteration, reconstruct optimal context:
- Profile frontmatter (KPIs, strategy, mutation targets)
- Current profile markdown body section for the active phase
- Most recent `summary.json` or `baseline.json`
- Previous iteration's `decision.json` (if any)
- Current iteration number and remaining budget

**Do NOT carry forward full analysis text from previous iterations.** Each iteration starts clean.

---

#### Phase 1: MEASURE

**Sequential Thinking — Thought 1**

Collect current KPI values:

- If measurement tool exists: dispatch **kaizen-measurer** agent to run it
  - Pass: path to measurement script, run directory
  - Expect: JSON output with KPI values
- If `user-reported` KPIs: ask the user for current values
- If `hybrid`: run automated tool + ask user for non-automatable metrics

Write results to `.kaizen/runs/{run-id}/iterations/{NNN}/measurement.json`:
```json
{
  "iteration": N,
  "timestamp": "ISO-8601",
  "kpis": {"kpi_name": numeric_value, ...},
  "source": "automated|user-reported|hybrid"
}
```

**Failure mode:** If measurement tool crashes, log the error. If recoverable (typo, missing file), fix and retry once. If fundamental (missing runtime, permissions), abort the iteration and report to user.

---

#### Phase 2: ANALYZE

**Sequential Thinking — Thought 2**

Dispatch **kaizen-analyzer** agent to interpret measurements:

**Context to pass:**
- Current measurement.json
- Baseline or previous iteration's measurement
- Profile's KPI definitions and directions
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

**Sequential Thinking — Thought 3**

Based on the analysis, form hypotheses about:
- **Root causes** — why are specific KPIs at their current levels?
- **Opportunities** — what changes would most likely improve the target KPIs?
- **Risks** — what could go wrong with potential changes?

Read the profile's `## HYPOTHESIZE Phase` section for domain-specific guidance.

This phase is inline (no subagent dispatch) — it uses the Sequential Thinking chain's reasoning capability.

Write hypotheses to `.kaizen/runs/{run-id}/iterations/{NNN}/analysis.md` (append to analysis).

---

#### Phase 4: PROPOSE

**Sequential Thinking — Thought 4**

Dispatch **kaizen-proposer** agent to generate a concrete change proposal:

**Context to pass:**
- Analysis and hypotheses from Phases 2-3
- Profile's mutation targets (defaults + any user overrides)
- Profile's immutable list (MUST NOT be touched)
- Profile's `## PROPOSE Phase` section
- Previous iteration's proposal and decision (if the previous change was reverted, avoid repeating it)

**Expected output:**
- A specific, minimal change plan
- Which files/assets to modify
- What the modification is (described precisely)
- Expected impact on KPIs (with reasoning)
- Confidence level (high/medium/low)

Write to `.kaizen/runs/{run-id}/iterations/{NNN}/proposal.md`

**Autonomy gate:** If autonomy is `supervised`, present the proposal to the user and wait for approval. If `hybrid(N)` and iteration count > N, also pause for approval. If `autonomous`, proceed directly.

**Failure mode:** If the proposer cannot find a viable change, log "no viable proposal" and proceed to DECIDE (which will trigger the patience counter).

---

#### Phase 5: APPLY

**Sequential Thinking — Thought 5**

Apply the proposed changes:

1. **Backup** — before any mutation, create backups of all files in mutation scope:
   `.kaizen/runs/{run-id}/iterations/{NNN}/backup/`
   Copy each file that will be modified, preserving relative paths.

2. **Verify immutability** — double-check that no proposed change touches files matching `mutation_targets.immutable` patterns. If a violation is detected, ABORT the iteration and flag to the user.

3. **Apply changes** — execute the mutations described in the proposal using `Edit` or `Write` tools. For each change:
   - Read the current file
   - Apply the modification
   - Verify the file is syntactically valid (if applicable — e.g., JSON, YAML)

4. **Generate diff** — capture the changes:
   - If targets are under git: `git diff` → save as `.kaizen/runs/{run-id}/iterations/{NNN}/diff.patch`
   - If not under git: generate a unified diff from the backup copies

**Failure mode:** If any mutation fails partway through:
1. Restore ALL files from backup (full revert)
2. Log the failure
3. Proceed to DECIDE with `apply_failed: true`

---

#### Phase 6: VERIFY

**Sequential Thinking — Thought 6**

Re-measure KPIs after the change (same method as Phase 1):
- If measurement tool exists: dispatch **kaizen-measurer** agent
- If user-reported: ask user for updated values
- If hybrid: both

Write to `.kaizen/runs/{run-id}/iterations/{NNN}/verification.json` (same schema as measurement.json).

**Failure mode:** If verification measurement fails, treat the iteration as inconclusive and revert (fail-safe).

---

#### Phase 7: DECIDE

**Sequential Thinking — Thought 7**

`Read references/ratchet-strategies.md`

Compare verification KPIs against the pre-iteration measurement:

**Greedy strategy (single KPI):**
- If the target KPI improved by at least `epsilon`: **KEEP**
- Otherwise: **REVERT**

**Multi-objective strategy:**
Apply Pareto dominance check:
- **KEEP** if: no KPI regressed beyond epsilon AND at least one KPI improved by at least epsilon
- **REVERT** if: any KPI regressed beyond epsilon
- **ESCALATE** if: autonomy is not `autonomous` and there's a trade-off (one improved, another regressed within epsilon) — present to user for judgment

**Decision record:**
Write to `.kaizen/runs/{run-id}/iterations/{NNN}/decision.json`:
```json
{
  "iteration": N,
  "decision": "keep|revert|escalate",
  "strategy": "greedy|multi-objective",
  "kpi_deltas": {"kpi_name": {"before": X, "after": Y, "delta": Z, "direction": "improved|regressed|unchanged"}},
  "reasoning": "...",
  "apply_failed": false,
  "no_proposal": false
}
```

**If REVERT:**
- Restore all files from `.kaizen/runs/{run-id}/iterations/{NNN}/backup/`
- If targets are under git: `git checkout` the modified files
- Increment the patience counter

**If KEEP:**
- If targets are under git: stage and commit with message `kaizen({profile}): iteration {N} — {brief description}`
- Reset the patience counter

---

#### Phase 8: LOG

**Sequential Thinking — Thought 8**

Update the run's aggregate state:

1. Update `.kaizen/runs/{run-id}/summary.json` (create if first iteration):
```json
{
  "profile": "{name}",
  "run_id": "{run-id}",
  "started_at": "ISO-8601",
  "updated_at": "ISO-8601",
  "iterations_completed": N,
  "iterations_kept": K,
  "iterations_reverted": R,
  "baseline": {"kpi_name": value, ...},
  "current": {"kpi_name": value, ...},
  "improvement": {"kpi_name": "+XX%", ...},
  "patience_counter": P,
  "convergence_reason": null|"patience_exceeded"|"budget_exhausted"|"user_stopped"|"adversarial_flag"
}
```

2. Present a brief iteration summary to the user:
   - Iteration N of M (budget)
   - Decision: kept/reverted
   - Current KPIs vs baseline (with improvement percentages)
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
   - Profile's mission (name, description, KPI definitions)
   - The measurement tool source code
   - summary.json (baseline → final KPIs)
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
- **Recommendations**: based on the adversarial review, suggest next steps (re-run with different focus, manual review of specific changes, schedule next run)

---

## 3. Progressive Disclosure

| Step | Documents to Read |
|------|-------------------|
| Step 0 | Profile's PROFILE.md (frontmatter only for config) |
| Step 1b | Previous run's summary.json (if continuity) |
| Step 1d | `references/tool-scaffolding.md` |
| Phase 4 (PROPOSE) | Profile's PROPOSE section from markdown body |
| Phase 7 (DECIDE) | `references/ratchet-strategies.md` |
| Step 3 | (no additional — reviewer agent is self-contained) |

---

## 4. Subagent Dispatch Reference

| Phase | Agent | Model | Context Package |
|-------|-------|-------|-----------------|
| BOOTSTRAP (1e) | kaizen-reviewer | opus | KPI defs + tool source + baseline output |
| MEASURE (1) | kaizen-measurer | haiku | Measurement script path + run directory |
| ANALYZE (2) | kaizen-analyzer | sonnet | Measurements + baseline + KPI defs + profile ANALYZE section |
| PROPOSE (4) | kaizen-proposer | sonnet | Analysis + mutation targets + immutable list + profile PROPOSE section |
| VERIFY (6) | kaizen-measurer | haiku | Measurement script path + run directory |
| Final review (3) | kaizen-reviewer | opus | Profile mission + tool source + summary + sample decisions |

See `references/subagent-dispatch.md` for detailed context packaging instructions per agent.

---

## 5. Context Management Protocol

**Between iterations:** After Phase 8 (LOG), before the next Phase 1 (MEASURE):

1. The current iteration's detailed analysis, proposals, and reasoning are written to disk (the audit trail).
2. The next iteration starts with **reconstructed minimal context**:
   - Profile frontmatter (static — reloaded from PROFILE.md)
   - Current summary.json (aggregate state)
   - Previous iteration's decision.json (to avoid repeating reverted proposals)
   - Current iteration number and remaining budget
3. Full history is available on disk but NOT loaded into context unless specifically needed.

This ensures the engine can run many iterations without context exhaustion.

---

## 6. Error Recovery

| Failure | Recovery |
|---------|----------|
| Measurement tool crash (recoverable) | Fix typo/path, retry once |
| Measurement tool crash (fundamental) | Abort iteration, report to user |
| Partial APPLY failure | Full revert from backup |
| Subagent dispatch failure | Retry once, then run phase inline |
| Sequential Thinking unavailable | CRITICAL — skill cannot function. Direct user to README for setup. |
| Git operations fail | Fall back to file-backup-based revert |
| summary.json corrupted | Rebuild from iteration records |

---

## 7. Integration

This skill is the core of the kaizen plugin. It is invoked by:
- `/kaizen` command — primary entry point
- Direct skill activation via trigger phrases

Its output (audit trail in `.kaizen/runs/`) is consumed by:
- **kaizen-report** — reads summary.json files to show trends and history
- **kaizen-profile-designer** — uses the profile-template.md reference
