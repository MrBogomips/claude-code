# context-hygiene/discovery-checks Specification

## Purpose
Defines how context-hygiene runs its read-only checks without permission prompts, and which load
limits its size checks measure against.

## Requirements

### Requirement: Checks run with read-only tools the skill pre-approves
Discovery and the Wrong, Stale and Redundant checks SHALL use only the Read, Glob and Grep tools
and the commands the skill's `allowed-tools` pre-approves (`git rev-parse`, `git ls-files`,
`git log`, `git status`, `git branch`, `git check-ignore`, `wc`, `ls`), one command per call. They
SHALL NOT use other shell commands or pipes, so that no check asks for permission in manual mode
or is denied in a headless run.

#### Scenario: Headless dry run
- **WHEN** the skill runs headless with `--permission-mode default` and reaches the recap
- **THEN** no tool call was denied, and no file was written

#### Scenario: Ignored CLAUDE.local.md
- **WHEN** the project has a git-ignored `CLAUDE.local.md` in a subdirectory
- **THEN** discovery lists it through `git ls-files -o -i --exclude-standard`

### Requirement: Memory index size is checked in lines and bytes against the verified load limit
The checks SHALL state the load limits with the date they were verified on the Claude Code
memory documentation: `MEMORY.md` loads its first 200 lines or first 25KB, whichever comes
first; a `CLAUDE.md` loads in full up to 4 MiB. The Size check SHALL flag a `MEMORY.md` longer
than 150 lines or larger than 20,000 bytes, and SHALL report the lines past either load limit as
a Wrong finding.

#### Scenario: Long index lines
- **WHEN** `MEMORY.md` has 120 lines but 22,000 bytes
- **THEN** the Size check flags it, although it is under the line threshold

#### Scenario: Index past the load limit
- **WHEN** `MEMORY.md` has 230 lines
- **THEN** the lines past line 200 are reported as a Wrong finding, because they never load at session start
