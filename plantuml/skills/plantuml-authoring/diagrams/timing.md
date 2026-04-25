# Timing Diagrams

## Purpose

Show how the state of one or more participants changes over a time
axis, including absolute/relative time constraints.

## Choose this when / avoid when

- ✅ Hardware signals, protocol timing, real-time systems
- ✅ Explaining lifecycle overlaps across processes
- ❌ Logical ordering without time scale → use `sequence`
- ❌ State transitions of a single entity without time → use `state`

## Detail-level presets

- `minimal`: single participant, state changes only.
- `standard`: multiple participants, time constraints labelled
  (`@0`, `@+5`).
- `detailed`: numeric time axis, overlapping states, messages
  between participants aligned on the axis.

## Layout tips

- Timing notation is niche; always add a short legend note.
- Use `concise` for quick overviews, `robust` for full state detail.
- Keep the time axis short and scaled to the story.

## Snippet

```plantuml
@startuml Timing_BatteryCharging
!$target = %getenv("PLANTUML_TARGET")
!include .plantuml/_base.puml
!include .plantuml/_targets/$target.puml

robust "Battery" as B
concise "Charger" as C

@0
B is Empty
C is Idle

@+1
C is Detected
B is Charging

@+10
B is Full
C is Trickle

@+11
C is Idle
@enduml
```

## Common pitfalls

- Using timing where a sequence would do. Fix: prefer `sequence`
  unless the time axis is genuinely meaningful.
- Missing legend. Fix: add a note explaining the `robust`/`concise`
  distinction if the reader isn't familiar.
