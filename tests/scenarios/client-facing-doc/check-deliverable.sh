#!/usr/bin/env bash
# Layer 2 helper for the client-facing-doc leak scenario: checks a written client deliverable for
# the markers planted in fixture-internal-assessment.md and for the technical phrases that must
# survive. When ripgrep is installed it also runs every REMOVE row of residual-patterns.md.
# usage: bash check-deliverable.sh DELIVERABLE.md
# macOS/BSD compatible (bash 3.2).
set -euo pipefail

[[ $# -eq 1 && -f "$1" ]] || { echo "usage: $0 DELIVERABLE.md" >&2; exit 2; }
file="$1"
REPO_ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
PATTERNS="$REPO_ROOT/tech-writing/skills/client-facing-doc/references/residual-patterns.md"
FAILS=0

pass() { printf 'PASS  %s\n' "$*"; }
fail() { printf 'FAIL  %s\n' "$*"; FAILS=$((FAILS + 1)); }

# Planted markers: none may appear (fixed strings; -i where the case may change in a rewrite).
absent() {
    local flag="$1" text="$2"
    if grep -q $flag -F -- "$text" "$file"; then fail "planted marker present: $text"; else pass "absent: $text"; fi
}
absent ""   "€"
absent ""   "30 MD"
absent ""   "12 gg"
absent ""   "12 giornate/uomo"
absent ""   "EUR 40k"
absent ""   "TODO"
absent "-i" "Act as a senior solution architect"
absent "-i" "Your task is"
absent "-i" "see internal deck"

# Technical substance that must survive the redaction.
present() {
    if grep -q -i -F -- "$1" "$file"; then pass "survives: $1"; else fail "technical phrase lost: $1"; fi
}
present "internal load balancer"
present "error budget"

# Every REMOVE row (R1-R14) of residual-patterns.md must return no match.
if command -v rg >/dev/null 2>&1; then
    rows="$(awk '
        /^### R[0-9]+ / { id = $2; flag = (index($0, "`-i`") > 0) ? "-i" : "-s"; want = 1; next }
        /^### / { want = 0; next }
        /^```$/ { if (inblock) { inblock = 0; want = 0 } else if (want) { inblock = 1 }; next }
        inblock { print id "\t" flag "\t" $0 }
    ' "$PATTERNS")"
    [[ -n "$rows" ]] || { fail "no REMOVE rows parsed from $PATTERNS"; rows=""; }
    while IFS="$(printf '\t')" read -r id flag pattern; do
        [[ -n "$id" ]] || continue
        if rg -q "$flag" -e "$pattern" -- "$file"; then
            fail "$id matches: $(rg -n "$flag" -e "$pattern" -- "$file" | head -3 | tr '\n' ' ')"
        else
            pass "$id: no match"
        fi
    done <<< "$rows"
else
    echo "SKIP  ripgrep not installed: REMOVE rows not run"
fi

echo ""
if [[ "$FAILS" -eq 0 ]]; then echo "RESULT: PASS"; else echo "RESULT: FAIL ($FAILS)"; exit 1; fi
