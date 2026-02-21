#!/bin/bash
# PostToolUse hook: auto-format .rs files after Write/Edit
# Zero tokens, deterministic, non-blocking

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.file // empty' 2>/dev/null)

# Only act on .rs files
case "$FILE_PATH" in
  *.rs) ;;
  *)    exit 0 ;;
esac

# Verify file exists
[ -f "$FILE_PATH" ] || exit 0

# Run rustfmt — auto-fix, don't block on failure
if command -v rustfmt >/dev/null 2>&1; then
  rustfmt "$FILE_PATH" 2>/dev/null
  echo "rustfmt: formatted $FILE_PATH" >&2
fi

exit 0
