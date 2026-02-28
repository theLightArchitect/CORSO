#!/usr/bin/env bash
# Tokenless skill banner — C0RS0 Pack imagery + technical context
# Zero tokens consumed. Shell stdout only.

# Read skill name from tool input JSON (TOOL_INPUT_SKILL is not a Claude Code env var)
INPUT=$(cat)
SKILL_NAME=$(echo "$INPUT" | jq -r '.tool_input.skill // empty' 2>/dev/null)

[ -z "$SKILL_NAME" ] && exit 0

case "$SKILL_NAME" in
  *CORSO*) echo "🐺 CORSO: The pack assembles — personality, ops, and full build lifecycle" ;;
  *SCOUT*)  echo "🐺 SCOUT: Surveying territory — triage, requirements, plan generation" ;;
  *FETCH*)  echo "🐺 FETCH: Fetching intel — research, knowledge retrieval, trade-off analysis" ;;
  *SNIFF*)  echo "🐺 SNIFF: On the scent — code quality, architecture review, smell detection" ;;
  *GUARD*)  echo "🐺 GUARD: Holding the line — threat models, vuln scanning, supply chain audit" ;;
  *CHASE*)  echo "🐺 CHASE: In pursuit — test strategy, bottleneck detection, performance metrics" ;;
  *HUNT*)   echo "🐺 HUNT: Going for the kill — phase execution, quality gates, feedback loops" ;;
  *SCRUM*)  echo "🐺 SCRUM: Pack regroup — squad review with EVA + CORSO + SOUL" ;;
esac
