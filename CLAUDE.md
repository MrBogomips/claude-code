# CLAUDE.md

Guidance for working in the mrbogomips plugins marketplace repository.

## Repository structure

This is a flat-at-root plugin marketplace following the convention used by Anthropic's domain-specific marketplaces. Each top-level directory is a plugin:

- `developer-tools/` — developer environment tooling
- `human-resources/` — HR workflow support
- `project-management/` — project management workflows
- `tech-writing/` — technical writing support

## Plugin conventions

Every plugin must contain `.claude-plugin/plugin.json`. Components are discovered by convention:

- **Skills** — `skills/*/SKILL.md`
- **Agents** — `agents/*/AGENT.md`
- **Hooks** — `hooks/hooks.json`
- **Commands** — `commands/*.md`

## Editing marketplace.json

`.claude-plugin/marketplace.json` is the marketplace manifest. Each plugin entry must be an object with at least `name`, `source`, and `description`. Use `category` and `tags` for classification.

String-only entries (bare paths) are not valid — always use the object format.

## Validation

After any change to a plugin or to `marketplace.json`, run:

```claude
/plugin validate .
```

This is a strict requirement. No change is complete until validation passes.

## Architecture

This is a static marketplace — no build steps, no CI runner, no test framework. Plugins are collections of markdown, JSON, and templates. When adding or changing a plugin, update both the plugin's own files and the marketplace manifest.
