#!/bin/bash
# Test: firewall-rules.conf has valid syntax
RULES=".devcontainer/firewall-rules.conf"

if [[ ! -f "$RULES" ]]; then
    echo "SKIP: firewall-rules.conf not found"
    exit 2
fi

errors=0
line_num=0

while IFS= read -r line || [[ -n "$line" ]]; do
    ((line_num++))
    # Strip whitespace
    line="$(echo "$line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"

    # Skip empty lines and comments
    [[ -z "$line" || "$line" =~ ^# ]] && continue

    # Must match: ACTION TARGET
    if ! echo "$line" | grep -qE '^(ALLOW|DENY)[[:space:]]+\S+$'; then
        echo "  Line $line_num invalid: $line"
        ((errors++))
    fi
done < "$RULES"

if [[ "$errors" -eq 0 ]]; then
    echo "PASS: firewall-rules.conf syntax is valid ($line_num lines parsed)"
    exit 0
else
    echo "FAIL: firewall-rules.conf has $errors syntax errors"
    exit 1
fi
