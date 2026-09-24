#!/usr/bin/env bash
# Layer 2 fixture for context-hygiene: builds a disposable project + memory dir
# with known hygiene defects, or fingerprints their state to prove zero writes.
# macOS/BSD compatible (bash 3.2).
set -euo pipefail

GIT_ID=(-c user.name=fixture -c user.email=fixture@example.invalid)

usage() {
    echo "usage: $0 create DIR | fingerprint DIR" >&2
    exit 2
}

write_repo() {
    local repo="$1"
    mkdir -p "$repo/alpha" "$repo/beta" "$repo/gamma" "$repo/notes-wip"
    local p
    for p in alpha beta gamma; do
        printf '# %s\n' "$p" > "$repo/$p/README.md"
    done
    printf '{"components":["alpha","beta","gamma"]}\n' > "$repo/components.json"
    printf 'notes-wip/\n' > "$repo/.gitignore"

    # W-a: lists 2 of 3 components. W-b: scripts/build.sh does not exist.
    # R-a: shell rule duplicated in memory/feedback_shell.md.
    cat > "$repo/CLAUDE.md" <<'EOF'
# CLAUDE.md

## Components

Each top-level directory is a component (see `components.json`):

- `alpha/` — first component
- `beta/` — second component

## Build

Run `scripts/build.sh` before committing.

## Shell conventions

Avoid `((VAR++))` with `set -e`; use `VAR=$((VAR + 1))`.
EOF

    # S-b: superseded by the -1.1.0 sibling.
    cat > "$repo/notes-wip/2026-01-10-gamma-design.md" <<'EOF'
# Gamma design

Doc version: 1.0.0

Decision: gamma stores state in a flat file.
EOF
    cat > "$repo/notes-wip/2026-01-10-gamma-design-1.1.0.md" <<'EOF'
# Gamma design

Doc version: 1.1.0 — Refines 2026-01-10-gamma-design.md

Decision: gamma stores state in a flat file; writes are atomic via rename.
EOF
    # S-c: handoff whose branch is merged and whose boxes are all checked.
    cat > "$repo/notes-wip/HANDOFF-gamma.md" <<'EOF'
# Handoff: gamma

Branch: feature/gamma

- [x] implement gamma state
- [x] tests
EOF
}

commit_repo() {
    local repo="$1"
    git -C "$repo" init -q -b main
    git -C "$repo" add -A
    git -C "$repo" "${GIT_ID[@]}" commit -qm "init"
    git -C "$repo" checkout -qb feature/gamma
    printf 'state\n' > "$repo/gamma/state.txt"
    git -C "$repo" add gamma/state.txt
    git -C "$repo" "${GIT_ID[@]}" commit -qm "feat(gamma): flat-file state"
    git -C "$repo" checkout -q main
    git -C "$repo" "${GIT_ID[@]}" merge -q --no-ff feature/gamma -m "Merge branch 'feature/gamma'"
    git -C "$repo" branch -qd feature/gamma
}

write_memory() {
    local mem="$1"
    mkdir -p "$mem"
    # S-a: status narrative in index line 3. W-c: reference_tracker.md missing.
    # W-d: user_role.md exists but is not indexed.
    cat > "$mem/MEMORY.md" <<'EOF'
# Memory Index

- [project_gamma.md](project_gamma.md) — gamma: PR #12 pending review, v0.3.0 WIP, next step merge
- [feedback_shell.md](feedback_shell.md) — shell arithmetic rule for set -e scripts
- [reference_tracker.md](reference_tracker.md) — where issues are tracked
EOF
    cat > "$mem/feedback_shell.md" <<'EOF'
---
name: feedback-shell
description: shell arithmetic rule for set -e scripts
metadata:
  type: feedback
---

Avoid `((VAR++))` with `set -e`; use `VAR=$((VAR + 1))`.
EOF
    cat > "$mem/user_role.md" <<'EOF'
---
name: user-role
description: the user is a backend developer
metadata:
  type: user
---

The user is a backend developer who prefers small PRs.
EOF
    write_gamma_memory "$mem/project_gamma.md"
}

# R-b: >3 KB narrative that hides one decision and one lesson.
write_gamma_memory() {
    local f="$1" i=0
    cat > "$f" <<'EOF'
---
name: project-gamma
description: gamma: PR #12 pending review, v0.3.0 WIP, next step merge
metadata:
  type: project
---

Decision: gamma uses flat-file state (user chose it over sqlite, 2026-01-10).

Incident 2026-01-12: the first version wrote state in place and corrupted it
on crash. Lesson: never write state in place; write a temp file, then rename.

## Status log
EOF
    while [ "$i" -lt 45 ]; do
        printf -- '- 2026-01-%02d: status update — CI green, waiting for review, rebased on main\n' \
            $(( (i % 28) + 1 )) >> "$f"
        i=$((i + 1))
    done
}

create() {
    local root="$1"
    if [ -e "$root" ]; then
        echo "refusing: $root already exists" >&2
        exit 1
    fi
    write_repo "$root/repo"
    commit_repo "$root/repo"
    write_memory "$root/memory"
    echo "repo:   $root/repo"
    echo "memory: $root/memory"
}

fingerprint() {
    local root="$1"
    [ -d "$root/repo/.git" ] || { echo "not a fixture: $root" >&2; exit 1; }
    ( cd "$root" && find . -path ./repo/.git -prune -o -type f -print \
        | LC_ALL=C sort | while IFS= read -r f; do cksum "$f"; done )
    git -C "$root/repo" rev-parse HEAD
    git -C "$root/repo" status --porcelain
}

[ "$#" -eq 2 ] || usage
case "$1" in
    create) create "$2" ;;
    fingerprint) fingerprint "$2" ;;
    *) usage ;;
esac
