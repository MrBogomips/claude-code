#!/usr/bin/env bash
# Layer 1: OpenSpec validation
# Runs `openspec validate --all --strict` over openspec/ (main specs and active changes).
# Uses the openspec CLI on PATH, or the pinned version through npx (Node >= 20.19).
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OPENSPEC_VERSION="1.13.2"
export OPENSPEC_NO_UPDATE_CHECK=1

red()   { printf '\033[0;31m%s\033[0m\n' "$*"; }
green() { printf '\033[0;32m%s\033[0m\n' "$*"; }

if [[ ! -d "$REPO_ROOT/openspec" ]]; then
    red "ERROR: openspec/ not found at repository root"
    exit 1
fi

if command -v openspec >/dev/null 2>&1; then
    OPENSPEC=(openspec)
elif command -v npx >/dev/null 2>&1; then
    OPENSPEC=(npx --yes "@fission-ai/openspec@$OPENSPEC_VERSION")
else
    red "ERROR: OpenSpec CLI not found and npx unavailable."
    red "       Install OpenSpec $OPENSPEC_VERSION or Node >= 20.19 (see CONTRIBUTING.md)."
    exit 1
fi

cd "$REPO_ROOT"
if "${OPENSPEC[@]}" validate --all --strict --no-interactive; then
    green "OK: openspec validate --all --strict"
else
    red "ERROR: openspec validate --all --strict failed"
    exit 1
fi
