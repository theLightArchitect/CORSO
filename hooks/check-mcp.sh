#!/bin/bash
# Deterministic MCP health check — runs before any mcp__* tool use
# Verifies service dependencies are available before tool calls
# Exit 0 = proceed (advisory warnings only, never blocks)
#
# Services checked:
# - Ollama (HTTP health + auto-start + model availability)
# - EVA MCP server (process detection)
# - CORSO MCP server (process detection)
# - SOUL MCP server (process detection)
# - Perplexity API key (for EVA research)

TOOL_NAME="${CLAUDE_TOOL_NAME:-}"

# --- Service Checks ---

check_ollama() {
  local status
  status=$(curl -s -o /dev/null -w "%{http_code}" --max-time 2 http://localhost:11434/api/tags 2>/dev/null)
  if [ "$status" = "200" ]; then
    echo "Ollama: ok" >&2
    return 0
  fi
  # Not running — start it
  echo "Ollama not responding, starting..." >&2
  nohup ollama serve >/dev/null 2>&1 &
  # Wait up to 8 seconds for startup
  for i in 1 2 3 4 5 6 7 8; do
    sleep 1
    status=$(curl -s -o /dev/null -w "%{http_code}" --max-time 2 http://localhost:11434/api/tags 2>/dev/null)
    if [ "$status" = "200" ]; then
      echo "Ollama: started after ${i}s" >&2
      return 0
    fi
  done
  echo "WARNING: Ollama failed to start after 8s. AI generation may fail." >&2
}

check_ollama_models() {
  # Verify Ollama has at least one model available (running but empty = silent failures)
  local models
  models=$(curl -s --max-time 2 http://localhost:11434/api/tags 2>/dev/null)
  if [ -z "$models" ]; then
    return 0  # Can't check, Ollama may not be ready yet
  fi
  local count
  count=$(echo "$models" | python3 -c "import sys,json; d=json.load(sys.stdin); print(len(d.get('models',[])))" 2>/dev/null || echo "0")
  if [ "$count" = "0" ]; then
    echo "WARNING: Ollama running but no models loaded. Run 'ollama pull <model>' first." >&2
  else
    echo "Ollama models: ${count} available" >&2
  fi
}

check_ollama_api_key() {
  # Check OLLAMA_HOST or cloud API key for tier fallback
  # Local Ollama doesn't need a key, but cloud tier (api.ollama.ai) does
  if [ -n "${OLLAMA_API_KEY:-}" ]; then
    echo "Ollama Cloud API key: set" >&2
  elif [ -n "${OLLAMA_HOST:-}" ] && echo "$OLLAMA_HOST" | grep -qi "api.ollama"; then
    echo "WARNING: OLLAMA_HOST points to cloud but OLLAMA_API_KEY is not set. Cloud tier will fail." >&2
  fi
  # Also check Anthropic API key (used by CORSO MCP as CORSO_API_KEY)
  if [ -z "${ANTHROPIC_API_KEY:-}" ] && [ -z "${CORSO_API_KEY:-}" ]; then
    echo "WARNING: Neither ANTHROPIC_API_KEY nor CORSO_API_KEY is set. AI tier routing may fail." >&2
  fi
}

check_eva() {
  if ! pgrep -qf "eva.*mcp\|eva.*stdio" 2>/dev/null; then
    if ! pgrep -qf "/\.eva/bin/eva" 2>/dev/null; then
      echo "WARNING: EVA MCP server not detected. Run /mcp to reconnect." >&2
      return 1
    fi
  fi
  echo "EVA MCP: ok" >&2
}

check_corso() {
  if ! pgrep -qf "corso.*mcp\|corso.*stdio" 2>/dev/null; then
    if ! pgrep -qf "/\.corso/bin/corso" 2>/dev/null; then
      echo "WARNING: CORSO MCP server not detected. Run /mcp to reconnect." >&2
      return 1
    fi
  fi
  echo "CORSO MCP: ok" >&2
}

check_soul() {
  if ! pgrep -qf "soul.*mcp\|soul.*stdio" 2>/dev/null; then
    if ! pgrep -qf "/\.soul/\.config/bin/soul" 2>/dev/null; then
      echo "WARNING: SOUL MCP server not detected. Vault operations and /SCRUM will fail. Run /mcp to reconnect." >&2
      return 1
    fi
  fi
  echo "SOUL MCP: ok" >&2
}

check_perplexity() {
  if [ -z "${PERPLEXITY_API_KEY:-}" ]; then
    echo "WARNING: PERPLEXITY_API_KEY not set. EVA research with source:perplexity will fail. Ollama fallback available." >&2
  else
    echo "Perplexity API key: set" >&2
  fi
}

# --- Tool Routing ---
# Match tool name to required services

# For corsoTools orchestrator: extract action from stdin
ACTION=""
if [ "$TOOL_NAME" = "mcp__C0RS0__corsoTools" ] || [ "$TOOL_NAME" = "mcp__plugin_corso_C0RS0__corsoTools" ]; then
  INPUT=$(cat)
  ACTION=$(echo "$INPUT" | jq -r '.tool_input.action // empty' 2>/dev/null)
fi

case "$TOOL_NAME" in

  # EVA tools — need Ollama + EVA process
  mcp__EVA__speak|mcp__EVA__visualize|mcp__EVA__ideate|mcp__EVA__build|mcp__EVA__memory|mcp__EVA__teach|mcp__EVA__secure|mcp__EVA__bible|mcp__plugin_eva_EVA__speak|mcp__plugin_eva_EVA__visualize|mcp__plugin_eva_EVA__ideate|mcp__plugin_eva_EVA__build|mcp__plugin_eva_EVA__memory|mcp__plugin_eva_EVA__teach|mcp__plugin_eva_EVA__secure|mcp__plugin_eva_EVA__bible)
    check_ollama
    check_ollama_models
    check_ollama_api_key
    check_eva
    ;;

  # EVA research — needs Ollama + EVA + optionally Perplexity
  mcp__EVA__research|mcp__plugin_eva_EVA__research)
    check_ollama
    check_ollama_models
    check_ollama_api_key
    check_eva
    check_perplexity
    ;;

  # CORSO corsoTools orchestrator — route by action
  mcp__C0RS0__corsoTools|mcp__plugin_corso_C0RS0__corsoTools)
    case "$ACTION" in
      # AI-dependent actions — need Ollama + CORSO
      fetch|query_knowledge|sniff|code_review|scout)
        check_ollama
        check_ollama_models
        check_ollama_api_key
        check_corso
        ;;
      # Non-AI actions — need CORSO only
      # speak: default ai_mode=none returns SOUL-injected prompt (~5ms, no Ollama)
      guard|security_scan|chase|read_file|list|speak)
        check_corso
        ;;
      # Unknown action — check CORSO at minimum
      *)
        check_corso
        ;;
    esac
    ;;

  # SOUL tools — need SOUL process
  mcp__SOUL__soulTools|mcp__plugin_soul_SOUL__soulTools)
    check_soul
    ;;

  *) ;; # Not a known MCP tool, pass through
esac

exit 0
