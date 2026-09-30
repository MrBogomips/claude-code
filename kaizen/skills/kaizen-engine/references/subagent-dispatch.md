# Subagent Dispatch Protocol

## Overview

The kaizen engine dispatches 3 specialized agents during the improvement loop. Each agent receives a **minimal, tailored context package** — only the information needed for its phase. This prevents context bloat and ensures agents reason about their specific task.

MEASURE and VERIFY dispatch no agent. Running the measure script and checking its JSON is fully determined by the script, so the engine does it through `Bash` (see `tool-scaffolding.md` → Running the Tool), which saves two model calls per iteration.

## Agent Registry

| Agent | Model | Invocation Points | Purpose |
|-------|-------|--------------------|---------|
| kaizen-analyzer | sonnet | ANALYZE | Interpret data, find patterns |
| kaizen-proposer | sonnet | PROPOSE | Generate change proposals |
| kaizen-reviewer | opus | BOOTSTRAP, Final Review | Adversarial validation |

## Context Packaging

### kaizen-analyzer (sonnet)

**Dispatch at:** Phase 2 (ANALYZE)

**Context package:**
```
You are the kaizen-analyzer agent. Compare current measurements against the reference point and identify improvement opportunities.

Profile KPIs:
{for each kpi in manifest.json: name, description, direction, unit, epsilon, observational}

Current measurement:
{contents of measurement.json}

Reference measurement (baseline or previous iteration):
{contents of baseline.json or previous measurement.json}

Profile analysis guidance:
{contents of the ## ANALYZE Phase section from PROFILE.md body}

Instructions:
1. Calculate per-KPI deltas (absolute and percentage); a delta smaller than the KPI's epsilon counts as unchanged
2. Assess trend direction for each KPI; mark observational KPIs, which are tracked but never decide an iteration
3. Rank KPIs by room for improvement
4. Flag any anomalies or unexpected patterns
5. Write your analysis as structured markdown
```

**Do NOT include:** Mutation targets, previous proposals, the measurement tool source code.

### kaizen-proposer (sonnet)

**Dispatch at:** Phase 4 (PROPOSE)

**Context package:**
```
You are the kaizen-proposer agent. Generate a concrete, minimal improvement proposal.

Analysis and hypotheses:
{contents of iterations/{NNN}/analysis.md}

Mutation targets (you MAY modify these):
{mutation_targets.defaults from manifest.json, which includes any user overrides}

Immutable targets (you MUST NOT modify these):
{mutation_targets.immutable from manifest.json}

Profile proposal guidance:
{contents of the ## PROPOSE Phase section from PROFILE.md body}

Proposals reverted or rejected earlier in this run (DO NOT repeat any of them):
{summary.json reverted_proposals, one line each; "None" if the list is empty}

User note on the previous proposal:
{decision.json user_note of the previous iteration, if the user rejected it; otherwise "None"}

Instructions:
1. Based on the analysis, identify the highest-impact change
2. Verify the change targets only mutable files
3. Describe the change precisely (which file, what modification)
4. Estimate expected KPI impact with reasoning
5. Assess confidence level (high/medium/low)
6. If you cannot find a viable change, report "no viable proposal"
```

**Do NOT include:** Measurement tool source, full iteration history, other agents' prompts.

### kaizen-reviewer (opus)

**Dispatch at:** BOOTSTRAP (Step 1f, only for a newly generated script) and Final Review (Step 3)

#### BOOTSTRAP dispatch:
```
You are the kaizen-reviewer agent performing adversarial review of a measurement tool.

Profile KPI definitions:
{for each KPI as resolved at BOOTSTRAP: name, description, direction, formula}

Measurement tool source code:
{full contents of measure.py or measure.ts}

Baseline measurement output:
{contents of baseline.json}

Review criteria:
1. Does the tool faithfully implement each KPI formula?
2. Are there edge cases where the tool produces misleading values?
3. Is the JSON output format compliant with the interface contract?
4. Could the tool be gamed by trivial changes (e.g., renaming to change counts)?
5. Are there hardcoded assumptions that could break?

Rate each finding as: CRITICAL (must fix), MEDIUM (note and monitor), LOW (acceptable).
```

#### Final Review dispatch:
```
You are the kaizen-reviewer agent performing final adversarial review of a completed kaizen run.

Profile mission:
  Name: {name}
  Description: {description}
  KPIs: {list from manifest.json with directions, epsilons and observational flags}

Measurement tool: {path of measure.py or measure.ts}
{full contents of the script}

Run directory: {path to .kaizen/runs/{run-id}/}
Kept iterations: {for each kept iteration: number and path of its diff.patch; "None" if nothing was kept}

Run summary:
{contents of summary.json}

Sample iteration decisions:
  First: {decision.json from iteration 001}
  Best improvement: {decision.json from the iteration with largest positive delta}
  Last: {decision.json from final iteration}

Review criteria:
1. Are the reported improvements genuine or measurement artifacts?
2. Do the applied changes align with the profile's stated mission?
3. Could any improvement be attributed to gaming the measurement tool?
4. Were immutable boundaries respected throughout? Read the diff.patch of every kept iteration.
5. Is the convergence reason appropriate?

Provide a verdict: PASSED (improvements are genuine) or FLAGGED (concerns identified, with details).
```

## Dispatch Mechanics

Use the `Agent` tool with:
- `subagent_type`: the entry in the available agent list whose name ends with the agent name (plugin agents are listed with a `kaizen:` namespace prefix)
- `model`: as specified in the registry
- `prompt`: the context package above, with placeholders filled
- `description`: brief label (e.g., "Analyze KPIs for iteration 3")

## Failure Handling

If an agent dispatch fails (timeout, error, unexpected output):

1. **First failure:** Retry the dispatch once with the same context
2. **Second failure:** Fall back to running the phase inline (without subagent)
3. Log the failure in the iteration record
4. If the reviewer agent fails, proceed but note in summary that adversarial review was skipped
