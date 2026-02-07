---
sidebar_position: 1
sidebar_label: Example Skills
title: Example Skills
---

# Example Skills Plugin

A plugin demonstrating how to create skills for Claude Code.

> For details on skills in Claude Code, see the [official documentation](https://docs.anthropic.com/en/docs/claude-code/plugins).

## Components

### `code-quality`

Best practices for writing high-quality, maintainable code.

**Usage:**
```
/example-skills:code-quality
```

**What it provides:**
- SOLID principles guidance
- Code smell detection
- Naming conventions
- Refactoring patterns
- Testing best practices

**Key configuration:**

The skill is user-invocable (available as a slash command) and includes a `references/` directory with detailed best-practices material that Claude draws on when the skill is active.

## Installation

```bash
claude --plugin-dir /path/to/example-skills
```
