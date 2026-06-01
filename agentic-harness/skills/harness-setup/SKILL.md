---
name: harness-setup
description: "Build, extend, and maintain a project's agentic harness — the agents, skills, and orchestrator under .claude/. This skill writes files. Use it to set up or build a harness, scaffold or design an agent team and the skills they use, add or change an agent or skill, update or rebuild the harness, sync it after drift, or apply a review context produced by harness-review. On explicit request it can also discover and configure external tools — MCP servers and plugins — that fit the project, and register the approved ones in the harness tools registry. Also triggers on follow-ups such as 'extend the harness', 'the harness needs a new agent', 're-run setup', 'act on the review', and 'find tools or MCPs for this project'. For read-only assessment of how well an existing harness is used, use harness-review instead — this skill is the writer, that one is the reader."
model: opus
---

# Harness setup — build and maintain the agent team

This skill builds and maintains a project-local **agentic harness**: a team of agent
definitions, the skills those agents use, an orchestrator that coordinates them, and a
pointer in the project's `CLAUDE.md`. It writes files. It does not do the project's domain
work — it builds the agents and skills that do.

Read the model first: `${CLAUDE_PLUGIN_ROOT}/shared/harness-model.md` defines the three
parts (agent = who, skill = how, orchestrator = when/order) and why they stay separate.

## This skill vs harness-review

`harness-setup` is the **writer** — every change to the harness goes through it. `harness-review`
is the **reader** — it assesses an existing harness and writes nothing. When a request is
"assess / review / audit / how well is it used," that is `harness-review`. When a request
creates or changes anything, it is this skill. After `harness-review` hands off a *review
context*, this skill is what acts on it.

## Step 0: Orient before writing

Always check the current state first, then pick the path. Do not start generating until the
plan is confirmed.

1. Read `.claude/agents/`, `.claude/skills/`, and the harness section of `CLAUDE.md`.
2. Branch on what you find:
   - **New build** — no harness, or empty agent/skill dirs → run Steps 1–7 in full.
   - **Extend** — a harness exists and the request adds or changes an agent or skill → run
     only the needed steps, per the extension matrix in `references/maintenance.md`.
   - **Apply a review context** — `harness-review` produced a prioritized list → work it as
     an interactive improvement pass (see `references/maintenance.md`).
   - **Sync** — the files and the `CLAUDE.md` record disagree → reconcile and record the
     correction.
3. Summarize what you found and the plan you propose; get the user's confirmation.

## Step 1: Analyze the domain

1. Identify the domain and the core task types (creation, validation, editing, analysis).
2. Explore the codebase — tech stack, data models, key modules — so agents and skills fit
   the project rather than a generic template.
3. Check for conflicts or overlap with any existing agents and skills from Step 0.
4. Read the user's technical level from the conversation and match your wording to it.
   Explain a term like "assertion" or "schema" when the cues suggest it is unfamiliar.

## Step 1b: Discover tools — optional, on request

Run this only when the user asks for it ("find tools / MCPs / plugins for this project").
It is never automatic. It can run inside a build or standalone against an existing harness.

This skill proposes nothing of its own — the candidates come from a live search, not a
built-in catalog:

1. Hand a **search-optimized subagent** (`general-purpose`, with web search) a tight context
   — the project's domain, stack, and task types from Step 1 — and have it find candidate
   MCP servers and plugins that fit. Also inspect the local and session configuration for
   tools already available, so you don't propose what is already there.
2. Present each candidate with the **role** it would fill, what it does, and its trade-off.
   The user **accepts or rejects each one explicitly**. Adopt only what is accepted.
3. Register accepted tools **by role** in the tools registry under the orchestrator — a
   `tools.md` file in `.claude/skills/{domain}-orchestrator/references/`. It is a lookup of
   role → preferred tool → alternative (for when the preferred one is unavailable) → status.
   Agents and skills reference a tool by its **role**, never by a hard tool name, so the
   harness falls back to the alternative when a tool is missing.

