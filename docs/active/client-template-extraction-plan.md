---
type: planning-doc
status: draft
created: 2026-04-09
owner: forge
adr_ref: ADR-001 (AWS governance activation)
sprint: aws-governance-day2-phase-g
---

# Client Template Extraction Plan

## Why this matters

AWS is a proven internal operating system — as of Day 1 it has enforced standards, a decision log, versioned governance (v1.0.0), and a clear authority model. AGF is Jesse's commercial client project that synthesizes NIST / OWASP / CSA / ISO / OTel / EU AI Act into an enterprise governance playbook for organizations building agentic systems. The gap: AGF defines *what* good governance looks like at enterprise scale, but doesn't yet ship a *deployable starter kit* that a client engagement can adopt on Day 1. Extracting AWS as a client template closes that gap — it gives AGF a battle-tested scaffold that's already proven its value in Jesse's own workflow.

---

## What "extracting AWS as a client template" means

The deliverable is a reusable engagement scaffold — a directory of templates, standards, and role contracts — that a client team can instantiate at kickoff to immediately inherit structured governance. It is NOT a copy of Jesse's personal infrastructure. It is a distilled, generalized version of the AWS patterns (artifact contracts, decision logging, session lifecycle, frontmatter standards, CLAUDE.md shape) stripped of personal context and adapted to team-based engagement dynamics. The scope of the template scales with the engagement: a one-week assessment gets a lightweight subset; a six-month transformation engagement gets the full scaffold.

---

## What's transferable from AWS to client template

| AWS component | Transferable? | Adaptation needed |
|---|---|---|
| `project-layout.yaml` standard | Yes | Map AWS artifacts to engagement artifacts (intent.md → engagement-charter.md; BACKLOG.md → deliverable-manifest.md; lessons.md → engagement-retro.md) |
| `claude-md.yaml` standard | Yes | Strip personal refs; add client-context section; raise max_lines to 60 for engagement complexity |
| ADR pattern | Yes | Direct transfer — industry-standard practice; clients already understand decision logging |
| `artifact-frontmatter.yaml` | Yes | Direct transfer; adjust freshness thresholds for engagement cadence (status.md: 3d vs 7d) |
| Session lifecycle (orient, wrap, handoff) | Yes | Direct transfer with role-language substitution (agent → team member; Jesse → engagement lead) |
| Forge exclusive write-authority model | Partial | Replaced with "engagement lead" role or designated governance owner; on small engagements could still be Jesse solo |
| ADR versioning + CHANGELOG pattern | Yes | Direct transfer; enterprise clients respond well to versioned decisions |
| `docs/active/` working documents pattern | Yes | Direct transfer |
| `docs/decisions/` ADR directory | Yes | Direct transfer |
| `intent.md` artifact | Yes | Becomes engagement-charter.md with added fields: client name, engagement scope, timeline, commercial terms ref |
| Soft-gate governance model | Partial | On solo or small-team engagements: direct port. On larger engagements: may need hard gates (PR review, Jira integration) |
| Maturity model scoring concept | Yes (concept only) | AWS maturity model is personal; template gets a simplified 3-level readiness scale (baseline / structured / optimized) |
| Capabilities registry | No | Internal personal infrastructure; not deployable to clients |
| Pike-agents portfolio | No | Personal agent definitions; client templates assume platform-agnostic tooling |
| Memory MCP / KB MCP servers | No | Jesse's runtime infrastructure on macbook2014 |
| Nerve Center / launchd jobs | No | Personal automation infrastructure |
| Symlink-based migration patterns | No | Personal codebase organization pragmatics |
| Krypton, Link Triage, Work Management | No | Personal runtime components; no client relevance |
| `_shared/` peer subsystem references | No | Internal path topology |
| ADF stage specs (full set) | Partial | Stage model (Discover → Design → Develop → Deliver → Operate) transfers; the specific skills and tooling do not |

---

## What's NOT transferable

The following are Jesse's personal infrastructure and should not appear in any client template:

- **Memory MCP and KB MCP** — Runtime servers on macbook2014 (port 9101, 9102). No client equivalent assumed.
- **Capabilities registry** — Jesse's personal catalog of skills, agents, plugins. Not deployable.
- **Pike-agents portfolio** — The 9 exec/system agents (forge, cto, cfo, cmo, cpo, cro, ciso, krypton, tools) are personal definitions.
- **Nerve Center / macbook2014 runtime** — Cron infrastructure specific to Jesse's hardware.
- **Three-tier isolation model** — Host Mac / OrbStack / UTM topology is Jesse's personal environment architecture.
- **Personal Wiki** — `_shared/personal-wiki/` is Jesse's synthesized read-side of his KB.
- **Session-wrap KB promotion** — The `promote_cross_project_to_kb` action depends on Jesse's KB MCP. Template sessions would omit or substitute.
- **Global CLAUDE.md inheritance pattern** — Works because Jesse's global CLAUDE.md is loaded every turn. Client teams may not share a global config. Template CLAUDE.md must be self-contained or explicitly reference a shared team CLAUDE.md.
- **Forge as write-authority agent** — Forge is a personal agent definition. The authority model transfers; the specific agent does not.

