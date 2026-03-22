# Connectors

Tool-agnostic connector registry for the human-resources plugin. Skills reference connectors via `~~category` placeholders and degrade gracefully when no server is connected.

## Registry

| Category | Placeholder | Options | Used by |
|----------|-------------|---------|---------|
| Knowledge base | `~~knowledge base` | Notion, Confluence, Guru, Coda, SharePoint | all skills |
| ATS | `~~ATS` | Greenhouse, Lever, Ashby, Workable, TeamTailor | pre-screening, interview-prep, interview-close |
| HRIS | `~~HRIS` | Workday, BambooHR, Rippling, Gusto, Personio | interview-close |

## How Skills Use Connectors

Skills check for connected servers at runtime. When a connector is available, the skill uses it to enrich its pipeline:

- **~~knowledge base** — pull corporate templates (JDs, evaluation forms), seniority matrices, policies, DEI guidelines, brand/tone guides
- **~~ATS** — pull candidate CV/resume, application data, HR notes, pipeline stage, recruiter assessments, prior interview feedback
- **~~HRIS** — pull seniority framework, level definitions, compensation bands, organizational structure, role catalogs

When no connector is available, skills fall back to manual input and local file output.
