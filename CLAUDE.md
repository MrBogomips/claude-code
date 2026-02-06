# CLAUDE.md

Guidance for working in this Claude Code plugin marketplace repository.

## Editing marketplace.json

`.claude-plugin/marketplace.json` is the marketplace manifest. Edit it directly when adding, removing, or modifying plugins. Each entry must be an object with these required fields:

```json
{
  "name": "plugin-name",
  "source": "./plugins/plugin-name",
  "description": "What the plugin does"
}
```

String-only entries (bare paths) are not valid — always use the object format.

## Plugin structure conventions

Every plugin lives under `plugins/<name>/` and must contain `.claude-plugin/plugin.json`. Components are discovered by convention:

- **Agents** — subdirectories of `agents/`, each containing an `AGENT.md`
- **Skills** — subdirectories of `skills/`, each containing a `SKILL.md`
- **Hooks** — a `hooks/hooks.json` file
- **Commands** — `*.md` files in `commands/`

## Validation

After any change to a plugin or to `marketplace.json`, run:

```claude
/plugin validate .
```

This is a strict requirement. No change is complete until validation passes.

## Architecture

This is a static marketplace — no build steps, no CI, no test runner. Plugins are collections of markdown, JSON, and templates managed by hand. When adding or changing a plugin, update both the plugin's own files and the marketplace manifest.
