---
sidebar_position: 6
title: Network Firewall
---

# Network Firewall

The `devcontainer-generator` skill **always deploys** a firewall — `apply-firewall.sh` and `firewall-rules.conf` are generated regardless of policy choice. The policy determines whether traffic is blocked by default (deny-all) or allowed by default (allow-all).

## Architecture

```
┌─────────────────────────────────────────────┐
│ devcontainer                                │
│                                             │
│   iptables OUTPUT chain                     │
│   ┌───────────────────────────────────┐     │
│   │ DEVCONTAINER_FW chain             │     │
│   │ 1. Root (uid 0) → RETURN (exempt) │     │
│   │ 2. Loopback → ACCEPT              │     │
│   │ 3. Established/Related → ACCEPT   │     │
│   │ 4. DNS (53) → ACCEPT              │     │
│   │ 5. DHCP (67-68) → ACCEPT          │     │
│   │ 6. User rules (first match wins)  │     │
│   │ 7. Default policy: DENY/ALLOW *   │     │
│   └───────────────────────────────────┘     │
│                                             │
│   postStartCommand runs apply-firewall.sh   │
│   capAdd: NET_ADMIN                         │
└─────────────────────────────────────────────┘
```

**Key properties:**
- Runs on every container start via `postStartCommand`
- Requires `NET_ADMIN` capability (always present in `devcontainer.json` and `docker-compose.yml`)
- Uses both `iptables` (IPv4) and `ip6tables` (IPv6)
- Root (uid 0) is **always exempt** from firewall rules
- System essentials (loopback, established connections, DNS, DHCP) are **always allowed** before user rules

## Rule Syntax

Rules are defined in `firewall-rules.conf`:

```
# Comments start with #
ACTION TARGET

# Examples:
ALLOW example.com          # Allow specific domain
ALLOW *.example.com         # Allow all subdomains (wildcard)
DENY suspicious.com         # Block specific domain
ALLOW 10.0.0.0/8            # Allow CIDR range
ALLOW 192.168.1.100         # Allow specific IP
DENY *                      # Block all remaining traffic (catch-all)
ALLOW *                     # Allow all remaining traffic (catch-all)
```

| Element | Options |
|---------|---------|
| **ACTION** | `ALLOW` or `DENY` |
| **TARGET** | Domain, `*.domain` (wildcard), CIDR notation, IPv4/IPv6 address, `*` (all) |

### Evaluation

- **First match wins** — rules are evaluated top-to-bottom
- The **last rule** should be a catch-all: `DENY *` (restrictive) or `ALLOW *` (permissive)
- Lines starting with `#` are comments
- Empty lines are ignored

### Domain Resolution

The firewall resolves domains to IP addresses at apply time:

- **Exact domains** (e.g., `github.com`): resolved to all A (IPv4) and AAAA (IPv6) records
- **Wildcard domains** (e.g., `*.github.com`): the base domain is resolved, then a `/24` (IPv4) or `/64` (IPv6) CIDR range is applied — this is a pragmatic approximation for cloud-hosted services that share subnets

## Default Whitelist

When deny-all policy is selected, the generated `firewall-rules.conf` includes these categories:

| Category | Examples |
|----------|---------|
| **Claude AI Services** | `api.anthropic.com`, `claude.ai`, `*.anthropic.com` |
| **GitHub** | `github.com`, `*.github.com`, `*.githubusercontent.com`, `ghcr.io` |
| **NPM** | `registry.npmjs.org`, `*.npmjs.org` |
| **PyPI** | `pypi.org`, `files.pythonhosted.org` |
| **NuGet** | `api.nuget.org`, `*.nuget.org` |
| **Docker/Container registries** | `docker.io`, `*.docker.io`, `mcr.microsoft.com` |
| **Microsoft/Azure** | `*.microsoft.com`, `*.azure.com`, `*.visualstudio.com` |
| **CDNs** | `*.cloudflare.com`, `cdn.jsdelivr.net`, `unpkg.com` |
| **Node.js ecosystem** | `nodejs.org`, `yarnpkg.com`, `pnpm.io` |
| **.NET ecosystem** | `dotnet.microsoft.com`, `dotnetcli.azureedge.net` |
| **Documentation sites** | `react.dev`, `nextjs.org`, `angular.dev`, `tailwindcss.com` |
| **Fonts** | `fonts.googleapis.com`, `fonts.gstatic.com` |
| **Database docs** | `postgresql.org`, `redis.io`, `mongodb.com` |
| **Dev tools** | `httpbin.org`, `postman.com` |
| **OpenAI** | `api.openai.com`, `*.openai.com` |
| **SSL/TLS CAs** | `*.digicert.com`, `*.letsencrypt.org`, OCSP responders |
| **Error tracking** | `sentry.io`, `*.sentry.io` |

