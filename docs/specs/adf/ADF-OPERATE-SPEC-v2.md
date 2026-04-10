---
type: "specification"
description: "Detailed specification for the Operate & Learn loop closure mechanism"
version: "2.0.0"
updated: "2026-03-23"
supersedes: "ADF-OPERATE-SPEC.md (v0.4.0)"
scope: "adf"
lifecycle: "active"
location: "docs/active/ADF-OPERATE-SPEC-v2.md"
---

# ADF Operate & Learn Specification

## Purpose

Define Operate & Learn — the **loop closure mechanism** that activates after Deliver for living systems. It is not a sequential 5th stage in the same sense as Discover through Deliver. It is the feedback channel that converts real-world evidence into the starting point for the next cycle.

---

## Conceptual Model

ADF operates in two modes:

```
┌─────────────────── ASSUMPTION MODE ───────────────────┐
│                                                        │
│  Discover → Design → Develop → Deliver                 │
│  (Building on what we think is true)                   │
│                                │                       │
└────────────────────────────────┼───────────────────────┘
                                 │ ship it — assumptions meet reality
                                 ▼
┌─────────────── EVIDENCE MODE ──────────────────────────┐
│                                                        │
│  Operate & Learn                                       │
│  (Refining based on what we observed)                  │
│                                │                       │
└────────────────────────────────┼───────────────────────┘
                                 │ real-world evidence seeds next cycle
                                 ▼
                            Discover (next cycle)
```

**Assumption Mode** (Discover → Design → Develop → Deliver) works from a model of the world: what we think the problem is, how we think it should be solved, how we think it should be built. Every artifact produced in these stages is an assumption made explicit.

**Evidence Mode** (Operate & Learn) is what happens when the delivered system meets real use. The act of using what was built immediately generates evidence about which assumptions were right, which were wrong, and what wasn't anticipated at all. This evidence — not speculation — seeds the next Discover cycle.

**The loop is continuous.** Operate & Learn doesn't end the project. It closes the loop from one cycle into the next.

---

## Stage Overview

> **"Is this working well, and what should change?"**

Operate & Learn is activated by shipping. The moment a system is in real use, every friction point, every missing capability, every unexpected usage pattern is evidence. Collecting and synthesizing that evidence is the work of this stage.

It does not produce a deliverable. It produces a decision: **continue observing, fix in place, launch a new Discover cycle, or retire.**

**This mechanism applies to living systems.** One-shot artifacts (presentations, reports, one-time outputs) complete at Deliver. Operate & Learn is for systems that run, get used, and evolve.

| System Type | What Gets Observed |
|-------------|-------------------|
| Apps | Usage patterns, UX friction, performance, feature gaps |
| MCP Servers | Tool call patterns, error rates, missing capabilities, schema mismatch |
| Workflows | Execution reliability, edge cases, trigger accuracy, intent drift |
| Agents / Plugins | Invocation patterns, failure modes, unmet use cases |

**Key distinction from backlog:** Operate & Learn captures *signals* — raw observations that may or may not be actionable. BACKLOG.md captures *work items*. Signal synthesis is what converts observations into backlog entries.

---

## Phase Model

Operate & Learn is **continuous and cyclical**, not a bounded sprint. Phases 2 and 3 repeat until a Cycle Decision is reached.

| Phase | Description | Cadence |
|-------|-------------|---------|
| **1. Activation** | One-time setup at Deliver completion. Verify intent alignment. Define what "working well" means. | Once (at loop entry) |
| **2. Observation** | Ongoing. Log signals as they arise during real use. Low ceremony — just capture. | Every session |
| **3. Synthesis** | Periodic. Cluster observations, assess intent alignment, feed actionable items to backlog, write synthesis report. | Weekly / monthly / threshold |
| **4. Cycle Decision** | Human decision point. What happens based on the synthesis? | After each Synthesis |

---

## Inputs

