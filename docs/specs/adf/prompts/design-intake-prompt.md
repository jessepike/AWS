---
type: "prompt"
description: "Structured questioning prompt for Design stage Intake & Clarification phase"
version: "1.0.0"
updated: "2026-01-27"
scope: "design"
usage: "Use at start of Design stage to drive clarification interview with human"
---

# Design Intake Prompt (Phase 1: Intake & Clarification)

## Purpose

Drive a structured interview at the start of Design stage. The goal is to resolve ambiguities, surface decisions, and ensure the agent has everything needed to draft design.md.

---

## Usage

At the start of a Design session, the agent should:

1. Load this prompt as guidance for the intake process
2. Read Brief + Intent thoroughly
3. Use AskUserQuestion pattern to interview the human
4. Continue until all clarifications are resolved
5. Confirm: "I have what I need to draft the design"

---

## Prompt

```
You are starting the Design stage of an ADF project. Before drafting any design specifications, you must thoroughly understand the Brief and resolve all ambiguities through structured questioning.

## Your Task

1. Read the Brief and Intent completely
2. Identify ambiguities, gaps, implicit assumptions, and decisions needed
3. Conduct a structured interview using batches of 2-4 targeted questions
4. Continue in multiple rounds until all clarifications are resolved
5. Confirm you have enough to draft design.md

## Questioning Categories

Work through these areas systematically. Not every category applies to every project — focus on what's relevant.

### Brief Interpretation
- "I read [X] as meaning [Y] — is that correct?"
- "The Brief says [term] — what specifically does that mean in this context?"
- "The success criteria mention [X] — how will we measure that concretely?"

### Ambiguity Resolution
- "The Brief mentions [feature] but doesn't specify [detail] — what's your preference?"
- "[Section A] seems to imply X, but [Section B] suggests Y — which is correct?"
- "This constraint could be interpreted as [A] or [B] — which did you mean?"

### Technical Preferences
- "For [component], I see options: [A], [B], [C]. Do you have a preference, or should I recommend?"
- "The Brief doesn't specify [technical choice] — any constraints I should know about?"
- "Are there existing tools/systems this needs to integrate with?"

### Constraint Clarification
- "You mentioned [constraint] — is there a specific threshold/limit?"
- "The Brief says [soft constraint] — is that a hard requirement or a preference?"
- "If we hit a conflict between [A] and [B], which takes priority?"

### Proactive Recommendations
- "Based on the Brief, I'd recommend [approach] because [reason] — thoughts?"
- "I see an opportunity to simplify by [X] — would that align with your goals?"
- "Industry standard for [this type of thing] is [Y] — should we follow that or deviate?"

### Risk Surfacing
- "I see a potential issue: [description]. How should we handle it?"
- "This assumption seems risky: [assumption]. What's our fallback if it's wrong?"
- "The Brief depends on [external factor] — what if that changes?"

### Prioritization
- "If we can't do everything in scope, what's non-negotiable vs nice-to-have?"
- "Between [A] and [B], which matters more if we have to choose?"
- "What would make this a success even if we cut corners elsewhere?"

### Capabilities & Tooling
- "Based on this design, I think you'll need: [list of tools/skills/agents]. Sound right?"
- "Are there any specific tools you want to use or avoid?"
- "Any capabilities you think might be helpful that I should consider?"

## What NOT to Ask

- **Timeline/effort estimates** — Don't ask "how long will this take" or suggest effort levels
- **Resource planning** — Don't ask about team size, skill levels, or availability
- **Scope expansion** — Don't suggest adding features or "have you considered X?"
- **Obvious questions** — If the Brief clearly answers it, don't ask again

## Questioning Style

- **Batched:** 2-4 questions at a time, not overwhelming
- **Probing:** Go deep on important topics, don't just skim surface
- **Iterative:** Follow up based on answers, don't stick to a rigid script
- **Decisive:** Help the human make decisions, don't just collect information
- **Concrete:** Ask about specific choices, not abstract preferences

## Process

Round 1: Start with the most critical ambiguities and interpretation questions
Round 2+: Follow up based on answers, probe deeper, surface new questions
Final Round: Confirm understanding, verify you have what you need

## Exit Criteria

Stop interviewing when:
- [ ] All Brief ambiguities resolved
- [ ] Technical preferences clarified (or agent empowered to decide)
- [ ] Constraints have concrete thresholds where needed
- [ ] Prioritization clear for trade-off decisions
- [ ] Capabilities inventory has human input
- [ ] Agent can confidently draft design.md

## Completion

When you have enough to proceed:

"I have what I need to draft the design specification. Here's my understanding: [brief summary of key decisions/clarifications]. Ready to proceed to Technical Design."

If the human confirms, move to drafting design.md.
```

---

## Notes

- This is not a checklist to exhaustively complete — focus on what matters for the specific project
- Some projects will need 1-2 rounds of questions; complex ones may need 5+
- The goal is clarity, not bureaucracy
- If the Brief is already clear on something, don't re-ask
