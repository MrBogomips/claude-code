# Work Breakdown Structure

## Purpose

Decompose a project into deliverables/work packages in a tree. Each
node is a unit of work, not a concept.

## Choose this when / avoid when

- ✅ Project planning, PMO deliverables
- ✅ Estimation scaffolding (pairs with `pmo-pert-estimate` skill)
- ❌ Concept maps → use `mindmap`
- ❌ Process flow → use `activity`

## Detail-level presets

- `minimal`: 2 levels, deliverables only.
- `standard`: 3 levels, work packages with owner tag.
- `detailed`: 4 levels, estimate in the node label (e.g., `[5d]`).

## Layout tips

- `@startwbs`/`@endwbs`.
- Use WBS codes (1, 1.1, 1.1.1) as a prefix for traceability.
- Keep the tree balanced; a lopsided WBS is a sign of missing work.

## Snippet

```plantuml
@startwbs WBS_NewFeature
!$target = %getenv("PLANTUML_TARGET")
!include .plantuml/_base.puml
!include .plantuml/_targets/$target.puml

* 1. New Feature
** 1.1 Discovery
*** 1.1.1 Stakeholder interviews
*** 1.1.2 Competitive analysis
** 1.2 Design
*** 1.2.1 UX wireframes
*** 1.2.2 Technical design
** 1.3 Build
*** 1.3.1 Backend
*** 1.3.2 Frontend
*** 1.3.3 Integration
** 1.4 Release
*** 1.4.1 QA
*** 1.4.2 Rollout
@endwbs
```

## Common pitfalls

- WBS with non-deliverable nodes ("meetings", "reviews"). Fix: those
  are activities, not work packages. Put them in a plan, not a WBS.
- No WBS codes. Fix: codes are what make the WBS referenceable
  elsewhere (budget lines, Gantt tasks).
