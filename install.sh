#!/bin/sh
# Install bmor from GitHub Releases.
# Usage: curl -fsSL https://raw.githubusercontent.com/branchmore/cli/master/install.sh | sh
set -e

REPO="branchmore/cli"
BINARY="bmor"

# ── detect OS ──────────────────────────────────────────────────────────────────
OS="$(uname -s)"
case "$OS" in
  Linux)  OS="linux"  ;;
  Darwin) OS="darwin" ;;
  *)
    echo "Unsupported OS: $OS" >&2
    exit 1
    ;;
esac

# ── detect arch ────────────────────────────────────────────────────────────────
ARCH="$(uname -m)"
case "$ARCH" in
  x86_64)          ARCH="amd64" ;;
  aarch64 | arm64) ARCH="arm64" ;;
  *)
    echo "Unsupported architecture: $ARCH" >&2
    exit 1
    ;;
esac

# ── resolve latest version ─────────────────────────────────────────────────────
if command -v curl >/dev/null 2>&1; then
  FETCH="curl -fsSL"
elif command -v wget >/dev/null 2>&1; then
  FETCH="wget -qO-"
else
  echo "Neither curl nor wget found. Please install one and retry." >&2
  exit 1
fi

echo "Fetching latest release info..."
LATEST_JSON="$($FETCH "https://api.github.com/repos/${REPO}/releases/latest")"
VERSION="$(echo "$LATEST_JSON" | grep '"tag_name"' | head -1 | sed 's/.*"tag_name": *"\(.*\)".*/\1/')"
VERSION="${VERSION#v}"  # strip leading "v" to match GoReleaser archive names (e.g. v1.2.3 → 1.2.3)

if [ -z "$VERSION" ]; then
  echo "Could not determine latest version." >&2
  exit 1
fi

echo "Installing bmor v${VERSION} (${OS}/${ARCH})..."

# ── build download URLs ────────────────────────────────────────────────────────
ARCHIVE="${BINARY}_${VERSION}_${OS}_${ARCH}.tar.gz"
BASE_URL="https://github.com/${REPO}/releases/download/v${VERSION}"
ARCHIVE_URL="${BASE_URL}/${ARCHIVE}"
CHECKSUMS_URL="${BASE_URL}/checksums.txt"

# ── download to temp dir ───────────────────────────────────────────────────────
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

$FETCH "$ARCHIVE_URL"   > "${TMP}/${ARCHIVE}"
$FETCH "$CHECKSUMS_URL" > "${TMP}/checksums.txt"

# ── verify checksum ────────────────────────────────────────────────────────────
EXPECTED_SUM="$(grep "  ${ARCHIVE}" "${TMP}/checksums.txt" | awk '{print $1}')"
if [ -n "$EXPECTED_SUM" ]; then
  if command -v sha256sum >/dev/null 2>&1; then
    ACTUAL_SUM="$(sha256sum "${TMP}/${ARCHIVE}" | awk '{print $1}')"
  elif command -v shasum >/dev/null 2>&1; then
    ACTUAL_SUM="$(shasum -a 256 "${TMP}/${ARCHIVE}" | awk '{print $1}')"
  else
    echo "Warning: neither sha256sum nor shasum found — skipping checksum verification." >&2
    ACTUAL_SUM=""
  fi
  if [ -n "$ACTUAL_SUM" ] && [ "$ACTUAL_SUM" != "$EXPECTED_SUM" ]; then
    echo "Checksum mismatch for ${ARCHIVE}!" >&2
    echo "  Expected: $EXPECTED_SUM" >&2
    echo "  Got:      $ACTUAL_SUM" >&2
    exit 1
  fi
fi

# ── extract ────────────────────────────────────────────────────────────────────
tar -xzf "${TMP}/${ARCHIVE}" -C "$TMP"

# ── install ────────────────────────────────────────────────────────────────────
install_to() {
  INSTALL_DIR="$1"
  NEED_SUDO="$2"
  mkdir -p "$INSTALL_DIR" 2>/dev/null || true
  if [ "$NEED_SUDO" = "yes" ]; then
    sudo install -m 755 "${TMP}/${BINARY}" "${INSTALL_DIR}/${BINARY}"
  else
    install -m 755 "${TMP}/${BINARY}" "${INSTALL_DIR}/${BINARY}"
  fi
}

# Prefer ~/.local/bin (no sudo, user-scoped).
LOCAL_BIN="${HOME}/.local/bin"
if install_to "$LOCAL_BIN" "no" 2>/dev/null; then
  INSTALLED_AT="${LOCAL_BIN}/${BINARY}"
  # Warn if ~/.local/bin is not on PATH.
  case ":${PATH}:" in
    *":${LOCAL_BIN}:"*) ;;
    *)
      echo ""
      echo "Note: ${LOCAL_BIN} is not on your PATH."
      echo "Add the following to your shell profile (~/.bashrc, ~/.zshrc, etc.):"
      echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
      ;;
  esac
else
  # Fall back to /usr/local/bin (requires sudo).
  if install_to "/usr/local/bin" "yes" 2>/dev/null; then
    INSTALLED_AT="/usr/local/bin/${BINARY}"
  else
    echo "Could not install to ${LOCAL_BIN} or /usr/local/bin." >&2
    echo "Try running with sudo, or install manually from:" >&2
    echo "  ${ARCHIVE_URL}" >&2
    exit 1
  fi
fi

echo ""
echo "Installed: ${INSTALLED_AT}"
echo "Run: ${BINARY} init"
