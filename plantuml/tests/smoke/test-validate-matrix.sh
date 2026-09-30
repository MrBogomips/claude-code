#!/usr/bin/env bash
set -euo pipefail

# Behavioural test for validate-matrix.sh, the deterministic (file x target)
# validator used by plantuml-validate and plantuml-migrate.
# Part 1 runs a stub `plantuml` and needs nothing installed.
# Part 2 runs the real plantuml and is skipped when it is not on PATH.

PLUGIN_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
VM="$PLUGIN_ROOT/skills/plantuml-validate/scripts/validate-matrix.sh"
FIXTURES="$PLUGIN_ROOT/tests/fixtures"

fail() { echo "FAIL: $*" >&2; exit 1; }

[[ -f "$VM" ]] || fail "missing $VM"
[[ -x "$VM" ]] || fail "$VM is not executable"

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

run() {
  set +e
  OUT="$("$@" 2>"$WORK/stderr")"
  RC=$?
  set -e
}
cell() { grep -F "\"file\":\"$1\",\"target\":\"$2\"" <<<"$OUT" || true; }
assert_cell() { # file target status
  local line; line="$(cell "$1" "$2")"
  [[ -n "$line" ]] || fail "no cell for $1 [$2] in: $OUT"
  grep -qF "\"status\":\"$3\"" <<<"$line" || fail "$1 [$2]: expected $3, got $line"
}
count_cells() { grep -c '"file":' <<<"$OUT" || true; }
json_ok() {
  if command -v jq >/dev/null 2>&1; then
    jq -e 'type == "array"' <<<"$OUT" >/dev/null || fail "output is not a JSON array: $OUT"
  fi
}

# --- Part 1: stub plantuml ---
mkdir -p "$WORK/bin"
cat > "$WORK/bin/plantuml" <<'EOF'
#!/usr/bin/env bash
# Stub: fails on files containing BROKEN, writes a fake SVG/PNG otherwise.
echo "target=${PLANTUML_TARGET-<unset>} args=$*" >> "${STUB_LOG:?}"
mode="" out="" file=""
while [ $# -gt 0 ]; do
  case "$1" in
    -checkonly) mode=check ;;
    -tsvg) mode=svg ;;
    -tpng) mode=png ;;
    -pipe) echo "stub: -pipe is not allowed" >&2; exit 99 ;;
    -o) out="$2"; shift ;;
    -*) ;;
    *) file="$1" ;;
  esac
  shift
done
[ -f "$file" ] || { echo "stub: no such file $file" >&2; exit 98; }
if grep -q BROKEN "$file"; then
  echo "Error line 2 in file: $file" >&2
  echo "Some diagram description contains errors"
  exit 200
fi
id="$(awk '/^@start/ { print $2; exit }' "$file")"
case "$mode" in
  svg) mkdir -p "$out"
       { printf '<svg><?plantuml %s?><!--c-->' "${STUB_VERSION:-1.0}"; printf '%s' "$PLANTUML_TARGET"; cat "$file"; echo '</svg>'; } > "$out/$id.svg" ;;
  png) mkdir -p "$out"; printf 'PNG' > "$out/$id.png" ;;
esac
exit 0
EOF
chmod +x "$WORK/bin/plantuml"
export PATH="$WORK/bin:$PATH"
export STUB_LOG="$WORK/stub.log"

P="$WORK/proj"
mkdir -p "$P/.plantuml" "$P/diagrams/sub"
cat > "$P/CLAUDE.md" <<'EOF'
## PlantUML Policy
- **Primary target**: `docx`
- **Additional targets**: `web`
- **Theme**: `plain`
EOF
printf '@startuml A\nclass A\n@enduml\n' > "$P/diagrams/A.puml"
printf '@startuml B\nclass B\n@enduml\n' > "$P/diagrams/sub/B.puml"
printf '@startuml Broken\nBROKEN\n@enduml\n' > "$P/diagrams/Broken.puml"
printf 'BROKEN partial\n' > "$P/diagrams/_shared.puml"
printf 'BROKEN include file\n' > "$P/diagrams/lib.iuml"
printf 'BROKEN\n' > "$P/.plantuml/_base.puml"
cd "$P"

# checkonly: every declared target, explicit PLANTUML_TARGET, no baselines.
: > "$STUB_LOG"
run "$VM"
[[ $RC -eq 1 ]] || fail "checkonly with a broken file exited $RC, expected 1"
json_ok
[[ "$(count_cells)" -eq 6 ]] || fail "expected 3 files x 2 targets = 6 cells: $OUT"
for t in docx web; do
  assert_cell diagrams/A.puml "$t" pass
  assert_cell diagrams/sub/B.puml "$t" pass
  assert_cell diagrams/Broken.puml "$t" fail
done
grep -q 'Error line 2' <<<"$(cell diagrams/Broken.puml docx)" || fail "fail cell does not carry the error text"
grep -q 'target=<unset>' "$STUB_LOG" && fail "plantuml was called without PLANTUML_TARGET"
grep -qE '_shared|lib\.iuml|\.plantuml/' "$STUB_LOG" && fail "partials, .iuml or .plantuml/ files were validated"
[[ ! -e tests/plantuml-baselines ]] || fail "checkonly created baselines"

