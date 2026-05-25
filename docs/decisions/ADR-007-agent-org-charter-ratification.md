---
adr: 007
title: Agent Org Charter Ratification — Manager/Operator Model, Functional Owners, Per-Project Contract
date: 2026-05-25
status: accepted
owner: Forge
supersedes: []
related: [ADR-002, ADR-004]
ratifies:
  - docs/active/agent-org-charter.md
  - docs/active/per-project-contract-proposal.md
---

# ADR-007: Agent Org Charter Ratification

## Context

AWS runs a multi-agent team (Krypton at altitude; CTO/Forge and the domain
executives below; operators at the leaf). Until now the org structure was
**ad-hoc role understanding encoded implicitly in `pike-agents/` definitions** —
no single artifact answered *who the agents are, how they relate, and what each
may do*. Two design docs converged on an answer and were ratified by Jesse on
2026-05-25 via a Canvas decision-set:

- `docs/active/agent-org-charter.md` (Krypton-authored, **RATIFIED 2026-05-25**) —
  the org chart + role cards + 7 resolved calls (§6).
- `docs/active/per-project-contract-proposal.md` — the per-project contract
  (R1–R10), with R2 (the canonical-context-file question) decided in this round.

This ADR is the **durable rationale of record** for both. Per the Forge-owned
implementation boundary (charter §7), the charter/contract are *design*
(AWS-owned, Krypton may edit); the ADR + the agent-definition encoding +
`project-layout.yaml` v1.2.0 are *implementation* (Forge-owned). The model is
settled; the role/tool boundaries become **live** only as Forge encodes them.
This ADR records the decisions and scopes the encoding into phases.

## Decision

### A. The core distinction — Manager vs Operator

The organizing primitive: separate **who decides** from **who does**. This is
both a flow decision and an AGF control — a decision is auditable apart from the
action only if they are separate agents.

| | **Managers / Orchestrators** | **Operators / Workers** |
|---|---|---|
| Count | Few | Many |
| Lifespan | Persistent, stateful | Ephemeral, near-stateless |
| Job | Oversee health · route · resolve · judgment · thought-partner | Execute a well-specified task, then terminate |
| Continuity | Hold context across sessions | Fresh each spawn; direction supplied per task |
| Tools (target) | Read + delegate + coordinate (Read, Grep, Glob, Task, Memory/KB). **No** Write/Edit/Bash-mutation | Execution tools (Write, Edit, Bash, etc.) |
| Model | Opus/Sonnet (judgment) | Cheapest that fits (Haiku→Sonnet) |
| Entry point | **Yes** — Jesse/Krypton talk to managers | No — spawned by a manager |

**Flow preserved:** Jesse still "calls up the CTO." After the conversation the
manager **spawns an operator** (Codex or an ephemeral Claude implementer) with a
spec and reviews the result — it does not implement in its own context. Same
shape Krypton already is.

**Phasing (important — see §Consequences):** default-to-delegate first; harden to
actual tool-removal from managers only once the spawn path is proven. **This ADR
does NOT strip tools from any existing agent** (that is Phase 2).

**Trivial-change carve-out (ratified):** a manager may make a direct edit only if
it is **≤15 lines, a single existing file, no new files/deps/schema, fully
reversible, and within its own domain.** Anything larger → spawn an operator.
Flagged *monitored* — revisit if managers lean on it.

### B. The seven ratified org decisions (charter §6)

1. **Infrastructure splits in two.** Krypton owns the **knowledge substrate**
   (personal-context, Knowledge Base, Memory); CTO owns **compute/runtime infra**
   (hosts, environments, MCP-server ops, networking).
2. **wm-agent owns the WM spine** — with a deterministic runtime face **and** a
   latent owner face (answers status, makes judgment calls). Krypton has stood in
   as that face; it is formalized into wm-agent (see §D, encoded this ADR).
3. **Create `jobs-agent`** as the functional owner of all scheduled jobs (fires
   up, verifies job health, routes/resolves failures). **Nerve Center is the
   observability/control *product*** it operates through — agent ≠ product.
   (Created this ADR — see §D.)
4. **Forge is a peer to CTO**, owning the dev-system end-to-end; delegates heavy
   implementation to operators. **Not** subordinated under CTO. CTO owns
   product/technical architecture; Forge owns the toolchain.
