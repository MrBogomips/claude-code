# Class Diagrams

## Purpose

Show the static structure of a software system: classes, interfaces,
their attributes and operations, and how they relate through
inheritance, association, aggregation, and composition.

## Choose this when / avoid when

- ✅ Explaining a domain model or an object-oriented design
- ✅ Documenting inheritance hierarchies
- ✅ Showing interface contracts between modules
- ❌ Showing runtime behavior → use `sequence` or `activity`
- ❌ Showing persistence (DB tables) → use `er`
- ❌ Documenting more than ~15 classes in one diagram → split

## Detail-level presets

- `minimal`: class names only, key relationships, no attributes or
  operations. Audience: architect overview, exec briefing.
- `standard`: class names + public operations (no parameters if they
  add noise), attributes only when they drive the design. Audience:
  design review, onboarding.
- `detailed`: full signatures (name + parameters + return type),
  visibility markers (`+`, `-`, `#`), stereotypes, cardinalities on
  associations. Audience: implementation reference.

## Layout tips

- Direction: `top-to-bottom` for inheritance-dominant stories;
  `left-to-right` for association-dominant.
- Group related classes with `package` blocks; collapse external
  dependencies into a single `<<external>>` class.
- Use `--|>` for inheritance, `-->` for association, `*--` for
  composition, `o--` for aggregation. Consistency matters more than
  preference.

## Snippet

```plantuml
@startuml Class_Order_Domain
!$target = %getenv("PLANTUML_TARGET")
!include .plantuml/_base.puml
!include .plantuml/_targets/$target.puml

package "Order Domain" {
  class Order {
    +id: OrderId
    +status: OrderStatus
    +total: Money
    +submit(): void
  }
  class OrderLine {
    +sku: SKU
    +quantity: int
    +subtotal(): Money
  }
  class Customer {
    +id: CustomerId
    +name: string
  }
}

Customer "1" --> "*" Order : places
Order "1" *-- "*" OrderLine : contains
@enduml
```

## Common pitfalls

- Using `<|--` and `<|..` interchangeably (extends vs implements).
  Fix: `<|--` is extends (solid), `<|..` is implements (dashed).
- Cluttering the diagram with getters/setters. Fix: omit them at
  `standard`; they add no information.
- Mixing domain classes with persistence DTOs in one diagram.
  Fix: split into `domain-model.puml` and `persistence-mapping.puml`.
- Associations without roles and cardinalities at `detailed` level.
  Fix: `ClassA "1" --> "*" ClassB : owns`.
