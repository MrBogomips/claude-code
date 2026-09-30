#!/usr/bin/env bash
# validate-matrix.sh: validate every (diagram, target) cell of a PlantUML
# project. Run from the project root. Prints a JSON array, one object per line:
#   {"file":…,"target":…,"level":…,"status":…,"diff_summary":…[,"image":…]}
#
# Usage:
#   validate-matrix.sh [--mode check|bless|preview] [--level checkonly|svg-hash|png-perceptual]
#                      [--policy FILE] [--targets "t1 t2"] [--baselines DIR] [--out DIR] [FILE...]
#
# Files default to every *.puml / *.plantuml outside .plantuml/, .git/ and
# node_modules/, excluding _*.puml partials. Targets default to the Policy's.
# Every plantuml call gets PLANTUML_TARGET and the file path, so includes
# resolve from the diagram's own directory at every level.
#
# Levels: checkonly  plantuml -checkonly; keeps no baselines, so bless writes nothing.
#         svg-hash   SVG rendered from the file, hashed without the PlantUML
#                    version and source processing instructions and comments.
#         png-perceptual  not implemented: every cell is "unsupported".
# Modes:  check    compare with baselines (svg-hash) or just compile (checkonly).
#         bless    write svg-hash baselines, only for cells that render (exit 0).
#         preview  render PNGs into --out for the visual smoke check; no baselines.
# Status: pass | fail | blessed | rendered | missing-baseline | unsupported | error
# Exit:   0 every cell pass, blessed or rendered; 1 otherwise; 2 usage or setup error.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GEN="$SCRIPT_DIR/../../plantuml-bootstrap/scripts/generate-config.sh"
SUMMARY_MAX=120

die() { echo "ERROR: $*" >&2; exit 2; }
usage() { sed -n '6,7p' "$0" | sed 's/^# \{0,1\}//' >&2; exit 2; }

hash_stdin() {
  if command -v shasum >/dev/null 2>&1; then
    shasum -a 256 | awk '{print $1}'
  else
    sha256sum | awk '{print $1}'
  fi
}

json_escape() {
  printf '%s' "$1" | tr '\n\t' '  ' | tr -d '\000-\010\013-\037' | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g'
}

# First error-looking line of plantuml output, else the first non-empty line.
summarize() {
  local output="$1" rc="$2" line
  line="$(grep -m 1 -i 'error' <<<"$output" || true)"
  [[ -n "$line" ]] || line="$(grep -m 1 -v '^[[:space:]]*$' <<<"$output" || true)"
  printf '%s (exit %s)' "${line:0:$SUMMARY_MAX}" "$rc"
}

flat_name() { printf '%s' "$1" | sed -e 's|/|__|g' -e 's|\.[^.]*$||'; }

list_files() {
  find . \( -name .git -o -name .plantuml -o -name node_modules \) -prune -o \
    -type f \( -name '*.puml' -o -name '*.plantuml' \) -print \
    | sed 's|^\./||' | awk -F/ '$NF !~ /^_/' | LC_ALL=C sort
}

# run_plantuml <target> <args...>: sets OUTPUT and RC.
run_plantuml() {
  local target="$1"
  shift
  set +e
  OUTPUT="$(PLANTUML_TARGET="$target" plantuml "$@" 2>&1)"
  RC=$?
  set -e
}

emit() { # file target status summary [image]
  local obj
  obj="{\"file\":\"$(json_escape "$1")\",\"target\":\"$2\",\"level\":\"$LEVEL\",\"status\":\"$3\",\"diff_summary\":\"$(json_escape "$4")\""
  [[ -z "${5:-}" ]] || obj="$obj,\"image\":\"$(json_escape "$5")\""
  CELLS+=("$obj}")
  case "$3" in pass | blessed | rendered) ;; *) FAILED=1 ;; esac
}

cell_preview() {
  local f="$1" t="$2" dir image
  dir="$OUT_DIR/$(flat_name "$f")--$t"
  run_plantuml "$t" -tpng -o "$dir" "$f"
  if [[ $RC -ne 0 ]]; then emit "$f" "$t" error "$(summarize "$OUTPUT" "$RC")"; return; fi
  image="$(find "$dir" -type f -name '*.png' 2>/dev/null | LC_ALL=C sort | head -n 1)"
  if [[ -z "$image" ]]; then emit "$f" "$t" error "no PNG produced"; return; fi
  emit "$f" "$t" rendered "" "$image"
}

cell_checkonly() {
  local f="$1" t="$2"
  run_plantuml "$t" -checkonly "$f"
  if [[ $RC -eq 0 ]]; then emit "$f" "$t" pass ""; else emit "$f" "$t" fail "$(summarize "$OUTPUT" "$RC")"; fi
}

