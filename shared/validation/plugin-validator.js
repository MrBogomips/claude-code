/**
 * Plugin Validator
 * Validates Claude Code plugin structure and manifests
 */

import { readdir, readFile, stat } from 'node:fs/promises';
import { join, basename } from 'node:path';

/**
 * Required fields in plugin.json
 */
const REQUIRED_PLUGIN_FIELDS = ['name', 'version', 'description'];

/**
 * Valid component directories in a plugin
 */
const VALID_COMPONENTS = ['commands', 'agents', 'skills', 'hooks'];

/**
 * Validates a single plugin directory
 * @param {string} pluginPath - Path to the plugin directory
 * @returns {Promise<{valid: boolean, errors: string[], warnings: string[]}>}
 */
export async function validatePlugin(pluginPath) {
  const errors = [];
  const warnings = [];
  const pluginName = basename(pluginPath);

  // Check for .claude-plugin directory
  const manifestDir = join(pluginPath, '.claude-plugin');
  const manifestPath = join(manifestDir, 'plugin.json');

  try {
    await stat(manifestDir);
  } catch {
    errors.push(`Missing .claude-plugin directory in ${pluginName}`);
    return { valid: false, errors, warnings };
  }

  // Check for plugin.json
  let manifest;
  try {
    const content = await readFile(manifestPath, 'utf-8');
    manifest = JSON.parse(content);
  } catch (err) {
    if (err.code === 'ENOENT') {
      errors.push(`Missing plugin.json in ${pluginName}/.claude-plugin/`);
    } else if (err instanceof SyntaxError) {
      errors.push(`Invalid JSON in ${pluginName}/.claude-plugin/plugin.json: ${err.message}`);
    } else {
      errors.push(`Error reading plugin.json in ${pluginName}: ${err.message}`);
    }
    return { valid: false, errors, warnings };
  }

  // Validate required fields
  for (const field of REQUIRED_PLUGIN_FIELDS) {
    if (!manifest[field]) {
      errors.push(`Missing required field '${field}' in ${pluginName}/plugin.json`);
    }
  }

  // Check for README
  try {
    await stat(join(pluginPath, 'README.md'));
  } catch {
    warnings.push(`Missing README.md in ${pluginName}`);
  }

  // Validate component directories if they exist
  const entries = await readdir(pluginPath, { withFileTypes: true });
  const directories = entries.filter(e => e.isDirectory()).map(e => e.name);

  for (const dir of directories) {
    if (dir === '.claude-plugin' || dir === 'node_modules') continue;

    if (!VALID_COMPONENTS.includes(dir) && dir !== 'references') {
      warnings.push(`Unknown directory '${dir}' in ${pluginName} (expected: ${VALID_COMPONENTS.join(', ')})`);
    }
  }

  // Validate commands if present
  if (directories.includes('commands')) {
    const commandsPath = join(pluginPath, 'commands');
    const commandFiles = await readdir(commandsPath);
    const mdFiles = commandFiles.filter(f => f.endsWith('.md'));

    if (mdFiles.length === 0) {
      warnings.push(`Commands directory in ${pluginName} contains no .md files`);
    }
  }

  // Validate agents if present
  if (directories.includes('agents')) {
    const agentsPath = join(pluginPath, 'agents');
    const agentDirs = await readdir(agentsPath, { withFileTypes: true });

    for (const agentDir of agentDirs.filter(d => d.isDirectory())) {
      const agentMdPath = join(agentsPath, agentDir.name, 'AGENT.md');
      try {
        await stat(agentMdPath);
      } catch {
        errors.push(`Missing AGENT.md in ${pluginName}/agents/${agentDir.name}/`);
      }
    }
  }

  // Validate skills if present
  if (directories.includes('skills')) {
    const skillsPath = join(pluginPath, 'skills');
    const skillDirs = await readdir(skillsPath, { withFileTypes: true });

    for (const skillDir of skillDirs.filter(d => d.isDirectory())) {
      const skillMdPath = join(skillsPath, skillDir.name, 'SKILL.md');
      try {
        await stat(skillMdPath);
      } catch {
        errors.push(`Missing SKILL.md in ${pluginName}/skills/${skillDir.name}/`);
      }
    }
  }

  // Validate hooks if present
  if (directories.includes('hooks')) {
    const hooksPath = join(pluginPath, 'hooks');
    const hooksJsonPath = join(hooksPath, 'hooks.json');

    try {
      const content = await readFile(hooksJsonPath, 'utf-8');
      JSON.parse(content);
    } catch (err) {
      if (err.code === 'ENOENT') {
        errors.push(`Missing hooks.json in ${pluginName}/hooks/`);
      } else if (err instanceof SyntaxError) {
        errors.push(`Invalid JSON in ${pluginName}/hooks/hooks.json: ${err.message}`);
      }
    }
  }

  return {
    valid: errors.length === 0,
    errors,
    warnings
  };
}

/**
 * Validates marketplace.json
 * @param {string} marketplacePath - Path to marketplace.json
 * @returns {Promise<{valid: boolean, errors: string[], warnings: string[]}>}
 */
export async function validateMarketplace(marketplacePath) {
  const errors = [];
  const warnings = [];

  let manifest;
  try {
    const content = await readFile(marketplacePath, 'utf-8');
    manifest = JSON.parse(content);
  } catch (err) {
    if (err.code === 'ENOENT') {
      errors.push('Missing marketplace.json');
    } else if (err instanceof SyntaxError) {
      errors.push(`Invalid JSON in marketplace.json: ${err.message}`);
    } else {
      errors.push(`Error reading marketplace.json: ${err.message}`);
    }
    return { valid: false, errors, warnings };
  }

  // Validate required fields
  if (!manifest.name) {
    errors.push("Missing required field 'name' in marketplace.json");
  }

  if (!manifest.owner || !manifest.owner.name) {
    errors.push("Missing required field 'owner.name' in marketplace.json");
  }

  if (!Array.isArray(manifest.plugins)) {
    errors.push("Missing or invalid 'plugins' array in marketplace.json");
    return { valid: false, errors, warnings };
  }

  // Validate each plugin reference
  for (const plugin of manifest.plugins) {
    if (!plugin.name) {
      errors.push('Plugin entry missing required field: name');
    }
    if (!plugin.source) {
      errors.push(`Plugin '${plugin.name || 'unknown'}' missing required field: source`);
    }
    if (!plugin.description) {
      warnings.push(`Plugin '${plugin.name || 'unknown'}' missing description`);
    }
  }

  return {
    valid: errors.length === 0,
    errors,
    warnings
  };
}

/**
 * Validates all plugins in a directory
 * @param {string} pluginsDir - Path to the plugins directory
 * @returns {Promise<{valid: boolean, results: Map<string, {valid: boolean, errors: string[], warnings: string[]}>}>}
 */
export async function validateAllPlugins(pluginsDir) {
  const results = new Map();
  let allValid = true;

  try {
    const entries = await readdir(pluginsDir, { withFileTypes: true });
    const pluginDirs = entries.filter(e => e.isDirectory());

    for (const dir of pluginDirs) {
      const pluginPath = join(pluginsDir, dir.name);
      const result = await validatePlugin(pluginPath);
      results.set(dir.name, result);

      if (!result.valid) {
        allValid = false;
      }
    }
  } catch (err) {
    if (err.code === 'ENOENT') {
      return { valid: false, results, error: `Plugins directory not found: ${pluginsDir}` };
    }
    throw err;
  }

  return { valid: allValid, results };
}
