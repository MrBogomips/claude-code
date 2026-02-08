---
sidebar_position: 5
title: Agentic Tools & MCP Servers
---

# Agentic Tools & MCP Servers

The devcontainer generator supports 3 agentic coding tools and a catalog of 16 MCP (Model Context Protocol) servers across 7 categories. MCP servers are only offered when at least one agentic tool is selected.

## Agentic Coding Tools

### Claude Code

| Property | Value |
|----------|-------|
| **Installation** | `curl -fsSL https://claude.ai/install.sh \| bash` |
| **Alias** | `ccyolo` → `claude --dangerously-skip-permissions` |
| **Verification** | `claude --version` |

**Firewall domains:**

```
ALLOW api.anthropic.com
ALLOW claude.ai
ALLOW *.anthropic.com
ALLOW statsig.anthropic.com
ALLOW sentry.io
ALLOW *.sentry.io
```

### OpenAI Codex CLI

| Property | Value |
|----------|-------|
| **Installation** | `npm install -g @openai/codex` |
| **Alias** | `codex-full` → `codex --full-auto` |
| **Verification** | `codex --version` |

**Firewall domains:**

```
ALLOW api.openai.com
ALLOW *.openai.com
ALLOW cdn.openai.com
```

### Gemini Code Assist

| Property | Value |
|----------|-------|
| **Installation** | VS Code extension `google.geminicodeassist` + optional `gcloud components install gemini-code-assist` |
| **Alias** | None (primarily a VS Code extension) |
| **Verification** | `code --list-extensions \| grep -i gemini` |

**Firewall domains:**

```
ALLOW *.googleapis.com
ALLOW gemini.google.com
ALLOW *.google.com
ALLOW accounts.google.com
ALLOW oauth2.googleapis.com
ALLOW generativelanguage.googleapis.com
```

---

## MCP Servers

MCP servers extend agentic coding tools with external integrations — databases, project management, design tools, search, and more.

### How MCP Selection Works

1. MCP servers are **only offered if an agentic tool was selected** in Step 3
2. Before presenting options, the plugin runs a **live web search** to supplement the built-in catalog with fresh recommendations
3. Servers are **pre-selected based on context**: GitHub MCP if `.git` is detected, PostgreSQL MCP if PostgreSQL was chosen as a service, etc.
4. Selected servers are configured in `.mcp.json` and documented in `DEVCONTAINER.md`

### Configuration

Each MCP server is configured in a `.mcp.json` file at the project root:

```json
{
  "mcpServers": {
    "server-name": {
      "command": "npx",
      "args": ["-y", "@scope/package-name"],
      "env": {
        "API_KEY": "<your-key>"
      }
    }
  }
}
```

---

### Documentation & Code Context

#### Context7 (by Upstash)

Provides up-to-date, version-specific library documentation directly in prompts.

| Property | Value |
|----------|-------|
| **Package** | `@upstash/context7-mcp` |
| **API key** | Not required |
| **Relevant stacks** | All |

```json
{
  "mcpServers": {
    "context7": {
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp"]
    }
  }
}
```

**Firewall domains:** `context7.com`, `*.upstash.com`

---

### Source Control & Project Management

#### GitHub MCP

GitHub integration — PRs, issues, code search, repository management.

| Property | Value |
|----------|-------|
| **Package** | `@modelcontextprotocol/server-github` |
| **API key** | `GITHUB_PERSONAL_ACCESS_TOKEN` |
| **Pre-selected** | If `.git` detected |
| **Relevant stacks** | All |

```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "<your-token>"
      }
    }
  }
}
```

**Firewall domains:** `api.github.com`, `github.com`, `*.github.com`

#### Atlassian MCP (Jira + Confluence)

Jira issue tracking and Confluence wiki integration.

| Property | Value |
|----------|-------|
| **Package** | `@anthropic/mcp-server-atlassian` |
| **API key** | `ATLASSIAN_API_TOKEN` |
| **Additional env** | `ATLASSIAN_SITE_URL`, `ATLASSIAN_USER_EMAIL` |
| **Relevant stacks** | All |

```json
{
  "mcpServers": {
    "atlassian": {
      "command": "npx",
      "args": ["-y", "@anthropic/mcp-server-atlassian"],
      "env": {
        "ATLASSIAN_SITE_URL": "<your-site>.atlassian.net",
        "ATLASSIAN_USER_EMAIL": "<your-email>",
        "ATLASSIAN_API_TOKEN": "<your-token>"
      }
    }
  }
}
```

**Firewall domains:** `*.atlassian.net`, `*.atlassian.com`

#### Linear MCP

Linear project management integration.

| Property | Value |
|----------|-------|
| **Package** | `@anthropic/mcp-server-linear` |
| **API key** | `LINEAR_API_KEY` |
| **Relevant stacks** | All |

```json
{
  "mcpServers": {
    "linear": {
      "command": "npx",
      "args": ["-y", "@anthropic/mcp-server-linear"],
      "env": {
        "LINEAR_API_KEY": "<your-key>"
      }
    }
  }
}
```

**Firewall domains:** `api.linear.app`, `linear.app`

---

### Database

#### PostgreSQL MCP

PostgreSQL database integration — query execution, schema inspection.

| Property | Value |
|----------|-------|
| **Package** | `@modelcontextprotocol/server-postgres` |
| **API key** | Not required (uses connection string) |
| **Pre-selected** | If PostgreSQL chosen in Step 2 |
| **Firewall domains** | None (local service) |

```json
{
  "mcpServers": {
    "postgres": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-postgres",
               "postgresql://postgres:postgres@postgres:5432/{{PROJECT_NAME}}"]
    }
  }
}
```

#### Redis MCP

Redis data store integration.