cell_svg_hash() {
  local f="$1" t="$2" dir hash baseline
  dir="$WORK/$(flat_name "$f")--$t"
  baseline="$BASELINES/$(flat_name "$f")--$t.svg-hash"
  run_plantuml "$t" -tsvg -o "$dir" "$f"
  if [[ $RC -ne 0 ]]; then
    if [[ "$MODE" == bless ]]; then emit "$f" "$t" error "not blessed: $(summarize "$OUTPUT" "$RC")"
    else emit "$f" "$t" fail "$(summarize "$OUTPUT" "$RC")"; fi
    return
  fi
  if [[ -z "$(find "$dir" -type f -name '*.svg' 2>/dev/null)" ]]; then emit "$f" "$t" error "no SVG produced"; return; fi
  hash="$(find "$dir" -type f -name '*.svg' | LC_ALL=C sort | while IFS= read -r svg; do cat "$svg"; done \
    | tr '\n' ' ' | sed -E -e 's/<\?plantuml[^?]*\?>//g' -e 's/<!--([^-]|-[^-])*-->//g' | hash_stdin)"
  if [[ "$MODE" == bless ]]; then
    mkdir -p "$BASELINES"
    echo "$hash" > "$baseline"
    emit "$f" "$t" blessed ""
  elif [[ ! -f "$baseline" ]]; then
    emit "$f" "$t" missing-baseline "no baseline at $baseline"
  elif [[ "$(cat "$baseline")" == "$hash" ]]; then
    emit "$f" "$t" pass ""
  else
    emit "$f" "$t" fail "svg hash differs from $baseline"
  fi
}

MODE=check LEVEL=checkonly POLICY=CLAUDE.md TARGETS="" BASELINES=tests/plantuml-baselines OUT_DIR=""
FILES=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    --mode) MODE="${2:?--mode needs a value}"; shift 2 ;;
    --level) LEVEL="${2:?--level needs a value}"; shift 2 ;;
    --policy) POLICY="${2:?--policy needs a file}"; shift 2 ;;
    --targets) TARGETS="${2:?--targets needs a list}"; shift 2 ;;
    --baselines) BASELINES="${2:?--baselines needs a directory}"; shift 2 ;;
    --out) OUT_DIR="${2:?--out needs a directory}"; shift 2 ;;
    -h | --help) usage ;;
    -*) die "unknown option $1" ;;
    *) FILES+=("${1#./}"); shift ;;
  esac
done
case "$MODE" in check | bless | preview) ;; *) die "--mode must be check, bless or preview" ;; esac
case "$LEVEL" in checkonly | svg-hash | png-perceptual) ;; *) die "--level must be checkonly, svg-hash or png-perceptual" ;; esac
if [[ "$MODE" == preview ]]; then
  [[ -n "$OUT_DIR" ]] || die "--mode preview needs --out DIR"
  mkdir -p "$OUT_DIR" && OUT_DIR="$(cd "$OUT_DIR" && pwd)"
fi
command -v plantuml >/dev/null 2>&1 \
  || die "plantuml not found on PATH (macOS: brew install plantuml; Debian/Ubuntu: apt install plantuml)"
command -v shasum >/dev/null 2>&1 || command -v sha256sum >/dev/null 2>&1 \
  || die "neither shasum nor sha256sum is available"
if [[ -z "$TARGETS" ]]; then
  [[ -f "$GEN" ]] || die "generator not found at $GEN"
  POLICY_OUT="$(bash "$GEN" policy --policy "$POLICY")" || die "cannot read the Policy targets from $POLICY"
  TARGETS="$(awk -F= '$1 == "targets" { print $2 }' <<<"$POLICY_OUT")"
  [[ -n "$TARGETS" ]] || die "the Policy in $POLICY declares no targets"
fi
if [[ ${#FILES[@]} -eq 0 ]]; then
  while IFS= read -r f; do FILES+=("$f"); done < <(list_files)
fi

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
CELLS=()
FAILED=0
for f in ${FILES[@]+"${FILES[@]}"}; do
  for t in $TARGETS; do
    if [[ ! -f "$f" ]]; then emit "$f" "$t" error "file not found"; continue; fi
    if [[ "$MODE" == preview ]]; then cell_preview "$f" "$t"
    elif [[ "$LEVEL" == png-perceptual ]]; then emit "$f" "$t" unsupported "png-perceptual is not implemented"
    elif [[ "$LEVEL" == checkonly ]]; then cell_checkonly "$f" "$t"
    else cell_svg_hash "$f" "$t"; fi
  done
done

echo "["
for i in ${CELLS[@]+"${!CELLS[@]}"}; do
  if [[ $i -lt $((${#CELLS[@]} - 1)) ]]; then echo "${CELLS[$i]},"; else echo "${CELLS[$i]}"; fi
done
echo "]"
exit "$FAILED"
