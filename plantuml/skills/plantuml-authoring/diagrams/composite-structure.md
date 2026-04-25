# Composite Structure Diagrams

## Purpose

Show the internal structure of a complex component: its parts, ports,
and connectors, contained within the component's boundary. The defining
notation is **ports on the boundary** — small squares straddling the
outer rectangle that expose the component's interaction points.

## Choose this when / avoid when

- ✅ Decomposing a component into collaborating parts that only make
  sense inside it
- ✅ Documenting an ACL, adapter, or façade pattern at high level
- ✅ Showing how a component's interaction points (ports) wire to
  internal parts
- ❌ Showing the component's place in a system → use `component`
- ❌ Showing classes that happen to collaborate → use `class`
- ❌ Pure dependency arrows between independent components → use
  `component` (composite structure is for *internal* decomposition)

## Detail-level presets

- `minimal`: outer component boundary + 2–3 named parts, no ports.
  Communicates the decomposition itself.
- `standard`: parts + ports on the boundary + connectors between ports
  and parts. Adds the defining-notation signal of the type.
- `detailed`: protocol stereotypes on connectors, multiplicities on
  ports, internal sub-parts where useful. Add 1–2 `note` directives
  if intent isn't obvious from structure.

## Layout tips

- The enclosing component is one big `component "..." { ... }` block.
- **Ports** sit on the outer boundary. PlantUML's port keyword is the
  canonical syntax: `port "name" as id` declared *inside* the
  enclosing component renders as a small square on the boundary.
- Inner **parts** are `[Part]` rectangles inside the component block
  (no need for a `<<part>>` stereotype unless you want it explicit).
- Connectors use plain arrows or undirected lines `--`. Reserve `-->`
  for delegation/dependency direction within the boundary.
- Keep internal parts to ≤ 7 — beyond that, extract a sub-component
  with its own composite-structure diagram.

## Snippet

```plantuml
@startuml CompositeStructure_PaymentGateway_Standard
!$target = %getenv("PLANTUML_TARGET")
!include .plantuml/_base.puml
!include .plantuml/_targets/$target.puml

title "Payment Gateway — internal composition (standard)"

component "Payment Gateway" {
  port "pay-in"  as PI
  port "pay-out" as PO

  [Router]      as R
  [Authorizer]  as A
  [Anti-Fraud]  as F
  [Settlement]  as S

  PI --> R
  R  --> A
  A  --> F : checks
  A  --> S : on success
  S  --> PO
}
@enduml
```

## Common pitfalls

- **Using lollipops `() "name"` as if they were ports.** Fix: lollipops
  denote *provided/required interfaces* in component diagrams, not
  ports in composite-structure. Use `port "name" as id` inside the
  component block — it renders as a small square on the boundary,
  which is the defining UML composite-structure notation.
- Indistinguishable from a component diagram. Fix: emphasize the
  boundary (one outer component) and keep all parts *inside*. If
  parts also live independently outside the boundary, you want
  `component`, not composite-structure.
- Ports drifting *inside* the container instead of on the boundary.
  Fix: declare ports immediately at the start of the component block
  (before parts) and connect them to parts with arrows; the layout
  engine then anchors them on the boundary.
- Missing decline/error path. Fix: at `standard`+, show alternatives
  explicitly (e.g., `A --> S : on success` paired with `A --> PO :
  denied` or a separate `denied-out` port).