5. **CTO is a pure orchestrator** — no direct implementation tools in the target
   state; the tool boundary is the guardrail. **No separate Architect agent** for
   now (architecture *thinking* is the CTO's job; *building* goes to operators).
   Revisit only if build volume demands it.
6. **Trivial-change threshold:** ≤15 lines / single existing file / no new
   artifacts / reversible / own-domain = direct edit OK; else delegate.
   *Monitored.*
7. **Krypton owns this charter** (design/map = coordination); **Forge owns what
   it encodes** — agent definitions, this ADR, `project-layout.yaml` v1.2.0,
   enforcement wiring.

### C. The org chart and functional owners

```
Jesse — Principal (owner, P&L, final authority)
  └── Krypton — Chief of Staff / Continuity (holds the whole picture · routes · never executes)
        ├── MANAGERS / ORCHESTRATORS (persistent · judgment + routing · delegate execution)
        │     ├── CTO   — technical architecture & compute infra
        │     ├── Forge — dev-system owner (peer to CTO)
        │     └── CFO · CPO · CRO · CISO · CMO — domain executives
        ├── FUNCTIONAL OWNERS (cross-cutting · health/route/resolve over a function)
        │     ├── wm-agent   — OWNS the WM spine (deterministic runtime + latent owner face)
        │     ├── jobs-agent — OWNS all scheduled jobs (health · route · resolve)
        │     └── Nerve Center — observability/control PRODUCT jobs-agent operates through
        └── OPERATORS / WORKERS (ephemeral · execution · spec-driven · no continuity)
              ├── Codex (GPT Pro) — primary implementer
              ├── ephemeral Claude implementers (Task-spawned)
              ├── Krypton gatherers (kb · memory · adf · wm) — read-only
              └── Explore · Plan · general-purpose
```

**Functional owners** are the "one agent owns all the X" pattern: a single owner
per cross-cutting concern whose job is keep-it-healthy + route/resolve on failure.

### D. Per-project contract (R1–R10)

The recurring operational gap: many projects don't cleanly answer *(1) who owns
this now?* and *(2) what exact artifacts must an agent ingest before acting?*
The contract makes both deterministic. Locked decisions:

| # | Decision |
|---|----------|
| R1 | **Owner declared in `CLAUDE.md` frontmatter `owner:` field (local truth) + resolver/portfolio-map (global index).** No `PROJECT.md`. Shape = local-truth + global-index: one write per project where agents land, reconciled up. |
| R2 | **AGENTS.md is the canonical source of truth; `CLAUDE.md` imports `@AGENTS.md` and adds Claude-specific rules.** See §E for the reconciliation — this reverses the prior `project-layout.yaml` "AGENTS.md = mirror of CLAUDE.md" line. |
| R3 | **`decisions.md` (or `docs/decisions/`) required for active system projects** — the Memory-feed convention; cheap, per-project decision ledger. Harness consistency tracked as a follow-up. |
| R4 | **`README.md` required only for human-facing/shared projects;** optional for internal. No busywork. |
| R5 | **Minimum resolver entry schema (7 fields):** path, owner, stage, canonical-context-file, status-file, portfolio-row, freshness-threshold. |
| R6 | **Freshness threshold for stale warning: 30 days** for active system projects (single default; tune per-class later). Enforcement process tracked as a follow-up. |
| R7 | **PM assignments re-derived by rubric, not asserted.** Locked: **Krypton → personal-context.** Everything else re-derived against the ownership rubric (`docs/active/ownership-rubric.md`) — not stamped by this ADR. |
| R8 | **PM may be an agent role.** Two-tier always: Jesse = principal; assigned agent = operating PM (single point of contact). PMO-agent vs distributed-PM-function decided after the rubric. |
| R9 | **Ownership vs Forge-only dev-system paths are different axes.** PM owns *direction*; Forge keeps *write-authority* on dev-system paths. A non-Forge PM routes dev-system changes to Forge (existing rule). No conflict. |
| R10 | **ADR-backed convention first → pilot on 2–3 projects → fold into `project-layout.yaml` v1.2.0.** No separate standard. (This ADR is that convention.) |

**Owner = single point of contact for direction + state.** Directs current intent,
curates state, keeps `status.md`/orientation pointers trustworthy, accepts/rejects
work, routes cross-project questions, marks stale state explicitly. PM ≠ doer —
implementation delegates to operators, which is why one agent can own many
projects. **Phase changes contributors, not the owner** (a security pass pulls in
CISO; the accountable owner is unchanged). Optional re-evaluation at Operate only
if steady-state needs genuinely differ; continuity is the default.

### E. Reconciling the AGENTS.md ↔ CLAUDE.md contradiction (R2)

A real contradiction existed across our own governance:

- `project-layout.yaml` called **AGENTS.md a "Codex mirror of CLAUDE.md"**
  (CLAUDE primary).
- ADF-MULTI-RUNTIME-SPEC + ADF-ARCHITECTURE-v3 say **AGENTS.md = source of truth,
  CLAUDE.md imports `@AGENTS.md`** (AGENTS primary).

That conflict is *why* R2 felt unsettled. **Decision: AGENTS.md is canonical;
CLAUDE.md imports it and layers Claude-specific rules.** Rationale: AGENTS.md is
the open, multi-runtime standard (Codex, Gemini, Cursor, and 20+ tools read it),
so the canonical context belongs there; Claude remains the **primary coding
model**, so `CLAUDE.md` is a first-class consumer that imports AGENTS.md plus the
Claude-only rules. One source of truth, model-specific layering on top — not
divergent context in two files.

This is consistent with ADR-002 ("one canonical home per topic; everything else
points to it"): AGENTS.md is the canonical project-context home; CLAUDE.md is the
pointer-plus-overlay for Claude.

## Consequences

- **No tools stripped (Phase 1 is additive).** The manager/operator tool boundary
  (target state in §A) is a *target*, reached by phased tool-removal in a later
  ADR/phase once the spawn path is proven. Existing agents keep their current tool
  arrays. This ADR records the model and creates the two functional-owner faces.
- **Encoded this ADR (Phase 1):**
  - `jobs-agent` created in `pike-agents/plugins/jobs-agent/` (manager-class:
    read + delegate + coordinate; read-only Bash diagnostics; spawns operators for
    remediation), registered in `marketplace.json` + capabilities-registry.
  - `wm-agent` definition updated to formalize its **latent owner face** (owns the
    WM spine; deterministic runtime face + latent owner face that answers status
    and makes judgment calls) alongside the existing deterministic-workflow shape.
  - `forge` `maxTurns` raised 25 → 60 (turn-budget fix for org-charter–scale work).
- **Deferred to later Forge phases (downstream, tracked — NOT this ADR):**
  - **Phase 2 — tool boundaries:** harden managers to the §A target tool posture
    (default-to-delegate → tool-removal) once the spawn path is proven. CTO →
    pure-orchestrator tool array (decision 5).
  - `project-layout.yaml` **v1.2.0**: fix the "AGENTS.md = mirror of CLAUDE.md"
    line per R2; fold in the per-project contract (R1–R10); reconcile the ADF
    specs by reference.
  - **R7 ownership rubric** (`ownership-rubric.md`) re-derives PM assignments for
    Jesse's review; only `Krypton → personal-context` is locked here.
  - **R3/R6 enforcement** — audit existing tooling (project-doctor, ADF-audit, NC
    freshness/lint jobs) for owner-field / decision-ledger / staleness coverage and
    wire the gaps.
  - **R8 PMO-agent** decision (dedicated PMO agent vs PM-as-function vs
    Krypton-as-PMO) — after the rubric.
  - **Pilot** the contract on 2–3 projects before the standard edit (R10).
- The charter (`agent-org-charter.md`) remains the live org *map*; this ADR is the
  durable *why*; agent definitions are the *enforcement*. Complementary, per the
  established "rule takes effect / ADR records rationale" split.

## Status notes

Accepted. The model + 7 decisions + R1–R10 are ratified (Jesse, 2026-05-25). The
Phase 1 encoding (jobs-agent, wm-agent latent face, forge maxTurns) is live with
this ADR. Tool-boundary hardening, `project-layout.yaml` v1.2.0, the ownership
rubric, enforcement wiring, and the pilot are gated to later Forge phases and are
explicitly **not** authorized by this ADR.
