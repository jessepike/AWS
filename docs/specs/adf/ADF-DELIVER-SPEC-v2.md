---
type: "specification"
description: "Detailed specification for the Deliver stage workflow"
version: "2.0.0"
updated: "2026-03-23"
supersedes: "ADF-DELIVER-SPEC.md (v1.0.0)"
scope: "adf"
lifecycle: "active"
location: "docs/active/ADF-DELIVER-SPEC-v2.md"
---

# ADF Deliver Stage Specification

## Purpose

Define the Deliver stage — the fourth stage in the ADF workflow where a completed deliverable becomes accessible and usable in its target environment.

---

## Stage Overview

> **"Is this increment done and usable?"**

Deliver transforms a built deliverable into an operational, accessible artifact in its target environment. This stage handles deployment planning, infrastructure setup, distribution/deployment execution, multi-tier validation, and milestone closeout.

**Primary Deliverables (in sequence):**

| Order | Artifact | Content | Creates |
|-------|----------|---------|---------|
| 1 | `manifest.md` | Deployment dependencies to install | What deployment needs |
| 2 | `capabilities.md` | Skills, tools for deployment/testing | What agent infrastructure is needed |
| 3 | `plan.md` | Deployment plan with phases/testing strategy | How to deliver it |
| 4 | `BACKLOG.md` | Atomic delivery task list with status tracking | What to do |
| 5 | Deployed/distributed artifact | Accessible in target environment | The thing, live |
| 6 | Access documentation | URLs, credentials, usage instructions | How users access it |

**Sequence matters.** Capabilities informs planning. Planning informs tasks. Do not create later artifacts until earlier ones are approved.

---

## Phase Model

**PLANNING PHASES (1-3):** Produce artifacts, proceed to review.

| Phase | Description | Exit Gate | Artifacts |
|-------|-------------|-----------|-----------|
| **1. Intake & Readiness Check** | Verify Develop outputs, understand delivery scope | Agent confirms readiness | — |
| **2. Delivery Capability Assessment** | Identify deployment target and required capabilities | Agent approves manifest + capabilities | manifest.md, capabilities.md |
| **3. Delivery Planning** | Create deployment plan and task breakdown | Agent approves plan + tasks | plan.md, BACKLOG.md |

**REVIEW + HARD GATE (Phase 4):** Validate plan, then get human approval.

| Phase | Description | Exit Gate | Artifacts |
|-------|-------------|-----------|-----------|
| **4. Review Loop & Approval** | Internal/external review, then human sign-off | No Critical/High issues + human approval | Updated planning artifacts |

**EXECUTION PHASES (5-8):** Require approved plan.

| Phase | Description | Exit Gate | Artifacts |
|-------|-------------|-----------|-----------|
| **5. Infrastructure Setup** | Prepare deployment target environment | Infrastructure ready | — |
| **6. Deployment Execution** | Deploy/distribute to target environment | Successfully deployed | — |
| **7. Validation & Testing** | 3-tier validation (automated, browser, manual) | Confirmed usable | Test results |
| **8. Milestone Closeout** | Cleanup, seal, mark increment complete | All criteria met, status.md sealed | — |

---

## Phase Boundary Protocol

Every phase transition requires context clearing to prevent accumulated drift and stale assumptions.

**Protocol (agent-driven):**

1. Agent completes phase work
2. Agent updates the **Handoff** block in `BACKLOG.md` (see format below)
3. Agent updates `status.md` with phase completion summary
4. **Agent commits all changes** (mandatory — not optional)
5. Agent updates `current_phase` in `BACKLOG.md` frontmatter
6. Agent moves completed tasks to Completed section in `BACKLOG.md`
7. Agent runs `/clear`
8. Agent re-reads artifacts fresh: `CLAUDE.md` → `status.md` → `BACKLOG.md` → `plan.md`
9. Agent confirms: **"Phase N complete. Starting Phase N+1. Here's what I see: [brief summary from handoff block]"**

**Why:** Multi-phase execution accumulates stale context. Agents carry assumptions forward that may no longer apply. Clearing context and re-reading from artifacts ensures each phase starts from ground truth, not memory.

### Handoff Block

