#!/bin/bash
# Example: External-only review workflow
# Use when: Internal review already passed, need fresh perspectives

set -e

PROJECT_ROOT="${1:-.}"
STAGE="${2:-develop}"
ARTIFACT="${3:-design.md}"

echo "=== ADF External-Only Review ==="
echo "Project: $PROJECT_ROOT"
echo "Stage: $STAGE"
echo "Artifact: $ARTIFACT"
echo

# Get external review prompt
echo "Getting external review prompt..."
# mcp__adf__get_review_prompt(stage="$STAGE", phase="external")

# List available models
echo "Checking available models..."
# mcp__external-review__list_models()
echo "  Available: gemini, gpt, kimi"
echo

# Execute external review with multiple models
ARTIFACT_PATH="$(cd "$PROJECT_ROOT" && pwd)/docs/$ARTIFACT"
echo "Executing external review on: $ARTIFACT_PATH"
# mcp__external-review__review(
#   models=["gemini", "gpt", "kimi"],
#   artifact_path="$ARTIFACT_PATH",
#   prompt="<external_review_prompt_content>"
# )

echo "✓ External review complete (3 models)"
echo "  - Gemini: 4 issues (2 High, 2 Medium)"
echo "  - GPT: 8 issues (4 High, 4 Medium)"
echo "  - Kimi: 6 issues (3 High, 3 Medium)"
echo

# Synthesize results
echo "Synthesizing findings..."
echo "  - Common High issues: 3"
echo "  - Unique insights: 12"
echo "  - Cost: $0.020, Latency: 80.6s"
echo

# Update artifacts
echo "Updating artifacts..."
echo "  - Adding issues to plan.md Issue Log"
echo "  - Marking external review complete"
echo

echo "=== External Review Complete ==="
echo "✓ 3 models executed in parallel"
echo "✓ 9 High impact issues identified"
echo "✓ Findings synthesized and documented"
echo
echo "Note: Internal review assumed complete (external-only mode)"
echo "If internal review not done, run: internal-only.sh first"
