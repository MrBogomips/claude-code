# plantuml/diagram-lint Specification

## Purpose
Defines which files plantuml-lint checks with which rules, and the include-target check that backs
its "broken includes" claim.

## Requirements

### Requirement: Include files are exempt from diagram-only rules
`.iuml` files SHALL NOT be in lint's default scope. When passed explicitly, `.iuml` files and
`_*.puml` partials SHALL be checked only against R2 and R6.

#### Scenario: Shared macro file
- **WHEN** lint runs on a project containing `diagrams/macros.iuml` with no `@startuml` block
- **THEN** no R1, R4 or R5 violation is reported for it

### Requirement: R6 reports include targets that do not exist
For each relative `!include`, lint SHALL resolve the path against the directory of the including
file, expand `$target` once per declared target, and report a violation when the resolved file
cannot be read. Standard-library includes, URLs, absolute paths and paths with other variables
SHALL be skipped.

#### Scenario: Root-relative include in a nested diagram
- **WHEN** `diagrams/login.puml` contains `!include .plantuml/_base.puml`
- **THEN** lint reports R6 with the resolved path `diagrams/.plantuml/_base.puml`

#### Scenario: Undeclared target file
- **WHEN** the Policy declares `docx` and `web` but `.plantuml/_targets/web.puml` is missing
- **THEN** lint reports R6 for each diagram's `_targets/$target.puml` include with target `web`
