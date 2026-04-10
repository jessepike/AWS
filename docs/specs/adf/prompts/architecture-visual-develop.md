---
type: "prompt"
description: "Prompt for generating Develop stage architecture diagram"
version: "1.0.0"
updated: "2026-02-02"
scope: "develop"
lifecycle: "reference"
location: "prompts/architecture-visual-develop.md"
---

# Prompt: Develop Stage Architecture Diagram

Use this prompt with an image generation tool or diagramming AI to create an architectural visualization of the ADF Develop stage.

---

## Prompt

Create a clean, modern architecture diagram for "ADF Develop Stage" showing the eight-phase workflow with clear PLANNING → REVIEW + HARD GATE → EXECUTION structure.

**Layout:** Left-to-right flow with three distinct sections (Planning, Review/Gate, Execution)

---

### 1. Title & Context (Top)

- **Title:** "ADF — Develop Stage"
- **Subtitle:** "From design to working deliverable"
- **Stage Question:** "Are we building it correctly?"

---

### 2. Inputs (Left Side)

Box labeled "Inputs from Design" containing:

- **design.md** (primary) — "Technical specification (consumed)"
- **Supporting design docs** — "architecture.md, data-model.md (if >500 lines)"
- **intent.md** — "North Star (referenced)"
- **discover-brief.md** — "Success criteria (referenced)"

Arrow flows RIGHT into Phase 1.

---

### 3. Phase Workflow (Center — Three Major Sections)

**VISUAL STRUCTURE:** Three distinct colored regions:

#### Section 1: PLANNING PHASES (Phases 1-3) — Light Blue

```
Phase 1: Intake & Validation
    ↓
Phase 2: Capability Assessment
    ↓
Phase 3: Planning
```

**Phase 1: Intake & Validation**
- Human: Med | Agent: High
- Key: "Clarify design, close loose ends"
- Output: Understanding confirmed

**Phase 2: Capability Assessment**
- Human: Low | Agent: High
- Key: "manifest.md (dependencies) + capabilities.md (skills/tools)"
- Output: What's needed to build
- Note: "Registry query mandatory"

**Phase 3: Planning**
- Human: Low-Med | Agent: High
- Key: "plan.md (approach + testing strategy) + tasks.md (atomic tasks)"
- Output: How to build it
- Note: "Testing strategy required"

#### Section 2: REVIEW + HARD GATE (Phase 4) — Orange/Amber

```
┌─────────────────────────────────────────────────────┐
│              PHASE 4: REVIEW LOOP & APPROVAL        │
│                                                     │
│  ┌────────────────┐      ┌──────────────────────┐  │
│  │ INTERNAL       │  →   │ EXTERNAL (Optional)  │  │
│  │ Ralph Loop     │      │ GPT, Gemini          │  │
│  │ 2-4 iterations │      │ 1-2 cycles           │  │
│  └────────────────┘      └──────────────────────┘  │
│                                                     │
│          ↓ No Critical/High issues                  │
│                                                     │
│  ┌─────────────────────────────────────────────┐   │
│  │         HARD GATE                            │   │
│  │  Human approves ALL planning artifacts       │   │
│  │  (manifest, capabilities, plan, tasks)       │   │
│  └─────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────┘
```

**CRITICAL:** This is a combined review + approval phase. Agents review thoroughly, THEN present to human for approval. Nothing executes until human approves.

#### Section 3: EXECUTION PHASES (Phases 5-8) — Green

```
Phase 5: Environment Setup
    ↓
Phase 6: Build (with parallel sub-agents)
    ↓
Phase 7: Documentation
    ↓
Phase 8: Closeout
```

**Phase 5: Environment Setup**
- Human: Low | Agent: High
- Key: "Install dependencies, configure capabilities"
- Output: Ready environment

**Phase 6: Build** (LARGEST PHASE — emphasize visually)
- Human: Low | Agent: High
- Key: "TDD approach, task execution, 95%+ automated tests, build-to-design verification"
- Visual: Show parallel sub-agent paths merging back
- Output: Working deliverable + tests
- Note: "Two-tier testing: Automated + Browser"

**Phase 7: Documentation**
- Human: None | Agent: High
- Key: "README, API docs, usage guides"
- Output: Documentation

**Phase 8: Closeout**
- Human: Low | Agent: High
- Key: "Cleanup, success criteria gate, archive planning artifacts, THE SEAL (status.md)"
- Output: Stage complete

---

### 4. Phase Boundary Protocol (Right Side)

Small callout box showing the context clearing mechanism:

