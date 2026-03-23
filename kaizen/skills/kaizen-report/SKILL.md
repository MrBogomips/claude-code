---
name: kaizen-report
description: "View improvement history and KPI trends from kaizen runs. Reads .kaizen/runs/ audit trail to show cross-run improvement trajectories, diminishing returns detection, and formatted KPI reports with delta tables. Use when user says 'kaizen report', 'kaizen history', 'improvement history', 'show kaizen results', 'KPI trends', 'how is improvement going', 'kaizen status', or wants to review past improvement loop outcomes."
---

# Kaizen Report — Improvement History & Trends

## 1. Overview

This skill reads the `.kaizen/runs/` audit trail and presents improvement history, KPI trends, and actionable insights. It works with any profile's audit data.

## 2. Pipeline

### Step 1 — Locate Audit Data

Search for `.kaizen/runs/` directories:
1. Check current project root: `.kaizen/runs/`
2. Check user home: `~/.kaizen/runs/`
3. If a specific profile is requested, filter to runs matching that profile name

If no runs are found, inform the user and suggest running `/kaizen` first.

### Step 2 — Load Run Summaries

For each run directory found:
1. Read `summary.json`
2. Extract: profile name, run ID, start date, iterations completed/kept/reverted, baseline KPIs, final KPIs, improvement percentages, convergence reason, adversarial review status
3. Sort runs chronologically

### Step 3 — Present Report

#### Single Profile Report

If runs are for a single profile (or user requested a specific profile):

```markdown
# Kaizen Report: {profile-name}

## Overview
- **Total runs:** {count}
- **Date range:** {first run date} → {latest run date}
- **Total iterations:** {sum across runs} ({kept} kept, {reverted} reverted)

## KPI Trajectory

| Run | Date | {KPI 1} | {KPI 2} | ... | Iterations | Result |
|-----|------|---------|---------|-----|------------|--------|
| 001 | ... | baseline → final (Δ%) | ... | ... | N (K kept) | converged/budget/stopped |
| 002 | ... | baseline → final (Δ%) | ... | ... | N (K kept) | converged/budget/stopped |

## Cumulative Improvement
- **{KPI 1}:** {first baseline} → {latest final} ({total Δ%} total improvement)
- **{KPI 2}:** {first baseline} → {latest final} ({total Δ%} total improvement)

## Trend Analysis
- **Rate of improvement:** [accelerating / steady / diminishing returns]
- **Diminishing returns alert:** [if last 2+ runs had few kept iterations, flag this]
- **Recommendation:** [continue / shift focus / review profile]

## Adversarial Review Status
| Run | Verdict |
|-----|---------|
| ... | passed/flagged |
```

#### Multi-Profile Summary

If runs span multiple profiles:

```markdown
# Kaizen Overview — All Profiles

| Profile | Runs | Last Run | Best KPI Improvement | Status |
|---------|------|----------|---------------------|--------|
| {name} | N | {date} | {best Δ%} | active/converged |
```

### Step 4 — Diminishing Returns Detection

For each KPI across sequential runs:
1. Calculate the improvement delta per run
2. If the last 3+ deltas are decreasing in magnitude: flag as **diminishing returns**
3. If the last 2+ runs converged with patience_exceeded: suggest shifting focus

Present recommendation:
- "tool_efficiency has improved from 0.45 to 0.89 over 4 runs. The last 2 runs gained only +0.02 each. Consider shifting focus to another KPI or accepting the current level."

### Step 5 — Drill-Down (Optional)

If the user asks about a specific run:
1. Read the full `summary.json` and `adversarial-review.md`
2. List each iteration with its decision (keep/revert) and KPI deltas
3. Show the proposals that were kept (from `proposal.md` files)
4. Present the adversarial review findings
