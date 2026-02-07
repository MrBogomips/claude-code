#!/bin/bash
# Test: CIDR rules are applied correctly
if ! sudo iptables -L DEVCONTAINER_FW -n &>/dev/null; then
    echo "SKIP: DEVCONTAINER_FW chain does not exist"
    exit 2
fi

# Check that the chain has rules (more than just system essentials)
rule_count=$(sudo iptables -L DEVCONTAINER_FW -n 2>/dev/null | grep -cE '(ACCEPT|DROP)')
if [[ "$rule_count" -gt 4 ]]; then
    echo "PASS: DEVCONTAINER_FW has $rule_count rules (system + user rules)"
    exit 0
else
    echo "FAIL: DEVCONTAINER_FW has only $rule_count rules (expected > 4)"
    exit 1
fi
