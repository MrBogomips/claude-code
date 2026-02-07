# Devcontainer Best Practices & Patterns

## Official Template Selection

Always prefer Microsoft official templates from `ghcr.io/devcontainers/templates/`:

**Priority order when multiple stacks detected:**
1. Primary language template (e.g., dotnet for .NET + Node.js project)
2. Universal template as fallback
3. Community templates only when official doesn't exist

**Template + Database combinations:**
When database services are selected, prefer combo templates:
- Python + PostgreSQL → `ghcr.io/devcontainers/templates/python-3-postgres`
- Node.js + PostgreSQL → `ghcr.io/devcontainers/templates/javascript-node-postgres`
- Node.js + MongoDB → `ghcr.io/devcontainers/templates/javascript-node-mongo`

**Specialized templates:**
Check containers.dev/templates for specialized scenarios:
- Quantum Computing: Julia, Qiskit
- Robotics: ROS, ROS2
- Enterprise: Salesforce DX, SAP
- Scientific: R, Miniconda

## Official Features Only

Always use official devcontainer features from `ghcr.io/devcontainers/features/`:
- `common-utils:2` - Zsh, Oh My Zsh, utilities
- `git:1` - Latest Git with PPA
- `docker-outside-of-docker:1` - Docker CLI access to host daemon
- `azure-cli:1` - Azure CLI with Bicep
- `github-cli:1` - GitHub CLI

Avoid community features unless absolutely necessary.

## Ubuntu Noble (24.04) Package Naming

Ubuntu Noble changed some package names. Use the correct ones:
- `libasound2t64` (NOT `libasound2`)
- Other packages remain the same

## Named Volumes with Project Prefix

Always prefix volume names with project identifier to avoid conflicts:

```yaml
volumes:
  devcontainer-{{PROJECT_NAME}}-postgres-data:
  devcontainer-{{PROJECT_NAME}}-nuget:
  devcontainer-{{PROJECT_NAME}}-pnpm-store:
```

This allows multiple devcontainers to coexist without volume name collisions.

## Health Checks for All Services

Every service should have a health check:

```yaml
healthcheck:
  test: ["CMD-SHELL", "pg_isready -U postgres"]
  interval: 10s
  timeout: 5s
  retries: 5
```

Common health check commands:
- PostgreSQL: `pg_isready -U postgres`
- MySQL: `mysqladmin ping -h localhost`
- Redis: `redis-cli ping`
- RabbitMQ: `rabbitmq-diagnostics check_running`
- MongoDB: `mongosh --eval "db.adminCommand('ping')"`

## Telemetry Opt-Out

Always disable telemetry by default in containerEnv:

```json
"containerEnv": {
  "DOTNET_CLI_TELEMETRY_OPTOUT": "1",
  "NEXT_TELEMETRY_DISABLED": "1",
  "NG_CLI_ANALYTICS": "false",
  "GATSBY_TELEMETRY_DISABLED": "1",
  "NUXT_TELEMETRY_DISABLED": "1",
  "HOMEBREW_NO_ANALYTICS": "1"
}
```

## Port Forwarding

Configure ports based on detected frameworks:

| Framework | Port | Label |
|-----------|------|-------|
| Next.js | 3000 | Next.js Dev Server |
| Angular | 4200 | Angular Dev Server |
| Vite | 5173 | Vite Dev Server |
| Storybook | 6006 | Storybook |
| .NET API | 5000-5005 | .NET API |
| Docusaurus | 3000 | Docusaurus |

Use `onAutoForward: "notify"` for main development servers, `"silent"` for background services.

## VS Code Extensions by Stack

### Frontend Development
- `dbaeumer.vscode-eslint` - ESLint
- `esbenp.prettier-vscode` - Prettier
- `bradlc.vscode-tailwindcss` - Tailwind CSS
- `ms-playwright.playwright` - Playwright testing

### Angular
- `angular.ng-template` - Angular Language Service

### React/Next.js
- `dsznajder.es7-react-js-snippets` - React snippets

