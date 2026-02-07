---
name: devcontainer-generator
description: Generate or configure .devcontainer setups by analyzing repository tech stack. Triggers on devcontainer, dev container, devcontainer.json, development container, containerized development environment, VS Code Remote Containers, GitHub Codespaces, Docker-based development setup, reproducible development environment. Produces Dockerfile, Docker Compose, post-create scripts, shell configs, firewall rules, and Claude Code integration. Not for production Docker, CI/CD pipelines, or general Docker questions.
user-invokable: true
context: fork
disable-model-invocation: true
allowed-tools: Read, Write, Glob, Grep, WebFetch, AskUserQuestion
---

# Devcontainer Generator

Generate a production-ready `.devcontainer` setup for any repository by analyzing its tech stack and asking about optional integrations.

## Workflow

This skill operates in three phases:

### Phase 1: Repository Analysis

**Empty Folder Detection:**
First, check if the directory is empty or contains only hidden files (like `.git`):

- If empty/minimal: Skip tech detection and go directly to Phase 1b for interactive setup
- Ask if user wants a "Claude-safe-only" environment or wants to describe their project

**Official Template Fetching:**
Before template selection, fetch the current list of available templates:

1. WebFetch from <https://containers.dev/templates>
2. Parse official templates (Dev Container Spec Maintainers)
3. Parse community templates (Microsoft Azure, research tools, etc.)
4. Cache results for the session

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

**Base Template Selection:**
After detecting tech stack, match to official templates using `references/template-selection-guide.md`:

- Single match → use that template
- Multiple matches → ask user to choose (Microsoft templates first)
- Combo match (language + database) → prefer combo template
- No match → use Universal template

**Existing Configuration:**
If `.devcontainer/` directory already exists, ask the user:

- Overwrite existing configuration (replace all files)
- Merge with existing (preserve customizations where possible)
- Cancel generation

### Phase 1b: Interactive Stack Discovery (Empty/Unknown Projects)

If the repository is empty or no tech stack is detected, engage the user in an interactive discovery process:

**Step 0: Usage Intent**
Ask: "What do you want to use this devcontainer for?"

- Full development environment (Recommended)
- Claude Code execution only (minimal container)

If "Claude Code execution only" selected:

- Use the same templates as full mode (`devcontainer.json.tmpl`, `Dockerfile.tmpl`, `docker-compose.yml.tmpl`, `post-create.sh.tmpl`) with these settings:
  - **Base image**: keep default `mcr.microsoft.com/devcontainers/base:ubuntu`
  - **Dockerfile**: activate only `{{APT_FIREWALL}}` and `{{COPY_FIREWALL}}`
  - **docker-compose.yml**: devcontainer service only, no database services
  - **devcontainer.json**: activate `{{FIREWALL_POST_START}}`, `{{CAP_NET_ADMIN}}`, basic features (common-utils, git, node)
  - **post-create.sh**: activate `{{INSTALL_FIREWALL}}`, `{{INSTALL_CLAUDE}}`, `{{ALIAS_CCYOLO}}`, `{{VERIFY_CLAUDE}}`, `{{CLAUDE_USAGE_HINT}}`
- **Firewall**: enabled by default with deny-all policy
- Generate `firewall-rules.conf` (ALLOW/DENY format) and `scripts/apply-firewall.sh`
- Container gets `CAP_NET_ADMIN` and `postStartCommand` for firewall enforcement
- Provide shell commands to attach:

  ```bash
  # Build and start the devcontainer
  devcontainer up --workspace-folder .

  # Attach to the running container
  devcontainer exec --workspace-folder . /bin/zsh

  # Or use VS Code: Command Palette → "Dev Containers: Attach to Running Container"
  ```

- Skip remaining questions and proceed to file generation

**Step 1: Application Type**
Ask: "What kind of application are you building?"

- Web application (frontend)
- Web API (backend)
- Full-stack application
- CLI tool
- Library/Package
- Other (describe)

