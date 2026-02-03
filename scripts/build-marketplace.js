#!/usr/bin/env node

/**
 * Build Marketplace Script
 * Generates/updates marketplace.json from plugins directory
 */

import { readdir, readFile, writeFile, stat } from 'node:fs/promises';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const ROOT_DIR = join(__dirname, '..');
const PLUGINS_DIR = join(ROOT_DIR, 'plugins');
const MARKETPLACE_PATH = join(ROOT_DIR, '.claude-plugin', 'marketplace.json');

async function main() {
  console.log('🔨 Building marketplace.json\n');

  // Read existing marketplace.json to preserve metadata
  let existingManifest = {};
  try {
    const content = await readFile(MARKETPLACE_PATH, 'utf-8');
    existingManifest = JSON.parse(content);
  } catch {
    console.log('  No existing marketplace.json found, creating new one');
  }

  // Discover plugins
  const plugins = [];
  const entries = await readdir(PLUGINS_DIR, { withFileTypes: true });

  for (const entry of entries) {
    if (!entry.isDirectory()) continue;

    const pluginPath = join(PLUGINS_DIR, entry.name);
    const manifestPath = join(pluginPath, '.claude-plugin', 'plugin.json');

    try {
      const manifestContent = await readFile(manifestPath, 'utf-8');
      const manifest = JSON.parse(manifestContent);

      // Get README description if available
      let longDescription = '';
      try {
        const readme = await readFile(join(pluginPath, 'README.md'), 'utf-8');
        // Extract first paragraph after title
        const match = readme.match(/^#[^\n]+\n+([^\n#]+)/);
        if (match) {
          longDescription = match[1].trim();
        }
      } catch {
        // No README or can't parse it
      }

      // Detect categories based on components
      const components = [];
      try {
        if ((await stat(join(pluginPath, 'commands'))).isDirectory()) {
          components.push('commands');
        }
      } catch { /* no commands */ }

      try {
        if ((await stat(join(pluginPath, 'agents'))).isDirectory()) {
          components.push('agents');
        }
      } catch { /* no agents */ }

      try {
        if ((await stat(join(pluginPath, 'skills'))).isDirectory()) {
          components.push('skills');
        }
      } catch { /* no skills */ }

      try {
        if ((await stat(join(pluginPath, 'hooks'))).isDirectory()) {
          components.push('hooks');
        }
      } catch { /* no hooks */ }

      plugins.push({
        name: manifest.name || entry.name,
        source: `./plugins/${entry.name}`,
        description: manifest.description || longDescription || 'A Claude Code plugin',
        version: manifest.version || '1.0.0',
        components,
        tags: manifest.keywords || []
      });

      console.log(`  ✅ Found: ${entry.name}`);
    } catch (err) {
      console.log(`  ⚠️  Skipping ${entry.name}: ${err.message}`);
    }
  }

  // Build marketplace manifest
  const marketplace = {
    $schema: 'https://anthropic.com/claude-code/marketplace.schema.json',
    name: existingManifest.name || 'mrbogomips-tools',
    owner: existingManifest.owner || {
      name: 'Mr Bogomips',
      email: 'giovanni.costagliola@gmail.com'
    },
    metadata: {
      description: existingManifest.metadata?.description || 'A collection of developer tools and plugins for Claude Code',
      version: existingManifest.metadata?.version || '1.0.0',
      license: existingManifest.metadata?.license || 'MIT',
      generatedAt: new Date().toISOString()
    },
    plugins
  };

  // Write marketplace.json
  await writeFile(MARKETPLACE_PATH, JSON.stringify(marketplace, null, 2) + '\n');

  console.log(`\n✅ Generated marketplace.json with ${plugins.length} plugins`);
}

main().catch(err => {
  console.error('Fatal error:', err);
  process.exit(1);
});
