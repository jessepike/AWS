# Issue Severity Classification Guide

This guide helps classify issues found during ADF reviews.

## Severity Levels

### Critical

**Definition:** Blocks implementation entirely. Build phase cannot proceed.

**Examples:**
- Missing required artifact (no tasks.md in Develop stage)
- Fundamental architectural flaw (no transaction protocol for distributed storage)
- Impossible dependencies (circular task dependencies)
- Missing critical capability (no API key for required service, no way to obtain)

**Test:** "Can we start Phase 0 implementation with this unfixed?" → If no, it's Critical.

**Action:** Must fix before proceeding to Build phase.

### High

**Definition:** Significant gap or risk. Build will fail or produce significantly wrong output.

**Examples:**
- Undefined tokenizer for chunking (different results across implementations)
- Missing database migration strategy (data loss risk)
- Incompatible deployment pattern (Docker exec with stdio won't work)
- Uncontrolled IDs causing sync issues (chunk IDs not matching vector IDs)

**Test:** "Will this cause build failures or major defects?" → If yes, it's High.

**Action:** Should fix before Phase 0, but Build can start if mitigation documented.

### Medium

**Definition:** Design clarification needed. May cause issues but won't block completely.

**Examples:**
- Unclear return types (what does search_semantic return?)
- Missing normalization (priority scores unbounded)
- Performance target conflicts (500ms with remote API)
- Edge case handling undefined (what happens on URL collision?)

**Test:** "Will this cause confusion or inefficiency during Build?" → If yes, it's Medium.

**Action:** Document for awareness, address during implementation or skip if accepted.

### Low

**Definition:** Minor documentation or cosmetic issue. No impact on implementation.

**Examples:**
- Typos in documentation
- Tool count inconsistencies (design says "20+", actual 16)
- Missing stub return value documentation

**Test:** "Does this affect implementation decisions?" → If no, it's Low.

**Action:** Note for polish, don't spend review cycles on it.

## Classification Decision Tree

```
Does it block starting implementation?
├─ YES → Critical
└─ NO
   └─ Will it cause significant build failures or defects?
      ├─ YES → High
      └─ NO
         └─ Will it cause confusion or inefficiency?
            ├─ YES → Medium
            └─ NO → Low
```

## Common Misclassifications

### Over-Escalation

❌ **Wrong:** "Missing example in docs" → High
✅ **Correct:** "Missing example in docs" → Low (doesn't affect build)

❌ **Wrong:** "Performance target ambitious" → Critical
✅ **Correct:** "Performance target ambitious" → Medium (document, test, adjust)

### Under-Escalation

❌ **Wrong:** "No transactional safety between DBs" → Medium
✅ **Correct:** "No transactional safety between DBs" → High (will cause data corruption)

❌ **Wrong:** "Circular task dependencies" → High
✅ **Correct:** "Circular task dependencies" → Critical (blocks implementation entirely)

## Stage-Specific Guidelines

### Discover Stage

**Critical:** Missing intent.md or brief.md
**High:** Unclear success criteria
**Medium:** Vague problem statement

### Design Stage

**Critical:** No data model or architecture
**High:** Incompatible technology choices
**Medium:** Unclear component boundaries

### Develop Stage

**Critical:** No tasks.md or missing capabilities
**High:** Unimplementable tasks or missing dependencies
**Medium:** Unclear testing strategy

### Deliver Stage

**Critical:** No deployment artifact or documentation
**High:** Broken deployment process
**Medium:** Incomplete handoff instructions

## Review Phase Differences

### Internal Review (Ralph Loop)

Focus on structural issues:
- Missing artifacts
- Task atomicity
- Dependency completeness
- Consistency across artifacts

### External Review (Multi-Model)

Focus on technical soundness:
- Architectural weaknesses
- Implementation feasibility
- Integration risks
- Hidden complexity

## Issue Reporting Format

```markdown
| # | Issue | Source | Severity | Status | Resolution |
|---|-------|--------|----------|--------|------------|
| 8 | No transactional protocol SQLite ↔ Chroma | GPT, Kimi | High | Open | Add staged-commit pattern in Phase 2 |
```

**Fields:**
- **#**: Sequential issue number
- **Issue**: Brief description (1 line)
- **Source**: Ralph-Stage-C# or Model names
- **Severity**: Critical/High/Medium/Low
- **Status**: Open/Resolved
- **Resolution**: How it was/will be addressed

## YAGNI Principle in Reviews

**Do NOT flag:**
- Feature suggestions ("should add X capability")
- Over-engineering ("should use enterprise pattern Y")
- Nice-to-haves ("would be nice to have Z")
- Cosmetic improvements

**Only flag if:**
- Missing element blocks or harms implementation
- Technical decision is unsound
- Significant gap or risk exists

**The test:** "If this isn't fixed, will the build fail or produce something significantly wrong?"
→ If no, don't report it.

## Examples from Real Reviews

### Example 1: Chunk ID Control (High)

**Issue:** "Chunk IDs not explicitly controlled - risk of mismatch with Chroma"

**Why High:**
- Will cause sync test failures (test #4)
- Data integrity issue if IDs diverge
- Directly impacts vector search reliability

**Not Critical because:**
- Build can proceed with fix during Phase 2
- Mitigation possible (generate UUIDs explicitly)

### Example 2: Tokenizer Unspecified (High)

**Issue:** "Tokenizer not specified for chunking (500 tokens, 50 overlap)"

**Why High:**
- Different implementations will chunk differently
- Will break token count accuracy
- Directly affects embedding costs and quality

**Not Critical because:**
- Can specify tiktoken during Phase 0
- Doesn't block starting implementation

### Example 3: Tool Count Discrepancy (Medium)

**Issue:** "Design says 20+ tools, actual ~16"

**Why Medium:**
- Documentation precision issue
- May cause expectation mismatch
- Easy to clarify

**Not High because:**
- Doesn't affect implementation
- 16 tools sufficient for MVP
- Can update docs anytime

### Example 4: Stub Return Value (Low)

**Issue:** "Task 0.9 doesn't specify stub returns 0.5 default"

**Why Low:**
- Clear from context
- Implementation detail
- No ambiguity in practice

**Not Medium because:**
- Won't cause confusion
- Obvious what stub should do
