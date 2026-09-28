# plantuml

Authoring, rendering, and maintenance of PlantUML diagrams in Claude Code projects. Policy-driven theming, multi-target output (web/docx/pdf/pptx), and a maintenance layer for lint, validate, review, advisor, and migration.

## Status

v1.0.0 — all 8 skills, 4 agents, and 1 command are present and validated by in-tree smoke tests.

The smoke tests (`plantuml/tests/smoke/`) are static structural assertions: they verify that skills, agents, commands, and the plugin manifest are correctly wired. Behavioral correctness (LLM-driven authoring and maintenance flows) is validated in real use after install.

## Requirements

- `plantuml` CLI — `brew install plantuml` (macOS) or `apt install plantuml` (Debian/Ubuntu)
- `java` — pulled transitively by the plantuml package
- `jq` — required by the marketplace structural tests

## Install

Add this marketplace to Claude Code and install the `plantuml` plugin via the plugin manager.

## Quickstart

```
# 1. Bootstrap your project
> /plantuml-init

  Creating ## PlantUML Policy in CLAUDE.md...
  Materializing .plantuml/ (theme: cerulean-outline, targets: docx web)...
  Done. Edit CLAUDE.md > PlantUML Policy to customize.

# 2. Author a diagram (the plantuml-authoring skill activates on intent)
> Create a sequence diagram for our login flow and save it as diagrams/login.puml

  [plantuml-authoring activates]
  Writing diagrams/login.puml with skinparam includes from _base.puml...
  Done.

# 3. Maintain it
> Lint all .puml files

  [plantuml-lint activates, dispatches puml-linter agents in parallel]
  diagrams/login.puml: OK

> plantuml-validate mode=bless

  [plantuml-validate activates, renders all targets, writes baselines]
  diagrams/login.puml [docx]: blessed
  diagrams/login.puml [web]: blessed
```

## Components

### Authoring and Rendering

| Component | Kind | Purpose |
|-----------|------|---------|
| `plantuml-authoring` | Skill | Create or restructure `.puml` files for any diagram type (UML, C4, ER, ArchiMate, MindMap, WBS, Gantt, Salt, JSON/YAML, nwdiag family) |
| `plantuml-convert` | Skill | Convert `.puml` files to PNG, SVG, or PDF; used by document skills as a render step |
| `puml-renderer` | Agent | Build-time worker: render or validate a single (file, target) pair and compare against a baseline |

### Bootstrap

| Component | Kind | Purpose |
|-----------|------|---------|
| `plantuml-bootstrap` | Skill | Create the `## PlantUML Policy` in `CLAUDE.md` and materialize `.plantuml/`; also runs in `mode=reverse` to recover policy from an existing directory |
| `/plantuml-init` | Command | User-facing shortcut that delegates to `plantuml-bootstrap` |

### Maintenance

| Component | Kind | Purpose |
|-----------|------|---------|
| `plantuml-lint` | Skill | Check `.puml` files for Policy drift, broken includes, and invariant violations (hardcoded colors, missing `_base.puml`, filename/title mismatch) |
| `plantuml-validate` | Skill | Render all declared targets and verify output against committed baselines; accepts `mode=check|bless` and `level=checkonly|svg-hash|png-perceptual` |
| `plantuml-review` | Skill | Qualitative review of a diagram for clarity, type-fit, layout, and readability |
| `plantuml-advisor` | Skill | Advise on diagram-type fit: confirm the current type or suggest a better one with a migration sketch |
| `plantuml-migrate` | Skill | Apply a Policy change (theme switch, target add/remove, brand colors) across all `.puml` files; backs up `.plantuml/` before any destructive write |

### Build-time Workers

| Component | Kind | Purpose |
|-----------|------|---------|
| `puml-linter` | Agent | Lint a batch of `.puml` files against Policy invariants; dispatched in parallel by `plantuml-lint` |
| `puml-migrator` | Agent | Apply a declarative edit plan to a single `.puml` file; dispatched by `plantuml-migrate` |
| `puml-visual-checker` | Agent | Smoke-check a rendered image for color, font, and layout correctness; build-time only, not user-facing in v1.0.0 |

## Maintenance Flow

Typical lifecycle after initial bootstrap:

1. **Bootstrap** — `/plantuml-init` once per project.
2. **Author** — `plantuml-authoring` to create or restructure `.puml` files.
3. **Lint** — `plantuml-lint` to catch Policy drift and invariant violations.
4. **Validate** — `plantuml-validate mode=bless` to commit baselines; `mode=check` in CI.
5. **Review / Advisor** — `plantuml-review` for qualitative feedback; `plantuml-advisor` when the diagram type feels wrong.
6. **Policy change** — edit `## PlantUML Policy` in `CLAUDE.md`, then `plantuml-migrate` to propagate to all files.

