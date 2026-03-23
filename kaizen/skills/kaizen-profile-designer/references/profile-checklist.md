# Profile Design Checklist

Use this checklist when helping users design custom kaizen profiles.

## KPI Checklist

For each KPI, verify:

- [ ] **Name** is short, lowercase, uses underscores (e.g., `build_time`)
- [ ] **Description** clearly explains what the KPI measures
- [ ] **Direction** is explicitly stated (maximize or minimize)
- [ ] **Unit** is defined (ratio, percentage, count, seconds, or custom with explanation)
- [ ] **Formula** is unambiguous — someone else could implement it from the description
- [ ] **Measurement method** is feasible:
  - `automated`: can be calculated from files/data without human input
  - `user-reported`: requires human observation
  - `hybrid`: some parts automated, some manual
- [ ] **Epsilon** is calibrated to the KPI's scale:
  - For ratios (0-1): epsilon 0.01-0.05
  - For percentages (0-100): epsilon 1-5
  - For counts: epsilon 1
  - For time (seconds): epsilon depends on scale

## Data Source Checklist

For each source:

- [ ] **Type** is one of: session_transcripts, config, git_history, memory, user_provided
- [ ] **Path** exists (or will be provided by the user)
- [ ] **Description** explains what data this provides for the KPIs

## Mutation Scope Checklist

- [ ] **Default targets** cover the files that need improvement
- [ ] **Immutable targets** protect: tests, git directory, lock files, dependencies
- [ ] Default and immutable targets don't overlap
- [ ] The user confirmed the scope is appropriate

## Engine Configuration Checklist

- [ ] **Strategy** matches the number of KPIs (greedy for 1, multi-objective for 2+)
- [ ] **Autonomy** is appropriate for the domain and user trust level
- [ ] **Iteration budget** is set (5-10 for first run)
- [ ] **Patience** is set (2-3 typically)
- [ ] **Measurement tool generation** is decided and language chosen (if automated)

## Profile Body Checklist

- [ ] Each phase section (MEASURE through VERIFY) has domain-specific instructions
- [ ] PROPOSE section includes constraints (what NOT to change)
- [ ] MEASURE section describes how to collect each KPI value
- [ ] ANALYZE section describes what good/bad values look like for each KPI

## Common Mistakes

- **Too many KPIs** — start with 1-2, add more later
- **Vague formulas** — "code quality" is not measurable; "functions with complexity > 10" is
- **Missing immutables** — always protect tests, git, and dependencies
- **Autonomous too early** — start supervised until you trust the loop
- **Epsilon too low** — catches noise instead of improvements
- **Budget too high** — 10 is usually enough; diminishing returns after that
