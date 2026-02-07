#!/bin/bash
# Test: running apply-firewall.sh twice produces no duplicate rules
SCRIPT=".devcontainer/scripts/apply-firewall.sh"
RULES=".devcontainer/firewall-rules.conf"

if [[ ! -f "$SCRIPT" ]] || [[ ! -f "$RULES" ]]; then
    echo "SKIP: Firewall script or rules file not found"
    exit 2
fi

# Run twice
sudo bash "$SCRIPT" "$RULES" &>/dev/null
sudo bash "$SCRIPT" "$RULES" &>/dev/null

# Count how many times the chain appears in OUTPUT
count=$(sudo iptables -L OUTPUT -n 2>/dev/null | grep -c "DEVCONTAINER_FW")
if [[ "$count" -eq 1 ]]; then
    echo "PASS: DEVCONTAINER_FW appears exactly once in OUTPUT after double apply"
    exit 0
else
    echo "FAIL: DEVCONTAINER_FW appears $count times in OUTPUT (expected 1)"
    exit 1
fi
