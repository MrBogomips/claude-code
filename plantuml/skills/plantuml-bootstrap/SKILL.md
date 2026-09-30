---
name: plantuml-bootstrap
description: Set up a project for PlantUML authoring — creates `## PlantUML Policy` in CLAUDE.md and generates `.plantuml/` from the policy with a bundled script. Use when a project has `.puml` work but no policy, or to recover a policy from an existing `.plantuml/` (reverse mode). Accepts `mode=bootstrap` (default) or `mode=reverse`. To regenerate `.plantuml/` after a policy change, use plantuml-migrate.
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
---

# PlantUML Bootstrap

Set up the **current project** for use with the `plantuml-authoring` skill.
Templates and the generator live inside this plugin; resolve them via
`${CLAUDE_PLUGIN_ROOT}`.

## Locate the plugin assets (first Bash block in every flow)

```bash
SKILL_DIR="${CLAUDE_PLUGIN_ROOT}/skills/plantuml-authoring"
GEN="${CLAUDE_PLUGIN_ROOT}/skills/plantuml-bootstrap/scripts/generate-config.sh"
[ -d "$SKILL_DIR/templates" ] && [ -f "$GEN" ] || { echo "ERROR: plantuml plugin assets missing"; exit 1; }
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
- Policy ✓ + `.plantuml/` ✓ → tell the user it is already configured. If
  they want `.plantuml/` regenerated from the Policy, run `plantuml-migrate`:
  it shows the diff, asks before replacing hand-edited files, and backs up
  `.plantuml/` first. Stop.
- Policy ✓ + `.plantuml/` ✗ → run **Generation** only.
- Policy ✗ + `.plantuml/` ✓ → suggest `mode=reverse` and stop.
- Policy ✗ + `.plantuml/` ✗ → run **Wizard**, then **Generation**.

## Wizard

Use `AskUserQuestion` if available (preferred), otherwise ask in chat.
Collect:

1. **Primary target**: `web | docx | pdf | pptx`. Default `docx` for
   enterprise contexts; `web` for OSS docs. It is also the fallback when a
   renderer runs without `PLANTUML_TARGET`.
2. **Additional targets**: subset of the above. Optional.
3. **Theme**: a built-in PlantUML theme name (e.g. `cerulean-outline`,
   `plain`, `vibrant`, `materia`) OR `custom`. Only if `custom`, ask for 5
   brand colors; a built-in theme brings its own palette:
   - primary, accent, neutral, surface, danger
   - each must be a 6- or 8-digit hex (`#RRGGBB[AA]`)
4. **Font family**: default `Inter, Arial, sans-serif`.
5. **Base font size**: default `14`. The targets derive from it: web and
   docx use it, pdf 2 points less, pptx 4 points more.
6. **Default detail level**: `minimal | standard | detailed`. Default `standard`.
7. **Label language**: ISO code (`en`, `it`, `fr`, …). Default `en`.
8. **Layout engine**: `smetana | elk | dot`. Default `smetana`. `dot`
   needs Graphviz installed.
9. **Default direction**: `top-to-bottom | left-to-right`. Default
   `top-to-bottom`. It applies to diagrams that call `$apply_direction()`
   (see `$SKILL_DIR/render-profiles.md`).
10. **Max width (docx)**: pixels. Default `5800`. Used by the render
    width check.

## Append Policy section to CLAUDE.md

Format per `$SKILL_DIR/project-config.md` § "Section schema". Header:
`## PlantUML Policy`. Add `**Recorded on**: YYYY-MM-DD`. Omit the Brand
colors entry when the theme is built-in and the user gave none.

If `CLAUDE.md` does not exist, create it with `# <Project Name>` derived
from the directory, followed by the Policy section. Otherwise append.

## Generation

The bundled generator writes every partial from the Policy, so the files
are the same bytes on every run and `plantuml-migrate` can compare them:

```bash
bash "$GEN" generate --policy CLAUDE.md --out .plantuml
```

