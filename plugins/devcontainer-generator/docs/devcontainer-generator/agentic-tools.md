# Agentic Tools

The Devcontainer Generator can install AI coding assistants into your development container. During setup, you choose which tools to include, and the generator handles installation, aliases, and firewall rules.

## Supported tools

### Claude Code

Claude Code is installed via the official installer script and is ready to use after container creation.

- **Installation**: `curl -fsSL https://claude.ai/install.sh | bash`
- **Alias**: `ccyolo` -- runs Claude Code with `--dangerously-skip-permissions` for fully autonomous operation
- **Verification**: `claude --version`
- **Firewall domains**:
  ```
  ALLOW api.anthropic.com
  ALLOW claude.ai
  ALLOW *.anthropic.com
  ALLOW statsig.anthropic.com
  ALLOW sentry.io
  ALLOW *.sentry.io
  ```

### OpenAI Codex CLI

Codex CLI is installed globally via npm.

- **Installation**: `npm install -g @openai/codex`
- **Alias**: `codex-full` -- runs Codex with `--full-auto` for autonomous operation
- **Verification**: `codex --version`
- **Firewall domains**:
  ```
  ALLOW api.openai.com
  ALLOW *.openai.com
  ALLOW cdn.openai.com
  ```

### Gemini Code Assist

Gemini Code Assist is installed as a VS Code extension and optionally via the Google Cloud CLI.

- **Installation**: `code --install-extension google.geminicodeassist` and optionally `gcloud components install gemini-code-assist`
- **Verification**: `code --list-extensions | grep gemini`
- **Firewall domains**:
  ```
  ALLOW *.googleapis.com
  ALLOW gemini.google.com
  ALLOW *.google.com
  ALLOW accounts.google.com
  ALLOW oauth2.googleapis.com
  ALLOW generativelanguage.googleapis.com
  ```

## MCP Servers

The generator can configure [Model Context Protocol (MCP)](https://modelcontextprotocol.io/) servers for your agentic coding tools. MCP servers give AI assistants access to external data sources and tools -- databases, project management systems, documentation, and more.

This step is only presented if you selected at least one agentic coding tool.

### How MCP servers are proposed

The generator proposes MCP servers based on your project context:

- **GitHub MCP** is pre-selected if a `.git` directory is detected
- **PostgreSQL MCP** is pre-selected if you chose PostgreSQL as a service
- **Redis MCP** is pre-selected if you chose Redis as a service
- Stack-relevant servers (like Figma for frontend projects) are suggested based on your selected stacks

### Available categories

- **Documentation and Code Context** -- Context7 (up-to-date library docs)
- **Source Control and Project Management** -- GitHub, Atlassian (Jira + Confluence), Linear
- **Database** -- PostgreSQL, Redis, SQLite
- **Design and Browser** -- Figma, Puppeteer, Playwright
- **Code Quality and Monitoring** -- Sentry, Serena
- **Search and Web** -- Brave Search, Fetch
- **AI and Reasoning** -- Memory, Sequential Thinking

### Configuration in DEVCONTAINER.md

For each selected MCP server, the generated `DEVCONTAINER.md` includes:

- The install command (e.g., `npx -y @upstash/context7-mcp`)
- A `.mcp.json` configuration snippet ready to paste
- Required API keys and where to obtain them
- Firewall domains to whitelist (already added to `firewall-rules.conf`)

For the full catalog of supported MCP servers with configuration details, see the [MCP servers reference](../skills/devcontainer-generator/references/mcp-servers.md).
