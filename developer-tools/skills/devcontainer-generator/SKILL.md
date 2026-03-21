---
name: devcontainer-generator
description: Generate devcontainer setups by scanning CWD for tech stack and infra services. Triggers on devcontainer, dev container, devcontainer.json, development container, containerized development, VS Code Remote Containers, GitHub Codespaces. Produces devcontainer.json, Dockerfile, Docker Compose, post-create scripts, firewall rules, and DEVCONTAINER.md summary. Uses an 11-step interactive workflow (Steps 0–9 with Step 1b for host credential sharing).
user-invokable: true
context: fork
disable-model-invocation: true
allowed-tools: Read, Write, Glob, Grep, WebFetch, WebSearch, AskUserQuestion
---

# Devcontainer Generator

Generate a production-ready `.devcontainer` setup for any repository through an 11-step interactive workflow (Steps 0–9 with Step 1b). The skill scans the CWD, proposes smart defaults, and lets the user confirm or adjust at each step.

## Design Principles

- **Firewall always deployed**: `apply-firewall.sh` and `firewall-rules.conf` are always generated. When user doesn't want restrictions, the default policy is `ALLOW *`.
- **Prepopulated choices**: Each step comes with reasonable defaults pre-selected based on detection.
- **Every step = multiple choices + open option**: All steps use `AskUserQuestion(multiSelect: true)` with pre-selected defaults. The built-in "Other" escape allows user additions.
- **Host reachability**: Dev servers must bind to `0.0.0.0` not `localhost`/`127.0.0.1`. Generated configs and DEVCONTAINER.md include per-framework guidance.
- **Lean interaction**: Propose smart defaults, let user confirm or adjust, never ask for information you can detect.

## Workflow

### Step 0: Preflight Discovery

**Automatic — no user interaction.**

1. Parse `$ARGUMENTS` for explicit requests (e.g., "Next.js with PostgreSQL", "no firewall", "Claude Code only"). Use any explicit requests to pre-select options in subsequent steps.

2. Scan CWD for tech stack:
   - **Languages**: `package.json` → Node.js, `*.csproj`/`*.sln`/`global.json` → .NET, `requirements.txt`/`pyproject.toml`/`setup.py`/`Pipfile` → Python, `go.mod` → Go, `Cargo.toml` → Rust, `pom.xml`/`build.gradle`/`build.gradle.kts` → Java
   - **Frameworks**: `angular.json` → Angular, `next.config.*` → Next.js, `nuxt.config.*` → Nuxt, `vite.config.*` → Vite, `docusaurus.config.js` → Docusaurus, `.storybook/` → Storybook, `remix.config.*` → Remix
   - **Package managers**: `pnpm-lock.yaml` → pnpm, `yarn.lock` → Yarn, `package-lock.json` → npm, `bun.lockb` → Bun
   - **Monorepo indicators**: `pnpm-workspace.yaml`, `nx.json`, `turbo.json`, `lerna.json`, `apps/`, `packages/`, `services/`
   - **Versions**: Check `engines.node` in package.json, `sdk.version` in global.json, Python version in pyproject.toml

3. Scan for services:
   - Existing `docker-compose.yml` — parse service names and images
   - Environment variables or connection strings referencing databases/brokers
   - Cloud provider files: `azure-pipelines.yml`, `azuredeploy.json`, Bicep → Azure; `serverless.yml`, `aws-cdk.*` → AWS

4. Detect Git LFS: check `.gitattributes` for `filter=lfs` patterns

5. Check for existing `.devcontainer/` directory

6. If nothing detected and no arguments: proceed with empty state (all options unselected in subsequent steps)

### Step 1: Tech Stack

Present detected stacks as pre-selected options. If nothing detected, present all options unselected.

**Options** `AskUserQuestion(multiSelect: true)` (pre-select based on detection):
[ ] Node.js {latest or detected version} (+ detected framework if any, e.g., "Node.js 22 + Next.js")
[ ] Python {latest or detected version} (+ detected framework)
[ ] .NET {latest or detected version} (+ detected framework)
[ ] Go {latest or detected version}
[ ] Rust {latest or detected version}
[ ] Java {latest or detected version} (+ detected framework)
[ ] Other: ________ (free text input)

