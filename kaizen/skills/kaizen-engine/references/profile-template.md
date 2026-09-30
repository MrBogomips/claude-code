# Profile Template

Use this template to create a new kaizen improvement profile. Copy the content below into `.kaizen/profiles/{your-profile-name}/PROFILE.md` at the project root, or into `~/.kaizen/profiles/{your-profile-name}/PROFILE.md` for a profile you use across projects, and fill in the sections. The engine finds a profile by name in both folders. Do not save profiles inside the plugin directory: it is the plugin cache, which is replaced on update.

The folder that holds PROFILE.md is the **profile directory**. A `references/...` path in the body resolves against it, so reference files go in `.kaizen/profiles/{your-profile-name}/references/`.

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
  epsilon: 0.02    # fallback minimum delta for KPIs that set no epsilon of their own
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
    epsilon: 0.02              # optional: minimum delta that counts, in this KPI's unit
    observational: false       # optional: true = tracked and reported, never decides keep/revert
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
  required: []
  optional:
    - "~~sequential-thinking"
---

# Improvement Instructions

These sections provide domain-specific guidance for each phase of the improvement loop. The engine reads the relevant section during each phase.

## BOOTSTRAP Special Handling

Optional. Include it only when the profile needs something settled with the user before the first measurement — for example, KPIs or the mutation target path that depend on the user's situation. The engine reads this section at BOOTSTRAP and stores what it settles in the run's `manifest.json`.

## MEASURE Phase

Describe how to collect data for your KPIs:
- What files or sources to examine
- What patterns to look for
- How to handle edge cases (missing data, ambiguous values)

The engine reads this section, and every `references/` file it names, before generating the measurement script.

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
- Checks a command can run (build, tests, lint). At BOOTSTRAP the engine turns them into commands, confirms them with the user and keeps those that pass on the baseline. A failing check forces REVERT, whatever the KPIs say
- Manual checks the user should perform (for supervised mode)
- Signs that a change may have unintended side effects
```

---

## Guidelines for Good Profiles

1. **Start with 1-2 KPIs** — add more only if needed. Multi-objective optimization is harder.
2. **Keep formulas concrete** — even though they're human-readable, they should be unambiguous enough to implement as code.
3. **Set epsilon per KPI, in its own unit** — 0.02 suits a ratio but is noise on a 0–100 percentage. Too low catches noise, too high misses real improvements.
4. **Use supervised autonomy initially** — switch to autonomous once you trust the loop.
5. **Define immutables carefully** — err on the side of protecting more files.
6. **Write detailed phase instructions** — the engine is generic; your domain knowledge lives in these sections.
7. **Mark KPIs the loop cannot move as observational** — a KPI read from past activity (for example, session transcripts) does not change within a run, so it should inform the analysis without deciding keep or revert.
8. **Bump `version` when a KPI formula changes** — the engine reuses the previous run's measurement script while the version is unchanged.
