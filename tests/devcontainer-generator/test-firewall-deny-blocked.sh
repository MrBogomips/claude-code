#!/bin/bash
# Test: non-root user cannot access non-whitelisted domain (DENY * policy)
result=$(curl -sf -o /dev/null -w '%{http_code}' --connect-timeout 5 https://example.com 2>/dev/null)
if [[ "$result" == "000" ]] || [[ -z "$result" ]]; then
    echo "PASS: non-whitelisted domain example.com is blocked"
    exit 0
else
    echo "FAIL: non-whitelisted domain example.com is accessible (HTTP $result)"
    exit 1
fi
