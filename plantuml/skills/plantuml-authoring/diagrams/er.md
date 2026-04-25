# Entity-Relationship Diagrams

## Purpose

Show a data model: entities, their attributes, and the relationships
(cardinalities) between them.

## Choose this when / avoid when

- ✅ Database schema design
- ✅ Domain model focused on data rather than behavior
- ✅ Explaining a normalized model to an audience familiar with ERDs
- ❌ When behavior matters → use `class`
- ❌ Physical DB (indexes, partitions) → use `deployment` or custom
  docs

## Detail-level presets

- `minimal`: entities as boxes with name + primary key, crow's-foot
  relationships, no attributes.
- `standard`: primary + foreign keys, a handful of business-key
  attributes, cardinalities on both ends.
- `detailed`: all attributes with types and nullability, junction
  entities for many-to-many.

## Layout tips

- PlantUML's `entity` keyword or Chen ER notation; prefer `entity` +
  standard crow's-foot unless stakeholders expect Chen.
- Direction: LR for wide schemas; TB for hierarchical.
- Keep to ≤ 15 entities per diagram.

## Snippet

```plantuml
@startuml ER_OrderModel
!$target = %getenv("PLANTUML_TARGET")
!include .plantuml/_base.puml
!include .plantuml/_targets/$target.puml

entity "Customer" as c {
  *id : uuid <<PK>>
  --
  name : text
  email : text
}
entity "Order" as o {
  *id : uuid <<PK>>
  --
  *customer_id : uuid <<FK>>
  status : text
  total : numeric
}
entity "OrderLine" as ol {
  *id : uuid <<PK>>
  --
  *order_id : uuid <<FK>>
  *sku : text
  qty : int
}

c ||--o{ o
o ||--o{ ol
@enduml
```

## Common pitfalls

- Modeling behavior (methods) on entities. Fix: this is an ER
  diagram, not a class diagram.
- Missing cardinalities. Fix: always show both ends.
- Skipping junction entities for many-to-many. Fix: explicit junction
  entity is the canonical form.