### .NET
- `ms-dotnettools.csdevkit` - C# Dev Kit
- `ms-dotnettools.csharp` - C# Extension
- `ms-dotnettools.vscode-dotnet-runtime` - .NET Runtime

### Python
- `ms-python.python` - Python
- `ms-python.vscode-pylance` - Pylance

### Common
- `eamodio.gitlens` - GitLens
- `usernamehw.errorlens` - Error Lens
- `editorconfig.editorconfig` - EditorConfig

## Monorepo Detection

When monorepo indicators are found, scan subdirectories for additional tech stack:

```
project/
├── apps/
│   ├── web/          # Check for package.json, framework configs
│   └── api/          # Check for .csproj, go.mod, etc.
├── packages/
│   └── shared/       # Check for package.json
└── pnpm-workspace.yaml
```

Aggregate all detected technologies and configure the devcontainer to support all of them.

## Service Configuration Templates

### PostgreSQL with PostGIS
```yaml
postgres:
  image: postgis/postgis:16-3.4
  restart: unless-stopped
  volumes:
    - devcontainer-{{PROJECT_NAME}}-postgres-data:/var/lib/postgresql/data
  environment:
    POSTGRES_USER: postgres
    POSTGRES_PASSWORD: postgres
    POSTGRES_DB: {{PROJECT_NAME}}
  ports:
    - "5432:5432"
  healthcheck:
    test: ["CMD-SHELL", "pg_isready -U postgres"]
    interval: 10s
    timeout: 5s
    retries: 5
```

### RabbitMQ with Management UI
```yaml
rabbitmq:
  image: rabbitmq:3.13-management
  restart: unless-stopped
  volumes:
    - devcontainer-{{PROJECT_NAME}}-rabbitmq-data:/var/lib/rabbitmq
  environment:
    RABBITMQ_DEFAULT_USER: guest
    RABBITMQ_DEFAULT_PASS: guest
  ports:
    - "5672:5672"
    - "15672:15672"
  healthcheck:
    test: ["CMD", "rabbitmq-diagnostics", "check_running"]
    interval: 10s
    timeout: 5s
    retries: 5
```

### Azurite (Azure Storage Emulator)
```yaml
azurite:
  image: mcr.microsoft.com/azure-storage/azurite
  restart: unless-stopped
  volumes:
    - devcontainer-{{PROJECT_NAME}}-azurite-data:/data
  command: "azurite --blobHost 0.0.0.0 --queueHost 0.0.0.0 --tableHost 0.0.0.0 --location /data --debug /data/debug.log"
  ports:
    - "10000:10000"
    - "10001:10001"
    - "10002:10002"
```

### Redis
```yaml
redis:
  image: redis:7-alpine
  restart: unless-stopped
  volumes:
    - devcontainer-{{PROJECT_NAME}}-redis-data:/data
  ports:
    - "6379:6379"
  healthcheck:
    test: ["CMD", "redis-cli", "ping"]
    interval: 10s
    timeout: 5s
    retries: 5
```

### MongoDB
```yaml
mongodb:
  image: mongo:7
  restart: unless-stopped
  volumes:
    - devcontainer-{{PROJECT_NAME}}-mongodb-data:/data/db
  environment:
    MONGO_INITDB_ROOT_USERNAME: admin
    MONGO_INITDB_ROOT_PASSWORD: admin
  ports:
    - "27017:27017"
  healthcheck:
    test: ["CMD", "mongosh", "--eval", "db.adminCommand('ping')"]
    interval: 10s
    timeout: 5s
    retries: 5
```

## Claude Code Integration

When Claude Code is selected:
1. Install via official script in post-create.sh
2. Add `ccyolo` alias

```bash
# In post-create.sh
curl -fsSL https://claude.ai/install.sh | bash
alias ccyolo="claude --dangerously-skip-permissions"
```

## Other Agentic Coders

When "Other agentic coder" is selected, provide a customization section in post-create.sh with examples for:

- **Aider**: `pip install aider-chat`
- **Continue**: VS Code extension `Continue.continue`
- **Cline/Roo Code**: VS Code extension `saoudrizwan.claude-dev`

Note: Cursor uses its own editor and is not applicable to devcontainers.
