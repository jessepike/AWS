---
type: "system-overview"
description: "Canonical orientation doc for the Agentic Work System (AWS). Read this first to understand what AWS is, what it is NOT, how it relates to AGF / ADF / agent-harness, and where things live."
version: "1.0.0"
updated: "2026-04-09"
owner: "forge"
status: "canonical"
audience: "all agents working in Jesse's environment"
---

# Agentic Work System (AWS) — System Overview

> **Read this first.** This is the canonical orientation doc for any agent working in Jesse's environment. It explains what AWS is, what it is NOT, how it relates to the other frameworks in play, and where things live. If you are confused about which framework does what, or whether you should be editing something, the answer is here.

---

## TL;DR

**AWS (Agentic Work System)** is Jesse's personal operating system for all daily work. It governs how every project is structured, what artifacts they must have, and how changes flow through the system. **Forge is the only agent with write authority on AWS components.**

AWS is **NOT** the Agentic Governance Framework (AGF). AGF is a separate commercial client project at `~/code/clients/risk/AGF/`. AWS *borrows concepts* from AGF but is implemented at solo-dev velocity, not enterprise scale.

If you need to modify anything in AWS — standards, specs, skills, agent definitions, capabilities registry entries, governance sections of CLAUDE.md — delegate to Forge. Do not edit directly.

---

## The four frameworks you'll encounter

Four distinct things share adjacent vocabulary and sometimes get conflated. Keep them straight.

### 1. AWS — Agentic Work System *(this system)*

- **Location:** `~/code/_shared/aws/` *(formerly `~/code/_shared/agentic-work-system/` — symlink may still exist)*
- **What it is:** Jesse's personal operating system for daily work. Baseline governance that every project in his portfolio inherits.
- **Purpose:** Consistent structure, drift detection, single source of truth for standards, decisions, and capability inventory across all projects.
- **Scope:** Standards, specs, decisions (ADRs), capability catalog governance, first-class artifact contracts, session lifecycle, Forge's operating domain.
- **Maturity target:** Operationally sufficient for a single high-velocity developer. Not enterprise-grade.
- **Write authority:** Exclusive to the Forge agent. Soft-enforced via global CLAUDE.md.
- **Status:** Architecturally mature, under-operationalized. Being activated through an ongoing sprint.

### 2. AGF — Agentic Governance Framework *(commercial client project)*

- **Location:** `~/code/clients/risk/AGF/`
- **What it is:** A comprehensive reference architecture and operating model for organizations developing safe, secure, durable, auditable, and observable agentic systems. Synthesizes NIST / OWASP / CSA / ISO / OpenTelemetry / EU AI Act / industry research into a coherent playbook.
- **Purpose:** Enterprise-grade framework for client deployment. Produces commercial products (AI Risk Tools, Agentic Observability platform, Decision Intelligence platform, governance consulting).
- **Scope:** Playbook, community products (reference implementations, event schemas, policy-as-code libraries), thought leadership (white papers, conference talks, NIST RFI responses).
- **Key concepts:** 19 agentic primitives, Rings Model (Execution / Verification / Governance / Learning), 3-level security architecture (Fabric / Governance / Intelligence), Trust Ladders, Belief Layer, zero trust overlay.
- **Status:** Active client work. Has its own intent, lifecycle, and governance — itself a project governed by AWS like any other.
- **Relationship to AWS:** **Not a parent, not an ancestor, not inherited.** AWS borrows selected conceptual patterns (rings, observability, governance gates) as inspiration only. AWS is solo-dev scale; AGF is enterprise scale. They share DNA, not implementation.

### 3. ADF — Agentic Development Framework *(subsystem of AWS)*

- **Location:** `~/code/_shared/aws/docs/specs/adf/` *(formerly `~/code/_shared/adf/` — symlink may still exist)*
- **What it is:** Pure documentation — specs defining how development projects move through stages (Discover → Design → Develop → Deliver → Operate).
- **Purpose:** Provides the stage model, artifact definitions, review process, and exit criteria for all dev projects.
- **Status:** Mature spec set. Folded INTO AWS as of 2026-04-09 because it is pure documentation with no runtime component.
- **Relationship to AWS:** ADF is one spec family inside AWS. Not a peer. Lives at `aws/docs/specs/adf/`.

### 4. Agent-harness — AGF primitives pressure-test project