The Handoff section lives at the top of `BACKLOG.md` (after frontmatter, before phase tables). It is **overwritten** at each phase boundary — only the current handoff matters.

**Required format:**

```markdown
## Handoff

| Field | Value |
|-------|-------|
| Phase | {completed phase name} |
| Status | Complete |
| Next | {next phase name} |
| Blocker | {blocker or "None"} |

**Done this phase:**
- {task ID}: {brief summary}
- {task ID}: {brief summary}

**Next phase requires:**
- {what to start, key dependencies, any setup needed}

**Deployment notes:**
- {decisions made, gotchas discovered, anything the next phase needs to know}
```

**Rules:**
- **Overwrite, don't append.** Each boundary replaces the previous handoff block.
- **Keep it short.** 10-20 lines max. This is orientation, not a journal.
- **Deployment notes are optional.** Omit the section if there's nothing worth noting.

---

## Inputs

What enters the Deliver stage:

| Input | Source | Description |
|-------|--------|-------------|
| The deliverable | Develop | Primary input — built artifact (code, workflow, presentation, etc.) |
| Documentation | Develop | README, API docs, usage guides |
| Test suite | Develop | Automated tests (95%+ passing) |
| `design.md` | Design | Technical specification (referenced for validation) |
| `brief.md` | Discover | Contract — referenced for success criteria |
| `intent.md` | Discover | North Star — referenced throughout |
| Project classification | Brief | Type + modifiers determine delivery approach |
| ADF specs | Environment layer | Deliver spec, Project Types spec |

---

## Outputs

What Deliver produces:

| Output | Description | Location |
|--------|-------------|----------|
| `manifest.md` | Deployment dependencies (hosting, DNS, CI/CD tools) | `docs/active/manifest.md` |
| `capabilities.md` | Skills, tools for deployment/testing | `docs/active/capabilities.md` |
| `plan.md` | Deployment plan — phases, testing strategy, rollout | `docs/active/plan.md` |
| `BACKLOG.md` | Atomic delivery task list with status tracking | `BACKLOG.md` (cross-stage) or `docs/active/BACKLOG.md` |
| Deployed artifact | Live, accessible deliverable in target environment | Target-specific |
| Access documentation | URLs, credentials, access instructions | README or docs/ACCESS.md |
| Test results | Validation evidence (automated, browser, manual) | docs/active/test-results.md |

---

## Phase Details

### 1. Intake & Readiness Check

**Purpose:** Quick validation that Develop delivered what Deliver needs. Smell test only — trust Develop did thorough validation.

**Activities:**
- Verify Develop outputs present:
  - [ ] Deliverable exists and builds/runs
  - [ ] Documentation exists (README, usage guides)
  - [ ] Tests exist and pass (95%+)
  - [ ] No uncommitted changes
- Understand what was built:
  - Read README and docs
  - Run deliverable locally (smoke test)
  - Understand scope (MVP? Feature? Full app?)
- **Determine delivery scope:**
  - **Artifact:** Simple export/distribution
  - **App feature:** Deploy to existing production environment
  - **App MVP:** First-time infrastructure setup + deployment
  - **Workflow:** Installation/activation in target environment

**This is NOT a full review.** Develop already did exhaustive validation. This is a handoff verification.

**Agent role:** Verifier. Checklist validation. Flag blockers if deliverable incomplete.

**Key questions to resolve:**
- "What's the delivery target?" (Railway, Vercel, local, export, etc.)
- "First-time setup or existing environment?"
- "Who's the end user and how do they access it?"

**Exit signal:** Agent confirms: "Develop outputs verified. Delivery scope understood. Ready to assess deployment capabilities."

---

### 2. Delivery Capability Assessment

**Purpose:** Identify everything needed to deploy/distribute the deliverable — both infrastructure dependencies and agent capabilities.

**Sequence:** Create manifest.md first, then capabilities.md. Capabilities cannot be assessed until deployment dependencies are known.

**Two distinct outputs:**

#### manifest.md — Deployment Dependencies

