# ArchiMate Diagrams

## Purpose

Model enterprise architecture across Business, Application, and
Technology layers per the ArchiMate 3 specification. PlantUML
provides `<archimate/Archimate>` stdlib macros.

## Choose this when / avoid when

- ✅ Enterprise architecture docs
- ✅ Capability-to-technology mappings
- ❌ Software architecture of a single system → use `c4`
- ❌ If the audience is dev-focused: ArchiMate notation is heavy

## Detail-level presets

- `minimal`: one layer, 5–7 elements.
- `standard`: two layers (Business + Application) with realizations
  and serves relationships.
- `detailed`: all three layers, with motivation elements (goals,
  drivers, stakeholders).

## Layout tips

- Use the stdlib element macros: `Business_Actor`, `Business_Process`,
  `Application_Component`, `Technology_Node`, etc.
- Layer elements vertically (Business top, Technology bottom) — this
  is the ArchiMate convention.
- Color-coding is built in; don't override.

## Snippet

```plantuml
@startuml Archimate_OrderManagement
!$target = %getenv("PLANTUML_TARGET")
!include .plantuml/_base.puml
!include .plantuml/_targets/$target.puml
!include <archimate/Archimate>

Business_Actor(customer, "Customer")
Business_Process(place_order, "Place Order")
Application_Service(order_svc, "Order Service")
Application_Component(order_app, "Order App")
Technology_Node(k8s, "Kubernetes Cluster")

Rel_Triggering(customer, place_order)
Rel_Serving(order_svc, place_order)
Rel_Realization(order_app, order_svc)
Rel_Assignment(k8s, order_app)
@enduml
```

## Common pitfalls

- Using ArchiMate where a simpler diagram works. Fix: only use if
  enterprise stakeholders specifically expect ArchiMate.
- Mixing layer conventions. Fix: stick to Business above, Technology
  below.
