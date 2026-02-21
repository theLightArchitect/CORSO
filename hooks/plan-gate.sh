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

# Check for manifest
MANIFEST=".corso/manifest.yaml"
[ -f "$MANIFEST" ] || exit 0  # No manifest = not in C0RS0 pipeline, allow

# Read status (simple grep — manifest is flat YAML written by Claude)
STATUS=$(grep '^status:' "$MANIFEST" 2>/dev/null | awk '{print $2}' || echo "unknown")

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
