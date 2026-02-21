#!/bin/bash
# PostToolUse hook: Light Architects code quality check (advisory, non-blocking)
#
# Checks .rs/.py/.js/.ts/.go files for violations:
# 1. .unwrap()/.expect() in Rust production code (not test modules)
# 2. panic!() in production code
# 3. unsafe without // SAFETY: comment
# 4. Functions exceeding 60-line limit
# 5. Hardcoded secrets/API keys
#
# ADVISORY: Exits 0 with additionalContext so Claude can self-correct.
# Never blocks the conversation — Claude sees feedback and keeps working.

set -euo pipefail

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.file // empty' 2>/dev/null)

# Only check code files
case "$FILE_PATH" in
  *.rs|*.py|*.js|*.ts|*.go) ;;
  *) exit 0 ;;
esac

# Verify file exists
[ -f "$FILE_PATH" ] || exit 0

VIOLATIONS=""

# --- Rust-specific checks ---
if [[ "$FILE_PATH" == *.rs ]]; then

  # Check for .unwrap() / .expect() outside test modules
  # Strategy: find lines with unwrap/expect, exclude lines inside #[cfg(test)] blocks
  # Simple heuristic: if the file has #[cfg(test)], only flag lines BEFORE it
  TEST_LINE=$(grep -n '#\[cfg(test)\]' "$FILE_PATH" 2>/dev/null | head -1 | cut -d: -f1)
  if [ -n "$TEST_LINE" ]; then
    # Only check lines before test module
    UNWRAP_HITS=$(head -n "$((TEST_LINE - 1))" "$FILE_PATH" | grep -n '\.unwrap()' 2>/dev/null || true)
    EXPECT_HITS=$(head -n "$((TEST_LINE - 1))" "$FILE_PATH" | grep -n '\.expect(' 2>/dev/null || true)
  else
    UNWRAP_HITS=$(grep -n '\.unwrap()' "$FILE_PATH" 2>/dev/null || true)
    EXPECT_HITS=$(grep -n '\.expect(' "$FILE_PATH" 2>/dev/null || true)
  fi

  # Also exclude lines with #[allow(clippy::unwrap_used)] context
  if [ -n "$UNWRAP_HITS" ]; then
    # Filter out lines that are inside allow blocks (simple: check if allow appears within 5 lines before)
    while IFS= read -r line; do
      LINE_NUM=$(echo "$line" | cut -d: -f1)
      # Check if there's an allow annotation nearby
      START=$((LINE_NUM > 5 ? LINE_NUM - 5 : 1))
      CONTEXT=$(sed -n "${START},${LINE_NUM}p" "$FILE_PATH" 2>/dev/null)
      if ! echo "$CONTEXT" | grep -q 'allow.*unwrap_used\|allow.*clippy::unwrap_used'; then
        VIOLATIONS="${VIOLATIONS}\n- Line ${LINE_NUM}: \`.unwrap()\` — production code should use ? or match instead of unwrap patterns"
      fi
    done <<< "$UNWRAP_HITS"
  fi

  if [ -n "$EXPECT_HITS" ]; then
    while IFS= read -r line; do
      LINE_NUM=$(echo "$line" | cut -d: -f1)
      START=$((LINE_NUM > 5 ? LINE_NUM - 5 : 1))
      CONTEXT=$(sed -n "${START},${LINE_NUM}p" "$FILE_PATH" 2>/dev/null)
      if ! echo "$CONTEXT" | grep -q 'allow.*expect_used\|allow.*clippy::expect_used'; then
        VIOLATIONS="${VIOLATIONS}\n- Line ${LINE_NUM}: \`.expect()\` — production code should use ? or match instead of unwrap patterns"
      fi
    done <<< "$EXPECT_HITS"
  fi

  # Check for panic!() outside test modules
  if [ -n "$TEST_LINE" ]; then
    PANIC_HITS=$(head -n "$((TEST_LINE - 1))" "$FILE_PATH" | grep -n 'panic!(' 2>/dev/null || true)
  else
    PANIC_HITS=$(grep -n 'panic!(' "$FILE_PATH" 2>/dev/null || true)
  fi
  if [ -n "$PANIC_HITS" ]; then
    while IFS= read -r line; do
      LINE_NUM=$(echo "$line" | cut -d: -f1)
      VIOLATIONS="${VIOLATIONS}\n- Line ${LINE_NUM}: \`panic!()\` — use Result/Option instead"
    done <<< "$PANIC_HITS"
  fi

  # Check for unsafe without // SAFETY:
  UNSAFE_HITS=$(grep -n 'unsafe ' "$FILE_PATH" 2>/dev/null | grep -v '// SAFETY:' | grep -v '#\[' || true)
  if [ -n "$UNSAFE_HITS" ]; then
    while IFS= read -r line; do
      LINE_NUM=$(echo "$line" | cut -d: -f1)
      # Check if // SAFETY: appears on the line before
      PREV=$((LINE_NUM - 1))
      PREV_LINE=$(sed -n "${PREV}p" "$FILE_PATH" 2>/dev/null || true)
      if ! echo "$PREV_LINE" | grep -q '// SAFETY:'; then
        VIOLATIONS="${VIOLATIONS}\n- Line ${LINE_NUM}: \`unsafe\` block without \`// SAFETY:\` comment"
      fi
    done <<< "$UNSAFE_HITS"
  fi
