---
type: "knowledge"
description: "Guide for conducting Tier 3 manual testing and user acceptance validation"
updated: "2026-02-02"
scope: "adf"
lifecycle: "reference"
tags: ["testing", "manual-testing", "validation", "user-acceptance"]
---

# Manual Testing Guide (Tier 3)

## Purpose

Tier 3 manual testing validates what automated tests and browser automation cannot:
- Subjective user experience
- Edge cases requiring human judgment
- Visual/aesthetic quality
- Contextual appropriateness
- Real-world usability

This tier catches issues that slip through Tier 1 (automated) and Tier 2 (browser/real-world).

## When to Conduct Tier 3

**Develop Stage:** After Tier 1 and Tier 2 pass in development environment
**Deliver Stage:** After Tier 1 and Tier 2 pass in production environment

**Critical:** Do NOT skip Tier 3 in Develop. Deferring manual validation to Deliver is expensive and risky.

## Who Performs Tier 3

- **Human user** (project owner, stakeholder, or tester)
- **Not agents** — this tier requires human judgment

## General Testing Approach

### 1. Review Success Criteria

Check `brief.md` for success criteria. These define what "done" means.

### 2. Test Core Flows

Execute the primary user flows end-to-end as a real user would:
- Start from entry point (not midway through a flow)
- Use realistic data and scenarios
- Note any friction, confusion, or errors

### 3. Validate Against Brief

Map each success criterion to evidence:
- ✓ Criterion met — note how you confirmed it
- ✗ Criterion not met — describe the gap
- ? Uncertain — explain why

### 4. Document Results

Record findings in a structured format (template below).

## Testing by Project Type

### App (Web/Desktop/Mobile)

**Focus:** User experience, visual quality, accessibility, error handling

**Checklist:**
- [ ] Launch the app (from a fresh state, not dev tools)
- [ ] Complete primary user flow end-to-end
- [ ] Test error scenarios (invalid input, network failure, etc.)
- [ ] Check visual consistency (spacing, fonts, colors, alignment)
- [ ] Test accessibility (keyboard navigation, screen reader compatibility)
- [ ] Verify responsive behavior (if applicable: resize window, mobile viewport)
- [ ] Test edge cases (empty states, max values, special characters)
- [ ] Confirm all success criteria from brief.md are met

**Questions to Ask:**
- Is this intuitive for someone who hasn't seen it before?
- Are error messages helpful and actionable?
- Does it feel polished and professional?
- Would I use this myself?

### MCP Server

**Focus:** Tool correctness, error handling, real-world usage

**Checklist:**
- [ ] Connect the MCP server to Claude Desktop or Claude Code
- [ ] Execute each tool with realistic inputs (not just happy path)
- [ ] Test error scenarios (invalid inputs, missing files, permission errors)
- [ ] Verify tool descriptions are clear and accurate
- [ ] Check that tool outputs are useful and well-formatted
- [ ] Test with tilde paths, relative paths, and absolute paths
- [ ] Confirm tools handle edge cases gracefully (empty results, large outputs)
- [ ] Verify all success criteria from brief.md are met

**Questions to Ask:**
- Are tool descriptions clear enough for someone who hasn't built this?
- Do error messages guide the user to a solution?
- Do outputs provide enough context to be actionable?
- Would this be useful in a real Claude session?

### Workflow (Automation/Pipeline)

**Focus:** Trigger reliability, error recovery, output quality

**Checklist:**
- [ ] Trigger the workflow in its intended environment
- [ ] Test with realistic inputs (not synthetic test data)
- [ ] Verify outputs are correct and complete
- [ ] Test error scenarios (missing dependencies, invalid inputs, external service failures)
- [ ] Check logs and error messages for clarity
- [ ] Test idempotency (can it run multiple times safely?)
- [ ] Verify all success criteria from brief.md are met

**Questions to Ask:**
- Does this work reliably in the target environment?
- If it fails, can I diagnose the issue from the error message?
- Is the output format stable and usable downstream?
- Would I trust this to run unattended?

### Artifact (Document/Template/Spec)

**Focus:** Accuracy, completeness, clarity, usability

**Checklist:**
- [ ] Read the artifact as a new user would (top to bottom)
- [ ] Check for factual accuracy and internal consistency
- [ ] Verify all required sections are present and complete
- [ ] Test any examples or code snippets (do they work?)
- [ ] Check formatting and readability
- [ ] Verify links and references are valid
- [ ] Confirm the artifact achieves its stated purpose
- [ ] Verify all success criteria from brief.md are met

**Questions to Ask:**
- Is this clear enough for someone unfamiliar with the context?
- Are examples accurate and helpful?
- Does this provide enough information to be actionable?
- Would I be confident using this as a reference?

## Test Results Template

