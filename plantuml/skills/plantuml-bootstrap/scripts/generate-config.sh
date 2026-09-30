#!/usr/bin/env bash
# generate-config.sh: materialize .plantuml/ from the "## PlantUML Policy"
# section of CLAUDE.md. Shared by plantuml-bootstrap and plantuml-migrate.
#
# Usage:
#   generate-config.sh generate [--policy FILE] [--out DIR] [--templates DIR]
#   generate-config.sh verify   [DIR] [--against EXPECTED_DIR]
#   generate-config.sh policy   [--policy FILE]
#
# generate  writes every partial into DIR (default .plantuml), which must be
#           absent or empty. Each file starts with "' generated-sha256: <hash>",
#           the SHA-256 of the rest of the file.
# verify    prints "ok|edited|no-header <file>" for each .puml under DIR
#           (default .plantuml). A file is "edited" when its body no longer
#           matches its own header hash. With --against, a file whose body
#           equals the body of the same file in EXPECTED_DIR is "ok" too:
#           replacing it loses nothing (for example after promote-to-policy).
# policy    prints the parsed Policy as key=value lines, defaults applied.
#
# Exit codes: 0 ok, 1 verify found edited or header-less files, 2 error.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_TEMPLATES="$SCRIPT_DIR/../../plantuml-authoring/templates"
ALLOWED_TARGETS="web docx pdf pptx"
BRAND_KEYS="primary accent neutral surface danger"
DEFAULT_FONT_FAMILY="Inter, Arial, sans-serif"
DEFAULT_FONT_SIZE=14
DEFAULT_MAX_WIDTH=5800
HEADER_PREFIX="' generated-sha256: "
NOTICE="' Generated from the PlantUML Policy in CLAUDE.md. Edit the Policy, then run plantuml-migrate."

die() { echo "ERROR: $*" >&2; exit 2; }
usage() { sed -n '4,7p' "$0" | sed 's/^# \{0,1\}//' >&2; exit 2; }

hash_stdin() {
  if command -v shasum >/dev/null 2>&1; then
    shasum -a 256 | awk '{print $1}'
  elif command -v sha256sum >/dev/null 2>&1; then
    sha256sum | awk '{print $1}'
  else
    die "neither shasum nor sha256sum is available"
  fi
}

# Strip CR and trailing blanks per line, so line-ending noise is not an edit.
normalize() { awk '{ sub(/\r$/, ""); sub(/[ \t]+$/, ""); print }'; }

in_list() { case " $2 " in *" $1 "*) return 0 ;; esac; return 1; }

