# Spec Delta

## Purpose

Defines how plantuml diagrams are compiled and compared with baselines: always against an explicit
target, with includes resolved the same way at every level, by one bundled matrix script.

## ADDED Requirements

### Requirement: Every compile check names its target
Every `plantuml -checkonly` that the plantuml skills run in a project with a Policy SHALL set
`PLANTUML_TARGET` explicitly: authoring and review use the Primary target; bootstrap, validate and
migrate check each declared target.

#### Scenario: docx-only project
- **WHEN** plantuml-review checks a valid diagram in a project whose Policy declares only `docx`
- **THEN** it runs `PLANTUML_TARGET=docx plantuml -checkonly <file>`, the check passes, and the review proceeds

### Requirement: One script runs the validation matrix
plantuml-validate and plantuml-migrate SHALL run the bundled `validate-matrix.sh`, which calls
`plantuml` once per (diagram, declared target) with the file path as argument, never stdin, and
prints one JSON object per cell. Any non-zero exit from `plantuml` SHALL make the cell `fail`, or
`error` when blessing.

#### Scenario: Nested diagram at every level
- **WHEN** `diagrams/auth/Login.puml` includes `../../.plantuml/_base.puml`
- **THEN** it passes at `checkonly` and renders at `svg-hash`, because both levels resolve includes from the file's own directory

### Requirement: checkonly keeps no baselines
At `level=checkonly` validation SHALL read and write no baseline; in `mode=bless` it SHALL report
the compile result and write nothing, so a failing file never becomes a passing baseline.

#### Scenario: Blessing a broken file at checkonly
- **WHEN** `mode=bless level=checkonly` runs on a project with a diagram that does not compile
- **THEN** that cell is `fail`, no baseline file is written, and a later check still fails

### Requirement: Baselines are written only after the visual check
At `level=svg-hash`, `mode=bless` SHALL render preview PNGs and run the visual smoke check before it
writes any baseline. A failed check SHALL stop the bless unless the user explicitly confirms. A cell
that does not render SHALL get no baseline. The SVG hash SHALL exclude PlantUML's version and source
processing instructions and comments.

#### Scenario: Visual check fails
- **WHEN** the visual checker reports `fail` for one image during `mode=bless level=svg-hash`
- **THEN** the skill shows the failure, asks whether to bless anyway, and writes no baseline without a yes

#### Scenario: Built-in theme
- **WHEN** `mode=bless level=svg-hash` runs in a project whose Theme is `cerulean-outline` and whose Policy declares brand colors
- **THEN** the visual checker receives `primary_color: null`, returns `skipped` for the color check, and the bless is not stopped by it

#### Scenario: PlantUML upgrade
- **WHEN** baselines blessed with one PlantUML version are checked with another that renders the same diagram
- **THEN** the cells pass
