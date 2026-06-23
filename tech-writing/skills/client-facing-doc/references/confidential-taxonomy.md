# Confidential Content Taxonomy

Every item matching a category below is removed from the client deliverable. When in doubt, treat
the content as confidential and remove it. Removal is silent — leave no marker, placeholder, or note
in the client text. Record each removal in the audit buffer.

## A. Commercial & Financial

| Category | What to remove | Detection cues |
|----------|----------------|----------------|
| Internal cost estimates | Any internal estimate of what the work costs to deliver | "cost to deliver", "internal cost", cost tables tied to delivery |
| Daily / hourly rates | Per-day or per-hour rates for any role | `/day`, `/hour`, `€…/gg`, "day rate", "rate card" |
| Budget information | Budget envelopes, caps, allocations | "budget", "envelope", "cap", "allocated funds" |
| Commercial pricing | Prices, discounts, margins, quotes | currency amounts, "list price", "discount", "margin" |

## B. Effort & Estimation

| Category | What to remove | Detection cues |
|----------|----------------|----------------|
| Internal effort estimates | Estimated effort in days/hours/story points | `\d+ (gg\|pd\|dev-days\|man-days\|person-days\|giorni/uomo)`, "story points", "ideal days" |
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
| References to AI | Any mention that content is AI-generated/assisted | "AI-generated", "as an AI", tool names |

## E. Internal Notes & Working Material

| Category | What to remove | Detection cues |
|----------|----------------|----------------|
| Internal discussions / comments | Notes between team members | "@name", review comments, "we discussed", margin notes |
| Draft content | Clearly draft or provisional passages | "DRAFT", "bozza", "provisional", "to be confirmed internally" |
| TODO items | Outstanding internal actions | `TODO`, `FIXME`, `WIP`, "to do", "da fare" |
| Temporary annotations | Placeholders and scaffolding | `[…]` placeholders, `XXX`, "fill in later" |
| References to internal documents | Pointers to internal/unpublished material | "see internal deck", "per the estimation sheet", links to internal stores |
| Information intended for internal use | Anything explicitly internal-only | "internal only", "interno", "riservato", "do not share" |

## Catch-all rule

If content does not clearly belong to the customer audience and is not covered above, but its
presence in an externally-shared document would be inappropriate or surprising, remove it and log it
under the closest category (or `internal-only`).
