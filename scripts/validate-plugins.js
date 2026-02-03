#!/usr/bin/env node

/**
 * Plugin Validation Script
 * Validates all plugins in the plugins/ directory
 */

import { validateAllPlugins, validateMarketplace } from '../shared/validation/plugin-validator.js';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const ROOT_DIR = join(__dirname, '..');
const PLUGINS_DIR = join(ROOT_DIR, 'plugins');
const MARKETPLACE_PATH = join(ROOT_DIR, '.claude-plugin', 'marketplace.json');

async function main() {
  console.log('🔍 Validating Claude Code Marketplace\n');

  let hasErrors = false;

  // Validate marketplace.json
  console.log('📋 Validating marketplace.json...');
  const marketplaceResult = await validateMarketplace(MARKETPLACE_PATH);

  if (marketplaceResult.errors.length > 0) {
    hasErrors = true;
    console.log('  ❌ Errors:');
    for (const error of marketplaceResult.errors) {
      console.log(`     - ${error}`);
    }
  }

  if (marketplaceResult.warnings.length > 0) {
    console.log('  ⚠️  Warnings:');
    for (const warning of marketplaceResult.warnings) {
      console.log(`     - ${warning}`);
    }
  }

  if (marketplaceResult.valid) {
    console.log('  ✅ marketplace.json is valid\n');
  } else {
    console.log('');
  }

  // Validate all plugins
  console.log('📦 Validating plugins...\n');
  const pluginsResult = await validateAllPlugins(PLUGINS_DIR);

  if (pluginsResult.error) {
    console.log(`  ❌ ${pluginsResult.error}`);
    hasErrors = true;
  } else {
    for (const [pluginName, result] of pluginsResult.results) {
      console.log(`  ${result.valid ? '✅' : '❌'} ${pluginName}`);

      if (result.errors.length > 0) {
        hasErrors = true;
        for (const error of result.errors) {
          console.log(`     ❌ ${error}`);
        }
      }

      if (result.warnings.length > 0) {
        for (const warning of result.warnings) {
          console.log(`     ⚠️  ${warning}`);
        }
      }
    }
  }

  console.log('');

  // Summary
  if (hasErrors) {
    console.log('❌ Validation failed with errors');
    process.exit(1);
  } else {
    console.log('✅ All validations passed');
    process.exit(0);
  }
}

main().catch(err => {
  console.error('Fatal error:', err);
  process.exit(1);
});
