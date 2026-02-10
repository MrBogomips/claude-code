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

## Docusaurus documentation site

The repository includes a Docusaurus documentation site under `docsite/` that serves content from `docs/`. When modifying a plugin, check whether corresponding documentation exists in `docs/` and update it to stay in sync.

After any documentation change, verify the Docusaurus site renders correctly:

```bash
cd docsite && npm run build
```

Key documentation locations:
- `docs/devcontainer-generator/` — user-facing documentation served at `/claude-code/devcontainer-generator/`
- `plugins/devcontainer-generator/docs/` — plugin-internal documentation (may overlap with the above; keep both in sync)
