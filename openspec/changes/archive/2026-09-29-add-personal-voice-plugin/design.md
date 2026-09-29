# Design

## Context

See proposal.md for the motivation and specs/ for the required behavior. This section covers
only what shapes the approach.

- **Prior art.** Open-source skills cover parts of the loop. Some capture a draft and a final
  version inside one session with evidence levels (myvoice-skill). One compacts a two-level
  store (write-like-me). One harvests the author's own texts (voice-suite). Anti-slop skills
  remove LLM habits without adding the author's voice. None combines capture, topic- and
  language-aware routing, and maintenance. Commercial tools that learn from edits (Lindy,
  Fyxer, Grammarly) are closed and focused on email.
- **Research.**
  - PRELUDE/CIPHER (NeurIPS 2024) infers one plain-language preference per edit and retrieves
    preferences by context.
  - PROSE (ICML 2025) checks each preference against several samples and drops those that
    only fit one sample; rules combined with examples outperform either alone.
  - Baumler et al. (ACL 2026) found that post-edited text stays closer to LLM style than to the
    author's unassisted writing, while authors perceive it as their own.
  - Memory partitioned by domain leaks less across contexts.
- **Claude Code facts this design relies on** (checked against the current documentation):
  - Once loaded, a skill's content stays in context across turns. After compaction, the most
    recent invocation of each skill is re-attached, keeping its first 5,000 tokens.
  - `userConfig` supports a `directory` type, and `${user_config.KEY}` is substituted in skill
    content. Verified by spike 2.1: a configured value is substituted, and an unset value stays
    as the literal placeholder text.
  - `.claude/` and `.git/` are protected paths: in manual and `acceptEdits` modes a write there
    always prompts, and allow rules do not pre-approve it (spike 2.2).
  - `${CLAUDE_PLUGIN_DATA}` survives plugin updates but is deleted on uninstall.
  - `allowed-tools` grants apply only to the turn that invokes the skill.
  - `context: fork` subagents do not see the conversation.
  - The skill listing truncates `description` plus `when_to_use` at 1,536 characters.
- **Repository constraints.**
  - `tests/validate-references.sh` resolves every `references/...` path relative to the skill
    that mentions it.
  - Descriptions must not contain angle brackets.
  - Examples in the repository must be anonymized.

## Goals / Non-Goals

**Goals:**
- The whole plugin is Markdown skills that the user's model executes with its built-in tools.
- The write skill stays small, because it remains in context for the whole session.
- Every store file stays readable and editable by the author.

**Non-Goals:**
- Automatic capture outside the session (edits made after the session ends, sent emails).
- Retrieval by embeddings, stylometric computation, or any fine-tuned model.
- Other hosts (claude.ai, Cowork, other agents), and sharing a profile across assistants.
- Brand or team voice: the profile belongs to one person.

## Decisions

### D1. Skills only
The plugin ships three skills (`write`, `learn`, `maintain`), with no hooks, scripts,
connectors, MCP servers or local models.
- **Why:** the user's choice. It also keeps installation to one step, and matches the research,
  since CIPHER and PROSE work through prompting alone.
- **Rejected:**
  - `PostToolUse` + `FileChanged` hooks for capture. The FileChanged matcher accepts file names
    only, its payload carries no content, and it only works while a session is open.
  - Local embedding models, the one role where a local model clearly wins, because they add a
    runtime dependency for every user.
  - Email connectors to diff a draft against the email that was sent.

### D2. A sentinel inside the write skill
The learn skill runs alongside the user's main request ("here is the final version, now export
it"), so a trigger based on its description alone would be unreliable. The write skill, whose
trigger is the main task, carries a short standing instruction near the top of its body: when
the author revises text Claude wrote, or signals the end of the session, invoke the learn skill.
A revision includes a file Claude wrote that changed on disk: on the next turn Claude Code
tells the model about the change and shows the new content (spike 2.3).
- **Why:** the body stays in context for the rest of the session. Placing the sentinel near the
  top keeps it inside the 5,000 tokens re-attached after compaction.
- **Fallback:** the user can invoke the learn skill explicitly.
- **Rejected:**
  - A `SessionStart` hook that injects a reminder (excluded by D1).
  - An output style with `force-for-plugin`, which applies to every response and overrides the
    user's own output style.
  - A forked learn skill, which would not see the draft.

### D3. Observations, rules and exemplars
Each revision produces observations, each a single trait with its provenance. A trait becomes a
rule only after two independent pieces of evidence and the author's confirmation. At write time,
rules and a few exemplars are combined.
- **Why:** this follows CIPHER (one preference per edit), PROSE (confirm across samples before
  trusting; rules plus examples), and the user's choice of two pieces of evidence.
- **Rejected:**
  - Putting raw past edits in the prompt: costly in tokens and weaker in the papers.
  - Fine-tuning per author (DITTO, LoRA): needs model weights and more data.

### D4. Own-text learning
The learn skill accepts texts the author wrote without AI, as a source of both observations and
exemplars.
- **Why:** without it the profile only fills from revisions, slowly. Revisions are also anchored
  to LLM style (Baumler), and unassisted text is the corrective.

### D5. Two stores, with the global location chosen by the user
The global store's location comes from a `userConfig` `directory` field, and the skills read it
as `${user_config.store_dir}`. The project store lives at `.personal-voice/` in the project root.
- **Why:** the user owns the location of months of accumulated data. The generic-usage principle
  forbids assuming a personal path. A folder outside `.claude/` lets one allow rule remove the
  prompts, as for the global store.