What needs to be set up or configured:
- **Hosting/infrastructure** (Railway, Vercel, AWS, local server)
- **Domain/DNS** (if custom domain needed)
- **Environment variables/secrets** (API keys, DB connection strings)
- **CI/CD pipelines** (GitHub Actions, Railway auto-deploy)
- **External services** (databases, caches, CDNs)
- **Distribution channels** (package registries, app stores, file hosting)

#### capabilities.md — Agent Infrastructure

What the agent team needs to execute delivery. **Required sections:**

| Section | Content | Example |
|---------|---------|---------|
| **Deployment Skills** | Specialized deployment capabilities | Railway skill, Vercel skill, AWS deploy |
| **Testing Tools** | Browser, E2E, validation tools | Claude in Chrome, MCP Inspector, Playwright |
| **CLIs & Tools** | External command-line tools | Railway CLI, Vercel CLI, gh, npm |
| **MCP Servers** | External integrations for deployment | Railway MCP, GitHub MCP |

**Testing capabilities MUST be identified in Phase 2.** If missing, Phase 2 is incomplete.

**Registry Query Step (mandatory):**

Before documenting capabilities, query available resources:

1. **Read registry inventory** — `~/code/_shared/capabilities-registry/INVENTORY.md`
2. **Match to requirements** — Which available capabilities apply to deployment?
3. **Identify gaps** — What's needed but not in registry? (manual specification required)
4. **Document source** — For each capability, note: registry path OR manual specification
5. **Write Registry Summary** — Include as the first section of capabilities.md

Without the summary, Phase 2 is incomplete.

**Agent role:** Query registry, research deployment requirements from README/docs, document comprehensively with sources.

**Human role:** Validate capability choices, approve or suggest alternatives.

**Exit signal:** Manifest and capabilities documented. Ready to plan deployment.

---

### 3. Delivery Planning

**Purpose:** Create a comprehensive deployment plan and atomic task breakdown.

**Two outputs:**

#### plan.md — Deployment Plan

- **Overview:** What we're deploying, where it's going
- **Deployment target:** Specific environment details (Railway project, domain, etc.)
- **Phases:** Logical groupings of work (e.g., Phase 1: Infrastructure, Phase 2: Deploy, Phase 3: Validate)
- **Deployment approach:** How we'll execute (CI/CD, manual deploy, export)
- **Testing Strategy:** What gets tested (see Testing Strategy section below)
- **Rollback plan:** How to undo deployment if issues arise
- **Access setup:** How users will access the deployed artifact
- **Risk areas:** Known challenges, mitigation approaches

**Testing strategy MUST specify:**
- **Tier 1 (Automated):** What frameworks, what gets tested, coverage targets
- **Tier 2 (Browser/Agent):** Browser testing plan (Claude in Chrome, MCP Inspector)
- **Tier 3 (Manual):** User acceptance scenarios, who tests, success criteria

If the testing strategy section is missing or incomplete, Phase 3 is incomplete.

#### BACKLOG.md — Handoff + Atomic Task List

In Deliver, BACKLOG.md uses the **full structure** with:
- Handoff block (overwritten at each phase boundary)
- Active Tasks table with all columns (ID, Task, Status, Acceptance Criteria, Testing, Depends, Capability)
- Upcoming section for next phase planning
- Completed section for traceability

**Key Deliver requirements:**
- Every task has acceptance criteria and testing approach
- Capability column links to capabilities.md entries
- Progressive disclosure: read Handoff + Active, skip Completed unless investigating
- Task granularity: one agent, one session, verifiable completion

**Exit signal:** Plan and tasks drafted. Ready for review.

---

### 4. Review Loop & Approval

**Purpose:** Validate the deployment plan through thorough review, THEN get human approval.

**Two-step process:**

#### Step 1: Review Loop

Invoke review per ADF-REVIEW-SPEC.md.

**What gets reviewed:**
- manifest.md
- capabilities.md
- plan.md
- BACKLOG.md

All artifacts reviewed together — they must align.

**Review focus:**
- Does the plan cover all deployment requirements?
- Are tasks atomic enough for single-agent execution?
- Are dependencies complete? Anything missing?
- Is the testing strategy sufficient? (3-tier coverage)
- Is the rollback plan viable?
- Are there deployment risks not addressed?
- Is user access clearly defined?

