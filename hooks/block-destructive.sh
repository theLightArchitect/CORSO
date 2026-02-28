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
  # git reset --hard HEAD / bare reset — safe (discards local changes only, no commit loss)
  # git reset --hard origin/* / upstream/* — safe (explicit sync intent)
  # Block only patterns that rewind commit history or undo merges:
  *"git reset --hard HEAD~"*|*"git reset --hard HEAD^"*)
    echo "BLOCKED: git reset --hard HEAD~N / HEAD^ rewinds commit history. Use 'git revert' to safely undo commits, or confirm you mean to do this and run it yourself."
    exit 2 ;;
  *"git reset --hard ORIG_HEAD"*)
    echo "BLOCKED: git reset --hard ORIG_HEAD undoes a merge or rebase. Run it yourself if intentional."
    exit 2 ;;
  *"drop table"*|*"DROP TABLE"*)
    echo "BLOCKED: DROP TABLE detected."
    exit 2 ;;
esac

exit 0
