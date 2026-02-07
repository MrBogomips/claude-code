---
title: Skills Overview
---

# Skills

Skills provide reusable knowledge and workflows that extend Claude Code's capabilities. Unlike commands (which are directly invoked) or agents (which run autonomously), skills give Claude contextual knowledge it can draw on during conversations.

## What Are Skills?

Skills are ideal for:

- **Coding standards and best practices** — teach Claude your team's conventions
- **Domain-specific knowledge** — provide context about your business logic
- **Reusable workflows** — define step-by-step processes Claude can follow
- **Reference documentation** — make specialized knowledge available on demand

## Skill Structure

Each skill lives in a subdirectory under `skills/` and contains a `SKILL.md` file with YAML frontmatter:

```yaml
---
name: my-skill
description: What this skill provides
user_invocable: true
---

# Skill Content

The knowledge and guidance this skill provides...
```

Skills can also include a `references/` directory for supporting materials that Claude loads on demand.

## Available Skills

Browse the skills in this marketplace:
