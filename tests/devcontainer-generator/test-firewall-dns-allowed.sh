#!/bin/bash
# Test: DNS resolution works (port 53 always allowed)
if command -v dig &>/dev/null; then
    result=$(dig +short +time=3 example.com A 2>/dev/null)
    if [[ -n "$result" ]]; then
        echo "PASS: DNS resolution works (example.com -> $result)"
        exit 0
    else
        echo "FAIL: DNS resolution failed for example.com"
        exit 1
    fi
elif command -v nslookup &>/dev/null; then
    if nslookup example.com &>/dev/null; then
        echo "PASS: DNS resolution works (nslookup)"
        exit 0
    else
        echo "FAIL: DNS resolution failed"
        exit 1
    fi
else
    echo "SKIP: No DNS tools available (dig/nslookup)"
    exit 2
fi
