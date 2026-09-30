#!/usr/bin/env bash
set -euo pipefail

# Behavioural test for the Policy -> .plantuml/ generator shared by
# plantuml-bootstrap and plantuml-migrate. Runs without plantuml installed.

PLUGIN_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
GEN="$PLUGIN_ROOT/skills/plantuml-bootstrap/scripts/generate-config.sh"
FIXTURES="$PLUGIN_ROOT/tests/fixtures"

fail() { echo "FAIL: $*" >&2; exit 1; }

[[ -f "$GEN" ]] || fail "missing $GEN"
[[ -x "$GEN" ]] || fail "$GEN is not executable"

if command -v shasum >/dev/null 2>&1; then
  sha() { shasum -a 256 | awk '{print $1}'; }
elif command -v sha256sum >/dev/null 2>&1; then
  sha() { sha256sum | awk '{print $1}'; }
else
  fail "neither shasum nor sha256sum is available"
fi

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

# run <cmd...>: capture combined output in OUT and the exit code in RC.
run() {
  set +e
  OUT="$("$@" 2>&1)"
  RC=$?
  set -e
}

file_list() { ( cd "$1" && find . -type f | sed 's|^\./||' | sort | tr '\n' ' ' ); }

assert_headers() {
  local dir="$1" f first body_hash
  while IFS= read -r f; do
    first="$(head -n 1 "$dir/$f")"
    [[ "$first" =~ ^\'\ generated-sha256:\ [0-9a-f]{64}$ ]] || fail "$f: bad header '$first'"
    body_hash="$(tail -n +2 "$dir/$f" | sha)"
    [[ "$first" == "' generated-sha256: $body_hash" ]] || fail "$f: header hash does not match body"
  done < <(cd "$dir" && find . -type f -name '*.puml' | sed 's|^\./||' | sort)
}

# --- docx-only Policy: built-in theme, elk, left-to-right, font size 16 ---
cp -R "$FIXTURES/docx-only-project" "$WORK/docx"
cd "$WORK/docx"

run "$GEN" generate --policy CLAUDE.md --out .plantuml
[[ $RC -eq 0 ]] || fail "generate (docx-only) exited $RC: $OUT"

expected="_base.puml _brand.puml _fonts.puml _layout.puml _targets/docx.puml _theme.puml "
[[ "$(file_list .plantuml)" == "$expected" ]] || fail "unexpected files: $(file_list .plantuml)"
assert_headers .plantuml

grep -qF '!$target = "docx"' .plantuml/_base.puml || fail "_base.puml fallback is not the primary target"
grep -qF '"web"' .plantuml/_base.puml && fail "_base.puml still falls back to web"
order="$(grep -E '^!include ' .plantuml/_base.puml | tr '\n' ' ')"
[[ "$order" == "!include _brand.puml !include _theme.puml !include _fonts.puml !include _layout.puml " ]] \
  || fail "_base.puml include order is '$order' (fonts must follow the theme)"

grep -qxF '!pragma layout elk' .plantuml/_layout.puml || fail "_layout.puml ignores the Policy layout engine"
grep -qE '^!pragma layout smetana' .plantuml/_layout.puml && fail "_layout.puml still hardcodes smetana"
grep -qxF '!$direction = "left-to-right"' .plantuml/_layout.puml || fail "_layout.puml misses the Policy direction"
outside="$(awk '/^!procedure/ { p = 1 } !p && /^left to right direction$/ { n++ } /^!endprocedure/ { p = 0 } END { print n + 0 }' .plantuml/_layout.puml)"
[[ "$outside" -eq 0 ]] || fail "_layout.puml applies the direction globally (breaks sequence diagrams)"

grep -qxF '!$base_font_size = 16' .plantuml/_fonts.puml || fail "_fonts.puml ignores the Policy font size"
grep -qxF 'skinparam defaultFontName "Inter, Arial, sans-serif"' .plantuml/_fonts.puml || fail "_fonts.puml font family"
grep -qE 'defaultFontSize[[:space:]]+[0-9]' .plantuml/_targets/docx.puml && fail "_targets/docx.puml overrides the font size with a literal"

grep -qxF '!theme cerulean-outline' .plantuml/_theme.puml || fail "_theme.puml misses the built-in theme"
grep -qE '\$(surface|neutral)' .plantuml/_theme.puml && fail "_theme.puml references brand colors the Policy does not declare"
grep -qE '^!\$' .plantuml/_brand.puml && fail "_brand.puml defines colors the Policy does not declare"

run "$GEN" policy --policy CLAUDE.md
[[ $RC -eq 0 ]] || fail "policy exited $RC: $OUT"
for kv in "primary_target=docx" "targets=docx" "theme=cerulean-outline" "layout_engine=elk" \
          "direction=left-to-right" "base_font_size=16" "max_width_docx=5000" "brand_primary="; do
  grep -qxF "$kv" <<<"$OUT" || fail "policy output misses '$kv': $OUT"
done

# A CLAUDE.md with CRLF line endings yields the same Policy and the same bytes.
awk '{ printf "%s\r\n", $0 }' CLAUDE.md > "$WORK/CLAUDE-crlf.md"
run "$GEN" policy --policy "$WORK/CLAUDE-crlf.md"
[[ $RC -eq 0 ]] || fail "policy on a CRLF CLAUDE.md exited $RC: $OUT"
grep -q $'\r' <<<"$OUT" && fail "policy values from a CRLF CLAUDE.md keep the carriage return"
grep -qxF "primary_target=docx" <<<"$OUT" || fail "CRLF CLAUDE.md: wrong primary target: $OUT"
run "$GEN" generate --policy "$WORK/CLAUDE-crlf.md" --out "$WORK/docx-crlf"
[[ $RC -eq 0 ]] || fail "generate from a CRLF CLAUDE.md exited $RC: $OUT"
diff -r .plantuml "$WORK/docx-crlf" >/dev/null || fail "a CRLF CLAUDE.md generates different files"

# Determinism: a second generation is byte-identical.
run "$GEN" generate --policy CLAUDE.md --out "$WORK/docx-again"
[[ $RC -eq 0 ]] || fail "second generate exited $RC"
diff -r .plantuml "$WORK/docx-again" >/dev/null || fail "generation is not deterministic"

# Never overwrites: a non-empty output directory is refused and left untouched.
before="$(cat .plantuml/_brand.puml)"
run "$GEN" generate --policy CLAUDE.md --out .plantuml
[[ $RC -eq 2 ]] || fail "generate into a non-empty directory exited $RC, expected 2"
[[ "$(cat .plantuml/_brand.puml)" == "$before" ]] || fail "refused generate still changed files"

# --- verify: hand-edit detection from the header hash alone ---
run "$GEN" verify .plantuml
[[ $RC -eq 0 ]] || fail "verify on fresh output exited $RC: $OUT"
[[ "$(grep -c '^ok ' <<<"$OUT")" -eq 6 ]] || fail "verify did not report 6 ok files: $OUT"

# A Policy change is not a hand edit: old files still verify, the diff shows the change.
sed 's/`elk`/`dot`/' CLAUDE.md > CLAUDE.md.new && mv CLAUDE.md.new CLAUDE.md
run "$GEN" generate --policy CLAUDE.md --out "$WORK/docx-dot"
[[ $RC -eq 0 ]] || fail "generate after the Policy change exited $RC"
run "$GEN" verify .plantuml
[[ $RC -eq 0 ]] || fail "files generated from the old Policy were flagged as hand edits: $OUT"
changed="$(diff -rq .plantuml "$WORK/docx-dot" | awk '{print $2}' | sed 's|.*/||' | tr '\n' ' ' || true)"
[[ "$changed" == "_layout.puml " ]] || fail "expected only _layout.puml to change, got '$changed'"

# Line-ending and trailing-space noise is not a hand edit.
awk '{ printf "%s  \r\n", $0 }' .plantuml/_theme.puml > "$WORK/crlf" && cp "$WORK/crlf" .plantuml/_theme.puml
# A real hand edit and a missing header are reported.
echo 'skinparam roundCorner 10' >> .plantuml/_layout.puml
tail -n +2 .plantuml/_fonts.puml > "$WORK/nohdr" && cp "$WORK/nohdr" .plantuml/_fonts.puml
run "$GEN" verify .plantuml
[[ $RC -eq 1 ]] || fail "verify with edits exited $RC, expected 1"
grep -qxF 'edited _layout.puml' <<<"$OUT" || fail "hand edit not detected: $OUT"
grep -qxF 'no-header _fonts.puml' <<<"$OUT" || fail "missing header not reported: $OUT"
grep -qxF 'ok _theme.puml' <<<"$OUT" || fail "CRLF/trailing spaces reported as an edit: $OUT"
grep -qxF 'ok _targets/docx.puml' <<<"$OUT" || fail "target file not verified: $OUT"

# --- after promote-to-policy: an edit the new Policy reproduces is not asked again ---
mkdir -p "$WORK/promote" && cd "$WORK/promote"
cp "$FIXTURES/docx-only-project/CLAUDE.md" .
"$GEN" generate >/dev/null
# Hand edits: the engine switched in the partial instead of the Policy, an
# extra skinparam no Policy key expresses, and a header stripped.
sed 's/^!pragma layout elk$/!pragma layout dot/' .plantuml/_layout.puml > "$WORK/l" && cp "$WORK/l" .plantuml/_layout.puml
echo 'skinparam roundCorner 10' >> .plantuml/_fonts.puml
tail -n +2 .plantuml/_theme.puml > "$WORK/t" && cp "$WORK/t" .plantuml/_theme.puml
run "$GEN" verify .plantuml
grep -qxF 'edited _layout.puml' <<<"$OUT" || fail "promote setup: layout edit not detected: $OUT"
# Promote the engine into the Policy, then compare with the new expected output.
sed 's/`elk`/`dot`/' CLAUDE.md > "$WORK/c" && cp "$WORK/c" CLAUDE.md
"$GEN" generate --out "$WORK/promote-expected" >/dev/null
run "$GEN" verify .plantuml --against "$WORK/promote-expected"
[[ $RC -eq 1 ]] || fail "verify --against with a remaining hand edit exited $RC, expected 1: $OUT"
grep -qxF 'ok _layout.puml' <<<"$OUT" || fail "promoted file is still reported as a hand edit: $OUT"
grep -qxF 'ok _theme.puml' <<<"$OUT" || fail "header-less file equal to the expected body not ok: $OUT"
grep -qxF 'edited _fonts.puml' <<<"$OUT" || fail "an edit the Policy cannot express was accepted: $OUT"
# Without --against the header is still the only reference.
run "$GEN" verify .plantuml
grep -qxF 'edited _layout.puml' <<<"$OUT" || fail "verify without --against changed meaning: $OUT"
grep -qxF 'no-header _theme.puml' <<<"$OUT" || fail "verify without --against changed meaning: $OUT"
run "$GEN" verify .plantuml --against "$WORK/does-not-exist"
[[ $RC -eq 2 ]] || fail "verify --against a missing directory exited $RC, expected 2"

# --- custom theme: brand colors required, unquoted values with comments ---
mkdir -p "$WORK/custom" && cd "$WORK/custom"
cat > CLAUDE.md <<'EOF'
# custom

## PlantUML Policy
- **Primary target**: pptx   # slides first
- **Additional targets**: web, pptx
- **Theme**: custom
- **Brand colors**:
  - primary: #0B5FFF   # brand blue
  - accent: `#F59E0B`
  - neutral: #475569
  - surface: #F8FAFCFF
  - danger: #DC2626
- **Recorded on**: 2026-09-29
EOF
run "$GEN" generate --out .plantuml
[[ $RC -eq 0 ]] || fail "generate (custom) exited $RC: $OUT"
[[ "$(file_list .plantuml)" == "_base.puml _brand.puml _fonts.puml _layout.puml _targets/pptx.puml _targets/web.puml _theme.puml " ]] \
  || fail "custom: unexpected files: $(file_list .plantuml)"
assert_headers .plantuml
grep -qF '!$target = "pptx"' .plantuml/_base.puml || fail "custom: fallback is not pptx"
for kv in 'primary = "#0B5FFF"' 'accent = "#F59E0B"' 'neutral = "#475569"' 'surface = "#F8FAFCFF"' 'danger = "#DC2626"'; do
  grep -E '^!\$' .plantuml/_brand.puml | tr -s ' ' | grep -qF "${kv}" || fail "custom: _brand.puml misses $kv"
done
grep -qF 'skinparam class {' .plantuml/_theme.puml || fail "custom: _theme.puml is not the custom template"
grep -q '^!theme' .plantuml/_theme.puml && fail "custom: _theme.puml names a built-in theme"
grep -qxF '!pragma layout smetana' .plantuml/_layout.puml || fail "custom: default layout engine is not smetana"
grep -qxF '!$direction = "top-to-bottom"' .plantuml/_layout.puml || fail "custom: default direction is not top-to-bottom"
grep -qxF '!$base_font_size = 14' .plantuml/_fonts.puml || fail "custom: default font size is not 14"
run "$GEN" policy
grep -qxF 'targets=pptx web' <<<"$OUT" || fail "custom: targets not deduplicated primary-first: $OUT"

# --- invalid Policies are refused with exit 2 and nothing is written ---
expect_invalid() {
  local label="$1" policy="$2"
  mkdir -p "$WORK/bad" && printf '%s\n' "$policy" > "$WORK/bad/CLAUDE.md"
  run "$GEN" generate --policy "$WORK/bad/CLAUDE.md" --out "$WORK/bad/.plantuml"
  [[ $RC -eq 2 ]] || fail "$label: exited $RC, expected 2 ($OUT)"
  grep -q 'ERROR' <<<"$OUT" || fail "$label: no ERROR message"
  [[ ! -e "$WORK/bad/.plantuml" ]] || fail "$label: wrote output despite the error"
  rm -rf "$WORK/bad"
}
expect_invalid "custom without danger" "$(printf '## PlantUML Policy\n- **Primary target**: web\n- **Theme**: custom\n- **Brand colors**:\n  - primary: #000000\n  - accent: #000000\n  - neutral: #000000\n  - surface: #000000\n')"
expect_invalid "short color" "$(printf '## PlantUML Policy\n- **Primary target**: web\n- **Theme**: custom\n- **Brand colors**:\n  - primary: #12345\n  - accent: #000000\n  - neutral: #000000\n  - surface: #000000\n  - danger: #000000\n')"
expect_invalid "unknown target" "$(printf '## PlantUML Policy\n- **Primary target**: html\n- **Theme**: plain\n')"
expect_invalid "unknown layout engine" "$(printf '## PlantUML Policy\n- **Primary target**: web\n- **Theme**: plain\n- **Layout engine**: neato\n')"
expect_invalid "missing theme" "$(printf '## PlantUML Policy\n- **Primary target**: web\n')"
expect_invalid "no Policy section" "$(printf '# Project\n\nNothing here.\n')"

# --- the committed fixture .plantuml/ is exactly what the generator produces ---
cd "$WORK"
run "$GEN" generate --policy "$FIXTURES/minimal-project/CLAUDE.md" --out "$WORK/minimal"
[[ $RC -eq 0 ]] || fail "generate (minimal-project) exited $RC: $OUT"
diff -r "$FIXTURES/minimal-project/.plantuml" "$WORK/minimal" >/dev/null \
  || fail "tests/fixtures/minimal-project/.plantuml is out of date; regenerate it with generate-config.sh"

echo "PASS: generate-config behaviour"
