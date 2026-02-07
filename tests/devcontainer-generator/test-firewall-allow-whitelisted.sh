#!/bin/bash
# Test: non-root user can access whitelisted domain
result=$(curl -sf -o /dev/null -w '%{http_code}' --connect-timeout 10 https://api.anthropic.com 2>/dev/null)
if [[ "$result" =~ ^[23456] ]]; then
    echo "PASS: whitelisted domain api.anthropic.com is accessible"
    exit 0
else
    echo "FAIL: whitelisted domain api.anthropic.com is not accessible (HTTP $result)"
    exit 1
fi