User can type additional technologies via "Other".

**After response**: For each selected stack, load `@references/stacks/{name}.md` and extract base image, extensions, features, aliases, firewall domains, and host binding guidance.

If multiple stacks selected, use the first one as the primary (its devcontainer feature is installed first). Additional stacks are layered in the Dockerfile.

### Step 1b: Host Credential Sharing

**Conditional — only shown if at least one stack was selected in Step 1.** If no stacks selected, skip to Step 2.

Present credential files relevant to the selected stacks. Options are dynamically filtered — only credential files for selected stacks are shown.

**Options** `AskUserQuestion(multiSelect: true)` (pre-select based on stack selection):

**Node.js credentials** (shown if Node.js selected):
[ ] ~/.npmrc — NPM auth tokens for private registries (pre-selected)
[ ] ~/.yarnrc.yml — Yarn Berry private registry auth (pre-selected if Yarn Berry detected)

**Python credentials** (shown if Python selected):
[ ] ~/.pip/pip.conf — Private PyPI index configuration (pre-selected)
[ ] ~/.pypirc — PyPI publishing credentials (not pre-selected, optional)

**Java credentials** (shown if Java selected):
[ ] ~/.m2/settings.xml — Maven server credentials (pre-selected if Maven detected)
[ ] ~/.gradle/gradle.properties — Gradle repository credentials (pre-selected if Gradle detected)

**.NET credentials** (shown if .NET selected):
[ ] ~/.nuget/NuGet.Config — NuGet private feed credentials (pre-selected)

**Go credentials** (shown if Go selected):
[ ] ~/.netrc — Private Go module credentials (pre-selected)
[ ] GOPRIVATE / GONOSUMCHECK env vars — Private module path prefixes (pre-selected)

**Rust credentials** (shown if Rust selected):
[ ] ~/.cargo/credentials.toml — Cargo registry auth tokens (pre-selected)

[ ] Other: ________ (free text — user specifies host path, mount target, and extraction strategy)

**After response**: For each selected credential file, load the `## Credential Files` section from the corresponding `@references/stacks/{name}.md` reference file and extract mount spec, initializeCommand, extraction script, and DEVCONTAINER.md block.

**Multi-stack handling**: When multiple stacks are selected, the credential options from all stacks are unioned into a single prompt. Duplicate credential files (if any) are shown once.

**Go env vars special case**: `GOPRIVATE` and `GONOSUMCHECK` are not files — they don't need a mount or extraction. They are merged into the existing `{{REMOTE_ENV}}` placeholder in `devcontainer.json` using `"${localEnv:GOPRIVATE}"` syntax.

**If all credentials deselected**: Skip credential generation entirely — no `initializeCommand`, `mounts`, or `{{CREDENTIAL_SETUP}}` content is emitted. The generated files will have no credential-related sections.

### Step 2: Infrastructure Services



Present detected services as pre-selected. Suggest relevant services based on stack.

**Options** `AskUserQuestion(multiSelect: true)` (pre-select based on detection):
[ ] PostgreSQL (with PostGIS) — pre-select if detected or if .NET/.Python selected
[ ] MySQL 8
[ ] MongoDB 7 — pre-select if Node.js selected and detected
[ ] Redis 7 — suggest if any backend stack selected
[ ] RabbitMQ (with Management UI)
[ ] Kafka (with Zookeeper)
[ ] Azurite (Azure Storage Emulator) — pre-select if Azure detected
[ ] LocalStack (AWS Emulator) — pre-select if AWS detected
[ ] Other: ________ (free text input)

**After response**: For each selected service, load `@references/services/{name}.md` and extract Docker Compose block, connection strings, credentials, volumes, ports, and client tools.

### Step 3: Agentic Coding Tools

**Options** `AskUserQuestion(multiSelect: true)`: 
[ ] Claude Code (default selected) — install with ccyolo alias
[ ] OpenAI Codex CLI
[ ] Gemini Code Assist
[ ] Other: ________ (free text input)

**After response**: For each selected tool, load `@references/agentic-tools/{name}.md` and extract installation commands, aliases, verification, and firewall domains.

### Step 4: Git Configuration

`AskUserQuestion(multiSelect: true)`