# Prints "key<TAB>value" for each Policy entry; exit 3 if there is no section.
# CRLF line endings are accepted. Values: backticks removed, a "#" preceded
# by blanks starts a comment.
POLICY_AWK='
{ sub(/\r$/, "") }
function clean(v) {
  gsub(/`/, "", v); sub(/^[ \t]+/, "", v)
  sub(/[ \t]+#.*$/, "", v); sub(/[ \t]+$/, "", v); return v
}
/^## PlantUML Policy[ \t]*$/ { in_sec = 1; found = 1; next }
in_sec && (/^#[ \t]/ || /^##[ \t]/) { in_sec = 0 }
!in_sec { next }
/^[ \t]*[-*][ \t]+\*\*/ {
  line = $0; sub(/^[ \t]*[-*][ \t]+\*\*/, "", line)
  i = index(line, "**"); if (i == 0) next
  key = tolower(substr(line, 1, i - 1)); rest = substr(line, i + 2)
  sub(/:[ \t]*$/, "", key); sub(/^[ \t]*:/, "", rest)
  in_brand = (key == "brand colors")
  printf "%s\t%s\n", key, clean(rest); next
}
in_brand && /^[ \t]+[-*][ \t]+[A-Za-z]+[ \t]*:/ {
  line = $0; sub(/^[ \t]+[-*][ \t]+/, "", line)
  i = index(line, ":"); name = tolower(substr(line, 1, i - 1)); sub(/[ \t]+$/, "", name)
  printf "brand:%s\t%s\n", name, clean(substr(line, i + 1)); next
}
/^[^ \t]/ { in_brand = 0 }
END { if (!found) exit 3 }
'

parse_policy() {
  local file="$1" raw rc key value t
  [[ -f "$file" ]] || die "Policy file not found: $file"
  set +e
  raw="$(awk "$POLICY_AWK" "$file")"
  rc=$?
  set -e
  [[ $rc -ne 3 ]] || die "no '## PlantUML Policy' section in $file"
  [[ $rc -eq 0 ]] || die "cannot read $file"

  P_PRIMARY="" P_ADDITIONAL="" P_THEME="" P_LAYOUT="" P_DIRECTION="" P_DETAIL="" P_LANGUAGE=""
  P_FONT_FAMILY="" P_FONT_SIZE="" P_MAX_WIDTH=""
  for key in $BRAND_KEYS; do printf -v "BRAND_$key" '%s' ""; done
  while IFS=$'\t' read -r key value; do
    case "$key" in
      "primary target") P_PRIMARY="$(echo "$value" | tr '[:upper:]' '[:lower:]')" ;;
      "additional targets") P_ADDITIONAL="$(echo "$value" | tr '[:upper:]' '[:lower:]')" ;;
      "theme") P_THEME="$value" ;;
      "layout engine") P_LAYOUT="$(echo "$value" | tr '[:upper:]' '[:lower:]')" ;;
      "default direction") P_DIRECTION="$(echo "$value" | tr '[:upper:]' '[:lower:]')" ;;
      "default detail level") P_DETAIL="$value" ;;
      "label language") P_LANGUAGE="$value" ;;
      "font family") P_FONT_FAMILY="$value" ;;
      "base font size") P_FONT_SIZE="$value" ;;
      "max width (docx)" | "max width") P_MAX_WIDTH="$value" ;;
      brand:*) in_list "${key#brand:}" "$BRAND_KEYS" && printf -v "BRAND_${key#brand:}" '%s' "$value" ;;
    esac
  done <<<"$raw"

  [[ -n "$P_PRIMARY" ]] || die "Policy has no Primary target"
  in_list "$P_PRIMARY" "$ALLOWED_TARGETS" || die "Primary target '$P_PRIMARY' is not one of: $ALLOWED_TARGETS"
  TARGETS="$P_PRIMARY"
  for t in $(echo "$P_ADDITIONAL" | tr ',' ' '); do
    case "$t" in none | - | —) continue ;; esac
    in_list "$t" "$ALLOWED_TARGETS" || die "Additional target '$t' is not one of: $ALLOWED_TARGETS"
    in_list "$t" "$TARGETS" || TARGETS="$TARGETS $t"
  done

  [[ -n "$P_THEME" ]] || die "Policy has no Theme"
  [[ "$P_THEME" =~ ^[A-Za-z0-9_-]+$ ]] || die "Theme '$P_THEME' is not a theme name or 'custom'"
  P_LAYOUT="${P_LAYOUT:-smetana}"
  in_list "$P_LAYOUT" "smetana elk dot" || die "Layout engine '$P_LAYOUT' is not one of: smetana elk dot"
  P_DIRECTION="${P_DIRECTION:-top-to-bottom}"
  in_list "$P_DIRECTION" "top-to-bottom left-to-right" || die "Default direction '$P_DIRECTION' is not top-to-bottom or left-to-right"
  P_DETAIL="${P_DETAIL:-standard}"
  P_LANGUAGE="${P_LANGUAGE:-en}"
  P_FONT_FAMILY="${P_FONT_FAMILY:-$DEFAULT_FONT_FAMILY}"
  [[ "$P_FONT_FAMILY" != *'"'* ]] || die "Font family must not contain double quotes"
  P_FONT_SIZE="${P_FONT_SIZE:-$DEFAULT_FONT_SIZE}"
  [[ "$P_FONT_SIZE" =~ ^[0-9]+$ ]] && ((P_FONT_SIZE >= 6 && P_FONT_SIZE <= 96)) \
    || die "Base font size '$P_FONT_SIZE' is not a whole number between 6 and 96"
  P_MAX_WIDTH="${P_MAX_WIDTH:-$DEFAULT_MAX_WIDTH}"
  [[ "$P_MAX_WIDTH" =~ ^[0-9]+$ ]] || die "Max width (docx) '$P_MAX_WIDTH' is not a whole number of pixels"

  local name color
  for name in $BRAND_KEYS; do
    color="$(brand "$name")"
    if [[ -z "$color" ]]; then
      [[ "$P_THEME" != "custom" ]] || die "Theme custom needs all five brand colors; '$name' is missing"
    elif [[ ! "$color" =~ ^#[0-9A-Fa-f]{6}([0-9A-Fa-f]{2})?$ ]]; then
      die "brand color $name '$color' is not #RRGGBB or #RRGGBBAA"
    fi
  done
}

brand() { local var="BRAND_$1"; printf '%s' "${!var}"; }

render_base() {
  awk -v t="$P_PRIMARY" '/^[ \t]*!\$target[ \t]*=/ { sub(/"[^"]*"/, "\"" t "\"") } { print }' "$TEMPLATES/_base.puml"
}

render_brand() {
  local name color any=0
  echo "' Brand colors from the Policy."
  for name in $BRAND_KEYS; do
    color="$(brand "$name")"
    [[ -n "$color" ]] || continue
    printf '!$%-7s = "%s"\n' "$name" "$color"
    any=1
  done
  [[ $any -eq 1 ]] || echo "' The Policy declares no brand colors (built-in theme $P_THEME)."
}

render_fonts() {
  echo "' Fonts from the Policy. The target files derive their font size from \$base_font_size."
  echo "!\$base_font_size = $P_FONT_SIZE"
  echo "skinparam defaultFontName \"$P_FONT_FAMILY\""
  echo "skinparam defaultFontSize \$base_font_size"
}

render_theme() {
  if [[ "$P_THEME" == "custom" ]]; then
    cat "$TEMPLATES/_theme.puml"
  else
    echo "' Theme from the Policy: a built-in PlantUML theme."
    echo "!theme $P_THEME"
  fi
}

render_layout() {
  awk -v e="$P_LAYOUT" -v d="$P_DIRECTION" '
    /^!pragma layout / { print "!pragma layout " e; next }
    /^!\$direction[ \t]*=/ { print "!$direction = \"" d "\""; next }
    { print }' "$TEMPLATES/_layout.puml"
}

# The generator edits three template lines; fail loudly if they are not there.
check_templates() {
  local t
  for t in _base.puml _layout.puml _theme.puml; do
    [[ -f "$TEMPLATES/$t" ]] || die "template missing: $TEMPLATES/$t"
  done
  for t in $TARGETS; do
    [[ -f "$TEMPLATES/_targets/$t.puml" ]] || die "template missing: $TEMPLATES/_targets/$t.puml"
  done
  [[ "$(grep -cE '^[[:space:]]*!\$target[[:space:]]*=' "$TEMPLATES/_base.puml")" -eq 1 ]] \
    || die "unexpected $TEMPLATES/_base.puml: expected one fallback \$target line"
  [[ "$(grep -c '^!pragma layout ' "$TEMPLATES/_layout.puml")" -eq 1 ]] \
    || die "unexpected $TEMPLATES/_layout.puml: expected one layout pragma"
  [[ "$(grep -cE '^!\$direction[[:space:]]*=' "$TEMPLATES/_layout.puml")" -eq 1 ]] \
    || die "unexpected $TEMPLATES/_layout.puml: expected one \$direction line"
}

# write_partial <dest>: body on stdin; prepends the header hash of the body.
write_partial() {
  local dest="$1" body
  body="$(mktemp)"
  { echo "$NOTICE"; normalize; } > "$body"
  { printf '%s%s\n' "$HEADER_PREFIX" "$(hash_stdin < "$body")"; cat "$body"; } > "$dest"
  rm -f "$body"
}

cmd_generate() {
  local policy="CLAUDE.md" out=".plantuml" t
  TEMPLATES="$DEFAULT_TEMPLATES"
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --policy) policy="${2:?--policy needs a file}"; shift 2 ;;
      --out) out="${2:?--out needs a directory}"; shift 2 ;;
      --templates) TEMPLATES="${2:?--templates needs a directory}"; shift 2 ;;
      *) usage ;;
    esac
  done
  if [[ -e "$out" && -n "$(ls -A "$out" 2>/dev/null)" ]]; then
    die "refusing to write into non-empty $out; plantuml-migrate regenerates an existing .plantuml/"
  fi
  parse_policy "$policy"
  check_templates
  hash_stdin </dev/null >/dev/null

  STAGE="$(mktemp -d)"
  trap 'rm -rf "$STAGE"' EXIT
  mkdir -p "$STAGE/_targets"
  render_base | write_partial "$STAGE/_base.puml"
  render_brand | write_partial "$STAGE/_brand.puml"
  render_fonts | write_partial "$STAGE/_fonts.puml"
  render_theme | write_partial "$STAGE/_theme.puml"
  render_layout | write_partial "$STAGE/_layout.puml"
  for t in $TARGETS; do
    write_partial "$STAGE/_targets/$t.puml" < "$TEMPLATES/_targets/$t.puml"
  done
  mkdir -p "$out"
  cp -R "$STAGE/." "$out/"
  (cd "$out" && find . -type f | sed 's|^\./||' | LC_ALL=C sort | sed "s|^|wrote $out/|")
}

# body_hash <file>: hash of the file without its generated-sha256 header line.
body_hash() {
  if head -n 1 "$1" | normalize | grep -q "^$HEADER_PREFIX"; then
    tail -n +2 "$1" | normalize | hash_stdin
  else
    normalize < "$1" | hash_stdin
  fi
}

cmd_verify() {
  local dir=".plantuml" against="" rel first state status=0
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --against) against="${2:?--against needs a directory}"; shift 2 ;;
      -*) usage ;;
      *) dir="$1"; shift ;;
    esac
  done
  [[ -d "$dir" ]] || die "not a directory: $dir"
  [[ -z "$against" || -d "$against" ]] || die "not a directory: $against"
  hash_stdin </dev/null >/dev/null
  while IFS= read -r rel; do
    first="$(head -n 1 "$dir/$rel" | normalize)"
    case "$first" in
      "$HEADER_PREFIX"*)
        if [[ "${first#"$HEADER_PREFIX"}" == "$(body_hash "$dir/$rel")" ]]; then state=ok; else state=edited; fi ;;
      *) state=no-header ;;
    esac
    if [[ "$state" != ok && -n "$against" && -f "$against/$rel" ]] \
      && [[ "$(body_hash "$dir/$rel")" == "$(body_hash "$against/$rel")" ]]; then
      state=ok
    fi
    [[ "$state" == ok ]] || status=1
    echo "$state $rel"
  done < <(cd "$dir" && find . -type f -name '*.puml' | sed 's|^\./||' | LC_ALL=C sort)
  return $status
}

cmd_policy() {
  local policy="CLAUDE.md" name
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --policy) policy="${2:?--policy needs a file}"; shift 2 ;;
      *) usage ;;
    esac
  done
  parse_policy "$policy"
  echo "primary_target=$P_PRIMARY"
  echo "targets=$TARGETS"
  echo "theme=$P_THEME"
  echo "layout_engine=$P_LAYOUT"
  echo "direction=$P_DIRECTION"
  echo "detail_level=$P_DETAIL"
  echo "label_language=$P_LANGUAGE"
  echo "font_family=$P_FONT_FAMILY"
  echo "base_font_size=$P_FONT_SIZE"
  echo "max_width_docx=$P_MAX_WIDTH"
  for name in $BRAND_KEYS; do echo "brand_$name=$(brand "$name")"; done
}

[[ $# -ge 1 ]] || usage
cmd="$1"
shift
case "$cmd" in
  generate) cmd_generate "$@" ;;
  verify) cmd_verify "$@" ;;
  policy) cmd_policy "$@" ;;
  *) usage ;;
esac
