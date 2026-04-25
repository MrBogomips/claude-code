# Mind Maps

## Purpose

Hierarchical concept map radiating from a central node. Good for
brainstorming, note-taking, or executive-facing conceptual overviews.

## Choose this when / avoid when

- ✅ Capturing a brainstorm or a concept decomposition
- ✅ High-level overview slides
- ❌ Project decomposition with ownership/effort → use `wbs`
- ❌ Process flow → use `activity`

## Detail-level presets

- `minimal`: 2 levels (root + children).
- `standard`: 3 levels, max ~6 children per node.
- `detailed`: 4 levels with notes; beyond that the map becomes noise.

## Layout tips

- Use `@startmindmap` / `@endmindmap`.
- `*` for right branches, `-` for left. Balance both sides.
- Leaf nodes can carry a short note with `:caption:` syntax.

## Render-engine note (PlantUML 1.2026.x)

PlantUML 1.2026.x mindmap rendering does **not reserve enough left-side
padding**, especially when branches grow leftward (`-` prefix). The SVG
viewBox can start at a negative `x`, and PNG output clips the leftmost
labels. Adversarial reviewers consistently flag this as a defect.

Add explicit canvas padding at the top of any mindmap that uses
left-side branches:

```plantuml
@startmindmap Mindmap_<Subject>
!$target = %getenv("PLANTUML_TARGET")
!include .plantuml/_base.puml
!include .plantuml/_targets/$target.puml

skinparam padding 24    ' prevents left-edge clipping
…
@endmindmap
```

24 px is sufficient for typical labels; increase to 40+ if your labels
are long.

## Snippet

```plantuml
@startmindmap Mindmap_PlatformObjectives
!$target = %getenv("PLANTUML_TARGET")
!include .plantuml/_base.puml
!include .plantuml/_targets/$target.puml

skinparam padding 24

* Platform Objectives
** Reliability
*** SLO 99.9%
*** Disaster recovery
** Performance
*** Latency p95 < 200 ms
*** Throughput +30%
** Security
*** OWASP compliance
*** Audit trail
-- Cost
--- Cloud spend -15%
-- Team
--- Hiring plan
--- Training
@endmindmap
```

## Common pitfalls

- Using a mindmap as a project plan. Fix: use WBS.
- Unbalanced trees (all branches right). Fix: alternate left/right.
- **Left-side branch labels get clipped at canvas edge.** Fix: add
  `skinparam padding 24` (or larger). See Render-engine note above.
