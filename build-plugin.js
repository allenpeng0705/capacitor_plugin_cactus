#!/usr/bin/env node

const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

console.log('Building Cactus Plugin...');

// Step 1: Clean previous build
console.log('Step 1: Cleaning previous build...');
execSync('npm run clean', { stdio: 'inherit' });

// Step 2: Generate documentation
console.log('Step 2: Generating documentation...');
execSync('npm run docgen', { stdio: 'inherit' });

// Step 3: Compile TypeScript with skipLibCheck explicitly set
console.log('Step 3: Compiling TypeScript...');
try {
  // Explicitly set skipLibCheck to true when running tsc
  execSync('npx tsc --skipLibCheck -p tsconfig.json', { stdio: 'inherit' });
} catch (error) {
  console.error('TypeScript compilation failed. Trying with --noEmit...');
  // If compilation fails, try with noEmit to just check our code
  execSync('npx tsc --skipLibCheck --noEmit -p tsconfig.json', { stdio: 'inherit' });
  // But still try to compile the code for Rollup
  execSync('npx tsc --skipLibCheck --noCheckJs -p tsconfig.json', { stdio: 'inherit' });
}

// Step 4: Run Rollup
console.log('Step 4: Running Rollup...');
execSync('npx rollup -c rollup.config.mjs', { stdio: 'inherit' });

console.log('\n✅ Build completed successfully!');
console.log('Plugin built at: dist/');