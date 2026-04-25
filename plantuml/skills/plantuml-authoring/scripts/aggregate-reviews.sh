#!/usr/bin/env bash
# Aggregate per-variant review.md files into a run-level _report.md.
# Usage: aggregate-reviews.sh <run-dir>
#
# Verdict matching is tolerant: reviewers used many non-standard
# strings in run-01 (REJECT, PASS-WITH-RESERVATIONS, ACCEPT WITH
# CHANGES, FAIL ON RENDERING, ACCEPTABLE-WITH-FIXES …). The classifier
# normalizes them to PASS / WARN / FAIL / UNKNOWN.
set -euo pipefail

RUN_DIR="${1:-$(cat /tmp/plantuml-tests-latest 2>/dev/null || true)}"
[ -n "$RUN_DIR" ] && [ -d "$RUN_DIR" ] || { echo "Usage: $0 <run-dir>"; exit 1; }

pass=0; warn=0; fail=0; unknown=0
fails_list=""
unknowns_list=""
issues_file=$(mktemp)
trap "rm -f $issues_file" EXIT

# Map a verdict string to one of PASS / WARN / FAIL / UNKNOWN.
classify() {
  local v
  v=$(echo "$1" | tr '[:lower:]' '[:upper:]')
  case "$v" in
    *FAIL*|*REJECT*|*BLOCK*) echo FAIL ;;
    *WARN*|*RESERVATION*|*CONDITIONAL*|*WITH-CHANGE*|*WITH-FIX*|*ACCEPTABLE*|*PASS-WITH*) echo WARN ;;
    *PASS*|*ACCEPT*|*OK*) echo PASS ;;
    "") echo UNKNOWN ;;
    *) echo UNKNOWN ;;
  esac
}

shopt -s nullglob
for review in "$RUN_DIR"/*/*/review.md; do
  raw=$(grep -m1 -iE "^(verdict)[[:space:]]*[:|]" "$review" 2>/dev/null \
        | sed -E 's/^[Vv]erdict[[:space:]]*[:|][[:space:]]*//; s/[*_`]//g; s/[[:space:]]+$//')
  cls=$(classify "$raw")
  case "$cls" in
    PASS) pass=$((pass+1));;
    WARN) warn=$((warn+1));;
    FAIL) fail=$((fail+1)); fails_list="${fails_list}- $review (\"$raw\")"$'\n';;
    UNKNOWN) unknown=$((unknown+1)); unknowns_list="${unknowns_list}- $review (raw=\"$raw\")"$'\n';;
  esac

  awk -F'|' '
    /^\|/ && /(BLOCKER|HIGH|MEDIUM|LOW)/ {
      sev=$2; axis=$3;
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", sev);
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", axis);
      if (sev != "" && axis != "") print sev"\t"axis;
    }
  ' "$review" >> "$issues_file"
done
shopt -u nullglob

total=$((pass + warn + fail + unknown))
top10=$(sort "$issues_file" | uniq -c | sort -rn | head -10 || true)

{
  echo "# Adversarial Review Report — $(basename "$RUN_DIR")"
  echo
  echo "## Counters"
  echo
  echo "- PASS: $pass"
  echo "- WARN (PASS-WITH-WARNINGS / RESERVATIONS / etc): $warn"
  echo "- FAIL (FAIL / REJECT / BLOCK): $fail"
  echo "- UNKNOWN (no verdict line found): $unknown"
  echo "- Total reviews scanned: $total"
  echo
  echo "## Failures requiring fix"
  echo
  if [ -n "$fails_list" ]; then printf "%s" "$fails_list"; else echo "None."; fi
  echo
  echo "## Reviews with unparseable verdict"
  echo
  if [ -n "$unknowns_list" ]; then printf "%s" "$unknowns_list"; else echo "None."; fi
  echo
  echo "## Top 10 systemic issues (count · severity · axis)"
  echo
  echo '```'
  [ -n "$top10" ] && echo "$top10" || echo "No issues recorded."
  echo '```'
  echo
  echo "## Exit"
  echo
  if [ "$fail" -eq 0 ]; then
    echo "OK — suite passes (warnings may remain; see WARN list above)."
  else
    echo "BLOCKED — fix failures."
  fi
} > "$RUN_DIR/_report.md"

echo "Report: $RUN_DIR/_report.md"
[ "$fail" -eq 0 ]