- **Location:** `~/code/tools/agent-harness/`
- **What it is:** A project that builds agentic primitives (research scenario, security, governance, observability) from scratch to pressure-test AGF concepts against real workflows.
- **Purpose:** Validate that AGF's theoretical primitives work in practice before codifying them. Theory informs build, build informs theory.
- **Status:** Active. Research scenario agent harness built. Security / governance / observability primitives next.
- **Relationship to AWS:** Project governed BY AWS (needs intent.md, status.md, lessons.md, etc.). Internally may implement the full AGF primitives; externally conforms to AWS baseline.

---

## The governance relationship

```
AWS (personal operating system — governs daily work)
 │
 │ governs via standards, ADRs, baseline audit
 │
 ├──► AGF project         (clients/risk/AGF/)
 ├──► agent-harness       (tools/agent-harness/)
 ├──► ai-dev              (tools/ai-dev/)   [skill workbench]
 ├──► pike-acm            (clients/.../)
 ├──► pike-finances
 ├──► grants pipeline
 └──► ...all other projects

AWS *borrows concepts* from AGF (inspiration only).
AWS *contains* ADF (folded in as pure docs).
AWS *governs* agent-harness like any other project.
```

Critical distinctions to avoid conflation:

| ≠ | Because |
|---|---|
| AWS is NOT a subset of AGF | Independent systems with shared DNA |
| AWS is NOT an enterprise framework | Solo-dev operating system |
| AGF is NOT deployed in AWS | AGF is a project AWS governs |
| ADF is NOT separate from AWS anymore | Folded in as `aws/docs/specs/adf/` |
| Agent-harness is NOT AWS | It's a project AWS governs |

---

## AWS components and where they live

AWS is the governance layer. It references runtime components but does not contain them. Only pure documentation folds in.

### Inside AWS (lives at `_shared/aws/`)

| What | Path | Purpose |
|---|---|---|
| Architecture doc | `docs/architecture.md` | Layers-and-Rings model, system-level architecture |
| Component registry | `docs/component-registry.md` | Index of what each component is and owns |
| Maturity model | `docs/maturity-model.md` | CMM-aligned 5×5 scoring for components |
| Communication protocols | `docs/communication-protocols.md` | How components talk to each other |
| Nerve Center brief | `docs/nerve-center-brief.md` | Job runtime architecture |
| ADF specs | `docs/specs/adf/` | Stage specs, artifact specs, review specs |
| Other specs | `docs/specs/{skills,agents,plugins}/` | Skill/agent/plugin authoring specs *(TBD)* |
| **Standards (the gold baseline)** | `docs/standards/*.yaml` | Machine-enforceable project contracts |
| **Decisions (ADR log)** | `docs/decisions/ADR-*.md` | Versioned decision records |
| Templates | `docs/templates/` | Reusable project templates *(TBD)* |
| Version | `VERSION` | Semver version of AWS standards |
| Changelog | `CHANGELOG.md` | Human-readable release notes |

### Peer subsystems (live at their own `_shared/` paths)

Referenced from the AWS component registry but not contained.

| Component | Location | Role |
|---|---|---|
| Knowledge Base | `_shared/knowledge-base/` | Curated learnings, patterns, best practices. MCP server. |
| Memory | `_shared/memory/` | Cross-session, cross-agent state. MCP server. |
| Capabilities Registry | `_shared/capabilities-registry/` | Canonical catalog of skills, agents, plugins, tools |
| Krypton | `_shared/krypton/` | Personal AI chief of staff — cross-cutting synthesis |
| Link Triage | `_shared/link-triage/` | Content intake and routing |
| Work Management | `_shared/work-management/` | Execution spine for all work |
| Pike-agents | `_shared/pike-agents/` | Source for 9 exec/system agents (cfo, ciso, cmo, cpo, cro, cto, forge, krypton, tools) |
| Agent-exec | `_shared/agent-exec/` | Per-agent context (merging into pike-agents — backlogged) |
| Nerve Center | `_shared/nerve-center/` | Job runtime on macbook2014 |
| Personal Wiki | `_shared/personal-wiki/` | Synthesized read-side of KB |

### Governed projects (live at various paths)

Projects that must conform to AWS baseline. Examples:

