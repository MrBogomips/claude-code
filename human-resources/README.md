# Human Resources

HR interview workflow for Claude Code — from job description authoring through candidate evaluation.

## Skills

| Skill | Trigger | Purpose |
|-------|---------|---------|
| `job-description` | "write a JD", "descrizione del lavoro" | Write JDs for technical (competency-based) and non-technical (outcome-based) roles |
| `pre-screening` | "screening questions", "domande filtro" | Generate pre-filter questionnaires (async or live script) from CV-JD gap analysis |
| `interview-prep` | "prepare interview for", "preparazione colloquio" | Candidate assessment, STAR-method questions with examples, and interview notes template |
| `interview-close` | "evaluate candidate", "valutazione candidato" | Guided evaluation, seniority classification, and hiring recommendation |
| `compliance-check` | "check compliance", "controlla conformita" | Legal/bias/GDPR review for any HR document (standalone or embedded validation) |
| `hr-help` | "how do I use", "come funziona" | Plugin mentor — methodology, skill guidance, HR best practices |

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

## Language Support

Auto-detects conversation language. Excellent support for Italian and English.

## Methodology

See `METHODOLOGY.md` for the full philosophy, theoretical foundations, design rationale, and usage scenarios.

## License

MIT