- **Rejected:**
  - `${CLAUDE_PLUGIN_DATA}`, which is deleted on uninstall.
  - A fixed path under `~/.claude/`, which assumes the author's layout.
  - Claude Code auto-memory, which is managed by Claude Code, scoped per project, and loaded
    every session.
  - `.claude/voice/`, the first choice. `.claude/` is a protected path, so in manual and
    `acceptEdits` modes every recording would prompt, and no allow rule removes the prompt.

### D6. Tone and lexicon, routed by a decision table
Tone lives in `core.md` (global) and `languages/<code>.md` (per language). Lexicon lives in
`topics/<slug>.md`. Cross-topic signature expressions go in the language file. A single ordered
routing test (project? tone or lexicon? language- or topic-dependent?) decides where each entry
goes.
- **Why:** each file answers one question. Hard partitions limit leakage across contexts. The
  test gives the same answer for the same entry every time.

### D7. Topic as the only file axis; audience as a qualifier
There is one file per topic. Audience-dependent tone is written as a qualified entry in a tone
file, such as `[to clients]` or `[to family]`.
- **Why:** audience mostly changes tone, and tone is not organized by topic.
- **Rejected:** separate files for each topic and audience pair, which multiplies files with no
  clear gain.

### D8. Project store personal by default
When the project store is created, the author chooses. The default adds `.personal-voice/` to
`.git/info/exclude`.
- **Why:** it protects client names in shared or public repositories without touching the
  shared `.gitignore`. Versioning is an informed opt-in.
- **Cost:** `.git/` is a protected path, so the edit to `.git/info/exclude` prompts once, when
  the store is created or its git choice changes.

### D9. No draft registry
The draft is available only while it is in the session. To learn from a later revision, the
author provides both versions.
- **Why:** the simplest design first. A registry can be added later without changing the store
  layout.

### D10. Markdown everywhere, with shared formats in one place
Store files, including `observations.md`, are Markdown with a small frontmatter; there is no
JSONL. The store format and routing table live in a single file at the plugin root,
`shared/store-format.md`. The skills reference it as `${CLAUDE_PLUGIN_ROOT}/shared/store-format.md`,
which the reference validator does not treat as a skill-local path. Material specific to one
skill stays in that skill's `references/`.
- **Why:** the model edits these files with its built-in tools and the author reviews them.
  Keeping one copy of the format avoids drift between skills.
- **Rejected:** a copy of the format in each skill, which would drift.

### D11. Assumed limits
The limits come from two sources:
- **Chosen by the user:** 50 rules per file; promotion after two pieces of evidence.
- **Proposed here and confirmed by the user, adjustable after trial:**
  - at most five exemplars per topic and language, each at most 300 words;
  - a maintenance suggestion at 10 pending observations or 30 days;
  - decay review after 6 months; expiry of single-evidence observations after 3 months.

## Risks / Trade-offs

- **Permission prompts.** Measured by spike 2.2, with headless sessions and a second turn on a
  resumed session:
  - In manual mode, writes to the global store and to the project store prompt on every turn.
    In `acceptEdits` mode, only the global store prompts, since it is outside the working
    directory. In auto mode, the classifier approved both.
  - With `Edit(//<store path>/**)` and `Edit(**/.personal-voice/**)` in the user settings, no
    write prompts, in the first turn or later ones.
  - The edit to `.git/info/exclude` prompts in manual and `acceptEdits` modes whatever the
    rules, because `.git/` is protected.
  - In the live end-to-end run (task 7.1), a compound shell command that listed the store
    was denied in manual mode: the file rules do not cover shell commands.
  → The README documents the allow rules. The project store sits outside `.claude/` (D5). The
  skills use the Glob, Read, Write and Edit tools on the store, never shell commands; with
  that, the end-to-end run raised no prompt.
- **The write skill may not trigger.** Triggering depends on the description.
  → The description leads with the intent in several languages and stays within the listing cap.
  Explicit invocation remains available. Layer 2 scenarios cover triggering.
- **Edits to a file made outside Claude Code may go unnoticed.** Spike 2.3 observed the notice:
  on the next turn of a resumed session, the model was told that a file it wrote had changed and
  was shown the new content. The docs do not describe it as guaranteed, and the notice may show
  only the changed lines.
  → The sentinel treats the notice as a revision (D2), and the learn skill re-reads the file
  for the full text. The README still asks the author to say when they edited a file. The
  wrap-up re-reads files Claude wrote in the session.
- **Context cost.** The write skill stays loaded, and each draft loads up to six store files.
  → Keep the write SKILL.md body short. Cap rules and exemplars (D11). Load at most two topics.
- **Style and content confused.** Research classifiers perform poorly on style edits.
  → Only the model judges which edits are style. An observation needs two pieces of evidence and
  the author's confirmation before it affects any text.
- **Profile anchored to LLM style** (Baumler).
  → Own-text learning (D4). Exemplars come only from unassisted texts.
- **Personal data.** The global store holds personal texts.
  → It lives only where the author chose. Personal material never enters a project store, and
  the README states what the store holds.
- **Expectations.** Studies report modest gains in style matching, and informal registers are
  the hardest.
  → The README sets expectations and does not overpromise.

## Migration Plan

This is a new plugin, so there is nothing to migrate. Registering it in `marketplace.json` makes
it installable; removing the entry and the directory rolls it back. Stores the author created
stay in place.

## Open Questions

- Settled: the write skill's description triggers without `when_to_use`. In headless runs,
  10 of 11 requests for human-facing text in four languages invoked it, and none of 5 requests
  for explanations, docstrings, workflow YAML or commit messages did.
