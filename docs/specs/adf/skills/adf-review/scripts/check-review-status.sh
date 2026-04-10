#!/bin/bash
# Check if ADF artifacts need review
# Usage: check-review-status.sh [project-root]

PROJECT_ROOT="${1:-.}"

echo "Checking review status for: $PROJECT_ROOT"
echo

# Check if this is an ADF project
if [ ! -d "$PROJECT_ROOT/docs/adf" ]; then
  echo "❌ Not an ADF project (docs/adf/ not found)"
  exit 1
fi

# Check design.md
if [ -f "$PROJECT_ROOT/docs/design.md" ]; then
  echo "design.md:"
  if grep -q "review_status.*complete" "$PROJECT_ROOT/docs/design.md" 2>/dev/null; then
    echo "  ✓ Review complete"
  else
    echo "  ⚠️  Review status not found or incomplete"
  fi
fi

# Check plan.md
if [ -f "$PROJECT_ROOT/docs/adf/plan.md" ]; then
  echo "plan.md:"
  if grep -q "Review Status.*Complete" "$PROJECT_ROOT/docs/adf/plan.md" 2>/dev/null; then
    echo "  ✓ Review complete"
  elif grep -q "Internal Review.*Complete" "$PROJECT_ROOT/docs/adf/plan.md" 2>/dev/null; then
    echo "  ⚠️  Internal review complete, external review pending"
  else
    echo "  ❌ Review needed"
  fi
fi

# Check for Issue Log
if [ -f "$PROJECT_ROOT/docs/adf/plan.md" ]; then
  if grep -q "## Issue Log" "$PROJECT_ROOT/docs/adf/plan.md" 2>/dev/null; then
    CRITICAL=$(grep -c "Critical.*Open" "$PROJECT_ROOT/docs/adf/plan.md" 2>/dev/null || echo "0")
    HIGH=$(grep -c "High.*Open" "$PROJECT_ROOT/docs/adf/plan.md" 2>/dev/null || echo "0")

    if [ "$CRITICAL" -gt 0 ] || [ "$HIGH" -gt 0 ]; then
      echo "  ⚠️  Open issues: $CRITICAL Critical, $HIGH High"
    fi
  fi
fi

echo
echo "Use '/adf-review' skill to run reviews"
