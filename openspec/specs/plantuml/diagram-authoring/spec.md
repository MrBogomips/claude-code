# plantuml/diagram-authoring Specification

## Purpose
Defines the include header that plantuml-authoring writes, so diagrams outside the project root
compile and follow the Policy's direction without breaking diagram types that reject it.

## Requirements

### Requirement: Include paths are relative to the diagram's own directory
plantuml-authoring and every snippet in `diagrams/*.md` SHALL write `!include` paths to `.plantuml/`
relative to the diagram file's directory, with one `../` per directory between the project root
and the file.

#### Scenario: Diagram one level down
- **WHEN** the author asks for `diagrams/login.puml`
- **THEN** the header includes `../.plantuml/_base.puml` and `../.plantuml/_targets/$target.puml`, and the file compiles for each declared target

### Requirement: Direction is applied only by diagrams that accept it
Snippets of types that accept a layout direction SHALL call `$apply_direction()` after the include
chain. Sequence, activity, timing, gantt, wbs, interaction-overview and nwdiag snippets SHALL NOT.

#### Scenario: Every snippet on every target
- **WHEN** each snippet is saved as `diagrams/<name>.puml` in a project with a left-to-right Policy and all four targets
- **THEN** every snippet passes `plantuml -checkonly` for web, docx, pdf and pptx
