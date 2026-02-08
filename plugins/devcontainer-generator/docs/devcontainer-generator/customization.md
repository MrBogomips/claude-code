# Customization

After the Devcontainer Generator creates your `.devcontainer/` directory, you can modify any of the generated files. This page covers the most common customizations.

## Adding VS Code extensions

Edit `.devcontainer/devcontainer.json` and add extension IDs to the `customizations.vscode.extensions` array:

```json
"customizations": {
  "vscode": {
    "extensions": [
      "dbaeumer.vscode-eslint",
      "your-publisher.your-extension"
    ]
  }
}
```

Find extension IDs on the VS Code Marketplace -- they follow the format `publisher.extension-name`.

## Adding system packages

Edit `.devcontainer/Dockerfile` and add packages to the `apt-get install` command:

```dockerfile
RUN apt-get update && apt-get install -y \
    your-package-here \
    && rm -rf /var/lib/apt/lists/*
```

The generated Dockerfile uses Ubuntu Noble (24.04) package names.

## Adding services

Edit `.devcontainer/docker-compose.yml` to add a new service block. For example, to add a Memcached instance:

```yaml
services:
  memcached:
    image: memcached:latest
    restart: unless-stopped
    ports:
      - "11211:11211"
```

Remember to add a named volume if the service needs persistent storage, and add a `depends_on` entry to the application container if needed.

## Modifying post-create setup

Edit `.devcontainer/scripts/post-create.sh` to add commands that run after the container is first created. This is the right place for:

- Installing global tools
- Running database migrations
- Seeding development data
- Setting up additional shell configuration

## Changing firewall rules

Edit `.devcontainer/firewall-rules.conf` to add or remove domain rules:

```
# Add a new domain
ALLOW api.example.com

# Add a wildcard domain
ALLOW *.example.com

# Block a specific domain
DENY tracking.example.com
```

Rules are evaluated top-to-bottom, first match wins. See the [Firewall guide](firewall.md) for full syntax details.

## Switching firewall policy

The last line of `firewall-rules.conf` sets the default policy. Change it with a single edit:

```
# Deny-all (recommended for security)
DENY *

# Allow-all (no restrictions)
ALLOW *
```

The firewall scripts are always present regardless of which policy you choose. Switching from `ALLOW *` to `DENY *` enables restrictions without regenerating any files.

## Rebuilding after changes

After editing any file in `.devcontainer/`, rebuild the container for changes to take effect:

- **VS Code**: Command Palette, select "Dev Containers: Rebuild Container"
- **CLI**: `devcontainer up --workspace-folder . --rebuild`

Changes to `firewall-rules.conf` take effect on the next container start without a full rebuild -- the firewall script runs via `postStartCommand`.
