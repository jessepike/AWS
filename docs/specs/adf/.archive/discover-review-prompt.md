---
type: "prompt"
description: "Base review prompt for Discover stage Brief review"
version: "1.0.0"
updated: "2026-01-27"
scope: "discover"
usage: "Submit to external reviewer models along with the Brief"
---

# Discover Stage: Brief Review Prompt

## Usage

Copy this prompt and append the Brief content when submitting to external reviewer models (Claude, GPT-4, Gemini, etc.).

---

## Prompt

```
You are reviewing a project Brief as part of a structured discovery process. Your role is to provide critical, constructive feedback that strengthens the Brief before it moves to the Design stage.

## Context

This Brief is being developed using ACM (Agentic Context Management) — a minimal framework for agent-assisted project development. The Brief is the primary deliverable of the Discover stage. It defines what we're building, why, scope boundaries, success criteria, and constraints.

The Brief will be:
- Consumed in Design (drives architecture and technical decisions)
- Referenced in Develop and Deliver (validates we're building the right thing)

## Your Task

Review the attached Brief for:

1. **Clarity** — Is the intent clear? Would a new team member understand what we're building and why?

2. **Completeness** — Are all required sections populated? Are there obvious gaps?

3. **Scope** — Are boundaries explicit? Is there anything ambiguous about what's in vs out?

4. **Success Criteria** — Are they verifiable? Could someone objectively assess if each criterion is met?

5. **Feasibility** — Are there red flags suggesting this is unrealistic given stated constraints?

6. **Assumptions** — What assumptions are being made? Are any risky or unstated?

7. **Non-obvious Considerations** — What might the author be missing? What questions should they be asking?

## Output Format

Structure your feedback as:

### Issues Found

For each issue:
- **Issue:** [Brief description]
- **Impact:** High / Medium / Low
- **Rationale:** [Why this matters]
- **Suggestion:** [How to address it]

### Strengths

What's working well in this Brief? (2-3 points)

### Questions to Consider

Open questions the author should think through (not necessarily issues, but considerations).

## Constraints

- Do NOT rewrite the Brief. Provide feedback, not a replacement.
- Do NOT expand scope. Flag scope creep if you see it.
- Do NOT add requirements. Identify gaps, don't fill them.
- Be direct and specific. Vague feedback is not useful.
- Prioritize. Not everything is equally important.

---

## Brief to Review

[PASTE BRIEF CONTENT HERE]
```

---

## Type-Specific Modules

For certain project types, append additional review focus areas to the base prompt.

### Commercial App Module

Add after "7. Non-obvious Considerations" in the review task:

```
8. **Market Fit** — Is the target market clearly defined? Is the value proposition compelling?

9. **Competitive Position** — Is differentiation clear? Are competitor comparisons realistic?

10. **Monetization** — Is the revenue model viable? Are pricing assumptions reasonable?

11. **Financial Projections** — Are forecasts grounded in reality? What assumptions drive them?

12. **Go-to-Market** — Is the launch strategy realistic given constraints?
```

### Workflow Module

Add after "7. Non-obvious Considerations" in the review task:

```
8. **Trigger Clarity** — Is it clear what initiates this workflow and under what conditions?

9. **Integration Points** — Are all external systems identified? Are there hidden dependencies?

10. **Data Flow** — Is the input/output transformation clear? Are edge cases considered?

11. **Error Handling** — What happens when things fail? Is recovery strategy defined?

12. **Scalability** — Will this workflow handle expected volume? What are the bottlenecks?
```

### Artifact Module

Add after "7. Non-obvious Considerations" in the review task:

```
8. **Audience Fit** — Is the target audience clearly defined? Will this artifact serve their needs?

9. **Format Appropriateness** — Is the chosen format right for the content and audience?

10. **Source Quality** — Are the inputs/sources sufficient to produce a quality output?

11. **Scope vs Depth** — Is the balance between breadth and depth appropriate?
```

---

## Capturing Feedback

After receiving reviewer feedback:

1. Extract discrete issues
2. Log each in the Brief's Issue Log with:
   - Issue description
   - Source (which model/reviewer)
   - Impact (High/Med/Low)
   - Priority (P1/P2/P3)
   - Status (Open)
3. Identify cross-reviewer consensus (issues flagged by multiple reviewers)
4. Prioritize P1s for immediate action
5. Update Brief's Session State with review cycle progress

---

## Example Issue Log Entry

From reviewer feedback:

> **Issue:** Success criteria are vague — "user-friendly" is not measurable
> **Impact:** High
> **Suggestion:** Replace with specific metrics (task completion time, error rate, etc.)

Becomes:

| # | Issue | Source | Impact | Priority | Status | Resolution |
|---|-------|--------|--------|----------|--------|------------|
| 4 | Success criteria vague ("user-friendly" not measurable) | GPT-4 | High | P1 | Open | - |
