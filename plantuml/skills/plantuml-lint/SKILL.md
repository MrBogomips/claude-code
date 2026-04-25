---
name: plantuml-lint
description: Check `.puml` files for PlantUML Policy drift, broken includes, and invariant violations (hardcoded colors, missing `_base.puml`, filename≠title, duplicated skinparams). Use when reviewing diagrams for compliance.
allowed-tools: Read, Glob, Grep, Bash, Task
---

# PlantUML Lint

Static lint over `.puml` files in the current project.

## Usage

Default: lint every `.puml` and `.plantuml` and `.iuml` under the project
root, excluding `.plantuml/_*.puml` (those are policy partials, not
authored diagrams).

Custom path: a single file, glob, or directory passed as argument.

## Flow

1. **Detect policy presence**:
   ```bash
   grep -q '^## PlantUML Policy' CLAUDE.md 2>/dev/null && \
     test -f .plantuml/_base.puml && policy_present=true || policy_present=false
   ```
2. **Enumerate files** via `Glob`, excluding `.plantuml/_*.puml`.
3. **Batch** files into chunks of ≤10.
4. **Dispatch** each batch to `puml-linter` (agent) via `Task`. Pass the
   batch + `project_root` (absolute, from `pwd`) + `policy_present` as
   the prompt. Run batches in parallel.
5. **Aggregate** the JSON arrays into one. Sort by `file` then `line`.
6. **Render** a table for the user:

   ```
   file              | rule | sev   | message
   ----------------- | ---- | ----- | -------
   diagrams/Drift.puml | R3 | error | hex color #FF00FF (line 3) — use $primary
   ```

   Plus a footer: `N error(s), M warning(s) across K file(s) checked`.

## Exit semantics

If any error: skill ends with non-zero summary ("lint failed: N errors").
Otherwise: "lint passed: K files clean".

## Notes

- The agents return JSON, never prose. Reject and re-dispatch a batch
  whose output does not parse as JSON.
- Do NOT auto-fix. This skill is read-only.
- For ad-hoc single-file lint, you may apply the rules inline (skipping
  the agent dispatch) when N=1 — minor optimization, not required.
