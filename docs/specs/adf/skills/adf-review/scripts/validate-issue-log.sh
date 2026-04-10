#!/bin/bash
# Validate Issue Log format in plan.md
# Usage: validate-issue-log.sh [project-root]

PROJECT_ROOT="${1:-.}"
PLAN_FILE="$PROJECT_ROOT/docs/adf/plan.md"

if [ ! -f "$PLAN_FILE" ]; then
  echo "❌ plan.md not found at: $PLAN_FILE"
  exit 1
fi

echo "Validating Issue Log in: $PLAN_FILE"
echo

# Check if Issue Log section exists
if ! grep -q "## Issue Log" "$PLAN_FILE"; then
  echo "⚠️  No Issue Log section found"
  echo "Expected: ## Issue Log"
  exit 1
fi

# Check for table header
if ! grep -q "| # | Issue | Source | Severity | Status | Resolution |" "$PLAN_FILE"; then
  echo "⚠️  Issue Log table header malformed"
  echo "Expected: | # | Issue | Source | Severity | Status | Resolution |"
  exit 1
fi

# Count issues
TOTAL_ISSUES=$(grep -c "^| [0-9]" "$PLAN_FILE" 2>/dev/null || echo "0")
CRITICAL=$(grep -c "Critical" "$PLAN_FILE" 2>/dev/null || echo "0")
HIGH=$(grep -c "High" "$PLAN_FILE" 2>/dev/null || echo "0")
MEDIUM=$(grep -c "Medium" "$PLAN_FILE" 2>/dev/null || echo "0")
LOW=$(grep -c "Low" "$PLAN_FILE" 2>/dev/null || echo "0")

OPEN=$(grep -c "Open" "$PLAN_FILE" 2>/dev/null || echo "0")
RESOLVED=$(grep -c "Resolved" "$PLAN_FILE" 2>/dev/null || echo "0")

echo "Issue Log Summary:"
echo "  Total issues: $TOTAL_ISSUES"
echo "  By severity: $CRITICAL Critical, $HIGH High, $MEDIUM Medium, $LOW Low"
echo "  By status: $OPEN Open, $RESOLVED Resolved"
echo

# Check for review completion markers
if grep -q "Internal Review.*Complete" "$PLAN_FILE"; then
  echo "✓ Internal review marked complete"
else
  echo "⚠️  Internal review status not found"
fi

if grep -q "External Review.*Complete" "$PLAN_FILE"; then
  echo "✓ External review marked complete"
else
  echo "⚠️  External review status not found"
fi

echo
if [ "$CRITICAL" -gt 0 ] || [ "$HIGH" -gt 0 ]; then
  echo "⚠️  Critical or High issues remain - review may not be complete"
  exit 1
else
  echo "✓ Issue Log format valid"
  exit 0
fi
