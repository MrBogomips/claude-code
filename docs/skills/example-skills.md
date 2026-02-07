---
sidebar_position: 2
sidebar_label: Example Skills
title: Example Skills
---

# Example Skills Plugin

This plugin demonstrates how to create skills for Claude Code.

## Skills

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

## Skill Structure

Skills are defined in subdirectories under `skills/`:

```
skills/
└── code-quality/
    ├── SKILL.md          # Main skill definition
    └── references/       # Supporting materials
        └── best-practices.md
```

Each skill has a `SKILL.md` file with YAML frontmatter:

```yaml
---
name: skill-name
description: What knowledge/capability this skill provides
user_invocable: true
---

# Skill Content

The knowledge and guidance the skill provides...
```

## Skills vs Commands vs Agents

| Component | Purpose | User Interaction |
|-----------|---------|------------------|
| **Commands** | Execute specific actions | Direct invocation via `/` |
| **Skills** | Provide knowledge/context | Claude draws on as needed |
| **Agents** | Autonomous task execution | Invoked via Task tool |

**Skills** are ideal for:
- Coding standards and best practices
- Domain-specific knowledge
- Reusable workflows
- Reference documentation

## Installation

Add this plugin to your Claude Code configuration:

```bash
claude --plugin-dir /path/to/example-skills
```
