---
name: plantuml-review
description: Review a single PlantUML diagram for clarity, type-fit, layout, and readability. Use when an author wants qualitative feedback before merging or sharing.
model: sonnet
allowed-tools: Read, Bash
---

# PlantUML Review

Qualitative review of a single `.puml` file. Interactive, no agent.

## Input

A file path. If multiple are passed, review them sequentially (one per
turn).

## Flow

1. Run `plantuml -checkonly <file>` first. If it errors, surface the
   syntax error and stop — there is nothing meaningful to review.
2. Read the file.
3. If a `## PlantUML Policy` section exists in the project's CLAUDE.md,
   read it (for label-language, detail-level expectations).
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
