# Use Case Diagrams

## Purpose

Show user goals that a system fulfills, the actors involved, and
relationships between use cases (`include`, `extend`).

## Choose this when / avoid when

- ✅ Requirements discovery with stakeholders
- ✅ Scoping a release ("which goals are in, which out")
- ❌ Implementation design — use cases give *what*, not *how*
- ❌ Workflow detail → use `activity`

## Detail-level presets

- `minimal`: actors + use cases as ovals, simple arrows.
- `standard`: grouping with system boundary rectangle,
  `<<include>>`/`<<extend>>` relationships.
- `detailed`: generalization between actors or use cases, notes
  describing the preconditions/postconditions per use case.

## Layout tips

- Actors on the left and right; use cases in the middle.
- System boundary rectangle encloses the use cases.
- Primary actor(s) on the left, secondary/support on the right.

## Snippet

```plantuml
@startuml UseCase_Shop
!$target = %getenv("PLANTUML_TARGET")
!include .plantuml/_base.puml
!include .plantuml/_targets/$target.puml

left to right direction
actor Customer
actor "Customer Support" as CS

rectangle "Online Shop" {
  (Browse catalog)    as UC1
  (Place order)       as UC2
  (Track shipment)    as UC3
  (Return item)       as UC4
  (Process refund)    as UC5
}

Customer --> UC1
Customer --> UC2
Customer --> UC3
Customer --> UC4
CS       --> UC5
UC4 ..> UC5 : <<include>>
@enduml
```

## Common pitfalls

- Mixing use cases with system functions ("login", "retrieve data").
  Fix: a use case delivers value *to an actor*; "login" is a means,
  not a goal.
- Over-decomposition with `<<include>>`. Fix: use sparingly; a use
  case diagram is a map, not a call graph.
- Too many actors. Fix: collapse secondary actors into a category
  ("External Systems"), or split the diagram by business area.
