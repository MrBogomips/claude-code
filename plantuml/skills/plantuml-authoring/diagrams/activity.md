# Activity Diagrams

## Purpose

Model a process as a sequence of activities with decisions, parallel
paths, and swimlanes. Think flowchart with UML semantics.

## Choose this when / avoid when

- ✅ Business processes or workflows
- ✅ Decision-heavy flows (many `if/else`)
- ✅ Cross-role processes (swimlanes show ownership)
- ❌ Temporal message exchange between systems → use `sequence`
- ❌ Single-object lifecycle → use `state`
- ❌ Class structure → use `class`

## Detail-level presets

- `minimal`: linear flow, no swimlanes, ≤ 10 steps.
- `standard`: swimlanes for each role/system, decisions, merge nodes.
- `detailed`: parallel fork/join, exceptions, notes on SLAs or
  business rules.

## Layout tips

- PlantUML's `beta` activity syntax (`:Step;`) is current practice;
  avoid the legacy `(*)` syntax.
- Direction: TB by default; LR for long horizontal processes.
- Use `partition` for swimlanes.
- Keep decision branches to 2–3; more than that becomes a table.

## Snippet

```plantuml
@startuml Activity_Return_Process
!$target = %getenv("PLANTUML_TARGET")
!include .plantuml/_base.puml
!include .plantuml/_targets/$target.puml

start
:Receive return request;
partition "Warehouse" {
  :Inspect item;
  if (Item sellable?) then (yes)
    :Restock;
  else (no)
    :Scrap;
  endif
}
partition "Finance" {
  :Issue refund;
}
:Notify customer;
stop
@enduml
```

## Common pitfalls

- Mixing beta and legacy syntax. Fix: use beta (`:…;`, `start/stop`,
  `if/then/else/endif`, `fork/end fork`).
- Missing `stop` or `end`. Fix: every path must terminate.
- Too many swimlanes (≥ 5). Fix: collapse or split.
