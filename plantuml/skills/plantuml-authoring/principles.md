# PlantUML Authoring — Design Principles

Universal principles. Loaded on any authoring task. Each principle has a
rationale and a short bad-vs-good example.

## 1. Audience-first

**Rule:** The first question before drawing anything is "who reads this?"
Executive, architect, dev, QA, auditor? Detail level, vocabulary, and
notation follow from the answer.

**Why:** A sequence diagram that satisfies a dev ("show every return
arrow") suffocates an executive; one that pleases an executive ("just
happy path") leaves the dev guessing.

**Bad:** Drawing "a login sequence" without asking. You default to
developer-grade detail and the PM can't read it.
**Good:** Ask. Or infer from context (PRD → exec-leaning; runbook →
ops-leaning; design doc → dev-leaning) and state the assumption
in a top-of-file comment.

## 2. One diagram = one message

**Rule:** Every `.puml` communicates exactly one thing. If you catch
yourself adding a subtitle to explain "also this", split.

**Why:** A diagram is read in one glance; if the glance yields two
takeaways, none of them lands.

**Bad:** A class diagram that shows both the domain model *and* the
persistence mapping.
**Good:** Two files, `domain-model.puml` and `persistence-mapping.puml`,
cross-referenced with `note` directives.

## 3. Progressive disclosure

**Rule:** Overview first in its own diagram; drill-down in separate
diagrams linked from the overview. Never cram drill-downs into the
overview.

When generating multiple detail levels (`minimal` / `standard` /
`detailed`) of the same diagram, the levels MUST share a common spine:
each step adds depth along the *same* axes, never new orthogonal
content. `detailed` is a strict superset of `standard` along the
already-present axes; `standard` is a strict superset of `minimal`.
A reader who sees `minimal → standard → detailed` should be able to
predict `detailed`'s structure from `standard`'s.

**Why:** A 40-node component diagram is unreadable regardless of layout.
Context + container + component (C4-style) is readable at each level.
Adversarial reviewers consistently flag detail levels that introduce
new entities at higher tiers as "three different diagrams of roughly
the same topic, not a zoom-in on one model".

**Detailed is the riskiest preset.** If `detailed` degrades readability
or introduces semantic ambiguity vs `standard`, prefer `standard` and
split the extra content into a separate sibling diagram. More density
≠ more value.

**Bad:** One component diagram with 40 components and 80 arrows.
**Bad:** `standard` shows 4 services; `detailed` adds a saga + queue +
DR replica + observability stack — 4 new categories at once, with no
intermediate. Reader cannot trace the gradient.
**Good:** A 5-container overview; each container expanded into its own
component diagram.
**Good:** `minimal` 3 entities, `standard` 5 entities, `detailed` 7
entities — same entities present at every tier, more attributes /
notes / relations added.

## 4. Layout follows flow, not convenience

**Rule:** The diagram's layout encodes its semantics. Temporal flows go
top-to-bottom. Dependency flows go in the direction of the dependency.
Class inheritance trees may use left-to-right if that's the story.

**Why:** Fighting the default layout wastes hours; aligning with
semantics makes the default layout look right.

**Bad:** A sequence with participants in random order.
**Good:** A sequence with participants in *call order*, left to right.

## 5. Names over technology

**Rule:** Label nodes, arrows, and messages with domain concepts, not
tech. "Order submitted" > "POST /api/v1/orders". Tech names appear only
when the diagram *is about* tech (deployment, component-level HTTP).

**Why:** A diagram about business logic littered with HTTP verbs
confuses the signal. If the arrow label reads like an API spec, the
diagram is pretending to be something it isn't.

**Bad:** `Web → API : POST /orders` in a business-process sequence.
**Good:** `Web → API : Place order` (plus a note if the HTTP binding
matters).

## 6. Color is semantic, not decorative

**Rule:** Color carries information: category, lifecycle, severity, team
ownership. If removing color leaves the message intact, the color wasn't
semantic — remove it.

**Why:** Decorative color increases cognitive load and clashes with
accessibility. Semantic color compresses information.

**Bad:** Every class in a different random color.
**Good:** Red for deprecated, amber for in-progress, green for stable
— *and nothing else*.

## 7. Annotations replace re-drawing

**Rule:** When you want to say "in case X, this differs": add a `note`,
don't draw a second parallel diagram showing the same thing with one
arrow swapped.

**Why:** Two near-identical diagrams force the reader to diff them
mentally. A note on one diagram is explicit.

**Bad:** `sequence-happy.puml` + `sequence-error.puml`, 90% identical.
**Good:** One sequence with `alt/else` or with a `note right of …`
describing the error path.

## 8. Title every diagram

**Rule:** Every `.puml` carries a `title "Human readable caption"`
directive on its own line, in addition to the `@startuml <id>` token.

**Why:** PlantUML names the rendered image after the `@startuml` id,
not the source filename — so the id must be unique per file (otherwise
two diagrams in the same output dir overwrite each other). The id is
a tech identifier; the `title` is what the reader sees in a DOCX
caption, a slide header, or a PDF figure list. Most adversarial
review failures around "no caption" trace back to authors using the
id as if it were the title.

**Conventions:**
- `@startuml <Type>_<Subject>_<Variant>` — unique, mechanically derived,
  matches filename for batch rendering.
- `title "<Subject> — <intent>"` — human, e.g. `title "Checkout — happy
  path"`. Italian/other-locale titles only when the project's `Label
  language` Policy key is non-`en`.

**Bad:** `@startuml Sequence_Checkout` in three sibling files; no
`title`. All three render to `Sequence_Checkout.png`.
**Good:** `@startuml Sequence_Checkout_Standard` + `title "Checkout —
happy path with payment alternatives"`.

## 9. One convention per diagram

**Rule:** Pick a labeling, naming, or notation convention before
drawing, and don't drift mid-diagram.

**Why:** Mixing `submit()` (method call) with `paymentOk` (event name)
on the same sequence forces the reader to context-switch on every
arrow. Same for ArchiMate `Triggering` ↔ `Assignment` for the same
relation type, or for prefix-style ids (`o_771`) interleaved with
natural names (`anne`).

**How to apply:**
- Decide upfront: methods or events, prefixed or natural ids, sync or
  async arrows, `<<include>>` or `..>` for the same semantic.
- If a diagram needs two conventions (rare), separate them spatially
  (e.g., one swimlane per convention) and note why.

## 10. Diagrams are code

**Rule:** Version the `.puml` source. Rendered PNG/SVG/PDF are build
artifacts and go into `/dist`, `/build`, or `.gitignore`d directories
— unless a specific workflow (legal sign-off, offline review, print
deliverables) requires checking them in.

**Why:** Binary artifacts blow up git history; regenerating from source
is cheap.

**Bad:** Committing both `foo.puml` and `foo.png`, updating them by hand
out of sync.
**Good:** Commit `foo.puml` only; render on demand (CI or `plantuml-
convert`).

---

**Usage in the workflow:** these principles are checks applied during
step 4 ("Emit `.puml`") and step 5 ("Validate") of the SKILL.md
workflow. An adversarial reviewer (test harness) uses them as evaluation
axes.
