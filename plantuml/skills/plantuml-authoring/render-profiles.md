# Render Profiles

Target-aware rendering from neutral sources. The `.puml` source is
target-agnostic; the `PLANTUML_TARGET` env var selects a target at render
time, and the project's `.plantuml/_targets/<target>.puml` is included
accordingly.

## Supported targets

| Target | Format | Scale | DPI  | Font size | Max px width | Direction     | Hyperlinks | Shadowing |
|--------|--------|-------|------|-----------|--------------|---------------|------------|-----------|
| `web`  | svg    | n/a   | n/a  | base      | —            | Policy        | enabled    | true      |
| `docx` | png    | 3     | 150  | base      | Policy (5800)| Policy        | disabled   | false     |
| `pdf`  | pdf    | n/a   | 300  | base − 2  | —            | Policy        | enabled    | true      |
| `pptx` | png    | 3     | 150  | base + 4  | 4800 (16:9)  | left-to-right | disabled   | false     |

- **Font size**: "base" is the Policy's Base font size (default 14), set as
  `$base_font_size` in `_fonts.puml`; each target file derives its size
  from it, so changing the Policy changes every target.
- **Max px width** for docx is the Policy's `Max width (docx)`.
- **Direction**: "Policy" is the Policy's Default direction. It applies to
  the diagrams that call `$apply_direction()` after the include chain (see
  `diagrams/<type>.md`); pptx switches those diagrams to left-to-right.
  Sequence, activity, timing, gantt, wbs, interaction-overview and nwdiag
  diagrams reject `left to right direction`, so no partial writes it.

**Rationale per target:**
- **web**: SVG preserves quality at any zoom, supports hyperlinks. No
  DPI concept; font size 14 reads well in browsers.
- **docx**: PNG at scale 3 / 150 DPI looks crisp in Word at 100% zoom
  without bloating the document. Shadowing off = cleaner in print.
  Max 5800 px keeps a single diagram within A4 portrait at ~150 DPI.
- **pdf**: Direct PDF output keeps vectors. 300 DPI is print-friendly.
- **pptx**: 16:9 slides, landscape direction for diagrams that call
  `$apply_direction()`. Larger font size because slides are seen from
  distance.

## Invocation pattern

The skill composes the call to `plantuml-convert` like this:

```bash
# 1. Pick target from CLAUDE.md Policy or user override.
TARGET="docx"    # or web | pdf | pptx

# 2. Export env var so %getenv("PLANTUML_TARGET") in the .puml resolves.
export PLANTUML_TARGET="$TARGET"

# 3. Map target → plantuml-convert CLI args.
case "$TARGET" in
  web)  FMT=svg; SCALE_ARGS="";;
  docx) FMT=png; SCALE_ARGS="-Sscale=3";;
  pdf)  FMT=pdf; SCALE_ARGS="";;
  pptx) FMT=png; SCALE_ARGS="-Sscale=3";;
esac

# 4. Invoke plantuml (plantuml-convert skill handles the actual call).
OUT="$(pwd)/dist/diagrams"
mkdir -p "$OUT"
plantuml "-t$FMT" $SCALE_ARGS -o "$OUT" "$SOURCE.puml"
```

**Important:** set `PLANTUML_TARGET` explicitly on every `plantuml` call,
`-checkonly` included. PlantUML evaluates `%getenv(...)` at parse time, and
a project ships `_targets/<target>.puml` only for the targets its Policy
declares. When the variable is unset, `_base.puml` falls back to the
Policy's primary target, which the generator writes into it; that fallback
serves editors and previewers, not validation. A target the Policy does not
declare fails on the missing `_targets/<target>.puml`. That is intended: add
the target to the Policy and run `plantuml-migrate`.

The generator prints the parsed Policy, so a script can read the primary
target and the docx max width instead of parsing CLAUDE.md:

```bash
"${CLAUDE_PLUGIN_ROOT}/skills/plantuml-bootstrap/scripts/generate-config.sh" policy
# primary_target=docx, targets=docx web, max_width_docx=5800, …
```

## Default target resolution

1. If user specified a target explicitly in the request → use it.
2. Else if CLAUDE.md has a Policy → its `Primary target` (required).
3. Else (one-shot diagram without a Policy) → `docx` defaults, inlined in
   the diagram instead of the include chain.

## Multi-target rendering

If the project's Policy lists additional targets (e.g., `Primary target:
docx`, `Additional targets: web`), the skill renders each diagram once
per target by looping:

```bash
for T in docx web; do
  export PLANTUML_TARGET="$T"
  # … render all .puml into dist/$T/
done
```

Output is kept in per-target subdirectories so consumers can pick the
right format.

## Max-width post-check (docx, pptx)

After rendering PNG, if ImageMagick's `identify` is available
(`command -v identify`), compare the width with the limit: for docx the
Policy's `Max width (docx)` (`max_width_docx` in the generator's `policy`
output, default 5800), for pptx 4800.

```bash
MAX="$("${CLAUDE_PLUGIN_ROOT}/skills/plantuml-bootstrap/scripts/generate-config.sh" policy \
  | awk -F= '$1 == "max_width_docx" { print $2 }')"   # pptx: MAX=4800
W=$(identify -format "%w" "$PNG")
[ "$W" -le "$MAX" ] || echo "WARN: $PNG is $W px, max is $MAX"
```

If `identify` is not installed, skip the check and tell the user it was skipped.

Over-wide diagrams are a warning, not an error: the author may have
intentionally laid out a wide landscape that the consumer will scale to
fit. The skill flags the warning and asks the author whether to re-lay
out (change direction, split the diagram) or accept.

## Adding a new target

1. Append a row to the table above.
2. Create `templates/_targets/<name>.puml` with the target-specific
   `skinparam` overrides.
3. Add the name to `ALLOWED_TARGETS` in
   `plantuml-bootstrap/scripts/generate-config.sh`.
4. Add the `case` branch to the invocation pattern.
5. Run `plantuml/tests/smoke/*.sh` and the variant test suite.

No changes needed in individual diagram files — that is the whole point
of keeping sources target-neutral.
