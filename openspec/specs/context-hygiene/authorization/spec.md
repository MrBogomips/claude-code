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
