# Ralph Loop Review Experiment

## Purpose

Test whether Ralph Loop can drive the Discover stage review cycle — iterating on a Brief until it meets exit criteria.

## Hypothesis

Ralph's self-referential loop can automate Brief revision by:
1. Reading the current Brief state from file
2. Applying review feedback (from previous iteration or external input)
3. Updating the Brief
4. Checking exit criteria
5. Repeating until complete

## Limitation Tested

Ralph is Claude-only (single agent). Our ideal review loop uses external models (GPT, Gemini) for diverse perspectives. This experiment tests whether Claude self-review produces useful iteration.

---

## Setup

### 1. Install Ralph Loop Plugin

```bash
# From Claude Code — use the plugin installer
/install-plugin ralph-loop
```

Or manually clone to your Claude Code plugins directory.

### 2. Prepare Test Artifacts

Create a rough Brief to iterate on. Use your portfolio project or a simple test case.

Place in this directory: `test-brief.md`

### 3. Run the Experiment

**Important syntax notes:**
- Use namespaced command: `/ralph-loop:ralph-loop` (not just `/ralph-loop`)
- Use **absolute paths** — Ralph runs from Claude Code's working directory, not this folder

```bash
/ralph-loop:ralph-loop "$(cat ~/code/_shared/acm/experiments/ralph-review-loop/test-prompt.md)" --max-iterations 10 --completion-promise "REVIEW_COMPLETE"
```

---

## Skill Reference

| Skill | Purpose |
|-------|---------|
| `/ralph-loop:ralph-loop "<prompt>"` | Start a loop |
| `/ralph-loop:cancel-ralph` | Cancel active loop |
| `/ralph-loop:help` | Show help |

---

## Test Prompt

See `test-prompt.md` for the full prompt. Key elements:

- **Task:** Review and improve the Brief
- **Completion criteria:** All P1 issues resolved, no new critical issues found
- **Completion promise:** Output `<promise>REVIEW_COMPLETE</promise>` when done
- **Safety net:** Max 10 iterations

**Note:** The prompt must reference the Brief using an **absolute path** since Ralph doesn't know your working directory.

---

## Results (2026-01-27)

### What Happened

- Ralph completed in **2 iterations**
- Initial Brief was intentionally weak (vague problem, subjective success criteria, no constraints)
- Final Brief has measurable criteria, explicit constraints, assumptions section

### Issues Found and Resolved

| # | Issue | Status |
|---|-------|--------|
| 1 | Problem statement too vague | Resolved |
| 2 | Desired outcome unverifiable ("nice looking") | Resolved |
| 3 | Success criteria not measurable | Resolved |
| 4 | No assumptions section | Resolved |
| 5 | Scope items lack detail | Open (P2) |
| 6 | Open questions are blockers | Open (P2) |
| 7 | No constraints identified | Resolved |
| 8 | Open Questions vs Constraints inconsistency | Open (P2) |

### Assessment

**Worked well:**
- Claude found real issues, not cosmetic ones
- Iteration produced meaningful improvement
- Loop terminated appropriately (didn't spin)
- P1/P2 prioritization was reasonable

**Limitations:**
- Single-model review — no external perspective
- 2 iterations may be too fast (rubber-stamping risk)
- P2 issues left open — appropriate for handoff to Design, but could be stricter

---

## Success Criteria Evaluation

1. [x] Ralph loop runs without crashing
2. [x] Brief improves measurably across iterations
3. [x] Loop terminates on completion promise (not max iterations)
4. [ ] Final Brief would pass external review — **needs validation**

---

## Next Steps

1. **External validation:** Submit final Brief to GPT/Gemini to check what Claude missed
2. **Integration decision:** If external review finds major issues, Ralph alone isn't sufficient
3. **Hybrid approach:** Consider Ralph for rapid iteration + periodic external checkpoints

---

## Files in This Experiment

| File | Purpose |
|------|---------|
| `README.md` | This file — experiment overview and results |
| `test-prompt.md` | The Ralph loop prompt |
| `test-brief.md` | Brief that was iterated on |
