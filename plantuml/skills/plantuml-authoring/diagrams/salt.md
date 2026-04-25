# Salt (UI Wireframes)

## Purpose

Low-fidelity UI mockups: forms, windows, dialogs rendered as ASCII-
art-like grids inside PlantUML.

## Choose this when / avoid when

- ✅ Quick wireframes embedded in a design doc
- ✅ Specifying field layouts without a design tool
- ❌ High-fidelity UI: use Figma/Sketch
- ❌ Interaction design: Salt is static

## Detail-level presets

- `minimal`: one screen with labels only.
- `standard`: one screen with fields, buttons, menu.
- `detailed`: multiple screens (use `newpage`); tab bars, trees,
  grids.

## Layout tips

- `@startsalt` / `@endsalt` (or `@startuml` + `salt` keyword block).
- Use `{` grid layouts with `|` column separators.
- Prefix field types: `[Button]`, `"Label"`, `(Radio)`, `<Link>`,
  `[Text field    ]`.

## Known limitations (PlantUML 1.2026.x)

The `newpage` directive does **not produce separate PNG files** when
rendering with `plantuml -tpng`. Only the first page of a multi-page
salt diagram is emitted. SVG output similarly bundles all pages but
most viewers display only the first.

Workaround: split a multi-page wireframe into **separate
`@startsalt`/`@endsalt` blocks** in the same `.puml` file (PlantUML
emits one image per top-level block), or into **separate `.puml`
files** for each page. Each block then renders to its own PNG/SVG and
is independently embeddable in docs.

## Snippet

```plantuml
@startsalt Salt_LoginDialog
!$target = %getenv("PLANTUML_TARGET")
!include .plantuml/_base.puml
!include .plantuml/_targets/$target.puml

{
  Sign in to the Shop
  --
  Email | "you@example.com           "
  Password | "***************         "
  [  ] Remember me
  [Sign in] | [Forgot password]
}
@endsalt
```

## Common pitfalls

- Mistaking Salt for design. Fix: Salt communicates layout intent;
  visual design lives elsewhere.
- Omitting field types. Fix: explicit `[…]` / `"…"` / `(…)` signals
  prevent ambiguity.
- **Using `newpage` and expecting individual page renders.** Fix:
  split into separate `@startsalt` blocks. See Known limitations
  above.
