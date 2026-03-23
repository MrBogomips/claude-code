---
name: code-refactoring
description: "Recursively improve code quality metrics for a target codebase area"
version: 1.0.0

strategy: multi-objective
autonomy: hybrid(3)
iteration_budget: 10
convergence:
  epsilon: 0.05
  patience: 3

initial_state:
  capture_strategy: automatic
  sources:
    - type: config
      path: "."
      description: "Project root — scan for language, framework, and existing quality config"
    - type: git_history
      command: "git log --oneline -50 --diff-filter=M"
      description: "Recently modified files to focus refactoring effort"

measurement:
  tool_generation: true
  language: python

kpis:
  - name: cyclomatic_complexity
    description: "Average cyclomatic complexity per function across files in scope. Lower indicates simpler, more maintainable code."
    direction: minimize
    unit: count
    measurement_method: automated
    formula: "sum(function_complexity) / count(functions)"
  - name: duplication_ratio
    description: "Percentage of code that exists as duplicated blocks (>= 6 lines identical). Lower is better."
    direction: minimize
    unit: percentage
    measurement_method: automated
    formula: "duplicated_lines / total_lines * 100"
  - name: file_size_compliance
    description: "Percentage of files in scope that are under 400 lines. Higher means better modularization."
    direction: maximize
    unit: percentage
    measurement_method: automated
    formula: "files_under_400_lines / total_files * 100"

mutation_targets:
  defaults:
    - path: "src/**"
      description: "Source code files — primary refactoring target"
    - path: "lib/**"
      description: "Library code — secondary target"
  immutable:
    - path: "tests/**"
    - path: "test/**"
    - path: "spec/**"
    - path: "__tests__/**"
    - path: ".git/**"
    - path: "node_modules/**"
    - path: "vendor/**"
    - path: "*.lock"
    - path: "package-lock.json"
    - path: "yarn.lock"

connectors:
  required:
    - "~~sequential-thinking"
  optional: []
---

# Code Refactoring Improvement Instructions

## MEASURE Phase

Calculate code quality metrics for all files in the mutation scope:

1. **Identify language** — detect the primary programming language(s) from file extensions
2. **Calculate cyclomatic complexity** — use language-appropriate tools:
   - Python: `radon cc` or AST-based analysis
   - JavaScript/TypeScript: count decision points (if, else, for, while, switch cases, &&, ||, ?:)
   - Go: count branching statements
   - For other languages: count `if`, `for`, `while`, `switch`, `case`, `&&`, `||`, `?:`, `catch` tokens
3. **Detect duplicated blocks** — find sequences of >= 6 identical non-blank lines across files
4. **Measure file sizes** — count lines per file (excluding blank lines and comments)

`Read references/quality-metrics.md` for detailed calculation methods.

## ANALYZE Phase

Interpret the metrics in context:

- **cyclomatic_complexity > 15 average**: Code is highly complex. Focus on the functions with complexity > 20 first.
- **cyclomatic_complexity 8-15**: Moderate. Target functions above 10 for extraction or simplification.
- **cyclomatic_complexity < 8**: Good baseline. Look for subtle improvements.

- **duplication_ratio > 10%**: Significant duplication. Identify the most duplicated patterns.
- **duplication_ratio 3-10%**: Moderate. Focus on semantic duplication (same logic, different names).
- **duplication_ratio < 3%**: Low. Check for near-duplicates that could be parameterized.

- **file_size_compliance < 70%**: Many oversized files. Identify files > 400 lines and their natural split points.
- **file_size_compliance 70-90%**: Getting there. Focus on the largest remaining files.
- **file_size_compliance > 90%**: Well-modularized.

Look for correlations: large files often have high complexity and duplication.

## HYPOTHESIZE Phase

Common root causes for poor code quality:

1. **God objects/files** — a single file that does too much
2. **Copy-paste programming** — duplicated code that should be extracted
3. **Deep nesting** — nested conditionals instead of early returns
4. **Feature envy** — functions that operate mostly on another module's data
5. **Primitive obsession** — using raw types instead of domain objects
6. **Long parameter lists** — functions taking >4 parameters

## PROPOSE Phase

`Read references/refactoring-catalog.md`

Appropriate refactoring patterns:

- **Extract function** — pull a block of code into a named function
- **Extract module/file** — split a large file by responsibility
- **Replace conditional with polymorphism** — reduce switch/if chains
- **Introduce early return** — reduce nesting depth
- **Extract common code** — deduplicate by creating shared utilities
- **Rename for clarity** — improve naming to reduce need for comments

**Constraints:**
- ONE refactoring per iteration — atomic changes that can be verified independently
- MUST NOT change behavior — all refactorings are behavior-preserving
- MUST NOT touch test files — tests validate that behavior is preserved
- Prefer the smallest refactoring that meaningfully improves a KPI
- If the user has tests, suggest running them after APPLY

## APPLY Phase

When applying refactoring changes:
- Read the full file before editing (understand context)
- Use `Edit` for targeted changes, `Write` only for new files (extractions)
- Preserve existing formatting style (indentation, quotes, semicolons)
- Update imports/requires when extracting to new files
- Do NOT add new comments, type annotations, or documentation (scope creep)

## VERIFY Phase

After applying the refactoring:
1. Re-run the measurement tool to check KPIs
2. If the project has a build/compile step, verify it still passes
3. If the project has tests, suggest the user run them (supervised mode)
4. Check that no new linting errors were introduced
