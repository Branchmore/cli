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

#### MacOS: troubleshooting `"bmor" Not Opened`

If MacOS shows a popup with that title and text like `Apple could not verify "bmor" is free of malware that may harm your Mac or compromise your privacy"`, you can follow [these instructions](https://support.apple.com/en-sa/guide/mac-help/mchleab3a043/mac) on Apple's Mac User Guide:

  1. On your Mac, choose Apple menu  > System Settings, then click Privacy & Security in the sidebar. (You may need to scroll down.)

  2. Go to Security, then click Open.

  3. Click Open Anyway.

      3.1. This button is available for about an hour after you try to open the app.

  4. Enter your login password, then click OK.

This warning is expected, because we are a small and early software publisher. We plan to set up our Apple Developer processes as our software matures.

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