| Property | Value |
|----------|-------|
| **Package** | `@anthropic/mcp-server-redis` |
| **API key** | Not required (uses connection string) |
| **Pre-selected** | If Redis chosen in Step 2 |
| **Firewall domains** | None (local service) |

```json
{
  "mcpServers": {
    "redis": {
      "command": "npx",
      "args": ["-y", "@anthropic/mcp-server-redis"],
      "env": {
        "REDIS_URL": "redis://redis:6379"
      }
    }
  }
}
```

#### SQLite MCP

SQLite database integration.

| Property | Value |
|----------|-------|
| **Package** | `@modelcontextprotocol/server-sqlite` |
| **API key** | Not required |
| **Firewall domains** | None (local file) |

```json
{
  "mcpServers": {
    "sqlite": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-sqlite", "/path/to/db.sqlite"]
    }
  }
}
```

---

### Design & Browser

#### Figma MCP

Figma design file access and inspection.

| Property | Value |
|----------|-------|
| **Package** | `@anthropic/mcp-server-figma` |
| **API key** | `FIGMA_ACCESS_TOKEN` |
| **Relevant stacks** | Node.js (frontend) |

```json
{
  "mcpServers": {
    "figma": {
      "command": "npx",
      "args": ["-y", "@anthropic/mcp-server-figma"],
      "env": {
        "FIGMA_ACCESS_TOKEN": "<your-token>"
      }
    }
  }
}
```

**Firewall domains:** `api.figma.com`, `*.figma.com`

#### Puppeteer MCP

Browser automation, screenshots, and web scraping.

| Property | Value |
|----------|-------|
| **Package** | `@modelcontextprotocol/server-puppeteer` |
| **API key** | Not required |
| **Firewall domains** | Depends on target sites |
| **Relevant stacks** | Node.js |

```json
{
  "mcpServers": {
    "puppeteer": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-puppeteer"]
    }
  }
}
```

#### Playwright MCP

Browser testing automation with Playwright.

| Property | Value |
|----------|-------|
| **Package** | `@anthropic/mcp-server-playwright` |
| **API key** | Not required |
| **Firewall domains** | Depends on target sites |
| **Relevant stacks** | Node.js, Python |

```json
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": ["-y", "@anthropic/mcp-server-playwright"]
    }
  }
}
```

---

### Code Quality & Monitoring

#### Sentry MCP

Error tracking and debugging — view issues, stack traces, breadcrumbs.

| Property | Value |
|----------|-------|
| **Package** | `@sentry/mcp-server` |
| **API key** | `SENTRY_AUTH_TOKEN` |
| **Relevant stacks** | All |

```json
{
  "mcpServers": {
    "sentry": {
      "command": "npx",
      "args": ["-y", "@sentry/mcp-server"],
      "env": {
        "SENTRY_AUTH_TOKEN": "<your-token>"
      }
    }
  }
}
```

**Firewall domains:** `sentry.io`, `*.sentry.io`

#### Serena MCP

Code navigation and understanding — semantic search, symbol lookup.

| Property | Value |
|----------|-------|
| **Package** | `serena-mcp` |
| **API key** | Not required |
| **Firewall domains** | None (local analysis) |
| **Relevant stacks** | All |

```json
{
  "mcpServers": {
    "serena": {
      "command": "npx",
      "args": ["-y", "serena-mcp"]
    }
  }
}
```

---

### Search & Web

#### Brave Search MCP

Web search from within the agent.

| Property | Value |
|----------|-------|
| **Package** | `@modelcontextprotocol/server-brave-search` |
| **API key** | `BRAVE_API_KEY` |
| **Relevant stacks** | All |

```json
{
  "mcpServers": {
    "brave-search": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-brave-search"],
      "env": {
        "BRAVE_API_KEY": "<your-key>"
      }
    }
  }
}
```

**Firewall domains:** `api.search.brave.com`, `brave.com`

#### Fetch MCP

Web content fetching and conversion to markdown.

| Property | Value |
|----------|-------|
| **Package** | `@modelcontextprotocol/server-fetch` |
| **API key** | Not required |
| **Firewall domains** | Depends on target sites |
| **Relevant stacks** | All |

```json
{
  "mcpServers": {
    "fetch": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-fetch"]
    }
  }
}
```

---

### AI & Reasoning

#### Memory MCP

Knowledge graph-based persistent memory across sessions.

| Property | Value |
|----------|-------|
| **Package** | `@modelcontextprotocol/server-memory` |
| **API key** | Not required |
| **Firewall domains** | None (local storage) |
| **Relevant stacks** | All |

```json
{
  "mcpServers": {
    "memory": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-memory"]
    }
  }
}
```

#### Sequential Thinking MCP

Structured problem-solving with step-by-step reasoning.

| Property | Value |
|----------|-------|
| **Package** | `@modelcontextprotocol/server-sequential-thinking` |
| **API key** | Not required |
| **Firewall domains** | None (local processing) |
| **Relevant stacks** | All |

```json
{
  "mcpServers": {
    "sequential-thinking": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-sequential-thinking"]
    }
  }
}
```

---

## Summary

| Category | Servers | API Keys Required |
|----------|---------|-------------------|
| Documentation & Code Context | Context7 | None |
| Source Control & Project Management | GitHub, Atlassian, Linear | GitHub PAT, Atlassian token, Linear key |
| Database | PostgreSQL, Redis, SQLite | None (connection strings) |
| Design & Browser | Figma, Puppeteer, Playwright | Figma token |
| Code Quality & Monitoring | Sentry, Serena | Sentry token |
| Search & Web | Brave Search, Fetch | Brave API key |
| AI & Reasoning | Memory, Sequential Thinking | None |

**Total: 16 servers across 7 categories.** 5 require API keys, 11 work out of the box.
