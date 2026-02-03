---
name: code-quality
description: Best practices for writing high-quality, maintainable code
user_invocable: true
---

# Code Quality Skill

This skill provides guidance on writing high-quality, maintainable code.

## When to Apply

Use this skill when:
- Writing new code
- Reviewing existing code
- Refactoring for quality
- The user asks about best practices

## Core Principles

### 1. Readability First

Code is read far more often than it's written. Prioritize clarity:

- **Meaningful names**: Variables, functions, and classes should describe their purpose
- **Small functions**: Each function should do one thing well
- **Consistent formatting**: Follow the project's style guide
- **Self-documenting code**: Good code explains itself; comments explain "why", not "what"

### 2. SOLID Principles

- **Single Responsibility**: A class/module should have one reason to change
- **Open/Closed**: Open for extension, closed for modification
- **Liskov Substitution**: Subtypes must be substitutable for base types
- **Interface Segregation**: Many specific interfaces over one general interface
- **Dependency Inversion**: Depend on abstractions, not concretions

### 3. Error Handling

- Handle errors at the appropriate level
- Provide meaningful error messages
- Don't swallow exceptions silently
- Use custom error types when appropriate

### 4. Testing

- Write tests before or alongside code
- Test behavior, not implementation
- Keep tests focused and independent
- Aim for meaningful coverage, not 100%

## Code Smells to Avoid

| Smell | Description | Solution |
|-------|-------------|----------|
| Long methods | Functions > 20 lines | Extract smaller functions |
| Deep nesting | > 3 levels of indentation | Early returns, extract methods |
| Magic numbers | Unexplained literal values | Named constants |
| God classes | Classes that do everything | Split responsibilities |
| Duplicate code | Same logic in multiple places | Extract shared function |

## Quick Checklist

Before committing code, verify:

- [ ] Names are clear and descriptive
- [ ] Functions are focused and small
- [ ] Error cases are handled
- [ ] No obvious code smells
- [ ] Tests cover critical paths
- [ ] No sensitive data exposed

## References

See `references/best-practices.md` for detailed examples and patterns.