fi

# --- Universal checks ---

# Function length check (> 60 lines)
# For Rust: match fn declarations, count to closing brace
if [[ "$FILE_PATH" == *.rs ]]; then
  # Use awk to find functions exceeding 60 lines
  LONG_FNS=$(awk '
    /^[[:space:]]*(pub )?(async )?fn [a-zA-Z_]/ {
      fn_name = $0
      sub(/.*fn /, "", fn_name)
      sub(/\(.*/, "", fn_name)
      fn_start = NR
      brace_depth = 0
      started = 0
    }
    /{/ { brace_depth++; started = 1 }
    /}/ {
      brace_depth--
      if (started && brace_depth == 0 && fn_start > 0) {
        fn_len = NR - fn_start + 1
        if (fn_len > 60) {
          printf "- Lines %d-%d: Function `%s` is %d lines (exceeds 60-line limit)\n", fn_start, NR, fn_name, fn_len
        }
        fn_start = 0
      }
    }
  ' "$FILE_PATH" 2>/dev/null || true)

  if [ -n "$LONG_FNS" ]; then
    VIOLATIONS="${VIOLATIONS}\n${LONG_FNS}"
  fi
fi

# Secret detection (all languages)
SECRET_PATTERNS='sk-ant-api|api[_-]?key.*=.*["\x27][a-zA-Z0-9]{32}|-----BEGIN.*PRIVATE KEY|password\s*=\s*["\x27][^\x27"]{8}'
SECRET_HITS=$(grep -inE "$SECRET_PATTERNS" "$FILE_PATH" 2>/dev/null | head -3 || true)
if [ -n "$SECRET_HITS" ]; then
  while IFS= read -r line; do
    LINE_NUM=$(echo "$line" | cut -d: -f1)
    VIOLATIONS="${VIOLATIONS}\n- Line ${LINE_NUM}: Possible hardcoded secret/API key"
  done <<< "$SECRET_HITS"
fi

# --- Output ---
if [ -n "$VIOLATIONS" ]; then
  # Advisory output — Claude sees this as context and self-corrects
  FORMATTED=$(printf "Light Architects violations found in %s:\n%b\n\nThe violations above should be fixed. This is advisory — continue working and fix these issues." "$FILE_PATH" "$VIOLATIONS")

  # Output as JSON with additionalContext (non-blocking)
  jq -n --arg ctx "$FORMATTED" '{"additionalContext": $ctx}'
  exit 0
fi

# No violations — clean exit
exit 0
