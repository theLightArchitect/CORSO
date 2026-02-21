#!/bin/bash
# PreToolUse hook: security scanning prerequisites
# Validates environment before guard runs (security_scan is a legacy alias for guard)
# Exit 0 = allow (advisory warnings only, never blocks)
#
# Consolidates EVA's 3 security hooks:
# - pre-security-scan: target path validation
# - pre-dependency-audit: lockfile presence
# - pre-secrets-scan: gitignore validation

TOOL_NAME="${CLAUDE_TOOL_NAME:-}"
INPUT=$(cat)

# Extract action for corsoTools orchestrator
ACTION=""
case "$TOOL_NAME" in
  mcp__C0RS0__corsoTools|mcp__plugin_corso_C0RS0__corsoTools)
    ACTION=$(echo "$INPUT" | jq -r '.tool_input.action // empty' 2>/dev/null)
    ;;
  *) exit 0 ;;
esac

# Only run for security actions
case "$ACTION" in
  guard|security_scan) ;;
  *) exit 0 ;;
esac

# Extract path from tool input
TARGET_PATH=$(echo "$INPUT" | jq -r '.tool_input.path // empty' 2>/dev/null)

WARNINGS=""

# Check 1: Target path exists (for path-based scans)
if [ -n "$TARGET_PATH" ] && [ ! -e "$TARGET_PATH" ]; then
  WARNINGS="${WARNINGS}WARNING: Target path '${TARGET_PATH}' does not exist. Scan may fail.\n"
fi

# Check 2: Cargo.lock present for Rust dependency audits
if [ -n "$TARGET_PATH" ] && [ -d "$TARGET_PATH" ]; then
  if [ -f "${TARGET_PATH}/Cargo.toml" ] && [ ! -f "${TARGET_PATH}/Cargo.lock" ]; then
    WARNINGS="${WARNINGS}WARNING: Cargo.toml found but no Cargo.lock in '${TARGET_PATH}'. Run 'cargo generate-lockfile' for accurate dependency audit.\n"
  fi
fi

# Check 3: .gitignore present (secrets may be committed without it)
if [ -n "$TARGET_PATH" ] && [ -d "$TARGET_PATH" ]; then
  GIT_ROOT=$(git -C "$TARGET_PATH" rev-parse --show-toplevel 2>/dev/null)
  if [ -n "$GIT_ROOT" ]; then
    if [ ! -f "${GIT_ROOT}/.gitignore" ]; then
      WARNINGS="${WARNINGS}WARNING: No .gitignore found in git root '${GIT_ROOT}'. Secrets may be tracked.\n"
    fi
  fi
fi

# Check 4: MANIFEST compliance — verify security phase was planned
MANIFEST=".corso/manifest.yaml"
if [ -f "$MANIFEST" ]; then
  STATUS=$(grep '^status:' "$MANIFEST" 2>/dev/null | awk '{print $2}')
  TIER=$(grep '^tier:' "$MANIFEST" 2>/dev/null | awk '{print $2}')
  if [ "$STATUS" = "executing" ]; then
    echo "Security scan running (tier: ${TIER}, action: ${ACTION})" >&2
  fi
fi

# Output warnings as advisory (non-blocking)
if [ -n "$WARNINGS" ]; then
  printf "%b" "$WARNINGS" >&2
fi

exit 0
