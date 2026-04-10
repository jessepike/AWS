---
type: "prompt"
description: "External model prompt for Phase 2 review in Develop stage"
version: "4.0.0"
updated: "2026-02-01"
scope: "develop"
mechanism_ref: "~/code/_shared/adf/ADF-REVIEW-SPEC.md"
usage: "Sent to external models via external-review MCP server alongside artifact content"
---

# Develop External Review (Phase 2)

## Usage

This prompt is sent to external LLM models via the `external-review` MCP server. The server reads the artifact from disk and appends it to this prompt automatically.

**Automated (MCP):** Invoked by the external-review skill — no manual assembly needed.

**Manual fallback:** If the MCP server is unavailable, assemble with:

```bash
sed \
  -e '/\[ARTIFACT CONTENT INJECTED BY MCP SERVER\]/{r docs/design.md' -e 'd;}' \
  ~/code/_shared/adf/prompts/develop-external-review-prompt.md | pbcopy
```

---

## Prompt

You are reviewing an implementation plan/design that has already passed internal review. Your job is to catch what the internal reviewer missed — particularly feasibility issues and blind spots.

## Context

This artifact has passed Phase 1 (internal) review:
- All design requirements are addressed
- Dependencies and capabilities are identified
- Architecture decisions are documented
- Testing strategy is defined

You are Phase 2: a fresh perspective to catch blind spots.

## Document Provided

The artifact is provided below. Your job is to validate that it is technically sound and implementable.

## Rules

- YAGNI: Only flag issues that would block or significantly harm implementation
- Do NOT suggest features or capabilities beyond what's described
- Do NOT recommend over-engineering
- Do NOT add "nice to have" tooling or testing
- If something is out of scope, respect that decision
- The test: "If this isn't fixed, will the build fail or produce something significantly wrong?" If no, don't report it.

## Your Task

Review the artifact for technical soundness. Look for:

1. **Architectural Weaknesses** — Technical decisions that seem unsound or risky?
2. **Dependency Gaps** — Missing dependencies that will block implementation?
3. **Capability Gaps** — Skills/tools/sub-agents sufficient?
4. **Task Feasibility** — Any components too large or vague for implementation?
5. **Sequencing Issues** — Dependency problems in ordering?
6. **Testing Gaps** — Testing strategy catch real issues?
7. **Integration Risks** — Integration points fragile or under-planned?
8. **Internal Consistency** — Does the artifact contradict itself anywhere?

## Output Format

### Issues Found

For each significant issue only:
- **Issue:** [Brief description]
- **Impact:** High / Medium (no Low)
- **Rationale:** [Why this blocks or harms implementation]
- **Suggestion:** [Minimal fix]

**If you find no significant issues, say so.**

### Strengths

What's working well? (2-3 points max)

### Questions for Build

Questions for implementation — NOT suggestions for scope expansion.

Rules:
- Only include questions where the answer affects implementation
- Each question must relate to something already in the artifact
- If no questions meet criteria, leave empty

## What NOT To Do

- Do NOT suggest adding features or capabilities beyond scope
- Do NOT flag cosmetic issues
- Do NOT report issues just to have something to report
- Do NOT over-engineer — this is MVP-focused
- Do NOT second-guess explicit design decisions

---

## Type-Specific Modules

### App Module

```
Additional checks for Apps:

- **Build Pipeline** — Is there a clear path from code to running application?
- **State Management** — Are state patterns appropriate for the complexity?
- **Error Handling** — Are error states and edge cases covered in tasks?
```

### Workflow Module

```
Additional checks for Workflows:

- **Orchestration** — Is the execution flow clear and testable?
- **Failure Recovery** — Are retry and rollback strategies defined?
- **Idempotency** — Can steps be safely re-run if interrupted?
```

### Artifact Module

```
Additional checks for Artifacts:

- **Content Pipeline** — Is the process from inputs to output clear?
- **Validation** — How will output quality be verified?
- **Format Compliance** — Are format requirements covered in tasks?
```
