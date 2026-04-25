# Package Diagrams

## Purpose

Show the package/namespace structure of a codebase and dependencies
between packages. Answers "how is this codebase organized and what
depends on what?".

## Choose this when / avoid when

- ✅ Explaining directory/module organization
- ✅ Identifying dependency cycles
- ✅ Architectural review ("is this layered correctly?")
- ❌ Showing class-level detail → use `class`
- ❌ Showing deployment units → use `component` or `deployment`

## Detail-level presets

- `minimal`: packages as boxes, high-level dependency arrows.
- `standard`: nested packages, dependency arrows labelled with the
  reason (`uses`, `imports`, `extends`).
- `detailed`: each package annotated with a short description; cyclic
  dependencies called out with notes and red color.

## Layout tips

- Direction: TB — layers flow top to bottom (presentation → app →
  domain → infra).
- Use `<<layer>>` stereotypes to make the layering explicit.
- Color-code by layer (semantic color, per principle #6).

## Snippet

```plantuml
@startuml Package_Layers
!$target = %getenv("PLANTUML_TARGET")
!include .plantuml/_base.puml
!include .plantuml/_targets/$target.puml

package "presentation" <<layer>> {
  package "web"  as web
  package "api"  as api
}
package "application" <<layer>> {
  package "commands" as cmd
  package "queries"  as qry
}
package "domain" <<layer>> {
  package "order" as ord
  package "pricing" as prc
}
package "infrastructure" <<layer>>

web --> api
api --> cmd
api --> qry
cmd --> ord
qry --> ord
ord --> prc
cmd --> "infrastructure"
qry --> "infrastructure"
@enduml
```

## Common pitfalls

- Drawing a package diagram that is actually a component diagram. Fix:
  packages are namespaces; components are deployable units.
- Arrow direction reversed. Fix: arrow points *from* the package that
  imports *to* the package that defines.
- Undocumented cycles. Fix: if there's a cycle, highlight it and add a
  note — never pretend it doesn't exist.
