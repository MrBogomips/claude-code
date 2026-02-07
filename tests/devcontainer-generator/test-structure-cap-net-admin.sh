#!/bin/bash
# Test: devcontainer.json includes NET_ADMIN capability
JSON=".devcontainer/devcontainer.json"

if [[ ! -f "$JSON" ]]; then
    echo "SKIP: devcontainer.json not found"
    exit 2
fi

if grep -q "NET_ADMIN" "$JSON"; then
    echo "PASS: devcontainer.json includes NET_ADMIN capability"
    exit 0
else
    echo "FAIL: devcontainer.json does not include NET_ADMIN capability"
    exit 1
fi
