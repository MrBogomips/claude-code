# Spec Delta

## Purpose

Decides, from cheap mechanical signals of the current session, whether kaizen is worth offering, and
offers it at most once per session without blocking the turn or calling a model on every turn.

## ADDED Requirements

### Requirement: The Stop hook offers kaizen at most once per session
The kaizen Stop hook SHALL hand the model an offer at most once per session, identified by the hook
input's `session_id`. When it cannot record that the offer was made, it SHALL make no offer.

#### Scenario: Second trip in the same session
- **WHEN** the gate trips at the end of a turn after an offer was already made in the same session
- **THEN** the hook prints nothing

#### Scenario: Marker cannot be written
- **WHEN** the gate trips and the hook cannot write its per-session marker
- **THEN** the hook prints nothing

### Requirement: The offer asks the model to judge the full gate
When a signal trips, the hook SHALL output `additionalContext` that names the signals and asks the model
to judge the full gate (breadth of changes, errors, reworks, ambiguities it noticed) and, only if the gate
trips and kaizen has not run yet in the session, to end its reply with one line offering kaizen.

#### Scenario: Offer content
- **WHEN** 3 tool errors were recorded in the session and no offer was made yet
- **THEN** the hook outputs valid JSON whose `hookSpecificOutput.additionalContext` names "3 tool errors" and asks for a one-line offer only if the gate trips

### Requirement: The offer fires only when a signal crosses its threshold
The hook SHALL trip on any of: more than 7 distinct project files edited in the session, more than 7
changed files or more than 200 changed lines in the working tree, a changed sensitive path (`.claude/`,
`CLAUDE.md`, `CLAUDE.local.md`, a lockfile, a migration), 3 or more tool errors, 2 or more user
interruptions. Below every threshold it SHALL print nothing.

#### Scenario: Quiet session
- **WHEN** the session edited 2 project files, changed 40 lines and had 1 tool error
- **THEN** the hook prints nothing and records no marker

#### Scenario: Sensitive path changed
- **WHEN** the session edited the project's `CLAUDE.md`
- **THEN** the hook trips and names the sensitive change

### Requirement: Working-tree signals count only for sessions that edited project files
The hook SHALL read working-tree signals only when the session edited at least one file under the project
directory, and SHALL never count edits to files outside it.

#### Scenario: Tree dirty before the session
- **WHEN** the working tree has 12 changed files from earlier work and the session edited none
- **THEN** the hook prints nothing

#### Scenario: Edits outside the project
- **WHEN** the session wrote 10 files under the user's home configuration and none in the project
- **THEN** those files are not counted

### Requirement: The hook never blocks, never calls a model and fails silent
The hook SHALL exit 0 with no stderr output in every case, SHALL NOT use `decision: "block"` or call a
model, and SHALL print nothing when its input or the transcript is missing or malformed.

#### Scenario: Malformed input
- **WHEN** the hook receives empty or malformed JSON, or the transcript path does not exist
- **THEN** it exits 0 and prints nothing

#### Scenario: Not a git directory
- **WHEN** the project directory is not a git work tree
- **THEN** the hook skips working-tree signals and still evaluates the transcript signals

### Requirement: The hook stays out of continuations, waits and unattended runs
The hook SHALL print nothing when the turn is already a stop-hook continuation, when background tasks are
pending, when the session is not attended by a user (headless or SDK runs), or when `KAIZEN_STOP_HOOK` is
`0`.

#### Scenario: Headless run
- **WHEN** a gate signal trips in a `claude -p` run
- **THEN** the hook prints nothing and the run's result is unchanged

#### Scenario: Opt-out
- **WHEN** `KAIZEN_STOP_HOOK=0` is set and a gate signal trips
- **THEN** the hook prints nothing
