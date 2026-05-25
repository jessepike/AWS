---
title: Agent Org Charter
status: RATIFIED 2026-05-25 — all 7 open calls closed (Jesse, via Canvas decision-set); Forge implements next
owner: krypton
created: 2026-05-25
supersedes-on-ratification: ad-hoc role understanding in pike-agents/ definitions
related:
  - docs/active/ownership-rubric.md
  - docs/active/per-project-contract-proposal.md
  - docs/active/portfolio-map.md
  - docs/decisions/ADR-004-coordination-model.md
---

# Agent Org Charter

The single defining artifact for **who the agents are, how they relate, and what each may do**.
This doc is the org chart + role descriptions. It is **design/coordination** (Krypton-authored,
AWS-owned). Implementation into actual agent definitions, tool boundaries, and an ADR is
**Forge-owned** — see §7.

> Status: RATIFIED 2026-05-25. The org model + all 7 open calls (§6) were ratified by Jesse via a
> Canvas decision-set. The model is now settled; role/tool boundaries are not *live* until Forge
> encodes them into agent definitions + the ADR (§7).

---

## 1. The core distinction — Manager vs Operator

The organizing primitive. Separating **who decides** from **who does** is both a flow decision
and an AGF control (you can audit a decision apart from the action only if they're separate agents).

| | **Managers / Orchestrators** | **Operators / Workers** |
|---|---|---|
| Count | Few | Many |
| Lifespan | Persistent, stateful | Ephemeral, near-stateless |
| Job | Oversee health · route · resolve · judgment · thought-partner | Execute a well-specified task, then terminate |
| Continuity | Hold context across sessions | Fresh each spawn; direction supplied per task |
| Tools | Read + delegate + coordinate (Read, Grep, Glob, Task, Memory/KB). **Retain** Write/Edit/Bash but **instructed to delegate by default** — soft constraint, monitored (amended 2026-05-25) | Execution tools (Write, Edit, Bash, etc.) |
| Model | Opus/Sonnet (judgment) | Cheapest that fits (Haiku→Sonnet) |
| Entry point? | **Yes** — Jesse/Krypton talk to managers | No — spawned by a manager |

**Flow preserved:** Jesse still "calls up the CTO." The CTO is still his thought partner and
oversees the build. What changes: after the conversation, the CTO **spawns an operator** (Codex
or an ephemeral Claude implementer) with a spec and reviews the result — it does not implement in
its own context. Same shape Krypton already is.

**Tool boundary = SOFT constraint (amended 2026-05-25, Jesse).** Managers **keep** their execution
tools and are *instructed* to delegate by default; this is **monitored**, not enforced by tool-removal.
Hard tool-stripping (Phase 2b) is **contingent** — done only if monitoring shows managers
over-implementing — *not* the default endpoint. The trivial-change carve-out below works precisely
because tools are retained. (Resolves the contradiction: you can't both strip Write/Edit and allow a
≤15-line direct edit.)

**Trivial-change carve-out (ratified):** a manager may make a direct edit only if it is **≤15 lines,
a single existing file, no new files/deps/schema, fully reversible, and within its own domain.**
Anything larger → spawn an operator. Flagged as *monitored* — revisit if managers lean on it.

---

## 2. The org chart

```
Jesse — Principal (owner, P&L, final authority)
  │
  └── Krypton — Chief of Staff / Continuity
        (holds the whole picture · single point of contact for status · routes · never executes)
        │
        ├── MANAGERS / ORCHESTRATORS  (persistent · judgment + routing · delegate execution)
        │     ├── CTO    — technical architecture & infra direction
        │     ├── Forge  — dev-system owner  (special case — see §4)
        │     ├── CFO · CPO · CRO · CISO · CMO — domain executives (portfolio advisory/oversight)
        │
        ├── FUNCTIONAL OWNERS  (cross-cutting · health/route/resolve over a function, not a project)
        │     ├── wm-agent  — OWNS the WM spine (deterministic runtime + latent owner face)
        │     ├── jobs-agent — OWNS all scheduled jobs (health · route · resolve)
        │     └── Nerve Center — observability/control PRODUCT that jobs-agent operates through
        │
        └── OPERATORS / WORKERS  (ephemeral · execution · spec-driven · no continuity)
              ├── Codex (GPT Pro) — primary implementer
              ├── ephemeral Claude implementers (Task-spawned)
              ├── Krypton gatherers (kb · memory · adf · wm) — read-only
              └── Explore · Plan · general-purpose
```

---

## 3. Manager role cards

Each card: **Remit** (domain) · **JTBD** (the few things) · **Oversees** · **Constraints**.
Tool posture is the §1 manager default unless noted; exact arrays are Forge's to set.

### Krypton — Chief of Staff / Continuity
- **Remit:** cross-system intelligence + continuity across all sessions. The altitude layer.
  **Owns the knowledge substrate** — personal-context, Knowledge Base, Memory (decision 1).
- **JTBD:** (1) hold the whole picture so no workstream dies of neglect; (2) be Jesse's single
  point of contact for "what's the status"; (3) route work to the right owner; (4) resolve +
  push next action + write it down so it recurs.
- **Oversees:** the portfolio map, owner index, freshness cadence (PMO *function*).
- **Constraints:** never executes (no code, no project-file edits — routes to owners). Writes only
  its own state file + AWS coordination/design docs + KB-on-approval.

### CTO — Technical Architecture & Compute Infra
- **Remit:** product/technical architecture; system design; integration coherence; **compute/runtime
  infrastructure** — hosts, environments, MCP-server ops, networking (decision 1). *Knowledge*
  substrate is Krypton's, not CTO's.
- **JTBD:** thought-partner Jesse on builds · set architecture · oversee implementation · review.
- **Oversees:** architecture decisions, compute infra. (Does **not** own every project.)
- **Constraints (amended — pure orchestrator, soft):** retains tools but is **instructed to delegate
  by default** (soft constraint, monitored — *not* tool-stripped). The instruction + monitoring is the
  guardrail; hard tool-removal is contingent. **No separate Architect agent** — architecture *thinking*
  is the CTO's job; *building* goes to operators. Revisit an Architect-operator only if build volume demands it.

### Forge — Dev-System Owner *(peer to CTO)*
- **Remit:** the dev system (skills, agents, standards, ADRs, hooks, configs, registry).
- **JTBD:** build/maintain the toolchain all other agents run on.
- **Position (ratified — decision 4):** Forge is a **peer to CTO**, owning the dev-system end-to-end —
  *not* subordinated under CTO. It resolves the blur the same way every manager does: orchestrate,
  and **spawn Codex/operators for heavy implementation.** CTO owns product/technical architecture;
  Forge owns the toolchain.

### CFO · CPO · CRO · CISO · CMO — Domain Executives
- **Remit:** portfolio-level finance / product / revenue / security / marketing.
- **JTBD:** advise + oversee + audit within domain; surface risks; produce strategy artifacts.
- **Constraints:** manager posture; spawn operators for heavy analysis/build.

---

## 4. Functional owners

Cross-cutting concerns that span projects get **one** owner whose job is keep-it-healthy +
route/resolve on failure (Jesse's "one agent owns all the jobs" pattern).

| Function | Owner | Status |
|---|---|---|
| **WM spine** — task routing / prioritization | **wm-agent** | exists. Owns the spine (decision 2). Has a deterministic runtime face + a **latent owner face** (answers status, makes judgment calls). Krypton has stood in as that face; formalize into wm-agent. |
| **All scheduled jobs** — health · route · resolve | **jobs-agent** | **NEW — Forge builds** (decision 3). Fires up, verifies job health, routes/resolves failures. |
| Observability / control surface | **Nerve Center** (product, not agent) | exists. The product `jobs-agent` operates *through* (decision 3). Forge-maintained. |

---

## 5. Ownership model (continuity)

- Each **project and each critical function** has exactly **one accountable owner** — the single
  point of contact Krypton queries. Continuous **design → operate**.
- **Phase changes contributors, not the owner.** A security pass pulls in CISO; the accountable
  owner is unchanged. (This corrects the earlier "phase-aware ownership swaps the owner" model.)
- Optional **re-evaluation at Operate** — a project *may* transfer to a steady-state owner only if
  steady-state needs genuinely differ. Continuity is the default.
- **Two entry points per project** (the latent/deterministic split):
  - **Artifact** (`AGENTS.md`/`CLAUDE.md`) = cached snapshot — static context, fast read.
  - **Owner agent** = live brain — "what's really going on." Krypton reads the artifact for
    context, asks the owner for live judgment.
- Detailed assignments + scoring rubric: `ownership-rubric.md`. Per-project contract (R1–R10,
  frontmatter owner, resolver, freshness): `per-project-contract-proposal.md`.

---

## 6. Resolved calls (ratified 2026-05-25 — Jesse, via Canvas decision-set)

All settled at Krypton's recommendation. Decision IDs referenced from the role cards above.

1. **Infrastructure splits in two.** Krypton owns the **knowledge substrate** (personal-context,
   KB, Memory); CTO owns **compute/runtime infra** (hosts, environments, MCP-server ops, networking).
2. **wm-agent owns the WM spine** — with a deterministic runtime face + a latent owner face.
3. **Create `jobs-agent`** as the functional owner of all scheduled jobs; **Nerve Center is the
   observability/control *product*** it operates through (agent ≠ product).
4. **Forge is a peer to CTO**, owning the dev-system end-to-end; delegates heavy implementation to
   operators. Not subordinated under CTO.
5. **CTO is a pure orchestrator** — *instructed* to delegate by default (soft constraint, monitored).
   Tools are **retained**, not stripped; hard tool-removal is contingent on monitoring. No separate
   Architect agent for now.
6. **Trivial-change threshold:** ≤15 lines / single existing file / no new artifacts / reversible /
   own-domain = direct edit OK; else delegate. *Monitored.*
7. **Krypton owns this charter** (design/map = coordination); Forge owns what it encodes (agent
   definitions, the ADR, `project-layout.yaml`).

### Still open (downstream, not blocking)
- **Where each functional-owner agent is *defined*:** canonical definition lives in
  `pike-agents/<agent>/` (Forge-owned); this charter is the org *map* that indexes them (decision
  from comment 3). Forge creates the `jobs-agent` definition + formalizes wm-agent's latent face.

---

## 7. Ownership boundary for this doc

- **AWS-owned (Krypton may author/edit):** this charter, the org model, assignments, open calls.
- **Forge-owned (implementation):** the ratifying **ADR**; folding role/tool boundaries into agent
  definitions in `pike-agents/`; `project-layout.yaml` v1.2.0; enforcement wiring.
- Ratification path: ✅ Jesse approved the model (2026-05-25) → **next: Forge ADRs it → Forge
  updates agent definitions (phased tool boundaries) + creates `jobs-agent` → encodes
  `project-layout.yaml` v1.2.0 → pilot on 2–3 projects.**
