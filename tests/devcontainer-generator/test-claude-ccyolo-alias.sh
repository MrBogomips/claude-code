#!/bin/bash
# Test: ccyolo alias exists in shell configuration
found=0

if grep -q 'alias ccyolo=' ~/.zshrc 2>/dev/null; then
    found=1
elif grep -q 'alias ccyolo=' ~/.bashrc 2>/dev/null; then
    found=1
fi

if [[ "$found" -eq 1 ]]; then
    echo "PASS: ccyolo alias is configured"
    exit 0
else
    echo "FAIL: ccyolo alias not found in shell configuration"
    exit 1
fi
