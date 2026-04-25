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
- **Additional targets**: `web`          # optional, comma-separated
- **Theme**: `cerulean-outline`          # PlantUML built-in theme name OR `custom`
- **Layout engine**: `smetana`           # smetana | elk | dot
- **Default direction**: `top-to-bottom` # top-to-bottom | left-to-right
- **Default detail level**: `standard`   # minimal | standard | detailed
- **Label language**: `en`               # en | it | fr | …
- **Brand colors**:
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

- Keys are the text between `**…**:` markers, case-sensitive.
- Values are everything after `:` until `#` (comment) or end-of-line,
  trimmed.
- Nested lists (brand colors) are parsed as sub-key → value.
- Missing optional keys fall back to documented defaults; missing
  required keys (Primary target, Theme, Brand colors) trigger
  bootstrap.

## Generated artifacts: `.plantuml/`

From the Policy the skill generates (and keeps in sync) the directory
`.plantuml/` at the project root, containing:

```
.plantuml/
├── _base.puml         ← single include entry-point
├── _brand.puml        ← !$primary, !$accent, ... variables
├── _fonts.puml        ← font family + size
├── _theme.puml        ← !theme + global skinparam
├── _layout.puml       ← direction + !pragma layout
└── _targets/
    ├── web.puml
    ├── docx.puml
    ├── pdf.puml
    └── pptx.puml
```

Treat `.plantuml/` like a lockfile: it is always regenerable from the
Policy. Do not hand-edit files there; edit the Policy and sync.

## Sync semantics

- **Policy present, `.plantuml/` absent:** regenerate everything.
- **Policy present, `.plantuml/` present:** diff generated content vs
  existing files. If different, overwrite with a diff shown to the
  user in dry-run first.
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
3. On **setup**: run the wizard:
   - *"Primary render target? (web / docx / pdf / pptx)"*
   - *"Theme: built-in PlantUML theme name, or `custom`?"*
     - If `custom`: ask for 5 brand color hex values (primary,
       accent, neutral, surface, danger).
   - *"Font family? (default: Inter, Arial, sans-serif)"*
   - *"Label language? (en / it / fr / … — default: en)"*
   - *"Default detail level? (minimal / standard / detailed — default
     standard)"*
4. Generate the CLAUDE.md Policy section (append if CLAUDE.md exists,
   create it otherwise).
5. Generate `.plantuml/` (see next section).
6. Generate the requested diagram using the freshly configured setup.
7. Confirm to user: *"Setup complete. Policy in CLAUDE.md + `.plantuml/`
   generated. First diagram at <path>."*

## Generation details

### `_brand.puml`

Emit one `!$variable` per brand color + a `skinparam` mapping to hint
themes that honor variable-based palettes. Example output:

```plantuml
' Auto-generated from CLAUDE.md "PlantUML Policy". Do not edit by hand.
!$primary = "#0B5FFF"
!$accent  = "#F59E0B"
!$neutral = "#475569"
!$surface = "#F8FAFC"
!$danger  = "#DC2626"
```

### `_fonts.puml`

```plantuml
skinparam defaultFontName "Inter, Arial, sans-serif"
skinparam defaultFontSize 14
```

### `_theme.puml`

If Policy theme is a built-in:
```plantuml
!theme cerulean-outline
skinparam backgroundColor $surface
skinparam ArrowColor $neutral
skinparam DefaultTextAlignment center
```

If `custom`, skip `!theme` and emit a full skinparam block derived from
brand variables (class background `$surface`, class border `$neutral`,
highlight `$accent`, error `$danger`, etc.). The emitter is documented
in the templates.

### `_layout.puml`

```plantuml
!pragma layout smetana
skinparam linetype ortho
skinparam shadowing true
' direction is set per-diagram unless overridden here
```

If the Policy `Default direction` is `left-to-right`, append
`left to right direction` on its own line.

### `_base.puml`

```plantuml
' Auto-generated from CLAUDE.md "PlantUML Policy".
' Single include entry-point. Do not add target-specific overrides here.
!include _brand.puml
!include _fonts.puml
!include _theme.puml
!include _layout.puml
```

### `_targets/<target>.puml`

See the templates directory for each target's exact content. Example
for `docx`:

```plantuml
skinparam shadowing false
skinparam defaultFontSize 14
skinparam dpi 150
' No hyperlink support in flat PNG rendering; nothing to toggle.
```

## Reverse-init (Policy missing, .plantuml/ exists)

Script parses existing `.plantuml/` to reconstruct a Policy draft:

- `_brand.puml` → brand colors.
- `_fonts.puml` → font family + base size.
- `_theme.puml` → theme name (grep first `!theme …` line) or `custom`.
- `_layout.puml` → layout engine + direction.
- `_targets/` listing → Primary target (first alphabetically found) +
  additional targets (others).
- Max width: inferred from `_targets/docx.puml` `defaultMaxWidth` if
  present, else default 5800.

The user reviews the draft, edits, accepts → Policy added to CLAUDE.md.