| Input | Source | Description |
|-------|--------|-------------|
| Delivered system | Deliver | The live artifact in real use |
| `intent.md` | Discover | North Star — what this system is supposed to do |
| `brief.md` | Discover | Original success criteria (reference for intent alignment) |
| Deliver milestone seal | Deliver | Structured stage handoff in status.md |
| Usage context | Real-world operation | How the system is actually being used |

---

## Outputs

| Output | Description | Location |
|--------|-------------|----------|
| `docs/operate/observations.md` | Running signal log — friction, gaps, errors, patterns | `docs/operate/observations.md` |
| `docs/operate/synthesis-YYYY-MM-DD.md` | Periodic synthesis — clustered patterns, intent alignment rating, backlog refs | `docs/operate/` |
| BACKLOG.md entries | Actionable items from synthesis clusters | `BACKLOG.md` |
| Cycle decision record | Decision + reasoning logged in status.md | `status.md` |
| Seeded `brief.md` | If new cycle triggered — brief updated with evidence from synthesis | `docs/brief.md` |

---

## Phase Details

### 1. Activation

**Purpose:** Ground-truth calibration before the observation window opens. Happens once at Deliver completion.

#### 1.0 Living System Gate (mandatory, before anything else)

Verify that the delivered artifact qualifies as a living system before activating Operate & Learn.

A living system has at least two of the following:
- Runs continuously or is invoked repeatedly in production
- Accepts live input (user actions, triggers, API calls)
- Maintains state that evolves over time
- Is expected to change in response to observed usage

If the artifact fails this check (e.g., a one-time report, a static document, a single-run script), seal `status.md` as `Complete` and do not activate Operate & Learn.

#### 1.1 Intention Alignment Check (mandatory)

The first act of Operate & Learn is looking back: did what shipped match what was intended?

- Read `intent.md` — problem, outcome, why it matters
- Read `brief.md` — original success criteria
- Map each criterion to the delivered system: met / partial / not met
- Document any gaps in `observations.md` as the opening entries

This is not a re-evaluation of Deliver. Deliver already validated shipping quality. This is checking whether shipping quality matches original intent — a different question. Gaps found here are the first evidence, not blockers.

#### 1.2 Define Observation Targets

What does "working well" mean for this system specifically?

| Type | Observation Targets |
|------|-------------------|
| **Apps** | Core flows completing without friction, error rates, feature gaps surfacing in use |
| **MCP Servers** | Tools called as designed, schemas matching actual use, missing tools becoming apparent |
| **Workflows** | Triggers firing correctly, edge cases uncovered, context drift |
| **Agents / Plugins** | Invocation patterns, failure modes, capability gaps |

Document chosen targets in `docs/operate/observations.md` as the header section.

#### 1.3 Set Synthesis Cadence

| System Type | Default Cadence |
|-------------|----------------|
| Actively used app / MVP | Weekly |
| Low-traffic tool or workflow | Monthly |
| Background MCP server | After 10+ observations accumulate |

**Exit signal:** Intent alignment check documented, observation targets defined, cadence set.

---

### 2. Observation

**Purpose:** Capture signals as they arise during real use. The lower the friction, the more signal gets captured.

**What to log:**

| Signal Type | Description |
|-------------|-------------|
| **Friction** | Workarounds needed, unexpected behavior, confusing output |
| **Error** | Tool failures, exceptions, data issues |
| **Gap** | Missing capability, uncovered use case, "I wish it could..." |
| **Drift** | System behavior diverging from intent over time |
| **Delight** | Something working better than expected — worth preserving |
| **Pattern** | Recurring behavior (positive or negative) worth noting |

**Log format** in `docs/operate/observations.md`:

```markdown
| Date | Type | Signal | Context | Severity |
|------|------|--------|---------|----------|
| YYYY-MM-DD | Friction | [Brief description] | [When/where observed] | Low/Med/High |
```

**Severity rubric:**

| Severity | Criteria |
|----------|----------|
| **High** | System unusable for key use case; data loss or corruption; core intent blocked |
| **Med** | Recurring friction with a workaround; capability gap affecting multiple sessions |
| **Low** | One-off confusion; cosmetic issue; minor inconsistency |

