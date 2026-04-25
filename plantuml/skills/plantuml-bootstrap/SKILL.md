---
name: plantuml-bootstrap
description: Set up a project for PlantUML authoring — creates `## PlantUML Policy` in CLAUDE.md and materializes `.plantuml/` from the policy. Use when a project has `.puml` work but no policy, or to migrate an existing `.plantuml/` back to a policy (reverse mode). Accepts `mode=bootstrap` (default) or `mode=reverse`.
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
---

# PlantUML Bootstrap

Set up the **current project** for use with the `plantuml-authoring` skill.
Templates live inside this plugin; resolve them via `${CLAUDE_PLUGIN_ROOT}`.

## Locate the templates (first Bash block in every flow)

```bash
SKILL_DIR="${CLAUDE_PLUGIN_ROOT}/skills/plantuml-authoring"
SKILL_TPL="$SKILL_DIR/templates"
[ -d "$SKILL_TPL" ] || { echo "ERROR: plantuml-authoring assets missing in plugin"; exit 1; }
```

When the canonical schema for the Policy section is needed, read
`$SKILL_DIR/project-config.md` via the Read tool with that resolved path.

## Mode dispatch

Read the `mode` argument. Default `bootstrap`. If `reverse`, jump to the
**Reverse** section at the bottom; otherwise run **State detection** then
**Wizard**, **Append Policy**, **Generation**, **Validate**, **Confirm**.

## State detection

Run from the project root (`pwd`). Check four facts:

1. Does `CLAUDE.md` exist?
2. Does `CLAUDE.md` contain `## PlantUML Policy`?
3. Does `.plantuml/` exist?
4. Does `.plantuml/_base.puml` exist?

Branches:
- Policy ✓ + `.plantuml/` ✓ → tell the user it is already configured; ask
  whether to **regenerate** `.plantuml/` from policy, or exit. Stop.
- Policy ✓ + `.plantuml/` ✗ → run **Generation** only.
- Policy ✗ + `.plantuml/` ✓ → suggest `mode=reverse` and stop.
- Policy ✗ + `.plantuml/` ✗ → run **Wizard**, then **Generation**.

## Wizard

Use `AskUserQuestion` if available (preferred), otherwise ask in chat.
Collect:

1. **Primary target**: `web | docx | pdf | pptx`. Default `docx` for
   enterprise contexts; `web` for OSS docs.
2. **Additional targets**: subset of the above. Optional.
3. **Theme**: a built-in PlantUML theme name (e.g. `cerulean-outline`,
   `plain`, `vibrant`, `materia`) OR `custom`. If `custom`, ask for 5
   brand colors:
   - primary, accent, neutral, surface, danger
   - each must be a 6- or 8-digit hex (`#RRGGBB[AA]`)
4. **Font family**: default `Inter, Arial, sans-serif`.
5. **Base font size**: default `14`.
6. **Default detail level**: `minimal | standard | detailed`. Default `standard`.
7. **Label language**: ISO code (`en`, `it`, `fr`, …). Default `en`.
8. **Layout engine**: `smetana | elk | dot`. Default `smetana`.
9. **Default direction**: `top-to-bottom | left-to-right`. Default `top-to-bottom`.
10. **Max width (docx)**: pixels. Default `5800`.

## Append Policy section to CLAUDE.md

Format per `$SKILL_DIR/project-config.md` § "Section schema". Header:
`## PlantUML Policy`. Add `**Recorded on**: YYYY-MM-DD`.

If `CLAUDE.md` does not exist, create it with `# <Project Name>` derived
from the directory, followed by the Policy section. Otherwise append.

## Generation

```bash
mkdir -p .plantuml/_targets
cp "$SKILL_TPL/_base.puml"   .plantuml/_base.puml
cp "$SKILL_TPL/_layout.puml" .plantuml/_layout.puml
```

Per-file substitutions:

- `.plantuml/_brand.puml`:
  ```plantuml
  ' Auto-generated from CLAUDE.md "PlantUML Policy". Do not edit by hand.
  !$primary = "<value>"
  !$accent  = "<value>"
  !$neutral = "<value>"
  !$surface = "<value>"
  !$danger  = "<value>"
  ```
- `.plantuml/_fonts.puml`:
  ```plantuml
  skinparam defaultFontName "<font family>"
  skinparam defaultFontSize <base size>
  ```
- `.plantuml/_theme.puml`: built-in theme → `!theme <name>` followed by
  `skinparam backgroundColor $surface` and `skinparam ArrowColor $neutral`.
  Otherwise (custom): `cp "$SKILL_TPL/_theme.puml" .plantuml/_theme.puml`.
- `.plantuml/_layout.puml`: append `left to right direction` at end if
  policy direction is `left-to-right`.
- `.plantuml/_targets/<target>.puml` for each target (Primary + Additional):
  ```bash
  for t in <primary> <additional...>; do
    cp "$SKILL_TPL/_targets/$t.puml" ".plantuml/_targets/$t.puml"
  done
  ```

## Validate

```bash
PROJECT_ROOT="$(pwd)"
TMPDIR="$(mktemp -d -t plantuml-bootstrap-validate.XXXXXX)"
trap 'rm -rf "$TMPDIR"' EXIT

ln -s "$PROJECT_ROOT/.plantuml" "$TMPDIR/.plantuml"

cat > "$TMPDIR/_smoke.puml" <<'EOF'
@startuml _Smoke
!$target = %getenv("PLANTUML_TARGET")
!include .plantuml/_base.puml
!include .plantuml/_targets/$target.puml
class X
@enduml
EOF

( cd "$TMPDIR" && PLANTUML_TARGET=<primary-target> plantuml -checkonly _smoke.puml )
```

Must exit 0.

## Confirm

```
PlantUML Policy added to <project-root>/CLAUDE.md
Generated <project-root>/.plantuml/:
  _base.puml, _brand.puml, _fonts.puml, _theme.puml, _layout.puml,
  _targets/<each>.puml

To author: invoke plantuml-authoring or just create *.puml.
To render: invoke plantuml-convert, or run
  PLANTUML_TARGET=<target> plantuml -t<format> -Sscale=3 <file>.puml
```

## Reverse

(`mode=reverse`) — `.plantuml/` exists but no Policy in CLAUDE.md.
Reconstruct a draft Policy from existing files (paths relative to project
root):

1. `.plantuml/_brand.puml` → `!$<name> = "#…"` lines as brand colors.
2. `.plantuml/_fonts.puml` → `defaultFontName` and `defaultFontSize`.
3. `.plantuml/_theme.puml` → `!theme <name>` if present, else `custom`.
4. `.plantuml/_layout.puml` → `!pragma layout`, plus `left to right
   direction` presence implies LR.
5. `.plantuml/_targets/*.puml` → first alphabetically = primary, rest = additional.
6. Max width: parse `_targets/docx.puml` for `defaultMaxWidth N`, else `5800`.

Show the draft, confirm with the user, then append the section to
CLAUDE.md as in the bootstrap flow. Do NOT regenerate `.plantuml/` —
it is already the source of truth in this direction.

## Don'ts

- Do NOT modify the plugin (it is read-only at runtime).
- Do NOT hardcode any path containing `/Users/<name>/` or `/home/<name>/`.
- Do NOT translate the Policy section or `.plantuml/` files — they stay
  English regardless of `Label language` (which controls diagram-content
  labels, not config).
- Do NOT commit secrets — brand colors are public.
- Do NOT regenerate without asking when the project is already configured.
