# SDD coordination

When a project has a spec-driven development (SDD) system installed, the harness does not run
beside it — the two **work coordinated**. This file defines how the generated orchestrator and an
installed SDD system compose: who owns which part of the workflow, how the orchestrator hands work
in, and how it picks the work back up. `harness-setup` reads this to bake the coordination into the
orchestrator it generates; the orchestrator itself cannot read this file at runtime, so the
relevant values are **inlined** at generation time.

A harness is the *who/how/when* of the work — agents, skills, order. An SDD system is the
*project process* the work follows — requirements, design, decomposition, decision records. They
are different layers, so they compose cleanly once the boundary is drawn. Detection of which
system is present is a separate concern: see `${CLAUDE_PLUGIN_ROOT}/shared/detection-signatures.md`.

## The coordination model

An SDD system owns a **bounded segment** of the workflow — usually the spec/plan/decompose
front-end, and for the heavier systems part of the build too. The orchestrator stays the driver
and coordinates that segment through a **two-way handoff**, the same shape for every system:

1. **Activate (hand-in).** At the phase boundary the SDD owns, the orchestrator composes a
   **contextual prompt** from what it already holds — the goal, the constraints, the context it has
   gathered — and activates the SDD's entry point so the SDD starts cleanly without re-gathering:
   - *Auto-invokable* (a CLI or MCP entry point) → the orchestrator invokes it directly with the
     contextual prompt.
   - *Human-gated* (an IDE, or a workflow with an approval step) → the orchestrator emits the
     contextual prompt for the user, **pauses**, and resumes when the user confirms the step is done.
2. **The SDD runs its owned segment.** The orchestrator does **not** duplicate it — it never
   re-derives the requirements or the plan the SDD owns.
3. **Hand-back (return).** The SDD signals completion; its artifacts — the spec, plan, tasks,
   approved design, or task graph — are the **contract**. The orchestrator detects completion (the
   artifact is present, an approval flag is set, or the user confirms) and resumes.
4. **The orchestrator resumes its owned segment** — parallel execution, integration, cross-boundary
   QA — reading the SDD artifacts as its input and **writing status and decisions back** in the
   SDD's own conventions. The final deliverable still goes to the user's target path.

### Two rules that keep it clean

- **One owner per phase.** Mark each orchestrator phase as either delegated (`→ SDD: {system}`) or
  orchestrator-owned. A phase the SDD owns is not re-done by an agent, and vice versa. This is what
  prevents the parallel-and-conflicting flow the coordination exists to avoid.
- **One source of truth per artifact.** SDD artifacts are **referenced**, never copied into
  `_agents_workspace/`. The orchestrator reads them in place and writes status back in place. Copying
  a spec into the workspace creates a second copy that drifts — the same anti-pattern the `CLAUDE.md`
  pointer avoids by not duplicating the file system.

Friction is minimised by the two ends of the handoff: the **contextual prompt** on hand-in means the
SDD does not re-ask what the orchestrator already knows, and the **artifact-as-contract** on
hand-back means the orchestrator does not re-derive what the SDD already settled.

## Per-system coordination map

The owned segment, the activation entry point, the hand-back contract, and the write-back rule for
each system in the curated shortlist. `harness-setup` looks up the detected system's row and inlines
these concrete values into the orchestrator. Where a system spans versions (BMAD), the artifact path
follows the detected version — see `${CLAUDE_PLUGIN_ROOT}/shared/detection-signatures.md`.

| System | SDD owns | Activate (hand-in) | Auto-invokable? | Hand-back contract | Orchestrator writes back |
|---|---|---|---|---|---|
| **GitHub Spec Kit** | spec → plan → tasks | run the specify flow / author `specs/<NNN>/` from the contextual prompt | semi (CLI scaffolds; content authored) | `specs/<NNN>/{spec,plan,tasks}.md` present and complete | tick task checkboxes in `tasks.md` |
| **OpenSpec** | the change proposal | author `openspec/changes/<id>/` from the context | semi | the settled change proposal | implement the change; archive to `openspec/specs/` |
| **Agent OS** | the spec, honoring standards | produce `agent-os/specs/` per `standards/` | semi | the spec is ready | execute per spec + standards |
| **AWS Kiro** | EARS requirements/design/tasks (IDE) | emit the contextual prompt; the user authors in the Kiro IDE; **pause** | no (IDE / human) | `.kiro/specs/<feature>/{requirements,design,tasks}.md` | status back into `tasks.md` |
| **ADR tooling** | decision records | on a design decision, hand in "record this decision" | semi | an ADR file under `docs/adr/` | append an ADR for each decision the harness makes |
| **BMAD-METHOD** | the agile persona pipeline | activate the BMAD flow with the contextual prompt (which epic / story) | yes (CLI; human-in-loop steps) | `_bmad-output/` (v6) or `docs/{prd,architecture,stories}/` (v4) + story status | coordinate; add only the cross-cutting QA / integration BMAD lacks; write story status back |
| **spec-workflow-mcp** | the spec workflow + approval gate | call its MCP tools with the contextual prompt; wait on the approval gate | yes (MCP) + human approval | the approved spec under `.spec-workflow/specs/` | execute the approved spec; status back via its conventions |
| **Taskmaster** | task decomposition + tracking | hand in the PRD / context → it parses to a task graph | yes (CLI / MCP) | `.taskmaster/tasks/tasks.json` | execute tasks; update task status via Taskmaster |

The heavier systems (BMAD, spec-workflow-mcp, Taskmaster) own a **larger** segment and may be
human-gated, but the handoff protocol is the same — there is no "step aside and let the SDD own
everything" mode. The orchestrator always drives the parts the SDD does not own (typically
execution, integration, and a cross-boundary QA pass), and coordinates the rest.

### Taskmaster as a pairing

Taskmaster decomposes and tracks tasks; it **pairs** with an upstream spec system rather than
replacing one (it owns the task graph, not the requirements). When Taskmaster co-exists with a spec
system, the orchestrator anchors requirements to the spec system and routes **task status** through
Taskmaster's `tasks.json` instead of inventing its own status file — one owner per concern.

## How `harness-setup` uses this

1. After detecting the present system (Step 0), look up its row above and capture the **coordination
   context**: `{system, version, owned-segment, activation, auto-invokable, hand-back contract,
   write-back rule}`.
2. With the user, decide which phases the orchestrator delegates vs owns, and whether activation is
   auto or prompt-and-pause (Step 2). Fold the decision into the change manifest.
3. Splice the **SDD-coordination block** from `harness-setup`'s `references/orchestrator-template.md`
   into the chosen template (A / B / C), substituting the concrete values from the coordination
   context (Step 5). The generated orchestrator must be self-contained — inline the paths and the
   entry point; do not leave it pointing at this file.
4. Record the relationship in the `CLAUDE.md` pointer's **Spec process** line — see
   `${CLAUDE_PLUGIN_ROOT}/shared/claude-md-pointer.md`.