**Step 2: Primary Language**
Based on application type, ask: "What primary language will you use?"

- Present relevant options (e.g., for web: TypeScript/JavaScript, Python, Go, .NET, etc.)

**Step 3: Framework Selection**
Based on language, ask: "Which framework do you want to use?"

- Present framework options for the selected language
- Example for TypeScript web: Next.js, Angular, Nuxt, Vite + React, etc.

**Step 4: Package Manager** (if applicable)
Ask: "Which package manager do you prefer?"

- pnpm (Recommended)
- yarn
- npm
- bun

**Step 5: Services**
Ask: "Do you need any backend services?"

- Database (PostgreSQL, MySQL, MongoDB)
- Cache (Redis)
- Message Queue (RabbitMQ, Kafka)
- Storage Emulator (Azurite, LocalStack)
- None

**Step 6: Confirmation**
Present a summary of the configured stack:

```
Configured Stack:
- Application: Full-stack web application
- Language: TypeScript
- Framework: Next.js
- Package Manager: pnpm
- Services: PostgreSQL, Redis
```

Ask: "Does this configuration look correct? Proceed with generation?"

Continue iterating if user requests changes. Once confirmed, proceed to Phase 2.

### Phase 2: User Questions

After analysis, ask the user about their preferences using the AskUserQuestion tool.

**Q1: Agentic Coding Assistant** (multiSelect: false)

- Claude Code (Recommended) - Install with ccyolo alias
- None - I'll configure my own agentic coder
- Other agentic coder - Provide customization guidance

If "Claude Code" selected:

- Add ccyolo alias automatically
- Show what will be installed

If "Other agentic coder" selected:

- Generate post-create.sh with clear customization section for their preferred tool

**Q2: Developer Tools** (multiSelect: true)
Present optional tools. Default selections marked with checkmarks:

- GitHub CLI (gh) - Selected by default
- fzf (fuzzy finder)
- httpie (HTTP client)
- rg (ripgrep for fast searching)

**Q3: Shell Preference** (multiSelect: false)

- Zsh with Oh My Zsh - Recommended
- Fish
- Bash

**Q4: Detected Services** (only if services were detected, multiSelect: true)
Show detected services and ask which to include:

- [Each detected database]
- [Each detected message queue]
- Storage emulators (Azurite for Azure, LocalStack for AWS) - if cloud provider detected

**Q5: Version Confirmation** (only if versions were detected)
Present detected versions and allow override:

- Node.js: {{detected or latest}}
- .NET: {{detected or latest}}
- Python: {{detected or latest}}

Ask: "I detected these runtime versions. Would you like to use them or specify different versions?"

**Q6: Network Firewall** (multiSelect: false)

- Enabled with deny-all policy (Recommended) - Only whitelisted domains accessible, blocks all other traffic
- Enabled with allow-all policy - All traffic allowed, specific domains can be blocked
- Disabled - No network restrictions

If firewall enabled:

- Add `CAP_NET_ADMIN` capability to container
- Generate `firewall-rules.conf` with ALLOW/DENY rules from `references/configs/firewall-rules.conf`
- Generate `scripts/apply-firewall.sh` from `references/templates/apply-firewall.sh.tmpl`
- Add `postStartCommand` to run firewall on every container start
- Uncomment `{{INSTALL_FIREWALL}}`, `{{APT_FIREWALL}}`, `{{COPY_FIREWALL}}`, `{{CAP_ADD_FIREWALL}}`, `{{FIREWALL_POST_START}}`, `{{CAP_NET_ADMIN}}` placeholders
- If deny-all: last rule is `DENY *`
- If allow-all: last rule is `ALLOW *`

Firewall rules format (first match wins):
```
ACTION TARGET
# ACTION: ALLOW or DENY
# TARGET: domain | *.domain | CIDR | IPv4 | IPv6 | * (all)
# Root (uid 0) always exempt. DNS (port 53) always allowed.
```

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
   - If firewall enabled: add `postStartCommand`, `capAdd: ["NET_ADMIN"]`

