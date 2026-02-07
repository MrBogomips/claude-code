---
sidebar_position: 6
sidebar_label: Claude Code Integration
title: Claude Code Integration
---

# Claude Code Integration

The generator supports two levels of agentic coding assistant integration.

## Claude Code

The recommended option. Installs Claude Code via the official installer script and adds the `ccyolo` alias.

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

## The `ccyolo` alias

When Claude Code is selected, the generator adds the following alias to both `.bashrc` and `.zshrc`:

```bash
alias ccyolo="claude --dangerously-skip-permissions"
```

This runs Claude Code with all permission prompts disabled. Use it when you trust the task and want uninterrupted execution. The name is intentional -- it signals that you are bypassing safety checks.

## Claude-Only minimal mode

For empty folders or when you only need Claude Code without a full development environment, select "Claude Code execution only (minimal container)" during the interactive setup (Phase 1b, Step 0).

### What gets generated

The minimal mode uses the same file structure as full mode (`Dockerfile`, `docker-compose.yml`, `devcontainer.json`, `post-create.sh`) but with the `mcr.microsoft.com/devcontainers/base:ubuntu` image, no database services, and fewer activated placeholders. Includes the `common-utils`, `git`, and `node` features.

Additional files:

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
