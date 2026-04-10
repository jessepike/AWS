---
name: ADF Review
description: This skill should be used when the user asks to "run review", "review this", "run ADF review", "review artifact", "validate design", or when the user requests artifact validation at any ADF stage. Orchestrates the complete two-phase review process (internal Ralph Loop + external multi-model review).
version: 1.0.0
---

# ADF Review Skill

Orchestrates the complete ADF artifact review process with two phases: internal review (Ralph Loop) and external review (multi-model perspectives).

## Purpose

Execute comprehensive artifact reviews following ADF-REVIEW-SPEC methodology. Reviews validate design artifacts against stage requirements, identify implementation blockers, and catch blind spots through multiple perspectives.

## When to Use

Trigger this skill when:
- User requests artifact review ("run review", "review this design")
- Completing a stage's Build phase before transitioning
- User explicitly invokes with review type flag (--internal-only, --external-only)
- Default behavior: Run full review (internal + external)

## Review Process Overview

```
Full Review (Default)
├── Phase 1: Internal Review
│   ├── Get review prompt from ADF MCP (stage-specific)
│   ├── Execute Ralph Loop with prompt
│   ├── Process results and update artifacts
│   └── Check exit criteria (0 Critical/High issues)
└── Phase 2: External Review
    ├── Get review prompt from ADF MCP
    ├── Execute external-review MCP (3+ models)
    ├── Synthesize findings across models
    └── Update artifacts with consolidated issues
```

## Usage Patterns

### Default: Full Review

When user says "run review" or "review this artifact":

```bash
# Step 1: Confirm review type with user
AskUserQuestion:
  - Full review (internal + external) - Recommended
  - Internal review only
  - External review only

# Step 2: Execute selected review type
# (See workflows below)
```

### Internal-Only Review

Use when:
- Quick structural validation needed
- Early draft stage
- Iterative refinement cycles
- External API costs are a concern

### External-Only Review

Use when:
- Internal review already passed
- Fresh perspective needed on mature design
- Validating implementation approach

## Implementation Workflow

### Phase 1: Internal Review

1. **Get review prompt:**
   ```
   mcp__adf__get_review_prompt(stage, phase="internal")
   ```

2. **Determine project root:**
   - Current working directory (pwd)
   - Verify docs/adf/ exists

3. **Execute Ralph Loop:**
   ```
   /ralph-loop:ralph-loop \
     --project-dir <project_root> \
     --max-iterations 10 \
     --completion-promise "DEVELOP_INTERNAL_REVIEW_COMPLETE"
   ```

4. **Inject ADF prompt:**
   - Pass review prompt content as task to Ralph Loop
   - Ralph Loop reads artifacts and executes review cycles

5. **Verify completion:**
   - Check for completion promise in output
   - Verify 0 Critical/High issues remaining
   - Confirm minimum 2 cycles executed

### Phase 2: External Review

1. **Get review prompt:**
   ```
   mcp__adf__get_review_prompt(stage, phase="external")
   ```

2. **List available models:**
   ```
   mcp__external-review__list_models()
   ```

3. **Execute review:**
   ```
   mcp__external-review__review(
     models=["gemini", "gpt", "kimi"],
     artifact_path="<absolute_path_to_artifact>",
     prompt="<external_review_prompt_content>"
   )
   ```

4. **Synthesize results:**
   - Group issues by severity (High, Medium)
   - Identify common themes across models
   - Flag implementation blockers (High impact)

5. **Update artifacts:**
   - Add issues to plan.md Issue Log
   - Update review status in artifact frontmatter
   - Document external review metadata (models, cost, latency)

## Artifact Updates

### Plan.md Issue Log Format

```markdown
## Issue Log

| # | Issue | Source | Severity | Status | Resolution |
|---|-------|--------|----------|--------|------------|
| N | [issue description] | Ralph-Stage-C1 | Critical | Open | - |
| N | [issue description] | Gemini/GPT/Kimi | High | Open | - |

**Internal Review:** X cycles, 0 Critical/High remaining
**External Review:** Models: X, Y, Z | Cost: $N | Latency: Nms
```

### Review Status Updates

Update artifact frontmatter or header:

```yaml
# For frontmatter artifacts (design.md, manifest.md)
review_status: "internal-complete" | "external-complete" | "full-complete"

# For non-frontmatter artifacts (plan.md)
**Review Status:** Full Review Complete (Internal + External, YYYY-MM-DD)
```

## Critical Integration Points

### ADF MCP Server

Source of truth for review prompts:
- `get_review_prompt(stage, phase)` - Returns stage-specific prompts
- Prompts include review dimensions, exit criteria, issue logging format
- Must be called before executing review phases

### Ralph Loop Skill

