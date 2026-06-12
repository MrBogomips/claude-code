# Testing

Three-layer testing strategy for the marketplace. Layer 1 is automated; Layers 2-3 are manual with structured checklists.

## Layer 1: Structural Validation (automated)

```bash
bash tests/ci/run-structural-tests.sh
```

Runs on every push/PR to `main`. Requires `jq`.

| Script | Checks |
|--------|--------|
| `validate-plugin.sh` | plugin.json, SKILL.md/AGENT.md frontmatter, marketplace.json |
| `validate-connectors.sh` | `~~placeholder` references match CONNECTORS.md entries |
| `validate-references.sh` | `references/` paths in SKILL.md resolve to existing files |
| `validate-versions.sh` | every plugin.json version matches its marketplace.json entry; no orphan entries |

## Layer 2: Skill Scenarios (manual)

Scenario files live under `tests/scenarios/<skill-name>/`. Each describes setup, invocation, expected behavior, and acceptance criteria. To use one:

1. Read the scenario file
2. Invoke the skill in Claude Code with the specified trigger
3. Verify the acceptance criteria checkboxes

## Layer 3: Integration Tests (manual)

Multi-skill pipeline tests under `tests/scenarios/integration/`. Two reusable inputs are provided:

- `sample-brief.md` — fictional SaaS project brief
- `sample-contract.md` — fictional IT services contract

## Adding Tests

- **Layer 1**: add a script to `tests/`, register it in `ci/run-structural-tests.sh`
- **Layer 2**: add `scenarios/<skill>/scenario-<name>.md`
- **Layer 3**: add `scenarios/integration/test-<name>.md`
