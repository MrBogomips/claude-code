# context-hygiene/authorization Specification

## Purpose
Defines which user replies to a context-hygiene recap authorize changes, so that nothing is
applied on an approval the user did not tie to specific items.

## Requirements

### Requirement: Mixed replies authorize only their explicit IDs, after the vague part is resolved
When a reply names item IDs or group letters and also gives vague approval of items it does
not name, the skill SHALL treat only the named IDs as candidates, echo them, and re-prompt for
the vague portion. It SHALL apply nothing until the user answers. A reply whose only vague part
is a general assent such as "yes", with no reference to unnamed items, SHALL authorize exactly
the IDs it names.

#### Scenario: Explicit IDs plus vague approval of the rest
- **WHEN** the user replies "apply 3, and the rest looks fine" to a recap with items 1 to 5
- **THEN** the skill echoes {3} as the only candidate, asks which of the other items to apply, and changes nothing in that turn

#### Scenario: Leading assent with explicit IDs
- **WHEN** the user replies "yes, do 1 and 3"
- **THEN** the skill echoes {1, 3} and applies exactly items 1 and 3, without re-prompting

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
