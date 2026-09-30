# Connectors

Tool-agnostic connector registry for the project-management plugin. Skills refer to each
connector by the placeholder in the table below and degrade gracefully when no server is
connected.

## Registry

| Category | Placeholder | Options | Used by |
|----------|-------------|---------|---------|
| Document storage | `~~document storage` | Google Drive, OneDrive, SharePoint | sow-write |
| Email | `~~email` | Outlook, Gmail | sow-write |
| Knowledge base | `~~knowledge base` | Confluence, Notion, SharePoint Wiki | sow-write, sow-review |
| Calendar | `~~calendar` | Google Calendar, Outlook Calendar | sow-write |
| Chat | `~~chat` | Slack, Teams | sow-review |
| CRM | `~~CRM` | Salesforce, HubSpot | sow-write |
| Document converter | `~~document converter` | markitdown | sow-write, sow-review, sow-estimate |

## How Skills Use Connectors

Skills check for connected servers at runtime. When a connector is available, the skill uses it to enrich its pipeline:

- **~~knowledge base** — pull existing project docs, templates, and corporate standards
- **~~document storage** — search for related documents, save outputs
- **~~email** — send review reports, share SOW drafts
- **~~CRM** — pull client context for SOW personalization
- **~~calendar** — check team availability for scheduling
- **~~chat** — post review summaries, notify stakeholders
- **~~document converter** — convert DOCX, PPTX or PDF inputs to Markdown before analysis

When no connector is available, skills fall back to manual input and local file output. Without a
document converter, the SOW skills read Markdown and PDF directly, look for a converter command on
the system (for example `markitdown` or `pandoc`) and ask before running it, and otherwise ask the
user for a Markdown or PDF export.
