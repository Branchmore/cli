# Branchmore CLI

`bmor` is a command-line tool that collects and reports AI coding assistant usage metrics. It tracks how your team uses AI tools, giving you visibility into adoption and productivity across your organization.

## Installation

### curl | sh (Linux & macOS)

The quickest way to install. Downloads the latest release, verifies the checksum, and installs the binary to `~/.local/bin` (or `/usr/local/bin` as a fallback).

```sh
curl -fsSL https://raw.githubusercontent.com/branchmore/cli/master/install.sh | sh
```

If `~/.local/bin` is not on your `PATH`, add this to your shell profile (`~/.bashrc`, `~/.zshrc`, etc.):

```sh
export PATH="$HOME/.local/bin:$PATH"
```

### Homebrew (macOS & Linux)

```sh
brew tap Branchmore/homebrew-tap
brew install bmor
```

### npm

Requires Node.js 14 or later. Installs the correct platform binary automatically.

```sh
npm install -g @branchmore/cli
```

## Usage

After installation, initialize `bmor` to generate default settings, setup hooks, authenticate etc.

```sh
bmor init
```

## Requirements

- macOS or Linux (x64 or arm64), Windows x64
- Node.js ≥ 14 (npm install method only)
