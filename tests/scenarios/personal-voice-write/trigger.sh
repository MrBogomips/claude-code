#!/usr/bin/env bash
# Layer 2 helper: runs one headless Claude Code session with the personal-voice
# plugin loaded from this repository and prints the skills the model invoked.
# Checks description triggering only; the store does not need to be configured.
# usage: bash trigger.sh WORKDIR "prompt"
set -euo pipefail

[[ $# -eq 2 ]] || { echo "usage: $0 WORKDIR PROMPT" >&2; exit 2; }
REPO_ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
workdir="$1"
prompt="$2"
mkdir -p "$workdir"
cd "$workdir"

claude -p "$prompt" --plugin-dir "$REPO_ROOT/personal-voice" --permission-mode default \
    --output-format stream-json --verbose 2>/dev/null \
    | jq -r 'select(.type=="assistant") | .message.content[]?
             | select(.type=="tool_use" and .name=="Skill") | .input.skill'
