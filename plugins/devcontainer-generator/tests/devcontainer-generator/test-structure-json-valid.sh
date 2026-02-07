#!/bin/bash
# Test: devcontainer.json is valid JSON (strip comments first)
JSON=".devcontainer/devcontainer.json"

if [[ ! -f "$JSON" ]]; then
    echo "SKIP: devcontainer.json not found"
    exit 2
fi

if command -v jq &>/dev/null; then
    # Strip single-line comments then validate
    if sed 's|//.*$||' "$JSON" | jq . &>/dev/null; then
        echo "PASS: devcontainer.json is valid JSON"
        exit 0
    else
        echo "FAIL: devcontainer.json is not valid JSON"
        exit 1
    fi
elif command -v python3 &>/dev/null; then
    if python3 -c "
import json, re, sys
with open('$JSON') as f:
    content = f.read()
content = re.sub(r'//.*$', '', content, flags=re.MULTILINE)
content = re.sub(r',\s*([}\]])', r'\1', content)
json.loads(content)
" 2>/dev/null; then
        echo "PASS: devcontainer.json is valid JSON"
        exit 0
    else
        echo "FAIL: devcontainer.json is not valid JSON"
        exit 1
    fi
else
    echo "SKIP: No JSON validator available (jq/python3)"
    exit 2
fi
