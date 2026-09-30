# Spec Delta

## Purpose

Makes the literal "apply all" reply part of the authorization rules, in the hard rule as well as
in the protocol, so that the two no longer disagree.

## ADDED Requirements

### Requirement: The literal "apply all" authorizes every non-⚠, reversible item
Besides item numbers and group letters, the skill SHALL accept the literal reply "apply all" as
authorization for every item that is neither `⚠ rationale-risk` nor irreversible, and SHALL echo
the expanded set before applying anything. ⚠ and irreversible items SHALL still need their
numbers. The hard rule on authorization in `SKILL.md` SHALL name this form. Any other wording of
"everything" SHALL count as a vague reply.

#### Scenario: Reply "apply all"
- **WHEN** the user replies "apply all" to a recap that holds a BACKUP item, reversible edits, one ⚠ item and one untracked working-area item
- **THEN** the skill echoes the set of BACKUP and the reversible edits, applies it with BACKUP first, and lists the ⚠ and untracked items as awaiting individual approval

#### Scenario: Reply "do everything"
- **WHEN** the user replies "do everything"
- **THEN** the skill re-prompts with the valid IDs and changes nothing
