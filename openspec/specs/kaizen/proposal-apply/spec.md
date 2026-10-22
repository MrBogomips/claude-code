# kaizen/proposal-apply Specification

## Purpose
Keeps kaizen's edits to project assets small, consistent and explicitly authorized, so a retrospective
never grows the local skill and agent set or changes a file the user did not approve.

## Requirements

### Requirement: Proposed edits to model-facing text pass one read-only review
Before the recap, every proposed edit to text the model reads (skills, agents, rules, CLAUDE.md, commands,
output styles) SHALL go through one dispatch of a read-only reviewer that checks the after-text for
contradictions, duplicates, needless length, edits beyond the incident, trigger or frontmatter problems
and net growth. The recap SHALL show each item's verdict.

#### Scenario: Contradiction caught
- **WHEN** a proposed CLAUDE.md line contradicts a rule file loaded in the session
- **THEN** the reviewer returns REVISE or DROP citing the rule's file and line, and the recap shows the revised item or why it was dropped

#### Scenario: Config-only proposals
- **WHEN** every proposal edits only a settings file
- **THEN** no reviewer is dispatched

### Requirement: Kaizen never creates skills or agents and marks growth
The skill SHALL NOT create a new skill or agent file; an incident that needs one SHALL become advice.
Each option SHALL show its net line change, and options that add net lines of instruction text SHALL be
marked as growth. Deleting, merging or tightening text SHALL be preferred over adding it.

#### Scenario: Missing skill
- **WHEN** an incident shows that a project skill for a recurring task is missing
- **THEN** kaizen gives advice describing the skill and creates no file

### Requirement: The recap changes nothing and ends the turn
The skill SHALL present project proposals (with options, before and after text, net lines and review
verdict), external advice and pointers in chat, state that nothing has been changed, and end the turn.

#### Scenario: Recap shown
- **WHEN** kaizen has two project proposals and one external advice item
- **THEN** it shows them in chat, no file is modified, and it waits for the user's reply

### Requirement: Only explicit item IDs authorize an apply
The skill SHALL apply only the project items the user names by ID, with an option letter when the item
has options. A vague approval SHALL be answered by asking for IDs. Advice and pointer items SHALL never be
applied.

#### Scenario: Vague approval
- **WHEN** the user replies "sounds good"
- **THEN** kaizen asks which item IDs to apply and changes nothing

#### Scenario: Missing option letter
- **WHEN** the user replies "apply 1" and item 1 has options a and b
- **THEN** kaizen asks which option and changes nothing yet

#### Scenario: Advice item named
- **WHEN** the user names an external advice item
- **THEN** kaizen replies that it is advice only and edits nothing

### Requirement: A changed or dirty target is not edited
Before the first edit the skill SHALL re-read every authorized target. A target that changed since the
recap, was moved or deleted, or has uncommitted changes SHALL NOT be edited, and the skill SHALL ask the
user how to proceed. Its own edits during the apply SHALL NOT count as changes. An edited JSON file SHALL
remain valid.

#### Scenario: Target has uncommitted changes
- **WHEN** the user authorizes an item whose target file has uncommitted changes
- **THEN** kaizen asks the user to commit or set them aside and does not edit the file

#### Scenario: Two items on the same file
- **WHEN** the user authorizes two items that both edit a clean `CLAUDE.md`
- **THEN** kaizen applies both

### Requirement: Kaizen writes no reports, state files or commits
Apart from authorized edits, the skill SHALL write nothing: no report files, no state files and no
commits. After applying it SHALL list the applied items, those not applied, and how to undo with git.

#### Scenario: After apply
- **WHEN** kaizen applies item 1a
- **THEN** only the target of 1a changes and kaizen does not commit it
