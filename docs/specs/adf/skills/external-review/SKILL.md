---
name: external-review
description: Run Phase 2 external review — calls external LLMs via MCP, synthesizes feedback within Ralph Loop cycles
user_invocable: true
arguments:
  - name: stage
    description: "Override stage detection (discover|design|develop)"
    required: false
  - name: artifact
    description: "Override artifact path"
    required: false
  - name: models
    description: "Comma-separated model IDs (e.g., kimi,gemini)"
    required: false
---

# External Review Skill

You are executing a single cycle of Phase 2 external review. External LLM models review the artifact and you synthesize their feedback.

**Preferred invocation:** Use `/adf-review:artifact-external` (or `/adf-review:artifact` for full review) which handles iteration via Ralph Loop automatically. This skill is the single-cycle engine called within that loop.

## Step 1: Resolve Configuration (if invoked standalone)

If invoked directly (not via Ralph Loop), resolve configuration:

### Stage Detection
1. If `--stage` argument provided, use it
2. Otherwise, read `status.md` in the project root and extract the current stage
3. Valid stages: `discover`, `design`, `develop`

### Artifact Resolution
1. If `--artifact` argument provided, use the absolute path
2. Otherwise, use the stage default from `config.yaml`:
   - discover → `docs/discover-brief.md`
   - design → `docs/design.md`
   - develop → `docs/design.md`
3. Resolve path relative to project root

### Prompt Resolution
1. Try ADF MCP server: `adf.get_review_prompt(stage, "external")`
2. Fallback: read directly from `config.yaml` prompt path (relative to skill dir)

### Model Resolution
1. If `--models` argument provided, split by comma
2. Otherwise, use `default_models` from `config.yaml`
3. Verify models exist via MCP: `external-review.list_models()`

## Step 2: Confirm Before Execute (if invoked standalone)

Display the resolved configuration and wait for user confirmation:

```
External Review Configuration
─────────────────────────────
Stage:     {stage}
Artifact:  {artifact_path}
Prompt:    {prompt_source}
Models:    {model_list} (parallel)

Proceed? (y/n):
```

**Do NOT proceed without explicit user confirmation.**

## Step 3: Execute Single Review Cycle

### 3a. Call External Models

Use the MCP tool to call all models in parallel:

```
external-review.review(
  models: ["{model_1}", "{model_2}"],
  artifact_path: "{absolute_artifact_path}",
  prompt: "{review_prompt_content}"
)
```

The response includes per-model `cost_usd`, `tokens_used`, and aggregated `total_cost_usd` and `total_tokens`.

### 3b. Synthesize

Process the parallel responses into a unified issue list:

1. **Extract** — identify distinct issues from each model's response
2. **Deduplicate** — same issue from multiple models counts once; note all sources
3. **Consensus weight** — issues flagged by 2+ models get higher confidence

Use this synthesis prompt internally:

> Given these review responses from {N} external models, produce a deduplicated issue list. For each issue: (1) description, (2) source models, (3) consensus count, (4) suggested fix if provided. Group by theme. Exclude praise and general observations — only actionable issues.

### 3c. Classify

Assign severity and complexity per ADF-REVIEW-SPEC definitions:

**Severity:**
- **Critical**: Must resolve. Blocks next stage or fundamentally flawed.
- **High**: Should resolve. Significant gap or weakness.
- **Low**: Minor. Polish, cosmetic, or implementation detail.

**Complexity:**
- **Low**: Direct edit, no research, clear fix
- **Medium**: Design thinking, small refactor, clear path
- **High**: Needs research, investigation, architectural rethinking

### 3d. Capture

Format findings in the artifact's Issue Log section:

```markdown
| # | Issue | Source | Severity | Complexity | Status | Resolution |
|---|-------|--------|----------|------------|--------|------------|
| N | [description] | External-{model_id}[, External-{model_id}] | Critical | Medium | Resolved | [what was done] |
```

### 3e. Fix — Apply Action Matrix

| Severity | Complexity | Action |
|----------|------------|--------|
| Critical | Low | Auto-fix immediately |
| Critical | Medium | Auto-fix immediately |
| Critical | High | **Flag for user** — stop and ask |
| High | Low | Auto-fix immediately |
| High | Medium | Auto-fix immediately |
| High | High | **Flag for user** — stop and ask |
| Low | Any | Log only (no fix) |

### 3f. Update

1. Write fixes to the artifact
2. Update Issue Log entries with `Status: Resolved` and `Resolution` description
3. Add/update the **Review Log** section with cycle summary including cost:
   ```
   ### Cycle {N}
   - Models: {model_list}
   - Issues found: {N} (Critical: {N}, High: {N}, Low: {N})
   - Auto-fixed: {N}
   - Flagged to user: {N}
   - Cost: ${total_cost_usd}
   - Tokens: {total_input} in / {total_output} out
   ```

## Step 4: Report

Report single-cycle results:
```
External review cycle complete.
  Issues found:    {N} (Critical: {N}, High: {N}, Low: {N})
  Auto-fixed:      {N}
  Flagged to user: {N}
  Cost:            ${total_cost_usd}
  Tokens:          {input} in / {output} out
```
