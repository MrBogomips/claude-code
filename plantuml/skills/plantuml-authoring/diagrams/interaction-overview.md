# Interaction Overview Diagrams

## Purpose

An overview where each major interaction is a `ref over` block in a
top-level sequence, allowing branching via `alt/else` at sequence
level. The result reads as a "map" of sub-interactions: each `ref`
points to a separate, fully-detailed sequence diagram, and the
top-level control flow shows how those sub-interactions chain
together.

## Note on PlantUML limitations

Interaction overview is **not** a first-class diagram type in
PlantUML. There is no `ref(...)` activity-node function — writing
`:ref(Sequence_X);` in an activity diagram renders the parenthesised
text literally, it does not create a UML interaction-reference node.

Two workarounds exist:

- **Sequence + `ref over` (recommended, used here):** model the
  overview as a sequence diagram in which every "step" is a
  `ref over A, B : SubInteraction` block. Branching uses `alt/else`
  between refs. This is valid PlantUML, renders cleanly, and is what
  reviewers expect.
- **Activity with stereotyped nodes:** keep activity syntax but use
  `:Sub-interaction A<<ref>>;` or `:[ref] Sub-interaction A;` to
  signal "this node is a reference". Closer to UML 2.x interaction
  overview spec, but still a labelling convention rather than a
  first-class construct.

If you need a true UML 2.x interaction overview diagram, render it
outside PlantUML.

## Choose this when / avoid when

- ✅ A top-level "map" of several sequence diagrams, with branching
  between them
- ✅ Orchestrating choreographies where the control flow between
  sub-interactions is the story
- ✅ Onboarding readers who need the big picture before drilling into
  individual sequences
- ❌ A single interaction — use `sequence`
- ❌ A business process with swimlanes / parallel paths — use
  `activity`
- ❌ A static call graph between components — use `component`

## Detail-level presets

- `minimal`: only `ref over` blocks, linear order, no branching.
- `standard`: `ref over` blocks plus one or two `alt/else` branches
  for the main decision points.
- `detailed`: multiple branches, `par` for concurrent
  sub-interactions, and short inline messages between refs to clarify
  hand-offs.

## Layout tips

- Direction: TB (sequence default). The overview reads top-to-bottom
  like any sequence.
- Keep the participant list short — typically the actors and the one
  or two systems that span every sub-interaction. Per-sub-interaction
  participants live inside the referenced sequences, not here.
- Name each `ref` identically to the target `.puml` file (e.g.
  `Sequence_SignUp`) for greppable traceability.
- Use `== Phase ==` separators if the chain has clear lifecycle
  phases (e.g. Acquisition / Activation / Retention).

## Snippet

```plantuml
@startuml InteractionOverview_Onboarding_Standard
!$target = %getenv("PLANTUML_TARGET")
!include .plantuml/_base.puml
!include .plantuml/_targets/$target.puml

title "Onboarding — Interaction Overview (standard)"

actor       Customer
participant "Web App"      as Web
participant "Identity API" as Identity

== Sign-up ==
ref over Customer, Web, Identity : Sequence_SignUp

alt email verified
  == Activation ==
  ref over Customer, Web, Identity : Sequence_ProfileSetup
  ref over Customer, Web           : Sequence_FirstPurchase
else email not verified
  ref over Customer, Identity      : Sequence_ResendVerification
end
@enduml
```

## Common pitfalls

- Using `:ref(Sequence_X);` inside an activity diagram. Fix: PlantUML
  has no such function; the parentheses render literally. Use
  `ref over <participants> : Sequence_X` in a sequence diagram
  instead (see snippet).
- Re-drawing the referenced sequences inline. Fix: that defeats the
  purpose; keep refs opaque and link out to the dedicated sequence
  diagram.
- Missing link from ref label to the actual diagram. Fix: name the
  ref identically to the target `.puml` file for greppable
  traceability.
- Listing every participant of every sub-interaction at the top.
  Fix: keep the overview's participant list to the spanning
  actors/systems; sub-interaction-specific participants belong inside
  the referenced sequences.
