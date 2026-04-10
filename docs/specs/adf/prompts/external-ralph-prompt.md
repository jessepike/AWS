---
type: "prompt"
description: "Ralph Loop orchestrator prompt for Phase 2 external review in Discover stage"
version: "1.0.0"
updated: "2026-02-01"
scope: "discover"
mechanism_ref: "~/code/_shared/adf/ADF-REVIEW-SPEC.md"
usage: "Use with Ralph Loop plugin — instructs Claude to call external-review MCP each cycle"
---

# Discover External Review — Ralph Loop Orchestrator

## Usage

```bash
/ralph-loop:ralph-loop "$(cat ~/code/_shared/adf/prompts/external-ralph-prompt.md)" --max-iterations 10 --completion-promise "EXTERNAL_REVIEW_COMPLETE"
```

---

## Prompt

```
You are conducting Phase 2 (External) review of the Discover Brief as part of ADF's Discover stage.

## Mechanism

This review follows ADF-REVIEW-SPEC.md. Key rules:
- Minimum 1 review cycle, maximum 10
- Stop when a cycle produces zero Critical and zero High issues
- If past 4 cycles with Critical issues still appearing, stop and flag for human input
- If stuck on same issue for 3+ iterations, stop and flag for human input

## Files

- Brief: docs/discover-brief.md (in project root)

## Your Job — Each Iteration

### 1. Call External Models

Read the external review prompt content from `~/code/_shared/adf/prompts/external-review-prompt.md`.

Then call the MCP tool with all configured models in parallel:

mcp__external-review__review(
  models: ["kimi-k2", "gemini"],
  artifact_path: "{absolute_path_to_docs/discover-brief.md}",
  prompt: "{contents of external-review-prompt.md}"
)

Use the absolute path to the artifact. If --models was specified in the invoking command, use those models instead of the defaults.

### 2. Synthesize Responses

Process the parallel responses into a unified issue list:
- Extract distinct issues from each model's response
- Deduplicate — same issue from multiple models counts once; note all sources
- Issues flagged by 2+ models get higher confidence

### 3. Classify Issues

Assign severity and complexity per ADF-REVIEW-SPEC:

**Severity:**
- Critical: Must resolve. Blocks next stage or fundamentally flawed.
- High: Should resolve. Significant gap or weakness.
- Low: Minor. Polish, cosmetic, or implementation detail.

**Complexity:**
- Low: Direct edit, no research, clear fix
- Medium: Design thinking, small refactor, clear path
- High: Needs research, investigation, architectural rethinking

### 4. Apply Action Matrix

| Severity | Complexity | Action |
|----------|------------|--------|
| Critical | Low | Auto-fix immediately |
| Critical | Medium | Auto-fix immediately |
| Critical | High | **Flag for user** — stop and ask |
| High | Low | Auto-fix immediately |
| High | Medium | Auto-fix immediately |
| High | High | **Flag for user** — stop and ask |
| Low | Any | Log only (no fix) |

### 5. Update Artifact

1. Write fixes to docs/discover-brief.md
2. Update Issue Log entries with Status: Resolved and Resolution description
3. Add/update Review Log with cycle summary including cost:
   ### Cycle {N}
   - Models: {model_list}
   - Issues found: {N} (Critical: {N}, High: {N}, Low: {N})
   - Auto-fixed: {N}
   - Flagged to user: {N}
   - Cost: ${total_cost_usd}
   - Tokens: {total_input} in / {total_output} out

### 6. Check Stop Conditions

| Condition | Action |
|-----------|--------|
| Zero Critical + zero High issues (and min 1 cycle met) | **Stop — review complete** |
| Cycle 10 reached | **Hard stop** |
| Critical issues persist past cycle 4 | **Stop — structural problem** (flag to user) |
| Same issue persists 3+ cycles unchanged | **Stop — stuck** (flag to user) |
| Critical/High issues remain and fixable | Continue to next cycle |

## Completion

When stop conditions are met:
1. Update artifact frontmatter status if applicable
2. Output: <promise>EXTERNAL_REVIEW_COMPLETE</promise>
```
