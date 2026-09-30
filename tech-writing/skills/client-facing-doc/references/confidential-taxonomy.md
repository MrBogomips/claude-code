# Confidential Content Taxonomy

Every item matching a category below is removed from the client deliverable. When in doubt, treat
the content as confidential and remove it. Removal is silent — leave no marker, placeholder, or note
in the client text. Record each removal in the audit buffer.

The detection cues are about **meaning**. Several cue words also have technical meanings that the
customer needs ("internal load balancer", "error budget", "CAP theorem", "confidential data is
encrypted at rest"); those are kept (see `preserve-checklist.md`). The fixed patterns Step 6 runs on
the written deliverable are in `residual-patterns.md`.

## A. Commercial & Financial

| Category | What to remove | Detection cues |
|----------|----------------|----------------|
| Internal cost estimates | Any internal estimate of what the work costs to deliver | "cost to deliver", "internal cost", cost tables tied to delivery |
| Daily / hourly rates | Per-day or per-hour rates for any role | an amount per day or hour (`€600/day`, `€…/gg`), "day rate", "rate card" (not a throughput such as "10,000 requests/day") |
| Budget information | Budget envelopes, spending caps, allocations | "budget of <figure>", "budget envelope", "spending cap", "allocated funds" (not "error budget" or "CAP theorem") |
| Commercial pricing | Prices, discounts, margins, quotes | currency amounts and codes next to a figure (`EUR 40k`, `12 euro`, `k€`), "list price", a discount or margin on the price |

## B. Effort & Estimation

| Category | What to remove | Detection cues |
|----------|----------------|----------------|
| Internal effort estimates | Estimated effort in days/hours/story points | a figure followed by `MD`, `PD`, `gg`, `gg/uu`, `giornate/uomo`, `giorni/uomo`, man-days, person-days, man-hours, `ore uomo`, story points; hours stated as effort; "ideal days" (full list: `residual-patterns.md` R4–R6) |
| Estimation work breakdowns | WBS or task breakdowns created **for estimation** | tables pairing tasks with effort/cost, "estimation WBS", PERT/three-point figures |
| Resource allocation assumptions | Who/how many people, FTE assumptions for costing | "FTE", "x developers for y weeks", staffing-for-cost notes |

> Note: a *delivery* phase breakdown that carries **no** effort or cost figures and is appropriate for
> the customer may be kept and rewritten. The trigger for removal is the presence of effort/cost data
> or an explicitly estimation-purposed breakdown.

## C. Internal Planning & Constraints

| Category | What to remove | Detection cues |
|----------|----------------|----------------|
| Internal planning considerations | Internal scheduling logic, sequencing rationale tied to capacity | "we can start once X frees up", capacity-driven planning |
| Internal delivery constraints | Constraints meaningful only internally | "depends on our other engagements", team-availability caveats |
| Resource assumptions | Assumptions about internal staffing/skills availability | "assuming senior availability", "if the platform team can support" |

## D. AI & Process Artifacts

| Category | What to remove | Detection cues |
|----------|----------------|----------------|
| AI prompts | Prompt text used to generate content | prompt blocks, "Act as…", "Your task is to…" |
| AI intermediate artifacts | Scratch output, generated drafts not meant for delivery | "draft generated", model scratch, intermediate tables |
| Chain-of-thought reasoning | Step-by-step reasoning narration | "let me think", "step 1: I will", "first I'll consider" |
| References to AI | Any mention that the content itself is AI-generated or AI-assisted | "this document was AI-generated", "as an AI", a named AI tool credited with writing the text |

> Note: an AI model, service or feature that is part of the proposed solution is architecture, not
> a reference to AI. Keep it and describe it like any other component.

## E. Internal Notes & Working Material

| Category | What to remove | Detection cues |
|----------|----------------|----------------|
| Internal discussions / comments | Notes between team members | "@name", review comments, "we discussed", margin notes |
| Draft content | Clearly draft or provisional passages | "DRAFT", "bozza", "provisional", "to be confirmed internally" |
| TODO items | Outstanding internal actions | `TODO`, `FIXME`, `WIP`, "to do", "da fare" |
| Temporary annotations | Placeholders and scaffolding | `[…]` placeholders, `XXX`, "fill in later" |
| References to internal documents | Pointers to internal/unpublished material | "see internal deck", "per the estimation sheet", links to internal stores |
| Information intended for internal use | Anything explicitly marked internal-only | labels such as "internal only", "uso interno", "INTERNAL:", `[DRAFT]`, "Riservato:" or a "RISERVATO" stamp, "do not share" — not the adjective in "internal API" |

## Catch-all rule

If content does not clearly belong to the customer audience and is not covered above, but its
presence in an externally-shared document would be inappropriate or surprising, remove it and log it
under the closest category (or `internal-only`).