Generic iteration mechanism (not review-specific):
- Takes any prompt/task as input
- Executes in self-referential loop
- Continues until completion promise or max iterations
- Used FOR internal review, not exclusive to reviews

### External-Review MCP Server

Multi-model execution layer:
- `list_models()` - Available LLM models
- `review(models, artifact_path, prompt)` - Parallel execution
- Returns aggregated results with cost/latency metrics

## Exit Criteria

### Internal Review Complete

- [ ] Minimum 2 cycles executed
- [ ] Latest cycle: 0 Critical issues, 0 High issues
- [ ] All design requirements addressed in plan
- [ ] Tasks are atomic and executable
- [ ] Completion promise emitted

### External Review Complete

- [ ] 3+ models executed successfully
- [ ] High/Medium issues synthesized
- [ ] Findings added to Issue Log
- [ ] Review metadata documented

### Full Review Complete

- [ ] Both internal and external phases complete
- [ ] Issue Log consolidated
- [ ] Review status updated in artifacts
- [ ] Ready for Build phase or stage transition

## Error Handling

### Ralph Loop Fails

- Check project directory is correct (docs/adf/ exists)
- Verify completion promise format matches
- Inspect ralph-loop.local.md for errors
- Re-run with fresh prompt if stuck

### External Review Fails

- Verify external-review MCP server connected
- Check model availability (list_models)
- Ensure artifact path is absolute
- Review cost/latency if timeout

### ADF MCP Unavailable

- Check MCP connection status (/mcp)
- Verify ADF_ROOT environment variable
- Restart MCP server if needed
- Fallback: Read prompts manually from ~/code/_shared/adf/prompts/

## Stage-Specific Notes

### Discover Stage

- Review focuses on intent.md and brief.md
- Validates problem statement clarity
- Checks success criteria are measurable

### Design Stage

- Review validates design.md completeness
- Checks architectural soundness
- Verifies all components specified

### Develop Stage

- Review validates plan.md, tasks.md, manifest.md, capabilities.md
- Checks implementation readiness
- Verifies test coverage strategy

### Deliver Stage

- Review validates deployment artifacts
- Checks documentation completeness
- Verifies handoff readiness

## Additional Resources

### Reference Files

For detailed review methodology and specifications:
- **`references/review-spec.md`** - Full ADF review specification
- **`references/issue-severity.md`** - How to classify issue severity
- **`references/stage-reviews.md`** - Stage-specific review focus areas

### Example Files

Working examples of review execution:
- **`examples/full-review-workflow.sh`** - Complete review script
- **`examples/internal-only.sh`** - Internal review only
- **`examples/external-only.sh`** - External review only

### Scripts

Utility scripts for review operations:
- **`scripts/check-review-status.sh`** - Check if artifacts need review
- **`scripts/validate-issue-log.sh`** - Validate Issue Log format

## Best Practices

### Always Confirm Review Type

Use AskUserQuestion to present options:
- Default: Full review (recommended)
- Option: Internal only
- Option: External only

This prevents assumptions about user intent.

### Use Absolute Paths

External-review MCP requires absolute artifact paths:
```bash
# Get absolute path
artifact_path=$(cd "$(dirname "$0")" && pwd)/docs/design.md
```

### Parallel External Models

Always use multiple models (3+) for external review:
- Diverse perspectives catch different issues
- Common findings across models indicate real problems
- Cost-effective with parallel execution

### Update Artifacts Immediately

Don't defer artifact updates:
- Add issues to Issue Log right after finding them
- Update review status when phases complete
- Commit changes after each phase

### Preserve Review History

Keep all issues in Issue Log (don't delete):
- Mark as "Resolved" with resolution notes
- Track cycle numbers for internal review
- Document model sources for external issues

## Common Mistakes to Avoid

❌ Don't skip user confirmation - Always ask for review type
❌ Don't execute phases in wrong order - Internal before external
❌ Don't assume artifacts need review - Check review_status first
❌ Don't execute Ralph Loop without ADF prompt - Get prompt from MCP
❌ Don't use relative paths for external review - Always absolute
❌ Don't ignore Medium severity issues - Document for awareness
❌ Don't run reviews in non-ADF projects - Verify project structure first

## Quick Reference

**Trigger phrases:**
- "run review"
- "review this"
- "run ADF review"
- "review artifact"
- "validate design"

**Review types:**
- Full (default): Internal + External
- Internal only: Ralph Loop validation
- External only: Multi-model perspectives

**Key tools:**
- ADF MCP: `get_review_prompt()`
- Ralph Loop: `/ralph-loop:ralph-loop`
- External Review: `mcp__external-review__review()`

**Success indicators:**
- Internal: Completion promise emitted, 0 Critical/High
- External: 3+ models complete, issues synthesized
- Full: Both phases complete, artifacts updated
