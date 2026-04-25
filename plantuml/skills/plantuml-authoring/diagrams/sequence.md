# Sequence Diagrams

## Purpose

Show the ordered exchange of messages between participants
(actors/systems/components) over time.

## Choose this when / avoid when

- ✅ Explaining request/response flows, async interactions, timing
- ✅ Documenting a protocol or a use case scenario end-to-end
- ✅ Onboarding developers to an unfamiliar flow
- ❌ Static structure → use `class` or `component`
- ❌ State changes inside a single object → use `state`
- ❌ Business process with branches and parallel paths dominant →
  consider `activity`

## Detail-level presets

- `happy-path` (minimal equivalent): 2–5 participants, main flow only,
  no errors, ≤ 12 messages.
- `with-alternatives` (standard): add `alt/else/opt` for key
  branches; ≤ 20 messages.
- `exhaustive` (detailed): all return arrows, timeouts, errors,
  sub-sequences via `ref`. Usually a red flag — reconsider splitting.

## Layout tips

- Always TB (the default). Participants left-to-right in call-order.
- Group related exchanges with `== Phase ==` separators.
- `activate`/`deactivate` explicitly for overlapping calls to avoid
  ambiguous lifelines.
- Distinguish sync (`->`) from async (`->>`) consistently.

## Snippet

```plantuml
@startuml Sequence_Checkout
!$target = %getenv("PLANTUML_TARGET")
!include .plantuml/_base.puml
!include .plantuml/_targets/$target.puml

actor Customer
participant "Web App"    as Web
participant "Orders API" as API
database   "Orders DB"   as DB
queue      "Events"      as MQ

Customer -> Web : Place order
activate Web
Web -> API : POST /orders
activate API
API -> DB : INSERT order (PENDING)
API -> MQ : order.created
API --> Web : 201 Created
deactivate API

alt payment authorised
  MQ -> API : payment.ok
  API -> DB : UPDATE status=PAID
else payment failed
  MQ -> API : payment.ko
  API -> DB : UPDATE status=CANCELLED
end
Web --> Customer : Confirmation page
deactivate Web
@enduml
```

## Common pitfalls

- Participants named after HTTP verbs. Fix: use domain names
  (actors/systems); HTTP bindings go in message labels only if
  relevant.
- Mixing sync/async without visual distinction. Fix: `->` for sync,
  `->>` for async.
- More than ~25 messages in one diagram. Fix: split by phase into
  multiple diagrams, or use `ref over A, B : <subflow>`.
- No `activate/deactivate` when lifelines overlap. Fix: explicit
  activations disambiguate.
