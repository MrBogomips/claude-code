# Connectors

Tool-agnostic connector registry for the tech-writing plugin. Skills refer to each connector by the
placeholder listed in the table below, and degrade gracefully when no server is connected.

## Registry

| Category | Placeholder | Options | Used by |
|----------|-------------|---------|---------|
| Knowledge base | `~~knowledge base` | Notion, Confluence, Guru, Coda, SharePoint | client-facing-doc, bid-delivery-summary |
| Document converter | `~~document converter` | markitdown | client-facing-doc, bid-delivery-summary |

## How Skills Use Connectors

Skills check for connected servers at runtime. When a connector is available, the skill uses it to
enrich its pipeline:

- **~~knowledge base** — for `client-facing-doc`, pull the corporate style guide, terminology
  glossary, and naming standards to standardize terminology and expand acronyms consistently across
  the deliverable; for `bid-delivery-summary`, search for approved cost models, rate cards,
  service-catalog pricing, and commercial estimation frameworks (used only by its cost-model
  authorization gate).
- **~~document converter** — convert non-Markdown sources (PDF, DOCX, PPTX, XLSX, HTML) to Markdown
  before analysis.

When no connector is available, skills fall back to their built-in references and local file output.
