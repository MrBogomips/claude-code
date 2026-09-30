# Preservation Checklist

Content in these categories is customer-relevant and must be **kept** — then improved (restructured,
clarified, expanded into prose). Preserving means retaining the technical substance, not the original
wording: rewrite freely for clarity and a consultative tone, but do not drop the information and do
not invent facts the source does not support.

## Keep and improve

| Category | What it covers |
|----------|----------------|
| Solution architecture | System structure, components, layering, key diagrams and their explanations |
| Functional scope | What the solution does — features, capabilities, in-scope behavior |
| Non-functional requirements | Performance, scalability, availability, security, maintainability targets |
| Technical constraints | Platform, technology, standards, regulatory or compatibility constraints |
| Design decisions | Choices made and the rationale a customer should understand |
| Architectural considerations | Trade-offs, alternatives weighed, guiding principles |
| Customer-suitable assumptions | Assumptions appropriate to state to the customer |
| Dependencies | External systems, third-party services, customer-side prerequisites |
| Externally-communicable risks | Risks appropriate to disclose, with mitigations |
| Integration patterns | How the solution connects to other systems; protocols and contracts |
| Deployment considerations | Environments, topology, rollout approach relevant to the customer |
| Operational aspects | Monitoring, support model, maintenance relevant to the customer |

## Boundary cases

- **Risks** — keep risks that are appropriate to share with a customer (technical, dependency,
  integration risks with mitigations). Remove risks framed around internal capacity, commercial
  exposure, or margin.
- **Assumptions** — keep assumptions about the customer's environment, scope, and inputs. Remove
  assumptions about internal staffing, rates, or delivery economics.
- **Phase breakdowns** — keep a delivery roadmap that carries no effort or cost figures. Remove any
  breakdown that exists to support estimation or that pairs work with effort/cost.

## Technical vocabulary that looks confidential

Some words the taxonomy uses as cues are also plain technical vocabulary. When they describe the
solution, they are substance and stay:

- "internal" as an adjective: internal load balancer, internal API, internal network, internal DNS,
  an endpoint that is "internal only" (not exposed to the internet), an `Internal:` admin interface
- "budget" and "cap" in engineering terms: error budget, latency budget, CAP theorem, rate cap
- "confidential" as a data class: "confidential data is encrypted at rest"
- "cost" as a design property: cost-optimized storage tier, cloud cost monitoring
- hours and days as service levels: a recovery time objective of 4 hours, a 5-working-day response
  time, an estimated cut-over downtime of 2 hours, written out in full
- AI components of the solution: a model, an LLM-based feature, an AI service the solution calls

The Step 6 scan flags these words for review rather than removing them (`residual-patterns.md`,
REVIEW rows); the judgment is whether the sentence describes the solution or the vendor's internal
work.

When a single passage mixes preservable substance with confidential detail, keep the substance and
remove only the confidential portion — rewriting the sentence so the seam is invisible.
