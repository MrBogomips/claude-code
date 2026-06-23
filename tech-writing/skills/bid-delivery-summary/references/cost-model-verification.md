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
must be a deliberate, reusable costing artifact.

## Scan order

1. The provided source documents
2. The current conversation and any supplementary material the user has shared
3. A connected **~~knowledge base** (search for rate cards, costing tables, service-catalog pricing,
   estimation frameworks)

## Decision

**If one or more approved cost models are found:**
- Inform the user that cost-related information can be generated, naming the model(s) found.
- Ask for **explicit confirmation** before using any of them.
- Do **not** calculate costs without confirmation. If the user declines, proceed effort-only.

**If no approved cost model is found:**
- Produce **effort-only** output, expressed in Person-Days (PD) / Man-Days (MD).
- Do not infer, estimate, or invent costs, rates, margins, or pricing assumptions.
- In Commercial Considerations, include only this statement:

  > Cost calculations have not been included because no approved internal costing model was provided
  > or authorized.

## Always distinguish

Throughout the document, keep these three clearly separate and labeled:
- **Effort estimates** — work quantity in PD/MD
- **Cost estimates** — monetary figures (only when authorized)
- **Commercial assumptions** — qualitative inputs affecting price/scope (e.g., "assumes fixed price",
  "assumes customer provides environments")

When in doubt about whether a figure is a cost, treat it as effort or as a commercial assumption — do
not present it as a cost.
