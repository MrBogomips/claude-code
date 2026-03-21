# Gemini Code Assist

## Installation

```bash
# Install Gemini Code Assist (Google Cloud CLI extension)
# Requires gcloud CLI to be installed first
# Option 1: Install as VS Code extension
code --install-extension google.geminicodeassist 2>/dev/null || true

# Option 2: Install via gcloud (if available)
if command -v gcloud &> /dev/null; then
    gcloud components install gemini-code-assist 2>/dev/null || true
fi

log "Gemini Code Assist configured"
```

## Aliases

```bash
# No specific CLI aliases - Gemini Code Assist is primarily a VS Code extension
```

## Verification

```bash
# Check VS Code extension
code --list-extensions 2>/dev/null | grep -i gemini || echo "Gemini extension not found"
```

## Firewall Domains

```
# Google AI Services
ALLOW *.googleapis.com
ALLOW gemini.google.com
ALLOW *.google.com
ALLOW accounts.google.com
ALLOW oauth2.googleapis.com
ALLOW generativelanguage.googleapis.com
```
