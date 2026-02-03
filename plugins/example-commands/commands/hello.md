---
description: A simple greeting command that demonstrates basic slash command structure
user_invocable: true
arguments:
  - name: name
    description: Name to greet (optional)
    required: false
---

# Hello Command

This is a simple example command that greets the user.

## What to do

1. If a name was provided via `$ARGUMENTS`, greet that person by name
2. If no name was provided, give a friendly generic greeting
3. Include a brief tip about Claude Code

## Example responses

If name is "Alice":
> Hello, Alice! Welcome to Claude Code. I'm here to help you with software engineering tasks.

If no name:
> Hello! Welcome to Claude Code. I'm your AI pair programmer, ready to help with coding, debugging, and more.

## Additional context

This command demonstrates:
- Basic slash command structure
- Optional arguments
- User-invocable commands
