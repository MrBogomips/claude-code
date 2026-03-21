# OpenAI Codex CLI

## Installation

```bash
# Install OpenAI Codex CLI
npm install -g @openai/codex

# Verify installation
if command -v codex &> /dev/null; then
    log "OpenAI Codex CLI installed: $(codex --version 2>/dev/null || echo 'version unknown')"
fi
```

## Aliases

```bash
# OpenAI Codex aliases
alias codex-full="codex --full-auto"
```

## Verification

```bash
codex --version
```

## Firewall Domains

```
# OpenAI Services
ALLOW api.openai.com
ALLOW *.openai.com
ALLOW cdn.openai.com
```
