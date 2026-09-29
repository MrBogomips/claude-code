---
name: plantuml-authoring
description: Author PlantUML diagrams (UML, C4, ER, ArchiMate, MindMap, WBS,
  Gantt, Salt, JSON/YAML, nwdiag family). Use when creating, restructuring, or
  choosing a type for a .puml/.plantuml/.iuml file, when setting up PlantUML
  project configuration, or when adapting diagrams to a render target
  (web/docx/pdf/pptx). For rendering to image, use plantuml-convert.
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
---

# PlantUML Authoring

Progressive disclosure router. Do NOT read all sub-files by default.
Decide which sub-files to load based on the routing rules below.

## Routing

1. **Project has no `.plantuml/` AND no "PlantUML Policy" section in
   CLAUDE.md?**
   → Read `project-config.md` and run the bootstrap dialog.

2. **Need to choose a diagram type or generate one?**
   → Read `principles.md` (once, ~200 lines; applies to every type).
   → If type is already picked: read only `diagrams/<type>.md`.
   → If not: read `diagrams/INDEX.md` first to pick, then the type file.

3. **Rendering requested (any target)?**
   → Read `render-profiles.md`.
   → Compose the `plantuml-convert` invocation with `PLANTUML_TARGET` env var.

4. **Refactoring or reviewing an existing diagram?**
   → Do NOT re-run bootstrap. Respect existing `.plantuml/`.
   → Read `principles.md` + `diagrams/<type>.md`.

## Universal workflow (apply in order)

1. **Audience & purpose.** Ask: who reads this, what decision/understanding
   does it support? If unclear, ask the user — do not guess.
2. **Pick type.** Consult `diagrams/INDEX.md` decision table.
3. **Pick detail level preset.** The `diagrams/<type>.md` file lists its
   own `minimal`/`standard`/`detailed` presets. Default to the project's
   `Default detail level` from CLAUDE.md Policy, else `standard`.
4. **Emit `.puml`.** Start with:
   ```
   @startuml <Title>
   !$target = %getenv("PLANTUML_TARGET")
   !include .plantuml/_base.puml
   !include .plantuml/_targets/$target.puml
   ```
   If the project is unconfigured and the user chose "one-shot", inline
   defaults instead of `!include`, and add:
   `' TODO: run /plantuml-init to share styling across diagrams`.
5. **Validate.** Run `plantuml -checkonly <file>`; must exit 0.
6. **Render (if requested).** Invoke `plantuml-convert` with appropriate
   target profile (see `render-profiles.md`).

## Inherited invariants

Every diagram satisfies the five `plantuml-lint` invariants R1–R5, defined in
`${CLAUDE_PLUGIN_ROOT}/agents/puml-linter/AGENT.md`: include `_base.puml`; no inline
`skinparam` that the base already sets; no hex color literals outside `_*.puml` partials;
the `@start…` id matches the filename; one `@start…`/`@end…` block per file. R1–R3 apply
when the project has a PlantUML Policy.

## Do NOT

- Do NOT modify `plantuml-convert`; only invoke it.
- Do NOT write `skinparam` blocks inline in a diagram when the project has
  `.plantuml/_theme.puml` — put them in the theme file.
- Do NOT commit rendered PNG/SVG to version control unless the project
  explicitly requires it (images are build artifacts of `.puml` sources).
- Do NOT translate skill files; they stay English. Per-project label
  localization is controlled by the `Label language` Policy key.

Maintainers: the variant test suite and reviewer protocol are documented in the plugin README § Dev.
