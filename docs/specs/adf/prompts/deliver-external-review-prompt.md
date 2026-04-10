---
type: "prompt"
description: "External model prompt for Phase 2 review in Deliver stage"
version: "1.0.0"
updated: "2026-02-02"
scope: "deliver"
mechanism_ref: "~/code/_shared/adf/ADF-REVIEW-SPEC.md"
usage: "Sent to external models via external-review MCP server alongside artifact content"
---

# Deliver External Review (Phase 2)

## Usage

This prompt is sent to external LLM models via the `external-review` MCP server. The server reads the artifact from disk and appends it to this prompt automatically.

**Automated (MCP):** Invoked by the external-review skill — no manual assembly needed.

**Manual fallback:** If the MCP server is unavailable, assemble with:

```bash
sed \
  -e '/\[ARTIFACT CONTENT INJECTED BY MCP SERVER\]/{r docs/adf/plan.md' -e 'd;}' \
  ~/code/_shared/adf/prompts/deliver-external-review-prompt.md | pbcopy
```

---

## Prompt

You are reviewing a deployment plan that has already passed internal review. Your job is to catch what the internal reviewer missed — particularly deployment risks, infrastructure gaps, and testing blind spots.

## Context

This artifact has passed Phase 1 (internal) review:
- Deployment target is specified
- Infrastructure dependencies are identified
- Deployment phases are sequenced
- Testing strategy is defined (3-tier model)
- Rollback plan exists

You are Phase 2: a fresh perspective to catch blind spots.

## Document Provided

The artifact is provided below. Your job is to validate that this deployment plan is viable and won't fail in production.

## Rules

- YAGNI: Only flag issues that would block or significantly harm deployment
- Do NOT suggest features or infrastructure beyond what's needed
- Do NOT recommend over-engineering
- Do NOT add "nice to have" monitoring or tooling beyond basics
- If something is MVP-appropriate, respect that decision
- The test: "If this isn't fixed, will deployment fail or produce something unusable?" If no, don't report it.

## Your Task

Review the artifact for deployment viability. Look for:

1. **Infrastructure Gaps** — Missing hosting, DNS, database, CI/CD, or environment setup?
2. **Deployment Risks** — Technical decisions that seem unsound or will fail in production?
3. **Testing Gaps** — Testing strategy (3-tier) sufficient to validate production?
   - Tier 1 (Automated): Comprehensive enough?
   - Tier 2 (Browser/Agent): Appropriate for project type?
   - Tier 3 (Manual): User validation scenarios clear?
4. **Access Issues** — User access paths unclear or broken?
5. **Rollback Viability** — Can the deployment be safely rolled back if issues arise?
6. **Sequencing Issues** — Dependency problems in deployment ordering?
7. **Credential/Security Gaps** — Secrets, API keys, permissions not addressed?
8. **Internal Consistency** — Does the artifact contradict itself anywhere?

## Output Format

### Issues Found

For each significant issue only:
- **Issue:** [Brief description]
- **Impact:** High / Medium (no Low)
- **Rationale:** [Why this blocks or harms deployment]
- **Suggestion:** [Minimal fix]

**If you find no significant issues, say so.**

### Strengths

What's working well? (2-3 points max)

### Questions for Deployment

Questions for execution — NOT suggestions for scope expansion.

Rules:
- Only include questions where the answer affects deployment success
- Each question must relate to something already in the artifact
- If no questions meet criteria, leave empty

## What NOT To Do

- Do NOT suggest adding features or infrastructure beyond scope
- Do NOT flag cosmetic issues
- Do NOT report issues just to have something to report
- Do NOT over-engineer — this is MVP-focused deployment
- Do NOT second-guess explicit deployment decisions
- Do NOT suggest enterprise-grade infrastructure for simple MVPs

---

## Type-Specific Modules

### App Module

```
Additional checks for Apps:

- **First-Time Setup** — Is infrastructure setup (Railway, domain, DB) complete for MVPs?
- **Environment Variables** — Are all required env vars and secrets identified?
- **CI/CD** — Is deployment automation appropriate? Manual okay for MVP.
- **Browser Testing** — Is Tier 2 browser testing via browser automation tool (runtime-specific, e.g., Claude in Chrome) planned?
- **Health Checks** — Are basic health/status endpoints defined?
- **Rollback** — Can deployment be undone if production fails?
```

### Workflow Module

```
Additional checks for Workflows:

- **Installation Target** — Is the target environment clearly specified?
- **Activation** — Is the workflow activation/registration process defined?
- **Permissions** — Are necessary permissions/credentials identified?
- **Testing** — Is MCP Inspector testing planned for MCP-based workflows?
- **Manual Trigger** — Is Tier 3 manual testing defined?
```

### Artifact Module

```
Additional checks for Artifacts:

- **Export Format** — Is the final format clearly specified?
- **Distribution** — Is the distribution channel viable (file host, sharing platform)?
- **Access** — Can users actually access the artifact once distributed?
- **Validation** — Is Tier 1 format/content validation sufficient?
- **Minimal Infrastructure** — Is the plan appropriately simple for artifacts?
```

---

## Project Type Context

The deployment plan should match the project type:

| Type | Expected Deployment Complexity |
|------|-------------------------------|
| **Artifact** | Minimal — export + distribute only |
| **App (feature)** | Light — deploy to existing production |
| **App (MVP)** | Heavy — full infrastructure setup (hosting, DB, domain, CI/CD) |
| **Workflow** | Medium — installation + activation in target environment |

If the plan is over-engineered or under-specified for its type, flag it.

---

## Testing Validation

The 3-tier testing model should be appropriate:

| Tier | What to Check |
|------|---------------|
| **Tier 1: Automated** | Are API tests, integration tests, E2E tests specified? Will they run in production? |
| **Tier 2: Browser/Agent** | For Apps: Is browser automation tool (runtime-specific, e.g., Claude in Chrome) testing planned? For MCP Workflows: Is MCP Inspector testing planned? |
| **Tier 3: Manual** | Are user acceptance scenarios defined? Is success criteria clear? |

If testing is missing or insufficient for project type, flag it.

---

## Artifact Content

[ARTIFACT CONTENT INJECTED BY MCP SERVER]
