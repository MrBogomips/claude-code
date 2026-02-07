#!/bin/bash
# Test: iptables chain DEVCONTAINER_FW exists
if sudo iptables -L DEVCONTAINER_FW -n &>/dev/null; then
    echo "PASS: DEVCONTAINER_FW chain exists"
    exit 0
else
    echo "FAIL: DEVCONTAINER_FW chain does not exist"
    exit 1
fi