2. `.devcontainer/Dockerfile`
   - Use template: `references/templates/Dockerfile.tmpl`
   - **Always generate Dockerfile** even for simple scenarios (ensures customization point)
   - Select appropriate base image for primary language
   - Include runtime installations for detected languages
   - For multi-stack projects, layer additional runtimes
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
   - Include Claude Code installation based on Q1 selection:
     - If Claude Code: Install Claude Code
     - If Other: Add customization section with examples
   - Add ccyolo alias if Claude Code selected
   - Configure selected shell
   - Install language-specific tools

5. `.devcontainer/firewall-rules.conf` (if firewall enabled, or Claude-only mode)
   - Use config: `references/configs/firewall-rules.conf`
   - Format: `ACTION TARGET` (ALLOW/DENY syntax, first match wins)
   - Include domain patterns for detected package registries
   - Add cloud provider endpoints if detected
   - Set default policy based on Q6 selection (`DENY *` or `ALLOW *`)

6. `.devcontainer/scripts/apply-firewall.sh` (if firewall enabled, or Claude-only mode)
   - Use template: `references/templates/apply-firewall.sh.tmpl`
   - Runtime enforcement via iptables/ip6tables
   - Root (uid 0) always exempt — system tools (apt-get, systemd) work normally
   - System essentials hardcoded: loopback, established, DNS (port 53), DHCP
   - Runs on every container start via `postStartCommand` (idempotent: flush + recreate)

7. Shell configuration (based on selection):
   - Zsh: `.devcontainer/config/.zshrc` from `references/configs/zshrc.tmpl`
   - Fish: `.devcontainer/config/fish/config.fish` from `references/configs/config.fish.tmpl`

**Template Placeholders:**

- `{{PROJECT_NAME}}` - Project directory name in kebab-case
- `{{WORKSPACE_FOLDER}}` - Full workspace path
- `{{NODE_VERSION}}` - Detected or default Node.js version (22)
- `{{DOTNET_VERSION}}` - Detected or default .NET version (10.0)
- `{{PYTHON_VERSION}}` - Detected or default Python version (3.12)
- `{{PNPM_VERSION}}` - Detected or default pnpm version (9)

**Claude Code Installation Block:**
If Claude Code selected:

1. Install Claude Code via official script
2. Add ccyolo alias to shell config
3. Verify installation in summary output

For Claude-only mode, use the same templates with fewer placeholders activated (see Phase 1b).

**Other Agentic Coder Customization:**
If "Other agentic coder" selected, add this section to post-create.sh:

```bash
# -----------------------------------------------------------------------------
# Agentic Coder Customization
# -----------------------------------------------------------------------------
# Uncomment and modify for your preferred agentic coder:
#
# Aider (https://aider.chat):
# pip install aider-chat
#
# Continue (VS Code extension):
# Code will prompt to install the Continue extension
#
# Cline/Roo Code (VS Code extension):
# Code will prompt to install the Cline extension
#
# Add your custom installation commands here:
#
```

## Best Practices

Follow the patterns documented in `references/devcontainer-patterns.md`:

- Use official devcontainer features only
- Name volumes with project prefix to avoid conflicts
- Include health checks for all services
- Opt out of telemetry by default
- Use Ubuntu Noble (24.04) package naming conventions

## References

@references/devcontainer-patterns.md
@references/template-selection-guide.md
@references/templates/devcontainer.json.tmpl
@references/templates/Dockerfile.tmpl
@references/templates/docker-compose.yml.tmpl
@references/templates/post-create.sh.tmpl
@references/templates/apply-firewall.sh.tmpl
@references/configs/firewall-rules.conf
@references/configs/zshrc.tmpl
@references/configs/config.fish.tmpl
