#!/bin/bash
# =============================================================================
# Run all devcontainer-generator tests
# =============================================================================
# Usage: bash run-all.sh
# Run inside a devcontainer with firewall applied.
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
passed=0
failed=0
skipped=0
total=0

echo "=== Devcontainer Generator Tests ==="
echo ""

for test in "$SCRIPT_DIR"/test-*.sh; do
    [[ ! -f "$test" ]] && continue
    ((total++))
    test_name="$(basename "$test")"
    output=$("$test" 2>&1)
    rc=$?
    if [[ $rc -eq 0 ]]; then
        ((passed++))
    elif [[ $rc -eq 2 ]]; then
        ((skipped++))
    else
        ((failed++))
    fi
    echo "$output"
done

echo ""
echo "=== Results: $passed/$total passed, $failed failed, $skipped skipped ==="
exit $((failed > 0 ? 1 : 0))
