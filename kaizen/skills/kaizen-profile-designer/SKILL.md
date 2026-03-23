---
name: kaizen-profile-designer
description: "Interactive workflow to create custom kaizen improvement profiles. Guides users through KPI definition, data source identification, mutation scope selection, autonomy configuration, and profile validation. Use when user says 'create kaizen profile', 'design improvement loop', 'new kaizen profile', 'custom profile', 'custom kaizen', 'define improvement target', or wants to create a new improvement loop for a domain not covered by the bundled profiles."
---

# Kaizen Profile Designer — Custom Profile Creation

## 1. Overview

This skill guides the user through creating a custom PROFILE.md file for the kaizen engine. It produces a validated, ready-to-use profile that follows the engine's template format.

Output: `profiles/{name}/PROFILE.md` in the kaizen plugin directory, or a custom location specified by the user.

## 2. Pipeline

### Step 1 — Understand the Improvement Target

Interview the user to understand what they want to improve:

1. **What is the target?** A process, codebase, configuration, workflow, or system
2. **What's the pain point?** What's not working well, what triggered this
3. **What does success look like?** Concrete description of the improved state
4. **What's the scope?** Which files, systems, or processes are involved
5. **What's off-limits?** What must NOT be changed

### Step 2 — Define KPIs

`Read references/profile-checklist.md`

Help the user define 1-4 measurable KPIs:

For each KPI:
1. **Name** — short, descriptive (e.g., `build_time`, `error_rate`)
2. **Description** — what it measures in plain language
3. **Direction** — maximize or minimize
4. **Unit** — ratio, percentage, count, seconds, custom
5. **Measurement method** — automated, user-reported, or hybrid
6. **Formula** — human-readable description of how to calculate

**Guide the user with questions:**
- "If this improvement works, what number would change?"
- "How would you measure that? Can it be automated?"
- "Is there a trade-off KPI we should watch?" (suggest multi-objective)

### Step 3 — Identify Data Sources

Based on the KPIs, determine what data the engine needs:

1. **Source type**: files, git history, session logs, API output, user input
2. **Source path**: where to find the data
3. **Collection method**: automatic (Read/Grep/Bash) or manual (user provides)

### Step 4 — Define Mutation Scope

Determine what the engine is allowed to modify:

1. **Default targets** — files/patterns that are the primary improvement surface
2. **Immutable targets** — files/patterns that MUST NOT be touched (tests, git, dependencies)

**Guide with questions:**
- "Which files contain the things you want to improve?"
- "Are there files that must never be changed? (tests, configs, etc.)"

### Step 5 — Configure Engine Behavior

1. **Strategy** — greedy (single KPI) or multi-objective (multiple KPIs)
   - If 1 KPI defined: recommend greedy
   - If 2+ KPIs: recommend multi-objective, explain Pareto dominance

2. **Autonomy** — supervised, autonomous, or hybrid(N)
   - For first-time profiles: recommend supervised
   - For well-understood domains: suggest hybrid(3)

3. **Iteration budget** — how many iterations to allow (recommend 5-10)

4. **Convergence** — epsilon and patience values
   - Help calibrate epsilon to the KPI's scale

5. **Measurement tool** — should the engine auto-generate a measurement tool?
   - If KPIs are automatable: recommend `tool_generation: true`
   - If KPIs are user-reported: set `tool_generation: false`
   - Language preference: Python or TypeScript

### Step 6 — Generate Profile

1. Assemble the PROFILE.md using the profile template
2. Fill in all frontmatter fields from Steps 2-5
3. Write phase instructions in the markdown body:
   - MEASURE: how to collect KPI data
   - ANALYZE: how to interpret measurements
   - HYPOTHESIZE: common root causes in this domain
   - PROPOSE: appropriate change types and constraints
   - APPLY: special considerations for applying changes
   - VERIFY: additional verification beyond KPI re-measurement

4. Present the complete profile to the user for review

### Step 7 — Validate and Save

1. Verify all required frontmatter fields are present
2. Verify KPI definitions are complete (name, direction, unit)
3. Verify mutation targets don't overlap with immutable patterns
4. Save to the specified location
5. Suggest the user run `/kaizen {profile-name}` to start the loop

## 3. Progressive Disclosure

| Step | Documents to Read |
|------|-------------------|
| Step 2 | `references/profile-checklist.md` |
| Step 6 | Profile template from the kaizen-engine skill's reference directory (profile-template.md) |
