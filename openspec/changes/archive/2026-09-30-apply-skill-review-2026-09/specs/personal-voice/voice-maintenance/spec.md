# Spec Delta

## Purpose

Specifies the outcomes of a conflict, keeps scope moves within the current project, stops a kept
stale rule from coming back at every run, and aligns the "all" reply with the hard rule.

## MODIFIED Requirements

### Requirement: Explicit start and per-item authorization
Maintenance SHALL run only when the user invokes it or accepts a suggestion to run it. It SHALL
first present a numbered recap of proposed actions, each with its evidence and destination,
and SHALL change nothing until the user authorizes specific items. A vague reply SHALL NOT
count as authorization. The reply "all" SHALL authorize every item that needs no decision, and
maintenance SHALL ask for the decision on each item that needs one.

#### Scenario: Recap before any change
- **WHEN** maintenance starts
- **THEN** it lists numbered actions and changes no file until the user names the items to apply

#### Scenario: Vague reply
- **WHEN** the user answers "ok" to the recap
- **THEN** maintenance asks for the item numbers and changes nothing

#### Scenario: "all" with a pending conflict
- **WHEN** the user answers "all" to a recap that holds promotions and one CONFLICT
- **THEN** maintenance applies the promotions and asks which side of the conflict prevails

### Requirement: Merging and conflicts
Overlapping rules SHALL be proposed for merging, with their evidence summed. Contradictory rules
SHALL be presented together, and the user SHALL choose which prevails or qualify them by
audience, topic or language. When an observation prevails over a rule, the rule SHALL be replaced,
at its place, by the observation promoted as a rule with the observation's evidence, and the
observation SHALL be removed. When one rule prevails over another, the losing rule SHALL be
removed and the winning rule left unchanged. When a rule prevails over an observation, the
observation SHALL be removed.

#### Scenario: Contradiction
- **WHEN** one rule prefers the informal "tu" with clients and another prefers "Lei"
- **THEN** maintenance shows both and asks which prevails or how to qualify them

#### Scenario: Keep the observation
- **WHEN** the author answers "keep B" to a conflict between the rule "Lei with clients" and the observation "tu with clients" (evidence 2)
- **THEN** the "Lei" rule is replaced by a "tu with clients" rule with evidence 2, and the observation is removed

#### Scenario: Rule against rule
- **WHEN** two `core.md` rules contradict each other and the author keeps one
- **THEN** the other rule is removed and the kept rule is unchanged

### Requirement: Decay and expiry
A rule not reinforced for six months SHALL be flagged for review and SHALL NOT be deleted
without authorization. When the author keeps a flagged rule, maintenance SHALL record the date
of that review on the rule, and the stale check SHALL measure age from the later of the
last-reinforced and last-reviewed dates. An observation with a single piece of evidence older
than three months SHALL be proposed for deletion.

#### Scenario: Stale rule
- **WHEN** a rule was last reinforced seven months ago
- **THEN** maintenance flags it for review and keeps it unless the user authorizes removal

#### Scenario: Stale rule kept at the previous run
- **WHEN** the author kept a stale rule at a run two weeks ago
- **THEN** the next run does not flag it, and a run more than six months after that review flags it again

### Requirement: Scope moves
Maintenance SHALL propose moving a project rule to the global store when it proves general,
and a global observation to the project store when it proves project-specific, without ever
moving personal material into a project store. A move to a project store SHALL target only the
current project's store, and SHALL be proposed only for an observation that reinforces no rule
and whose sources all carry the current project root's absolute path; a folder name alone SHALL
NOT count as a match. When the sources all carry another path, or the observation reinforces a
rule, maintenance SHALL propose no move and SHALL add a one-line note to the recap instead.

#### Scenario: Project rule that proves general
- **WHEN** the same project rule has evidence from texts unrelated to that project
- **THEN** maintenance proposes moving it to the global store

#### Scenario: Observation from the current project
- **WHEN** a global observation that reinforces nothing has two sources, both tagged with the current project
- **THEN** maintenance proposes moving it to the current project's store

#### Scenario: Observation from another project with the same folder name
- **WHEN** a global observation's sources are all tagged `/work/client-b/backend` and the current project root is `/work/client-a/backend`
- **THEN** maintenance proposes no move and notes in the recap which project the evidence comes from
