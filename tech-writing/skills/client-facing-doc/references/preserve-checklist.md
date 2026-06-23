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

When a single passage mixes preservable substance with confidential detail, keep the substance and
remove only the confidential portion — rewriting the sentence so the seam is invisible.
