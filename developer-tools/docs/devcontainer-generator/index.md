# Devcontainer Generator

The Devcontainer Generator creates production-ready `.devcontainer` setups for any repository. It scans your project to detect languages, frameworks, services, and monorepo structures, then walks you through a guided workflow to configure everything -- from infrastructure services to firewall rules.

The result is a complete set of container configuration files that work with VS Code Dev Containers, GitHub Codespaces, and any tool that supports the devcontainer specification.

All generated containers are based on Ubuntu 24.04 LTS for long-term stability. Language runtimes are installed via [devcontainer features](https://containers.dev/features), giving you explicit control over versions without depending on upstream image maintainers.

## How to invoke

Run the skill directly:

```
/devcontainer-generator
```

Or use natural language:

> "Generate a devcontainer for this project"
> "Set up a dev container with PostgreSQL and Redis"
> "Create a containerized development environment"

## What gets generated

The skill produces a complete `.devcontainer/` directory:

```
.devcontainer/
  devcontainer.json          # Container configuration and VS Code settings
  Dockerfile                 # Custom image with your stack and tools
  docker-compose.yml         # Multi-service orchestration
  firewall-rules.conf        # Network access control rules
  scripts/
    post-create.sh           # Dependency installation and setup
    apply-firewall.sh        # Firewall enforcement script
  DEVCONTAINER.md            # Summary with credentials, ports, and guidance
```

## Quickstart

1. **Invoke the skill** -- run `/devcontainer-generator` or ask in natural language
2. **Answer the guided questions** -- confirm or adjust detected stacks, services, tools, extensions, and firewall policy
3. **Files are generated** -- the skill writes all configuration files to `.devcontainer/`
4. **Open in VS Code** -- use the Command Palette and select "Dev Containers: Reopen in Container"

## Learn more

- [Supported stacks](stacks.md) -- languages, frameworks, and detection
- [Infrastructure services](services.md) -- databases, message brokers, and cloud emulators
- [Generated files](generated-files.md) -- what each file does
- [Customization](customization.md) -- how to modify the generated setup
- [Firewall](firewall.md) -- network access control
- [Host Credential Sharing](stacks.md#credential-files) -- private registry authentication
- [Agentic tools](agentic-tools.md) -- AI coding assistants and MCP servers
