# Spec Delta

## Purpose

Defines how the kaizen engine builds, runs and reuses its measurement script, and where the
claude-code-usage profile reads Claude Code session data.

## ADDED Requirements

### Requirement: The engine runs the measurement script itself
In MEASURE, VERIFY and when capturing the baseline, the engine SHALL run the measurement script
through Bash with a 60-second timeout and SHALL validate the output itself: exit code 0, JSON on
stdout with a `kpis` object, and a numeric value for every automated KPI. No agent SHALL be
dispatched to run the script.

#### Scenario: The script hangs
- **WHEN** the measurement script runs for more than 60 seconds
- **THEN** the engine stops it, aborts the iteration and reports the hang to the user

#### Scenario: A KPI is missing from the output
- **WHEN** the script output lacks one automated KPI
- **THEN** the engine logs a warning and continues in MEASURE, and in VERIFY it treats a missing decision KPI as a failed verification

### Requirement: The scaffolding reads the profile's MEASURE guidance
Before generating a measurement script, the engine SHALL read the profile's `## MEASURE Phase`
section and every `references/` file that section names, resolving those paths against the
profile's own directory.

#### Scenario: A profile names a reference file
- **WHEN** a profile's MEASURE section names `references/quality-metrics.md`
- **THEN** the engine reads `<profile directory>/references/quality-metrics.md` before generating the script

### Requirement: Each run measures a fresh baseline and reuses the previous tool when the profile is unchanged
Every run SHALL measure its own baseline. The previous run's final KPIs SHALL be stored as
`previous_final` in the new manifest and SHALL NOT be used as the baseline. The engine SHALL
reuse the previous run's measurement script when the profile `version` and KPI names are
unchanged and the previous run's adversarial review was not `flagged`; a reused script SHALL
skip the BOOTSTRAP tool review.

#### Scenario: Second run of an unchanged profile
- **WHEN** a profile is run again with the same `version` and KPI names, and the previous review passed
- **THEN** the engine copies the previous `measure` script, measures a new baseline with it, stores the previous `current` KPIs as `previous_final`, and dispatches no tool review

#### Scenario: Profile version changed
- **WHEN** the profile `version` differs from the previous run's `profile_version`
- **THEN** the engine generates a new script and has it reviewed

### Requirement: claude-code-usage reads only this project's transcripts
The claude-code-usage profile SHALL read session transcripts from
`~/.claude/projects/<project>/*.jsonl`, where `<project>` is the project path with every
character that is not a letter or digit replaced by `-`, and auto memory from
`~/.claude/projects/<project>/memory/`. When the computed folder does not exist, the engine SHALL
ask the user which folder belongs to the project.

#### Scenario: Transcript folder resolved
- **WHEN** the project root is `/home/user/work/my-app`
- **THEN** the transcript source is `~/.claude/projects/-home-user-work-my-app/*.jsonl`, and no other project's transcripts are read
