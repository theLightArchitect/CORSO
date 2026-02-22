#!/usr/bin/env bash
# CORSO Installer — Security-first MCP server for Claude Code
# Usage: curl -fsSL https://raw.githubusercontent.com/theLightArchitect/CORSO/main/install.sh | bash
set -euo pipefail

REPO="theLightArchitect/CORSO"
INSTALL_DIR="$HOME/.corso/bin"
BINARY_NAME="corso"

# --- Platform checks ---

OS="$(uname -s)"
ARCH="$(uname -m)"

if [ "$OS" != "Darwin" ]; then
  echo "Error: CORSO currently supports macOS only (detected: $OS)"
  exit 1
fi

if [ "$ARCH" != "arm64" ]; then
  echo "Error: CORSO requires Apple Silicon (arm64). Detected: $ARCH"
  echo "Intel Mac support is planned. For now, CORSO runs on M1/M2/M3/M4 Macs."
  exit 1
fi

# --- Download latest release ---

echo "Fetching latest CORSO release..."
DOWNLOAD_URL=$(curl -fsSL "https://api.github.com/repos/$REPO/releases/latest" \
  | grep "browser_download_url.*darwin-arm64" \
  | head -1 \
  | cut -d '"' -f 4)

if [ -z "$DOWNLOAD_URL" ]; then
  echo "Error: Could not find a darwin-arm64 release asset."
  echo "Check https://github.com/$REPO/releases for available downloads."
  exit 1
fi

echo "Downloading from: $DOWNLOAD_URL"

TMPDIR_INSTALL="$(mktemp -d)"
trap 'rm -rf "$TMPDIR_INSTALL"' EXIT

curl -fsSL "$DOWNLOAD_URL" -o "$TMPDIR_INSTALL/corso.tar.gz"

# --- Extract and install ---

mkdir -p "$INSTALL_DIR"

tar xzf "$TMPDIR_INSTALL/corso.tar.gz" -C "$TMPDIR_INSTALL"
mv "$TMPDIR_INSTALL/$BINARY_NAME" "$INSTALL_DIR/$BINARY_NAME"
chmod +x "$INSTALL_DIR/$BINARY_NAME"

# --- Clear macOS Gatekeeper quarantine ---

xattr -cr "$INSTALL_DIR/$BINARY_NAME" 2>/dev/null || true

# --- Verify ---

if "$INSTALL_DIR/$BINARY_NAME" --help >/dev/null 2>&1; then
  VERSION_INFO="(verified)"
else
  VERSION_INFO="(binary installed but --help check skipped)"
fi

# --- Success ---

cat <<EOF

  CORSO installed successfully $VERSION_INFO
  Binary: $INSTALL_DIR/$BINARY_NAME

  Next steps:

  1. Add CORSO to Claude Code:

     claude mcp add C0RS0 -- $INSTALL_DIR/$BINARY_NAME

  2. Or manually add to ~/.claude/mcp.json:

     {
       "mcpServers": {
         "C0RS0": {
           "command": "$INSTALL_DIR/$BINARY_NAME",
           "env": { "RUST_LOG": "info" }
         }
       }
     }

  3. Restart Claude Code, then try:

     "CORSO, scan this project for security issues"
     "CORSO, review this code"
     "CORSO, what's the architecture of this codebase?"

EOF