The subagent's context template, the acceptance flow, and the registry schema are in
`references/tool-discovery.md`. Registered tools are reviewed periodically — see
`references/maintenance.md`.

## Step 2: Choose the execution mode and the architecture pattern

**Execution mode.** Default to an **agent team** when two or more agents genuinely need to
exchange information mid-task; fall back to **subagents** when they do not, or when the
experimental team tools are unavailable. The team-tools caveat and the mechanical fallback
mapping are in `${CLAUDE_PLUGIN_ROOT}/shared/execution-modes.md` — read it and decide the
mode before designing the team, because the mode shapes the agent definitions and the
orchestrator.

**Architecture pattern.** Decompose the work into areas of expertise and pick a structure.
The six patterns — Pipeline, Fan-out/Fan-in, Expert Pool, Producer-Reviewer, Supervisor,
Hierarchical Delegation — with their fit and their team-mode suitability are in
`references/agent-design-patterns.md`. Composite patterns are common; the same reference
covers them.

**Split agents** along four axes — expertise, parallelism, context, reusability. The
criteria table is in `references/agent-design-patterns.md`. Prefer a few focused agents over
many thin ones; coordination cost grows with team size.

## Step 3: Generate the agent definitions

Write every agent as a file under `.claude/agents/{name}.md` — including agents that use a
built-in type (`general-purpose`, `Explore`, `Plan`). Put the built-in type in the spawn
call; put the role, principles, and protocol in the file. The reason is in the harness
model: a role defined only inline is not reusable next session and carries no collaboration
contract.

Each agent file states: core role, working principles, input/output protocol, error
handling, and collaboration. In team mode, add a **team communication protocol** section —
who it messages, who messages it, and what it claims from the shared task list. The
definition template and worked agent files are in `references/agent-design-patterns.md` and
`references/team-examples.md`.

**Model.** Set each agent's model explicitly, in both the agent file and the spawn call. A
harness's quality tracks its agents' reasoning, so use the strongest reasoning model for
roles that depend on judgment rather than throughput.

**If the team includes a QA agent.** Use the `general-purpose` type (`Explore` is read-only
and cannot run validation). Make its core method *cross-boundary comparison* — read both
sides of a contract together (the producer and the consumer), not each in isolation — and
run it incrementally as each module lands, not once at the end. The full methodology,
boundary-bug patterns, and a QA agent template are in the `qa-agent-guide` reference under
the `harness-review` skill.

## Step 4: Create the skills

Create each skill the agents use at `.claude/skills/{name}/SKILL.md`. The authoring guide —
description writing, body principles, progressive disclosure, data-schema standards — is in
`references/skill-writing-guide.md`. The essentials:

- **Description.** It is the only trigger mechanism. Write it to be specific about what the
  skill does and when it should fire, slightly pushy to offset conservative triggering, and
  worded to stay clear of skills that should *not* fire on the same request.
- **Body.** Explain the *why* rather than issuing bare "ALWAYS/NEVER" rules — an agent that
  understands the reason handles edge cases correctly. Keep it lean (aim under 500 lines;
  move detail to `references/`). Generalize to the principle instead of overfitting to one
  example. Write imperatively.
- **Progressive disclosure.** Metadata is always in context; the body loads on trigger;
  `references/` load only when needed. Split large or domain-specific detail into
  `references/` so only the relevant file loads.
- **Linking.** One agent uses one or more skills; a skill may be shared across agents. The
  skill holds *how*; the agent holds *who*.

## Step 5: Build the orchestrator and register the pointer

The orchestrator is a skill whose subject is the team: which agents take part, what each
produces, how outputs flow, and how failures are handled. Templates for team, subagent, and
hybrid modes — with data-passing, error handling, and test scenarios — are in
`references/orchestrator-template.md`.

Build into the orchestrator:

- **A context-check first phase** so it distinguishes an initial run from a follow-up or a
  partial re-run (branch on whether `_agents_workspace/` already exists).
