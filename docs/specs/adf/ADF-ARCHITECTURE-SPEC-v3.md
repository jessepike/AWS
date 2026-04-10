---
type: "specification"
description: "Master framework specification — ADF's two-layer architecture, skills-first model, multi-runtime support, and spec index"
version: "3.0.0"
updated: "2026-03-23"
scope: "adf"
lifecycle: "active"
supersedes: "ADF-ARCHITECTURE-SPEC v2.2.0"
---

# ADF Architecture Specification v3.0

ADF (Agentic Development Framework) is a two-layer system for building intelligent project workflows. It separates project execution (stages) from ambient runtime primitives (environment), enabling progressive disclosure, loose coupling, and multi-model support.

## Two-Layer Model

ADF operates on two independent but coordinated layers:

### Layer 1: Project Layer (Stages)
Governs how work flows through a project lifecycle. Stages are sequential, explicit, and artifact-driven.

### Layer 2: Environment Layer (Ambient Primitives)
Provides persistent capabilities and governance infrastructure independent of any single project. These primitives are always-available or on-demand, self-maintaining, and cross-project.

```
┌─────────────────────────────────────────────────────────────────┐
│ PROJECT LAYER                                                   │
│ ┌──────┬──────┬─────────┬─────────┬─────────┬────────┐        │
│ │Disc  │ Design│ Develop │ Deliver │ Operate │ Learn  │        │
│ │over  │      │         │         │         │        │        │
│ └──────┴──────┴─────────┴─────────┴─────────┴────────┘        │
│ (Sequential, explicit, artifact-driven)                         │
├─────────────────────────────────────────────────────────────────┤
│ ENVIRONMENT LAYER (Ambient Primitives)                          │
│ ┌──────────────────────────────────────────────────────────────┐│
│ │ Always-On    │ On-Demand    │ Governance │ Integration      ││
│ │ - MD Mgmt    │ - Skills     │ - Rules    │ - MCP servers    ││
│ │ - Commit Cmd │ - Libraries  │ - Context  │ - External APIs  ││
│ └──────────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────────┘
```

---

## Project Layer: Stages

Work progresses through six sequential stages, each with defined inputs, outputs, and transitions:

| Stage | Purpose | Owner | Artifacts |
|-------|---------|-------|-----------|
| **Discover** | Understand problem, scope, constraints | User/Agent | Brief, Scope, Research |
| **Design** | Plan solution, architecture, approach | User/Agent + Claude | Design Doc, Plan, Specs |
| **Develop** | Implement, test, refine | User/Agent + Codex | Code, Tests, PRs |
| **Deliver** | Release, document, hand off | User/Agent + Gemini | Release Notes, Docs |
| **Operate** | Monitor, maintain, troubleshoot | User/Agent + Skills | Logs, Runbooks, Alerts |
| **Learn** | Analyze, improve, feedback | Claude/Agent | Analysis, Improvements |

Each stage produces **intent.md** at the project root — an immutable, first-class artifact governing that stage's work.

---

## Environment Layer: Ambient Primitives

Six categories of infrastructure supporting all stages and projects:

### 1. **Skills** (On-Demand Capabilities)
A library of executable task modules, spun up by projects or operators as needed. Skills encapsulate specific workflows (commit, code-review, deploy, etc.). No always-on skill overhead; dependencies declared in skill metadata.

### 2. **Environment Management**
Persistent runtime state, configuration, and infrastructure:
- Local development environments (containers, VMs, packages)
- CI/CD pipelines
- Logging, monitoring, alerting
- Secrets, credentials, API keys

### 3. **Governance Rules**
Policies in `.claude/rules/` applied by all agents and contexts:
- Linting, formatting, validation rules
- Security policies (secrets scanning, access control)
- Approval gates, sign-off requirements
- Audit and compliance rules

