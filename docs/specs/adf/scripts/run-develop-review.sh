#!/bin/bash
# Output the Ralph Loop command for Develop internal review
# Usage: ./run-develop-review.sh
# Then copy/paste the output into Claude Code

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ACM_DIR="$(dirname "$SCRIPT_DIR")"
PROMPT_FILE="$ACM_DIR/prompts/develop-ralph-review-prompt.md"

echo "Copy and paste this command into Claude Code:"
echo ""
echo "/ralph-loop:ralph-loop \"\$(cat $PROMPT_FILE)\" --max-iterations 10 --completion-promise \"DEVELOP_INTERNAL_REVIEW_COMPLETE\""
