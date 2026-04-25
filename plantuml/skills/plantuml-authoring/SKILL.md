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

The rules file (`~/.claude/rules/documentation/plantuml.md`) is auto-loaded
when editing `*.puml` and lists 5 universal invariants. They are NOT
repeated here; treat them as always applied.

## Do NOT

- Do NOT modify `plantuml-convert`; only invoke it.
- Do NOT write `skinparam` blocks inline in a diagram when the project has
  `.plantuml/_theme.puml` — put them in the theme file.
- Do NOT commit rendered PNG/SVG to version control unless the project
  explicitly requires it (images are build artifacts of `.puml` sources).
- Do NOT translate skill files; they stay English. Per-project label
  localization is controlled by the `Label language` Policy key.

## Test harness — reviewer dispatch

The test harness (`scripts/run-test-suite.sh`) automates steps 1–2
(generate + render) and step 4 (aggregate). Step 3 (adversarial
reviewers) is an **agent** responsibility: this skill does not
spawn subagents from a shell script.

### When to run the suite
- After any material change to principles.md, render-profiles.md,
  or a `diagrams/<type>.md` file.
- Before considering this skill "done" in an implementation cycle.

### Dispatch protocol

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

### Subagent prompt template

```text
You are an adversarial reviewer for PlantUML diagrams. Your job is
to find EVERY flaw. Do not be diplomatic, do not praise. If a
diagram is fine, say so in one sentence and move on. Most of your
output should be criticism.

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

### Iteration loop

If `_report.md` has FAILs:
  1. Read `_report.md` top 10 systemic issues.
  2. Fix the corresponding principles/diagram file(s).
  3. Re-seed the FAILed variants with improved content.
  4. Re-run `run-test-suite.sh`.
  5. Dispatch reviewers again on the regenerated variants only.
  6. Re-aggregate.

Stop when `_report.md` shows 0 FAILs and any remaining warnings are
acknowledged.
