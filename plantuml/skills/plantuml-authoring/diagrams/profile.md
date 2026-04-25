# Profile Diagrams

## Purpose

Show UML extensions: custom stereotypes, tagged values, and
constraints that adapt UML to a specific domain or tool. Rare in
application development; common in modeling frameworks.

## Choose this when / avoid when

- ✅ Documenting a DSL or modeling convention your team invented
- ✅ Extending UML for a specific industry (telecom, automotive, …)
- ❌ Any ordinary design communication — prefer a plain class or
  component diagram with `<<stereotype>>` labels inline
- ❌ If the audience doesn't already know what a UML profile is

## Detail-level presets

- `minimal`: the profile box + one or two stereotypes.
- `standard`: all stereotypes, base UML metaclasses they extend,
  tagged values.
- `detailed`: OCL constraints, iconography references.

## Layout tips

- Two-column layout: profile on the left, base UML elements on the
  right, extension arrows crossing between.
- Explicit `<<profile>>`, `<<metaclass>>`, `<<stereotype>>`
  stereotypes on every element — the notation is too niche to rely
  on visual conventions.

## Snippet

```plantuml
@startuml Profile_BankingExtensions_Standard
!$target = %getenv("PLANTUML_TARGET")
!include .plantuml/_base.puml
!include .plantuml/_targets/$target.puml

title "Banking Profile — UML 2 Profile Extensions (standard)"

package "Banking Profile" <<profile>> {
  class Account     <<stereotype>>
  class LedgerEntry <<stereotype>>
}
package "UML" {
  class Class       <<metaclass>>
  class Association <<metaclass>>
}

Account     --|> Class       : <<extend>>
LedgerEntry --|> Class       : <<extend>>
LedgerEntry --|> Association : <<extend>>
@enduml
```

## Common pitfalls

- Using profile diagrams to document domain models (which is what
  `<<stereotype>>` *tagging* in class diagrams is for). Fix: only use
  profile diagrams to document the profile itself, not uses of it.
- Omitting the base UML elements the stereotypes extend. Fix: always
  show the extension arrow to the metaclass.
- Drawing the stereotype-to-metaclass relation as `..|>` (interface
  realization: dashed line + hollow triangle). That notation means
  "implements an interface" and is wrong for profiles. UML 2 mandates
  the **Extension** arrow — solid line, filled triangle — pointing
  from the stereotype to the metaclass, conventionally labeled
  `<<extend>>`. In PlantUML, use `Stereotype --|> Metaclass : <<extend>>`
  (solid generalization arrow with the extend keyword as the label).
- Encoding the stereotype keyword inside the class label, e.g.
  `class "<<stereotype>>\nAccount" as StAccount`. PlantUML supports
  stereotypes natively: `class Account <<stereotype>>`. The native
  form renders the guillemets in the canonical position above the
  name and avoids the alias indirection.
