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

# Check for manifest
MANIFEST=".corso/manifest.yaml"
[ -f "$MANIFEST" ] || exit 0  # No manifest = not in pipeline

# Read status
STATUS=$(grep '^status:' "$MANIFEST" 2>/dev/null | awk '{print $2}' || echo "unknown")

# Only gate during execution
[ "$STATUS" = "executing" ] || exit 0

# Check if abort was triggered
ABORT_LINE=$(grep 'triggered:' "$MANIFEST" 2>/dev/null | tail -1)
if echo "$ABORT_LINE" | grep -q 'true'; then
  echo "BLOCKED: Pipeline abort triggered. All execution halted. See .corso/manifest.yaml for details."
  exit 2
fi

# Advisory: output current state to stderr (visible to user, non-blocking)
TIER=$(grep '^tier:' "$MANIFEST" 2>/dev/null | awk '{print $2}' || echo "unknown")
echo "Pipeline executing (tier: ${TIER}). Action: ${ACTION}" >&2

exit 0
