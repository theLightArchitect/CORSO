#!/bin/bash
# PreToolUse hook: block dangerous Bash commands
# Exit 2 = block, Exit 0 = allow

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)

[ -z "$COMMAND" ] && exit 0

# Dangerous patterns — exit 2 to block
case "$COMMAND" in
  *"rm -rf /"*|*"rm -rf ~"*|*"rm -rf \$HOME"*)
    echo "BLOCKED: recursive delete of root/home directory."
    exit 2 ;;
  *"git push --force main"*|*"git push --force origin main"*|*"git push -f main"*|*"git push -f origin main"*)
    echo "BLOCKED: force push to main."
    exit 2 ;;
  *"git push --force master"*|*"git push -f master"*|*"git push -f origin master"*)
    echo "BLOCKED: force push to master."
    exit 2 ;;
  *"git reset --hard"*)
    echo "BLOCKED: git reset --hard discards uncommitted work."
    exit 2 ;;
  *"drop table"*|*"DROP TABLE"*)
    echo "BLOCKED: DROP TABLE detected."
    exit 2 ;;
esac

exit 0
