---
type: "specification"
description: "Defines project types and modifiers at the ADF level"
version: "2.0.0"
updated: "2026-01-27"
scope: "adf"
lifecycle: "reference"
location: "adf/ADF-PROJECT-TYPES-SPEC.md"
---

# ADF Project Types Specification

## Purpose

Define the minimal project classification system that determines scaffolding, tooling, and workflow patterns.

## Design Principle

**Minimal and composable.** Three primary types + modifiers. Specific technologies and frameworks are determined in Discover/Design and captured in the Brief.

---

## Primary Types

### 1. Artifact

**What it produces:** Single deliverable. Done when shipped.

**Examples:**
- Report / analysis
- Presentation / slide deck
- Spreadsheet / workbook
- Specification / documentation
- Design mockup

**Characteristics:**
- Finite scope — clear "done" state
- Produces a file as output
- May use templates
- Consumed by humans (not executed)

**Sub-variations (determined in Design):**
- Format (PDF, PPTX, XLSX, MD)
- Audience (internal, external, technical, executive)
- Tooling (Google Slides, PowerPoint, Excel, etc.)

---

### 2. App

**What it produces:** Deployed software with users. Ongoing.

**Examples:**
- Website / web app
- Mobile app
- API / service
- Desktop application
- Library / package

**Characteristics:**
- Has source code
- Requires build/run environment
- Has users (even if just yourself)
- Typically versioned and deployed
- Ongoing lifecycle (maintenance, updates)

**Sub-variations (determined in Design):**
- Language/runtime (Python, Node, Go, etc.)
- Framework (Next.js, FastAPI, SvelteKit, etc.)
- Deployment target (cloud, local, edge)
- UI paradigm (SSR, SPA, static, hybrid)

---

### 3. Workflow

**What it produces:** Automation/orchestration. May feed into Apps or run standalone.

**Examples:**
- Agentic pipeline
- Automation / integration
- Data pipeline
- Scheduled jobs
- Multi-step process automation

**Characteristics:**
- Orchestrates actions across tools/systems
- May be deterministic or probabilistic (agentic)
- Produces outcomes, not just artifacts
- Often event-driven or scheduled

**Sub-variations (determined in Design):**
- Deterministic (scripted steps) vs. probabilistic (agent reasoning)
- Trigger type (manual, scheduled, event-driven, webhook)
- Integration points (APIs, databases, external systems)
- Orchestration platform (n8n, Temporal, custom, etc.)

---

## Modifiers

Modifiers add context without changing the fundamental type. Apply as relevant.

### Scale Modifiers

| Modifier | Description |
|----------|-------------|
| `personal` | Just you. Private. Low stakes, fast iteration. |
| `shared` | Known users — family, friends, small group. Moderate expectations. |
| `community` | Public access. Not monetized. Open contribution possible. |
| `commercial` | Revenue intent. Business requirements. Support expectations. |

### Scope Modifiers

| Modifier | Description |
|----------|-------------|
| `mvp` | Minimum viable. Ship fast, validate, iterate. |
| `full-build` | Complete implementation per spec. |

### Complexity Modifiers

| Modifier | Description |
|----------|-------------|
| `standalone` | Single component. Self-contained. |
| `multi-component` | Multiple services, apps, or systems working together. |

---

## Classification Syntax

```
{Type} + {scale} + {scope} + {complexity}
```

**Examples:**

| Project | Classification |
|---------|----------------|
| Personal portfolio website | `App + personal + mvp + standalone` |
| Family cooking assistant | `App + shared + mvp + standalone` |
| Enterprise AI risk platform | `App + commercial + full-build + multi-component` |
| Personal automation assistant | `Workflow + personal + mvp + standalone` |
| Quarterly board report | `Artifact + commercial + standalone` |
| Content publishing pipeline | `Workflow + personal + standalone` |
| Knowledge aggregator system | `Workflow + personal + multi-component` |

---

## Type Selection

**When:** Project Init (before Discover begins)

**How:** Human identifies type based on initial concept.

**Core question:** "What kind of thing are we making?"

| If the answer is... | Type is... |
|---------------------|------------|
| "A document or file — done when delivered" | Artifact |
| "Software that runs and has users" | App |
| "A process or automation" | Workflow |

---

## Type Implications

| Aspect | Artifact | App | Workflow |
|--------|----------|-----|----------|
| Folder structure | docs/, assets/ | src/, tests/, config/ | workflows/, scripts/ |
| Primary tools | Office suite, design tools | IDE, build tools, runtime | Orchestration, integration |
| Develop phase | Creating/refining content | Writing/testing code | Building/testing process |
| Deliver phase | Published/shared | Deployed and running | Operational and triggered |
| Done state | Shipped file | Running in production | Executing reliably |

---

## Hybrid Projects

Some projects span types:

- **App + Artifact:** Build an app AND write documentation
- **Workflow + App:** Automation that includes custom UI
- **Artifact + Workflow:** Report generation pipeline

**For hybrids:** Pick the **primary** type for scaffolding. Secondary types inform Design decisions and may warrant sub-projects.

---

## What Type Does NOT Determine

- Specific technologies (captured in Design)
- Success criteria (captured in Brief)
- Timeline or resources (captured in Brief)
- Detailed requirements (captured in Brief)

---

## References

- ADF-BRIEF-SPEC.md (Brief captures type + modifiers)
- ADF-STAGES-SPEC.md (Project Init identifies type)
- ADF-FOLDER-STRUCTURE-SPEC.md (scaffolding varies by type)