# bless at checkonly writes nothing: a failing file never becomes a baseline.
run "$VM" --mode bless --level checkonly
[[ $RC -eq 1 ]] || fail "bless checkonly with a broken file exited $RC, expected 1"
assert_cell diagrams/Broken.puml docx fail
grep -q '"status":"blessed"' <<<"$OUT" && fail "checkonly bless reported blessed cells"
[[ ! -e tests/plantuml-baselines ]] || fail "checkonly bless created baselines"

# svg-hash: renders from the file (never stdin), missing baselines are reported.
: > "$STUB_LOG"
run "$VM" --level svg-hash
[[ $RC -eq 1 ]] || fail "svg-hash check without baselines exited $RC"
assert_cell diagrams/A.puml docx missing-baseline
assert_cell diagrams/Broken.puml web fail
grep -q -- '-pipe' "$STUB_LOG" && fail "svg-hash used -pipe"
grep -q 'args=-tsvg -o .* diagrams/sub/B.puml' "$STUB_LOG" || fail "svg-hash did not render from the file path"

run "$VM" --mode bless --level svg-hash
[[ $RC -eq 1 ]] || fail "svg-hash bless with a broken file exited $RC, expected 1"
assert_cell diagrams/A.puml web blessed
assert_cell diagrams/Broken.puml docx error
[[ -f tests/plantuml-baselines/diagrams__sub__B--web.svg-hash ]] || fail "flat baseline name missing"
[[ -f tests/plantuml-baselines/diagrams__A--docx.svg-hash ]] || fail "baseline for A docx missing"
[[ -z "$(find tests/plantuml-baselines -name '*Broken*')" ]] || fail "a failing file was blessed"

# check against baselines; the PlantUML version in the SVG does not count.
STUB_VERSION=9.9 run "$VM" --level svg-hash diagrams/A.puml ./diagrams/sub/B.puml
[[ $RC -eq 0 ]] || fail "svg-hash check after bless exited $RC: $OUT"
[[ "$(count_cells)" -eq 4 ]] || fail "explicit file list not honored: $OUT"
assert_cell diagrams/sub/B.puml docx pass
printf '@startuml A\nclass A\nclass C\n@enduml\n' > diagrams/A.puml
run "$VM" --level svg-hash diagrams/A.puml
[[ $RC -eq 1 ]] || fail "changed diagram still passed"
assert_cell diagrams/A.puml docx fail

# preview renders PNGs for the visual check and writes no baseline.
rm -rf tests/plantuml-baselines
run "$VM" --mode preview --out "$WORK/png" diagrams/A.puml
[[ $RC -eq 0 ]] || fail "preview exited $RC: $OUT"
assert_cell diagrams/A.puml docx rendered
img="$(cell diagrams/A.puml web | sed -E 's/.*"image":"([^"]*)".*/\1/')"
[[ -f "$img" ]] || fail "preview image not found: $img"
[[ ! -e tests/plantuml-baselines ]] || fail "preview created baselines"

run "$VM" --level png-perceptual diagrams/A.puml
[[ $RC -eq 1 ]] || fail "png-perceptual exited $RC, expected 1"
assert_cell diagrams/A.puml docx unsupported

run "$VM" --targets pdf diagrams/A.puml
[[ "$(count_cells)" -eq 1 ]] || fail "--targets override not honored: $OUT"
assert_cell diagrams/A.puml pdf pass

# setup errors exit 2
mkdir -p "$WORK/nopolicy" && cd "$WORK/nopolicy" && printf '# none\n' > CLAUDE.md
run "$VM"
[[ $RC -eq 2 ]] || fail "missing Policy exited $RC, expected 2"
run "$VM" --level nope
[[ $RC -eq 2 ]] || fail "unknown level exited $RC, expected 2"

# --- Part 2: real plantuml on the committed fixture ---
PATH="${PATH#"$WORK/bin:"}"
if ! command -v plantuml >/dev/null 2>&1; then
  echo "SKIP: plantuml not on PATH (test-validate-matrix real-render part)"
  echo "PASS: validate-matrix behaviour (stub)"
  exit 0
fi
cp -R "$FIXTURES/minimal-project" "$WORK/real"
cd "$WORK/real"
run "$VM"
[[ $RC -eq 1 ]] || fail "real: checkonly on the fixture exited $RC, expected 1 (Broken.puml)"
assert_cell diagrams/Valid.puml web pass
assert_cell diagrams/nested/Nested.puml web pass
assert_cell diagrams/Broken.puml web fail
run "$VM" --mode bless --level svg-hash diagrams/Valid.puml diagrams/nested/Nested.puml
[[ $RC -eq 0 ]] || fail "real: svg-hash bless exited $RC: $OUT"
run "$VM" --level svg-hash diagrams/Valid.puml diagrams/nested/Nested.puml
[[ $RC -eq 0 ]] || fail "real: svg-hash is not stable between two renders: $OUT"

echo "PASS: validate-matrix behaviour (stub and real plantuml)"
