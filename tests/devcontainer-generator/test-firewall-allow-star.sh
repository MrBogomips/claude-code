#!/bin/bash
# Test: ALLOW * policy makes everything accessible
SCRIPT=".devcontainer/scripts/apply-firewall.sh"
RULES=".devcontainer/firewall-rules.conf"

if [[ ! -f "$SCRIPT" ]] || [[ ! -f "$RULES" ]]; then
    echo "SKIP: Firewall script or rules file not found"
    exit 2
fi

# Create temporary rules with ALLOW * policy
tmp_rules=$(mktemp)
echo "ALLOW *" > "$tmp_rules"

# Apply permissive rules
sudo bash "$SCRIPT" "$tmp_rules" &>/dev/null

# Test access to normally blocked domain
result=$(curl -sf -o /dev/null -w '%{http_code}' --connect-timeout 5 https://example.com 2>/dev/null)

# Restore original rules
sudo bash "$SCRIPT" "$RULES" &>/dev/null
rm -f "$tmp_rules"

if [[ "$result" =~ ^[23] ]]; then
    echo "PASS: ALLOW * policy permits all traffic"
    exit 0
else
    echo "FAIL: ALLOW * policy did not permit traffic to example.com (HTTP $result)"
    exit 1
fi
