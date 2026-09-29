# Proposal

## Why

Text Claude writes for people (documents, reports, emails, messages) reads impersonal next to its
author's own writing: it carries LLM habits and lacks the author's tone, lexicon and signature
expressions. Users fix this by hand every time, and nothing learns from those fixes. Existing
skills either strip LLM habits without adding the author's voice, or learn from static samples;
none learns from revisions, keeps topic- and language-specific lexicon apart from general tone,
and maintains its store over time.

## What Changes

- New plugin `personal-voice` (0.1.0), made only of skills: no hooks, scripts, connectors or
  local models. Claude Code only.
- `personal-voice:write`: when Claude writes human-facing text, applies the author's profile
  (general tone, language tone, topic lexicon, project glossary, the author's own texts as
  exemplars). While loaded, it also watches for the author's revisions and for the end of the
  session.
- `personal-voice:learn`: learns from the author's revisions of Claude-written text (edited
  file, pasted final version, spoken corrections) and from texts the author wrote without AI.
  Records observations without interrupting, with a one-line notice.
- `personal-voice:maintain`: turns observations into rules with the author's per-item
  confirmation; merges, resolves conflicts, decays and caps the store.
- Two stores: a global store at a directory the user chooses (plugin `userConfig`), holding
  tone of voice (global and per language) and lexicon per topic; and an optional project store
  in `.personal-voice/` for client glossaries and content-type conventions, kept out of git
  unless the user chooses otherwise.
- Works in any language the author writes in, detected automatically.
- Marketplace registration, root README and CONTRIBUTING tables, CLAUDE.md plugin list, and
  Layer 2 scenarios.

## Capabilities

### New Capabilities
- `personal-voice/voice-store`: layout and formats of the global and project stores,
  routing of observations and rules between them, store initialization and its git choice.
- `personal-voice/voice-writing`: when the profile applies, what it loads and in which order,
  precedence, topic resolution and exclusions.
- `personal-voice/voice-learning`: capture of revisions and of the author's own texts,
  separation of style from content, recording of observations, session wrap-up.
- `personal-voice/voice-maintenance`: promotion to rules, merging, conflicts, decay, expiry,
  size limits and scope moves, each with per-item confirmation.

### Modified Capabilities
None.

## Impact

- **Plugins**: new `personal-voice` at 0.1.0 (`plugin.json` and a new `marketplace.json`
  entry, category `documentation`). No existing plugin changes.
- **Marketplace**: `metadata.version` minor bump, 3.1.1 → 3.2.0, as for previous plugin
  additions.
- **Repository docs**: root `README.md` plugin table, `CONTRIBUTING.md` categories table,
  `CLAUDE.md` repository-structure list.
- **Tests**: new scenarios under `tests/scenarios/`; the structural suite covers the new
  plugin unchanged.
- **Users**: writes outside the project (global store) and into `.personal-voice/` raise
  permission prompts in manual mode; the README documents the two allow rules that remove them. The global store never lives in
  the plugin's data directory, which Claude Code deletes on uninstall.
