---
type: "plan"
description: "90-day non-breaking roadmap to leverage Codex for ADF execution quality"
version: "1.0.0"
updated: "2026-02-10"
scope: "adf"
lifecycle: "planning"
location: "adf/docs/inbox/adf-codex-90-day-roadmap-2026-02-10.md"
---

# Codex Leverage Plan for ADF (90 Days, Non-Breaking)

## Summary
Use Codex to improve **ADF execution quality** first, while keeping Claude compatibility and existing MCP interfaces stable.
This aligns with `AGENTIC-WORK-SYSTEM-ARCHITECTURE.md` by strengthening ADF's Operations-layer reliability and ring coverage (especially Control/Observability), and preparing cleaner upstream handoffs to Management/Governance layers later.

## Architecture Alignment (Current State vs Target)

### Current (from repo + architecture docs)
1. ADF is positioned as an Operations-layer process engine (`ADF-ARCHITECTURE-SPEC.md`).
2. Codex coexistence exists at Phase 1 (`AGENTS.md`, `ADF-CODEX-COMPAT-SPEC.md`).
3. MCP server is read-only and stable, but still has legacy schema assumptions (`claude_md`, `docs/brief.md` expectations in project/orchestration tools).
4. Backlog already flags missing maintenance/health surfaces (`B36`, `B75`, `B77`, `B81`, `B82`).

### 90-day target
1. Codex becomes first-class for **quality enforcement and execution reliability**.
2. ADF ring implementation improves in:
   - Control ring: stricter contract checks, runtime-aware validation.
   - Observability ring: measurable quality telemetry and drift detection outputs.
   - Knowledge ring: tighter capture of fixes/findings into KB and backlog.
3. No breaking MCP API changes; aliases and compatibility shims only.

## Workstreams and Milestones

## Phase 1 (Days 1-30): Stabilize Execution Contracts

### WS1: Runtime-Aware Project Health (non-breaking)
1. Extend `check_project_structure` and `check_project_health` logic to accept either:
   - Claude context contract (`.claude/CLAUDE.md`)
   - Codex context contract (`AGENTS.md`)
2. Keep existing outputs, but add explicit runtime findings sections:
   - `Runtime Contract Check`
   - `Context Artifact Compatibility`
3. Keep existing required artifact checks; add compatibility handling for `docs/discover-brief.md` vs `docs/brief.md` in validation paths.

Deliverables:
1. Updated `adf-server/src/tools/project.ts`
2. Added/updated tests in `adf-server/src/tools/__tests__/project.test.ts`
3. Spec note in `ADF-CODEX-COMPAT-SPEC.md` clarifying health-check behavior.

### WS2: Transition Validation Reliability
1. Update transition validation in orchestration tooling to support current ADF artifact conventions (`discover-brief` fallback already conceptually expected by project usage).
2. Ensure validation failures are deterministic and actionable (single error taxonomy).

Deliverables:
1. Updated `adf-server/src/tools/orchestration.ts`
2. Tests in `adf-server/src/tools/__tests__/orchestration.test.ts` aligned to real artifact paths.

### WS3: Codex-First Ops Runbook
1. Create a concise runbook for using Codex during ADF stage execution:
   - startup context sequence
   - phase boundary behavior
   - review loop execution expectations
   - quality gates and when to escalate to human
2. Keep it additive (no contract replacement).

Deliverables:
1. `docs/adf/codex-operations-runbook.md`
2. Link from `AGENTS.md` and `README.md`.

Phase 1 acceptance criteria:
1. `adf-server` tests pass consistently in-repo.
2. Health/transition checks no longer fail due to expected ADF path variants.
3. Codex execution runbook is present and referenced.

## Phase 2 (Days 31-60): Control + Observability Ring Hardening

### WS4: Add Non-Breaking MCP Compatibility Aliases (B81/B82)
1. Add additive aliases only:
   - `context_md` alias for `claude_md` inputs where applicable.
   - neutral context-spec alias while preserving `get_context_spec`.
2. Mark old names as "supported legacy" in docs, not deprecated yet.

Deliverables:
1. `adf-server/src/tools/artifacts.ts` alias support
2. `adf-server/src/tools/governance.ts` additive naming support
3. Tests covering both old/new names.