## Verifying Install

From the marketplace root:

```bash
bash tests/ci/run-structural-tests.sh
```

Then run the six plugin smoke tests:

```bash
for t in bootstrap lint validate review advisor migrate; do
  bash plantuml/tests/smoke/test-$t.sh
done
```

All must pass before considering the install complete.

## Known Limitations (v1.0.0)

- `plantuml-validate level=png-perceptual` is not implemented and returns `unsupported`. Use `level=checkonly` (default) or `level=svg-hash` for CI.
- `plantuml-migrate` has no concurrent-edit locking. Do not run while another tool is writing `.puml` files.
- `puml-visual-checker` is a build-time agent only; it is not exposed as a user-facing skill in v1.0.0.
- Cross-machine `level=svg-hash` comparisons require pinned fonts. On heterogeneous CI, prefer `level=checkonly`.
- Agents (`agents/<name>/AGENT.md`) are auto-discovered by Claude Code. `plantuml-lint`, `plantuml-validate` and `plantuml-migrate` dispatch them and define no inline fallback, so verify agent availability at first use.

## Dev

The plugin is the source of truth for all PlantUML evolution. Edits go directly under `plantuml/`. Smoke tests live at `plantuml/tests/smoke/`. The minimal fixture project used by the smoke tests is at `plantuml/tests/fixtures/minimal-project/`.

### Test harness — reviewer dispatch

Maintainer protocol for the `plantuml-authoring` skill. Paths are relative to
`plantuml/skills/plantuml-authoring/`.

The test harness (`scripts/run-test-suite.sh`) automates steps 1–2
(generate + render) and step 4 (aggregate). Step 3 (adversarial
reviewers) is an **agent** responsibility: this skill does not
spawn subagents from a shell script.

#### When to run the suite
- After any material change to principles.md, render-profiles.md,
  or a `diagrams/<type>.md` file.
- Before considering this skill "done" in an implementation cycle.

#### Dispatch protocol

1. Run the orchestrator:
   `bash scripts/run-test-suite.sh`
   This prints the run directory (e.g. `~/temp/plantuml-tests/2026-
   04-24-run-01`).
2. For each type directory under `<run>/`, spawn one subagent via
   the `Agent` tool (general-purpose, with `Read` on .puml / .svg /
   .png). **Use the multimodal capability to view PNG.**
3. Prompt (English, adversarial; see full text below).
4. Subagent writes `review.md` into each `<run>/<type>/<variant>/`
   directory.
5. After all 23 subagents complete, run
   `scripts/aggregate-reviews.sh <run>` — it emits `_report.md` and
   exits non-zero if any variant FAILs.

#### Subagent prompt template

```text
You are an adversarial reviewer for PlantUML diagrams. Report every
real flaw you find, plainly and without praise. If a diagram is
fine, say so in one sentence and move on.

Inspect 3 variants of a <TYPE> diagram: minimal / standard / detailed.
For each variant, read the source .puml, the .png (vision), and
optionally the .svg (XML text if overflow suspected):
  - <RUN>/<TYPE>/minimal/<file>.puml  / .png / .svg
  - <RUN>/<TYPE>/standard/<file>.puml / .png / .svg
  - <RUN>/<TYPE>/detailed/<file>.puml / .png / .svg

Evaluate against axes (severity BLOCKER / HIGH / MEDIUM / LOW):
  1. Readability (overflow, overlap, font size, contrast)
  2. Semantic clarity (is the ONE message identifiable in 5 s?)
  3. Detail-level coherence (does the gradient feel authentic?)
  4. Design-principle adherence (principles.md)
  5. Target appropriateness (DOCX & web)
  6. Source quality (include pattern, no hardcoded colors, title
     matches filename)

For each variant produce <RUN>/<TYPE>/<VARIANT>/review.md with:
  - `Verdict: PASS | PASS-WITH-WARNINGS | FAIL` (on a line starting
    with `Verdict:`)
  - Issues table: `| severity | axis | description | fix |`
  - One-line summary

End your combined output (just log, not file) with a cross-variant
comparison: is the gradient authentic, or are variants
interchangeable?

Do not modify any file. Reviews only.
```

#### Iteration loop

If `_report.md` has FAILs:
  1. Read `_report.md` top 10 systemic issues.
  2. Fix the corresponding principles/diagram file(s).
  3. Re-seed the FAILed variants with improved content.
  4. Re-run `run-test-suite.sh`.
  5. Dispatch reviewers again on the regenerated variants only.
  6. Re-aggregate.

Stop when `_report.md` shows 0 FAILs and any remaining warnings are
acknowledged.
