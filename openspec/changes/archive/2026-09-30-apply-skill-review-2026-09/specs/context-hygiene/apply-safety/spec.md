# Spec Delta

## Purpose

Closes the gap where a group approval followed by "no" to BACKUP applied memory edits that
cannot be undone, without the user naming them.

## ADDED Requirements

### Requirement: Without a backup, only memory items named by number are applied
When the user declines BACKUP with an explicit "no", the skill SHALL treat every memory item as
irreversible: it SHALL apply only the memory items the user named by number, SHALL say so when it
echoes the authorized set, and SHALL list the memory items authorized only through a group letter
or "apply all" in the final report under "Awaiting individual approval". `SKILL.md` and
`references/safety.md` SHALL state the same rule.

#### Scenario: Group approval, then no backup
- **WHEN** the user replies "apply B, 5", where group B holds memory items 5, 6 and 7, and then answers "no" to the BACKUP question
- **THEN** the skill applies item 5 and the non-memory items of group B, leaves items 6 and 7 untouched, and lists them as awaiting individual approval

#### Scenario: Memory item named by number, no backup
- **WHEN** the user replies "apply 5" for a memory item and then answers "no" to the BACKUP question
- **THEN** the skill applies item 5 and creates no backup directory
