# Firewall

The Devcontainer Generator includes a firewall that controls outbound network access from your development container. The firewall is always deployed -- even in allow-all mode -- so you can tighten restrictions at any time without regenerating files.

## Two modes

- **Deny-all** (recommended) -- only whitelisted domains are accessible. The generator pre-populates rules for your selected stacks, package registries, and tools.
- **Allow-all** -- no restrictions. All outbound traffic is permitted. The firewall scripts are still present, and you can switch to deny-all by editing one line.

You choose the mode during the guided setup workflow.

## How it works

The `apply-firewall.sh` script runs on every container start via the `postStartCommand` in `devcontainer.json`. It:

1. Reads rules from `firewall-rules.conf`
2. Resolves domain names to IP addresses using DNS
3. Applies `iptables` and `ip6tables` rules in a dedicated chain (`DEVCONTAINER_FW`)
4. Inserts the chain into the `OUTPUT` chain of the container's network stack

The container must have the `NET_ADMIN` capability, which the generator configures automatically in both `devcontainer.json` and `docker-compose.yml`.

## Rule syntax

Each rule is one line with an action and a target:

```
ACTION TARGET
```

**Actions:**
- `ALLOW` -- permit traffic to the target
- `DENY` -- block traffic to the target

**Targets:**
- `domain.com` -- a specific domain (resolved to IP addresses)
- `*.domain.com` -- a wildcard domain (resolves the base domain and applies a /24 CIDR for IPv4, /64 for IPv6)
- `10.0.0.0/8` -- a CIDR range
- `192.168.1.1` -- a specific IP address
- `*` -- all traffic (used as the default policy on the last line)

**Examples:**

```
ALLOW api.github.com
ALLOW *.npmjs.org
DENY  tracking.example.com
ALLOW 10.0.0.0/8
DENY  *
```

## First-match-wins

Rules are evaluated top-to-bottom. The first rule that matches a destination determines whether the traffic is allowed or blocked. Always place more specific rules above more general ones, and end with a catch-all (`DENY *` or `ALLOW *`).

## Root exemption

The root user (uid 0) is always exempt from firewall rules. This ensures that system-level operations like package installation (`apt-get`) and container management continue to work regardless of firewall policy.

## System essentials

The following traffic is always allowed before any user rules are evaluated:

- **Loopback** -- all traffic on the `lo` interface
- **Established/related connections** -- responses to outbound requests
- **DNS** -- UDP and TCP on port 53
- **DHCP** -- UDP on ports 67-68

## Stack-specific domains

When you select stacks during setup, the generator automatically includes firewall rules for the relevant package registries and ecosystem domains. For example:

- **Node.js**: `registry.npmjs.org`, `nodejs.org`, `yarnpkg.com`, `pnpm.io`
- **Python**: `pypi.org`, `files.pythonhosted.org`
- **.NET**: `api.nuget.org`, `dotnet.microsoft.com`
- **Go**: `proxy.golang.org`, `sum.golang.org`
- **Rust**: `crates.io`, `static.crates.io`, `doc.rust-lang.org`
- **Java**: `repo1.maven.org`, `plugins.gradle.org`

## Editing rules

Open `.devcontainer/firewall-rules.conf` in any editor. Add new rules above the default policy line:

```
# Add access to your company's API
ALLOW api.mycompany.com
ALLOW *.internal.mycompany.com

# Default policy (keep this last)
DENY *
```

To remove access, delete or comment out the relevant line:

```
# ALLOW tracking.example.com    <-- commented out, no longer allowed
```

## Switching policy

To switch between deny-all and allow-all, change the last line of `firewall-rules.conf`:

```
# From deny-all to allow-all:
ALLOW *

# From allow-all to deny-all:
DENY *
```

No other changes are needed. The firewall scripts work with either policy.

## Re-applying rules manually

If you edit `firewall-rules.conf` while the container is running, you can re-apply the rules without restarting:

```bash
sudo bash .devcontainer/scripts/apply-firewall.sh
```

The script is idempotent -- it flushes the existing chain before applying the updated rules.
