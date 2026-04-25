# Render Profiles

Target-aware rendering from neutral sources. The `.puml` source is
target-agnostic; the `PLANTUML_TARGET` env var selects a target at render
time, and the project's `.plantuml/_targets/<target>.puml` is included
accordingly.

## Supported targets

| Target | Format | Scale | DPI  | Font size | Max px width | Direction     | Hyperlinks | Shadowing |
|--------|--------|-------|------|-----------|--------------|---------------|------------|-----------|
| `web`  | svg    | n/a   | n/a  | 14        | —            | top-to-bottom | enabled    | true      |
| `docx` | png    | 3     | 150  | 14        | 5800         | top-to-bottom | disabled   | false     |
| `pdf`  | pdf    | n/a   | 300  | 12        | —            | top-to-bottom | enabled    | true      |
| `pptx` | png    | 3     | 150  | 18        | 4800 (16:9)  | left-to-right | disabled   | false     |

**Rationale per target:**
- **web**: SVG preserves quality at any zoom, supports hyperlinks. No
  DPI concept; font size 14 reads well in browsers.
- **docx**: PNG at scale 3 / 150 DPI looks crisp in Word at 100% zoom
  without bloating the document. Shadowing off = cleaner in print.
  Max 5800 px keeps a single diagram within A4 portrait at ~150 DPI.
- **pdf**: Direct PDF output keeps vectors. 300 DPI is print-friendly.
- **pptx**: 16:9 slides, landscape direction by default. Larger font
  size because slides are seen from distance.

## Invocation pattern

The skill composes the call to `plantuml-convert` like this:

```bash
# 1. Pick target from CLAUDE.md Policy or user override.
TARGET="docx"    # or web | pdf | pptx

# 2. Export env var so !getenv("PLANTUML_TARGET") in the .puml resolves.
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

**Important:** `PLANTUML_TARGET` must be set *before* `plantuml` runs;
PlantUML evaluates `%getenv(...)` at parse time. If it is unset the
source file's `!include` of `_targets/$target.puml` will fail —
this is intentional: it forces the caller to declare a target.

## Default target resolution

1. If user specified a target explicitly in the request → use it.
2. Else if CLAUDE.md Policy has `Primary target: <X>` → use X.
3. Else if Policy has `Additional targets:` → use the first one.
4. Else → `docx` (the enterprise-defaults fallback).

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

After rendering PNG, run:

```bash
W=$(identify -format "%w" "out.png")
[ "$W" -le "$MAX" ] || echo "WARN: $out.png is $W px, max is $MAX"
```

Over-wide diagrams are a warning, not an error: the author may have
intentionally laid out a wide landscape that the consumer will scale to
fit. The skill flags the warning and asks the author whether to re-lay
out (change direction, split the diagram) or accept.

## Adding a new target

1. Append a row to the table above.
2. Create `templates/_targets/<name>.puml` with the target-specific
   `skinparam` overrides.
3. Add the `case` branch to the invocation pattern.
4. Re-run the test suite to validate the new target end-to-end.

No changes needed in individual diagram files — that is the whole point
of keeping sources target-neutral.
