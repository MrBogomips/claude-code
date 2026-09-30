# kaizen/kpi-ratchet Specification

## Purpose
Defines how the kaizen engine decides to keep or revert an iteration: which KPIs take part, the
tolerance each KPI is judged by, and how earlier reverted proposals are kept out of later ones.

## Requirements

### Requirement: Each KPI is judged against its own epsilon in its own unit
A profile KPI MAY set `epsilon`, expressed in the KPI's own unit. The engine SHALL judge each KPI
against its own `epsilon`, and SHALL use `convergence.epsilon` only for a KPI without one. A KPI
counts as improved only when it moved in its desired direction by at least its epsilon, for both
maximize and minimize KPIs.

#### Scenario: The KPI's epsilon is stricter than the fallback
- **WHEN** a minimize KPI with `epsilon: 5` drops by 1 and `convergence.epsilon` is 1
- **THEN** the greedy decision is `revert`, and `decision.json` shows the delta with `epsilon: 5`

#### Scenario: The KPI's epsilon is looser than the fallback
- **WHEN** a minimize KPI with `epsilon: 1` drops by 1 and `convergence.epsilon` is 10
- **THEN** the greedy decision is `keep`

#### Scenario: KPIs in different units
- **WHEN** a multi-objective profile has a ratio KPI with `epsilon: 0.03` and a percentage KPI with `epsilon: 5`, and the percentage KPI rises by 0.04 points
- **THEN** the percentage KPI counts as unchanged

### Requirement: Observational KPIs never decide an iteration
A KPI with `observational: true` SHALL be measured, logged and reported, and SHALL be excluded
from KEEP, REVERT and ESCALATE decisions. In the claude-code-usage profile, the KPIs computed
from past session transcripts (`tool_efficiency`, `search_precision`, `skill_utilization`) SHALL
be observational, and `config_completeness` SHALL decide.

#### Scenario: An observational KPI regresses
- **WHEN** a multi-objective iteration improves the only decision KPI and an observational KPI regresses
- **THEN** the decision is `keep`, and the observational KPI's change is reported

### Requirement: Every reverted or rejected proposal is passed to the proposer
After each REVERT, including a rejected proposal, the engine SHALL append a one-line summary of
the proposal to `reverted_proposals` in `summary.json`. Every PROPOSE phase SHALL receive the
whole list, and the proposer SHALL NOT repeat any entry.

#### Scenario: Two reverts in a row
- **WHEN** iteration 1 reverts proposal A and iteration 2 reverts proposal B
- **THEN** the proposer of iteration 3 receives both A and B as proposals not to repeat
