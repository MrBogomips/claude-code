# Human Resources

HR interview workflow for Claude Code — from job description authoring through candidate evaluation.

## Skills

| Skill | Trigger | Purpose |
|-------|---------|---------|
| `job-description` | "write a JD", "descrizione del lavoro" | Write JDs for technical (competency-based) and non-technical (outcome-based) roles |
| `pre-screening` | "screening questions", "colloquio telefonico", "domande filtro" | Generate pre-filter questionnaires (async or live script) from CV-JD gap analysis, with a role-level base set |
| `interview-prep` | "prepare interview for", "preparazione colloquio" | Candidate assessment, STAR-method questions with examples, and interview notes template |
| `interview-close` | "evaluate candidate", "valutazione candidato" | Guided evaluation per interviewer, panel consolidation, seniority classification, and a proposed recommendation |
| `compliance-check` | "check compliance", "controlla conformità" | Legal/bias/GDPR/pay-transparency review for any HR document (standalone, or embedded as each skill's last step) |
| `hr-help` | "which HR skill should I use", "come funziona" | Plugin mentor — methodology, skill guidance, HR best practices |

## Pipeline

Skills are loosely pipelined — each works standalone, all compose via file paths:

```
job-description → pre-screening → interview-prep → interview-close
      ↕               ↕               ↕               ↕
                  compliance-check (validation layer)
                            ↕
                         hr-help (guidance layer)
```

## Connectors

Optional integrations. All skills degrade gracefully. See `CONNECTORS.md`.

- `~~knowledge base` — corporate templates, policies, seniority matrices
- `~~ATS` — candidate data from applicant tracking systems
- `~~HRIS` — seniority frameworks, compensation bands
- `~~document converter` — DOCX or PDF CVs and documents to Markdown

## Candidate Data

Pre-screening, interview-prep and interview-close write files about named candidates. Keep them in a folder outside version control: the skills suggest one and warn when the chosen folder is inside a git repository. Each candidate file starts with a confidentiality line and a delete-by date from your retention policy. Candidate data is never saved to memory.

## Legal Content

The legal references in `compliance-check` come from reviewer analysis, not from counsel. They are not legal advice: verify them with counsel before relying on them. The statute for each protected ground is kept in one file, `skills/compliance-check/references/legal-map.md`.

## Changes in 0.3.0

- **Scale.** Scores use one absolute 1–5 scale (1 = no competence shown … 5 = sets direction for others) plus "Not assessed". Evaluations written with earlier versions, where 3 meant "meets expectations for the role", are not comparable number for number.
- **Severity.** Compliance findings use CRITICAL, WARNING and INFO everywhere; the former HIGH, MEDIUM and LOW levels in the reference tables are gone.
- **Files.** interview-close writes one evaluation per interviewer; pre-screening writes the recruiter guide and the live script as separate files and keeps a role-level base set.
- **Screening.** CV gaps are never a screening criterion, and pay-history questions are flagged as CRITICAL in EU jurisdictions.

## Language Support

Auto-detects conversation language. Excellent support for Italian and English.

## Methodology

See `METHODOLOGY.md` for the full philosophy, theoretical foundations, design rationale, and usage scenarios.

## License

MIT
