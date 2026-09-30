# kaizen/iteration-safety Specification

## Purpose
Defines how the kaizen engine protects the user's files and git history while it applies, keeps
and reverts changes, so that a run never commits edits the loop did not make and never keeps a
change that breaks a verify check.

## Requirements

### Requirement: Uncommitted changes in the mutation targets are resolved before any commit
At BOOTSTRAP, after the mutation targets are final, the engine SHALL run
`git status --porcelain` on each target inside a git work tree. If any file is listed, the engine
SHALL show the list and ask the user to either commit or stash the changes, or run without
commits, and SHALL NOT stage or commit anything until the user answers. The engine SHALL also
offer a `kaizen/<run-id>` branch and SHALL create it only if the user accepts.

#### Scenario: A target has uncommitted edits
- **WHEN** a run starts and a file under the mutation targets has uncommitted changes
- **THEN** the engine lists the file, offers commit-or-stash and run-without-commits, offers the `kaizen/<run-id>` branch, and HEAD is unchanged until the user replies

#### Scenario: The user runs without commits
- **WHEN** the user chooses to run without commits and an iteration is kept
- **THEN** the change stays in the working tree, no commit is made, and `decision.json` records `commit_skipped: "no_commits"`

#### Scenario: Uncommitted edits outside the targets
- **WHEN** a file outside the mutation targets has uncommitted changes
- **THEN** the engine does not ask about it and never includes it in a kaizen commit

### Requirement: KEEP commits only the edits the iteration made
On KEEP, the engine SHALL stage only the files the iteration modified or created. Before APPLY
it SHALL check those files with `git status --porcelain`, and if any of them already had
uncommitted changes it SHALL NOT commit the iteration, SHALL record `commit_skipped` in
`decision.json`, and SHALL tell the user.

#### Scenario: Kept iteration on clean targets
- **WHEN** an iteration is kept and its files were clean before APPLY
- **THEN** exactly one commit is made, named `kaizen(<profile>): iteration <N> — <description>`, and it contains only the files the iteration modified or created

#### Scenario: A target was edited outside the loop
- **WHEN** a file the iteration will modify has uncommitted changes just before APPLY
- **THEN** a KEEP leaves the change uncommitted, records `commit_skipped: "dirty_before_apply"`, and tells the user

### Requirement: REVERT restores the pre-iteration state from the backup
On REVERT, the engine SHALL restore every modified file from the iteration's backup and SHALL
delete every file listed in `backup/created.txt`. It SHALL NOT use `git checkout` or
`git restore` on these files, because the backup also holds the user's uncommitted edits.

#### Scenario: Reverted iteration that created a file
- **WHEN** an iteration that modified one file and created another is reverted
- **THEN** the modified file is byte-identical to its pre-iteration state, the created file no longer exists, and no commit is made

#### Scenario: Revert over uncommitted user edits
- **WHEN** a run without commits reverts an iteration on a file that held uncommitted user edits
- **THEN** the file is restored with the user's edits intact

### Requirement: A failed verify check forces REVERT
At BOOTSTRAP the engine SHALL turn the profile's VERIFY checks that a command can perform into
commands, confirm them with the user, run each once, and record those that pass as
`verify_checks` in the manifest; a check that already fails SHALL be reported and left out. In
VERIFY the engine SHALL run every recorded check. If a check fails or times out, or a decision
KPI is missing from the verification, the engine SHALL REVERT regardless of the KPIs and SHALL
record `verify_failed: true` and the failed check in `decision.json`.

#### Scenario: KPI improves but the build breaks
- **WHEN** an iteration improves every decision KPI by at least its epsilon and a recorded verify check exits non-zero
- **THEN** the decision is `revert` with `verify_failed: true` and `failed_check` naming that check, and the files are restored

#### Scenario: A check fails on the baseline
- **WHEN** a VERIFY check already fails when it is run at BOOTSTRAP
- **THEN** the engine reports it and does not record it in `verify_checks`

### Requirement: User decisions during an iteration are recorded as keep or revert
When the user rejects a supervised proposal, the engine SHALL skip APPLY and VERIFY, SHALL
record `no_proposal: true` with the user's reason in `user_note`, and SHALL pass that note to the
next proposer. When a multi-objective trade-off is escalated, the engine SHALL record the user's
answer as the decision, `keep` or `revert`, with `escalated: true`, and the patience counter
SHALL follow that decision.

#### Scenario: Supervised proposal rejected
- **WHEN** the user rejects a proposal in a supervised run and gives a reason
- **THEN** no file is changed, `decision.json` has `no_proposal: true` and the reason in `user_note`, the patience counter increases, and the next proposer receives the note

#### Scenario: Escalated trade-off accepted
- **WHEN** the user accepts an escalated trade-off
- **THEN** `decision.json` has `decision: "keep"` and `escalated: true`, the KEEP actions run, and the patience counter resets
