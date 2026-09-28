# Claude Code Plugins

A curated collection of [Claude Code](https://claude.com/claude-code) plugins for professional workflows.

## Plugins

| Plugin | Description | Category |
|--------|-------------|----------|
| [context-hygiene](./context-hygiene) | Context hygiene for agentic projects — audit CLAUDE.md, rules and auto-memory for wrong, stale and redundant content; apply only authorized changes | Engineering |
| [developer-tools](./developer-tools) | Developer environment tooling — devcontainer generation, stack detection, infrastructure config | Engineering |
| [human-resources](./human-resources) | HR interview workflow — job descriptions, pre-screening, interview prep, evaluation, compliance | Human Resources |
| [kaizen](./kaizen) | Continuous improvement loops — recursive optimization engine with profiles for Claude Code usage, refactoring, and process improvement | Engineering |
| [plantuml](./plantuml) | PlantUML diagrams — policy-driven authoring, rendering, lint, validate, review, advisor, and migrate | Documentation |
| [project-management](./project-management) | SOW writing, review, estimation, and PMI-compliant PERT analysis — integrated project management pipeline | Operations |
| [tech-writing](./tech-writing) | Technical writing support — transform documents between internal and client-facing audiences | Documentation |

> **Moved:** the `agentic-harness` plugin now lives in its own repository — [MrBogomips/agentic-harness](https://github.com/MrBogomips/agentic-harness). If you installed it from this marketplace, re-add it from there.

## Installation

There are two ways to install. Pick based on what you want:

- **Claude Code plugins** — installs a **whole plugin** (skills *plus* its agents, commands, and hooks) into Claude Code. Use this for the full experience.
- **`npx skills`** — installs **individual skills only**, portable across many agents (Claude Code, Cursor, Codex, Copilot, Gemini, opencode, …), with a choice of global or per-project scope. Use this when you just want a skill, or want it everywhere.

### Option A — Claude Code plugins (full plugins)

Add this marketplace, then install the plugins you want.

```bash
# 1. Add the marketplace
claude plugin marketplace add MrBogomips/claude-code

# 2. Install a plugin (the marketplace name is "mrbogomips-tools")
claude plugin install kaizen@mrbogomips-tools
```

Or, inside a Claude Code session, use the slash commands:

```
/plugin marketplace add MrBogomips/claude-code
/plugin install kaizen@mrbogomips-tools
```

Browse and manage everything interactively with `/plugin`.

### Option B — `npx skills` (individual skills, any agent)

The [`skills`](https://github.com/vercel-labs/skills) CLI installs the skills from this repo straight into your agent's skills directory — no marketplace setup, and it works outside Claude Code too. It pulls **only the skills**, not the agents/commands/hooks that come with the full plugins above.

First, see what's available:

```bash
npx skills add MrBogomips/claude-code --list
```

**Install locally to a project** (committed with the repo, shared with your team — lives in `./.claude/skills/`):

```bash
# Add the PlantUML authoring skill to the current project, for Claude Code
npx skills add MrBogomips/claude-code --skill plantuml-authoring -a claude-code
```

Use this when a skill is project-specific — e.g. the `plantuml-*` skills on a repo full of diagrams, or the `sow-*` skills on a proposal repo — so everyone who clones the repo gets it.

**Install globally for your user** (available in every project — lives in `~/.claude/skills/`):

```bash
# Add the kaizen continuous-improvement skill everywhere, for Claude Code
npx skills add MrBogomips/claude-code --skill kaizen-engine -g -a claude-code
```

Use this for skills you want on hand everywhere, regardless of which repo you're in.

Handy follow-ups:

```bash
npx skills list             # show installed skills (project + global)
npx skills update           # update installed skills
npx skills remove kaizen-engine -g   # remove a global skill
```

> **Tip:** `npx skills` targets other agents too — add `-a cursor`, `-a codex`, `-a gemini`, etc. (or several at once) to install the same skill across the tools you use.

## Contributing

See [CONTRIBUTING.md](./CONTRIBUTING.md) for guidelines on adding or improving plugins.

## License

MIT — see [LICENSE](./LICENSE) for details.

## Resources

- [Claude Code Documentation](https://code.claude.com/docs)
- [Plugin Development Guide](https://code.claude.com/docs/en/plugins)
- [Plugin Marketplaces Guide](https://code.claude.com/docs/en/plugin-marketplaces)

## Author

**Mr Bogomips** — giovanni.costagliola@gmail.com