### 4. **Context & Instructions**
Shared instruction sources for agent behavior:
- **AGENTS.md** – Shared agent identity, capabilities, constraints
- **CLAUDE.md** – Global Claude agent rules; imports `@AGENTS.md`
- **Project CLAUDE.md** – Project-specific Claude overrides
- Context map in CLAUDE.md enables progressive disclosure

### 5. **Multi-Runtime Support**
Coordinates work across multiple LLM providers:
- **Claude** – Planning, architecture, review, governance decisions
- **Codex** – Implementation, code generation, refactoring
- **Gemini** – Validation, edge-case testing, adversarial review
- See **ADF-MULTI-RUNTIME-SPEC** for task distribution and handoff

### 6. **Integration Layer**
External connection points (spun up on-demand by skills):
- MCP servers (filesystem, git, web, etc.)
- APIs, webhooks, event streams
- Third-party SaaS tools
- No always-on server overhead

---

## Skills-First Architecture

ADF prioritizes minimal always-on overhead with on-demand capability loading:

### Always-On (Bootstrapped at Startup)
- **claude-md-management** – Reads/applies CLAUDE.md context
- **commit-commands** – Local git operations

### On-Demand (Loaded by Projects/Users)
- Code review, testing, deployment, documentation
- External integrations (Slack, GitHub, Jira)
- Data analysis, visualization, reporting
- Custom domain-specific capabilities

Skills declare dependencies in metadata; missing dependencies fail gracefully with clear guidance.

---

## Governance Model

### Rules (Policies)
Stored in `.claude/rules/` and applied automatically:
- Formatting, linting, security scanning
- Sign-off requirements, approval gates
- Compliance and audit rules

### Context (Instructions)
Stored as markdown and imported by agents:
- AGENTS.md → shared identity and constraints
- CLAUDE.md → Claude-specific rules (imports @AGENTS.md)
- Project CLAUDE.md → project-specific overrides

Separation ensures **rules** are machine-enforced (CI/CD), while **context** guides agent behavior during reasoning.

---

## Design Principles

1. **Modular** – Stages, skills, and primitives are independently replaceable
2. **Loosely Coupled** – Stages exchange intent.md; primitives expose clear interfaces
3. **Self-Maintaining** – Environment Management tracks its own health; obsolete skills can be retired
4. **Progressive Disclosure** – CLAUDE.md context map reveals only relevant instructions to each agent role
5. **Multi-Model Native** – Work distributes across Claude, Codex, Gemini per task type and phase
6. **Audit Trail** – All decisions, rules, and context are versioned and queryable

---

## Coupling Rules

