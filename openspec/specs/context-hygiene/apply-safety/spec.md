# context-hygiene/apply-safety Specification

## Purpose
Defines the guards context-hygiene runs before it reads or writes anything, so that a run
never proceeds on missing instructions or on targets that changed since the user approved them.

## Requirements

### Requirement: The run stops when a reference file cannot be read
Before discovery, the skill SHALL check that every file it uses under its `references/`
directory can be read. If any cannot, the skill SHALL stop, name each missing or unreadable
file, and SHALL NOT run discovery, checks or the recap.

#### Scenario: A reference file is missing
- **WHEN** the skill is invoked and `references/checks.md` does not exist
- **THEN** it reports that `references/checks.md` is missing, produces no findings or recap, and writes nothing

### Requirement: An item whose target moved or was deleted since the recap is not applied
Before applying an authorized item, the skill SHALL re-read its target. If the target changed,
was moved or was deleted since the recap, the skill SHALL stop that item, report which of
these happened, and ask again before writing anything for it.

#### Scenario: Target deleted after the recap
- **WHEN** the user authorizes an item whose target file was deleted after the recap
- **THEN** the skill does not apply that item, reports that the file is no longer at the path shown in the recap, and asks how to proceed

#### Scenario: Target changed after the recap
- **WHEN** the user authorizes an item whose target file was edited after the recap
- **THEN** the skill does not apply that item, shows the new before→after, and asks again