---

## Where the template fits in AGF

AGF's `intent.md` is explicit: it produces a Playbook, community products, commercial products, and thought leadership. The client template is a commercial product — specifically an engagement accelerator bundled with governance consulting.

**Current AGF layout** (from filesystem inspection):

```
clients/risk/AGF/
├── agf-docs/               # Core framework docs (primitives, observability, decision-intel, etc.)
├── docs/                   # Supporting docs (same content, different path — may be duplicate)
├── diagrams/
├── data/
├── DECISIONS.md            # Decision log (exists — not using ADR format)
├── intent.md               # Exists — strong, substantive
├── README.md
├── CONTRIBUTING.md
├── LICENSE
└── [Next.js app files]     # app/, lib/, content/, scripts/ — AGF has a web app layer
```

**What's notable:** AGF has no `CLAUDE.md` (project-specific shell), no `status.md`, no `lessons.md`, no `BACKLOG.md`. It conforms to none of the AWS first-class artifact requirements. Its `DECISIONS.md` is a flat file, not ADR-formatted. This is a high-priority conformance gap separate from the template extraction work — note for Forge AUDIT mode.

**Proposed template home within AGF:**

```
clients/risk/AGF/
└── templates/
    └── aws-engagement-starter/
        ├── README.md               # How to instantiate this template
        ├── engagement-charter.md   # Replaces intent.md
        ├── status.md               # Template with required frontmatter
        ├── BACKLOG.md              # Template backlog
        ├── lessons.md              # Template retro/lessons buffer
        ├── CLAUDE.md               # Self-contained project shell template
        ├── docs/
        │   ├── active/             # Working documents directory
        │   └── decisions/          # ADR log directory
        │       └── ADR-000-template.md
        └── standards/
            ├── project-layout.yaml  # Adapted from AWS
            ├── claude-md.yaml       # Adapted from AWS
            └── artifact-frontmatter.yaml  # Adapted from AWS
```

This path keeps the template discoverable as an AGF deliverable while remaining cleanly separable from AGF's core framework content.

---

## Stages of extraction work

### Phase 1: Strip personal artifacts (1 week)

