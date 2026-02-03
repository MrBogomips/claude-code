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

2. **Asks about your preferences**:
   - Developer tools (Claude Code, ccyolo alias, GitHub CLI, fzf)
   - Shell preference (Zsh with Oh My Zsh, Fish, Bash)
   - Which detected services to include

3. **Generates a complete `.devcontainer` setup**:
   - `devcontainer.json` with features and VS Code extensions
   - `Dockerfile` with multi-runtime support
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

## Default Integrations

The following are **enabled by default** when generating:

- **Claude Code** - Mounts `~/.claude` for configuration persistence
- **ccyolo alias** - Quick access to `claude --dangerously-skip-permissions`
- **GitHub CLI (gh)** - For GitHub operations

## Supported Tech Stacks

### Languages & Runtimes
| Detection File | Runtime |
|---------------|---------|
| `package.json` | Node.js |
| `*.csproj`, `*.sln` | .NET |
| `requirements.txt`, `pyproject.toml` | Python |
| `go.mod` | Go |
| `Cargo.toml` | Rust |
| `pom.xml`, `build.gradle` | Java |

### Package Managers
| Lock File | Manager |
|-----------|---------|
| `pnpm-lock.yaml` | pnpm |
| `yarn.lock` | Yarn |
| `package-lock.json` | npm |
| `bun.lockb` | Bun |

### Frameworks
| Config File | Framework |
|-------------|-----------|
| `angular.json` | Angular |
| `next.config.*` | Next.js |
| `nuxt.config.*` | Nuxt |
| `vite.config.*` | Vite |
| `docusaurus.config.js` | Docusaurus |
| `.storybook/` | Storybook |

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

- **Official features only** - Uses `ghcr.io/devcontainers/features/`
- **Named volumes** - Project-prefixed to avoid conflicts
- **Health checks** - All services include proper health checks
- **Telemetry opt-out** - Disabled by default for privacy
- **Ubuntu Noble compatibility** - Uses correct package names (e.g., `libasound2t64`)

## Customization

After generation, you can customize the files:

1. **Add more VS Code extensions** in `devcontainer.json`
2. **Modify Dockerfile** to add additional tools
3. **Configure services** in `docker-compose.yml`
4. **Add shell aliases** in `config/.zshrc` or `config/fish/config.fish`

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
