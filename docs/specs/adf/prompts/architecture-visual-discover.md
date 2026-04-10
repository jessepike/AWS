---
type: "prompt"
description: "Prompt for generating Discover stage architecture diagram"
version: "1.1.0"
updated: "2026-02-02"
lifecycle: "reference"
location: "prompts/architecture-visual-discover.md"
---

# Prompt: ADF Discover Stage Architecture Diagram

Use this prompt with an image generation tool or diagramming AI to create an architectural visualization of the Discover stage.

---

## Prompt

Create a clean, modern software architecture diagram for "ADF — Discover Stage" showing the complete workflow for transforming raw ideas into a validated Brief.

**Layout:** Flow-based, left-to-right primary flow with review loop shown prominently

---

### 1. Title & Context (Top)

- **Title:** "ADF — Discover Stage"
- **Subtitle:** "From raw idea to validated Brief"
- **Stage Question:** "What are we trying to accomplish?"

---

### 2. Inputs (Left Side)

Box labeled "Inputs" containing:

- **Raw Idea** — "Initial concept (may be vague)"
- **Domain Context** — "Background, constraints, prior art"
- **ADF Specs** — "Brief spec, Intent spec, Project Types"

Arrow flows RIGHT into the Phase Workflow.

---

### 3. Phase Workflow (Center — Main Flow)

Four phases in sequence, LEFT to RIGHT:

```
Exploration → Crystallization → Review Loop → Finalization
```

Each phase shows:

**Exploration**
- "Divergent brainstorming"
- "Research, gather, follow threads"
- Human: High | Agent: Low
- Exit: "Enough to crystallize"

**Crystallization**
- "Synthesis into structure"
- "Draft Intent & Brief"
- Human: Low-Med | Agent: High
- Exit: "Draft ready for review"

**Review Loop** (LARGEST — this is the key innovation)
- See detailed breakdown below
- Human: Med | Agent: High
- Exit: "Convergence reached"

**Finalization**
- "Exit criteria check"
- "Human sign-off"
- Human: Med | Agent: High
- Exit: "Ready for Design"

---

### 4. Review Loop Detail (Center — Expanded View)

This is the most important section. Show as an EXPANDED box within the phase flow:

**Two-Phase Model — Side by Side:**

```
┌─────────────────────────────────────────────────────┐
│                  REVIEW LOOP                         │
│  ┌──────────────────┐    ┌──────────────────────┐   │
│  │ PHASE 1:         │    │ PHASE 2:             │   │
│  │ INTERNAL         │ →  │ EXTERNAL             │   │
│  │                  │    │                      │   │
│  │ Ralph Loop       │    │ GPT, Gemini, etc.    │   │
│  │ (Claude)         │    │                      │   │
│  │                  │    │                      │   │
│  │ • Fast iteration │    │ • Diverse views      │   │
│  │ • Handles grind  │    │ • Catches blind spots│   │
│  │ • 2-5 iterations │    │ • 1-2 cycles         │   │
│  └──────────────────┘    └──────────────────────┘   │
│                                                      │
│  PRINCIPLE: "Find real issues, not cosmetic ones"   │
└─────────────────────────────────────────────────────┘
```

**Key callouts:**
- Phase 1 arrow loops back on itself (iteration)
- Phase 1 → Phase 2 arrow (handoff)
- YAGNI principle prominently displayed at bottom of Review Loop box

---

### 5. Outputs (Right Side)

Box labeled "Outputs" containing:

- **intent.md** — "North Star (50-150 words)"
  - Problem, Outcome, Why It Matters
  - Visual: Star icon, GREEN color
  - Note: "Stable, universal, travels everywhere"

- **discover-brief.md** — "Detailed Contract"
  - Scope, Success Criteria, Constraints
  - Visual: Document icon, GREEN color
  - Note: "Evolves through review, stable after"

Arrow shows both outputs flowing to "Design Stage" (off diagram to right).

---

### 6. Exit Criteria Checklist (Bottom Right)

Small box showing key gates:

```
Exit Criteria:
☑ Intent exists (minimal, stable)
☑ Brief complete (all sections)
☑ Success criteria verifiable
☑ No P1 issues open
☑ Human sign-off
```

---

### 7. Supporting Elements (Bottom)

**Issue Log Flow:**
Show small diagram:
```
Review Feedback → Issue Log → Prioritize (P1/P2/P3) → Resolve or Defer
```

**Session Continuity:**
Small note: "status.md tracks progress across sessions"

---

### 8. Context Loading (Small Inset, Left Side)

```
Agent Context:
├── CLAUDE.md (manifest)
├── status.md (session state)
├── intent.md (North Star)
├── discover-brief.md (working doc)
└── ADF specs (reference)
```

---

## Visual Style

- Clean, minimal, professional
- **Color coding:**
  - Blue for phases (Exploration, Crystallization, Finalization)
  - **Orange/Amber for Review Loop** (highlight — this is the key)
  - Green for outputs (intent.md, brief.md)
  - Light blue for inputs and context
  - Gray for supporting elements
- White or light background
- Clear arrows showing flow direction
- Document icons for artifacts
- Loop arrows for iteration

---

## Key Visual Priorities

1. **Review Loop is prominent** — This is the innovation. Make it larger than other phases.

2. **Two-phase model is clear** — Internal (Ralph) and External (GPT/Gemini) are distinct but connected.

3. **YAGNI principle visible** — Call it out in the Review Loop box.

4. **Flow is left-to-right** — Inputs → Phases → Outputs → Design

5. **Intent is minimal** — Show it as small/compact compared to Brief.

---

## Common Mistakes to Avoid

1. **Don't make phases equal size** — Review Loop should be largest/most prominent.

2. **Don't skip the two-phase split** — Internal and External review are distinct mechanisms.

3. **Don't forget YAGNI** — It's a core principle, should be visible.

4. **Don't make Intent complex** — It's deliberately minimal (50-150 words).

5. **Don't show Brief as final** — It evolves through review, note says "stable after."

6. **Don't omit iteration loops** — Ralph Loop iterates (show loop arrow), External may cycle.

---

**Title:** "ADF — Discover Stage"

**Subtitle:** "From raw idea to validated Brief"
