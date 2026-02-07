#!/bin/bash
# Test: all expected devcontainer files exist
errors=0

required_files=(
    ".devcontainer/devcontainer.json"
    ".devcontainer/post-create.sh"
    ".devcontainer/firewall-rules.conf"
    ".devcontainer/scripts/apply-firewall.sh"
)

for f in "${required_files[@]}"; do
    if [[ ! -f "$f" ]]; then
        echo "  Missing: $f"
        ((errors++))
    fi
done

if [[ "$errors" -eq 0 ]]; then
    echo "PASS: all required files exist (${#required_files[@]} checked)"
    exit 0
else
    echo "FAIL: $errors required files missing"
    exit 1
fi
