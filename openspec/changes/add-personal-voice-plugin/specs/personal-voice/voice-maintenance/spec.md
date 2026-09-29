# Spec Delta

## Purpose

Keeps the voice stores small, consistent and current by turning observations into rules and
revising existing rules, always with the author's per-item confirmation.

## ADDED Requirements

### Requirement: Explicit start and per-item authorization
Maintenance SHALL run only when the user invokes it or accepts a suggestion to run it. It SHALL
first present a numbered recap of proposed actions, each with its evidence and destination,
and SHALL change nothing until the user authorizes specific items. A vague reply SHALL NOT
count as authorization.

#### Scenario: Recap before any change
- **WHEN** maintenance starts
- **THEN** it lists numbered actions and changes no file until the user names the items to apply

#### Scenario: Vague reply
- **WHEN** the user answers "ok" to the recap
- **THEN** maintenance asks for the item numbers and changes nothing

### Requirement: Promotion of observations to rules
An observation with at least two independent pieces of evidence SHALL be proposed as a rule.
For each proposal the user SHALL be able to accept, reject, edit, or change its scope (global
or project, file, language, audience). The user MAY promote an observation with a single piece
of evidence on explicit request. Accepted rules SHALL be written to the file routing selects,
and the observation SHALL be removed.

#### Scenario: Observation matching an existing rule
- **WHEN** a pending observation records a trait that an existing rule already states
- **THEN** maintenance proposes adding its evidence to that rule and updating its
  last-reinforced date, instead of a new rule

#### Scenario: Two pieces of evidence
- **WHEN** an observation has evidence from two independent texts
- **THEN** maintenance proposes it as a rule and shows both pieces of evidence

### Requirement: Merging and conflicts
Overlapping rules SHALL be proposed for merging, with their evidence summed. Contradictory rules
SHALL be presented together, and the user SHALL choose which prevails or qualify them by
audience, topic or language.

#### Scenario: Contradiction
- **WHEN** one rule prefers the informal "tu" with clients and another prefers "Lei"
- **THEN** maintenance shows both and asks which prevails or how to qualify them

### Requirement: Removal of rules that add nothing
Rules that only restate what the model does by default SHALL be proposed for removal.

#### Scenario: Generic rule
- **WHEN** a rule says only "write clearly"
- **THEN** maintenance proposes removing it as adding nothing

### Requirement: Decay and expiry
A rule not reinforced for six months SHALL be flagged for review and SHALL NOT be deleted
without authorization. An observation with a single piece of evidence older than three months
SHALL be proposed for deletion.

#### Scenario: Stale rule
- **WHEN** a rule was last reinforced seven months ago
- **THEN** maintenance flags it for review and keeps it unless the user authorizes removal

### Requirement: Size limits
No store file SHALL hold more than 50 rules. When a file would exceed the limit, maintenance
SHALL propose merges or removals that keep it at 50 or fewer. Exemplars SHALL be kept to at
most five per topic and language, each at most 300 words.

#### Scenario: Promotion over the limit
- **WHEN** accepting a promotion would bring a topic file to 51 rules
- **THEN** maintenance proposes a merge or removal in the same recap

### Requirement: Scope moves
Maintenance SHALL propose moving a project rule to the global store when it proves general,
and a global rule to the project store when it proves project-specific, without ever moving
personal material into a project store.

#### Scenario: Project rule that proves general
- **WHEN** the same project rule has evidence from texts unrelated to that project
- **THEN** maintenance proposes moving it to the global store

### Requirement: Changing the project store's git choice
Maintenance SHALL let the user switch the project store between personal and versioned,
explaining the implications again before applying the switch.

#### Scenario: From personal to versioned
- **WHEN** the user asks to share the project glossary with the team
- **THEN** maintenance explains the implications and, once authorized, removes the local
  exclusion

### Requirement: Maintenance date recorded
Maintenance SHALL record the date it last ran, so that the learn skill can apply its
suggestion threshold.

#### Scenario: After a run
- **WHEN** maintenance finishes
- **THEN** the date of the run is recorded in the global store
