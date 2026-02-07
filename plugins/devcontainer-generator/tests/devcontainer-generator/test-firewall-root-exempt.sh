#!/bin/bash
# Test: root user can access any domain (exempt from firewall)
result=$(sudo curl -sf -o /dev/null -w '%{http_code}' --connect-timeout 5 https://example.com 2>/dev/null)
if [[ "$result" =~ ^[23] ]]; then
    echo "PASS: root can access non-whitelisted domains"
    exit 0
else
    echo "FAIL: root appears blocked from non-whitelisted domains (HTTP $result)"
    exit 1
fi