**Options** `AskUserQuestion(multiSelect: true)` (pre-select based on detection):
[ ] Git (default, always recommended — pre-selected)
[ ] Git LFS (pre-selected if LFS detected in Step 0)
[ ] Other: ________ (free text input)

Git config includes: credential helper, autocrlf, default branch, push.autoSetupRemote, color, rebase.

If LFS selected: add `git-lfs` to Dockerfile apt install, run `git lfs install` in post-create.sh.

User can type additional version control needs via "Other".

### Step 5: MCP Servers

**Only present this step if an agentic coding tool was selected in Step 3.** Otherwise skip to Step 6.

Before presenting options, perform a `WebSearch` query like "best MCP servers for {detected stack} 2026" to check for newly popular MCP servers. Supplement the static catalog with any fresh recommendations.

Present MCP servers organized by category with stack-aware pre-selections:

**Documentation & Code Context:** `AskUserQuestion(multiSelect: true)`
[ ] Context7 (by Upstash) — up-to-date, version-specific library docs

**Source Control & Project Management:** `AskUserQuestion(multiSelect: true)`
[ ] GitHub MCP (pre-selected if .git detected) — PRs, issues, code search
[ ] Atlassian MCP (Jira + Confluence)
[ ] Linear MCP

**Database** `AskUserQuestion(multiSelect: true)` (pre-select based on Step 2 services):
[ ] PostgreSQL MCP (pre-selected if PostgreSQL chosen in Step 2)
[ ] Redis MCP (pre-selected if Redis chosen in Step 2)
[ ] SQLite MCP

**Design & Browser:** `AskUserQuestion(multiSelect: true)`
[ ] Figma MCP
[ ] Puppeteer MCP
[ ] Playwright MCP

**Code Quality & Monitoring:** `AskUserQuestion(multiSelect: true)`
[ ] Sentry MCP
[ ] Serena MCP

**Search & Web:** `AskUserQuestion(multiSelect: true)`
[ ] Brave Search MCP
[ ] Fetch MCP

**AI & Reasoning:** `AskUserQuestion(multiSelect: true)`
[ ] Memory MCP
[ ] Sequential Thinking MCP

User can type additional MCP servers via "Other".

[ ] Other: ________ (free text input)


**After response**: For each selected MCP server, load `@references/mcp-servers.md` and extract its npm/pip package, configuration, API key requirements, and firewall domains to whitelist.

### Step 6: VS Code Extensions & Features

Propose extensions based on selected stacks (from per-stack reference files):

**Common** `AskUserQuestion(multiSelect: true)`(always pre-selected):
[ ] GitLens, Error Lens, EditorConfig, Path Intellisense

**Stack-specific** `AskUserQuestion(multiSelect: true)`(pre-selected based on Step 1):
[ ] Node.js: ESLint, Prettier, Tailwind CSS
[ ] .NET: C# Dev Kit, C#, .NET Runtime
[ ] Python: Python, Pylance
[ ] Go: Go
[ ] Rust: rust-analyzer, crates
[ ] Java: Java Extension Pack, Spring Boot (if detected), Quarkus (if detected)
[ ] Other: ________ (free text input)

**Service-specific** `AskUserQuestion(multiSelect: true)`(pre-selected based on Step 2):
[ ] PostgreSQL explorer
[ ] MongoDB explorer
[ ] Redis explorer
[ ] RabbitMQ explorer

**Testing** (pre-selected if detected):
[ ] Playwright

**Devcontainer Features** to propose (always pre-selected):
[ ] common-utils, git, github-cli, docker-outside-of-docker
[ ] azure-cli (if Azure detected)

User can type additional extensions/features via "Other".

### Step 7: Firewall Policy



**Options** `AskUserQuestion(multiSelect: false)`:
[x] Deny-all (recommended) — only whitelisted domains accessible, tailored to your selected stack
[ ] Allow-all — no restrictions, `ALLOW *` default policy

**Note**: Firewall scripts are **always deployed** regardless of choice. `ALLOW *` simply means no restrictions are active. User can tighten later by editing `firewall-rules.conf`.

### Step 8: Final Recap & Confirmation

Present a formatted summary of ALL selections:

```
=== Devcontainer Configuration Recap ===

Tech Stack:      {stacks with versions and frameworks}
Services:        {services with ports}
Agentic Tools:   {tools}
MCP Servers:     {servers or "None"}
Git:             {Standard / Standard + LFS}
Credentials:     {files shared, e.g., "~/.npmrc, ~/.m2/settings.xml" or "None"}
VS Code:         {N extensions, N features}
Firewall:        {Deny-all / Allow-all}
Base Image:      {image:tag}

Host Reachability: Dev servers must bind 0.0.0.0 (not localhost)
```

If existing `.devcontainer/` found in Step 0: **warn about overwrite**.

`AskUserQuestion(multiSelect: false)`:
- Generate files — proceed to generation
- Let me adjust something — ask which step to revisit, re-run that step, return to recap
- Start over — restart from Step 1

### Step 9: Generate Files

1. Use `mcr.microsoft.com/devcontainers/base:ubuntu-24.04` as the base image for all stacks. Languages are installed via devcontainer features (defined in each stack reference file), not via language-specific base images. This ensures a stable Ubuntu LTS base that cannot be silently rebased by upstream image maintainers. Do NOT use language-specific images (e.g., `javascript-node:22`, `python:3.12`) — they may be rebased on unsupported distributions without notice.

2. **Read templates** from `@references/templates/`:
   - `devcontainer.json.tmpl`
   - `Dockerfile.tmpl`
   - `docker-compose.yml.tmpl`
   - `post-create.sh.tmpl`
   - `apply-firewall.sh.tmpl` (copy as-is)
   - `DEVCONTAINER.md.tmpl`

3. **Read reference data** from loaded stack/service/tool files and **compose** the final content by replacing template placeholders with assembled content blocks.

4. **IMPORTANT — remoteUser**: The `remoteUser` MUST always be `"vscode"`. The `common-utils:2` feature guarantees this user exists regardless of base image. Never use image-specific users (`node`, `python`, etc.) as `remoteUser` — they may not survive feature layering.

5. **CRITICAL — common-utils user settings**: NEVER add `username`, `userUid`, or `userGid` parameters to the `common-utils:2` feature. The template intentionally omits these so common-utils defaults to `"automatic"` user detection, which reuses existing non-root users. Setting explicit UID/GID causes `groupadd` failures. Only include the four template parameters: `installZsh`, `configureZshAsDefaultShell`, `installOhMyZsh`, `upgradePackages`.

