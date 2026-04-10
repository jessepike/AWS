---
type: "prompt"
description: "Prompt for generating full ADF vision architecture diagram"
version: "2.0.0"
updated: "2026-02-02"
lifecycle: "reference"
location: "prompts/architecture-visual-full-vision.md"
---

# Prompt: ADF Full Vision Architecture Diagram

Use this prompt with an image generation tool or diagramming AI to create an architectural visualization of the complete ADF vision.

---

## Prompt

Create a clean, modern software architecture diagram for "ADF — Agentic Development Framework" showing the complete system vision.

**Layout:** Layered architecture, top-to-bottom

---

### 1. Environment Layer (Top)

- Label: "Environment Layer (Six Primitives)"
- Contains six distinct primitives arranged in two rows:
  - **Row 1:** Orchestration | Capabilities | Knowledge
  - **Row 2:** Memory | Maintenance | Validation
- Visual: Horizontal band across top, wraps conceptually around everything below
- Note: "Ambient services — always available"
- Show as small labeled boxes within the layer, not just text

---

### 2. Context Layer — Tier-1 Memory (Below Environment Layer)

Two components side by side:

- **Global CLAUDE.md** (`~/.claude/CLAUDE.md`)
  - Label: "Universal guardrails, always loaded"

- **Project CLAUDE.md** (`.claude/CLAUDE.md`)
  - Label: "Project-specific context"

Box label: "Context Layer (Tier-1 Memory)"

Both feed DOWN into the Stage Workflow.

---

### 3. Intent.md — North Star (Prominent, Overarching)

- **Position:** Above or spanning the ENTIRE Stage Workflow — NOT just feeding into Design
- Visual: Most prominent artifact, use star icon, green color
- Label: "intent.md — North Star"
- **CRITICAL:** Show arrows feeding into Design, Develop, AND Deliver
- Note: "Referenced throughout — especially in Develop where agents do most work"

---

### 4. Brief.md — Scope

- Position: Feeds into Design stage ONLY
- Label: "brief.md — Scope and success criteria"
- Arrow: brief.md → Design (Design then flows to Develop)
- Note: "Influences Develop through Design, not directly"

---

### 5. Stage Workflow (Center)

Four connected stages in sequence:

```
Discover → Design → Develop → Deliver
```

Each stage shows its key question:
- Discover: "What are we trying to accomplish?"
- Design: "How will we build this?"
- Develop: "Are we building it correctly?"
- Deliver: "Is this increment done and usable?"

**Loopback:** Show arrow from Deliver back to Discover. Label: "Increments can loop back"

**IMPORTANT:** The entire workflow produces outcomes. Individual stages do NOT flow directly into specific Project Types.

---

### 6. Outcomes / Deliverables (Below Stage Workflow)

- Label: "Outcomes / Deliverables"
- The ENTIRE Stage Workflow flows into this box
- Inside, show Project Types as variants:
  - Software
  - Artifact
  - Workflow
- Note: "Project Type determines shape of deliverable"

**DO NOT:** Draw arrows from Develop → Software or Deliver → Workflow. The whole cycle produces outcomes.

---

### 7. Artifact Lifecycle (Bottom Left)

Separate section showing lifecycle classes:

- **Deliverable** (`src/`, `output/`, `workflows/`) — "Never auto-prune"
- **Reference** (`docs/`) — "Archive when obsolete"
- **Inbox** (`docs/inbox/`) — "Triage zone, process promptly"
- **Archive** (`_archive/`) — "Preserved but inactive (NOT ephemeral)"

Show flow: Reference → Archive (when obsolete)
Show flow: Inbox → Reference or Delete (after triage)

**IMPORTANT:** Inbox and Archive are SEPARATE concepts with different purposes.

---

### 8. Interface Layer (Right Side)

- Label: "Interface Layer"
- Components shown as small boxes:
  - **ADF MCP Server** — "Read-only spec/prompt/KB access"
  - **adf-env plugin** — "Environment management, health"
  - **.claude/rules/** — "Policy enforcement (human-controlled)"
  - **CLAUDE.md** — "Context and orientation (agent-writable)"
- Connects to: Environment Layer and Stage Workflow
- Note: "How consumers interact with ADF"

---

### 9. Memory Primitive Note (Small Callout)

- Label: "Memory (Planned)"
- Small note: "Session state, cross-agent continuity — planned for future implementation"
- Visual: Dashed box or grayed out within Environment Layer
- This distinguishes Memory as planned vs the five operational primitives

---

### 10. Self-Improvement Loop (Right Side)

- Arrow originates from **Deliver stage** (or the entire Stage Workflow box)
- Flows back UP to Environment Layer
- Label: "Learnings feed back into capabilities"

**CRITICAL:** Arrow must clearly come from Deliver/workflow completion, NOT from Design or Validators.

---

### Folder Structure (Small Inset, Left Side)

```
project/
├── .claude/
│   ├── CLAUDE.md
│   └── rules/
├── docs/
│   ├── intent.md
│   ├── brief.md
│   └── inbox/
├── _archive/
└── [type-specific]/
    ├── src/
    ├── output/
    └── workflows/
```

---

## Visual Style

- Clean, minimal, professional
- Color coding:
  - Blue for stages
  - Green for intent.md and brief.md (use star icons)
  - Light blue for CLAUDE.md files / Context Layer
  - Orange for Validators/Maintenance
  - Gray for Environment Layer
  - Muted tones for Artifact Lifecycle
- White or light background
- Clear arrows showing flow direction
- Document icons for artifacts

---

## Common Mistakes to Avoid

1. **Intent.md scope:** Do NOT show intent only feeding Design. It's the North Star for the ENTIRE workflow, especially Develop and Deliver.

2. **Brief.md path:** Brief feeds Design only. Develop and Deliver reference it for success criteria, not as primary input.

3. **Project Types flow:** Do NOT draw Develop → Software or Deliver → Workflow. The whole workflow produces outcomes; Project Type shapes them.

4. **Self-improvement origin:** Arrow comes from Deliver/workflow completion, NOT from Design or earlier stages.

5. **Environment primitives:** Show all six distinctly (Orchestration, Capabilities, Knowledge, Memory [planned], Maintenance, Validation). Don't merge or omit.

6. **Four stages:** Must show Discover → Design → Develop → Deliver. All four are part of the core pipeline.

7. **Interface layer:** ADF MCP Server, adf-env plugin, rules/, CLAUDE.md are distinct interface mechanisms. Show them separately, not as one "interface" blob.

8. **Memory status:** Mark Memory as "planned" (dashed box or grayed) to distinguish from the five operational primitives.

---

**Title:** "ADF — Agentic Development Framework: Full Architecture"

**Subtitle:** "Managed workflows for agentic software development"
