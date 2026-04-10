# Ralph Loop Test Prompt

## Usage

**Important:** Use absolute paths and namespaced command.

```bash
/ralph-loop:ralph-loop "$(cat ~/code/_shared/acm/experiments/ralph-review-loop/test-prompt.md)" --max-iterations 10 --completion-promise "REVIEW_COMPLETE"
```

Or copy the prompt section below directly into the command.

---

## Prompt

Copy everything between the triple backticks:

```
You are iterating on a project Brief as part of ACM's Discover stage review loop.

## Your Task

1. Read the Brief at: ~/code/_shared/acm/experiments/ralph-review-loop/test-brief.md
2. Review it critically using the criteria below
3. Log any issues found in the Brief's Issue Log
4. Address all P1 issues by updating the Brief
5. Re-review after changes
6. Repeat until no P1 issues remain and the Brief meets exit criteria

## Review Criteria

Evaluate the Brief for:

1. **Clarity** — Is the intent clear? Would someone new understand what we're building and why?
2. **Completeness** — Are all required sections populated? Any obvious gaps?
3. **Scope** — Are boundaries explicit? Anything ambiguous about in vs out?
4. **Success Criteria** — Are they verifiable? Could someone objectively assess each?
5. **Feasibility** — Red flags suggesting this is unrealistic?
6. **Assumptions** — What's assumed? Any risky or unstated?
7. **Consistency** — Do all sections align? Any contradictions?

## Issue Logging

For each issue found, add to the Brief's Issue Log:

| # | Issue | Source | Impact | Priority | Status | Resolution |
|---|-------|--------|--------|----------|--------|------------|
| N | [description] | Ralph-Review | High/Med/Low | P1/P2/P3 | Open | - |

## Priority Definitions

- **P1:** Must resolve before completion. Blocker.
- **P2:** Should resolve. May note for Design if minor.
- **P3:** Nice to have. Can defer.

## Exit Criteria

The Brief is complete when:

- [ ] All required sections populated
- [ ] Project classification assigned
- [ ] Scope boundaries explicit (in/out clear)
- [ ] Success criteria verifiable (not vague)
- [ ] No P1 issues open
- [ ] No internal contradictions

## Completion

When ALL exit criteria are met and you have verified no P1 issues remain:

1. Update the Brief's status to "complete"
2. Add a final entry to the Issue Log noting completion
3. Output: <promise>REVIEW_COMPLETE</promise>

## Constraints

- Be genuinely critical. Don't rubber-stamp.
- Each iteration should make meaningful progress.
- If stuck on the same issue for 3+ iterations, flag it as needing human input.
- Do NOT expand scope. Flag scope creep, don't add features.
- Do NOT invent requirements. Identify gaps, don't fill them with assumptions.

## Important

This is a test of iterative self-review. Push yourself to find real issues, not just cosmetic ones. The goal is a Brief that would survive external review by GPT/Gemini without major feedback.
```

---

## Before Running

Paths are resolved to `~/code/_shared/acm`. If your ACM directory is elsewhere, update the path in the prompt above.

---

## Notes

- The prompt explicitly asks Claude to be critical (addresses the "agrees with itself" risk)
- Max iterations capped at 10 as safety net
- Completion promise is explicit and tied to exit criteria

## Variations to Try

**Stricter version:** Add "Find at least 2 issues per iteration until exit criteria met"

**Logging version:** Add "After each iteration, append a summary to [path]/experiments/ralph-review-loop/iteration-log.md"

**External checkpoint:** Add "After iteration 5, pause and output NEEDS_EXTERNAL_REVIEW for human to send to GPT/Gemini"