6. **Generate these 7 files**:

   **a. `.devcontainer/devcontainer.json`**
   - Replace `{{PROJECT_NAME}}` with CWD directory name (kebab-case)
   - Insert stack-specific extensions into `{{EXTENSIONS}}`
   - Insert stack-specific settings into `{{SETTINGS}}`
   - Insert framework ports into `{{PORTS}}` and `{{PORT_ATTRS}}`
   - Insert telemetry opt-out vars into `{{CONTAINER_ENV}}`
   - Insert additional features into `{{FEATURES}}` (e.g., azure-cli)
   - If credentials selected: insert `initializeCommand` into `{{INITIALIZE_COMMAND}}`
   - If credentials selected: insert `mounts` array into `{{MOUNTS}}`
   - If Go selected with GOPRIVATE: merge into `{{REMOTE_ENV}}` alongside other env vars
   - `postStartCommand` and `capAdd: ["NET_ADMIN"]` are always present in the template

   **b. `.devcontainer/Dockerfile`**
   - Set `{{BASE_IMAGE}}` to the selected official image
   - Insert service client packages into `{{APT_EXTRA}}` (e.g., postgresql-client)
   - Insert runtime layers into `{{RUNTIME_LAYERS}}` for secondary stacks
   - If Git LFS selected: add `git-lfs` to apt install
   - Firewall prerequisites (iptables, dnsutils) are always in the template

   **c. `.devcontainer/docker-compose.yml`**
   - Replace `{{PROJECT_NAME}}` everywhere
   - Insert cache volume mounts into `{{CACHE_VOLUMES}}`
   - Insert service connection strings into `{{ENV_VARS}}`
   - Insert `depends_on` block into `{{DEPENDS_ON}}`
   - Insert service blocks from service reference files into `{{SERVICES}}`
   - Insert named volumes into `{{NAMED_VOLUMES}}`
   - `cap_add: NET_ADMIN` is always present in the template
   - Remove `placeholder:` from volumes if real volumes were added

   **d. `.devcontainer/scripts/post-create.sh`**
   - Replace `{{PROJECT_NAME}}`
   - Insert `git lfs install` into `{{GIT_LFS}}` if selected
   - Insert credential extraction blocks into `{{CREDENTIAL_SETUP}}` — must come BEFORE `{{STACK_SETUP}}` so auth tokens are available for package installs
   - Insert additional PATH entries into `{{PATH_EXTRA}}`
   - Insert tool installation from agentic-tools references into `{{INSTALL_TOOLS}}`
   - Insert stack post-create steps into `{{STACK_SETUP}}`
   - Insert stack-specific and tool aliases into `{{ALIASES_EXTRA}}`
   - Insert version verification checks into `{{VERIFY}}`
   - Insert service summary into `{{SERVICES_SUMMARY}}`

   **e. `.devcontainer/scripts/apply-firewall.sh`**
   - Copy directly from `@references/templates/apply-firewall.sh.tmpl` — no modifications

   **f. `.devcontainer/firewall-rules.conf`**
   - Start from `@references/configs/firewall-rules.conf` as base
   - Add stack-specific firewall domains from each selected stack's reference file
   - Add tool-specific firewall domains from each selected tool's reference file
   - Add MCP server firewall domains from `@references/mcp-servers.md` for each selected server
   - Set default policy: `DENY *` (if deny-all selected) or `ALLOW *` (if allow-all selected)

   **g. `.devcontainer/DEVCONTAINER.md`**
   - Fill in configuration summary table
   - Fill in services table with ports and credentials
   - Fill in host binding guidance per detected framework
   - If MCP servers selected: add MCP configuration section with install commands, `.mcp.json` example, required API keys
   - If credentials selected: insert credential sharing documentation into `{{CREDENTIAL_DOCS}}` with table of host files, container paths, purposes, and fallback env vars
   - Fill in customization instructions

7. After generation, display a summary of what was created and suggest next steps:
   - Open in VS Code / Rebuild container
   - Review firewall rules
   - Check DEVCONTAINER.md for service credentials and host binding

## Template Processing

Templates are clean skeletons with `{{PLACEHOLDER}}` markers. The skill:
1. Reads the template
2. Collects content blocks from per-stack and per-service reference files
3. Replaces each placeholder with the assembled content
4. Writes the final file

No commented-out placeholder blocks in generated output — templates produce readable, active code.

## Best Practices

- Use official devcontainer features from `ghcr.io/devcontainers/features/` only
- Name volumes with `devcontainer-{{PROJECT_NAME}}-*` prefix to avoid conflicts
- Include health checks for all services (from service reference files)
- Opt out of telemetry by default
- Use Ubuntu Noble (24.04) package naming conventions (e.g., `libasound2t64`)
- Always generate Dockerfile even for simple stacks (ensures customization point)
- Always use `mcr.microsoft.com/devcontainers/base:ubuntu-24.04` as base image; install languages via devcontainer features
- For multi-stack projects, install the primary stack's feature first, then layer additional features
- Never override `common-utils:2` user identity fields (`username`, `userUid`, `userGid`) — automatic detection prevents UID/GID conflicts across all base images

## References

@references/stacks/nodejs.md
@references/stacks/python.md
@references/stacks/dotnet.md
@references/stacks/go.md
@references/stacks/rust.md
@references/stacks/java.md
@references/services/postgresql.md
@references/services/mysql.md
@references/services/mongodb.md
@references/services/redis.md
@references/services/rabbitmq.md
@references/services/kafka.md
@references/services/azurite.md
@references/services/localstack.md
@references/agentic-tools/claude-code.md
@references/agentic-tools/openai-codex.md
@references/agentic-tools/gemini-code-assist.md
@references/mcp-servers.md
@references/templates/devcontainer.json.tmpl
@references/templates/Dockerfile.tmpl
@references/templates/docker-compose.yml.tmpl
@references/templates/post-create.sh.tmpl
@references/templates/apply-firewall.sh.tmpl
@references/templates/DEVCONTAINER.md.tmpl
@references/configs/firewall-rules.conf