**Review mechanism:** Review follows ADF-REVIEW-SPEC. Internal review is mandatory. External review is risk-driven, user-triggered.

**Exit condition (Step 1):** No Critical/High issues. Plan is executable.

#### Step 2: HARD GATE — Human Approval

After review completes, present all planning artifacts to human for approval.

**Agent presents:**
- manifest.md (deployment dependencies)
- capabilities.md (skills/tools needed)
- plan.md (deployment approach + testing strategy)
- BACKLOG.md (delivery tasks)
- Review summary (issues resolved, reviewer feedback)

**Human evaluates:**
- Does this make sense for our context?
- Are the deployment targets correct?
- Is the testing strategy appropriate?
- Any concerns or changes needed?

**Exit condition (Step 2):** Human approves: "Proceed with execution."

---

### 5. Infrastructure Setup

**Purpose:** Prepare the deployment target environment. No deployment yet — just setup.

**Activities (project-type specific):**

#### For Apps (first-time MVP)
- Create hosting project (Railway, Vercel, etc.)
- Configure environment variables
- Set up custom domain (if needed)
- Configure DNS
- Set up CI/CD pipelines
- Create database/cache instances
- Configure secrets management

#### For Apps (feature deployment)
- Verify production environment accessible
- Update environment variables (if needed)
- Minimal — environment already exists

#### For Workflows
- Verify installation target environment
- Install dependencies
- Configure activation hooks
- Set up permissions

#### For Artifacts
- **Skip this phase** — no infrastructure needed

**Agent role:** Execute setup per plan, verify each step.

**Verification:**
- All infrastructure components created
- Configurations applied
- Access credentials work
- Environment ready for deployment

**Exit signal:** Infrastructure verified. Ready to deploy.

---

### 6. Deployment Execution

**Purpose:** Actually deploy/distribute the deliverable to the target environment.

**Approach (project-type specific):**

#### For Apps
- Push to hosting provider (Railway, Vercel)
- Trigger CI/CD pipeline (if configured)
- Monitor deployment progress
- Verify deployment succeeded
- Capture deployment URL

#### For Workflows
- Install workflow in target environment
- Activate workflow
- Configure triggers/schedules
- Verify workflow registered

#### For Artifacts
- Export artifact to final format
- Move to distribution location
- Generate distribution package (if needed)
- Upload to sharing platform (if applicable)

**Skills-based execution:** Use deployment skills from capabilities.md

**Deployment verification:**
- Deployment completed without errors
- Artifact accessible at target location
- Health check passes (if applicable)
- Logs show successful startup

**Exit signal:** Successfully deployed to target environment. Ready for validation.

---

### 7. Validation & Testing

**Purpose:** Confirm the deployed artifact works correctly in its target environment through 3-tier validation.

### Three-Tier Testing Model

Testing depth varies by project type:

| Tier | What | Who/How | When |
|------|------|---------|------|
| **Tier 1: Automated** | Programmatic tests (unit, integration, E2E) | Test frameworks (Jest, Pytest, Playwright) | First — run in production/target environment |
| **Tier 2: Browser/Agent** | Interactive testing, user flows, real-world scenarios | Claude in Chrome, MCP Inspector, browser agents | After Tier 1 passes |
| **Tier 3: Manual** | User acceptance, edge cases, subjective validation | Human testing | After Tier 2 passes |

### Testing by Project Type

| Type | Tier 1 (Automated) | Tier 2 (Browser/Agent) | Tier 3 (Manual) |
|------|-------------------|----------------------|----------------|
| **App (MVP)** | API tests, integration tests, E2E tests in production | Full user flows via Claude in Chrome | User acceptance testing |
| **App (feature)** | Feature-specific tests in production | Feature validation via browser | Smoke test by human |
| **Workflow** | Unit + integration tests in target environment | MCP Inspector (if MCP-based) | Manual trigger test |
| **Artifact** | Format validation, smoke test | None (unless interactive) | Visual inspection, content review |

### Tier 1: Automated Testing

Run automated tests **in the production/target environment**:

**For Apps:**
- API endpoint tests (health checks, auth, core endpoints)
- Integration tests (DB, external services)
- E2E tests via Playwright/Cypress
- Performance/load tests (if applicable)
- Accessibility tests (axe-core)

