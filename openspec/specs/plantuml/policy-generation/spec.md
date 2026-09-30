# plantuml/policy-generation Specification

## Purpose
Defines how the `## PlantUML Policy` section of CLAUDE.md becomes the `.plantuml/` partials: one
bundled generator shared by plantuml-bootstrap and plantuml-migrate, so the same Policy always
yields the same bytes and every Policy value reaches a generated file.

## Requirements

### Requirement: One bundled generator writes .plantuml/ from the Policy
plantuml-bootstrap and plantuml-migrate SHALL obtain the `.plantuml/` files only from the bundled
script `plantuml-bootstrap/scripts/generate-config.sh`, never from content the model writes. The
generator SHALL be deterministic, SHALL validate the Policy before writing, SHALL write nothing
when the Policy is invalid, and SHALL refuse to write into a non-empty directory.

#### Scenario: Same Policy, same bytes
- **WHEN** the generator runs twice on the same Policy into two empty directories
- **THEN** `diff -r` between the two directories is empty

#### Scenario: CRLF line endings
- **WHEN** CLAUDE.md uses CRLF line endings
- **THEN** the generator reads the same Policy, with no carriage return in any value, and writes the same bytes as for LF

#### Scenario: Invalid Policy
- **WHEN** the Policy's Primary target is `html`, or Theme is `custom` with a brand color missing
- **THEN** the generator exits 2 with an `ERROR:` line naming the key and writes no file

#### Scenario: Existing .plantuml/
- **WHEN** bootstrap finds a Policy and a non-empty `.plantuml/`
- **THEN** it does not regenerate the files itself and routes the user to plantuml-migrate

### Requirement: Every generated file carries a hash of its own body
Each generated file SHALL start with the line `' generated-sha256: <hash>`, where `<hash>` is the
SHA-256 of the rest of the file after CR and trailing blanks are stripped from each line. No other
state SHALL record what was generated.

#### Scenario: Header matches body
- **WHEN** the generator writes `.plantuml/_brand.puml`
- **THEN** its first line holds the SHA-256 of the file's remaining lines

### Requirement: The primary target is the fallback target
The generated `_base.puml` SHALL fall back to the Policy's Primary target when `PLANTUML_TARGET`
is unset, and `.plantuml/_targets/` SHALL hold a file only for each declared target.

#### Scenario: docx-only Policy
- **WHEN** the Policy declares Primary target `docx` and no Additional targets
- **THEN** `_base.puml` falls back to `docx`, `_targets/` holds only `docx.puml`, and a diagram rendered without `PLANTUML_TARGET` compiles

### Requirement: Every Policy value takes effect
The generator SHALL write the Layout engine as the `!pragma layout` line, the Default direction as
`$direction`, the Font family and Base font size in `_fonts.puml` after the theme so a built-in
theme cannot reset them, and target font sizes derived from the base size (pdf −2, pptx +4). No
shared partial SHALL contain a bare `left to right direction`; diagrams opt in through
`$apply_direction()`. The docx Max width SHALL be read from the Policy by the render width check.

#### Scenario: Non-default layout, direction and font
- **WHEN** the Policy sets Layout engine `elk`, Default direction `left-to-right` and Base font size `16` with theme `cerulean-outline`
- **THEN** `_layout.puml` has `!pragma layout elk` and `$direction = "left-to-right"`, and a docx render uses font size 16 and the Policy font family

#### Scenario: Sequence diagram on the pptx target
- **WHEN** a sequence diagram is checked with `PLANTUML_TARGET=pptx`
- **THEN** it compiles, because the left-to-right direction applies only to diagrams that call `$apply_direction()`

### Requirement: Brand colors are required only for a custom theme
The Policy SHALL need all five brand colors only when Theme is `custom`. With a built-in theme,
`_theme.puml` SHALL hold only `!theme <name>`, and `_brand.puml` SHALL define only the colors the
Policy declares.

#### Scenario: Built-in theme without colors
- **WHEN** the Policy names theme `plain` and no brand colors
- **THEN** generation succeeds, `_theme.puml` is `!theme plain`, and `_brand.puml` defines no variables
