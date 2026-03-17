#!/usr/bin/env bash
# Publishes @branchmore/cli and platform packages to npm.
# Downloads binaries from the GitHub Release for the given version.
#
# Usage: VERSION=v1.2.3 npm/publish.sh
# Requires: npm trusted publishing (OIDC) configured, curl, node
set -euo pipefail

VERSION="${VERSION:?VERSION is required (e.g. v1.2.3)}"
# GoReleaser archive names use the version without the leading 'v'
NPM_VERSION="${VERSION#v}"

REPO="branchmore/cli"
RELEASE_URL="https://github.com/${REPO}/releases/download/${VERSION}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Map: npm package dir suffix -> goreleaser archive OS_ARCH suffix
declare -A PLATFORMS=(
  ["cli-darwin-arm64"]="darwin_arm64"
  ["cli-darwin-x64"]="darwin_amd64"
  ["cli-linux-x64"]="linux_amd64"
  ["cli-linux-arm64"]="linux_arm64"
  ["cli-win32-x64"]="windows_amd64"
)

set_version() {
  local pkg_json="$1"
  PKG_JSON="${pkg_json}" SET_VERSION="${NPM_VERSION}" node -e '
    const fs = require("fs");
    const p = JSON.parse(fs.readFileSync(process.env.PKG_JSON, "utf8"));
    p.version = process.env.SET_VERSION;
    if (p.optionalDependencies) {
      for (const k of Object.keys(p.optionalDependencies)) {
        p.optionalDependencies[k] = process.env.SET_VERSION;
      }
    }
    fs.writeFileSync(process.env.PKG_JSON, JSON.stringify(p, null, 2) + "\n");
  '
}

# Determine npm dist-tag: prerelease versions (e.g. 1.0.0-alpha-1) get a tag
# derived from the prerelease identifier; stable versions get "latest".
if [[ "${NPM_VERSION}" == *-* ]]; then
  # Extract prerelease label (e.g. "alpha" from "0.1.0-alpha-6", "beta" from "1.0.0-beta.1")
  NPM_TAG="${NPM_VERSION#*-}"
  NPM_TAG="${NPM_TAG%%[.-]*}"
else
  NPM_TAG="latest"
fi

echo "Publishing @branchmore/cli packages at version ${NPM_VERSION} (tag: ${NPM_TAG})"

# Download binaries and publish platform packages
for PKG_DIR_SUFFIX in "${!PLATFORMS[@]}"; do
  ARCH_SUFFIX="${PLATFORMS[$PKG_DIR_SUFFIX]}"
  PKG_DIR="${SCRIPT_DIR}/${PKG_DIR_SUFFIX}"
  BIN_DIR="${PKG_DIR}/bin"

  mkdir -p "${BIN_DIR}"

  if [[ "${PKG_DIR_SUFFIX}" == *win32* ]]; then
    ARCHIVE="bmor_${NPM_VERSION}_${ARCH_SUFFIX}.zip"
    echo "Downloading ${ARCHIVE}..."
    curl -fSL "${RELEASE_URL}/${ARCHIVE}" -o "/tmp/${ARCHIVE}"
    unzip -p "/tmp/${ARCHIVE}" bmor.exe > "${BIN_DIR}/bmor.exe"
  else
    ARCHIVE="bmor_${NPM_VERSION}_${ARCH_SUFFIX}.tar.gz"
    echo "Downloading ${ARCHIVE}..."
    curl -fSL "${RELEASE_URL}/${ARCHIVE}" -o "/tmp/${ARCHIVE}"
    tar -xzf "/tmp/${ARCHIVE}" -C "${BIN_DIR}" bmor
    chmod +x "${BIN_DIR}/bmor"
  fi

  set_version "${PKG_DIR}/package.json"
  echo "Publishing @branchmore/${PKG_DIR_SUFFIX}@${NPM_VERSION}..."
  npm publish "${PKG_DIR}" --access public --provenance --tag "${NPM_TAG}"
done

# Publish main package last (after platform packages are available)
set_version "${SCRIPT_DIR}/cli/package.json"
echo "Publishing @branchmore/cli@${NPM_VERSION}..."
npm publish "${SCRIPT_DIR}/cli" --access public --provenance --tag "${NPM_TAG}"

echo "Done. All packages published at ${NPM_VERSION}."
