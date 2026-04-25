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
  Materializing .plantuml/ (theme: aws, targets: png svg)...
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
  diagrams/login.puml [png]: blessed
  diagrams/login.puml [svg]: blessed
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
- Agents (`agents/<name>/AGENT.md`) are auto-discovered by Claude Code. If discovery fails on first install, the orchestrating skills degrade to inline Sonnet invocations (correct but slower and costlier). Verify agent availability at first use.

## Dev

The plugin is the source of truth for all PlantUML evolution. Edits go directly under `plantuml/`. Smoke tests live at `plantuml/tests/smoke/`. The minimal fixture project used by the smoke tests is at `plantuml/tests/fixtures/minimal-project/`.
