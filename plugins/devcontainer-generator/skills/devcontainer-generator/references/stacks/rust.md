# Rust

## Base Image
mcr.microsoft.com/devcontainers/base:ubuntu-24.04

## Detection
- `Cargo.toml` — primary indicator; contains package metadata and dependencies
- `Cargo.lock` — locked dependency versions
- `rust-toolchain.toml` or `rust-toolchain` — pinned toolchain version

## Frameworks

### Actix Web
- Detection: `actix-web` in `[dependencies]` of `Cargo.toml`
- Default port: 8080

### Axum
- Detection: `axum` in `[dependencies]` of `Cargo.toml`
- Default port: 3000

### Rocket
- Detection: `rocket` in `[dependencies]` of `Cargo.toml`
- Default port: 8000

## Package Managers

| Lock File | Manager | Install Command | Cache Volume |
|-----------|---------|-----------------|--------------|
| `Cargo.lock` | cargo | `cargo build` | `devcontainer-{{PROJECT_NAME}}-cargo-registry` mounted at `/usr/local/cargo/registry` |
| — | — | — | `devcontainer-{{PROJECT_NAME}}-cargo-target` mounted at `/workspaces/{{PROJECT_NAME}}/target` |

## Dockerfile Layers

When added as a secondary stack in a multi-stack project:

```dockerfile
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y \
    && . "$HOME/.cargo/env" \
    && rustup component add rust-analyzer clippy rustfmt
ENV PATH="/home/vscode/.cargo/bin:${PATH}"
```

## Devcontainer Features

```json
{
  "ghcr.io/devcontainers/features/rust:1": {
    "version": "latest"
  }
}
```

## VS Code Extensions

- `rust-lang.rust-analyzer` — Rust language server (IntelliSense, diagnostics, refactoring)
- `serayuzgur.crates` — crate version management in `Cargo.toml`

## Port Forwarding

| Port | Label | Condition |
|------|-------|-----------|
| 8080 | Actix Web | `actix-web` in `Cargo.toml` |
| 3000 | Axum | `axum` in `Cargo.toml` |
| 8000 | Rocket | `rocket` in `Cargo.toml` |

## Host Binding

Rust web frameworks bind via address strings. Ensure the bind address uses `0.0.0.0`:

- **Actix Web**: `HttpServer::new(...).bind("0.0.0.0:8080")`
- **Axum**: `let listener = TcpListener::bind("0.0.0.0:3000").await.unwrap();`
- **Rocket**: set `address = "0.0.0.0"` in `Rocket.toml` under `[default]`

## Environment Variables

```json
{
  "CARGO_HOME": "/usr/local/cargo",
  "RUSTUP_HOME": "/usr/local/rustup"
}
```

## Post-Create Steps

```bash
# Install additional components
rustup component add clippy rustfmt

# Install common cargo tools
cargo install cargo-watch
cargo install cargo-edit

# Build project to populate cache
cargo build
```

## Aliases

```bash
alias cr="cargo run"
alias cb="cargo build"
alias ct="cargo test"
alias cc="cargo check"
```

## Firewall Domains

```
ALLOW crates.io
ALLOW static.crates.io
ALLOW index.crates.io
ALLOW doc.rust-lang.org
ALLOW static.rust-lang.org
```

