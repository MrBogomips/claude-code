---
sidebar_position: 8
sidebar_label: Customization
title: Customization
---

# Customization

After generation, every file can be edited. This page lists the intended extension points per file and practices that help your changes survive regeneration.

## devcontainer.json

- **Add VS Code extensions** -- append to the `customizations.vscode.extensions` array.
- **Add features** -- add entries to `features`. Use official features from `ghcr.io/devcontainers/features/` when available.
- **Change port forwarding** -- edit `forwardPorts` and `portsAttributes`.
- **Add environment variables** -- add to `containerEnv` (available at build time) or `remoteEnv` (available at runtime, can reference `${localEnv:VAR}`).
- **Add mounts** -- add entries to the `mounts` array. Useful for mounting SSH keys, AWS credentials, or other host files.

## Dockerfile

- **Add system packages** -- add to the `apt-get install` block in the system dependencies section.
- **Add runtime layers** -- add `RUN` commands in the appropriate section (Node.js, Python, Go, etc.).
- **Change the base image** -- replace the `FROM` line. Make sure to use a `mcr.microsoft.com/devcontainers/` image if you want devcontainer features to work correctly.

## docker-compose.yml

- **Add services** -- add service definitions following the pattern described in [Docker Compose Services](services.md).
- **Add volumes** -- declare them under `volumes:` at the bottom of the file, using the `devcontainer-{{PROJECT_NAME}}-` prefix.
- **Change service images** -- update the `image:` field. For example, change `postgis/postgis:16-3.4` to `postgres:16` if you do not need PostGIS.
- **Add environment variables** -- add to the `environment` section of the `devcontainer` service or individual service definitions.

## post-create.sh

- **Add installation steps** -- append commands before the "Environment Verification" section.
- **Modify the agentic coder section** -- if you selected "Other agentic coder", uncomment and edit the customization block.
- **Add project-specific setup** -- for example, database seeding, certificate installation, or custom tool configuration.

## Firewall rules

- **Add domains** -- add `ALLOW domain.com` lines before the catch-all rule.
- **Add CIDRs** -- add `ALLOW 10.0.0.0/8` for internal network ranges.
- **Switch default policy** -- change the last line between `DENY *` and `ALLOW *`.
- **Block specific domains** (in allow-all mode) -- add `DENY unwanted.com` before the `ALLOW *` catch-all.

See [Network Firewall](firewall.md) for the full syntax reference and practical examples.

## Shell configurations

### Zsh

The generated `.devcontainer/config/.zshrc` is copied to `~/.zshrc` during post-create. To add your own customizations that survive regeneration, create `~/.zshrc.local`:

```bash
# ~/.zshrc.local -- loaded at the end of .zshrc
export MY_CUSTOM_VAR="value"
alias myalias="my-command --flag"
```

The generated `.zshrc` includes `[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local` at the end.

### Fish

Similarly, create `~/.config/fish/config.local.fish`:

```fish
# config.local.fish -- loaded at the end of config.fish
set -gx MY_CUSTOM_VAR "value"
alias myalias="my-command --flag"
```

The generated `config.fish` includes a check for this file at the end.

## Best practices

- **Edit generated files directly** for changes you want to keep in version control. The generator does not overwrite files without asking.
- **Use local override files** (`.zshrc.local`, `config.local.fish`) for personal preferences that should not be committed.
- **Follow the naming convention** for volumes (`devcontainer-{{PROJECT_NAME}}-<purpose>`) to avoid collisions.
- **Include health checks** when adding services. Every generated service has one; custom services should too.
- **Use official devcontainer features** from `ghcr.io/devcontainers/features/` rather than installing tools manually in the Dockerfile.

See [Generated Files](generated-files.md) for the full file reference, [Docker Compose Services](services.md) for per-service details, and [Network Firewall](firewall.md) for firewall customization.
