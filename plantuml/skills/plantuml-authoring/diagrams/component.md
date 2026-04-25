# Component Diagrams

## Purpose

Show the software components of a system, their provided and required
interfaces, and the connectors between them. Answers "what modules
exist and how are they wired?".

## Choose this when / avoid when

- ✅ Designing module boundaries in a service or application
- ✅ Showing dependencies between libraries, services, or plugins
- ✅ Contract-first design: making interfaces explicit
- ❌ Showing physical deployment → use `deployment`
- ❌ Showing runtime message exchange → use `sequence`
- ❌ Code-level class structure → use `class`

## Detail-level presets

- `minimal`: components only, direction of dependency, no interfaces.
- `standard`: components + provided/required interfaces (ball-and-socket
  or lollipop), dependency arrows labelled with "uses".
- `detailed`: ports, grouped into `package`s by subsystem, notes on
  protocol (HTTP/gRPC/AMQP) and non-functional constraints.

## Layout tips

- Direction: dependency direction. If A uses B, A is above (TB) or
  left (LR) of B.
- Prefer LR for pipeline architectures; TB for layered.
- Use `()` interface shorthand for brevity; explicit `interface` for
  clarity.

## Snippet

```plantuml
@startuml Component_Checkout
!$target = %getenv("PLANTUML_TARGET")
!include .plantuml/_base.puml
!include .plantuml/_targets/$target.puml

package "Checkout" {
  [Cart]     as Cart
  [Pricing]  as Pricing
  [Orders]   as Orders
  () "Catalog API"  as CatalogAPI
  () "Payments API" as PayAPI
}

Cart -down-> Pricing      : queries
Pricing -right-> CatalogAPI : reads
Cart -down-> Orders       : submits
Orders -right-> PayAPI    : authorizes
@enduml
```

## Common pitfalls

- Confusing components with classes. Fix: components are deployable
  units with interfaces; classes are code-level types.
- Drawing bidirectional arrows to mean "communicates with". Fix:
  one direction per arrow; if both directions matter, draw two.
- Skipping interfaces. Fix: at `standard`+, always show the interface
  at the boundary — that's the whole point of the diagram.
