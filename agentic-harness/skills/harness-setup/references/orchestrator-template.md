# Orchestrator template

The orchestrator is the top-level skill that coordinates the whole team. It comes in three
shapes, one per execution mode. Pick the shape from the mode chosen in Step 2; for hybrid,
state the mode per phase.

## Table of contents

- [Orchestrator template](#orchestrator-template)
  - [Table of contents](#table-of-contents)
  - [Template A — agent team (default)](#template-a--agent-team-default)
  - [Template B — subagent (fallback / lightweight)](#template-b--subagent-fallback--lightweight)
  - [Template C — hybrid](#template-c--hybrid)
  - [Authoring rules](#authoring-rules)
  - [Follow-up keywords](#follow-up-keywords)

---

## Template A — agent team (default)

The first choice when two or more agents need to talk while they work. Build the team with
`TeamCreate`; coordinate over a shared task list and `SendMessage`.

````markdown
---
name: {domain}-orchestrator
description: "Coordinates the {domain} agent team to produce {deliverable}. {initial keywords}. Also use for follow-ups: re-run, update, modify, supplement, improve the previous result, and everyday {domain} requests."
model: opus
---

# {Domain} orchestrator

Coordinates the {domain} agent team to produce {final deliverable}.

## Execution mode: agent team

## Team

| Member | Type | Role | Skill | Output |
|--------|------|------|-------|--------|
| {member-1} | {custom or built-in} | {role} | {skill} | {file} |
| {member-2} | ... | ... | ... | ... |

## Workflow

### Phase 0: context check
Branch on whether prior work exists:
- `_agents_workspace/` absent → initial run; go to Phase 1.
- `_agents_workspace/` present + a partial-change request → partial re-run; re-invoke only
  the affected member and overwrite only its output.
- `_agents_workspace/` present + new input → new run; move the old `_agents_workspace/` to
  `_agents_workspace/archive/{YYYYMMDD_HHMMSS}/`, then go to Phase 1.
On a partial re-run, pass the prior output path into the member's prompt so it reads the
existing result and folds in the change.

### Phase 1: prepare
1. Read the input and identify {what to identify}.
2. Create `_agents_workspace/` (or recreate it after archiving the old one on a new run).
3. Save the input under `_agents_workspace/00_input/`.

### Phase 2: form the team
1. `TeamCreate(team_name, members: [...])` — each member with its name, type, model, and a
   role prompt.
2. `TaskCreate(tasks: [...])` — roughly five to six tasks per member; declare dependencies
   with `depends_on`.

### Phase 3: {the main work}
Members claim tasks from the shared list and work independently. State the communication
rules: who passes what to whom via `SendMessage`; that each member saves its output to a
file and notifies the leader on completion; that a member requesting another's result asks
over `SendMessage`. The leader watches progress (it is notified when a member goes idle),
nudges or reassigns a stuck member, and checks state with `TaskGet`.

| Member | Output path |
|--------|-------------|
| {member-1} | `_agents_workspace/{phase}_{member-1}_{artifact}.md` |

### Phase 4: integrate
1. Wait for all tasks to complete (`TaskGet`).
2. Read each member's output.
3. Apply the integration logic; where members conflict, record both with their sources.
4. Write the final deliverable to the user's target path.

### Phase 5: tear down
1. Ask members to stop (`SendMessage`); `TeamDelete`.
2. Keep `_agents_workspace/` (do not delete intermediate work).
3. Report a summary to the user.

## Error handling

| Situation | Strategy |
|-----------|----------|
| One member fails or stalls | leader checks via `SendMessage`, restarts or replaces it |
| Most members fail | tell the user, confirm whether to continue |
| Timeout | use the partial results, stop the unfinished members |
| Members disagree | record both with sources; do not delete either |
| Task state lags | leader confirms with `TaskGet`, corrects with `TaskUpdate` |

## Test scenarios
- **Normal:** input → analysis → team of N + M tasks → self-coordinated work → integration →
  teardown → the deliverable exists at its path.
- **Error:** a member stops mid-phase → leader gets the idle notice → restart attempt →
  on repeated failure, reassign its task → integrate the rest → note the gap in the report.
````

## Template B — subagent (fallback / lightweight)

When team communication is unnecessary, or the team tools are unavailable. Spawn each agent
with the `Agent` tool and collect return values.

````markdown
---
name: {domain}-orchestrator
description: "Coordinates {domain} agents to produce {deliverable}. {initial keywords} + follow-up keywords."
model: opus
---

## Execution mode: subagent

## Agents

| Agent | subagent_type | Role | Skill | Output |
|-------|---------------|------|-------|--------|
| {agent-1} | {built-in or custom} | {role} | {skill} | {file} |

## Workflow

### Phase 0: context check
Same branch as Template A — on whether `_agents_workspace/` exists.

### Phase 1: prepare
Read the input; create `_agents_workspace/` (archiving any old one on a new run).

### Phase 2: run in parallel
Invoke the agents in a single message:

| Agent | Input | Output | model | run_in_background |
|-------|-------|--------|-------|-------------------|
| {agent-1} | {source} | `_agents_workspace/{phase}_{agent}_{artifact}.md` | opus | true |

### Phase 3: integrate
Collect each return value; read file outputs; apply the integration logic; write the final
deliverable.

### Phase 4: finish
Keep `_agents_workspace/`; report a summary.

## Error handling
- One agent fails: retry once; on a second failure, note the omission and continue.
- Most fail: tell the user and confirm.
- Timeout: use the partial results.
````

## Template C — hybrid

A different mode per phase. State `**Execution mode:** {team | subagent}` at the top of each
phase.

````markdown
---
name: {domain}-orchestrator
description: "{domain} orchestrator (hybrid). {keywords} + follow-up keywords."
model: opus
---

## Execution mode: hybrid

| Phase | Mode | Why |
|-------|------|-----|
| Phase 2 (parallel collection) | subagent | independent collection, no coordination needed |
| Phase 3 (consensus integration) | agent team | reconcile conflicting inputs by discussion |
| Phase 4 (independent verification) | subagent | one QA agent verifies objectively |

### Phase 2: collect — **Execution mode:** subagent
Invoke N agents in parallel (`run_in_background: true`); save each to
`_agents_workspace/02_{agent}_raw.md`.

### Phase 3: integrate — **Execution mode:** agent team
`TeamCreate` an integration team; `TaskCreate` work that reads the Phase 2 files; members
reconcile conflicts via `SendMessage`; write `_agents_workspace/03_integrated.md`;
`TeamDelete`.

### Phase 4: verify — **Execution mode:** subagent
One QA subagent reads `_agents_workspace/03_integrated.md` and writes a verification report.
````

**Transition rules.** Team → subagent: `TeamDelete` before any `Agent` call. Subagent →
team: pass the subagent's file outputs to members as read paths. Team → team: tear down the
old team before the next `TeamCreate` (only one team is active per session).

## Authoring rules

1. State the execution mode at the top. For hybrid, a per-phase mode table is required.
2. For team mode, be concrete about `TeamCreate` / `TaskCreate` / `SendMessage` usage.
3. For subagent mode, fully specify each `Agent` call (name, type, prompt, model,
   `run_in_background`).
4. Use clear paths under `_agents_workspace/`; avoid ambiguous relative paths.
5. State inter-phase dependencies — which phase needs which phase's output. For hybrid,
   call out the transition points.
6. Make error handling realistic — do not assume everything succeeds.
7. Include at least one normal and one error test scenario.

## Follow-up keywords

Initial-run keywords alone leave the harness unused after its first run. Put follow-up
phrasings in the description: re-run, run again, update, modify, supplement; "only the
{part} again"; "based on the previous result", "improve the result"; and everyday domain
requests (for a launch-planning harness: "launch", "promotion", and the like).
