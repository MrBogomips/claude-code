# Claude Code

## Installation

```bash
# Install Claude Code via official script
curl -fsSL https://claude.ai/install.sh | bash

# Verify installation
if command -v claude &> /dev/null; then
    log "Claude Code installed: $(claude --version 2>/dev/null || echo 'version unknown')"
elif [[ -x "$HOME/.local/bin/claude" ]]; then
    log "Claude Code installed to ~/.local/bin"
else
    log "Warning: Claude Code not found after installation"
fi
```

## Aliases

```bash
# Claude Code aliases
alias ccyolo="claude --dangerously-skip-permissions"
```

## Verification

```bash
claude --version
```

## Firewall Domains

```
# Claude AI Services
ALLOW api.anthropic.com
ALLOW claude.ai
ALLOW *.anthropic.com
ALLOW statsig.anthropic.com
ALLOW sentry.io
ALLOW *.sentry.io
```
