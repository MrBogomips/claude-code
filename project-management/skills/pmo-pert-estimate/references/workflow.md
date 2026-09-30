# Phase 2 Reference — Context Analysis

Read by the skill before it builds the Phase 2 agent prompt. The other phases are described in
`SKILL.md` itself.

| Attribute | Value |
|-----------|-------|
| **Agent** | Opus |
| **Inputs** | The input documents and reference folder from Phase 1, or `sow-extraction.md` and the SOW it names (entry from sow-estimate) |
| **Output** | `<estimate>/project-context.md`, plus a list of open questions |
| **Checkpoint** | Run by the skill: it presents the context and asks the open questions |
| **Backtrack from** | Phase 3, when the context turns out to be incomplete |

## Extraction targets

- Scope and boundaries (in scope, out of scope)
- Constraints: time, budget, regulatory
- Assumptions
- Stakeholders
- Deliverables
- Role references found in the input
- Phases and milestones mentioned
- Risks already identified in the input
- Targets for effort or duration, if the input states any

## Output layout

`project-context.md` uses one heading per extraction target, in the order above. Each item
cites where it came from (document and section), so later phases and the user can check it.
Items the input does not cover are listed under `## Gaps`, not invented.

The agent cannot ask the user anything, so it ends its reply with the open questions: each
ambiguity, contradiction or gap that changes the estimate, phrased so the user can answer it
directly.

When entering from sow-estimate, the extraction already holds a WBS draft, roles and risks.
The context analysis keeps them as they are and adds only what the SOW says beyond them
(constraints, assumptions, stakeholders); Phase 3 and Phase 4 refine the drafts.

## Error recovery

- An ambiguous input becomes an open question for the checkpoint.
- Unreadable reference files are skipped with a warning; the analysis goes on with the rest.
