# Subagent Dispatch Protocol

## Overview

The kaizen engine dispatches 4 specialized agents during the improvement loop. Each agent receives a **minimal, tailored context package** — only the information needed for its phase. This prevents context bloat and ensures agents reason about their specific task.

## Agent Registry

| Agent | Model | Invocation Points | Purpose |
|-------|-------|--------------------|---------|
| kaizen-measurer | haiku | MEASURE, VERIFY | Run measurement tools, collect KPIs |
| kaizen-analyzer | sonnet | ANALYZE | Interpret data, find patterns |
| kaizen-proposer | sonnet | PROPOSE | Generate change proposals |
| kaizen-reviewer | opus | BOOTSTRAP, Final Review | Adversarial validation |

## Context Packaging

### kaizen-measurer (haiku)

**Dispatch at:** Phase 1 (MEASURE) and Phase 6 (VERIFY)

**Context package:**
```
You are the kaizen-measurer agent. Run the measurement tool and return KPI values.

Measurement script: {path_to_measure.py_or_ts}
Run directory: {path_to_run_dir}
Expected KPIs: {list of kpi names from profile}
Output file: {path_to_measurement.json_or_verification.json}

Instructions:
1. Execute the measurement script: `python {script_path}` or `npx tsx {script_path}`
2. Capture stdout as the measurement result
3. If exit code is non-zero, capture stderr for error diagnosis
4. Write the result to the output file path
5. Return the KPI values and any errors encountered
```

**Do NOT include:** Analysis context, previous proposals, profile body, hypothesis text.

### kaizen-analyzer (sonnet)

**Dispatch at:** Phase 2 (ANALYZE)

**Context package:**
```
You are the kaizen-analyzer agent. Compare current measurements against the reference point and identify improvement opportunities.

Profile KPIs:
{for each kpi: name, description, direction, unit}

Current measurement:
{contents of measurement.json}

Reference measurement (baseline or previous iteration):
{contents of baseline.json or previous measurement.json}

Profile analysis guidance:
{contents of the ## ANALYZE Phase section from PROFILE.md body}

Instructions:
1. Calculate per-KPI deltas (absolute and percentage)
2. Assess trend direction for each KPI
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
{list of defaults from profile, with any user overrides}

Immutable targets (you MUST NOT modify these):
{list of immutable patterns from profile}

Profile proposal guidance:
{contents of the ## PROPOSE Phase section from PROFILE.md body}

Previous reverted proposal (DO NOT repeat this approach):
{contents of previous iteration's proposal.md, if it was reverted; "None" if first iteration or previous was kept}

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

**Dispatch at:** BOOTSTRAP (Step 1e) and Final Review (Step 3)

#### BOOTSTRAP dispatch:
```
You are the kaizen-reviewer agent performing adversarial review of a measurement tool.

Profile KPI definitions:
{for each kpi: name, description, direction, formula}

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
  KPIs: {list with directions}

Measurement tool source:
{full contents of measure.py or measure.ts}

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
4. Were immutable boundaries respected throughout?
5. Is the convergence reason appropriate?

Provide a verdict: PASSED (improvements are genuine) or FLAGGED (concerns identified, with details).
```

## Dispatch Mechanics

Use the `Agent` tool with:
- `subagent_type`: the agent name (e.g., "kaizen-measurer")
- `model`: as specified in the registry
- `prompt`: the context package above, with placeholders filled
- `description`: brief label (e.g., "Measure KPIs for iteration 3")

## Failure Handling

If an agent dispatch fails (timeout, error, unexpected output):

1. **First failure:** Retry the dispatch once with the same context
2. **Second failure:** Fall back to running the phase inline (without subagent)
3. Log the failure in the iteration record
4. If the reviewer agent fails, proceed but note in summary that adversarial review was skipped
