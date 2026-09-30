# Project Configuration

How a project declares its PlantUML identity (styling, target, brand) and
how the skill bootstraps / syncs that configuration.

## Source of truth: CLAUDE.md

Every configured project has a "PlantUML Policy" section in its
CLAUDE.md. This section is human-readable, machine-parseable by the
skill, and takes precedence over any file in `.plantuml/`.

### Section schema

```markdown
## PlantUML Policy

- **Primary target**: `docx`             # web | docx | pdf | pptx
- **Additional targets**: `web`          # optional, comma-separated, or none
- **Theme**: `cerulean-outline`          # PlantUML built-in theme name OR `custom`
- **Layout engine**: `smetana`           # smetana | elk | dot
- **Default direction**: `top-to-bottom` # top-to-bottom | left-to-right
- **Default detail level**: `standard`   # minimal | standard | detailed
- **Label language**: `en`               # en | it | fr | …
- **Brand colors**:                      # required only for Theme `custom`
  - primary:   `#0B5FFF`
  - accent:    `#F59E0B`
  - neutral:   `#475569`
  - surface:   `#F8FAFC`
  - danger:    `#DC2626`
- **Font family**: `Inter, Arial, sans-serif`
- **Base font size**: `14`
- **Max width (docx)**: `5800`
- **Recorded on**: `YYYY-MM-DD`
```

### Parsing rules

The bundled generator (`plantuml-bootstrap/scripts/generate-config.sh`)
implements these rules; `generate-config.sh policy` prints the result.

- The section runs from `## PlantUML Policy` to the next `#` or `##`
  heading. Keys elsewhere in CLAUDE.md are ignored.
- Keys are the text between `**…**` markers, matched case-insensitively.
- Backticks around values are optional and removed. A `#` preceded by
  whitespace starts a comment; a value may itself start with `#` (colors).
- Nested lists (brand colors) are parsed as sub-key → value.
- Required: Primary target and Theme. Brand colors are required only when
  Theme is `custom`, and then all five. With a built-in theme they are
  optional: any given are written to `_brand.puml` as variables.
- Colors are `#RRGGBB` or `#RRGGBBAA`. Base font size is a whole number
  from 6 to 96.
- Missing optional keys fall back to the defaults shown in the schema
  (Layout engine `smetana`, Default direction `top-to-bottom`, Font family
  `Inter, Arial, sans-serif`, Base font size `14`, Max width (docx)
  `5800`). An invalid value stops generation with an error; nothing is
  written.

## Generated artifacts: `.plantuml/`

From the Policy the generator writes the directory `.plantuml/` at the
project root:

```
.plantuml/
├── _base.puml         ← single include entry-point; fallback target
├── _brand.puml        ← !$primary, !$accent, ... variables
├── _theme.puml        ← !theme <name>, or the custom skinparam set
├── _fonts.puml        ← font family + $base_font_size
├── _layout.puml       ← !pragma layout, $direction, $apply_direction()
└── _targets/
    └── <target>.puml  ← one per declared target (web, docx, pdf, pptx)
```

Every file starts with a header line `' generated-sha256: <hash>`, the
SHA-256 of the rest of the file (after stripping CR and trailing blanks
per line). A file whose body no longer matches its own header was edited
by hand; `generate-config.sh verify` reports it. No other state is kept.

Treat `.plantuml/` like a lockfile: it is always regenerable from the
Policy. Do not hand-edit files there; edit the Policy and sync.

## Sync semantics

- **Policy present, `.plantuml/` absent:** generate everything
  (`generate-config.sh generate`).
- **Policy present, `.plantuml/` present:** run `plantuml-migrate`. It
  generates into a temp directory, shows the diff, asks before replacing
  a hand-edited or header-less file, and backs up `.plantuml/` before
  writing. The generator itself never writes into a non-empty directory.
- **Policy absent, `.plantuml/` present:** reverse-init — extract a
  Policy draft from existing files and ask the user to review it
  before adding to CLAUDE.md.
- **Policy absent, `.plantuml/` absent:** bootstrap dialog (see below).

## Bootstrap dialog (progressive)

