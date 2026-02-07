#!/bin/bash
# Test: Claude Code is installed and in PATH
if command -v claude &>/dev/null; then
    echo "PASS: claude is installed and in PATH"
    exit 0
elif [[ -x "$HOME/.local/bin/claude" ]]; then
    echo "PASS: claude is installed in ~/.local/bin"
    exit 0
else
    echo "FAIL: claude is not installed"
    exit 1
fi
