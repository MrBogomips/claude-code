# Detection signatures

The scan-first knowledge behind flow Step 1. This is a curated **reference of facts**, not a
set of recommendations: it tells you how to recognise a spec system or an ADR registry that is
already present, so the skill can report it and stay out. A generic search cannot reliably
re-derive these signatures each run — the on-disk layouts drift in load-bearing ways (BMAD
changed its directories between v4 and v6) and several systems share filenames — so they live
here as knowledge.

## How to scan

Look for the signature paths below at the repository root and one or two levels in. A hit means
a spec system or decision-record registry **already exists**. When you find one:

- Report **what** is present and **where** (the matched path), then **stop**.
- Do not push a second system on top of one that is already in use. The skill is advisory and
  detection-first: an existing process is the user's decision, and stacking a second SDD system
  on top of it creates exactly the duplication the skill is built to avoid.

This is a read-only report — the scan itself writes nothing.

## Path → system table

| Signature path(s) | System | Notes |
|---|---|---|
| `.specify/`, `specs/<NNN>/{spec,plan,tasks}.md` | GitHub Spec Kit | `specs/NNN-feature/` numbered dirs each holding `spec.md` + `plan.md` + `tasks.md`; `.specify/` is the tool's own config. |
| `openspec/` containing `changes/`, `specs/`, `config.yaml` | OpenSpec | Change-proposal layout — `changes/` holds in-flight proposals, `specs/` the settled capability specs. |
| `_bmad/` + `_bmad-output/` | BMAD-METHOD **v6** | New layout. Report the version — the installer and the flow differ from v4. |
| `.bmad-core/` + `docs/{prd,architecture,stories}/` | BMAD-METHOD **v4** | Legacy layout. The `docs/` artifacts (PRD, architecture, sharded stories) are the give-away. |
| `agent-os/` (v2) or `.agent-os/` (v1); plus `standards/`, `specs/` | Agent OS | `standards/` (governance) alongside light `specs/`. The dotted `.agent-os/` is the older v1 location. |
| `.taskmaster/` containing `docs/prd.txt`, `tasks/tasks.json` | Taskmaster | Task-decomposition tool; often **pairs** with a separate spec system rather than replacing one. |
| `.spec-workflow/` containing `specs/`, `steering/` | spec-workflow-mcp | MCP-surfaced workflow with an approval dashboard; `steering/` holds the project's steering docs. |
| `.kiro/specs/<feature>/{requirements,design,tasks}.md`, `.kiro/steering/` | AWS Kiro (IDE) | EARS-style `requirements.md`. Kiro is an **IDE**, not a repo install — see the Kiro caveat in `spec-systems.md`. |
| `docs/adr/`, `doc/adr/`, `.adr-dir`, `.log4brains.yml` | ADR tooling | A *decision-record* registry, not a full spec process. `.log4brains.yml` ⇒ log4brains specifically; `.adr-dir` / `docs/adr/` ⇒ adr-tools-style. |

## Disambiguation rules

Three cases need a rule because the raw signal is ambiguous.

### 1. The shared `requirements.md + design.md + tasks.md` triple — resolve by parent directory

More than one system writes a `requirements.md` + `design.md` + `tasks.md` triple (AWS Kiro under
`.kiro/specs/<feature>/`, spec-workflow-mcp under `.spec-workflow/specs/<feature>/`, and others).
The filenames alone do **not** identify the system. Resolve by the **parent directory**, not the
filenames:

- under `.kiro/` ⇒ AWS Kiro,
- under `.spec-workflow/` ⇒ spec-workflow-mcp,
- under `specs/NNN-*/` with a sibling `.specify/` ⇒ Spec Kit.

If the triple sits under a parent that matches none of the known roots, the result is genuinely
ambiguous: report exactly what was found and where, and ask the user which system it is rather
than guessing.

### 2. BMAD version — `_bmad/` is v6, `.bmad-core/` is v4

BMAD-METHOD changed its on-disk layout between major versions. `_bmad/` (with `_bmad-output/`)
is the **v6** layout; `.bmad-core/` (with the `docs/{prd,architecture,stories}/` artifacts) is
the **v4** layout. Always report the detected version, because the installer command and the
workflow differ between them — a user on v4 and a user on v6 need different guidance.

### 3. ADR signals mean a decision-record registry, not a spec system

`docs/adr/`, `doc/adr/`, `.adr-dir`, or `.log4brains.yml` indicate an **Architecture Decision
Record** registry — lightweight decision logs, not a full spec-driven workflow. Report it as ADR
tooling and distinguish the tool: `.log4brains.yml` ⇒ log4brains; a plain `docs/adr/` with an
`.adr-dir` pointer ⇒ adr-tools-style. A project can hold ADRs *and* still lack a spec system — if
only ADR signals are present, say so plainly, since the user may legitimately want to add a spec
process alongside their existing decision records (offer it; do not assume it).
