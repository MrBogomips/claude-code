---
description: Bootstrap a project for PlantUML authoring (delegates to the plantuml-bootstrap skill)
---

Invoke the `plantuml-bootstrap` skill from the `plantuml` plugin.

If the user passed `--reverse`, pass `mode=reverse` as the skill argument.
Otherwise use the default `mode=bootstrap`.

The skill handles wizard, generation, and validation autonomously. If the
delegation does not work in the current harness, fall back to inlining the
`plantuml-bootstrap` body (see `${CLAUDE_PLUGIN_ROOT}/skills/plantuml-bootstrap/SKILL.md`).