**For Workflows:**
- Unit tests (core logic)
- Integration tests (external service calls)
- Error handling tests

**For Artifacts:**
- Format validation (schema, structure)
- Content validation (required sections present)
- Export/import tests

**Pass criteria:** 95%+ pass rate minimum. If Tier 1 fails: Fix issues, re-deploy, re-test. Do NOT proceed to Tier 2.

### Tier 2: Browser/Agent Testing

Real-world interactive testing via browser agent:

**For Apps:**
- Navigate full user flows via Claude in Chrome
- Test authentication/authorization
- Test key features interactively
- Verify UI renders correctly
- Test error handling
- Validate accessibility

**For MCP-based Workflows:**
- Test tools via MCP Inspector
- Verify parameters and responses
- Test error cases

**For Artifacts (if interactive):**
- Open/render artifact
- Interact with elements
- Verify functionality

**Pass criteria:** All key user flows complete successfully. No critical bugs. If Tier 2 fails: Fix issues, re-deploy if needed, re-test.

### Tier 3: Manual User Validation

Human testing for subjective validation and edge cases:

**For Apps/MVPs:**
- Walk through core user scenarios manually
- Test edge cases not covered by automation
- Subjective assessment (UX, performance feel)
- Verify non-functional requirements

**For Features:**
- Smoke test the feature
- Verify integration with existing functionality

**For Workflows:**
- Manual trigger test
- Verify expected output/behavior

**For Artifacts:**
- Visual inspection
- Content review for accuracy/completeness
- Format/style validation

**Pass criteria:** Human confirms: "This works and meets success criteria."

### Documentation of Test Results

Create `docs/active/test-results.md` with:
- Tier 1 results (test framework output)
- Tier 2 results (browser test scenarios + outcomes)
- Tier 3 results (manual validation notes)
- Issues found and fixed
- Final validation status

**Exit signal:** All three tiers pass. Human confirms: "Deployed artifact is usable and meets success criteria."

---

### 8. Milestone Closeout

**Purpose:** Structured verification, cleanup, and seal.

**Ordered checklist:**

#### 8.1 Cleanup
- [ ] .gitignore updated (deployment artifacts, temp files)
- [ ] Transient files deleted (deployment logs, temp configs)
- [ ] No secrets in repo
- [ ] No commented-out code blocks

#### 8.2 Success Criteria Gate
- [ ] Load brief.md → success criteria
- [ ] Map each criterion to evidence (feature live, URL, test result)
- [ ] Mark each: met / partial (with explanation) / not met (BLOCKS completion)
- [ ] Document mapping in status.md

#### 8.3 Access Documentation
- [ ] URLs documented (production URL, admin panel, etc.)
- [ ] Access instructions written (how users access the artifact)
- [ ] Credentials documented (if applicable — use secure method)
- [ ] Distribution notes (if artifact is exported/distributed)

Update README or create `docs/ACCESS.md` with:
- Production URL(s)
- How to access (user accounts, credentials, download links)
- Who to contact for access issues

#### 8.4 Artifact Lifecycle
- Keep in `docs/`: intent.md, brief.md, design.md (cross-stage reference)
- Archive to `docs/archive/`: plan.md, BACKLOG.md, manifest.md, capabilities.md, test-results.md
- Keep in project: deliverable, tests, documentation, deployment configs

#### 8.5 Commit Verification
- [ ] No uncommitted changes
- [ ] Commit history shows atomic commits (not one giant commit)

#### 8.6 status.md Update (THE SEAL)
- Mark milestone complete
- Include structured stage handoff (per ADF-STAGES-SPEC.md Stage Boundary Handoff Protocol)
- Document what was delivered and where
- This is the LAST step

**Exit signal:** Milestone sealed in status.md. Increment is live and documented.

---

## Testing Strategy

Testing is not optional. It's core to Deliver.

### Planning-Time Decisions (Phase 2-3)

- plan.md MUST specify testing strategy with 3-tier breakdown
- capabilities.md MUST include testing tools
- If planning doesn't answer these questions, Phase 3 is incomplete:
  - What automated tests run in production?
  - What browser/agent testing is needed?
  - What manual validation scenarios?
  - Who performs manual testing?

