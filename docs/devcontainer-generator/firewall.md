---
sidebar_position: 5
sidebar_label: Network Firewall
title: Network Firewall
---

# Network Firewall

The generator includes an optional network firewall that restricts outbound traffic from the devcontainer. When enabled, it uses Linux iptables to enforce a whitelist (or blocklist) at the kernel level.

## Firewall modes

| Mode | Default rule | Behavior |
|------|-------------|----------|
| **Deny-all** (default) | `DENY *` | Only whitelisted domains are accessible. Everything else is blocked. |
| **Allow-all** | `ALLOW *` | All traffic is allowed. You can block specific domains with `DENY` rules. |
| **Disabled** | (none) | No network restrictions. No firewall files are generated. |

## Rules file syntax

The rules file (`.devcontainer/firewall-rules.conf`) uses a simple `ACTION TARGET` format:

```
ACTION TARGET
```

- **ACTION**: `ALLOW` or `DENY`
- **TARGET**: one of the following:
  - `domain.com` -- a specific domain (resolved to IPs via DNS at apply time)
  - `*.domain.com` -- a wildcard domain (resolves the base domain and uses a `/24` CIDR approximation)
  - `10.0.0.0/8` -- a CIDR range (IPv4)
  - `fd00::/8` -- a CIDR range (IPv6)
  - `192.168.1.1` -- a specific IP address
  - `*` -- all traffic (used as the catch-all default policy)

Rules are evaluated top to bottom, first match wins. Lines starting with `#` are comments. The last rule should be a catch-all (`DENY *` or `ALLOW *`).

Root (uid 0) is always exempt from firewall rules.

## Default whitelist

When the deny-all policy is selected, the generated `firewall-rules.conf` includes ALLOW rules for the following categories:

| Category | Domains |
|----------|---------|
| **Claude AI** | `api.anthropic.com`, `claude.ai`, `*.anthropic.com` |
| **GitHub** | `github.com`, `*.github.com`, `*.githubusercontent.com`, `ghcr.io`, `*.ghcr.io` |
| **NPM** | `registry.npmjs.org`, `*.npmjs.org`, `*.npmjs.com`, `npm.pkg.github.com` |
| **PyPI** | `pypi.org`, `*.pypi.org`, `files.pythonhosted.org` |
| **NuGet** | `api.nuget.org`, `*.nuget.org`, `nuget.pkg.github.com` |
| **Docker** | `docker.io`, `*.docker.io`, `registry-1.docker.io`, `mcr.microsoft.com` |
| **Microsoft/Azure** | `*.microsoft.com`, `*.azure.com`, `*.azureedge.net`, `*.windows.net`, `*.visualstudio.com` |
| **CDN** | `*.cloudflare.com`, `cdn.jsdelivr.net`, `unpkg.com`, `esm.sh` |
| **Node.js** | `nodejs.org`, `deb.nodesource.com`, `yarnpkg.com`, `pnpm.io`, `volta.sh` |
| **.NET** | `dotnet.microsoft.com`, `dotnetcli.azureedge.net` |
| **Documentation** | `docs.github.com`, `learn.microsoft.com`, `react.dev`, `nextjs.org`, `angular.dev`, `tailwindcss.com` |
| **Fonts** | `fonts.googleapis.com`, `fonts.gstatic.com`, `*.fontawesome.com` |
| **Databases** | `postgresql.org`, `redis.io`, `mongodb.com`, `rabbitmq.com` |
| **Dev tools** | `httpbin.org`, `jsonplaceholder.typicode.com`, `postman.com` |
| **OpenAI** | `api.openai.com`, `*.openai.com` |
| **SSL/TLS CAs** | `*.digicert.com`, `*.letsencrypt.org`, `ocsp.pki.goog` |
| **Error tracking** | `sentry.io`, `*.sentry.io` |

## Editing rules

### Add a domain

Add a line before the catch-all rule:

```
ALLOW my-internal-registry.example.com
```

### Add a CIDR range

```
ALLOW 10.0.0.0/8
```

### Switch from deny-all to allow-all

