# plantuml/skill-invocation Specification

## Purpose
Defines what invoking a plantuml skill does to the session: no model switch, and no file writes
from the skills that are read-only by intent.

## Requirements

### Requirement: Skills do not switch the session model
No plantuml skill SHALL declare `model:` in its frontmatter; the session model applies. Agents keep
their own model pins, which affect only the agent.

#### Scenario: Rendering during a document task
- **WHEN** a document skill running on the session model invokes plantuml-convert partway through a turn
- **THEN** the rest of the turn continues on the session model

### Requirement: Read-only skills cannot write files
plantuml-review and plantuml-advisor SHALL declare `disallowed-tools: Write, Edit`, and their
descriptions SHALL each exclude the other's use case.

#### Scenario: Review suggests a change
- **WHEN** plantuml-review finds a layout problem
- **THEN** it describes the change in text and does not modify the diagram
