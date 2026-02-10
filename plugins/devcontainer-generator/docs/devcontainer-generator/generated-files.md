# Generated Files

The Devcontainer Generator produces the following file structure:

```
.devcontainer/
  devcontainer.json
  Dockerfile
  docker-compose.yml
  firewall-rules.conf
  scripts/
    post-create.sh
    apply-firewall.sh
  DEVCONTAINER.md
```

## File descriptions

### devcontainer.json

The main configuration file for the dev container. It specifies:

- The Docker Compose file and service to connect to
- VS Code extensions to install automatically
- Editor settings (formatter, linting, font ligatures)
- Forwarded ports with labels
- Devcontainer features (common-utils, git, GitHub CLI, docker-outside-of-docker)
- The post-create and post-start commands
- Container capabilities (`NET_ADMIN` for firewall support)

### Dockerfile

A custom Dockerfile based on `mcr.microsoft.com/devcontainers/base:ubuntu-24.04`. Languages are installed via devcontainer features rather than language-specific base images — this gives you a stable Ubuntu LTS foundation with explicit control over language versions. The Dockerfile includes:

- System packages for service client tools (e.g., `postgresql-client`, `redis-tools`)
- Firewall prerequisites (`iptables`, `ip6tables`, `dnsutils`)
- Runtime layers for secondary stacks (when multiple languages are selected)
- Git LFS support (if enabled)

The Dockerfile is always generated, even for simple single-stack projects, to provide a customization point.

### docker-compose.yml

Orchestrates all containers in the development environment:

- The application container (built from the Dockerfile)
- Infrastructure service containers (databases, message brokers, emulators)
- Named volumes for persistent data and package caches
- Connection string environment variables
- Health checks and dependency ordering
- `NET_ADMIN` capability for the application container

### post-create.sh

Runs once after the container is created. It handles:

- Git configuration (credential helper, default branch, aliases)
- Git LFS initialization (if enabled)
- Package dependency installation for your stack
- Agentic coding tool installation (Claude Code, Codex CLI, Gemini)
- Shell aliases for common commands
- Version verification checks
- Service connection summary

### apply-firewall.sh

The firewall enforcement script, copied as-is from the template. It reads `firewall-rules.conf` and applies `iptables`/`ip6tables` rules on every container start. This script runs via `postStartCommand` in `devcontainer.json` and requires `NET_ADMIN` capability.

### firewall-rules.conf

Defines network access control rules using a simple syntax. Contains whitelisted domains for your selected stacks, tools, and package registries. The last line sets the default policy: `DENY *` (deny-all mode) or `ALLOW *` (allow-all mode).

See the [Firewall guide](firewall.md) for details on rule syntax and configuration.

### DEVCONTAINER.md

A generated summary document included in your `.devcontainer/` directory. It contains:

- **Configuration summary** -- selected stacks, services, and tools at a glance
- **Service credentials** -- usernames, passwords, and connection strings for each service
- **Host binding guidance** -- per-framework instructions for binding dev servers to `0.0.0.0` so they are reachable from the host machine
- **MCP server configuration** -- install commands and `.mcp.json` examples for selected MCP servers (if applicable)
- **Customization instructions** -- how to add extensions, packages, services, and adjust firewall rules after generation
