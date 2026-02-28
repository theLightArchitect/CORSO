#!/bin/bash
# PreToolUse hook: validates pipeline state during execution
# Checks abort status and outputs advisory phase info
# Exit 0 = allow (advisory only), Exit 2 = block (abort detected)
#
# Claude owns MANIFEST writes. This hook only reads for gating.
# Exempt tools: ask, read_file (always allowed)

TOOL_NAME="${CLAUDE_TOOL_NAME:-}"
INPUT=$(cat)

# Only check corsoTools orchestrator
case "$TOOL_NAME" in
  mcp__C0RS0__corsoTools|mcp__plugin_corso_C0RS0__corsoTools) ;;
  *) exit 0 ;;
esac

# Extract action
ACTION=$(echo "$INPUT" | jq -r '.tool_input.action // empty' 2>/dev/null)

# Exempt always-allowed actions
case "$ACTION" in
  speak|read_file|list) exit 0 ;;
esac

# Resolve manifest — SOUL vault first (default), local fallback
SOUL_ACTIVE="${HOME}/.soul/helix/corso/builds/active.yaml"
LOCAL_MANIFEST=".corso/manifest.yaml"

STATUS="unknown"
TIER="unknown"

if [ -f "$SOUL_ACTIVE" ]; then
  # SOUL vault mode: status and tier are indented under each active build entry
  if grep -qE '^\s+status:\s+aborted' "$SOUL_ACTIVE" 2>/dev/null; then
    STATUS="aborted"
  elif grep -qE '^\s+status:\s+executing' "$SOUL_ACTIVE" 2>/dev/null; then
    STATUS="executing"
    # Tier lives in the per-plan manifest — best-effort read for advisory logging only
    MANIFEST_PATH=$(grep -E '^\s+path:' "$SOUL_ACTIVE" 2>/dev/null | head -1 | awk '{print $2}')
    if [ -f "$MANIFEST_PATH" ]; then
      TIER=$(grep '^tier:' "$MANIFEST_PATH" 2>/dev/null | awk '{print $2}' || echo "unknown")
    fi
  fi
elif [ -f "$LOCAL_MANIFEST" ]; then
  STATUS=$(grep '^status:' "$LOCAL_MANIFEST" 2>/dev/null | awk '{print $2}' || echo "unknown")
  TIER=$(grep '^tier:' "$LOCAL_MANIFEST" 2>/dev/null | awk '{print $2}' || echo "unknown")
else
  exit 0  # No manifest — not in pipeline
fi

# Only gate during execution or on abort
[ "$STATUS" = "executing" ] || [ "$STATUS" = "aborted" ] || exit 0

# Block on abort
if [ "$STATUS" = "aborted" ]; then
  echo "BLOCKED: Pipeline abort triggered. All execution halted. Run /HUNT --resume or /SCOUT to start fresh."
  exit 2
fi

# Advisory: output current state to stderr (visible to user, non-blocking)
echo "Pipeline executing (tier: ${TIER}). Action: ${ACTION}" >&2

exit 0
