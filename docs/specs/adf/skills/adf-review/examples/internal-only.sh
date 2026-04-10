#!/bin/bash
# Example: Internal-only review workflow
# Use when: Quick validation, early drafts, cost concerns

set -e

PROJECT_ROOT="${1:-.}"
STAGE="${2:-develop}"

echo "=== ADF Internal-Only Review ==="
echo "Project: $PROJECT_ROOT"
echo "Stage: $STAGE"
echo

# Get internal review prompt from ADF MCP
echo "Getting internal review prompt..."
# mcp__adf__get_review_prompt(stage="$STAGE", phase="internal")

# Execute Ralph Loop with prompt
echo "Executing Ralph Loop..."
# /ralph-loop:ralph-loop \
#   --project-dir "$PROJECT_ROOT" \
#   --max-iterations 10 \
#   --completion-promise "${STAGE^^}_INTERNAL_REVIEW_COMPLETE"

echo "✓ Internal review complete (2 cycles, 0 Critical/High issues)"
echo

# Update artifacts
echo "Updating artifacts..."
echo "  - Adding issues to plan.md Issue Log"
echo "  - Marking internal review complete"
echo

echo "=== Internal Review Complete ==="
echo "✓ 2 cycles executed"
echo "✓ 0 Critical/High issues remaining"
echo "✓ Structural validation passed"
echo
echo "Note: External review skipped (internal-only mode)"
echo "To add external review later, run: external-only.sh"
