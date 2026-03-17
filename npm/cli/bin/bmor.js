#!/usr/bin/env node
'use strict';

const { execFileSync } = require('child_process');
const path = require('path');

const PLATFORMS = {
  'darwin-arm64': '@branchmore/cli-darwin-arm64',
  'darwin-x64': '@branchmore/cli-darwin-x64',
  'linux-arm64': '@branchmore/cli-linux-arm64',
  'linux-x64': '@branchmore/cli-linux-x64',
  'win32-x64': '@branchmore/cli-win32-x64',
};

const key = `${process.platform}-${process.arch}`;
const pkgName = PLATFORMS[key];

if (!pkgName) {
  console.error(`bmor: unsupported platform: ${key}`);
  process.exit(1);
}

let pkgJsonPath;
try {
  pkgJsonPath = require.resolve(`${pkgName}/package.json`);
} catch {
  console.error(`bmor: platform package ${pkgName} is not installed`);
  process.exit(1);
}

const binary = path.join(
  path.dirname(pkgJsonPath),
  'bin',
  process.platform === 'win32' ? 'bmor.exe' : 'bmor'
);

try {
  execFileSync(binary, process.argv.slice(2), { stdio: 'inherit' });
} catch (e) {
  process.exit(e.status ?? 1);
}
