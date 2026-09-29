# Spec Delta

## Purpose

Defines how context-hygiene marks recap items that could lose a decision, lesson or rationale,
so that those items always get the user's individual review.

## ADDED Requirements

### Requirement: The rationale-risk tag marks only shrinking actions on text that holds a rationale
The skill SHALL tag `⚠ rationale-risk` on every COMPRESS, POINTER, MERGE or REMOVE item whose
source text holds a decision, lesson or rationale, even when the proposed after-text preserves
it. It SHALL NOT add the tag to EDIT, BACKUP or POLICY items.

#### Scenario: Compressing a memory file that holds a decision
- **WHEN** the recap proposes COMPRESS on a memory file that records a decision, and the after-text keeps the decision
- **THEN** the item carries `⚠ rationale-risk` and must be named individually to be applied

#### Scenario: Correcting a wrong fact next to a rationale
- **WHEN** the recap proposes EDIT to fix a wrong path in a CLAUDE.md line that also states why a rule exists
- **THEN** the item does not carry `⚠ rationale-risk`