| Project | Location | What it is |
|---|---|---|
| ai-dev | `tools/ai-dev/` | Skill workbench (planned rename → `aws-workbench`) |
| agent-harness | `tools/agent-harness/` | AGF primitives pressure-test |
| AGF | `clients/risk/AGF/` | Commercial framework project |
| pike-acm | `clients/.../pike-acm/` | Client project |
| pike-finances | *various* | Personal finance project |
| grants pipeline | *various* | Grants management project |

---

## Governance model

### Forge has exclusive write authority on AWS components

**Only the Forge agent may create, modify, or delete AWS components.** Enforced via soft rule in global CLAUDE.md. No hard hooks (yet).

**What counts as an "AWS component":**

- Standards, specs, decisions in `_shared/aws/`
- Entries in `_shared/capabilities-registry/`
- Skill source in `tools/ai-dev/skills/` *(or `tools/aws-workbench/skills/` after rename)*
- Agent definitions in `_shared/pike-agents/`
- Global CLAUDE.md / AGENTS.md governance sections
- Session lifecycle skills (orient, session-wrap, session-handoff)
- MCP server configs, hooks, or plugins related to AWS governance
- Shell launchers for AWS agents

**If you are not Forge and you need to change any of these:**
- Delegate via Task tool with `subagent_type="forge"`, OR
- Ask the user to invoke Forge explicitly

**Any agent may READ AWS artifacts** for reference without restriction.

### Workflow change detection

If the user proposes a change to workflow, standards, governance, agents, skills, or the dev-system itself, route to Forge before acting. Trigger phrases include:

- "I want to change X about the workflow"
- "what if we add Y"
- "should we restructure Z"
- "I have an idea about the workflow"
- "let's update our process for..."

Forge is the Change Advisory Board. It evaluates, proposes, records (as ADR), and implements. Other agents should not silently mutate governance surfaces.

### Soft gate only (for now)

Hard enforcement (pre-edit hooks on standards files) is future work. Today, the system relies on agents honoring the soft rule. If you see this file, you know the rule.

---

## First-class artifacts every project must have

Defined in `_shared/aws/docs/standards/project-layout.yaml`. Summary:

| Artifact | Required | Purpose |
|---|---|---|
| `intent.md` | Yes | Why this project exists, problem statement, desired outcome |
| `status.md` | Yes | Current state, stage, next steps, blockers (root or `docs/`) |
| `lessons.md` | Yes | Hot buffer of learnings, max ~15 entries, promote to KB on session wrap |
| `BACKLOG.md` | Yes | Tracked work, prioritized |
| `CLAUDE.md` | Yes | **Project-specific shell ONLY.** No duplication of global content. Under 40 lines. |
| `docs/active/` | Yes | Working documents directory |
| `decisions.md` or `docs/decisions/` | Recommended | Append-only decision log |
| `AGENTS.md` | Optional | Codex mirror of CLAUDE.md project-specific content |