Change the last line of `firewall-rules.conf` from:

```
DENY *
```

to:

```
ALLOW *
```

Then re-apply:

```bash
sudo bash .devcontainer/scripts/apply-firewall.sh .devcontainer/firewall-rules.conf
```

## Practical examples

### Temporarily bypass the firewall for a single command

Root is exempt from firewall rules. Use `sudo` to bypass the firewall for a one-off operation:

```bash
sudo curl https://blocked-domain.com/file.tar.gz -o /tmp/file.tar.gz
```

### Temporarily open all traffic

Flush the firewall chain and add an ACCEPT-all rule:

```bash
sudo iptables -F DEVCONTAINER_FW && sudo iptables -A DEVCONTAINER_FW -j ACCEPT
```

This lasts until the next container restart (when `postStartCommand` re-applies the rules from the conf file).

### Re-apply rules after editing the conf file

```bash
sudo bash .devcontainer/scripts/apply-firewall.sh .devcontainer/firewall-rules.conf
```

### Check current rules

```bash
sudo iptables -L DEVCONTAINER_FW -n --line-numbers
```

## Technical details: how apply-firewall.sh works

The script runs as root via `postStartCommand` on every container start. Here is what it does, in order:

1. **DNS wait loop** -- waits up to 30 seconds for DNS to become available (the network stack may not be ready immediately at container start). Tests by resolving `github.com`.

2. **Chain setup** -- creates an iptables chain named `DEVCONTAINER_FW`. If the chain already exists, it is flushed (this makes the script idempotent).

3. **Root exemption** -- adds a RETURN rule for uid 0, so root always bypasses the firewall. This ensures system tools like `apt-get` work normally.

4. **System essentials** -- adds ACCEPT rules for:
   - Loopback interface (`-o lo`)
   - Established/related connections (`-m state --state ESTABLISHED,RELATED`)
   - DNS on port 53 (UDP and TCP)
   - DHCP on ports 67-68 (UDP)

5. **Rule parsing** -- reads `firewall-rules.conf` line by line, skipping comments and empty lines. For each rule:
   - `*` (catch-all): adds an ACCEPT or DROP rule for all traffic
   - `*.domain.com` (wildcard): resolves the base domain via DNS, then applies a `/24` CIDR rule for each resolved IPv4 address and a `/64` rule for each IPv6 address
   - `x.x.x.x/N` or `xxxx::/N` (CIDR): adds a direct CIDR rule to the appropriate iptables command (IPv4 or IPv6)
   - `domain.com` or plain IP: resolves via DNS and adds a rule for each resolved address

6. **OUTPUT chain insertion** -- removes any existing jump to `DEVCONTAINER_FW` from the OUTPUT chain, then inserts it at position 1. This is idempotent: running the script twice does not create duplicate jumps.

7. **Dual-stack** -- all rules are applied to both `iptables` (IPv4) and `ip6tables` (IPv6).

## Container requirements

For the firewall to work, the container needs:

- **`CAP_NET_ADMIN`** capability -- added via `capAdd` in devcontainer.json and `cap_add` in docker-compose.yml
- **`postStartCommand`** -- runs `apply-firewall.sh` on every container start
- **Packages**: `iptables` and `dnsutils` -- installed by `post-create.sh`

## Limitations

- **Wildcard `/24` approximation**: wildcard domains like `*.example.com` resolve the base domain and apply a `/24` CIDR (IPv4) or `/64` CIDR (IPv6). This is a pragmatic approximation; cloud-hosted services with many subdomains on different subnets may not be fully covered.
- **DNS-time resolution**: domain rules are resolved to IP addresses when `apply-firewall.sh` runs. If a domain's IP addresses change after that, the firewall rules are stale until the next container restart.
- **Root exemption**: any process running as root (uid 0) bypasses the firewall entirely. This is intentional so that system tools work, but it also means `sudo <command>` bypasses restrictions.

See [Customization](customization.md) for how to modify firewall rules after generation, and [Testing and Contributing](testing.md) for the firewall test suite.
