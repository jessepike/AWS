#!/bin/bash
# Example: Full review workflow (internal + external)
# This demonstrates the complete two-phase review process

set -e

PROJECT_ROOT="${1:-.}"
STAGE="${2:-develop}"

echo "=== ADF Full Review Workflow ==="
echo "Project: $PROJECT_ROOT"
echo "Stage: $STAGE"
echo

# Phase 1: Internal Review
echo "--- Phase 1: Internal Review ---"

# Get internal review prompt from ADF MCP
echo "Getting internal review prompt..."
# Note: In practice, this would be called via MCP tool
# mcp__adf__get_review_prompt(stage="$STAGE", phase="internal")

# Execute Ralph Loop with prompt
echo "Executing Ralph Loop..."
# /ralph-loop:ralph-loop \
#   --project-dir "$PROJECT_ROOT" \
#   --max-iterations 10 \
#   --completion-promise "${STAGE^^}_INTERNAL_REVIEW_COMPLETE"

echo "✓ Internal review complete (2 cycles, 0 Critical/High issues)"
echo

# Phase 2: External Review
echo "--- Phase 2: External Review ---"

# Get external review prompt
echo "Getting external review prompt..."
# mcp__adf__get_review_prompt(stage="$STAGE", phase="external")

# List available models
echo "Checking available models..."
# mcp__external-review__list_models()

# Execute external review with multiple models
ARTIFACT_PATH="$(cd "$PROJECT_ROOT" && pwd)/docs/design.md"
echo "Executing external review on: $ARTIFACT_PATH"
# mcp__external-review__review(
#   models=["gemini", "gpt", "kimi"],
#   artifact_path="$ARTIFACT_PATH",
#   prompt="<external_review_prompt_content>"
# )

echo "✓ External review complete (3 models, 6 High issues identified)"
echo

# Update artifacts
echo "--- Updating Artifacts ---"
echo "Adding issues to plan.md Issue Log..."
echo "Updating review status..."
echo

echo "=== Full Review Complete ==="
echo "✓ Internal: 2 cycles, 0 Critical/High remaining"
echo "✓ External: 3 models, 6 High issues documented"
echo "✓ Ready for implementation"
