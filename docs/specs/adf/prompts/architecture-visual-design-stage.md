---
type: "prompt"
description: "Prompt for generating Design stage architecture diagram"
version: "1.1.0"
updated: "2026-02-02"
scope: "design"
lifecycle: "reference"
location: "prompts/architecture-visual-design-stage.md"
---

# Prompt: Design Stage Architecture Diagram

Use this prompt with an image generation tool or diagramming AI to create an architectural visualization of the ADF Design stage.

---

## Prompt

Create a clean, modern architecture diagram for "ADF Design Stage" showing the workflow, inputs, outputs, and phase progression.

**Layout:** Left-to-right flow with vertical sections for each phase

---

### 1. Inputs (Left Side)

**From Discover Stage:**
- intent.md (North Star) — green, star icon
- discover-brief.md (Contract) — green, document icon
- status.md (State) — gray, small

**From ADF Environment Layer:**
- ADF-DESIGN-SPEC.md
- Project Type classification

Arrow label: "Validated inputs from Discover"

---

### 2. Phase Flow (Center, Left to Right)

Four phases in sequence:

```
Intake & Clarification → Technical Design → Review Loop → Finalization
```

**Phase 1: Intake & Clarification**
- Box color: Light purple
- Human involvement: High
- Agent involvement: High
- Key activity: "Structured questioning (AskUserQuestion pattern)"
- Output: Resolved ambiguities, decisions made

**Phase 2: Technical Design**
- Box color: Purple
- Human involvement: Low-Medium
- Agent involvement: High
- Key activity: "Draft design.md and supporting artifacts"
- Output: Draft design.md

**Phase 3: Review Loop**
- Box color: Purple with internal split
- Contains two sub-phases:
  - **Internal (Ralph Loop)**: 2-4 iterations, Claude
  - **External (GPT/Gemini)**: 1-2 cycles, diverse perspectives
- Arrow between: Internal → External
- Exit signal: "No P1 issues, diminishing returns"

**Phase 4: Finalization**
- Box color: Light purple
- Human involvement: Medium
- Agent involvement: High
- Key activity: "Exit criteria check, human sign-off"
- Output: Approved design.md

---

### 3. Outputs (Right Side)

**Primary Deliverable:**
- design.md — prominent, blue, document icon
- Label: "Technical specification"

**Supporting Artifacts (when >500 lines):**
- design-architecture.md
- design-interface.md
- design-data-model.md
- design-capabilities.md
- Show as smaller documents branching from design.md

**Type-Specific Sections (show as badges/tags on design.md):**
- All Types: Summary, Capabilities, Interface & Format, Decision Log, Backlog, **Develop Handoff** (stage transition document)
- App: + Architecture, Tech Stack, Data Model, Security
- Workflow: + Orchestration, Integration Points, Data Flow, Error Handling
- Artifact: + Format Specification, Content Outline, Source Materials

**Develop Handoff Section (required):**
- Small callout box: "Stage transition document"
- Contains: Design summary, key decisions, capabilities needed, open questions, success criteria, implementation guidance
- Purpose: Give Develop everything needed to start without re-reading entire design

Arrow label: "Ready for Develop stage"

---

### 4. Decision Flow (Bottom)

Horizontal bar showing key decisions captured:

```
Brief Interpretation → Technical Preferences → Architecture Choices → Capability Selection → Trade-offs
```

Label: "Decision Log — rationale documented at each step"

---

### 5. Review Prompts (Small Inset, Top Right)

Show prompt files used:
- start-design-prompt.md — Stage transition
- design-intake-prompt.md — Clarification interview
- design-ralph-review-prompt.md — Internal review
- design-external-review-prompt.md — External review

---

### 6. Breakout Threshold (Small Note)

- Label: "500 lines"
- Note: "Single design.md under threshold; split into child docs above"
- Visual: Small ruler/gauge icon

---

## Visual Style

- Clean, minimal, professional
- Color coding:
  - Green for inputs (intent.md, brief.md)
  - Purple/violet for Design stage phases
  - Blue for outputs (design.md)
  - Light blue for supporting artifacts
  - Gray for meta elements (prompts, status)
  - Orange for review loop emphasis
- White or light background
- Clear arrows showing flow direction
- Document icons for artifacts
- Person icons for human involvement indicators

---

## Key Relationships to Show

1. **Brief consumed**: THICK arrow from brief.md INTO Design phase. Label: "Fully consumed — transforms into technical decisions"
2. **Intent referenced**: Thin arrow from intent.md spanning all phases (North Star throughout)
3. **Two-phase review**: Clear visual split between Internal (fast iteration) and External (diverse perspectives)
4. **Type determines output**: Project type badge influences which sections appear in design.md
5. **Develop Handoff**: Small connecting element between Design outputs and arrow to Develop — represents the transition document

---

## Common Mistakes to Avoid

1. **Brief consumption**: Brief is CONSUMED in Design, not just referenced. Show it feeding IN.

2. **Review loop structure**: Internal and External are sequential, not parallel. Internal gets it solid, External catches blind spots.

3. **Output hierarchy**: design.md is primary. Supporting docs are children, only created when >500 lines.

4. **Capability flow**: Capabilities are identified in Design but can be modified in Develop. Show as "recommended" not "final."

---

**Title:** "ADF Design Stage: Brief → Technical Specification"

**Subtitle:** "How will we build this?"
