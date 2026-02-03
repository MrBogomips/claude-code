---
name: devcontainer-generator
description: Generate production-ready devcontainer configurations by analyzing repository tech stack. Detects languages, frameworks, package managers, and services to create a complete .devcontainer setup with Docker Compose, shell configurations, and optional developer tools like Claude Code.
user_invocable: true
---

# Devcontainer Generator

Generate a production-ready `.devcontainer` setup for any repository by analyzing its tech stack and asking about optional integrations.

## Workflow

This skill operates in three phases:

### Phase 1: Repository Analysis

Analyze the repository to detect the tech stack. Check both the root directory and subdirectories (for monorepo support).

**Monorepo Indicators:**
Look for these files at the root:
- `pnpm-workspace.yaml` - pnpm workspaces
- `lerna.json` - Lerna monorepo
- `nx.json` - Nx workspace
- `turbo.json` - Turborepo

And these directories:
- `apps/` - Application packages
- `packages/` - Library packages
- `services/` - Service packages

**Language Runtimes:**
Detect by presence of:
- `package.json` → Node.js (check `engines.node` for version)
- `*.csproj`, `*.sln`, `global.json` → .NET (check `global.json` for SDK version)
- `requirements.txt`, `pyproject.toml`, `setup.py` → Python
- `go.mod` → Go
- `Cargo.toml` → Rust
- `pom.xml`, `build.gradle`, `build.gradle.kts` → Java

**Package Managers:**
- `pnpm-lock.yaml` → pnpm
- `yarn.lock` → Yarn
- `package-lock.json` → npm
- `bun.lockb` → Bun

**Frameworks:**
- `angular.json` → Angular (check version in package.json)
- `next.config.js`, `next.config.mjs`, `next.config.ts` → Next.js
- `nuxt.config.js`, `nuxt.config.ts` → Nuxt
- `vite.config.*` → Vite
- `docusaurus.config.js` → Docusaurus
- `.storybook/` → Storybook

**Services (from docker-compose.yml, environment variables, or connection strings):**
- PostgreSQL (port 5432)
- MySQL (port 3306)
- MongoDB (port 27017)
- Redis (port 6379)
- RabbitMQ (ports 5672, 15672)
- Kafka (port 9092)

**Cloud Providers:**
- `azure-pipelines.yml`, `azuredeploy.json`, Bicep files → Azure
- `serverless.yml` with AWS, `aws-cdk.*` → AWS
- `app.yaml` (GCP), `cloudbuild.yaml` → GCP

### Phase 2: User Questions

After analysis, ask the user about their preferences using the AskUserQuestion tool.

**Q1: Developer Tools** (multiSelect: true)
Present detected tools and optional extras. Default selections marked with checkmarks:
- Claude Code (with ~/.claude mount) - Selected by default
- ccyolo alias (claude --dangerously-skip-permissions) - Selected by default
- GitHub CLI (gh) - Selected by default
- fzf (fuzzy finder)

**Q2: Shell Preference** (multiSelect: false)
- Zsh with Oh My Zsh (Recommended)
- Fish
- Bash

**Q3: Detected Services** (only if services were detected, multiSelect: true)
Show detected services and ask which to include:
- [Each detected database]
- [Each detected message queue]
- Storage emulators (Azurite for Azure, LocalStack for AWS) - if cloud provider detected

### Phase 3: Generate Files

Use the templates in `references/templates/` and configurations in `references/configs/` to generate the devcontainer files.

**Files to Generate:**

1. `.devcontainer/devcontainer.json`
   - Use template: `references/templates/devcontainer.json.tmpl`
   - Replace `{{PROJECT_NAME}}` with directory name (kebab-case)
   - Replace `{{WORKSPACE_FOLDER}}` with `/workspaces/{{PROJECT_NAME}}`
   - Add/remove features based on detected stack
   - Configure VS Code extensions for detected languages/frameworks
   - Set up port forwarding based on detected frameworks and services
   - Add telemetry opt-out environment variables

2. `.devcontainer/Dockerfile`
   - Use template: `references/templates/Dockerfile.tmpl`
   - Select appropriate base image for primary language
   - Include runtime installations for detected languages
   - Add framework-specific tooling (Angular CLI, etc.)
   - Use Ubuntu Noble package names (e.g., `libasound2t64`)

3. `.devcontainer/docker-compose.yml`
   - Use template: `references/templates/docker-compose.yml.tmpl`
   - Replace volume names with `devcontainer-{{PROJECT_NAME}}-*` prefix
   - Add service definitions for each selected service
   - Include health checks for all services
   - Configure proper environment variables

4. `.devcontainer/scripts/post-create.sh`
   - Use template: `references/templates/post-create.sh.tmpl`
   - Include Claude Code installation if selected
   - Add ccyolo alias if selected
   - Configure selected shell
   - Install language-specific tools

5. `.devcontainer/firewall-rules.conf`
   - Use config: `references/configs/firewall-rules.conf`
   - Include domain patterns for detected package registries
   - Add cloud provider endpoints if detected

6. Shell configuration (based on selection):
   - Zsh: `.devcontainer/config/.zshrc` from `references/configs/zshrc.tmpl`
   - Fish: `.devcontainer/config/fish/config.fish` from `references/configs/config.fish.tmpl`

**Template Placeholders:**
- `{{PROJECT_NAME}}` - Project directory name in kebab-case
- `{{WORKSPACE_FOLDER}}` - Full workspace path
- `{{NODE_VERSION}}` - Detected or default Node.js version (22)
- `{{DOTNET_VERSION}}` - Detected or default .NET version (10.0)
- `{{PYTHON_VERSION}}` - Detected or default Python version (3.12)
- `{{PNPM_VERSION}}` - Detected or default pnpm version (9)

## Best Practices

Follow the patterns documented in `references/devcontainer-patterns.md`:
- Use official devcontainer features only
- Name volumes with project prefix to avoid conflicts
- Include health checks for all services
- Opt out of telemetry by default
- Use Ubuntu Noble (24.04) package naming conventions

## References

@references/devcontainer-patterns.md
@references/templates/devcontainer.json.tmpl
@references/templates/Dockerfile.tmpl
@references/templates/docker-compose.yml.tmpl
@references/templates/post-create.sh.tmpl
@references/configs/firewall-rules.conf
@references/configs/zshrc.tmpl
@references/configs/config.fish.tmpl
