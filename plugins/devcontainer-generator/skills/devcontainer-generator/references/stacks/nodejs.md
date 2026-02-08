# Node.js

## Base Image
mcr.microsoft.com/devcontainers/javascript-node:22

## Detection
- `package.json` — primary indicator; check `engines.node` for version constraint
- `pnpm-lock.yaml` — pnpm project
- `yarn.lock` — yarn project
- `package-lock.json` — npm project
- `bun.lockb` — bun project
- `.nvmrc` or `.node-version` — pinned Node version
- `tsconfig.json` — TypeScript variant

## Frameworks

### Next.js
- Detection: `next.config.js`, `next.config.mjs`, `next.config.ts`
- CLI: `npx next dev`
- Dev port: 3000
- Telemetry opt-out: `NEXT_TELEMETRY_DISABLED=1`

### Angular
- Detection: `angular.json`, `nx.json` (Nx workspace)
- CLI: `npx ng serve`
- Dev port: 4200
- Telemetry opt-out: `NG_CLI_ANALYTICS=false`

### Vite
- Detection: `vite.config.js`, `vite.config.ts`, `vite.config.mjs`
- CLI: `npx vite`
- Dev port: 5173

### Nuxt
- Detection: `nuxt.config.js`, `nuxt.config.ts`
- CLI: `npx nuxt dev`
- Dev port: 3000
- Telemetry opt-out: `NUXT_TELEMETRY_DISABLED=1`

### Remix
- Detection: `remix.config.js`, `remix.config.ts`
- CLI: `npx remix dev`
- Dev port: 3000

### Docusaurus
- Detection: `docusaurus.config.js`, `docusaurus.config.ts`
- CLI: `npx docusaurus start`
- Dev port: 3000

### Storybook
- Detection: `.storybook/` directory
- CLI: `npx storybook dev`
- Dev port: 6006

## Package Managers

| Lock File | Manager | Install Command | Cache Volume |
|-----------|---------|-----------------|--------------|
| `package-lock.json` | npm | `npm ci` | `devcontainer-{{PROJECT_NAME}}-npm` mounted at `/home/vscode/.npm` |
| `pnpm-lock.yaml` | pnpm | `pnpm install --frozen-lockfile` | `devcontainer-{{PROJECT_NAME}}-pnpm` mounted at `/home/vscode/.local/share/pnpm/store` |
| `yarn.lock` | yarn | `yarn install --frozen-lockfile` | `devcontainer-{{PROJECT_NAME}}-yarn` mounted at `/home/vscode/.yarn/cache` |
| `bun.lockb` | bun | `bun install --frozen-lockfile` | `devcontainer-{{PROJECT_NAME}}-bun` mounted at `/home/vscode/.bun/install/cache` |

## Dockerfile Layers

When layered on a non-native base image:

```dockerfile
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g corepack \
    && corepack enable
```

## Devcontainer Features

```json
{
  "ghcr.io/devcontainers/features/node:1": {
    "version": "22"
  }
}
```

## VS Code Extensions

- `dbaeumer.vscode-eslint` — ESLint integration
- `esbenp.prettier-vscode` — Prettier code formatter
- `bradlc.vscode-tailwindcss` — Tailwind CSS IntelliSense
- `angular.ng-template` — Angular language service (Angular projects)
- `dsznajder.es7-react-js-snippets` — React/Redux snippets (React projects)
- `ms-playwright.playwright` — Playwright test runner

## Port Forwarding

| Port | Label | Condition |
|------|-------|-----------|
| 3000 | Next.js / Nuxt / Remix / Docusaurus | `next.config.*` or `nuxt.config.*` or `remix.config.*` or `docusaurus.config.*` detected |
| 4200 | Angular | `angular.json` detected |
| 5173 | Vite | `vite.config.*` detected |
| 6006 | Storybook | `.storybook/` detected |

## Host Binding

Bind to `0.0.0.0` so the dev server is reachable from the host:

- **Next.js**: `next dev -H 0.0.0.0`
- **Vite**: `vite --host 0.0.0.0`
- **Angular**: `ng serve --host 0.0.0.0`
- **Nuxt**: `nuxt dev --host 0.0.0.0`
- **Remix**: `remix dev --host 0.0.0.0`
- **Docusaurus**: `docusaurus start --host 0.0.0.0`
- **Storybook**: `storybook dev --host 0.0.0.0`

## Environment Variables

```json
{
  "NEXT_TELEMETRY_DISABLED": "1",
  "NG_CLI_ANALYTICS": "false",
  "NUXT_TELEMETRY_DISABLED": "1",
  "GATSBY_TELEMETRY_DISABLED": "1"
}
```

## Post-Create Steps

```bash
# Detect package manager and install dependencies
if [ -f pnpm-lock.yaml ]; then
  corepack enable && pnpm install --frozen-lockfile
elif [ -f yarn.lock ]; then
  corepack enable && yarn install --frozen-lockfile
elif [ -f bun.lockb ]; then
  bun install --frozen-lockfile
elif [ -f package-lock.json ]; then
  npm ci
fi
```

## Aliases

```bash
# pnpm
alias pn="pnpm"
alias pni="pnpm install"
alias pnr="pnpm run"
alias pnd="pnpm dev"

# yarn
alias yi="yarn install"
alias yr="yarn run"

# npm
alias ni="npm install"
alias nr="npm run"
alias nd="npm run dev"
```

## Firewall Domains

```
ALLOW registry.npmjs.org
ALLOW *.npmjs.org
ALLOW *.npmjs.com
ALLOW nodejs.org
ALLOW deb.nodesource.com
ALLOW yarnpkg.com
ALLOW pnpm.io
ALLOW volta.sh
ALLOW esm.sh
ALLOW unpkg.com
ALLOW cdn.jsdelivr.net
```

## Combo Templates

- `javascript-node-postgres` — Node.js + PostgreSQL
- `javascript-node-mongo` — Node.js + MongoDB
