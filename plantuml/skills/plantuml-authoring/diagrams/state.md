# State Diagrams

## Purpose

Show the lifecycle of a single entity: its possible states,
transitions between them, and the events that trigger those
transitions.

## Choose this when / avoid when

- ✅ Order lifecycle, account lifecycle, document workflow
- ✅ Any finite-state machine
- ❌ Cross-object processes → use `activity`
- ❌ Message exchange → use `sequence`

## Detail-level presets

- `minimal`: states + transitions labeled with the event.
- `standard`: states with entry/exit actions, guards on transitions,
  composite states for groupings.
- `detailed`: internal transitions, history pseudostates, concurrent
  regions.

## Layout tips

- Direction: LR when the flow is mostly linear; TB for branching.
- Use `[*]` for initial and final pseudostates.
- Compose related states with nested `state "…" { … }`.
- Keep to ≤ 8 states at the top level.

## Render-engine note (PlantUML 1.2026.x)

The default `smetana` layout engine (set in `_layout.puml`) **cannot render
state diagrams that use composite states with concurrent regions** (`||`
parallel composition). It emits `CucaDiagramFileMakerSmetana::exportGroup
issue` and silently drops entire regions from the PNG, while keeping the
syntax in the source — so the diagram looks complete but isn't.

For state diagrams with concurrent regions, override the layout engine
right after the include chain:

```plantuml
@startuml State_Order_Lifecycle
!$target = %getenv("PLANTUML_TARGET")
!include .plantuml/_base.puml
!include .plantuml/_targets/$target.puml
!pragma layout dot   ' override smetana for concurrent regions
…
@enduml
```

The `dot` engine (Graphviz) handles parallel regions correctly; it is
slower but reliable. Apply this override per file, not at the template
level — non-concurrent state diagrams render fine on smetana.

## Snippet

```plantuml
@startuml State_Order_Lifecycle
!$target = %getenv("PLANTUML_TARGET")
!include .plantuml/_base.puml
!include .plantuml/_targets/$target.puml

[*] --> Draft
Draft   --> Submitted : submit()
Submitted --> Paid    : paymentOk
Submitted --> Cancelled : paymentKo
Paid    --> Shipped   : ship()
Shipped --> Delivered : carrierEvent
Delivered --> [*]
Cancelled --> [*]
@enduml
```

## Common pitfalls

- States that are actually activities ("Processing…" with multiple
  internal steps). Fix: a state is a *situation*, not a task.
- Unlabeled transitions. Fix: every transition needs an event name
  (what triggers it).
- Unreachable or orphan states. Fix: every state must be reachable
  from `[*]` and have a path to `[*]` (or be explicitly terminal).
- **Concurrent regions silently disappear with smetana.** Fix: add
  `!pragma layout dot` after the include chain (see Render-engine
  note above). Verify by checking that `*.png.stderr` contains no
  `UNKNOWN ENTITY` lines after rendering.
