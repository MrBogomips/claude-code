---
description: Review code for quality, bugs, and improvements
user_invocable: true
arguments:
  - name: file
    description: File path to review (optional - will use current context if not provided)
    required: false
  - name: focus
    description: "Focus area: security, performance, style, or all"
    required: false
---

# Code Review Command

Perform a thorough code review with actionable feedback.

## Instructions

When this command is invoked:

1. **Identify the target code**
   - If `$ARGUMENTS` includes a file path, read that file
   - If no file specified, review any code from recent context
   - If no code is available, ask the user to specify a file

2. **Analyze the code** based on focus area:
   - **security**: Look for vulnerabilities (injection, XSS, auth issues, secrets)
   - **performance**: Identify inefficiencies, unnecessary operations, memory issues
   - **style**: Check naming, formatting, code organization, readability
   - **all** (default): Review all aspects

3. **Structure your review**:

```markdown
## Code Review: [filename]

### Summary
[1-2 sentence overview]

### Issues Found

#### Critical
- [Issue description with line reference]

#### Warnings
- [Issue description]

#### Suggestions
- [Improvement ideas]

### What's Good
- [Positive observations]
```

4. **Be constructive**: Focus on actionable improvements, not just criticism

## Example usage

- `/example-commands:review-code` - Review code from current context
- `/example-commands:review-code src/auth.js` - Review specific file
- `/example-commands:review-code src/api.ts security` - Security-focused review