**Rules:**
- Capture all signals regardless of whether they align to defined Observation Targets
- Capture immediately — don't batch observations in your head
- Flag High severity items in status.md; don't wait for synthesis cadence
- Do NOT convert observations to backlog items — that's synthesis work. Raw signal has more value unprocessed.

**Exit signal:** None — Observation continues until synthesis cadence triggers.

---

### 3. Synthesis

**Purpose:** Make sense of accumulated signals. Convert evidence into understanding.

#### 3.1 Cluster Observations

Group by theme, not by date:
- Similar friction points → single cluster
- Related gaps → single cluster
- Recurring errors → single cluster

#### 3.2 Intent Alignment Assessment

Against `intent.md`:
- Is the system fulfilling its stated purpose?
- Are usage patterns aligned with intended use, or has usage evolved?
- Is there scope drift (system used for things it wasn't designed for)?

Rate alignment: **Strong / Adequate / Degrading / Broken**

#### 3.3 Pattern Classification

For each cluster, classify:
- **Systematic gap** — a design decision that turned out wrong
- **Incremental improvement** — a good idea worth implementing
- **Usage evolution** — intent itself has shifted, new cycle needed
- **Noise** — one-off, not worth addressing

#### 3.4 Feed Actionable Clusters to BACKLOG.md

For each cluster that warrants action:
- Write a BACKLOG.md entry with pattern, evidence, and recommended action
- Include synthesis date and observation count
- Work items flow through normal backlog → dispatch, not directly to tasks

#### 3.5 Write Synthesis Report

```markdown
# Synthesis — YYYY-MM-DD

## Summary
[2-3 sentences: overall system health, dominant patterns, recommendation]

## Intent Alignment
**Rating:** Strong / Adequate / Degrading / Broken
[Brief justification]

## Signal Clusters

### [Cluster name]
- **Observations:** N
- **Pattern:** [Description]
- **Severity:** Low / Med / High
- **Classification:** Systematic gap / Incremental improvement / Usage evolution / Noise
- **Backlog:** B-xxx filed / No action needed / Informational

## Cycle Recommendation
[Continue observing / Fix in place / Launch new Discover / Retire]
[Reasoning]
```

**Exit signal:** Synthesis report written, backlog entries filed, cycle recommendation ready for human.

---

### 4. Cycle Decision

**Purpose:** Human decision point — what does the evidence say to do next?

| Decision | When | What Happens |
|----------|------|-------------|
| **Continue observing** | Alignment Strong/Adequate, no High clusters | Return to Observation phase |
| **Fix in place** | Isolated improvements, no intent revision needed | Lightweight Develop sprint scoped to the fix; re-enter Observation phase after |
| **Launch new Discover** | Alignment degrading, usage evolved, major new need | Synthesis seeds new `brief.md`; full cycle restarts |
| **Retire** | System obsolete, superseded, or out-of-scope | Archive/decommission; status.md sealed |

**Decision heuristic:**

```
Alignment Broken             → New Discover or Retire
3+ High severity clusters    → New Discover or Fix in place
Intent fundamentally shifted → New Discover
Improvements are incremental → Fix in place
No longer in active use      → Retire
Otherwise                    → Continue observing
```

**Tie-breaker: "New Discover vs Fix in place"**
Choose Fix in place if:
- Clusters are isolated to specific components
- Intent alignment is Adequate or Strong
- All target clusters can be scoped to a single minimal sprint

Choose New Discover if:
- Clusters span multiple architectural layers
- Intent alignment is Degrading
- Usage patterns show the system is being used for something it was not designed for

**Tie-breaker: "New Discover vs Retire"**
Choose Retire if:
- No active usage observed for a full synthesis period
- System has been superseded by another artifact
- Maintenance cost clearly exceeds benefit

Otherwise, default to New Discover.

**Agent role:** Present synthesis summary and recommendation. The decision belongs to the human. After the human responds:

1. Log the decision in status.md
2. Take the first action of the chosen path:
   - **Continue observing:** Note the decision; return to Observation phase
   - **Fix in place:** Scope a minimal plan for target cluster(s) using ADF-DEVELOP-SPEC-v2.md task patterns. File remaining clusters to BACKLOG.md as deferred. Return to Observation phase when fix deployed.
   - **Launch new Discover:** Create seeded `brief.md` with evidence-grounded content from synthesis report; enter Discover. Observation on the current live system may continue in parallel.
   - **Retire:** Archive `docs/operate/`; update status.md with retirement seal; done

**Seeding a new Discover brief (Launch new Discover path):**

Copy `brief.md` from the most recent version. Replace the following sections with evidence-grounded content from the synthesis report:
- **Problem statement** → dominant friction/gap patterns from synthesis
- **Success criteria** → what actually mattered in real use
- **Scope** → bounded by what usage revealed
- **Context** → intent alignment rating + key observations summary

Label the seeded brief: `Evidence-seeded from: docs/operate/synthesis-YYYY-MM-DD.md`.

**Log in status.md:**

```markdown
## Operate & Learn — Cycle Decision (YYYY-MM-DD)

**Synthesis:** docs/operate/synthesis-YYYY-MM-DD.md
**Decision:** [Continue / Fix in place / New Discover / Retire]
**Reasoning:** [Why]
**Next action:** [What happens next]
```

---

## How New Discover Cycles Differ from First Cycles

When Operate & Learn triggers a new Discover cycle, that cycle starts with **evidence instead of assumptions.**

| First Cycle (Discover) | Evidence-Seeded Cycle (Discover after Operate & Learn) |
|------------------------|-------------------------------------------------------|
| Problem is hypothesized | Problem is observed — real friction, real gaps |
| Success criteria are guessed | Success criteria are refined by what actually mattered |
| Scope is estimated | Scope is bounded by what usage revealed |
| intent.md is aspirational | intent.md is updated to reflect evolved understanding |

The synthesis report becomes the primary input to the new brief. Observations carry forward, clustered and prioritized, as the opening context for the next Discover phase.

---

## Session Protocol

Operate & Learn sessions are lighter than Develop/Deliver.

**Session start:**
1. Read `status.md` — understand current observation state
2. Review recent `observations.md` entries
3. Check if synthesis cadence threshold has been reached

**During session:**
- Use the system for its intended purpose
- Log signals as they arise
- If cadence threshold reached, run Synthesis
- If Synthesis complete, present Cycle Decision

**Session end:**
- Commit new observations / synthesis reports
- Update status.md with observation state
- Run `/handoff` to persist session context and write cross-project learnings

---

## Design Principles

**Shipping activates the loop.** Operate & Learn isn't a phase you plan to enter — it begins the moment real use begins. The act of using a delivered system is inherently discovery.

**Observation before action.** Raw signals have more value unprocessed. Converting observations to tasks prematurely loses signal fidelity. Let patterns emerge.

**Intent is the calibration point.** Operate & Learn is not about accumulating feature requests. It's about assessing whether the system is fulfilling its original intent. New direction needs a new Discover cycle, not backlog inflation.

**Evidence-seeded cycles are stronger.** The second Discover cycle for a system is inherently better than the first — it starts from observed reality, not assumptions. The loop improves the loop.

**Low ceremony or it gets skipped.** This runs indefinitely alongside normal operation. Observations must take seconds. Synthesis should take one session. If the overhead is higher than that, simplify.

---

## References

- ADF-STAGES-SPEC.md (Stage boundary handoff, session protocol)
- ADF-DISCOVER-SPEC-v2.md (New cycle entry point — seeded by synthesis)
- ADF-DELIVER-SPEC-v2.md (Deliver is the loop entry trigger)
- ADF-TASK-LIFECYCLE-SPEC.md (Backlog item format — synthesis output)
- ADF-STATUS-SPEC.md (Cycle decision logging)
- ADF-INTENT-SPEC.md (Intent alignment reference)