- **Stages** depend on **intent.md** (loose); projects can skip stages but must produce intent for completed work
- **Skills** import from **AGENTS.md** and **CLAUDE.md** (explicit context); missing context fails with guidance
- **Projects** import from **project CLAUDE.md** and **project .claude/rules/** (override environment defaults)
- **Multi-runtime** distribution defined in **ADF-MULTI-RUNTIME-SPEC**; handoff points are **stage transitions** and **code review**

---

## ADF Specification Index (21 Specs)

**Core Architecture**
1. [ADF-ARCHITECTURE-SPEC](ADF-ARCHITECTURE-SPEC-v3.md) — This doc; two-layer model, skills-first, governance
2. [ADF-MULTI-RUNTIME-SPEC](ADF-MULTI-RUNTIME-SPEC.md) — Claude (planning) → Codex (implementation) → Gemini (validation)
3. [ADF-ENVIRONMENT-SPEC](ADF-ENVIRONMENT-SPEC.md) — Environment Management: configs, containers, CI/CD, secrets

**Stages & Workflow**
4. [ADF-STAGES-SPEC](ADF-STAGES-SPEC.md) — Overview of all five stages, transitions, intent.md contract
5. [ADF-DISCOVER-SPEC](ADF-DISCOVER-SPEC.md) — Discover stage: scoping, research, Brief production
6. [ADF-DESIGN-SPEC](ADF-DESIGN-SPEC.md) — Design stage: architecture, planning, review
7. [ADF-DEVELOP-SPEC](ADF-DEVELOP-SPEC.md) — Develop stage: implementation, testing, PR flow
8. [ADF-DELIVER-SPEC](ADF-DELIVER-SPEC.md) — Deliver stage: release, documentation, handoff
9. [ADF-OPERATE-SPEC](ADF-OPERATE-SPEC.md) — Operate stage: monitoring, feedback loop, cycle decisions
10. [ADF-REVIEW-SPEC](ADF-REVIEW-SPEC.md) — Code and design review workflows, multi-model validation

**Projects & Tasks**
11. [ADF-PROJECT-TYPES-SPEC](ADF-PROJECT-TYPES-SPEC.md) — Project templates (Feature, Bug, Refactor, Research, etc.)
12. [ADF-TASK-LIFECYCLE-SPEC](ADF-TASK-LIFECYCLE-SPEC.md) — Task creation, assignment, status tracking, rollup [NEW]
13. [ADF-PLANNING-SPEC](ADF-PLANNING-SPEC.md) — OKRs, roadmaps, capacity planning, forecasting

**Artifacts & Context**
14. [ADF-INTENT-SPEC](ADF-INTENT-SPEC.md) — intent.md: immutable first-class artifact at project root
15. [ADF-BRIEF-SPEC](ADF-BRIEF-SPEC.md) — Brief: structured discovery output
16. [ADF-STATUS-SPEC](ADF-STATUS-SPEC.md) — Status: stage-aware project health snapshots
17. [ADF-CONTEXT-ARTIFACT-SPEC](ADF-CONTEXT-ARTIFACT-SPEC.md) — Shared context patterns (AGENTS.md, CLAUDE.md)

**Governance & Configuration**
18. [ADF-GLOBAL-CLAUDE-MD-SPEC](ADF-GLOBAL-CLAUDE-MD-SPEC.md) — Global CLAUDE.md: context map, agent roles, imports
19. [ADF-PROJECT-CLAUDE-MD-SPEC](ADF-PROJECT-CLAUDE-MD-SPEC.md) — Project CLAUDE.md: overrides, custom context
20. [ADF-RULES-SPEC](ADF-RULES-SPEC.md) — .claude/rules/: linting, security, compliance policies
21. [ADF-FOLDER-STRUCTURE-SPEC](ADF-FOLDER-STRUCTURE-SPEC.md) — Directory layout, naming conventions, file organization

---

## Entry Points for Different Audiences

- **Project Leads** → Start with [ADF-STAGES-SPEC](ADF-STAGES-SPEC.md), then [ADF-INTENT-SPEC](ADF-INTENT-SPEC.md)
- **Developers** → [ADF-DEVELOP-SPEC](ADF-DEVELOP-SPEC.md), [ADF-PROJECT-CLAUDE-MD-SPEC](ADF-PROJECT-CLAUDE-MD-SPEC.md)
- **Operators/DevOps** → [ADF-ENVIRONMENT-SPEC](ADF-ENVIRONMENT-SPEC.md), [ADF-OPERATE-SPEC](ADF-OPERATE-SPEC.md)
- **AI/Agent Engineers** → [ADF-MULTI-RUNTIME-SPEC](ADF-MULTI-RUNTIME-SPEC.md), [ADF-GLOBAL-CLAUDE-MD-SPEC](ADF-GLOBAL-CLAUDE-MD-SPEC.md)
- **Governance/Compliance** → [ADF-RULES-SPEC](ADF-RULES-SPEC.md), [ADF-CONTEXT-ARTIFACT-SPEC](ADF-CONTEXT-ARTIFACT-SPEC.md)

---

## See Also

- **[ADF-REBUILD-ROADMAP](ADF-REBUILD-ROADMAP.md)** – Phased implementation plan (Phase 0–5)
- **[FOLDER-STRUCTURE-SPEC](ADF-FOLDER-STRUCTURE-SPEC-v2.md)** – Disk layout, naming conventions
- **[Global CLAUDE.md](../../CLAUDE.md)** – Live agent context (imports @AGENTS.md)