Document your Tier 3 results in `docs/adf/test-results.md` (or append to existing results):

```markdown
### Tier 3: Manual Validation

**Tester:** [Your name]
**Date:** [YYYY-MM-DD]
**Environment:** [Development | Production]

#### Test Scenarios

| Scenario | Result | Notes |
|----------|--------|-------|
| [Primary user flow] | ✓ Pass | [Any observations] |
| [Error handling test] | ✗ Fail | [Issue description] |
| [Edge case test] | ✓ Pass | [Any observations] |

#### Success Criteria Validation

| Criterion (from brief.md) | Met? | Evidence |
|---------------------------|------|----------|
| [Criterion 1] | ✓ Yes | [How you confirmed it] |
| [Criterion 2] | ✗ No | [Gap description] |
| [Criterion 3] | ? Uncertain | [Why unclear] |

#### Issues Found

| Issue | Severity | Description |
|-------|----------|-------------|
| [Issue 1] | Critical | [Detailed description] |
| [Issue 2] | Medium | [Detailed description] |

#### Overall Assessment

**Pass/Fail:** [Pass | Fail with issues]

**Summary:** [1-3 sentences describing overall quality and readiness]

**Recommendation:** [Deploy | Fix issues and retest | Needs significant work]
```

## Issue Severity Guidelines

| Severity | Definition | Example |
|----------|------------|---------|
| **Critical** | Blocks primary use case or causes data loss | App crashes on login; MCP tool corrupts files |
| **High** | Significantly degrades user experience | Confusing error messages; broken navigation |
| **Medium** | Minor usability issue or edge case problem | Visual inconsistency; unclear label |
| **Low** | Cosmetic issue or nice-to-have improvement | Typo; color preference |

## When to Fail Tier 3

Fail Tier 3 and require fixes if:
- Any **Critical** issues found
- Multiple **High** issues found
- Any success criterion from brief.md is unmet
- Overall experience falls below acceptable quality

## When to Pass Tier 3

Pass Tier 3 when:
- All success criteria from brief.md are met
- No Critical or High issues remain
- User experience is acceptable for the project stage
- Tester would accept this as "done"

## Progressive Re-testing

If issues are found in Tier 3:
1. Fix the issues
2. Re-run **Tier 1** (automated tests must still pass)
3. Re-run **Tier 2** (browser/real-world tests in affected areas)
4. Re-run **Tier 3** (manual validation of fixes)

Do NOT skip earlier tiers when re-testing. Fixes can introduce regressions.

## Develop vs Deliver Differences

| Aspect | Develop (Testing) | Deliver (Validation) |
|--------|-------------------|----------------------|
| **Environment** | Development/staging | Production/target environment |
| **Data** | Test data | Real or production-like data |
| **Focus** | Does it work as designed? | Does it work in production? |
| **Pass criteria** | Meets design spec and brief | Meets brief and works in real environment |
| **Failure cost** | Low (iterate quickly) | High (requires hotfix/rollback) |

## Common Pitfalls

- **Skipping Tier 3 in Develop** — "We'll test it in production" is expensive
- **Testing only happy path** — Edge cases reveal quality issues
- **Accepting vague results** — "Looks good" is not validation; map to success criteria
- **Testing as the builder** — Fresh eyes find issues you've become blind to
- **Ignoring Medium issues** — They accumulate and degrade experience

## Example: MCP Server Manual Test

**Project:** ADF MCP Server
**Tester:** Jesse Pike
**Date:** 2026-02-02
**Environment:** Development (connected to Claude Code)

#### Test Scenarios

| Scenario | Result | Notes |
|----------|--------|-------|
| Query stage details (get_stage) | ✓ Pass | Returns complete stage spec with all phases |
| Check project health | ✓ Pass | Correctly identifies missing artifacts |
| Query capabilities with invalid query | ✓ Pass | Returns empty results with helpful message |
| Get artifact spec with invalid type | ✗ Fail | Error message unclear — says "invalid" but doesn't list valid types |

#### Success Criteria Validation

| Criterion | Met? | Evidence |
|-----------|------|----------|
| All ACM orchestration queries work | ✓ Yes | Tested get_stage, get_review_prompt, get_transition_prompt |
| Helpful error messages | ✗ No | Invalid enum error doesn't show valid options |
| Tool descriptions clear | ✓ Yes | Each tool description explains purpose and usage |

#### Issues Found

| Issue | Severity | Description |
|-------|----------|-------------|
| Enum error message unclear | High | When passing invalid artifact type, error says "Invalid type" but doesn't show valid options (brief, intent, status, etc.) |

#### Overall Assessment

**Pass/Fail:** Fail with issues

**Summary:** Core functionality works well, but error handling needs improvement. Users won't know valid options when they make mistakes.

**Recommendation:** Fix enum error messages to include valid values, then retest.
