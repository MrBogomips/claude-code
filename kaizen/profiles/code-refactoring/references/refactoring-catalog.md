# Refactoring Catalog — Safe Behavior-Preserving Patterns

Each refactoring is atomic and behavior-preserving. Apply ONE per iteration.

## Complexity Reducers

### Extract Function
**When:** A block of code inside a function has a clear purpose
**Effect:** Reduces cyclomatic complexity of the parent function
**Steps:**
1. Identify the block and its inputs/outputs
2. Create a new function with a descriptive name
3. Move the block to the new function
4. Replace the block with a call to the new function
5. Pass inputs as parameters, return outputs

### Introduce Early Return
**When:** Deep nesting from guard conditions
**Effect:** Reduces nesting depth and perceived complexity
**Steps:**
1. Identify guard conditions (null checks, validation, error cases)
2. Invert the condition and return/throw early
3. Remove the else branch and reduce indentation

### Replace Conditional with Polymorphism
**When:** Multiple if/switch branches doing different things based on type
**Effect:** Eliminates branching, distributes logic to appropriate classes
**Steps:**
1. Identify the type-based branching
2. Create an interface/abstract class
3. Implement one concrete class per branch
4. Replace the conditional with a method call on the polymorphic object

### Decompose Conditional
**When:** Complex boolean expression in a condition
**Effect:** Improves readability and reduces McCabe complexity
**Steps:**
1. Extract each part of the condition into a named boolean variable or function
2. Replace the complex expression with the named variables

## Duplication Reducers

### Extract Common Code
**When:** Same code block appears in 2+ places
**Effect:** Directly reduces duplication_ratio
**Steps:**
1. Identify the duplicated block
2. Create a shared function/utility
3. Replace all occurrences with calls to the shared function
4. Parameterize any differences between the occurrences

### Pull Up Common Code
**When:** Subclasses/implementations share identical code
**Effect:** Reduces duplication in class hierarchies
**Steps:**
1. Identify the shared code in subclasses
2. Move it to the parent class
3. Remove the duplicated code from subclasses

### Parameterize Method
**When:** Two methods do the same thing with slightly different values
**Effect:** Eliminates near-duplication
**Steps:**
1. Identify the differences between the two methods
2. Add parameters for the differing values
3. Merge into a single parameterized method
4. Update all callers

## File Size Reducers

### Extract Module
**When:** A file exceeds 400 lines and has identifiable sections
**Effect:** Directly improves file_size_compliance
**Steps:**
1. Identify cohesive groups of functions/classes
2. Create a new file for each group
3. Move the code to the new files
4. Update imports in the original file and all consumers
5. Re-export from the original file if it's a public API (backward compatibility)

### Move Function to Caller's Module
**When:** A function in a large file is only used by one other module
**Effect:** Reduces file size, improves cohesion
**Steps:**
1. Identify functions with a single caller in another file
2. Move the function to the caller's file
3. Remove the export from the original file
4. Update imports

## Safety Rules

1. **Never change behavior** — the refactored code must produce identical outputs for identical inputs
2. **Never change public APIs** — function signatures, export lists, and type definitions must remain compatible
3. **Never touch tests** — tests are the safety net, not the target
4. **One refactoring per iteration** — compound changes are harder to verify and revert
5. **Read before editing** — always read the full file to understand context
6. **Preserve style** — match existing indentation, naming conventions, and formatting
