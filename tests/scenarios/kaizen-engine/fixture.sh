#!/usr/bin/env bash
# Layer 2 fixture for kaizen-engine: builds a disposable git repo with a trivial
# greedy profile (minimize TODO lines under src/), or fingerprints its state to
# prove byte-identical reverts and commit contents.
# macOS/BSD compatible (bash 3.2).
set -euo pipefail

GIT_ID=(-c user.name=fixture -c user.email=fixture@example.invalid)
DIRTY_LINE='uncommitted user edit'

usage() {
    echo "usage: $0 create DIR [default|strict-epsilon|failing-check]" >&2
    echo "       $0 dirty DIR | interrupt DIR [project|user] | fingerprint DIR" >&2
    exit 2
}

# Prints "<KPI epsilon> <convergence epsilon>" for a variant.
epsilons() {
    case "$1" in
        default|failing-check) echo "1 10" ;;
        strict-epsilon) echo "5 1" ;;
        *) usage ;;
    esac
}

# $1 = repo, $2 = KPI epsilon, $3 = convergence (fallback) epsilon
write_profile() {
    local repo="$1" kpi_eps="$2" fallback_eps="$3"
    local dir="$repo/.kaizen/profiles/todo-count"
    mkdir -p "$dir"
    cat > "$dir/PROFILE.md" <<EOF
---
name: todo-count
description: "Fixture profile: resolve TODO lines under src/"
version: 0.1.0

strategy: greedy
autonomy: autonomous
iteration_budget: 1
convergence:
  epsilon: $fallback_eps
  patience: 1

initial_state:
  capture_strategy: automatic
  sources:
    - type: config
      path: "src/"
      description: "Text files whose TODO lines are counted"

measurement:
  tool_generation: true
  language: python

kpis:
  - name: todo_count
    description: "Number of lines containing the string TODO in src/*.txt"
    direction: minimize
    unit: count
    epsilon: $kpi_eps
    measurement_method: automated
    formula: "count of lines containing 'TODO' across src/*.txt"

mutation_targets:
  defaults:
    - path: "src/"
      description: "Text files with TODO lines, and src/DONE.md"
  immutable:
    - path: "checks/**"
    - path: ".git/**"

connectors:
  required: []
  optional: []
---
EOF
    cat >> "$dir/PROFILE.md" <<'EOF'

# TODO Count Fixture Instructions

## MEASURE Phase

Count the lines that contain the string `TODO` in every `src/*.txt` file. Do not count `src/DONE.md`.

## ANALYZE Phase

Every TODO line left is room for improvement. A lower count is better.

## HYPOTHESIZE Phase

Each TODO line is an open task that can be resolved by moving it to `src/DONE.md`.

## PROPOSE Phase

Propose exactly one change per iteration: delete one TODO line from one `src/*.txt` file, and append that line, without its `TODO: ` prefix, to `src/DONE.md`, creating `src/DONE.md` if it does not exist. Do not edit any other line.

## APPLY Phase

Edit only the two files named in the proposal.

## VERIFY Phase

Run `sh checks/verify.sh` from the repository root. It must exit 0.
EOF
}

