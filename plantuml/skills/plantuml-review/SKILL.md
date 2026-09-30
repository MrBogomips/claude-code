---
name: plantuml-review
description: Review a single PlantUML diagram for clarity, type-fit, layout, and readability. Use when an author wants qualitative feedback before merging or sharing. Not for deciding only which diagram type to use (plantuml-advisor), and not for Policy compliance checks (plantuml-lint).
allowed-tools: Read, Bash
disallowed-tools: Write, Edit
---

# PlantUML Review

Qualitative review of a single `.puml` file. Interactive, no agent, and
read-only: suggestions are given as text, never written to the file.

## Input

A file path. If multiple are passed, review them sequentially (one per
turn).

## Flow

1. If a `## PlantUML Policy` section exists in the project's CLAUDE.md,
   read it (for the Primary target, label-language and detail-level
   expectations).
2. Compile the file first. With a Policy, run
   `PLANTUML_TARGET=<Primary target> plantuml -checkonly <file>`: the
   project ships `_targets/` files only for its declared targets, so the
   target must be explicit. Without a Policy, run
   `plantuml -checkonly <file>`. If it errors, surface the syntax error and
   stop — there is nothing meaningful to review.
3. Read the file.
4. Read the relevant `diagrams/<type>.md` from the inherited
   `plantuml-authoring` skill at
   `${CLAUDE_PLUGIN_ROOT}/skills/plantuml-authoring/diagrams/<type>.md`
   for the type-specific principles.
5. Produce structured feedback in four sections (below).

## Output sections

### 1. Type fit

Is the chosen diagram type (class, component, sequence, …) right for what
the diagram is trying to communicate? If not, name the better type and
why. (For deeper "should I switch?" guidance, suggest invoking
`plantuml-advisor`.)

### 2. Detail level

Compare the actual element count and label density against the Policy's
default detail level (minimal | standard | detailed). Flag if too sparse
or too busy for the audience.

### 3. Layout

Crossings, awkward arrow paths, overflow risk in the declared targets,
left-to-right vs top-to-bottom appropriateness. One concrete suggestion if
issues are found.

### 4. Labels & language

Consistency with Policy `Label language`. Tone/abbreviations consistent
across labels. Mixed-case proper nouns intentional.

## Tone

Direct and specific. Cite line numbers. Do not rewrite the diagram —
suggest changes textually. End with a one-line verdict: `LGTM` /
`Minor suggestions` / `Recommend rework`.
