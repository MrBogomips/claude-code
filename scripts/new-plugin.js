#!/usr/bin/env node

/**
 * Interactive Plugin Scaffolding Tool
 * Creates a new plugin with the selected components
 */

import { createInterface } from 'node:readline';
import { mkdir, writeFile } from 'node:fs/promises';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const ROOT_DIR = join(__dirname, '..');
const PLUGINS_DIR = join(ROOT_DIR, 'plugins');

const rl = createInterface({
  input: process.stdin,
  output: process.stdout
});

function question(prompt) {
  return new Promise(resolve => {
    rl.question(prompt, resolve);
  });
}

function questionYN(prompt, defaultValue = true) {
  const hint = defaultValue ? '[Y/n]' : '[y/N]';
  return new Promise(resolve => {
    rl.question(`${prompt} ${hint}: `, answer => {
      if (answer.trim() === '') {
        resolve(defaultValue);
      } else {
        resolve(answer.toLowerCase().startsWith('y'));
      }
    });
  });
}

async function main() {
  console.log('\n🔧 Claude Code Plugin Scaffolding Tool\n');
  console.log('This tool will help you create a new plugin.\n');

  // Get plugin name
  let pluginName = '';
  while (!pluginName) {
    pluginName = await question('Plugin name (kebab-case, e.g., my-awesome-plugin): ');
    pluginName = pluginName.trim().toLowerCase().replace(/\s+/g, '-');

    if (!/^[a-z][a-z0-9-]*$/.test(pluginName)) {
      console.log('  ❌ Invalid name. Use lowercase letters, numbers, and hyphens.');
      pluginName = '';
    }
  }

  // Get description
  const description = await question('Description: ') || `A Claude Code plugin`;

  // Get author info
  const authorName = await question('Author name: ') || 'Anonymous';
  const authorEmail = await question('Author email (optional): ');

  // Select components
  console.log('\nWhich components do you want to include?\n');
  const includeCommands = await questionYN('  Commands (slash commands)');
  const includeAgents = await questionYN('  Agents (custom subagents)');
  const includeSkills = await questionYN('  Skills (reusable knowledge)');
  const includeHooks = await questionYN('  Hooks (event handlers)');

  // Confirm
  console.log('\n📋 Summary:');
  console.log(`  Name: ${pluginName}`);
  console.log(`  Description: ${description}`);
  console.log(`  Author: ${authorName}${authorEmail ? ` <${authorEmail}>` : ''}`);
  console.log(`  Components: ${[
    includeCommands && 'commands',
    includeAgents && 'agents',
    includeSkills && 'skills',
    includeHooks && 'hooks'
  ].filter(Boolean).join(', ') || 'none'}`);

  const proceed = await questionYN('\nCreate plugin?');
  if (!proceed) {
    console.log('Cancelled.');
    rl.close();
    return;
  }

  // Create plugin directory structure
  const pluginDir = join(PLUGINS_DIR, pluginName);

  try {
    // Create directories
    await mkdir(join(pluginDir, '.claude-plugin'), { recursive: true });

    if (includeCommands) {
      await mkdir(join(pluginDir, 'commands'), { recursive: true });
    }
    if (includeAgents) {
      await mkdir(join(pluginDir, 'agents', 'sample-agent'), { recursive: true });
    }
    if (includeSkills) {
      await mkdir(join(pluginDir, 'skills', 'sample-skill'), { recursive: true });
    }
    if (includeHooks) {
      await mkdir(join(pluginDir, 'hooks'), { recursive: true });
    }

    // Create plugin.json
    const pluginJson = {
      name: pluginName,
      version: '1.0.0',
      description,
      author: {
        name: authorName,
        ...(authorEmail && { email: authorEmail })
      },
      license: 'MIT',
      keywords: ['claude-code', 'plugin'],
      repository: {
        type: 'git',
        url: 'https://github.com/MrBogomips/claude-code'
      }
    };
    await writeFile(
      join(pluginDir, '.claude-plugin', 'plugin.json'),
      JSON.stringify(pluginJson, null, 2) + '\n'
    );

    // Create README.md
    const readme = `# ${pluginName}

${description}

## Installation

Add this plugin to your Claude Code configuration:

\`\`\`bash
claude --plugin-dir /path/to/${pluginName}
\`\`\`

${includeCommands ? `## Commands

- \`/${pluginName}:sample\` - A sample command

` : ''}${includeAgents ? `## Agents

- \`sample-agent\` - A sample agent

` : ''}${includeSkills ? `## Skills

- \`sample-skill\` - A sample skill

` : ''}${includeHooks ? `## Hooks

This plugin includes hooks for:
- [List your hooks here]

` : ''}## License

MIT
`;
    await writeFile(join(pluginDir, 'README.md'), readme);

    // Create sample components
    if (includeCommands) {
      const sampleCommand = `---
description: A sample command
user_invocable: true
---

# Sample Command

This is a sample command. Replace this with your actual command implementation.

## What to do

Describe what this command should do when invoked.
`;
      await writeFile(join(pluginDir, 'commands', 'sample.md'), sampleCommand);
    }

    if (includeAgents) {
      const sampleAgent = `---
name: sample-agent
description: A sample agent that demonstrates agent structure
tools:
  - Glob
  - Grep
  - Read
model: sonnet
---

# Sample Agent

You are a sample agent. Replace this with your actual agent implementation.

## Capabilities

Describe what this agent can do.

## Guidelines

Provide guidelines for how the agent should behave.
`;
      await writeFile(join(pluginDir, 'agents', 'sample-agent', 'AGENT.md'), sampleAgent);
    }

    if (includeSkills) {
      const sampleSkill = `---
name: sample-skill
description: A sample skill that demonstrates skill structure
user_invocable: true
---

# Sample Skill

This is a sample skill. Replace this with your actual skill content.

## When to Apply

Describe when Claude should use this skill.

## Knowledge

Provide the knowledge and guidance this skill offers.
`;
      await writeFile(join(pluginDir, 'skills', 'sample-skill', 'SKILL.md'), sampleSkill);
    }

    if (includeHooks) {
      const sampleHooks = {
        hooks: [
          {
            event: 'SessionStart',
            hook: {
              type: 'prompt',
              prompt: `Plugin ${pluginName} loaded. Add your session start instructions here.`
            }
          }
        ]
      };
      await writeFile(
        join(pluginDir, 'hooks', 'hooks.json'),
        JSON.stringify(sampleHooks, null, 2) + '\n'
      );
    }

    console.log(`\n✅ Plugin created at: plugins/${pluginName}/`);
    console.log('\nNext steps:');
    console.log(`  1. Edit the files in plugins/${pluginName}/`);
    console.log('  2. Run "npm run validate" to check your plugin');
    console.log('  3. Add your plugin to .claude-plugin/marketplace.json');
    console.log(`  4. Test with: claude --plugin-dir ./plugins/${pluginName}`);

  } catch (err) {
    console.error(`\n❌ Error creating plugin: ${err.message}`);
    process.exit(1);
  }

  rl.close();
}

main().catch(err => {
  console.error('Fatal error:', err);
  process.exit(1);
});
