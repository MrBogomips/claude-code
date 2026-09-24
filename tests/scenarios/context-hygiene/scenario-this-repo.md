# Scenario: Read-only dry run on this repository

Spec §11.3. Run only up to the recap. **Never authorize anything here.**

## Setup
`git status --porcelain` must be clean. Record the memory fingerprint:
`find "<memory dir>" -type f -exec cksum {} + | LC_ALL=C sort > <scratch>/repo-mem-before.txt`

## Invocation
> Read `context-hygiene/skills/context-hygiene/SKILL.md` and its references and follow it. Task: audit this repository's agentic context. Stop at the recap; do not apply anything.

## Acceptance Criteria
- [ ] Wrong: CLAUDE.md Repository structure lists fewer plugins than `.claude-plugin/marketplace.json`. Skip this check if Task 6 has already fixed it; then it must NOT be reported
- [ ] Stale: the MEMORY.md index line about agentic-harness carries old status
- [ ] Stale: `2026-06-12-tracker-sync-v0.8-design.md` is superseded by its `-1.1.0` sibling, found inside a working folder discovered from signals
- [ ] Redundant: the oversized agentic-harness memory file, proposed as a POINTER, marked ⚠
- [ ] Redundant: the shell-script rule duplicated between a memory file and CLAUDE.md
- [ ] Afterwards `git status --porcelain` is still clean, and the memory fingerprint is unchanged
