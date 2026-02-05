# Official Template Selection Guide

This guide describes how to select the appropriate base template from the official devcontainers registry.

## Dynamic Template Fetching

Before template selection, fetch the current list of available templates:

1. **WebFetch from https://containers.dev/templates**
2. Parse official templates (Dev Container Spec Maintainers)
3. Parse community templates (Microsoft Azure, research tools, etc.)
4. Cache results for the session

## Template Matching Algorithm

### 1. Exact Match
If detected stack has a direct template match, use it:
- Python detected → `python` template
- Node.js detected → `javascript-node` template
- Go detected → `go` template
- .NET detected → `dotnet` template
- Rust detected → `rust` template
- Java detected → `java` template

### 2. Combo Match
If stack + service detected, prefer combo template:
- Python + PostgreSQL → `python-3-postgres` template
- Node.js + PostgreSQL → `javascript-node-postgres` template
- Node.js + MongoDB → `javascript-node-mongo` template

### 3. Multiple Matches
Present options to user, Microsoft official templates first:
- Node.js project could use `javascript-node`, `typescript-node`, or `universal`
- Ask user to select preferred template

### 4. No Match
Fall back to `universal` template when no specific template matches.

### 5. Specialized Scenarios
WebFetch may reveal templates for specialized scenarios:
- **Quantum Computing**: Julia, Qiskit
- **Robotics**: ROS, ROS2
- **Enterprise**: Salesforce DX, SAP
- **Blockchain**: MultiversX, Smart contracts
- **Scientific**: R, Miniconda

## Complex Scenario Handling (Monorepos / Multi-Stack)

When multiple tech stacks are detected (e.g., Node.js frontend + Python backend + Go services):

### Identify Primary Stack

Analyze by:
1. Root-level config files (weighted higher)
2. Most files/LOC per language
3. User's stated intent (if available from empty folder flow)

### Selection Strategy

- **Clear primary** → Use that template as base
- **Ambiguous** → Ask user: "Which stack should be the base image?"
  - Present detected stacks with context: ".NET (apps/api), Node.js (apps/web), Python (scripts/)"
  - Recommend based on heaviest runtime requirements

### Always Generate Dockerfile

Dockerfile is always generated even for simple scenarios:
- Ensures customization point for users
- Documents the full tech stack
- Allows adding system dependencies not in base image

For multi-stack projects, layer additional stacks:

```dockerfile
# Base: Selected template (e.g., dotnet)
FROM mcr.microsoft.com/devcontainers/dotnet:8.0

# Layer: Node.js for frontend
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs

# Layer: Python for scripts
RUN apt-get update && apt-get install -y python3 python3-pip
```

## Template Priority Order

When multiple stacks detected, use this priority:

1. **Primary language template** (e.g., dotnet for .NET + Node.js project)
2. **Universal template** as fallback
3. **Community templates** only when official doesn't exist

## Template + Database Combinations

When database services are selected, prefer combo templates:

| Stack | Database | Combo Template |
|-------|----------|----------------|
| Python | PostgreSQL | `python-3-postgres` |
| Node.js | PostgreSQL | `javascript-node-postgres` |
| Node.js | MongoDB | `javascript-node-mongo` |

If no combo template exists, use the language template and add database via Docker Compose.

## Official Template Sources

### Microsoft Official (Preferred)
Repository: `ghcr.io/devcontainers/templates/`

Primary templates:
- `alpine` - Minimal Alpine Linux
- `debian` - Debian base
- `ubuntu` - Ubuntu base
- `dotnet` - .NET SDK
- `go` - Go language
- `java` - Java JDK
- `javascript-node` - Node.js
- `typescript-node` - TypeScript with Node.js
- `python` - Python 3
- `rust` - Rust toolchain
- `universal` - Multi-language universal image

### Community Templates
Check for specialized templates when Microsoft official doesn't cover the use case:
- Azure-specific templates
- Cloud provider templates
- Framework-specific templates (Django, Rails, etc.)
