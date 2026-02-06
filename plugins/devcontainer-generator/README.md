# Devcontainer Generator

A Claude Code plugin that generates production-ready devcontainer configurations by analyzing your repository's tech stack.

## What It Does

This skill automatically:

1. **Analyzes your repository** to detect:
   - Language runtimes (Node.js, .NET, Python, Go, Rust, Java)
   - Package managers (pnpm, yarn, npm, bun)
   - Frameworks (Angular, Next.js, Nuxt, Vite, etc.)
   - Services (PostgreSQL, MySQL, MongoDB, Redis, RabbitMQ, Kafka)
   - Cloud providers (Azure, AWS, GCP)
   - Monorepo structures

2. **Selects official templates** from containers.dev:
   - Fetches current template list dynamically
   - Matches detected stack to official Microsoft templates
   - Supports combo templates (e.g., python-3-postgres)
   - Falls back to Universal template when no match

3. **Asks about your preferences**:
   - Agentic coding assistant (Claude Code with CCometixLine, Claude Code only, or other)
   - Developer tools (GitHub CLI, fzf, httpie)
   - Shell preference (Zsh with Oh My Zsh, Fish, Bash)
   - Which detected services to include

4. **Generates a complete `.devcontainer` setup**:
   - `devcontainer.json` with features and VS Code extensions
   - `Dockerfile` with multi-runtime support (always generated)
   - `docker-compose.yml` with services and health checks
   - `post-create.sh` setup script
   - Shell configurations (Zsh/Fish)
   - Firewall rules for network whitelisting

## Usage

```bash
# Invoke the skill from within your project
claude /devcontainer-generator
```

Or simply ask:

> "Generate a devcontainer for this project"

## Claude-Only Mode

For empty folders or when you just need Claude Code execution without a full development environment:

1. Run `/devcontainer-generator` in an empty folder
2. Select "Claude Code execution only (minimal container)"
3. A lightweight container is generated with just Claude Code

**Attaching to the container:**

```bash
# Build and start the devcontainer
devcontainer up --workspace-folder .

# Attach to the running container
devcontainer exec --workspace-folder . /bin/zsh

# Or use VS Code: Command Palette → "Dev Containers: Attach to Running Container"
```

## Agentic Coding Integration

### Claude Code with CCometixLine (Recommended)

Full integration with statusline for enhanced visibility:

- Installs Claude Code via official script
- Installs CCometixLine (`npm install -g @cometix/ccline`)
- Configures statusline in `~/.claude/settings.json`
- Adds `ccyolo` alias for quick access

### Claude Code Only

Basic installation without statusline:

- Installs Claude Code via official script
- Mounts `~/.claude` for configuration persistence
- Adds `ccyolo` alias

### Other Agentic Coders

Generate a customization-ready post-create.sh with examples for:

- **Aider**: `pip install aider-chat`
- **Continue**: VS Code extension
- **Cline/Roo Code**: VS Code extension

## Official Template Selection

The skill fetches templates from https://containers.dev/templates and selects the best match:

| Detected Stack        | Selected Template       |
| --------------------- | ----------------------- |
| Python                | `python`                |
| Python + PostgreSQL   | `python-3-postgres`     |
| Node.js               | `javascript-node`       |
| Node.js + MongoDB     | `javascript-node-mongo` |
| TypeScript            | `typescript-node`       |
| .NET                  | `dotnet`                |
| Go                    | `go`                    |
| Rust                  | `rust`                  |
| Java                  | `java`                  |
| Multi-stack / Unknown | `universal`             |

## Supported Tech Stacks

### Languages & Runtimes

| Detection File                       | Runtime |
| ------------------------------------ | ------- |
| `package.json`                       | Node.js |
| `*.csproj`, `*.sln`                  | .NET    |
| `requirements.txt`, `pyproject.toml` | Python  |
| `go.mod`                             | Go      |
| `Cargo.toml`                         | Rust    |
| `pom.xml`, `build.gradle`            | Java    |

### Package Managers

| Lock File           | Manager |
| ------------------- | ------- |
| `pnpm-lock.yaml`    | pnpm    |
| `yarn.lock`         | Yarn    |
| `package-lock.json` | npm     |
| `bun.lockb`         | Bun     |

### Frameworks

| Config File            | Framework  |
| ---------------------- | ---------- |
| `angular.json`         | Angular    |
| `next.config.*`        | Next.js    |
| `nuxt.config.*`        | Nuxt       |
| `vite.config.*`        | Vite       |
| `docusaurus.config.js` | Docusaurus |
| `.storybook/`          | Storybook  |

### Services

- PostgreSQL (with PostGIS)
- MySQL
- MongoDB
- Redis
- RabbitMQ (with Management UI)
- Kafka (with Zookeeper)
- Azurite (Azure Storage Emulator)
- LocalStack (AWS Emulator)

### Monorepo Support

Detects monorepo structures via:

- `pnpm-workspace.yaml`
- `lerna.json`
- `nx.json`
- `turbo.json`
- `apps/`, `packages/`, `services/` directories

## Best Practices Applied

The generated configurations follow these best practices:

- **Official templates** - Prefers Microsoft official templates from containers.dev
- **Official features only** - Uses `ghcr.io/devcontainers/features/`
- **Named volumes** - Project-prefixed to avoid conflicts
- **Health checks** - All services include proper health checks
- **Telemetry opt-out** - Disabled by default for privacy
- **Ubuntu Noble compatibility** - Uses correct package names (e.g., `libasound2t64`)
- **Always generates Dockerfile** - Ensures customization point even for simple stacks

## Customization

After generation, you can customize the files:

1. **Add more VS Code extensions** in `devcontainer.json`
2. **Modify Dockerfile** to add additional tools
3. **Configure services** in `docker-compose.yml`
4. **Add shell aliases** in `config/.zshrc` or `config/fish/config.fish`
5. **Add agentic coder** by editing the customization section in `post-create.sh`

## Installation

Add to your Claude Code plugins directory:

```bash
# Clone the marketplace
git clone https://github.com/MrBogomips/claude-code.git

# Or copy just this plugin
cp -r plugins/devcontainer-generator ~/.claude/plugins/
```

Then configure in your Claude Code settings.

## License

MIT
