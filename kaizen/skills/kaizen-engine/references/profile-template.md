# Profile Template

Use this template to create a new kaizen improvement profile. Copy the content below into a new file at `profiles/{your-profile-name}/PROFILE.md` and fill in the sections.

---

```yaml
---
name: your-profile-name
description: "One-line description of what this profile improves"
version: 0.1.0

# Strategy: how the engine decides to keep or revert changes
# - greedy: single KPI, pure hill-climbing
# - multi-objective: Pareto dominance across multiple KPIs
strategy: multi-objective

# Autonomy: how much human involvement per iteration
# - autonomous: loop runs unattended until convergence or budget
# - supervised: pause for human approval at every PROPOSE step
# - hybrid(N): autonomous for N iterations, then pause for checkpoint
autonomy: supervised

# Iteration budget: max iterations before stopping (0 = unlimited)
iteration_budget: 10

# Convergence: when to stop if no improvement is happening
convergence:
  epsilon: 0.02    # minimum KPI delta to count as "improvement"
  patience: 3      # consecutive no-improvement iterations before stopping

# Initial state: how to capture the baseline before the first iteration
initial_state:
  capture_strategy: automatic  # automatic | manual | hybrid
  sources:
    - type: config             # session_transcripts | config | git_history | memory | user_provided
      path: ".claude/"
      description: "What this source provides"
    # Add more sources as needed

# Measurement: how KPIs are collected
measurement:
  tool_generation: true        # true = auto-scaffold a measurement script
  language: python             # python | typescript (when tool_generation is true)

# KPIs: what to measure and optimize
kpis:
  - name: your_kpi_name
    description: "Human-readable description of what this measures"
    direction: maximize        # maximize | minimize
    unit: ratio                # ratio | percentage | count | seconds | custom
    measurement_method: automated  # automated | user-reported | hybrid
    formula: "numerator / denominator — human-readable, not eval'd"

  # Add more KPIs as needed (multi-objective profiles should have 2-4 KPIs)

# Mutation targets: what the engine is allowed to change
mutation_targets:
  defaults:
    - path: "path/to/file-or-pattern"
      description: "Why this file is a valid improvement target"
  immutable:
    - path: "tests/**"         # patterns that MUST NOT be modified
    - path: ".git/**"

# Connectors: MCP server dependencies
connectors:
  required:
    - "~~sequential-thinking"
  optional: []
---

# Improvement Instructions

These sections provide domain-specific guidance for each phase of the improvement loop. The engine reads the relevant section during each phase.

## MEASURE Phase

Describe how to collect data for your KPIs:
- What files or sources to examine
- What patterns to look for
- How to handle edge cases (missing data, ambiguous values)

## ANALYZE Phase

Describe how to interpret the measurements:
- What constitutes a good vs poor value for each KPI
- Known correlations between KPIs
- Common patterns or anti-patterns to look for

## HYPOTHESIZE Phase

Describe the kinds of root causes and opportunities to consider:
- Typical reasons for poor KPI values in this domain
- Categories of improvements that tend to be high-impact
- Constraints or trade-offs to keep in mind

## PROPOSE Phase

Describe the kinds of changes that are appropriate:
- What types of modifications are safe and effective
- Examples of good proposals for this domain
- Constraints on proposal scope (e.g., "one file per iteration")
- Anti-patterns to avoid

## APPLY Phase

Describe any special considerations for applying changes:
- Syntax validation requirements
- Side effects to watch for
- Order-dependent operations

## VERIFY Phase

Describe any additional verification beyond KPI re-measurement:
- Smoke tests to run
- Manual checks the user should perform (for supervised mode)
- Signs that a change may have unintended side effects
```

---

## Guidelines for Good Profiles

1. **Start with 1-2 KPIs** — add more only if needed. Multi-objective optimization is harder.
2. **Keep formulas concrete** — even though they're human-readable, they should be unambiguous enough to implement as code.
3. **Set conservative epsilon** — too low catches noise, too high misses real improvements.
4. **Use supervised autonomy initially** — switch to autonomous once you trust the loop.
5. **Define immutables carefully** — err on the side of protecting more files.
6. **Write detailed phase instructions** — the engine is generic; your domain knowledge lives in these sections.