It validates the Policy first and writes nothing on an error (exit 2):
show the `ERROR:` line to the user, fix the Policy with them, and run it
again. It refuses a non-empty `.plantuml/`; that case belongs to
`plantuml-migrate`. What it writes, per `$SKILL_DIR/project-config.md`
§ "Generation details":

- `_base.puml` with the Primary target as the fallback `$target`;
- `_brand.puml`, `_theme.puml`, `_fonts.puml`, `_layout.puml` from the
  Policy values (layout engine, direction, font family and size);
- `_targets/<target>.puml` for the Primary and each Additional target;
- a `' generated-sha256: <hash>` header on every file, which lets
  `plantuml-migrate` tell hand edits from Policy changes.

## Validate

Compile a smoke diagram against every declared target, with the target
set explicitly:

```bash
PROJECT_ROOT="$(pwd)"
SMOKE_DIR="$(mktemp -d -t plantuml-bootstrap-validate.XXXXXX)"
trap 'rm -rf "$SMOKE_DIR"' EXIT

ln -s "$PROJECT_ROOT/.plantuml" "$SMOKE_DIR/.plantuml"

cat > "$SMOKE_DIR/_smoke.puml" <<'EOF'
@startuml _Smoke
!$target = %getenv("PLANTUML_TARGET")
!include .plantuml/_base.puml
!include .plantuml/_targets/$target.puml
class X
@enduml
EOF

TARGETS="$(bash "$GEN" policy | awk -F= '$1 == "targets" { print $2 }')"
for t in $TARGETS; do
  ( cd "$SMOKE_DIR" && PLANTUML_TARGET="$t" plantuml -checkonly _smoke.puml ) \
    || echo "FAILED for target $t"
done
```

Every target must pass. If `plantuml` is not installed, say so and skip
this step; the generated files are still valid input.

## Confirm

```
PlantUML Policy added to <project-root>/CLAUDE.md
Generated <project-root>/.plantuml/:
  _base.puml, _brand.puml, _fonts.puml, _theme.puml, _layout.puml,
  _targets/<each>.puml

To author: invoke plantuml-authoring or just create *.puml. A diagram at
  diagrams/<name>.puml includes ../.plantuml/_base.puml.
To render: invoke plantuml-convert, or run
  PLANTUML_TARGET=<target> plantuml -t<format> -Sscale=3 <file>.puml
```

## Reverse

(`mode=reverse`) — `.plantuml/` exists but no Policy in CLAUDE.md.
Reconstruct a draft Policy from existing files (paths relative to project
root), skipping comment lines such as the `' generated-sha256:` header:

1. `.plantuml/_brand.puml` → `!$<name> = "#…"` lines as brand colors.
2. `.plantuml/_fonts.puml` → `defaultFontName`, and the base size from
   `!$base_font_size` (older files: `defaultFontSize`).
3. `.plantuml/_theme.puml` → `!theme <name>` if present, else `custom`.
4. `.plantuml/_layout.puml` → `!pragma layout` as the engine; the direction
   from `!$direction` (older files: a bare `left to right direction` means
   left-to-right).
5. `.plantuml/_base.puml` → the fallback `!$target = "<name>"` as the Primary
   target. Older files have none: ask which `_targets/*.puml` is primary.
   The other `_targets/*.puml` files are the Additional targets.
6. Max width (docx): not stored in `.plantuml/`; propose `5800` and ask.

Show the draft, confirm with the user, then append the section to
CLAUDE.md as in the bootstrap flow. Do NOT regenerate `.plantuml/` —
it is already the source of truth in this direction. Suggest
`plantuml-migrate` afterwards if the user wants the files brought in line
with the generator (it adds the hash headers, with a backup).

## Don'ts

- Do NOT modify the plugin (it is read-only at runtime).
- Do NOT hardcode any path containing `/Users/<name>/` or `/home/<name>/`.
- Do NOT translate the Policy section or `.plantuml/` files — they stay
  English regardless of `Label language` (which controls diagram-content
  labels, not config).
- Do NOT overwrite an existing `.plantuml/` here; `plantuml-migrate`
  regenerates it with a diff, a confirmation and a backup.