### Progressive Testing

Test results feed into each other:
1. Tier 1 must pass before Tier 2 begins
2. Tier 2 must pass before Tier 3 begins
3. Issues found in later tiers trigger fixes and re-testing from Tier 1

**Critical rule:** Do NOT mark validation complete until all three tiers complete with human confirmation.

---

## Commit Cadence

**Hard requirements:**
- Commit after every task completion
- Commit at every phase boundary
- Commit before requesting human input
- Conventional format: `type(scope): description`

---

## Exit Criteria

### Universal Criteria

Per ADF-STAGES-SPEC.md:

- [ ] Primary deliverable(s) exist with required content
- [ ] No Critical or High issues open (post-review)
- [ ] Alignment verified with intent.md and brief.md
- [ ] All work committed (atomic commits, no uncommitted changes)
- [ ] Documentation appropriate to deliverable exists
- [ ] Workspace cleanup complete (no transients, .gitignore current)
- [ ] status.md updated with stage completion (THE SEAL — last step)
- [ ] Human sign-off obtained

### Deliver-Specific Criteria

- [ ] Artifact deployed/distributed to target environment
- [ ] Three-tier testing complete (automated + browser + manual)
- [ ] Access documentation exists (URLs, credentials, instructions)
- [ ] Success criteria from brief.md mapped to evidence (all met)
- [ ] Rollback plan tested or documented

### Type-Specific Criteria

| Type | Additional Criteria |
|------|---------------------|
| **App (MVP)** | Production URL accessible, database configured, CI/CD working |
| **App (feature)** | Feature live in production, integrated with existing app |
| **Workflow** | Installed and activated, triggers working |
| **Artifact** | Exported and distributed, format validated |

**The usability test:** Human can access and use the artifact without assistance. If this fails, Deliver is not done.

---

## Context Loading

### What the Primary Agent Needs

1. **Deliverable + docs** — Built artifact from Develop (consumed)
2. **Design** — Technical specification (referenced for validation)
3. **Brief** — Success criteria (referenced)
4. **Intent** — North Star (referenced)
5. **This spec** — Stage workflow
6. **Current state** — status.md

### Context Map (for CLAUDE.md)

```markdown
## Context Map

| File | Load When | Purpose |
|------|-----------|---------|
| intent.md | Always | North Star |
| brief.md | Deliver stage | Success criteria reference |
| design.md | Deliver stage (validation) | Technical specification |
| docs/active/plan.md | Deliver stage (after created) | Deployment guide |
| BACKLOG.md | Deliver stage (after created) | Task tracking |
| ADF-DELIVER-SPEC-v2.md | Deliver stage (reference) | Stage workflow |
```

---

## Sub-Agent Coordination

Deliver may use sub-agents for parallelization, though less common than in Develop.

### Primary Agent Responsibilities

- Orchestrate deployment workflow
- Coordinate infrastructure setup
- Monitor deployment execution
- Update status.md
- Final validation before milestone seal

### Sub-Agent Responsibilities

- Execute assigned deployment tasks
- Verify task completion
- Mark tasks complete in BACKLOG.md
- Report blockers to primary agent
- Do NOT update status.md

### Parallelization Rules

- Only parallelize independent tasks (e.g., DNS + env vars can happen concurrently)
- Tasks with dependencies execute sequentially (e.g., infrastructure before deployment)
- Primary agent monitors all parallel work
- Deployment and testing are synchronization barriers

---

## References

- ADF-STAGES-SPEC.md (Universal exit criteria, stage boundary handoff)
- ADF-REVIEW-SPEC.md (Review mechanism — cycles, severity, stop conditions)
- ADF-DEVELOP-SPEC-v2.md (Develop is primary input)
- ADF-DESIGN-SPEC-v2.md (Design referenced for validation)
- ADF-BRIEF-SPEC.md (Success criteria reference)
- ADF-INTENT-SPEC.md (North Star reference)
- ADF-PROJECT-TYPES-SPEC.md (Deliverable shape and delivery approach)
- ADF-FOLDER-STRUCTURE-SPEC.md (docs/active/ convention)
- ADF-TAXONOMY.md (Terminology)
