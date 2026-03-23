---
name: process-improvement
description: "Design and facilitate kaizen improvement loops for business and operational processes"
version: 1.0.0

strategy: multi-objective
autonomy: supervised
iteration_budget: 5
convergence:
  epsilon: 0.05
  patience: 2

initial_state:
  capture_strategy: hybrid
  sources:
    - type: user_provided
      path: ""
      description: "Process documentation — SOPs, workflow diagrams, checklists, runbooks"
    - type: user_provided
      path: ""
      description: "Current metrics — cycle time, defect rate, throughput, satisfaction scores"

measurement:
  tool_generation: false
  language: python

kpis:
  - name: primary_metric
    description: "The primary process KPI defined by the user during setup (e.g., cycle time, defect rate, throughput). Direction and unit are configured during BOOTSTRAP."
    direction: minimize
    unit: custom
    measurement_method: user-reported
    formula: "User-defined — established during BOOTSTRAP based on the specific process"
  - name: secondary_metric
    description: "Optional secondary KPI to track trade-offs (e.g., if reducing cycle time, track quality). Direction and unit configured during BOOTSTRAP."
    direction: maximize
    unit: custom
    measurement_method: user-reported
    formula: "User-defined — established during BOOTSTRAP based on the specific process"

mutation_targets:
  defaults:
    - path: ".docs/processes/"
      description: "Process documentation, SOPs, and checklists"
    - path: ".docs/workflows/"
      description: "Workflow definitions and diagrams"
  immutable:
    - path: ".git/**"
    - path: "src/**"
    - path: "tests/**"

connectors:
  required:
    - "~~sequential-thinking"
  optional:
    - "~~knowledge base"
---

# Process Improvement Instructions

This profile helps humans design and run kaizen improvement loops for business and operational processes. Unlike the code-focused profiles, this one works with human-reported metrics and process documents rather than code analysis.

## BOOTSTRAP Special Handling

This profile requires additional setup during BOOTSTRAP because KPIs are user-defined:

1. **Ask the user** to describe the process they want to improve:
   - What is the process? (name, purpose, scope)
   - Who is involved? (roles, handoffs)
   - What's the current pain point? (what's not working well)

2. **Define KPIs together** with the user:
   - What is the primary metric to optimize? (e.g., "time from request to delivery")
   - What direction? (minimize/maximize)
   - What unit? (hours, percentage, count, etc.)
   - What is the current value? (baseline)
   - Is there a secondary metric to track trade-offs?

3. **Gather process documentation**:
   - Ask the user to provide or point to existing SOPs, checklists, or workflow descriptions
   - If no documentation exists, help the user document the current process (this becomes the baseline artifact)

4. **Set the `.kaizen/` location**:
   - If the process relates to a specific project: use `.kaizen/` at project root
   - If the process is personal or cross-project: use `~/.kaizen/`

## MEASURE Phase

Since KPIs are user-reported:

1. **Present the KPI definitions** to the user as a reminder
2. **Ask for current values**:
   - "What is the current {primary_metric_name}? (in {unit})"
   - "What is the current {secondary_metric_name}? (in {unit})" (if defined)
3. **Record values** with timestamp
4. **Ask for qualitative observations**: "Any notable changes or events since the last measurement?"

`Read references/kpi-design-guide.md` if the user struggles to provide numeric values — help them define a measurement protocol.

## ANALYZE Phase

`Read references/kaizen-methodology.md`

Analyze the user-reported data in context:

1. **Quantitative analysis** — delta from baseline and previous iteration
2. **Qualitative analysis** — examine the user's observations for patterns
3. **Process document review** — read the current process documentation to identify:
   - Steps with excessive handoffs
   - Steps with waiting time (queues)
   - Steps that add no value (inspections that catch nothing, approvals that never reject)
   - Steps with high variability (sometimes fast, sometimes slow)

4. **Apply kaizen lenses**:
   - **Value Stream Analysis**: which steps add value vs waste?
   - **5 Whys**: for each problem, ask "why" iteratively to find root cause
   - **PDCA**: where are we in the Plan-Do-Check-Act cycle?

## HYPOTHESIZE Phase

Common root causes for process inefficiency:

1. **Batching** — work waits in queues instead of flowing
2. **Over-processing** — steps that add more detail than needed
3. **Handoff friction** — information lost between people/teams
4. **Rework loops** — defects found late, requiring re-doing previous steps
5. **Waiting** — approvals, reviews, or dependencies that block flow
6. **Motion waste** — switching between tools, systems, or contexts
7. **Unclear ownership** — nobody knows who's responsible for what

Apply the **5 Whys** technique: for each hypothesis, ask "why does this happen?" and trace to the root cause.

## PROPOSE Phase

`Read references/facilitation-guide.md`

Appropriate process improvements:

- **Eliminate a non-value-adding step** — remove unnecessary approvals, inspections, or handoffs
- **Reduce batch size** — process smaller units more frequently
- **Automate a manual step** — identify steps that could be automated
- **Add a quality gate earlier** — catch defects before they propagate
- **Clarify a handoff** — define exact inputs/outputs between steps
- **Create a checklist** — standardize a variable step
- **Parallelize sequential steps** — identify steps that don't actually depend on each other

**Format proposals as changes to process documents:**
- Update the SOP/checklist/workflow to reflect the proposed change
- Describe the change in human terms (not code)
- Include an implementation plan: who needs to do what, when

**Constraints:**
- ONE process change per iteration — don't overwhelm the team
- MUST be implementable by the team (don't propose changes they can't control)
- Present with rationale — people need to understand why
- Consider cultural impact — process changes affect people
- ALWAYS pause for user approval (supervised mode is mandatory for this profile)

## APPLY Phase

For process improvement, "applying" means updating the process documentation:

1. **Modify the SOP/checklist/workflow** — update the relevant document to reflect the proposed change
2. **Add implementation notes** — what the team needs to do differently
3. **Create a measurement protocol** — how to know if the change worked
4. **Set a review date** — when to measure the impact (typically 1-2 weeks for the next iteration)

The user is responsible for actually implementing the process change in their organization. The engine updates the documentation and tracks progress.

## VERIFY Phase

Since process changes take time to show results:

1. **Remind the user** that process improvements need time to take effect
2. **Ask for updated metrics** at the next iteration (possibly after days or weeks)
3. **Ask for qualitative feedback**: "How did the team respond to the change? Any unexpected effects?"
4. **Record both quantitative and qualitative data**

This profile is inherently slower than code-focused profiles. Each iteration may span days or weeks.
