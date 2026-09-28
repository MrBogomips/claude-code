# Refactoring Catalog — Safe Behavior-Preserving Patterns

Each refactoring is atomic and behavior-preserving. Apply ONE per iteration.

## Complexity Reducers

### Extract Function
**When:** A block of code inside a function has a clear purpose
**Effect:** Reduces cyclomatic complexity of the parent function

### Introduce Early Return
**When:** Deep nesting from guard conditions
**Effect:** Reduces nesting depth and perceived complexity

### Replace Conditional with Polymorphism
**When:** Multiple if/switch branches doing different things based on type
**Effect:** Eliminates branching, distributes logic to appropriate classes

### Decompose Conditional
**When:** Complex boolean expression in a condition
**Effect:** Improves readability and reduces McCabe complexity

## Duplication Reducers

### Extract Common Code
**When:** Same code block appears in 2+ places
**Effect:** Directly reduces duplication_ratio

### Pull Up Common Code
**When:** Subclasses/implementations share identical code
**Effect:** Reduces duplication in class hierarchies

### Parameterize Method
**When:** Two methods do the same thing with slightly different values
**Effect:** Eliminates near-duplication

## File Size Reducers

### Extract Module
**When:** A file exceeds 400 lines and has identifiable sections
**Effect:** Directly improves file_size_compliance
**Note:** Re-export moved symbols from the original file if it is a public API (backward compatibility).

### Move Function to Caller's Module
**When:** A function in a large file is only used by one other module
**Effect:** Reduces file size, improves cohesion

## Safety Rules

1. **Never change behavior** — the refactored code must produce identical outputs for identical inputs
2. **Never change public APIs** — function signatures, export lists, and type definitions must remain compatible
3. **Never touch tests** — tests are the safety net, not the target
4. **One refactoring per iteration** — compound changes are harder to verify and revert
5. **Read before editing** — always read the full file to understand context
6. **Preserve style** — match existing indentation, naming conventions, and formatting
