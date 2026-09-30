# Connectors

Tool-agnostic connector registry for the human-resources plugin. Skills name a connector by the placeholder in the table below and degrade gracefully when no server is connected.

## Registry

| Category | Placeholder | Options | Used by |
|----------|-------------|---------|---------|
| Knowledge base | `~~knowledge base` | Notion, Confluence, Guru, Coda, SharePoint | job-description, pre-screening, interview-prep, interview-close, compliance-check |
| ATS | `~~ATS` | Greenhouse, Lever, Ashby, Workable, TeamTailor | pre-screening, interview-prep, interview-close |
| HRIS | `~~HRIS` | Workday, BambooHR, Rippling, Gusto, Personio | interview-close |
| Document converter | `~~document converter` | markitdown | pre-screening, interview-prep, interview-close, compliance-check |

## How Skills Use Connectors

Skills check for connected servers at runtime. When a connector is available, the skill uses it to enrich its pipeline:

- **~~knowledge base** — pull corporate templates (JDs, evaluation forms), seniority matrices, policies, DEI guidelines, brand/tone guides
- **~~ATS** — pull candidate CV/resume, application data, HR notes, pipeline stage, recruiter assessments, prior interview feedback
- **~~HRIS** — pull seniority framework, level definitions, compensation bands, organizational structure, role catalogs
- **~~document converter** — convert CVs, JDs, interview notes and documents to audit from DOCX or PDF to Markdown before analysis

When no connector is available, skills fall back to manual input (for a DOCX or PDF file, the user pastes the text) and local file output.