- **Follow-up trigger keywords** in its description ("re-run", "update", "modify",
  "supplement", "improve the previous result", and everyday domain phrasings). Without
  these, the harness goes unused after its first run.
- **Data-passing** stated explicitly, matched to the mode — see
  `${CLAUDE_PLUGIN_ROOT}/shared/execution-modes.md`.
- **Error handling** that does not assume success: retry once, then proceed without the
  missing result and note the omission; never delete conflicting data — record it with its
  source.
- **The tools registry**, when tool discovery (Step 1b) has run: it lives in this
  orchestrator's `references/` directory as `tools.md`, and agents and skills reference tools
  by role from it.

When extending rather than building new, modify the existing orchestrator — do not create a
second one. Reflect a new agent in the team composition, task assignment, data flow, and
trigger keywords.

Then **register the pointer** in the project's `CLAUDE.md`: goal, trigger rule, and the
change-history table — and nothing the file system already holds. The convention and the
template are in `${CLAUDE_PLUGIN_ROOT}/shared/claude-md-pointer.md`.

## Step 6: Record the change in history

Every write to the harness appends a row to the change-history table in `CLAUDE.md`
(`Date | Change | Target | Reason`). This is a required step, not optional — it is how
evolution stays visible and regressions stay catchable. The table format is in
`${CLAUDE_PLUGIN_ROOT}/shared/claude-md-pointer.md`.

## Step 7: Capture feedback

A harness is a system that keeps changing, not a one-time artifact. After a run, offer the
user the chance to feed back ("anything to improve in the result, the team, or the
workflow?"). If there is none, move on — do not force it. When there is, route it to the
right place: output quality → the relevant skill; missing role → a new agent definition;
wrong order → the orchestrator; missing trigger → a description. The routing table and the
evolution triggers (recurring feedback, repeated failures, the user bypassing the
orchestrator) are in `references/maintenance.md`.

## Deliverable checklist

Before calling a setup or change complete:

- [ ] Every agent is a file under `.claude/agents/` — including built-in types.
- [ ] Skills exist under `.claude/skills/` with valid `name` + `description` frontmatter.
- [ ] One orchestrator, with data flow, error handling, and test scenarios.
- [ ] Execution mode is stated (team / subagent / hybrid; per-phase if hybrid), with the
      subagent fallback covered when team mode is the default.
- [ ] Each agent's model is set explicitly.
- [ ] No `commands/` directory was generated.
- [ ] No conflict with existing agents or skills.
- [ ] Skill and orchestrator descriptions are pushy and include follow-up keywords.
- [ ] Each SKILL.md body is within ~500 lines; overflow moved to `references/`.
- [ ] The orchestrator's first phase does a context check (initial / follow-up / partial).
- [ ] The `CLAUDE.md` pointer is registered (goal + trigger + change history).
- [ ] The change-history table records this change.
- [ ] If tool discovery ran: nothing was adopted without explicit approval, and accepted
      tools are registered by role (with alternatives) in the orchestrator's `tools.md`.

## References

- `references/agent-design-patterns.md` — execution-mode comparison, the six architecture
  patterns, agent-split criteria, the agent-definition template.
- `references/team-examples.md` — worked agent teams across generic domains, with full
  sample agent files.
- `references/orchestrator-template.md` — orchestrator templates by mode, with data-passing,
  error handling, and test scenarios.
- `references/skill-writing-guide.md` — skill authoring: descriptions, body style,
  progressive disclosure, data-schema standards.
- `references/maintenance.md` — extending an existing harness (the extension matrix),
  applying a review context, syncing drift, feedback routing, and periodic tool review.
- `references/tool-discovery.md` — the optional, on-request tool-discovery step: the
  search subagent's context, the explicit-acceptance flow, and the `tools.md` registry schema.
- `${CLAUDE_PLUGIN_ROOT}/shared/harness-model.md`,
  `${CLAUDE_PLUGIN_ROOT}/shared/execution-modes.md`,
  `${CLAUDE_PLUGIN_ROOT}/shared/claude-md-pointer.md` — shared concepts.
