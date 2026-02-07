---
sidebar_position: 9
sidebar_label: Testing and Contributing
title: Testing and Contributing
---

# Testing and Contributing

The plugin includes 16 integration tests that verify a generated devcontainer works correctly. These tests are designed to run **inside** a running devcontainer.

## Running the tests

```bash
# Run all tests
bash tests/devcontainer-generator/run-all.sh

# Run a single test
bash tests/devcontainer-generator/test-firewall-chain-exists.sh
```

The test runner (`run-all.sh`) executes every `test-*.sh` file in the directory and prints a summary:

```
=== Devcontainer Generator Tests ===

PASS: DEVCONTAINER_FW chain exists
PASS: root can access non-whitelisted domains
PASS: whitelisted domain api.anthropic.com is accessible
PASS: non-whitelisted domain example.com is blocked
...

=== Results: 16/16 passed, 0 failed, 0 skipped ===
```

## Output format

Each test prints one line:

| Status | Format | Exit code |
|--------|--------|-----------|
| Pass | `PASS: <description>` | 0 |
| Fail | `FAIL: <description> - <reason>` | 1 |
| Skip | `SKIP: <description>` | 2 |

The runner exits with code 0 if all tests pass, or 1 if any test fails. Skipped tests do not cause a failure.

## Test reference

### Firewall tests (10)

These tests verify the iptables-based firewall. They require the firewall to be applied (i.e., the container started with `postStartCommand` running `apply-firewall.sh`).

| Test | What it verifies |
|------|-----------------|
| `test-firewall-chain-exists.sh` | The `DEVCONTAINER_FW` iptables chain exists. |
| `test-firewall-root-exempt.sh` | Root (uid 0) can access non-whitelisted domains. Uses `sudo curl` to reach `example.com`. |
| `test-firewall-allow-whitelisted.sh` | Non-root user can reach whitelisted domains. Tests `api.anthropic.com`. |
| `test-firewall-deny-blocked.sh` | Non-root user cannot reach non-whitelisted domains. Tests `example.com` and expects connection failure. |
| `test-firewall-dns-allowed.sh` | DNS resolution works regardless of firewall policy. |
| `test-firewall-loopback-allowed.sh` | Localhost traffic is always allowed. |
| `test-firewall-idempotent.sh` | Running `apply-firewall.sh` twice does not create duplicate chain entries. |
| `test-firewall-allow-star.sh` | When the default policy is `ALLOW *`, all traffic passes. |
| `test-firewall-cidr-rule.sh` | CIDR rules (like `10.0.0.0/8`) are correctly applied. |
| `test-firewall-rules-syntax.sh` | The `firewall-rules.conf` file has valid syntax (every non-comment line has a valid ACTION and TARGET). |

### Structure tests (4)

These tests verify the generated file structure without depending on network access.

| Test | What it verifies |
|------|-----------------|
| `test-structure-files-exist.sh` | All required files are present in `.devcontainer/`. |
| `test-structure-scripts-executable.sh` | Scripts in `.devcontainer/scripts/` have execute permission. |
| `test-structure-json-valid.sh` | `devcontainer.json` is valid JSON (parseable by `jq` or similar). |
| `test-structure-cap-net-admin.sh` | `NET_ADMIN` capability is configured in `devcontainer.json`. |

### Claude Code tests (2)

These tests verify the Claude Code installation.

| Test | What it verifies |
|------|-----------------|
| `test-claude-installed.sh` | Claude Code is installed and available in PATH. |
| `test-claude-ccyolo-alias.sh` | The `ccyolo` alias is defined in the shell configuration. |

## Writing new tests

Each test is a standalone bash script in `tests/devcontainer-generator/`. Follow these conventions:

1. **Name**: `test-<category>-<description>.sh` (for example, `test-firewall-ipv6-rule.sh`)
2. **Output**: print exactly one line: `PASS: ...`, `FAIL: ...`, or `SKIP: ...`
3. **Exit code**: 0 for pass, 1 for fail, 2 for skip
4. **Self-contained**: each test should work independently without depending on other tests

Example:

```bash
#!/bin/bash
# Test: description of what this verifies
if some_condition; then
    echo "PASS: what passed"
    exit 0
else
    echo "FAIL: what failed - reason"
    exit 1
fi
```

The test runner discovers tests by globbing `test-*.sh`, so new files are picked up automatically.

## Contributing

### Report issues

Open an issue at [github.com/MrBogomips/claude-code/issues](https://github.com/MrBogomips/claude-code/issues) with:

- The command you ran
- The detected stack (from the analysis output)
- The error or unexpected behavior
- Your host OS and Docker version

### Request features

Open an issue describing the feature and the use case. Examples:

- Support for a new language or framework
- A new service in docker-compose.yml
- Additional firewall whitelist entries for a specific ecosystem

### Submit improvements

1. Fork the repository.
2. Make your changes in a branch.
3. Run the test suite inside a generated devcontainer to verify nothing is broken.
4. Open a pull request.
