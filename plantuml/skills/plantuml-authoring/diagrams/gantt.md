# Gantt Charts

## Purpose

Visualize a project timeline: tasks, durations, dependencies, and
milestones.

## Choose this when / avoid when

- ✅ Inline Gantt in a doc (for quick timeline communication); PPTX
  slide with phasing
- ✅ Shareable with non-PMO audiences
- ❌ Detailed PM needs → use your actual PM tool (JIRA, MS Project);
  PlantUML Gantt is illustrative only
- ❌ Resource levelling, earned value → out of scope

## Detail-level presets

- `minimal`: 3–5 top-level phases on a bar, no dependencies.
- `standard`: tasks grouped by phase, dependencies (`-> then`,
  `starts at`), milestones (`* …`).
- `detailed`: resources, percentage complete, today line, color
  coding per stream.

## Layout tips

- `@startgantt` / `@endgantt`.
- Use `Project starts YYYY-MM-DD`.
- `-- Phase --` separators structure the chart.
- Keep to ≤ 20 tasks; beyond that, use a real PM tool.

## Snippet

```plantuml
@startgantt Gantt_Release_Q3
!$target = %getenv("PLANTUML_TARGET")
!include .plantuml/_base.puml
!include .plantuml/_targets/$target.puml

Project starts 2026-07-01

-- Discovery --
[Stakeholders]    lasts 10 days
[Research]        lasts 10 days and starts at [Stakeholders]'s end

-- Build --
[Backend]         lasts 20 days and starts at [Research]'s end
[Frontend]        lasts 15 days and starts 5 days after [Backend]'s start
[Integration]     lasts 10 days and starts at [Frontend]'s end

-- Release --
[QA]              lasts 7 days and starts at [Integration]'s end
[Rollout]         lasts 3 days and starts at [QA]'s end

[Launch] happens at [Rollout]'s end
@endgantt
```

## Common pitfalls

- Using PlantUML Gantt for actual PM. Fix: it's illustrative; for
  critical-path analysis use `pmo-pert-estimate` (Excel) or a PM
  tool.
- Forgetting `Project starts`. Fix: always set a start date.
- Dependencies via comment instead of syntax. Fix: use `starts at
  [X]'s end`.
