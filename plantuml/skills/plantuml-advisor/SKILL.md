---
name: plantuml-advisor
description: Advise on diagram-type fit for a `.puml` — confirm the current type is right, or suggest a better one with rationale and a migration sketch. Use when an author is unsure whether class, component, sequence, or another type fits the intent best.
model: sonnet
allowed-tools: Read
---

# PlantUML Advisor

Type-fit advice for a single `.puml`. Interactive, no agent.

## Flow

1. Read the file. Identify the current diagram type from the leading
   directives (`@startuml`, `class`/`component`/`participant`/etc.).
2. Read the user's intent: any heading comment (`' purpose:`), file path
   context, and the elements present (entities, relationships).
3. Cross-reference with `principles.md` of the inherited
   `plantuml-authoring` skill:
   `${CLAUDE_PLUGIN_ROOT}/skills/plantuml-authoring/principles.md`
   and the `diagrams/INDEX.md` decision table for type selection.
4. Produce structured advice in four sections (below).

## Output sections

### 1. Current type

Name the type the file uses today, with one-sentence justification of how
you classified it.

### 2. Intent reading

What you understand the diagram is trying to communicate, in 1–2
sentences. Explicitly note where the intent is ambiguous and what
clarification would help.

### 3. Recommended type

`Same` (no change needed) or `<better-type>`. Cite the relevant principle
from `principles.md` by section number and title (e.g.,
"`principles.md §4 Layout follows flow, not convenience` argues for a
sequence diagram when ordering is the message"). One-paragraph rationale.

### 4. Migration sketch

If recommended type ≠ current type: a minimal `@startuml` skeleton in the
new type, listing which existing elements survive (and how they map) and
which ones disappear. Skip this section if no change is recommended.

## Tone

Authoritative but humble — when intent is genuinely unclear, ask for
confirmation rather than guess. End with a one-line verdict:
`Type is fit` / `Consider switching to <type>` / `Need user clarification`.
