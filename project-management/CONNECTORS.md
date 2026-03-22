# Connectors

Tool-agnostic connector registry for the project-management plugin. Skills reference connectors via `~~category` placeholders and degrade gracefully when no server is connected.

## Registry

| Category | Placeholder | Options | Used by |
|----------|-------------|---------|---------|
| Document storage | `~~document storage` | Google Drive, OneDrive, SharePoint | sow-write, sow-review |
| Email | `~~email` | Outlook, Gmail | sow-write |
| Knowledge base | `~~knowledge base` | Confluence, Notion, SharePoint Wiki | sow-write, sow-review |
| Project tracker | `~~project tracker` | Jira, Linear, Azure DevOps | sow-estimate |
| Calendar | `~~calendar` | Google Calendar, Outlook Calendar | sow-write |
| Chat | `~~chat` | Slack, Teams | sow-review |
| CRM | `~~CRM` | Salesforce, HubSpot | sow-write |
| Office suite | `~~office suite` | Google Workspace, Microsoft 365 | pmo-pert-estimate |

## How Skills Use Connectors

Skills check for connected servers at runtime. When a connector is available, the skill uses it to enrich its pipeline:

- **~~knowledge base** — pull existing project docs, templates, and corporate standards
- **~~document storage** — search for related documents, save outputs
- **~~project tracker** — import existing backlog items, link deliverables to tickets
- **~~email** — send review reports, share SOW drafts
- **~~CRM** — pull client context for SOW personalization
- **~~calendar** — check team availability for scheduling
- **~~chat** — post review summaries, notify stakeholders
- **~~office suite** — open generated Excel workbooks, convert markdown to docs

When no connector is available, skills fall back to manual input and local file output.
