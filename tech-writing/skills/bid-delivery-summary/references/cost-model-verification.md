# Cost-Model Verification Gate

The skill never invents costs. Cost figures appear only when an **approved cost model** is present and
the user has **explicitly authorized** its use. This gate runs before any cost-related content is
produced.

## What qualifies as an approved cost model

Any of the following, when present in the provided material or a connected knowledge base:
- Standard resource rates / day rates
- Internal costing tables
- Service-catalog pricing
- Functional pricing matrices
- Cost-allocation models
- Commercial estimation frameworks

A bare currency figure mentioned in passing in the source is **not** an approved cost model. The model
must be a deliberate, reusable costing artifact. Such a figure is not dropped silently either: see
[Prices in the source without an approved model](#prices-in-the-source-without-an-approved-model).

## Scan order

1. The provided source documents
2. The current conversation and any supplementary material the user has shared
3. A connected **~~knowledge base** (search for rate cards, costing tables, service-catalog pricing,
   estimation frameworks)

## Decision

**If one or more approved cost models are found:**
- Inform the user that cost-related information can be generated, naming the model(s) found.
- Ask for **explicit confirmation** before using any of them, and ask whose authorization to record
  (a name or a role; the user's own answer is enough).
- Do **not** calculate costs without confirmation. If the user declines, proceed effort-only.
- On confirmation, record the **cost basis** for Commercial Considerations: the model used (its name,
  and its version or date when it has one), where it was found, and who authorized its use.

**If no approved cost model is found:**
- Produce **effort-only** output, expressed in Person-Days (PD) / Man-Days (MD).
- Do not infer, estimate, or invent costs, rates, margins, or pricing assumptions.
- In Commercial Considerations, include only this statement:

  > Cost calculations have not been included because no approved internal costing model was provided
  > or authorized.

## Prices in the source without an approved model

In effort-only mode (no approved model, or the user declined one), the source may still quote prices,
rates, budgets or other cost figures. Missing and ambiguous information is a first-class output of
this skill (`extraction-principles.md`), so these figures are neither repeated nor dropped without a
word:

- Do not copy any of the figures into the summary.
- Add one item to the Bid Review Checklist's **Commercial Clarifications**, with the language pack's
  verbatim "unapproved cost figures" text, and say where in the source the figures appear (section
  or heading), without the figures themselves.
- Commercial Considerations still carries only the effort-only statement.

## Always distinguish

Throughout the document, keep these three clearly separate and labeled:
- **Effort estimates** — work quantity in PD/MD
- **Cost estimates** — monetary figures (only when authorized)
- **Commercial assumptions** — qualitative inputs affecting price/scope (e.g., "assumes fixed price",
  "assumes customer provides environments")

When in doubt about whether a figure is a cost, treat it as effort or as a commercial assumption — do
not present it as a cost.
