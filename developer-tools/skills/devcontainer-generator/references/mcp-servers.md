# MCP Servers Catalog

Reference catalog of Model Context Protocol (MCP) servers for agentic coding tools. Each entry includes installation, configuration, and firewall requirements.

## Documentation & Code Context

### Context7 (by Upstash)
- **Package**: `@upstash/context7-mcp`
- **Description**: Provides up-to-date, version-specific library documentation directly in prompts
- **Install**: `npx -y @upstash/context7-mcp`
- **Config**:
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
- **API key required**: No
- **Firewall domains**:
  ```
  ALLOW context7.com
  ALLOW *.upstash.com
  ```
- **Relevant stacks**: All

## Source Control & Project Management

### GitHub MCP
- **Package**: `@modelcontextprotocol/server-github`
- **Description**: GitHub integration — PRs, issues, code search, repository management
- **Install**: `npx -y @modelcontextprotocol/server-github`
- **Config**:
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
- **API key required**: Yes — `GITHUB_PERSONAL_ACCESS_TOKEN`
- **Firewall domains**:
  ```
  ALLOW api.github.com
  ALLOW github.com
  ALLOW *.github.com
  ```
- **Relevant stacks**: All

### Atlassian MCP (Jira + Confluence)
- **Package**: `@anthropic/mcp-server-atlassian`
- **Description**: Jira issue tracking and Confluence wiki integration
- **Install**: `npx -y @anthropic/mcp-server-atlassian`
- **Config**:
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
- **API key required**: Yes — `ATLASSIAN_API_TOKEN`
- **Firewall domains**:
  ```
  ALLOW *.atlassian.net
  ALLOW *.atlassian.com
  ```
- **Relevant stacks**: All

### Linear MCP
- **Package**: `@anthropic/mcp-server-linear`
- **Description**: Linear project management integration
- **Install**: `npx -y @anthropic/mcp-server-linear`
- **Config**:
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
- **API key required**: Yes — `LINEAR_API_KEY`
- **Firewall domains**:
  ```
  ALLOW api.linear.app
  ALLOW linear.app
  ```
- **Relevant stacks**: All

## Database

### PostgreSQL MCP
- **Package**: `@modelcontextprotocol/server-postgres`
- **Description**: PostgreSQL database integration — query, schema inspection
- **Install**: `npx -y @modelcontextprotocol/server-postgres`
- **Config**:
  ```json
  {
    "mcpServers": {
      "postgres": {
        "command": "npx",
        "args": ["-y", "@modelcontextprotocol/server-postgres", "postgresql://postgres:postgres@postgres:5432/{{PROJECT_NAME}}"]
      }
    }
  }
  ```
- **API key required**: No (uses connection string)
- **Firewall domains**: None (local service)
- **Relevant stacks**: All (when PostgreSQL service selected)

### Redis MCP
- **Package**: `@anthropic/mcp-server-redis`
- **Description**: Redis data store integration
- **Install**: `npx -y @anthropic/mcp-server-redis`
- **Config**:
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
- **API key required**: No (uses connection string)
- **Firewall domains**: None (local service)
- **Relevant stacks**: All (when Redis service selected)

### SQLite MCP
- **Package**: `@modelcontextprotocol/server-sqlite`
- **Description**: SQLite database integration
- **Install**: `npx -y @modelcontextprotocol/server-sqlite`
- **Config**:
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
- **API key required**: No
- **Firewall domains**: None (local file)
- **Relevant stacks**: All

## Design & Browser

### Figma MCP
- **Package**: `@anthropic/mcp-server-figma`
- **Description**: Figma design file access and inspection
- **Install**: `npx -y @anthropic/mcp-server-figma`
- **Config**:
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
- **API key required**: Yes — `FIGMA_ACCESS_TOKEN`
- **Firewall domains**:
  ```
  ALLOW api.figma.com
  ALLOW *.figma.com
  ```
- **Relevant stacks**: Node.js (frontend)

### Puppeteer MCP
- **Package**: `@modelcontextprotocol/server-puppeteer`
- **Description**: Browser automation, screenshots, and web scraping
- **Install**: `npx -y @modelcontextprotocol/server-puppeteer`
- **Config**:
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
- **API key required**: No
- **Firewall domains**: Depends on target sites
- **Relevant stacks**: Node.js

### Playwright MCP
- **Package**: `@anthropic/mcp-server-playwright`
- **Description**: Browser testing automation with Playwright
- **Install**: `npx -y @anthropic/mcp-server-playwright`
- **Config**:
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
- **API key required**: No
- **Firewall domains**: Depends on target sites
- **Relevant stacks**: Node.js, Python

## Code Quality & Monitoring

### Sentry MCP
- **Package**: `@sentry/mcp-server`
- **Description**: Error tracking and debugging — view issues, stack traces, breadcrumbs
- **Install**: `npx -y @sentry/mcp-server`
- **Config**:
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
- **API key required**: Yes — `SENTRY_AUTH_TOKEN`
- **Firewall domains**:
  ```
  ALLOW sentry.io
  ALLOW *.sentry.io
  ```
- **Relevant stacks**: All

### Serena MCP
- **Package**: `serena-mcp`
- **Description**: Code navigation and understanding — semantic search, symbol lookup
- **Install**: `npx -y serena-mcp`
- **Config**:
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
- **API key required**: No
- **Firewall domains**: None (local analysis)
- **Relevant stacks**: All

## Search & Web

### Brave Search MCP
- **Package**: `@modelcontextprotocol/server-brave-search`
- **Description**: Web search from within the agent
- **Install**: `npx -y @modelcontextprotocol/server-brave-search`
- **Config**:
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
- **API key required**: Yes — `BRAVE_API_KEY`
- **Firewall domains**:
  ```
  ALLOW api.search.brave.com
  ALLOW brave.com
  ```
- **Relevant stacks**: All

### Fetch MCP
- **Package**: `@modelcontextprotocol/server-fetch`
- **Description**: Web content fetching and conversion to markdown
- **Install**: `npx -y @modelcontextprotocol/server-fetch`
- **Config**:
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
- **API key required**: No
- **Firewall domains**: Depends on target sites
- **Relevant stacks**: All

## AI & Reasoning

### Memory MCP
- **Package**: `@modelcontextprotocol/server-memory`
- **Description**: Knowledge graph-based persistent memory across sessions
- **Install**: `npx -y @modelcontextprotocol/server-memory`
- **Config**:
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
- **API key required**: No
- **Firewall domains**: None (local storage)
- **Relevant stacks**: All

### Sequential Thinking MCP
- **Package**: `@modelcontextprotocol/server-sequential-thinking`
- **Description**: Structured problem-solving with step-by-step reasoning
- **Install**: `npx -y @modelcontextprotocol/server-sequential-thinking`
- **Config**:
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
- **API key required**: No
- **Firewall domains**: None (local processing)
- **Relevant stacks**: All
