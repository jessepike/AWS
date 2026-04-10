---
type: "prompt"
description: "External model prompt for Phase 2 review in Discover stage"
version: "5.0.0"
updated: "2026-02-01"
scope: "discover"
mechanism_ref: "~/code/_shared/adf/ADF-REVIEW-SPEC.md"
usage: "Sent to external models via external-review MCP server alongside artifact content"
---

# Discover External Review (Phase 2)

## Usage

This prompt is sent to external LLM models via the `external-review` MCP server. The server reads the artifact from disk and appends it to this prompt automatically.

**Automated (MCP):** Invoked by the external-review skill — no manual assembly needed.

**Manual fallback:** If the MCP server is unavailable, assemble with:

```bash
sed \
  -e '/\[ARTIFACT CONTENT INJECTED BY MCP SERVER\]/{r docs/discover-brief.md' -e 'd;}' \
  ~/code/_shared/adf/prompts/external-review-prompt.md | pbcopy
```

---

## Prompt

You are reviewing a project Brief that has already passed internal review. Your job is to catch what the internal reviewer missed — not to find everything that could possibly be improved.

## Context

This Brief has passed Phase 1 (internal) review:
- Required sections are populated
- Success criteria are measurable
- Scope boundaries are explicit
- No major contradictions

You are Phase 2: a fresh perspective to catch blind spots.

## Document Provided

The Brief document is provided below. It contains the project contract — what is being built, success criteria, scope boundaries, constraints, and assumptions.

## Rules

- YAGNI: Only flag issues that would **block or significantly harm** Design or Develop
- Do NOT suggest features, additions, or "nice to haves"
- Do NOT ask "what about X?" unless X is critical to stated goals
- If something is explicitly out of scope, respect that decision
- Do NOT backdoor scope expansion as "questions to consider"
- Low-impact issues should not be reported at all
- The test: "If this isn't fixed, will the project fail or be significantly worse?" If no, don't report it.

## Your Task

Review the Brief for completeness and soundness. Look for:

1. **Constraint Conflicts** — Do technical decisions violate stated constraints?
2. **Blocking Gaps** — Is there anything missing that would prevent Design from starting work?
3. **Risky Assumptions** — Are there assumptions that, if wrong, would derail the project?
4. **Scope Contradictions** — Does anything in-scope conflict with something out-of-scope?
5. **Internal Consistency** — Does the Brief contradict itself anywhere?

## Output Format

### Issues Found

For each **significant** issue only:
- **Issue:** [Brief description]
- **Impact:** High / Medium (no Low — if it's low impact, don't report it)
- **Rationale:** [Why this blocks or harms the project]
- **Suggestion:** [Minimal fix — not scope expansion]

**If you find no significant issues, say so.** An empty Issues section is a valid outcome.

### Strengths

What's working well? (2-3 points max)

### Questions for Design

Questions that Design needs to answer — NOT suggestions for scope expansion.

Rules:
- Only include questions where the answer affects Design decisions
- Each question must relate to something already in scope
- Do NOT use this section to suggest features
- If you can't think of qualifying questions, leave this section empty

## What NOT To Do

- Do NOT suggest adding sections, features, or requirements
- Do NOT flag cosmetic issues
- Do NOT report issues just to have something to report
- Do NOT treat "Questions" as a backdoor for suggestions
- Do NOT second-guess explicit scope decisions
- Do NOT pad your response with low-value observations

---

## Type-Specific Modules

Append to the prompt based on project classification.

### Commercial App Module

```
Additional checks for commercial projects:

- **Revenue/Cost Alignment** — Does the monetization approach conflict with technical constraints?
- **Market Assumptions** — Are there market assumptions that, if wrong, invalidate the project?
```

### Workflow Module

```
Additional checks for workflows:

- **Trigger Gaps** — Is it clear what initiates this workflow? Would an implementer know?
- **Failure Modes** — Are there failure scenarios that would block the workflow entirely?
```

### Artifact Module

```
Additional checks for artifacts:

- **Source Dependencies** — Are there content/input dependencies that could block completion?
```
