---
sidebar_position: 4
sidebar_label: Generated Files
title: Generated Files Reference
---

# Generated Files Reference

The generator produces the following directory structure inside `.devcontainer/`:

```
.devcontainer/
  devcontainer.json
  Dockerfile
  docker-compose.yml
  firewall-rules.conf          # if firewall enabled
  scripts/
    post-create.sh
    apply-firewall.sh           # if firewall enabled
  config/
    .zshrc                      # if Zsh selected
    fish/
      config.fish               # if Fish selected
```

## devcontainer.json

The main configuration file that ties everything together.

**Key sections:**

- **`dockerComposeFile`** -- points to `docker-compose.yml`
- **`service`** -- `devcontainer` (the main service)
- **`workspaceFolder`** -- `/workspaces/{{PROJECT_NAME}}`
- **`postCreateCommand`** -- runs `post-create.sh` once after container creation
- **`postStartCommand`** -- runs `apply-firewall.sh` on every container start (if firewall enabled)
- **`capAdd`** -- `["NET_ADMIN"]` (if firewall enabled)
- **`features`** -- official devcontainer features (`common-utils`, `git`, `docker-outside-of-docker`, optionally `azure-cli`, `github-cli`)
- **`customizations.vscode.extensions`** -- VS Code extensions matched to detected stack
- **`customizations.vscode.settings`** -- editor settings (format on save, tab size, default terminal)
- **`forwardPorts`** -- port forwarding for detected frameworks and services
- **`portsAttributes`** -- labels and auto-forward behavior per port
- **`containerEnv`** -- telemetry opt-out variables and development mode flags
- **`mounts`** -- bind mount for `~/.claude` (if Claude Code selected)
- **`remoteUser`** -- `vscode`

### Port forwarding defaults

| Framework/Service | Port | Auto-forward |
|-------------------|------|-------------|
| Next.js | 3000 | notify |
| Angular | 4200 | notify |
| Vite | 5173 | notify |
| Storybook | 6006 | notify |
| .NET API | 5000-5001 | notify |
| PostgreSQL | 5432 | silent |
| RabbitMQ | 5672, 15672 | silent |
| Redis | 6379 | silent |
| MongoDB | 27017 | silent |
| Azurite | 10000-10002 | silent |

### Telemetry opt-out

The following environment variables are set by default:

```json
{
  "DOTNET_CLI_TELEMETRY_OPTOUT": "1",
  "NEXT_TELEMETRY_DISABLED": "1",
  "NG_CLI_ANALYTICS": "false",
  "GATSBY_TELEMETRY_DISABLED": "1",
  "NUXT_TELEMETRY_DISABLED": "1",
  "HOMEBREW_NO_ANALYTICS": "1"
}
```

## Dockerfile

A multi-section Dockerfile that always uses a Microsoft devcontainer base image.

**Base image selection:**

| Primary stack | Base image |
|--------------|------------|
| .NET | `mcr.microsoft.com/devcontainers/dotnet:{{DOTNET_VERSION}}` |
| Node.js | `mcr.microsoft.com/devcontainers/javascript-node:{{NODE_VERSION}}` |
| Python | `mcr.microsoft.com/devcontainers/python:{{PYTHON_VERSION}}` |
| Go | `mcr.microsoft.com/devcontainers/go:latest` |
| Rust | `mcr.microsoft.com/devcontainers/rust:latest` |
| Multi-stack / Unknown | `mcr.microsoft.com/devcontainers/universal:2` |

**Sections in order:**

1. Base image selection
2. System dependencies (`apt-get install` -- build-essential, curl, shells, optionally iptables/dnsutils)
3. Node.js installation (if detected as secondary runtime)
4. Package manager installation (pnpm, yarn)
5. Framework CLI installation (Angular CLI)
6. Python/Go/Rust installation (if secondary)
7. Copy configuration files and scripts
8. Set default shell

The Dockerfile uses Ubuntu Noble (24.04) package names where they differ from earlier releases (for example, `libasound2t64` instead of `libasound2`).

## docker-compose.yml

Defines the main `devcontainer` service and any infrastructure services you selected.

**Main service features:**

- Workspace volume mount: `..:/workspaces/{{PROJECT_NAME}}:cached`
- Optional `~/.claude` bind mount for Claude Code
- Named volumes for package manager caches (NuGet, pnpm, npm, yarn)
- Connection string environment variables for each selected service
- `depends_on` for selected services
- `cap_add: [NET_ADMIN]` if firewall enabled
- `command: sleep infinity` to keep the container running

**Volume naming convention:**
All named volumes follow the pattern `devcontainer-{{PROJECT_NAME}}-<purpose>`. This avoids collisions when running multiple devcontainers on the same Docker host.

See [Docker Compose Services](services.md) for per-service configuration details.

## post-create.sh

A lifecycle script that runs once when the container is first created (`postCreateCommand`). Sections execute in this order:

1. **Firewall prerequisites** -- installs `iptables` and `dnsutils` via apt (if firewall enabled)
2. **Git configuration** -- credential helper, autocrlf, default branch, color, pull/push behavior
3. **Shell configuration** -- copies `.zshrc` or `config.fish` to home directory
4. **PATH setup** -- ensures `~/.local/bin` is in PATH, optionally adds `~/.dotnet/tools`
5. **Claude Code installation** -- installs Claude Code and optionally CCometixLine (see [Claude Code Integration](claude-integration.md))
6. **Agentic coder customization** -- commented-out examples for Aider, Continue, Cline/Roo Code
7. **.NET tools** -- installs `dotnet-ef` and `dotnet-outdated-tool` (if .NET detected)
8. **Development certificates** -- `dotnet dev-certs https --trust` (if .NET detected)
9. **Node.js packages** -- runs the selected package manager's install command
10. **Python virtual environment** -- creates `.venv` and installs from `requirements.txt`
11. **Developer tools** -- fzf, httpie (if selected)
12. **Aliases** -- development, git, docker, language-specific, and `ccyolo` aliases
13. **Workspace setup** -- creates common directories (`~/.cache`, `~/.config`)
14. **Environment verification** -- prints installed versions summary

## firewall-rules.conf

A text file listing network rules in `ACTION TARGET` format. See [Network Firewall](firewall.md) for the full syntax reference, default whitelist, and practical examples.

## apply-firewall.sh

A bash script that reads `firewall-rules.conf` and applies iptables/ip6tables rules. It runs on every container start via `postStartCommand`. See [Network Firewall](firewall.md) for a technical deep-dive.

## Shell configurations

### Zsh (`.devcontainer/config/.zshrc`)

- Oh My Zsh with `robbyrussell` theme
- Plugins: `git`, `docker`, `docker-compose`, plus stack-specific plugins (`npm`, `node`, `dotnet`)
- History: 10,000 entries, deduplication, shared across sessions
- Emacs key bindings with history search
- Case-insensitive completion
- Auto-cd, auto-pushd
- fzf integration (if installed)
- Environment variables: `EDITOR`, `VISUAL`, `LANG`, `LC_ALL`
- Development aliases (navigation, git, docker, language-specific)
- Loads `~/.zshrc.local` if present (for local overrides that survive regeneration)

### Fish (`.devcontainer/config/fish/config.fish`)

- Custom greeting showing container name and runtime versions
- Environment variables: `EDITOR`, `VISUAL`, `LANG`, `LC_ALL`
- fzf configuration
- Same alias set as Zsh
- Loads `~/.config/fish/config.local.fish` if present (for local overrides)

See [Customization](customization.md) for details on local override files.
