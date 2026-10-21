#!/usr/bin/env bash
# Layer 1: OpenSpec validation
# Runs `openspec validate --all --strict` over openspec/ (main specs and active changes).
# Uses the openspec CLI on PATH when it is the pinned version; otherwise runs the pinned version
# through npx (Node >= 20.19), so local results match CI. A different openspec on PATH is the
# last resort, with a warning.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OPENSPEC_VERSION="1.13.2"
export OPENSPEC_NO_UPDATE_CHECK=1

red()    { printf '\033[0;31m%s\033[0m\n' "$*"; }
yellow() { printf '\033[0;33m%s\033[0m\n' "$*"; }
green()  { printf '\033[0;32m%s\033[0m\n' "$*"; }

if [[ ! -d "$REPO_ROOT/openspec" ]]; then
    red "ERROR: openspec/ not found at repository root"
    exit 1
fi

local_version=""
if command -v openspec >/dev/null 2>&1; then
    local_version="$(openspec --version 2>/dev/null || echo unknown)"
fi

if [[ "$local_version" == "$OPENSPEC_VERSION" ]]; then
    OPENSPEC=(openspec)
elif command -v npx >/dev/null 2>&1; then
    OPENSPEC=(npx --yes "@fission-ai/openspec@$OPENSPEC_VERSION")
    if [[ -n "$local_version" ]]; then
        yellow "NOTE: openspec $local_version on PATH differs from the pinned $OPENSPEC_VERSION; using the pinned version through npx"
    fi
elif [[ -n "$local_version" ]]; then
    OPENSPEC=(openspec)
    yellow "WARN: openspec $local_version on PATH differs from the pinned $OPENSPEC_VERSION used in CI, and npx is unavailable"
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