### WS5: Structured Quality Telemetry for ADF Checks
1. Add machine-readable check summary blocks to project health/structure outputs:
   - counts by category
   - pass/fail by contract type
   - drift flags
2. Keep existing human-readable output unchanged; append structured section.

Deliverables:
1. Output contract update docs in `adf-server/README.md`
2. Regression tests for output schema stability.

### WS6: Drift Sentinel for Specs vs Runtime Contracts
1. Add a non-mutating script that verifies alignment among:
   - `AGENTS.md`
   - `.claude/CLAUDE.md` requirements in specs
   - MCP health tool assumptions
   - scaffold outputs (`scripts/init-project.sh`, `stubs/`)
2. Report only; no auto-fix in this phase.

Deliverables:
1. `scripts/check-runtime-contract-drift.sh`
2. CI/local check command documented in `scripts/README.md`.

Phase 2 acceptance criteria:
1. Old and new MCP contract names both pass tests.
2. Health tools emit stable structured summaries.
3. Drift check script catches at least known mismatch classes (path, naming, required files).

## Phase 3 (Days 61-90): Codex as Quality Engine

### WS7: Codex Review Mode for ADF Repo
1. Define Codex-specific review protocol for this framework repo:
   - prioritize regressions in stage gates, context contracts, and MCP API stability
   - standardized findings format mapped to backlog triage
2. Integrate with existing review artifacts (no replacement of Ralph/external flow).

Deliverables:
1. `docs/adf/codex-review-protocol.md`
2. Link from `AGENTS.md` and `ADF-REVIEW-SPEC.md` references section.

### WS8: Backlog Automation for Detected Contract Drift
1. Add rules for when Codex findings should auto-create backlog entries vs comments-only.
2. Target high-value classes:
   - spec/implementation mismatch
   - runtime contract break risk
   - validation false negatives/positives

Deliverables:
1. `docs/adf/codex-backlog-triage.md`
2. Backlog label conventions for Codex-detected issues.

### WS9: System-Architecture Handoff Readiness
1. Produce a mapping appendix from ADF execution improvements to system rings/layers:
   - Control ring: enforced contracts
   - Observability ring: measurable check outputs
   - Knowledge ring: captured learnings
2. Explicitly define what is now ready to feed Work Management layer.

Deliverables:
1. `docs/reports/adf-codex-execution-readiness-90d.md`
2. Update `docs/ecosystem-architecture.md` with a short "ADF readiness signals" section.

Phase 3 acceptance criteria:
1. Codex review protocol is operational and referenced by runtime docs.
2. Contract-drift findings can be consistently triaged into backlog.
3. ADF emits clear readiness signals for system-level integration.

## Public APIs / Interfaces (Important)
No breaking changes in this plan.

Additions:
1. Additive MCP aliases for context naming (`context_md` etc.) while preserving existing interfaces.
2. Optional structured summary section in health/structure outputs (append-only).
3. New docs/scripts/runbooks for Codex execution quality.

Unchanged:
1. Existing MCP tool names and behavior remain valid.
2. Claude compatibility contracts remain supported.
3. Stage semantics and review model remain intact.

## Test Cases and Scenarios

### Core regression set
1. Existing Claude-oriented project passes health checks.
2. Codex-oriented project with `AGENTS.md` passes health checks.
3. Dual-runtime project passes health checks.

### Transition validation set
1. Project with `docs/discover-brief.md` validates discover→design transition.
2. Project with legacy `docs/brief.md` still validates.
3. Missing brief returns deterministic actionable error.

### MCP alias compatibility set
1. `claude_md` path continues to work unchanged.
2. New alias path works identically.
3. Output parity assertions between legacy and alias inputs.

### Drift detection set
1. Script detects mismatch between scaffold outputs and health checker assumptions.
2. Script detects naming mismatch between compat spec and tool schema assumptions.
3. Script exits non-zero on drift conditions and provides clear diff hints.

## Assumptions and Defaults
1. Priority is execution quality inside ADF, not Work OS/Krypton buildout.
2. Non-breaking compatibility is mandatory for this 90-day window.
3. Codex is leveraged as a quality/reliability engine, not as a replacement for existing review mechanisms.
4. Backlog items `B81` and `B82` are in scope as additive compatibility work, not deprecations.
5. Historical backlog text may remain historical; only active runtime contracts must be normalized and enforceable.
