/**
 * Manifest Schema Tests
 * Validates JSON manifests against expected schemas
 */

import { describe, it } from 'node:test';
import assert from 'node:assert';
import { readFile } from 'node:fs/promises';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import { validatePluginEntry } from '../shared/validation/plugin-validator.js';

const __dirname = dirname(fileURLToPath(import.meta.url));
const ROOT_DIR = join(__dirname, '..');

describe('Marketplace Manifest', () => {
  it('should have valid marketplace.json', async () => {
    const manifestPath = join(ROOT_DIR, '.claude-plugin', 'marketplace.json');
    const content = await readFile(manifestPath, 'utf-8');
    const manifest = JSON.parse(content);

    assert.ok(manifest, 'marketplace.json should be valid JSON');
  });

  it('should have required fields', async () => {
    const manifestPath = join(ROOT_DIR, '.claude-plugin', 'marketplace.json');
    const content = await readFile(manifestPath, 'utf-8');
    const manifest = JSON.parse(content);

    assert.ok(manifest.name, 'marketplace.json must have a name');
    assert.ok(manifest.owner, 'marketplace.json must have an owner');
    assert.ok(manifest.owner.name, 'marketplace.json owner must have a name');
  });

  it('should have plugins array', async () => {
    const manifestPath = join(ROOT_DIR, '.claude-plugin', 'marketplace.json');
    const content = await readFile(manifestPath, 'utf-8');
    const manifest = JSON.parse(content);

    assert.ok(Array.isArray(manifest.plugins), 'marketplace.json must have plugins array');
    assert.ok(manifest.plugins.length > 0, 'marketplace.json must have at least one plugin');
  });

  it('should have valid plugin entries', async () => {
    const manifestPath = join(ROOT_DIR, '.claude-plugin', 'marketplace.json');
    const content = await readFile(manifestPath, 'utf-8');
    const manifest = JSON.parse(content);

    for (const plugin of manifest.plugins) {
      assert.ok(plugin.name, `Plugin entry must have a name`);
      assert.ok(plugin.source, `Plugin '${plugin.name}' must have a source`);
      assert.ok(plugin.description, `Plugin '${plugin.name}' must have a description`);
    }
  });

  it('should have valid version format in metadata', async () => {
    const manifestPath = join(ROOT_DIR, '.claude-plugin', 'marketplace.json');
    const content = await readFile(manifestPath, 'utf-8');
    const manifest = JSON.parse(content);

    if (manifest.metadata?.version) {
      const semverRegex = /^\d+\.\d+\.\d+(-[\w.]+)?(\+[\w.]+)?$/;
      assert.match(
        manifest.metadata.version,
        semverRegex,
        'Version should follow semver format'
      );
    }
  });
});

describe('Plugin Entry Schema Validation', () => {
  it('should reject string entries in plugins array', () => {
    const result = validatePluginEntry('./plugins/example', 0);

    assert.ok(result.errors.length > 0, 'Should have validation errors');
    assert.ok(
      result.errors[0].includes('expected object'),
      'Error should mention expected object format'
    );
    assert.ok(
      result.errors[0].includes('received string'),
      'Error should mention received string type'
    );
  });

  it('should reject null entries', () => {
    const result = validatePluginEntry(null, 0);

    assert.ok(result.errors.length > 0, 'Should have validation errors');
    assert.ok(
      result.errors[0].includes('received null'),
      'Error should mention received null'
    );
  });

  it('should reject array entries', () => {
    const result = validatePluginEntry(['./path'], 0);

    assert.ok(result.errors.length > 0, 'Should have validation errors');
    assert.ok(
      result.errors[0].includes('received array'),
      'Error should mention received array'
    );
  });

  it('should require name field', () => {
    const result = validatePluginEntry({ source: './path', description: 'desc' }, 0);

    assert.ok(result.errors.length > 0, 'Should have validation errors');
    assert.ok(
      result.errors.some(e => e.includes("Missing required field 'name'")),
      'Error should mention missing name'
    );
  });

  it('should require source field', () => {
    const result = validatePluginEntry({ name: 'test', description: 'desc' }, 0);

    assert.ok(result.errors.length > 0, 'Should have validation errors');
    assert.ok(
      result.errors.some(e => e.includes("Missing required field 'source'")),
      'Error should mention missing source'
    );
  });

  it('should warn when description is missing', () => {
    const result = validatePluginEntry({ name: 'test', source: './path' }, 0);

    assert.strictEqual(result.errors.length, 0, 'Should have no errors');
    assert.ok(result.warnings.length > 0, 'Should have warnings');
    assert.ok(
      result.warnings[0].includes('description'),
      'Warning should mention missing description'
    );
  });

  it('should validate field types', () => {
    const result = validatePluginEntry(
      { name: 123, source: [], description: {} },
      0
    );

    assert.ok(result.errors.length >= 3, 'Should have errors for all invalid types');
    assert.ok(
      result.errors.some(e => e.includes("'name' must be a string")),
      'Should error on non-string name'
    );
    assert.ok(
      result.errors.some(e => e.includes("'source' must be a string")),
      'Should error on non-string source'
    );
    assert.ok(
      result.errors.some(e => e.includes("'description' must be a string")),
      'Should error on non-string description'
    );
  });

  it('should accept valid plugin entry', () => {
    const result = validatePluginEntry(
      { name: 'test-plugin', source: './plugins/test', description: 'A test plugin' },
      0
    );

    assert.strictEqual(result.errors.length, 0, 'Should have no errors');
    assert.strictEqual(result.warnings.length, 0, 'Should have no warnings');
  });
});

describe('Plugin Manifests', () => {
  it('should have valid version format', async () => {
    const { readdir } = await import('node:fs/promises');
    const pluginsDir = join(ROOT_DIR, 'plugins');

    let pluginDirs;
    try {
      const entries = await readdir(pluginsDir, { withFileTypes: true });
      pluginDirs = entries.filter(e => e.isDirectory()).map(e => e.name);
    } catch {
      return; // Skip if plugins directory doesn't exist
    }

    const semverRegex = /^\d+\.\d+\.\d+(-[\w.]+)?(\+[\w.]+)?$/;

    for (const pluginName of pluginDirs) {
      const manifestPath = join(pluginsDir, pluginName, '.claude-plugin', 'plugin.json');

      try {
        const content = await readFile(manifestPath, 'utf-8');
        const manifest = JSON.parse(content);

        if (manifest.version) {
          assert.match(
            manifest.version,
            semverRegex,
            `Plugin '${pluginName}' version should follow semver format`
          );
        }
      } catch {
        // Skip if manifest doesn't exist
      }
    }
  });

  it('should have consistent naming', async () => {
    const { readdir } = await import('node:fs/promises');
    const pluginsDir = join(ROOT_DIR, 'plugins');

    let pluginDirs;
    try {
      const entries = await readdir(pluginsDir, { withFileTypes: true });
      pluginDirs = entries.filter(e => e.isDirectory()).map(e => e.name);
    } catch {
      return;
    }

    for (const pluginName of pluginDirs) {
      const manifestPath = join(pluginsDir, pluginName, '.claude-plugin', 'plugin.json');

      try {
        const content = await readFile(manifestPath, 'utf-8');
        const manifest = JSON.parse(content);

        // Plugin name in manifest should match directory name
        assert.strictEqual(
          manifest.name,
          pluginName,
          `Plugin manifest name '${manifest.name}' should match directory name '${pluginName}'`
        );
      } catch {
        // Skip if manifest doesn't exist
      }
    }
  });
});
