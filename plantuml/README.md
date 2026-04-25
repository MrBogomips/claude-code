# plantuml

Authoring, rendering, and maintenance of PlantUML diagrams in Claude Code projects. Policy-driven theming, multi-target output (web/docx/pdf/pptx), and a maintenance layer for lint, validate, review, advisor, and migration.

## Requirements

- `plantuml` CLI — `brew install plantuml` (macOS) or `apt install plantuml` (Debian/Ubuntu)
- `java` — pulled transitively by the plantuml package
- `jq` — required by the marketplace structural tests

## Install

Add the marketplace and install the plugin via Claude Code's plugin manager.

## Quickstart

1. Run `/plantuml-init` in your project root to create a `## PlantUML Policy` in `CLAUDE.md` and materialize `.plantuml/`.
2. Author `.puml` files — the `plantuml-authoring` skill activates on intent.
3. Maintain: `plantuml-lint`, `plantuml-validate`, `plantuml-review`, `plantuml-advisor`, `plantuml-migrate`.

## Components

- **Skills:** `plantuml-authoring`, `plantuml-convert`, `plantuml-bootstrap`, `plantuml-lint`, `plantuml-validate`, `plantuml-review`, `plantuml-advisor`, `plantuml-migrate`
- **Agents:** `puml-linter`, `puml-renderer`, `puml-migrator`, `puml-visual-checker`
- **Commands:** `/plantuml-init`

See each skill's `SKILL.md` for usage details.

## Verifying install

Run `bash tests/ci/run-structural-tests.sh` from the marketplace root. All suites should pass.

## Dev

The plugin is the source of truth for all PlantUML evolution. Edits go directly under `plantuml/`.
