/**
 * Plugin Structure Tests
 * Validates that all plugins have the correct directory structure
 */

import { describe, it } from 'node:test';
import assert from 'node:assert';
import { readdir, stat, readFile } from 'node:fs/promises';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const ROOT_DIR = join(__dirname, '..');
const PLUGINS_DIR = join(ROOT_DIR, 'plugins');

describe('Plugin Structure', async () => {
  let pluginDirs = [];

  // Get all plugin directories
  try {
    const entries = await readdir(PLUGINS_DIR, { withFileTypes: true });
    pluginDirs = entries.filter(e => e.isDirectory()).map(e => e.name);
  } catch {
    // Plugins directory might not exist yet
  }

  it('should have at least one plugin', async () => {
    assert.ok(pluginDirs.length > 0, 'No plugins found in plugins/ directory');
  });

  for (const pluginName of pluginDirs) {
    describe(`Plugin: ${pluginName}`, () => {
      const pluginPath = join(PLUGINS_DIR, pluginName);

      it('should have .claude-plugin directory', async () => {
        const manifestDir = join(pluginPath, '.claude-plugin');
        const stats = await stat(manifestDir);
        assert.ok(stats.isDirectory(), '.claude-plugin should be a directory');
      });

      it('should have valid plugin.json', async () => {
        const manifestPath = join(pluginPath, '.claude-plugin', 'plugin.json');
        const content = await readFile(manifestPath, 'utf-8');
        const manifest = JSON.parse(content);

        assert.ok(manifest.name, 'plugin.json must have a name');
        assert.ok(manifest.version, 'plugin.json must have a version');
        assert.ok(manifest.description, 'plugin.json must have a description');
      });

      it('should have README.md', async () => {
        const readmePath = join(pluginPath, 'README.md');
        const stats = await stat(readmePath);
        assert.ok(stats.isFile(), 'README.md should be a file');
      });

      it('should have valid component directories', async () => {
        const validDirs = ['commands', 'agents', 'skills', 'hooks', 'references', '.claude-plugin'];
        const entries = await readdir(pluginPath, { withFileTypes: true });
        const directories = entries.filter(e => e.isDirectory()).map(e => e.name);

        for (const dir of directories) {
          if (dir === 'node_modules') continue;
          assert.ok(
            validDirs.includes(dir),
            `Unknown directory '${dir}' in plugin (expected: ${validDirs.join(', ')})`
          );
        }
      });
    });
  }
});

describe('Commands Validation', async () => {
  let pluginDirs = [];

  try {
    const entries = await readdir(PLUGINS_DIR, { withFileTypes: true });
    pluginDirs = entries.filter(e => e.isDirectory()).map(e => e.name);
  } catch {
    return;
  }

  for (const pluginName of pluginDirs) {
    const commandsPath = join(PLUGINS_DIR, pluginName, 'commands');

    let hasCommands = false;
    try {
      await stat(commandsPath);
      hasCommands = true;
    } catch {
      continue;
    }

    if (hasCommands) {
      describe(`Commands in ${pluginName}`, () => {
        it('should have .md files', async () => {
          const files = await readdir(commandsPath);
          const mdFiles = files.filter(f => f.endsWith('.md'));
          assert.ok(mdFiles.length > 0, 'Commands directory should contain .md files');
        });
      });
    }
  }
});

describe('Agents Validation', async () => {
  let pluginDirs = [];

  try {
    const entries = await readdir(PLUGINS_DIR, { withFileTypes: true });
    pluginDirs = entries.filter(e => e.isDirectory()).map(e => e.name);
  } catch {
    return;
  }

  for (const pluginName of pluginDirs) {
    const agentsPath = join(PLUGINS_DIR, pluginName, 'agents');

    let hasAgents = false;
    try {
      await stat(agentsPath);
      hasAgents = true;
    } catch {
      continue;
    }

    if (hasAgents) {
      describe(`Agents in ${pluginName}`, () => {
        it('should have AGENT.md in each agent directory', async () => {
          const entries = await readdir(agentsPath, { withFileTypes: true });
          const agentDirs = entries.filter(e => e.isDirectory());

          for (const agentDir of agentDirs) {
            const agentMdPath = join(agentsPath, agentDir.name, 'AGENT.md');
            const stats = await stat(agentMdPath);
            assert.ok(stats.isFile(), `Missing AGENT.md in agents/${agentDir.name}/`);
          }
        });
      });
    }
  }
});

describe('Skills Validation', async () => {
  let pluginDirs = [];

  try {
    const entries = await readdir(PLUGINS_DIR, { withFileTypes: true });
    pluginDirs = entries.filter(e => e.isDirectory()).map(e => e.name);
  } catch {
    return;
  }

  for (const pluginName of pluginDirs) {
    const skillsPath = join(PLUGINS_DIR, pluginName, 'skills');

    let hasSkills = false;
    try {
      await stat(skillsPath);
      hasSkills = true;
    } catch {
      continue;
    }

    if (hasSkills) {
      describe(`Skills in ${pluginName}`, () => {
        it('should have SKILL.md in each skill directory', async () => {
          const entries = await readdir(skillsPath, { withFileTypes: true });
          const skillDirs = entries.filter(e => e.isDirectory());

          for (const skillDir of skillDirs) {
            const skillMdPath = join(skillsPath, skillDir.name, 'SKILL.md');
            const stats = await stat(skillMdPath);
            assert.ok(stats.isFile(), `Missing SKILL.md in skills/${skillDir.name}/`);
          }
        });
      });
    }
  }
});

describe('Hooks Validation', async () => {
  let pluginDirs = [];

  try {
    const entries = await readdir(PLUGINS_DIR, { withFileTypes: true });
    pluginDirs = entries.filter(e => e.isDirectory()).map(e => e.name);
  } catch {
    return;
  }

  for (const pluginName of pluginDirs) {
    const hooksPath = join(PLUGINS_DIR, pluginName, 'hooks');

    let hasHooks = false;
    try {
      await stat(hooksPath);
      hasHooks = true;
    } catch {
      continue;
    }

    if (hasHooks) {
      describe(`Hooks in ${pluginName}`, () => {
        it('should have valid hooks.json', async () => {
          const hooksJsonPath = join(hooksPath, 'hooks.json');
          const content = await readFile(hooksJsonPath, 'utf-8');
          const hooks = JSON.parse(content);

          assert.ok(typeof hooks === 'object', 'hooks.json should be a valid JSON object');
        });
      });
    }
  }
});
