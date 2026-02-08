---
sidebar_position: 7
title: Generated Files
---

# Generated Files

The devcontainer generator produces 7 files inside `.devcontainer/`. Each file is built from a template skeleton (`references/templates/*.tmpl`) with `{{PLACEHOLDER}}` markers replaced by content assembled from your selected stack, service, and tool reference files.

```
.devcontainer/
├── devcontainer.json         # Container config, extensions, ports, lifecycle
├── Dockerfile                # Base image, system deps, runtime layers
├── docker-compose.yml        # App container + infrastructure services
├── firewall-rules.conf       # Domain allowlist / denylist
├── scripts/
│   ├── post-create.sh        # Git, tools, aliases, deps — runs once after build
│   └── apply-firewall.sh     # iptables enforcement — runs on every start
└── DEVCONTAINER.md           # Human-readable config summary
```

---

## devcontainer.json

The central configuration file read by VS Code Remote Containers and GitHub Codespaces.

### Key Sections

| Section | Purpose |
|---------|---------|
| `dockerComposeFile` / `service` | Points to `docker-compose.yml` and the `devcontainer` service |
| `workspaceFolder` | `/workspaces/{{PROJECT_NAME}}` |
| `postCreateCommand` | Runs `scripts/post-create.sh` once after container build |
| `postStartCommand` | Runs `apply-firewall.sh` on every container start |
| `capAdd: ["NET_ADMIN"]` | Required for firewall (always present) |
| `features` | Devcontainer features: common-utils, git, github-cli, docker-outside-of-docker, plus stack-specific features |
| `customizations.vscode.extensions` | Common + stack-specific + service-specific extensions |
| `customizations.vscode.settings` | Editor defaults (formatOnSave, tabSize, trimWhitespace, zsh shell) |
| `forwardPorts` | Framework and service ports |
| `portsAttributes` | Port labels and auto-forward behavior |
| `containerEnv` | Telemetry opt-out and development mode variables |
| `remoteUser` | `vscode` |

### Template Placeholders

| Placeholder | Source |
|-------------|--------|
| `{{PROJECT_NAME}}` | CWD directory name (kebab-case) |
| `{{FEATURES}}` | Stack-specific devcontainer features (e.g., `azure-cli`) |
| `{{EXTENSIONS}}` | Stack and service VS Code extension IDs |
| `{{SETTINGS}}` | Stack-specific editor settings |
| `{{PORTS}}` | Framework dev ports + service ports |
| `{{PORT_ATTRS}}` | Port labels and auto-forward config |
| `{{CONTAINER_ENV}}` | Telemetry opt-out environment variables |
| `{{REMOTE_ENV}}` | Project-specific environment variables |

### Customization

- **Add extensions**: append extension IDs to the `extensions` array
- **Add features**: add entries to the `features` object (use `ghcr.io/devcontainers/features/` only)
- **Change ports**: modify `forwardPorts` and `portsAttributes`
- **Add environment variables**: add to `containerEnv` or `remoteEnv`

---

## Dockerfile

Defines the container image build. Always generated (even for simple stacks) to provide a customization point.

### Structure

```dockerfile
FROM {{BASE_IMAGE}} AS base

# System dependencies (always included)
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential curl wget gnupg2 ca-certificates lsb-release jq \
    iptables dnsutils \        # Firewall prerequisites (always)
    {{APT_EXTRA}} \            # Stack/service client packages
    && apt-get clean

{{RUNTIME_LAYERS}}             # Additional runtime installations

COPY scripts/ /devcontainer/scripts/
COPY firewall-rules.conf /devcontainer/firewall-rules.conf
RUN chmod +x /devcontainer/scripts/*.sh
```

### Template Placeholders

| Placeholder | Source |
|-------------|--------|
| `{{BASE_IMAGE}}` | Official devcontainer image for the primary stack |
| `{{APT_EXTRA}}` | Service client packages (`postgresql-client`, `mysql-client`, `mongosh`, `redis-tools`, `awscli`) and `git-lfs` if selected |
| `{{RUNTIME_LAYERS}}` | Installation commands for secondary stacks (e.g., Node.js layer on a .NET base) |

### Customization

- **Add system packages**: insert into the `apt-get install` list and rebuild
- **Add runtime layers**: append `RUN` commands after `{{RUNTIME_LAYERS}}`
- **Change base image**: modify the `FROM` line

---

## docker-compose.yml

Defines the app container and all infrastructure services.

### Structure

```yaml
services:
  devcontainer:
    build:
      context: .
      dockerfile: Dockerfile
    volumes:
      - ..:/workspaces/{{PROJECT_NAME}}:cached
      {{CACHE_VOLUMES}}        # Package manager cache mounts
    environment:
      {{ENV_VARS}}             # Connection strings, env vars
    {{DEPENDS_ON}}             # Service dependencies
    cap_add:
      - NET_ADMIN              # Always present (firewall)
    command: sleep infinity

  {{SERVICES}}                 # Infrastructure service blocks

volumes:
  {{NAMED_VOLUMES}}            # Named volumes for data persistence
```

### Template Placeholders

