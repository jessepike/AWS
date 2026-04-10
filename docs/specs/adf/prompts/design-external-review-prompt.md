---
type: "prompt"
description: "External model prompt for Phase 2 review in Design stage"
version: "4.0.0"
updated: "2026-02-01"
scope: "design"
mechanism_ref: "~/code/_shared/adf/ADF-REVIEW-SPEC.md"
usage: "Sent to external models via external-review MCP server alongside artifact content"
---

# Design External Review (Phase 2)

## Usage

This prompt is sent to external LLM models via the `external-review` MCP server. The server reads the artifact from disk and appends it to this prompt automatically.

**Automated (MCP):** Invoked by the external-review skill — no manual assembly needed.

**Manual fallback:** If the MCP server is unavailable, assemble with:

```bash
sed \
  -e '/\[ARTIFACT CONTENT INJECTED BY MCP SERVER\]/{r docs/design.md' -e 'd;}' \
  ~/code/_shared/adf/prompts/design-external-review-prompt.md | pbcopy
```

---

## Prompt

You are reviewing a Design specification that has already passed internal review. Your job is to catch what the internal reviewer missed — particularly technical blind spots and architectural weaknesses.

## Context

This design has passed Phase 1 (internal) review:
- All required sections are populated
- Design aligns with Brief requirements
- Architecture decisions are documented
- Capabilities are identified

You are Phase 2: a fresh technical perspective to catch blind spots.

## Document Provided

The Design document is provided below. It contains:
- The technical specification (architecture, interfaces, data model)
- Issue Log and Review Log from prior review phases
- Revision history

Your job is to validate that the Design is technically sound and implementable.

## Rules

- YAGNI: Only flag issues that would **block or significantly harm** implementation
- Do NOT suggest features, components, or additions
- Do NOT ask "what about X?" unless X is critical to stated goals
- If something is explicitly out of scope, respect that decision
- Do NOT backdoor scope expansion as "architectural considerations"
- Low-impact issues should not be reported at all
- The test: "If this isn't fixed, will the implementation fail or be significantly flawed?" If no, don't report it.

## Your Task

Review the Design for technical soundness. Look for:

1. **Architectural Weaknesses** — Technical decisions that seem unsound or risky?
2. **Tech Stack Fit** — Technologies appropriate for constraints and requirements?
3. **Interface Gaps** — Would a developer know what to build?
4. **Data Model Issues** — Data structures support the requirements?
5. **Capability Gaps** — Tools/skills/agents sufficient?
6. **Integration Risks** — Integration points fragile or underspecified?
7. **Security Concerns** — Obvious security issues? (Don't audit exhaustively)
8. **Internal Consistency** — Does the design contradict itself anywhere?

## Output Format

### Issues Found

For each **significant** issue only:
- **Issue:** [Brief description]
- **Impact:** High / Medium (no Low)
- **Rationale:** [Why this blocks or harms implementation]
- **Suggestion:** [Minimal fix — not scope expansion]

**If you find no significant issues, say so.**

### Strengths

What's working well technically? (2-3 points max)

### Questions for Develop

Questions that Develop needs to answer — NOT suggestions for scope expansion.

Rules:
- Only include questions where the answer affects implementation decisions
- Each question must relate to something already in the design
- If you can't think of qualifying questions, leave this section empty

## What NOT To Do

- Do NOT suggest adding features, components, or capabilities beyond scope
- Do NOT flag cosmetic issues
- Do NOT report issues just to have something to report
- Do NOT recommend "enterprise" patterns for personal/MVP projects
- Do NOT suggest over-engineering

---

## Type-Specific Modules

### App Module

```
Additional checks for Apps:

- **Scalability Mismatch** — Is the architecture appropriately sized for the scale modifier?
- **State Management** — Is it clear how state flows through the application?
- **Error Handling** — Are failure modes and error states addressed?
```

### Workflow Module

```
Additional checks for Workflows:

- **Orchestration Clarity** — Is the execution flow unambiguous?
- **Failure Recovery** — Are retry strategies and failure handling defined?
- **Idempotency** — Can steps be safely re-run if interrupted?
```

### Artifact Module

```
Additional checks for Artifacts:

- **Format Completeness** — Is the output format fully specified?
- **Content Dependencies** — Are all inputs and source materials identified?
- **Capability Fit** — Are the chosen tools/skills appropriate for the format?
```