- Take AWS standards (`project-layout.yaml`, `claude-md.yaml`, `artifact-frontmatter.yaml`, `session-lifecycle.yaml`) as starting point
- Remove personal references: Jesse's name, macbook2014 host, pike-agents, Memory/KB MCP references
- Replace solo-dev assumptions with role-based language (Forge → engagement lead; Jesse's global CLAUDE.md → team shared config)
- Produce: 4 adapted YAML standards at `templates/aws-engagement-starter/standards/`

### Phase 2: Generalize Forge → engagement-lead role (1 week)

- AWS concentrates write authority in a single agent (Forge). The client template needs a flexible authority model:
  - **Solo engagement (Jesse only):** Claude Code + Forge pattern works directly
  - **Small team (Jesse + 1-2 client staff):** Engagement lead holds write authority; others are read-only on governance surfaces
  - **Larger engagement (Jesse + client team):** PR-review gate on governance changes; designated governance owner per workstream
- Define the role contract as a `roles.yaml` in the template: lists governance surfaces and who may write to them
- The key insight from AWS: the authority model matters more than who fills the role. The template should make the model explicit; the engagement fills in the names.

### Phase 3: Add client-specific layers (1-2 weeks)

- **Engagement charter** — Replaces `intent.md`. Adds: client name, engagement scope, commercial terms reference, success metrics, timeline, out-of-scope declaration
- **Deliverable manifest** — Replaces or supplements `BACKLOG.md`. Tracks deliverables with status, owner, due date, acceptance criteria
- **Risk/scope tracker** — New artifact. Captures scope creep, blockers, escalation path
- **Compliance mapping** — Bridges AWS-style governance into AGF's NIST / ISO / OTel compliance posture. Each governed artifact maps to one or more AGF framework controls. This is where the template earns its place inside AGF rather than being a standalone product.
- **Adapted ADR template** — AGF-flavored: includes `risk_rating`, `compliance_refs`, `reversibility` fields not present in AWS ADRs

### Phase 4: Pilot on one engagement (1 month)

- Use the extracted template on a real or synthetic client engagement
- Real option: apply retroactively to the AGF project itself (which currently has no AWS conformance)
- Synthetic option: create a reference engagement scenario with realistic scope (e.g., "enterprise AI governance assessment for a Series B fintech")
- Capture friction: what did clients not understand? what required customization? what was over-specified?
- Produce: updated template + pilot debrief doc in `templates/aws-engagement-starter/docs/active/`

### Phase 5: Productize (2-4 weeks)

- Polish for self-service instantiation: add `instantiate.sh` or equivalent setup script
- Write activation guide: "How to deploy this template for a new engagement in under 2 hours"
- Define the CLI or manual steps for stamping out a new engagement from the template
- Position the template explicitly in AGF's commercial product map — is it bundled into governance consulting, offered as a standalone starter kit, or open-sourced?
- Final artifact: `templates/aws-engagement-starter/README.md` that a client (or Jesse) can follow without additional context

**Total estimated effort: 10-13 weeks of focused work.** Most phases can run in parallel with ongoing AGF development — they do not require AGF to pause.

---

## Open questions

1. **Engagement scale target.** Does the template optimize for a 2-week assessment engagement, a 6-month transformation, or both? The AWS pattern is tuned for indefinite solo-dev work — a time-boxed client engagement has different artifact lifecycles.

2. **Agent platform assumption.** AWS is built for Claude Code. Does the client template assume Claude Code, or is it platform-agnostic (tools-neutral YAML/Markdown artifacts that any agent or human team could operate)? Platform-agnostic is more portable but weaker on the "operational AI governance" story that makes AGF distinctive.

3. **Client team baseline.** Does the template assume the client has any agent-based workflow? If not, session lifecycle and CLAUDE.md sections may need a "human-only" mode alongside the agent-assisted mode.

4. **Pricing model.** Three options:
   - Bundled into AGF governance consulting engagements (no separate SKU)
   - Separate commercial product ("AGF Engagement Starter Kit" — one-time license or annual)
   - Open-sourced as marketing / thought leadership (drives consulting pipeline)
   Each has a different implication for how polished the template needs to be and how much ongoing maintenance it requires.

5. **AGF conformance first.** The AGF project itself has no `status.md`, `CLAUDE.md`, `lessons.md`, or `BACKLOG.md`. Should AGF get brought into AWS conformance before the template is extracted — as a forcing function to discover template gaps? This would run Phase 4 (pilot) concurrently with Phases 1-2.

---

## Risks

- **Maintenance debt.** Two parallel governance artifacts (AWS standards + client template standards) that must stay synchronized. Every AWS standards update becomes a potential template update. Mitigation: make the template inherit from AWS standards via explicit version pinning, not by copying files.
- **Adoption gap.** Client teams may not operate agent-based workflows at all. If the template assumes Claude Code as the execution environment, it may not land. Mitigation: design all artifacts as human-operable first; agent assistance is an enhancement, not a requirement.
- **Scope creep on the extraction itself.** The template is planned as a scaffold, but AGF's full framework complexity (19 primitives, rings model, compliance mapping) creates pressure to make the template comprehensive. A comprehensive template is a product; a scaffold is a starting point. Keep Phase 1-3 scope tight.
- **AGF's current state.** AGF is a framework project with a strong `intent.md` and substantive docs, but no AWS-conformant project structure (no status.md, no CLAUDE.md, no lessons.md, no ADR log). The template extraction work may surface pressure to fix AGF's own conformance, which is separate work and out of scope for this plan.

---

## Decision needed

**Do we start this in 2026 Q2?**

Three options:

**A. Start Q2** — Phases 1-2 begin now, concurrent with ongoing AWS Day 2 work. The extraction is simple enough to run in parallel. Estimated: complete through Phase 3 by end of Q2.

**B. Defer to Q3** — Let AWS governance stabilize through Day 2 (audit skill, project-doctor, nightly launchd job). Extract after the baseline is proven. Lower risk of the template encoding patterns that Day 2 changes.

**C. Park indefinitely** — AGF has higher-priority deliverables (Playbook, community products). The template is valuable but not on the critical path. Revisit when a real client engagement demands it.

Recommendation for Jesse's consideration: **Option B** offers the best risk/reward. AWS needs 4-6 weeks to prove the governance model in production (daily workflow, audit catches, drift correction). Extracting before that proof accumulates means the template may encode Day 1 patterns that Day 2 revises. Q3 start gives a clean extraction off a proven v1.x baseline.

---

## References

- ADR-001 (AWS governance activation): `~/code/_shared/aws/docs/decisions/ADR-001-aws-governance-activation.md`
- AWS overview (canonical): `~/code/_shared/aws/docs/overview.md`
- AWS standards: `~/code/_shared/aws/docs/standards/`
- AWS CHANGELOG: `~/code/_shared/aws/CHANGELOG.md`
- AGF project: `~/code/clients/risk/AGF/`
- AGF intent (exists, substantive): `~/code/clients/risk/AGF/intent.md`
- AGF framework docs: `~/code/clients/risk/AGF/agf-docs/`
