---
name: plantuml-lint
description: Check `.puml` files for PlantUML Policy drift and invariant violations (missing `_base.puml` include, `!include` targets that do not exist, hardcoded colors, filename≠`@start` id, duplicated skinparams). Use when reviewing diagrams for compliance.
allowed-tools: Read, Glob, Grep, Bash, Agent
---

# PlantUML Lint

Static lint over `.puml` files in the current project.

## Usage

Default: lint every `.puml` and `.plantuml` under the project root,
excluding everything under `.plantuml/` (policy partials and `_targets/`
overrides, not authored diagrams). `.iuml` files are include files with no
`@start` block, so they are not in the default scope; passed explicitly,
they are checked only against the rules that apply to include files (R2,
R6).

Custom path: a single file, glob, or directory passed as argument.

## Flow

1. **Detect policy presence**:
   ```bash
   if grep -q '^## PlantUML Policy' CLAUDE.md 2>/dev/null && test -f .plantuml/_base.puml; then
     policy_present=true
   else
     policy_present=false
   fi
   ```
   With a Policy, read its Primary and Additional targets into `targets`
   (R6 expands `$target` in include paths with each of them). Without one,
   `targets` is empty.
2. **Enumerate files** via `Glob`, excluding everything under `.plantuml/`.
3. **Batch** files into chunks of ≤10.
4. **Dispatch** each batch to `puml-linter` (agent) via the `Agent` tool. Pass the
   batch + `project_root` (absolute, from `pwd`) + `policy_present` +
   `targets` as the prompt. Run batches in parallel.
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