```
Phase Boundary:
1. Update Handoff in tasks.md
2. Update status.md
3. Commit (mandatory)
4. Update current_phase
5. Move completed tasks
6. /clear
7. Re-read artifacts
8. Confirm understanding
```

Label: "Context clearing prevents drift"

---

### 5. Artifacts Created (Bottom)

**Sequential artifact creation:**

```
manifest.md → capabilities.md → plan.md → tasks.md → deliverable → docs
```

Show as timeline or sequential flow.

**Artifact lifecycle note:**
- Keep: intent.md, brief.md, design.md, deliverable, tests, docs
- Archive: plan.md, tasks.md, manifest.md, capabilities.md

---

### 6. Testing Strategy Callout (Bottom Right)

**Two-Tier Testing Model:**

```
┌─────────────────────────────────────┐
│  TIER 1: Automated (During Build)  │
│  • Unit tests                       │
│  • Integration tests                │
│  • E2E tests                        │
│  • 95%+ pass rate minimum          │
└─────────────────────────────────────┘
              ↓
┌─────────────────────────────────────┐
│  TIER 2: Real-world (After Tier 1)  │
│  • browser automation tool (runtime-specific, e.g., Claude in Chrome) (Apps)          │
│  • MCP Inspector (MCP servers)      │
│  • Human validation                 │
└─────────────────────────────────────┘
```

---

### 7. Outputs (Right Side)

Box labeled "Outputs" containing:

- **The deliverable** — "Code, artifact, or workflow (working + tested)"
- **Documentation** — "README, API docs, usage guides"
- **Test results** — "95%+ automated tests passing"
- **Archived planning artifacts** — "plan.md, tasks.md, manifest.md, capabilities.md → docs/adf/archive/"

Arrow shows flow to "Deliver Stage" (off diagram to right).

---

### 8. Exit Criteria Checklist (Bottom Right)

Small box showing key gates:

```
Exit Criteria:
☑ Deliverable exists and works
☑ 95%+ automated tests pass
☑ Build-to-design verification complete
☑ Documentation exists
☑ Success criteria mapped to evidence
☑ No uncommitted changes
☑ status.md sealed (THE SEAL)
☑ Human sign-off
```

---

## Visual Style

- Clean, minimal, professional
- **Color coding:**
  - **Light blue** for Planning section (Phases 1-3)
  - **Orange/amber** for Review + HARD GATE (Phase 4) — this is the critical decision point
  - **Green** for Execution section (Phases 5-8)
  - Purple/violet for inputs (design.md)
  - Gray for supporting elements
- **Phase 6 (Build) should be visually larger** — it's where most work happens
- **Phase 4 (HARD GATE) should be prominent** — it's the approval checkpoint
- White or light background
- Clear arrows showing flow direction
- Document icons for artifacts
- Show parallel execution in Phase 6 (sub-agents)

---

## Key Visual Priorities

1. **Three-section structure is clear** — Planning → Review/Gate → Execution are visually distinct regions

2. **HARD GATE is prominent** — Phase 4 is the approval checkpoint; nothing executes without human approval

3. **Sequential artifact creation** — manifest → capabilities → plan → tasks → deliverable → docs flows left to right

4. **Phase boundary protocol** — Context clearing mechanism is visible but not overwhelming

5. **Two-tier testing** — Automated (during build) then Real-world (browser/inspector) is clear

6. **Phase 6 is largest** — Build phase is where most work happens, make it visually prominent

7. **Sub-agent parallelization** — Show multiple paths in Phase 6 that merge back

---

## Common Mistakes to Avoid

1. **Don't make all phases equal size** — Phase 6 (Build) should be largest, Phase 4 (HARD GATE) should be prominent

2. **Don't skip the HARD GATE** — Phase 4 is a combined review + approval. Human approval is mandatory before execution

3. **Don't show execution before approval** — Phases 5-8 CANNOT start until Phase 4 HARD GATE is complete

4. **Don't forget sequential artifacts** — manifest → capabilities → plan → tasks. Order matters.

5. **Don't omit testing tiers** — Two-tier testing (Automated + Real-world) is core to the model

6. **Don't forget phase boundaries** — Context clearing is the mechanism that prevents drift

7. **Don't show design.md as output** — Design is INPUT (consumed), not output. Only update if gaps found.

8. **Don't forget THE SEAL** — status.md seal is the LAST step in Closeout (Phase 8)

---

**Title:** "ADF — Develop Stage"

**Subtitle:** "From design to working deliverable"