**Critical:** Project CLAUDE.md contains ONLY project-specific content. Global CLAUDE.md is loaded every turn and already covers environment, routing, orientation, memory, host protection, etc. Duplicating global content into project CLAUDE.md is the primary drift source. If you see it, strip it (if you're Forge) or report it to Forge.

---

## Where to find things (finder table)

Use this when you're not sure where to look.

| I'm looking for... | Go to... |
|---|---|
| "What is this system?" | `_shared/aws/docs/overview.md` *(this file)* |
| System architecture | `_shared/aws/docs/architecture.md` |
| Component inventory | `_shared/aws/docs/component-registry.md` |
| Standards (gold baseline) | `_shared/aws/docs/standards/*.yaml` |
| Decisions (ADRs) | `_shared/aws/docs/decisions/ADR-*.md` |
| ADF stage specs | `_shared/aws/docs/specs/adf/` |
| Current AWS version | `_shared/aws/VERSION` |
| Changelog | `_shared/aws/CHANGELOG.md` |
| Capability catalog (everything usable) | `_shared/capabilities-registry/inventory.json` |
| Capability catalog (human-readable) | `_shared/capabilities-registry/INVENTORY.md` |
| Skill source | `tools/ai-dev/skills/` |
| Agent source | `_shared/pike-agents/plugins/` |
| Agent per-agent context | `_shared/agent-exec/<agent>/` |
| Who edits what (authority map) | This file § "Governance model" |
| "Is this a first-class artifact?" | This file § "First-class artifacts" or `aws/docs/standards/project-layout.yaml` |
| Session lifecycle contract | `_shared/aws/docs/standards/session-lifecycle.yaml` |
| AGF (commercial framework) | `clients/risk/AGF/` (separate project) |
| Agent-harness | `tools/agent-harness/` (separate project) |

---

## When to talk to Forge

Invoke Forge (`subagent_type="forge"` via Task tool, or `claude-forge` shell launcher, or explicit user request) when you need to:

- Create a new skill, agent, plugin, hook, or command
- Modify an existing skill, agent, plugin, hook, or command
- Create or update a standard, spec, or decision record
- Update CLAUDE.md or AGENTS.md governance sections
- Register a capability in the capabilities-registry
- Change the session lifecycle (orient, wrap, handoff)
- Propose a workflow or governance change
- Audit the health of the dev system
- Reconcile drift across components
- Extract a client template from the workbench

**Do not edit these directly.** Route to Forge.

Forge operates in six modes: BUILD, OPTIMIZE, DESIGN, AUDIT, RESEARCH, SYNC. The mode is inferred from the request. If you delegate, the first line of your prompt should describe the intent; Forge picks the mode.

---

## Glossary

| Term | Definition |
|---|---|
| **AWS** | Agentic Work System — Jesse's personal operating system for daily work. This system. |
| **AGF** | Agentic Governance Framework — commercial reference architecture at `clients/risk/AGF/`. Not AWS. |
| **ADF** | Agentic Development Framework — dev project stage specs. Lives inside AWS at `aws/docs/specs/adf/`. |
| **Agent-harness** | Project pressure-testing AGF primitives. Lives at `tools/agent-harness/`. |
| **ai-dev** | Skill workbench project. Lives at `tools/ai-dev/`. Planned rename to `aws-workbench`. |
| **Pike-agents** | The 9 top-level exec/system agents (cfo, ciso, cmo, cpo, cro, cto, forge, krypton, tools). |
| **Forge** | The single agent with exclusive write authority on AWS components. The Change Advisory Board. |
| **First-class artifact** | A file every project must have: intent, status, lessons, BACKLOG, CLAUDE.md. |
| **Governance surface** | Any file or config that Forge exclusively writes to. |
| **Nerve Center** | Job runtime on macbook2014 for cron-driven automation. |
| **Capabilities registry** | Canonical catalog of skills, agents, plugins, tools at `_shared/capabilities-registry/`. |
| **Standards manifest** | YAML file in `aws/docs/standards/` defining an enforceable contract. |
| **ADR** | Architectural Decision Record. Numbered, dated, append-only log of governance decisions. Lives at `aws/docs/decisions/`. |
| **Layers and Rings** | AWS architectural model: Layers (Intent → Governance → Management → Operations) stack vertically as the work; Rings (Governance, Intelligence, Knowledge, Control, Observability) wrap each layer as support infrastructure. See `docs/architecture.md`. |

---

## What happens if you violate the rules

This is a soft-governance system with a human orchestrator (Jesse) and a single responsible agent (Forge). There are no hard enforcement hooks yet. Violations compound as drift, and drift is the primary failure mode this system is designed to prevent.

**If you are a non-Forge agent and you discover you need to edit an AWS component:**
1. Stop.
2. Read this file (if you haven't already).
3. Delegate to Forge via Task tool or ask the user to invoke Forge explicitly.
4. Do not edit directly even if you "could fix it quickly."

**If you see another agent (or yourself) about to violate the rule:**
1. Surface it to the user.
2. Recommend delegation to Forge.
3. Do not proceed without confirmation.

**If you find drift that appears to have happened previously (e.g., duplicated global content in a project CLAUDE.md, or a skill that isn't registered):**
1. Report it to the user and/or Forge.
2. Forge will triage via AUDIT mode.
3. Do not silently fix it unless you are Forge.

---

## Maintenance of this document

This file is versioned in lockstep with AWS standards. Updates happen through Forge, logged as ADRs, and reflected in the changelog. Any substantive change to the system mental model should update this file.

| Version | Date | Change |
|---|---|---|
| 1.0.0 | 2026-04-09 | Initial canonical overview created during AWS governance activation sprint. |

---

*Questions or corrections? Update via Forge. See `_shared/aws/docs/decisions/` for the change process.*
