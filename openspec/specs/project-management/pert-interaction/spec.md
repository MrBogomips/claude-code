# project-management/pert-interaction Specification

## Purpose
Defines how pmo-pert-estimate divides work between dispatched agents and the user checkpoints,
given that a dispatched agent cannot hold a dialogue.

## Requirements

### Requirement: Agents return drafts and open questions; the skill runs the checkpoints
Each agent dispatched by pmo-pert-estimate SHALL return a draft plus a list of open questions
and write only its own draft file. The skill itself SHALL present the draft, ask the questions
and, for a larger change, dispatch the agent again with the user's answers.

#### Scenario: Ambiguous scope in Phase 2
- **WHEN** the context-analysis agent finds a scope item it cannot resolve
- **THEN** it lists the item as an open question, and the skill asks the user at the Phase 2 checkpoint

### Requirement: Level A decomposes one project phase per dispatch
At Level A (Formative), the skill SHALL dispatch the WBS builder once per project phase, with a
checkpoint between dispatches, passing the phases already approved.

#### Scenario: Three-phase project at Level A
- **WHEN** the user chose Level A for a project with three phases
- **THEN** the WBS builder runs three times, and the user validates each phase before the next dispatch

### Requirement: The roles builder does not allocate work
The Phase 3 roles builder SHALL define roles, teams, competencies and billable flags only; roles
SHALL be assigned to activities by the Estimator in Phase 4.

#### Scenario: Roles draft
- **WHEN** the roles builder returns its draft
- **THEN** the draft contains no allocation of roles to work packages

### Requirement: The 8/80 rule applies to leaf activities in person-days
The skill SHALL apply the 8/80 rule as a most-likely effort of 1 to 10 PD per leaf activity, and
SHALL quote effort bands, not a confidence interval, as the estimate's range.

#### Scenario: Activity of 15 PD
- **WHEN** the WBS builder proposes a leaf activity of 15 PD most-likely
- **THEN** the draft flags it and proposes a split
