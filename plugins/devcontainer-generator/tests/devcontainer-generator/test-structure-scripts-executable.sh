#!/bin/bash
# Test: script files are executable
errors=0

scripts=(
    ".devcontainer/post-create.sh"
    ".devcontainer/scripts/apply-firewall.sh"
)

for s in "${scripts[@]}"; do
    if [[ -f "$s" ]] && [[ ! -x "$s" ]]; then
        echo "  Not executable: $s"
        ((errors++))
    elif [[ ! -f "$s" ]]; then
        echo "  Missing: $s"
        ((errors++))
    fi
done

if [[ "$errors" -eq 0 ]]; then
    echo "PASS: all scripts are executable"
    exit 0
else
    echo "FAIL: $errors scripts not executable"
    exit 1
fi
