# Contributing to MrBogomips Claude Code Marketplace

Thank you for your interest in contributing! This document provides guidelines for contributing plugins and improvements to this marketplace.

## Code of Conduct

Please be respectful and constructive in all interactions. We're all here to make Claude Code better.

## How to Contribute

### Reporting Issues

If you find a bug or have a feature request:

1. Check if an issue already exists
2. Create a new issue with a clear description
3. Include steps to reproduce (for bugs)
4. Suggest a solution if you have one

### Contributing a Plugin

We welcome new plugins that add useful functionality to Claude Code.

#### Before You Start

1. **Check for duplicates** - Make sure a similar plugin doesn't already exist
2. **Plan your plugin** - Consider what components (commands, agents, skills, hooks) you need
3. **Keep it focused** - Plugins should do one thing well

#### Creating Your Plugin

1. **Fork this repository**

2. **Create your plugin**
   ```bash
   npm run new-plugin
   ```

3. **Implement your functionality**
   - Follow the existing patterns in `plugins/example-*`
   - Add clear documentation in your README.md
   - Include helpful examples

4. **Validate your plugin**
   ```bash
   npm run validate
   npm test
   ```

5. **Test with Claude Code**
   ```bash
   claude --plugin-dir ./plugins/your-plugin
   ```

#### Plugin Guidelines

**Do:**
- Keep plugins focused on a single purpose
- Write clear, helpful documentation
- Include examples of usage
- Follow existing code patterns
- Test thoroughly before submitting

**Don't:**
- Create plugins that duplicate existing functionality
- Include sensitive data or credentials
- Create plugins that could be harmful or deceptive
- Ignore validation errors

### Improving Existing Plugins

1. Fork the repository
2. Make your changes
3. Run tests: `npm test`
4. Validate: `npm run validate`
5. Submit a pull request with a clear description

### Improving Infrastructure

For changes to scripts, CI/CD, or marketplace configuration:

1. Discuss major changes in an issue first
2. Make your changes
3. Ensure all tests pass
4. Update documentation if needed

## Pull Request Process

1. **Create a descriptive PR title**
   - `feat: Add code-formatter plugin`
   - `fix: Correct validation for hooks`
   - `docs: Improve README installation section`

2. **Include a clear description**
   - What does this change do?
   - Why is it needed?
   - How was it tested?

3. **Ensure CI passes**
   - All tests must pass
   - Validation must succeed
   - Linting must pass

4. **Respond to feedback**
   - Address review comments
   - Make requested changes

## Plugin Categories

When creating plugins, consider these categories:

| Category | Description |
|----------|-------------|
| Development | Code writing, review, refactoring |
| Documentation | Doc generation, comments, READMEs |
| Testing | Test generation, coverage, validation |
| DevOps | CI/CD, deployment, infrastructure |
| Productivity | Workflow automation, shortcuts |
| Learning | Tutorials, explanations, best practices |

## Component Guidelines

### Commands

- Use clear, descriptive names
- Support optional arguments where sensible
- Provide helpful error messages
- Document all arguments

### Agents

- Define a clear purpose
- Limit tool access to what's needed
- Include detailed system prompts
- Specify the appropriate model

### Skills

- Focus on reusable knowledge
- Organize with references for detailed content
- Make them user-invocable when appropriate
- Include practical examples

### Hooks

- Use appropriate events
- Keep prompts concise and focused
- Test thoroughly to avoid blocking legitimate actions
- Document any side effects

## Questions?

If you have questions about contributing:

1. Check existing documentation
2. Look at example plugins
3. Open an issue for discussion

Thank you for contributing!