Trigger: first `.puml` authoring request in a project where both Policy
and `.plantuml/` are missing.

Script:

1. Ask the user: *"This project has no PlantUML configuration. Do you
   want a shared project setup (recommended) or a one-shot diagram
   with inline defaults?"*
2. On **one-shot**: generate the diagram inline with safe defaults
   (`theme plain`, target `docx`, font `Inter, 14`, no brand colors).
   Prepend comment: `' TODO: run /plantuml-init to share styling`.
   Skip to rendering.
3. On **setup**: run the `plantuml-bootstrap` skill
   (`${CLAUDE_PLUGIN_ROOT}/skills/plantuml-bootstrap/SKILL.md`). It runs the
   wizard, appends the Policy section to CLAUDE.md, and generates `.plantuml/`.
4. Generate the requested diagram using the freshly configured setup.
5. Confirm to user: *"Setup complete. Policy in CLAUDE.md + `.plantuml/`
   generated. First diagram at <path>."*

## Generation details

Each file below is shown without its header line and notice comment.

### `_brand.puml`

One `!$variable` per brand color the Policy declares:

```plantuml
!$primary = "#0B5FFF"
!$accent  = "#F59E0B"
!$neutral = "#475569"
!$surface = "#F8FAFC"
!$danger  = "#DC2626"
```

With a built-in theme and no brand colors, the file holds only a comment.

### `_theme.puml`

Built-in theme: `!theme <name>` and nothing else, so the theme's own
palette is not mixed with brand variables the Policy may not declare.

`custom`: a copy of `templates/_theme.puml`, a full skinparam block derived
from the brand variables (class background `$surface`, class border
`$neutral`, header `$primary`, highlight `$accent`, …).

### `_fonts.puml`

```plantuml
!$base_font_size = 14
skinparam defaultFontName "Inter, Arial, sans-serif"
skinparam defaultFontSize $base_font_size
```

`_base.puml` includes it after `_theme.puml`, because a built-in theme
resets the font family and size.

### `_layout.puml`

`templates/_layout.puml` with the Policy's values on two lines:

```plantuml
!pragma layout smetana            ' Layout engine
…
!$direction = "top-to-bottom"     ' Default direction
!procedure $apply_direction()
  !if ($direction == "left-to-right")
left to right direction
  !endif
!endprocedure
```

`left to right direction` is a syntax error in sequence, activity, timing,
gantt, wbs, interaction-overview and nwdiag diagrams, so no partial writes
it globally. Diagrams of the other types call `$apply_direction()` after
the include chain.

### `_base.puml`

```plantuml
!if (%not(%variable_exists("$target")) || $target == "")
  !$target = "docx"               ' the Policy's Primary target
!endif
!include _brand.puml
!include _theme.puml
!include _fonts.puml
!include _layout.puml
```

### `_targets/<target>.puml`

Copied from `templates/_targets/`, one per declared target. Example for
`docx`:

```plantuml
skinparam shadowing false
skinparam dpi 150
' No hyperlink rendering in flat PNG; keep labels self-explanatory.
```

The pdf and pptx files set `defaultFontSize` from `$base_font_size` (−2 and
+4); pptx also sets `$direction` to left-to-right.

## Reverse-init (Policy missing, .plantuml/ exists)

Parse the existing `.plantuml/` to reconstruct a Policy draft, skipping
comment lines (including the `' generated-sha256:` header):

- `_brand.puml` → brand colors.
- `_fonts.puml` → font family, and base size from `$base_font_size` (or
  `defaultFontSize` in older files).
- `_theme.puml` → theme name (grep first `!theme …` line) or `custom`.
- `_layout.puml` → layout engine from `!pragma layout`; direction from
  `!$direction`, or from a bare `left to right direction` in older files.
- `_base.puml` → Primary target from the fallback `!$target = "<name>"`.
  If absent (older files), ask the user which of the `_targets/` files is
  primary.
- `_targets/` listing → additional targets (the others).
- Max width (docx): not stored in `.plantuml/`; propose the default 5800
  and ask.

The user reviews the draft, edits, accepts → Policy added to CLAUDE.md.
