# Object Diagrams

## Purpose

Show a snapshot of runtime objects and their links at a particular
moment. A class diagram describes the rule; an object diagram
illustrates one instance of that rule.

## Choose this when / avoid when

- ✅ Concretising a complex class diagram with an example
- ✅ Explaining a corner case ("what the state looks like after X")
- ✅ Test case documentation
- ❌ Showing general structure → use `class`
- ❌ Temporal flow → use `sequence`

## Detail-level presets

- `minimal`: objects with names and types; no attributes.
- `standard`: objects with key attribute values.
- `detailed`: all attribute values, link labels, snapshot timestamp
  in a note.

## Layout tips

- Use the same orientation as the related class diagram so the reader
  sees the mapping.
- Mark object names in lowercase to distinguish from class types
  (UML convention: `anOrder:Order`).

## Snippet

```plantuml
@startuml Object_Checkout_State
!$target = %getenv("PLANTUML_TARGET")
!include .plantuml/_base.puml
!include .plantuml/_targets/$target.puml

object "anne:Customer" as anne {
  id = 42
  tier = GOLD
}
object "o_771:Order" as o771 {
  id = 771
  status = SUBMITTED
  total = 128.90
}
object "ol_1:OrderLine" as ol1 {
  sku = "SKU-A"
  qty = 2
}
object "ol_2:OrderLine" as ol2 {
  sku = "SKU-B"
  qty = 1
}

anne --> o771
o771 --> ol1
o771 --> ol2
@enduml
```

## Common pitfalls

- Using object diagrams where a class diagram would do. Fix: prefer
  class unless the point is genuinely a snapshot.
- Omitting the class type after the colon. Fix: `name:ClassName` is
  the standard form.
- Showing too many objects. Fix: ≤ 8 objects per diagram; more than
  that defeats the purpose of illustration.
