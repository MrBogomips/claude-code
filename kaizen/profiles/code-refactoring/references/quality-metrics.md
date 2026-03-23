# Quality Metrics — Calculation Methods

## Cyclomatic Complexity

Cyclomatic complexity measures the number of linearly independent paths through a function.

### Calculation

For each function, count:
- 1 (base path)
- +1 for each `if`, `elif`, `else if`
- +1 for each `for`, `while`, `do-while`
- +1 for each `case` in switch/match
- +1 for each `catch`/`except`
- +1 for each `&&` or `||` in conditions
- +1 for each `?:` (ternary)
- +1 for each `?.` (optional chaining with branching effect)

### Thresholds

| Complexity | Assessment | Action |
|-----------|------------|--------|
| 1-5 | Low | No action needed |
| 6-10 | Moderate | Consider simplification |
| 11-20 | High | Refactor recommended |
| 21+ | Very high | Must refactor |

### Language-Specific Tools

| Language | Tool | Command |
|----------|------|---------|
| Python | radon | `radon cc -a -s {path}` |
| JavaScript/TypeScript | eslint | `eslint --rule 'complexity: [warn, 10]' {path}` |
| Go | gocyclo | `gocyclo {path}` |
| Java | PMD | `pmd check -d {path} -R rulesets/java/metrics.xml` |

When language-specific tools are unavailable, use token counting (see Calculation above).

## Duplication Detection

### Algorithm

1. Normalize code: remove blank lines, trim whitespace, normalize string literals
2. Sliding window: compare every N-line block (N=6) against all other blocks
3. Count matches: identical normalized blocks are duplicates
4. Calculate ratio: `duplicated_lines / total_lines * 100`

### Thresholds

| Ratio | Assessment |
|-------|------------|
| 0-3% | Low duplication |
| 3-10% | Moderate — review identified blocks |
| 10-20% | High — systematic deduplication needed |
| 20%+ | Critical — copy-paste culture |

### What Counts as Duplication

- **Exact duplication**: Identical code blocks (after whitespace normalization)
- **Near duplication**: Blocks that differ only in variable names or literals (harder to detect, note but don't count)
- **Structural duplication**: Same control flow with different operations (note but don't count in automated measurement)

### What Doesn't Count

- Import/require statements (naturally repeated)
- Boilerplate required by the language (main functions, module exports)
- Test setup/teardown (tests are out of scope)

## File Size

### Measurement

Count total lines per file. Do NOT exclude blank lines or comments for the primary metric (they contribute to cognitive load).

### Thresholds

| Lines | Assessment | Recommendation |
|-------|------------|----------------|
| 1-200 | Small | Ideal size |
| 201-400 | Medium | Acceptable |
| 401-800 | Large | Consider splitting |
| 801+ | Very large | Must split |

### Split Point Identification

Look for natural boundaries:
- Multiple class definitions in one file
- Groups of functions with different concerns
- Sections separated by comment headers
- Functions that are only called by each other (form a cohesive group)
