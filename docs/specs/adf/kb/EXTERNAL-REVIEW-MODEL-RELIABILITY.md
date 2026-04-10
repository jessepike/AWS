# External Review Model Reliability

Tracking log for review iteration learnings. Goal: tune the review function through 10-20 real reviews (week of 2026-02-01).

## Tuning Targets

After each review, log observations below and check whether any of these need adjustment:

| Target | File | What to tune |
|--------|------|-------------|
| External model prompts | `prompts/{stage}-external-review-prompt.md` | Prompt clarity, false positive triggers, severity calibration |
| External ralph prompts | `prompts/{stage}-external-ralph-prompt.md` | Orchestration instructions, synthesis quality, stop conditions |
| Internal review prompts | `prompts/{stage}-ralph-review-prompt.md` | Coverage, YAGNI enforcement, severity thresholds |
| Review spec | `ADF-REVIEW-SPEC.md` | Cycle rules, severity definitions, stop conditions |
| Model config | `~/.claude/models.yaml` | Model selection, pricing, extra_params tuning |
| Single-model warning | `acm-review/commands/artifact-external.md` | Threshold for warning, default model count |

## Per-Model Observations

### Gemini
- ~20% false positive rate (1/5 issues, hallucinated nonexistent field) — sample size: 1 review
- Hallucination type: referencing artifact sections/fields that don't exist
- Review 2: Re-raised already-tracked OQs as High issues (3 of 5 items in Round 5 were re-raises). Tends to ignore "already deferred to Develop" status.
- Review 4: Clean review - 0 false positives, 4 valid issues (1 High, 3 Medium). Good architectural insights (Task tool invocation clarity, degraded mode specification).
- Good at finding real structural issues (URL normalization, dedup logic, implementation gaps)
- Sample size: 3 reviews (5 cycles total)

### GPT
- 2 true High issues in Round 4 (URL PK, API call count) — good signal, different from Gemini's findings
- Round 5: flagged DB↔Raindrop consistency and ETag concerns — valid for enterprise but Low for personal MVP
- Tendency toward enterprise-grade concerns (transaction coordination, optimistic concurrency) — appropriate for larger projects, overshoot for MVP
- Sample size: 1 review (3 cycles)

### Kimi-K2
- Timed out on first invocation (2 retries attempted)
- Need to investigate timeout — may need increased timeout or model config change

## Pattern Log

Patterns that emerge across multiple reviews. Update as data accumulates.

| Pattern | Occurrences | Action Taken |
|---------|-------------|-------------|
| Single-model false positives | 1 | Added single-model warning to artifact-external command |
| Shell pipe corruption in prompts | 1 | Added --prompt-file to ralph-loop |
| Models re-raise already-tracked OQs despite "deferred to Develop" | 2 | Convergence prompt explicitly says "Do NOT re-flag items tracked as OQs" — helps but doesn't eliminate |
| Kimi-K2 errors (timeout or unknown model) | 2 | Review 3: timeout. Review 4: unknown model error. Check model availability and config. |
| GPT enterprise-grade over-engineering for MVP | 1 | Monitor — may need MVP-scale emphasis in prompt |

## Review Iteration Log

Log every review here. One row per review invocation.

| # | Date | Project | Stage | Phase | Models | Cycles | Issues Found | False Positives | True Positives | Action Items |
|---|------|---------|-------|-------|--------|--------|-------------|----------------|---------------|-------------|
| 1 | 2026-02-01 | ACM | Design | External | Gemini | 1 | 5 | 1 (hallucinated field) | 4 | Added single-model warning, --prompt-file |
| 2 | 2026-02-01 | link-triage-pipeline | Design | Internal | claude | 2 | 0 | 0 | 0 | none |
| 3 | 2026-02-01 | link-triage-pipeline | Design | External | Gemini, GPT (Kimi timeout) | 3 | 9 | 3 (re-raised tracked OQs) | 3 High + 6 Low | URL PK→raindrop_id, API call clarification, dedup logic |
| 4 | 2026-02-03 | pike-ace | Design | External | Gemini (Kimi-K2 unknown model error) | 1 | 4 | 0 | 1 High + 3 Medium | Task tool invocation clarified, open questions resolved, degraded mode defined, progressive disclosure deferred to Develop |

## Recommendations (living)

- Default to 2+ models for external review
- Treat single-model structural claims with higher scrutiny
- After 5 reviews: reassess severity calibration in prompts
- After 10 reviews: consider model-specific prompt tuning if patterns diverge
- After 20 reviews: publish tuned defaults and archive this tracking log
