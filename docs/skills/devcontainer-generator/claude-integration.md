---
sidebar_position: 6
sidebar_label: Claude Code Integration
title: Claude Code Integration
---

# Claude Code Integration

The generator supports three levels of agentic coding assistant integration.

## Claude Code with CCometixLine

The recommended option. This installs Claude Code and adds [CCometixLine](https://www.npmjs.com/package/@cometix/ccline) for an enhanced statusline.

**What gets installed:**

1. Claude Code via the official installer script (`curl -fsSL https://claude.ai/install.sh | bash`)
2. CCometixLine via npm (`npm install -g @cometix/ccline`)
3. Claude Code settings.json with statusline configuration:

```json
{
  "statusLine": {
    "type": "command",
    "command": "~/.claude/ccline/ccline",
    "padding": 0
  }
}
```

The settings file is only created if `~/.claude/settings.json` does not already exist. If it does, a log message tells you to configure CCometixLine manually.

## Claude Code only

Installs Claude Code without the statusline. Same installer script, same bind mount, same `ccyolo` alias -- just no CCometixLine.

## Other agentic coders

If you select "Other agentic coder", the generator adds a commented-out customization section in `post-create.sh` with installation examples:

```bash
# Aider (https://aider.chat):
# pip install aider-chat

# Continue (VS Code extension):
# code --install-extension Continue.continue

# Cline/Roo Code (VS Code extension):
# code --install-extension saoudrizwan.claude-dev
```

Uncomment and modify as needed.

## The `.claude` bind mount

When Claude Code is selected (either option), the generator adds a bind mount from `~/.claude` on your host to `/home/vscode/.claude` inside the container:

```json
"mounts": [
  "source=${localEnv:HOME}/.claude,target=/home/vscode/.claude,type=bind,consistency=cached"
]
```

This means the following persist across container rebuilds:

- API keys and authentication tokens
- Claude Code settings (`settings.json`)
- Conversation history
- Installed plugins and plugin settings

The directory must exist on your host before starting the container. If it does not exist, Docker will create it as a root-owned directory, which may cause permission issues.

## The `ccyolo` alias

When Claude Code is selected, the generator adds the following alias to both `.bashrc` and `.zshrc`:

```bash
alias ccyolo="claude --dangerously-skip-permissions"
```

This runs Claude Code with all permission prompts disabled. Use it when you trust the task and want uninterrupted execution. The name is intentional -- it signals that you are bypassing safety checks.

## Claude-Only minimal mode

For empty folders or when you only need Claude Code without a full development environment, select "Claude Code execution only (minimal container)" during the interactive setup (Phase 1b, Step 0).

### What gets generated

The minimal mode produces a simpler set of files:

- **devcontainer.json** -- uses `mcr.microsoft.com/devcontainers/base:ubuntu` directly (no Dockerfile or docker-compose.yml). Includes the `common-utils`, `git`, and `node` features.
- **post-create.sh** -- installs firewall prerequisites, Git configuration, Claude Code, shell aliases, and runs environment verification.
- **firewall-rules.conf** -- same default whitelist as the full mode.
- **scripts/apply-firewall.sh** -- same firewall script as the full mode.

The firewall is enabled by default in Claude-Only mode with the deny-all policy.

### How to build and attach

```bash
# Build and start
devcontainer up --workspace-folder .

# Attach via terminal
devcontainer exec --workspace-folder . /bin/zsh

# Or in VS Code: Command Palette > "Dev Containers: Attach to Running Container"
```

### Environment verification output

After the post-create script runs, you see output like:

```
=== my-project Claude Code Environment ===

Claude Code: 1.x.x
Git: git version 2.x.x
Node.js: v22.x.x

============================================

To start using Claude Code:
  claude

Or with skip permissions:
  ccyolo
```

See [Network Firewall](firewall.md) for firewall details and [Customization](customization.md) for how to extend the minimal container.
