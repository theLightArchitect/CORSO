#!/bin/bash
# PreToolUse hook: gates execution-only MCP tools during planning phase
# Reads .corso/manifest.yaml to determine pipeline state
# Exit 0 = allow, Exit 2 = block
#
# Blocked during planning: guard, chase (execution-only tools)
# Allowed during planning: sniff (plan gen), fetch (research), code_review, speak, read_file
# Note: security_scan alias resolves to guard in server, but hooks see raw action

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

# Only gate execution-only actions
case "$ACTION" in
  guard|security_scan|chase)
    # These are execution-phase actions — gate during planning
    ;;
  *)
    # All other actions allowed during planning
    exit 0
    ;;
esac

# Resolve manifest — SOUL vault first (default), local fallback
# SOUL mode: active builds tracked in ~/.soul/helix/corso/builds/active.yaml
# Local mode: flat manifest at .corso/manifest.yaml
SOUL_ACTIVE="${HOME}/.soul/helix/corso/builds/active.yaml"
LOCAL_MANIFEST=".corso/manifest.yaml"

STATUS="unknown"
if [ -f "$SOUL_ACTIVE" ]; then
  # SOUL vault mode: status field is indented under each active build entry
  if grep -qE '^\s+status:\s+planning' "$SOUL_ACTIVE" 2>/dev/null; then
    STATUS="planning"
  elif grep -qE '^\s+status:\s+aborted' "$SOUL_ACTIVE" 2>/dev/null; then
    STATUS="aborted"
  else
    exit 0  # No blocking state in SOUL vault
  fi
elif [ -f "$LOCAL_MANIFEST" ]; then
  # Local mode: top-level status field
  STATUS=$(grep '^status:' "$LOCAL_MANIFEST" 2>/dev/null | awk '{print $2}' || echo "unknown")
else
  exit 0  # No manifest anywhere — not in C0RS0 pipeline, allow
fi

case "$STATUS" in
  planning)
    echo "BLOCKED: Pipeline is in planning phase (status: planning). Complete /SCOUT gates before using execution actions like ${ACTION}."
    exit 2
    ;;
  aborted)
    echo "BLOCKED: Pipeline was aborted. Run /HUNT --resume or start a new plan with /SCOUT."
    exit 2
    ;;
  *)
    # approved, executing, completed, unknown — allow
    exit 0
    ;;
esac