# $1 = repo, $2 = variant
write_check() {
    local repo="$1" variant="$2"
    mkdir -p "$repo/checks"
    if [ "$variant" = "failing-check" ]; then
        # Passes on the baseline (7 lines); fails once any src/*.txt line is deleted.
        cat > "$repo/checks/verify.sh" <<'EOF'
#!/bin/sh
lines=$(cat src/*.txt | wc -l | tr -d ' ')
[ "$lines" -ge 7 ] || { echo "src/*.txt lost lines: $lines < 7" >&2; exit 1; }
EOF
    else
        cat > "$repo/checks/verify.sh" <<'EOF'
#!/bin/sh
exit 0
EOF
    fi
}

write_repo() {
    local repo="$1" variant="$2" eps kpi_eps fallback_eps
    eps="$(epsilons "$variant")"
    kpi_eps="${eps% *}"; fallback_eps="${eps#* }"
    mkdir -p "$repo/src"
    printf 'alpha line one\nTODO: rename alpha\nalpha line three\n' > "$repo/src/a.txt"
    printf 'beta line one\nTODO: document beta\nbeta line three\nTODO: test beta\n' > "$repo/src/b.txt"
    printf '# Fixture project\n\nA scratch repository for kaizen-engine scenarios.\n' > "$repo/README.md"
    write_check "$repo" "$variant"
    write_profile "$repo" "$kpi_eps" "$fallback_eps"
}

create() {
    local root="$1" variant="${2:-default}"
    if [ -e "$root" ]; then
        echo "refusing: $root already exists" >&2
        exit 1
    fi
    write_repo "$root/repo" "$variant"
    printf '%s\n' "$variant" > "$root/variant"
    git -C "$root/repo" init -q -b main
    git -C "$root/repo" add -A
    git -C "$root/repo" "${GIT_ID[@]}" commit -qm "init"
    # An uncommitted edit outside the mutation targets: it must neither trigger
    # the dirty-tree prompt nor end up in a kaizen commit.
    printf '\nLocal note, not part of any iteration.\n' >> "$root/repo/README.md"
    echo "repo:    $root/repo"
    echo "variant: $variant"
    echo "HEAD:    $(git -C "$root/repo" rev-parse HEAD)"
}

# Adds an uncommitted user edit inside the mutation targets.
dirty() {
    local root="$1"
    [ -d "$root/repo/.git" ] || { echo "not a fixture: $root" >&2; exit 1; }
    printf '%s\n' "$DIRTY_LINE" >> "$root/repo/src/a.txt"
    git -C "$root/repo" status --porcelain -- src/
}

# Measurement script and config of the simulated run: counts the TODO lines in
# src/*.txt, run from the project root.
write_measure() {
    local run="$1"
    cat > "$run/measure.py" <<'EOF'
#!/usr/bin/env python3
"""Kaizen measurement tool: todo-count (fixture)."""
import glob
import json
import sys
from datetime import datetime, timezone
from pathlib import Path


def main():
    try:
        config = json.loads((Path(__file__).parent / "config.json").read_text())
        files = sorted(glob.glob("src/*.txt"))
        count = 0
        for path in files:
            with open(path) as f:
                count += sum(1 for line in f if "TODO" in line)
        print(json.dumps({
            "kpis": {"todo_count": count},
            "metadata": {
                "timestamp": datetime.now(timezone.utc).isoformat(),
                "profile": config["profile"],
                "measurement_duration_ms": 0,
                "details": {"todo_count": {"files": len(files)}},
            },
        }, indent=2))
    except Exception as e:
        print(json.dumps({"error": str(e), "partial_kpis": {}, "recoverable": False}), file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
EOF
    cat > "$run/config.json" <<'EOF'
{
  "profile": "todo-count",
  "run_id": "2026-01-15-todo-count-001",
  "sources": [{"type": "config", "path": "src/"}],
  "kpis": [{"name": "todo_count", "formula": "count of lines containing 'TODO' across src/*.txt", "direction": "minimize"}]
}
EOF
}

# $1 = run dir, $2 = storage root name, $3 = profile path, $4 = KPI eps, $5 = fallback eps
write_manifest() {
    cat > "$1/manifest.json" <<EOF
{
  "run_id": "2026-01-15-todo-count-001",
  "profile": "todo-count",
  "profile_version": "0.1.0",
  "profile_path": "$3",
  "storage_root": "$2",
  "started_at": "2026-01-15T09:00:00Z",
  "strategy": "greedy",
  "autonomy": "autonomous",
  "iteration_budget": 1,
  "convergence": {"epsilon": $5, "patience": 1},
  "kpis": [
    {"name": "todo_count", "description": "Number of lines containing the string TODO in src/*.txt",
     "direction": "minimize", "unit": "count", "epsilon": $4, "observational": false,
     "measurement_method": "automated", "formula": "count of lines containing 'TODO' across src/*.txt"}
  ],
  "mutation_targets": {"defaults": ["src/"], "immutable": ["checks/**", ".git/**"]},
  "verify_checks": [{"name": "verify", "command": "sh checks/verify.sh"}],
  "git": {"repo": true, "commits": true, "branch": null, "dirty_at_start": []},
  "measure_script": "measure.py",
  "measure_script_reused_from": null,
  "scope_overrides": {},
  "previous_run": null,
  "previous_final": null
}
EOF
}

# Simulates an open run whose session ended partway through APPLY of iteration
# 001: backup and created.txt were written and src/a.txt was already edited, but
# src/DONE.md was not created, and there is no diff.patch, decision.json or
# summary.json. $2 picks the storage root: the project's .kaizen/, or
# $DIR/home/.kaizen/ (the scenario tells the agent that ~ is $DIR/home).
interrupt() {
    local root="$1" where="$2" base eps
    [ -d "$root/repo/.git" ] || { echo "not a fixture: $root" >&2; exit 1; }
    case "$where" in
        project) base="$root/repo/.kaizen" ;;
        user) base="$root/home/.kaizen" ;;
        *) usage ;;
    esac
    eps="$(epsilons "$(cat "$root/variant")")"
    local run="$base/runs/2026-01-15-todo-count-001"
    local it="$run/iterations/001"
    [ ! -e "$run" ] || { echo "refusing: $run already exists" >&2; exit 1; }
    mkdir -p "$it/backup/src"
    write_measure "$run"
    write_manifest "$run" "$where" "$root/repo/.kaizen/profiles/todo-count/PROFILE.md" "${eps% *}" "${eps#* }"
    printf '{"iteration": 0, "timestamp": "2026-01-15T09:01:00Z", "kpis": {"todo_count": 3}, "source": "automated", "execution_time_ms": 40, "warnings": []}\n' \
        > "$run/baseline.json"
    printf '{"iteration": 1, "timestamp": "2026-01-15T09:02:00Z", "kpis": {"todo_count": 3}, "source": "automated", "execution_time_ms": 40, "warnings": []}\n' \
        > "$it/measurement.json"
    printf '# Iteration 1 Analysis\n\n3 TODO lines remain; todo_count is the only KPI.\n' > "$it/analysis.md"
    cat > "$it/proposal.md" <<'EOF'
# Iteration 1 Proposal

## Target
- **File(s):** `src/a.txt`, `src/DONE.md` (new)

## Change Description

Delete the line `TODO: rename alpha` from `src/a.txt`, and create `src/DONE.md` containing the single line `rename alpha`.

## Confidence: high
EOF
    # APPLY steps 1-2 had run: backup of the original file, created.txt, no outside edits.
    cp "$root/repo/src/a.txt" "$it/backup/src/a.txt"
    printf 'src/DONE.md\n' > "$it/backup/created.txt"
    : > "$it/dirty-before-apply.txt"
    # APPLY step 4 stopped after its first edit.
    printf 'alpha line one\nalpha line three\n' > "$root/repo/src/a.txt"
    echo "open run: $run"
}

# Everything except .git and the run directories: file checksums, branch, HEAD
# and the porcelain status.
fingerprint() {
    local root="$1"
    [ -d "$root/repo/.git" ] || { echo "not a fixture: $root" >&2; exit 1; }
    ( cd "$root/repo" && find . \( -path ./.git -o -path ./.kaizen/runs \) -prune -o -type f -print \
        | LC_ALL=C sort | while IFS= read -r f; do cksum "$f"; done )
    git -C "$root/repo" branch --show-current
    git -C "$root/repo" rev-parse HEAD
    git -C "$root/repo" status --porcelain -- . ':(exclude).kaizen/runs'
}

[ "$#" -ge 2 ] || usage
case "$1" in
    create) [ "$#" -le 3 ] || usage; create "$2" "${3:-default}" ;;
    dirty) [ "$#" -eq 2 ] || usage; dirty "$2" ;;
    interrupt) [ "$#" -le 3 ] || usage; interrupt "$2" "${3:-project}" ;;
    fingerprint) [ "$#" -eq 2 ] || usage; fingerprint "$2" ;;
    *) usage ;;
esac