| Placeholder | Source |
|-------------|--------|
| `{{PROJECT_NAME}}` | CWD directory name (kebab-case) |
| `{{CACHE_VOLUMES}}` | Package manager cache volume mounts (e.g., npm, pip, NuGet) |
| `{{ENV_VARS}}` | Service connection strings and environment variables |
| `{{DEPENDS_ON}}` | `depends_on` block listing selected services |
| `{{SERVICES}}` | Full Docker Compose service blocks from service reference files |
| `{{NAMED_VOLUMES}}` | Named volume declarations for all services and caches |

### Customization

- **Add services**: add a new service block with image, ports, volumes, and health check
- **Modify environment**: add connection strings to the `devcontainer` environment
- **Add volumes**: declare under `volumes:` and mount in the relevant service

---

## scripts/post-create.sh

Runs **once** after the container is built (`postCreateCommand`). Sets up the development environment.

### Sections

1. **Git Configuration** — credential helper, autocrlf, default branch, push.autoSetupRemote, color, rebase
2. **Git LFS** — `git lfs install` (if selected)
3. **Path Setup** — ensures `~/.local/bin` is on PATH
4. **Shell Configuration** — Oh My Zsh history, completion, directory navigation, FZF, editor
5. **Agentic Tool Installation** — Claude Code, Codex CLI, Gemini (from tool reference files)
6. **Stack-Specific Setup** — package installation (npm ci, pip install, dotnet restore, etc.)
7. **Aliases** — navigation, project, git, docker aliases + stack-specific + tool-specific aliases
8. **Workspace Setup** — creates `~/.cache` and `~/.config`
9. **Environment Verification** — prints version info for installed tools and services

### Template Placeholders

| Placeholder | Source |
|-------------|--------|
| `{{PROJECT_NAME}}` | CWD directory name |
| `{{GIT_LFS}}` | `git lfs install` if Git LFS selected |
| `{{PATH_EXTRA}}` | Additional PATH entries from stack reference |
| `{{INSTALL_TOOLS}}` | Agentic tool installation blocks |
| `{{STACK_SETUP}}` | Stack post-create steps (package install, tool install) |
| `{{ALIASES_EXTRA}}` | Stack and tool aliases |
| `{{VERIFY}}` | Version check commands for tools and runtimes |
| `{{SERVICES_SUMMARY}}` | Service access info (ports, credentials) |

### Customization

- **Add tools**: append installation commands in the "Agentic Tool Installation" section
- **Add aliases**: append to the `ALIASES` variable or the `{{ALIASES_EXTRA}}` section
- **Add setup steps**: insert commands in the "Stack-Specific Setup" section

---

## scripts/apply-firewall.sh

Copied **as-is** from the template — no placeholder replacement. Runs on **every container start** (`postStartCommand`).

See [Network Firewall](./firewall) for full documentation on how this script works.

### Customization

This file should generally not be modified. To change firewall behavior, edit `firewall-rules.conf` instead.

---

## firewall-rules.conf

The editable rule file read by `apply-firewall.sh`. See [Network Firewall](./firewall) for syntax and customization.

### Assembly

The file is assembled from multiple sources:

1. **Base rules** from `references/configs/firewall-rules.conf` (common domains: GitHub, Docker, CDNs, CAs, etc.)
2. **Stack-specific domains** from each selected stack's reference file
3. **Tool-specific domains** from each selected agentic tool's reference file
4. **MCP server domains** from `references/mcp-servers.md` for each selected server
5. **Default policy** — `DENY *` (deny-all) or `ALLOW *` (allow-all) as the last line

### Customization

Edit directly and re-apply:

```bash
sudo bash /devcontainer/scripts/apply-firewall.sh /devcontainer/firewall-rules.conf
```

---

## DEVCONTAINER.md

A human-readable summary document generated alongside the container configuration. Not used by Docker or VS Code — it's for developers to reference.

### Sections

| Section | Content |
|---------|---------|
| **Configuration Summary** | Stack, services, tools, firewall policy, base image |
| **Generated Files** | Table of all 6 config files with purpose |
| **Services** | Ports, credentials, and health check for each service |
| **Host Reachability** | Per-framework binding guidance (`0.0.0.0`) |
| **MCP Servers** | Configuration and API key requirements (if MCP selected) |
| **Customization** | How to edit firewall rules, add dependencies, add services |
| **Common Operations** | Rebuild, restart, reset volumes, check firewall |

### Customization

This file is informational. Update it when you modify other generated files to keep the documentation in sync.

---

## Common Operations

### Rebuild the container

After modifying `Dockerfile`, `docker-compose.yml`, or `devcontainer.json`:

> VS Code → Command Palette → **Dev Containers: Rebuild Container**

### Restart the container

> VS Code → Command Palette → **Dev Containers: Reopen in Container**

### Reset all volumes (fresh databases, caches)

```bash
docker compose -f .devcontainer/docker-compose.yml down -v
```

### Re-run post-create script

```bash
bash /devcontainer/scripts/post-create.sh
```

### Re-apply firewall rules

```bash
sudo bash /devcontainer/scripts/apply-firewall.sh /devcontainer/firewall-rules.conf
```
