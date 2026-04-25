# Communication Diagrams

## Purpose

An alternative view of a sequence: show participants as nodes in a
graph and messages as numbered labels on the edges. Emphasizes
structure over time.

> **PlantUML limitation.** PlantUML has no first-class
> communication-diagram syntax. The rendered SVG metadata reports
> `data-diagram-type="CLASS"` because the engine treats this as an
> object diagram with labelled links. This skill **emulates** UML
> communication notation by combining `object` participants,
> `hide empty members`, explicit numeric prefixes on labels, and
> reply-arrow conventions. Read every snippet here as "object diagram
> styled to read as a communication diagram", not as native support.

## Choose this when / avoid when

- ✅ When the structural relationship between participants matters
  more than the exact ordering
- ✅ When the same participants exchange messages in multiple
  scenarios and you want to show the graph once
- ✅ When stakeholders specifically ask for the
  numbered-graph-with-arrows idiom
- ❌ When ordering dominates → use `sequence` (PlantUML's first-class
  support there is far stronger)
- ❌ When there are branches/alts → `sequence` handles them; this
  emulation does not
- ❌ When you need lifelines, activations, or async distinctions →
  `sequence`

## Detail-level presets

- `minimal`: participants + numbered messages, no attributes.
- `standard`: add argument summaries to message labels and an
  explicit numbering tree (e.g. `1`, `1.1`, `1.2`, `2`).
- `detailed`: nested numbering with replies shown as dashed arrows
  (`..>`) carrying return values.

## Layout tips

- Always include `hide empty members` — without it, every `object`
  renders an empty attribute compartment and the graph becomes
  visually noisy.
- Use `-->` (solid) for synchronous calls, `..>` (dashed) for
  replies/return values. PlantUML accepts both on object diagrams and
  the convention reads as UML communication notation.
- Encode call order in the **label**, not in the file order. Use
  dotted decimals to express nesting: `1`, `1.1`, `1.2`, `2`.
- Keep message count ≤ 10; beyond that the numbers become confusing.
  If you have more, you almost certainly want `sequence`.
- Quote labels that contain spaces or colons (`: "1: quote(items)"`).

## Snippet

```plantuml
@startuml Communication_Checkout_Standard
!$target = %getenv("PLANTUML_TARGET")
!include .plantuml/_base.puml
!include .plantuml/_targets/$target.puml

title "Communication — Checkout (standard preset)"

' Emulated communication diagram: object nodes + numbered labels.
' `hide empty members` strips the empty attribute compartments so
' the result reads as a graph of participants, not as data objects.
hide empty members

object ":Cart"     as cart
object ":Pricing"  as pricing
object ":Orders"   as orders
object ":Payments" as pay

cart    --> pricing : "1: quote(items)"
pricing ..> cart    : "1.1: total"
cart    --> orders  : "2: submit(cart)"
orders  --> pay     : "2.1: authorize(total)"
pay     ..> orders  : "2.2: authCode"
orders  ..> cart    : "3: confirmation"
@enduml
```

## Common pitfalls

- Treating PlantUML output as a true UML communication diagram. Fix:
  remember the SVG metadata says `CLASS`/object — the notation is
  emulated. If a tool downstream parses diagram type from metadata,
  this will not be detected as `COMMUNICATION`.
- Confusing with sequence diagrams. Fix: if you need timing arrows,
  activations, or alt/else, switch to `sequence`.
- Inconsistent numbering. Fix: use dotted decimals (`1`, `1.1`,
  `1.2`, `2`) to nest sub-calls; never repeat a number.
- Forgetting `hide empty members`. Fix: without it, every object
  renders an empty `{}` compartment and the diagram looks like a data
  model rather than a message graph.
- Mixing solid and dashed arrows arbitrarily. Fix: solid `-->` for
  calls, dashed `..>` for replies — pick the convention and apply it
  uniformly.