Stack-specific, tool-specific, and MCP server firewall domains are **appended dynamically** based on your selections.

## How `apply-firewall.sh` Works

1. **Wait for DNS** — retries `dig github.com` for up to 30 seconds (network may not be ready at container start)
2. **Create/flush chain** — creates `DEVCONTAINER_FW` chain (or flushes if it exists)
3. **Root exemption** — uid 0 always gets `RETURN` (exempt)
4. **System essentials** — loopback, established/related, DNS (port 53), DHCP (ports 67-68)
5. **Parse rules** — reads `firewall-rules.conf` line by line:
   - `*` → catch-all ACCEPT or DROP
   - `*.domain` → resolve base domain, apply /24 (IPv4) or /64 (IPv6) CIDR
   - `CIDR` → direct iptables rule
   - `domain/IP` → resolve to IPs, add individual rules
6. **Insert into OUTPUT** — inserts `DEVCONTAINER_FW` at position 1 in the OUTPUT chain (idempotent)

### Container Requirements

The firewall needs two things in the container configuration (both are always present in generated files):

```json
// devcontainer.json
"capAdd": ["NET_ADMIN"],
"postStartCommand": "sudo bash /devcontainer/scripts/apply-firewall.sh /devcontainer/firewall-rules.conf"
```

```yaml
# docker-compose.yml
cap_add:
  - NET_ADMIN
```

## Practical Recipes

### Check current rules

```bash
sudo iptables -L DEVCONTAINER_FW -n -v
```

### Temporarily bypass firewall

```bash
sudo iptables -F DEVCONTAINER_FW
sudo iptables -A DEVCONTAINER_FW -j ACCEPT
```

### Add a domain at runtime

```bash
# Resolve and add
for ip in $(dig +short newdomain.com A); do
  sudo iptables -I DEVCONTAINER_FW -d "$ip" -j ACCEPT
done
```

### Permanently add a domain

Edit `.devcontainer/firewall-rules.conf` and add:

```
ALLOW newdomain.com
```

Then re-apply:

```bash
sudo bash /devcontainer/scripts/apply-firewall.sh /devcontainer/firewall-rules.conf
```

### Switch from deny-all to allow-all

Change the last line of `firewall-rules.conf` from `DENY *` to `ALLOW *`, then re-apply.

### Re-apply after editing rules

```bash
sudo bash /devcontainer/scripts/apply-firewall.sh /devcontainer/firewall-rules.conf
```

## Troubleshooting

### "Could not resolve" warnings at container start

DNS may not be ready when the container starts. The script retries for 30 seconds. If warnings persist:
- The domain may be unreachable or misspelled
- Check DNS configuration: `dig +short example.com`

### Package install fails (npm, pip, etc.)

The domain may not be in the whitelist. Check:

```bash
# Test connectivity
curl -v https://registry.npmjs.org 2>&1 | head -20

# Check if domain is blocked
sudo iptables -L DEVCONTAINER_FW -n -v | grep DROP
```

Add the missing domain to `firewall-rules.conf` and re-apply.

### API calls to external services fail

External APIs need their domains whitelisted. Common additions:

```
ALLOW api.stripe.com         # Stripe
ALLOW api.twilio.com         # Twilio
ALLOW *.amazonaws.com        # AWS services
ALLOW *.firebaseio.com       # Firebase
```

### Container starts but firewall not active

Verify `NET_ADMIN` capability is present and `postStartCommand` is set:

```bash
# Check if chain exists
sudo iptables -L DEVCONTAINER_FW 2>/dev/null && echo "Active" || echo "Not active"
```
