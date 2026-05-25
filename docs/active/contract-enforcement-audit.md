---
type: "audit-report"
title: "Per-Project Contract Enforcement Audit"
status: "draft"
updated: "2026-05-25"
owner: "unassigned"
---

# Per-Project Contract Enforcement Audit

> DRAFT. Scope: existing enforcement tooling only. Goal: identify what can already check the per-project contract, what is already scheduled or wired, and the smallest owner/schedule/wiring actions needed to make the contract durable.

## Sources Checked

- `docs/standards/project-layout.yaml`
- `docs/standards/artifact-frontmatter.yaml`
- `docs/standards/session-lifecycle.yaml`
- `docs/active/per-project-contract-proposal.md`
- `docs/active/baseline-audit-2026-04-09.md`
- `docs/active/portfolio-map.md`
- `docs/decisions/ADR-001-aws-governance-activation.md`
- `docs/decisions/ADR-006-north-star-capture-and-resolver.md`
- `~/code/tools/ai-dev/skills/project-doctor/`
- `~/code/_shared/aws/docs/specs/adf/skills/project-health/`
- `~/code/_shared/aws/scripts/`
- `~/code/_shared/nerve-center/config/jobs.yaml`
- `~/code/_shared/nerve-center/packages/core/probes/probe-artifact-health.sh`
- `~/Library/LaunchAgents/com.laptop.artifact-health.plist`
- `~/Library/LaunchAgents/com.aws.il-lint-sweep.plist`
- `~/Library/LaunchAgents/com.aws.il-classifier-sweep.plist`
- recent logs under `~/.nerve-center/logs/` and `~/.logs/`

## Summary

The harness is partially in place. The strongest existing pieces are:

- `project-doctor` as the standards-aware per-project audit engine.
- `probe-artifact-health.sh` as the actually scheduled nightly portfolio sweep.
- `il-classifier.sh` as the working hot-buffer router for `decisions.md`/`lessons.md`/`captures.md`.
- `project-health --scope freshness` and `adf-stage` as stage-gate doc freshness checks.

The gap is not lack of tooling. The gap is that the newly agreed contract is not fully encoded in the standards or the scheduled probe:

- `decisions.md` and `AGENTS.md` are still "recommended" in `project-layout.yaml` / `project-doctor`, not required.
- owner is recommended in artifact frontmatter but not required on the canonical project context file.
- resolver entry existence is proposed but not implemented as a machine-checked registry contract.
- status freshness is checked today, but with inconsistent thresholds and mechanisms: `project-doctor` says 7 days from frontmatter; artifact-health checks status file mtime against last commit and flags >14 days; the new contract asks for <30 days.
- no current recurring portfolio job was found that runs full `project-doctor` across the repo set. ADR-001 mentions `baseline-audit.sh` and a nightly launchd job as Day 2 work, but I did not find a current `baseline-audit.sh` file.

Uncertainty: `launchctl list` did not show the artifact/IL launchd labels in this shell, but logs prove `artifact-health` ran nightly through 2026-05-24 and `il-lint-sweep` ran weekly on 2026-05-24.

## Contract Enforcement Matrix

| Contract element | Existing tool/job that can check/enforce it | Currently scheduled/wired? | Gap | Recommended wiring |
|---|---|---|---|---|
| 1. Owner field present in each project's canonical context file | Partial: `artifact-frontmatter.yaml` recommends `owner` for `intent.md`, `design.md`, and ADRs. `portfolio-map.md` tracks owner-like fields. `per-project-contract-proposal.md` says canonical context should expose owner/sync target, with AGENTS.md as the decided canonical file and CLAUDE.md importing it. | No direct scheduled check found. `project-doctor` does not currently check owner in `AGENTS.md`/`CLAUDE.md`. `probe-artifact-health.sh` does not check owner. | Owner is a policy/design proposal, not an enforced machine check. Existing standards also conflict: `project-layout.yaml` still says `AGENTS.md` is a Codex mirror of `CLAUDE.md`, while the proposal says AGENTS.md is canonical. | Owner: Forge for standard/tool updates; PMO/Krypton for triage. Schedule: add to weekly full contract audit; optionally add a nightly lightweight `artifact-health` check. Failure action: NC/YELLOW finding tagged `missing-project-owner`; assigned project PM or PMO must add/confirm `owner:` in canonical context within 7 days. |
| 2. `decisions.md` present and actually used as decision ledger | Partial: `project-layout.yaml` recommends `decisions.md` or `docs/decisions/`; `project-doctor` notes missing `decisions.md` as recommended/non-blocking; `adf-init` creates `decisions.md`; ADF specs and ADR skill define decision logging; `il-classifier.sh` discovers and routes `decisions.md` entries to Memory; `il-lint-sweep.sh` counts `decisions.md` entries for hot-buffer context. | Partially wired. `il-classifier` is scheduled every 4h via `com.aws.il-classifier-sweep` and recent logs show it processing decisions/lessons/captures. No scheduled job requires `decisions.md` to exist or validates that it is non-stub/current. | Presence is not required. "Actually used" is not checked. A project can pass required-artifact checks without a decision ledger; an empty/stub ledger is not distinguished from a real ledger. | Owner: Forge encodes requirement; PMO/Krypton reviews exceptions; project PM remediates. Schedule: weekly `project-doctor --contract` portfolio audit plus existing 4h IL classifier. Failure action: missing ledger = NC/YELLOW finding + create/backlog remediation; unused ledger = NC/BLUE or YELLOW depending active project status, requiring either append current decisions or mark project paused/no decisions. |
| 3. `status.md` freshness < 30 days | Strong but inconsistent: `project-doctor` checks `status.md` `updated` freshness at 7 days from `artifact-frontmatter.yaml`; `probe-artifact-health.sh` checks `status.md` exists and flags if status mtime is >14 days older than last git commit; archived `probe-session-discipline.sh` checked status updated frontmatter and session recency; `project-health` checks doc freshness for root/docs artifacts but is broader than status. | Yes for artifact-health. `com.laptop.artifact-health.plist` runs daily at 22:15. Logs show nightly runs through 2026-05-24 with stale status findings. `project-doctor` appears available on demand and used for the 2026-04-09 baseline audit, but no current recurring full project-doctor job was found. | Threshold mismatch: contract says <30 days; `project-doctor` says 7 days; artifact-health uses mtime-vs-last-commit and 14 days, not frontmatter age. The scheduled check can miss stale-but-unchanged paused projects and can overfocus on commit-relative drift. | Owner: Forge updates thresholds/check semantics; PMO/Krypton owns weekly review; project PM owns remediation. Schedule: keep nightly artifact-health but align threshold to 30d for active projects using `updated:` frontmatter where present; run weekly full audit for canonical report. Failure action: nightly warning to NC; project PM must refresh `status.md`, mark project paused/archived, or explain no-op in `status.md`. |
| 4. Resolver entry exists | Partial concept only: `portfolio-map.md` functions as a draft/global index with path, owner, stage, freshness, workstream context; `per-project-contract-proposal.md` defines minimum resolver entry schema: path, owner, stage, canonical-context-file, status-file, portfolio-row, freshness-threshold. ADR-006 uses "resolver" for AWS North Star re-grounding, not as a general portfolio resolver implementation. | No machine-enforced resolver-entry check found. `portfolio-map.md` exists and was generated/curated, but no scheduled validator was found that ensures every project has a row with required resolver fields. | Resolver is not yet a formal schema or canonical machine-readable file. The current `portfolio-map.md` is useful operating context but not enough for durable enforcement. | Owner: Forge for resolver schema/check; Krypton or PMO for portfolio index authority. Schedule: weekly resolver reconciliation job after project-contract audit. Failure action: NC/YELLOW `missing-resolver-entry`; PMO/Krypton adds or corrects the resolver row, or explicitly marks project out of scope. |
| 5. Required artifact set present: `intent`, `status`, `BACKLOG`, `lessons`, `CLAUDE` + `AGENTS` | Strong for old set: `project-layout.yaml` requires `intent.md`, `status.md`, `BACKLOG.md`, `lessons.md`, `CLAUDE.md`, `docs/active/`; `project-doctor` checks those plus frontmatter/freshness; `probe-artifact-health.sh` checks a subset across 15 projects nightly. `adf-init` creates AGENTS/CLAUDE/intent/BACKLOG/status/decisions/lessons/captures/README. | Partially scheduled. Artifact-health runs nightly and checks CLAUDE/status/BACKLOG/lessons, but not intent, AGENTS, decisions, resolver, owner, or docs/active. `project-doctor` covers more but recurring schedule was not found. | Required set is not the new contract set. `AGENTS.md` is only recommended today. `docs/active/` is required in project-layout but not artifact-health. `intent.md` is required in project-layout/project-doctor but not artifact-health. `decisions.md` is recommended. | Owner: Forge updates `project-layout.yaml` and `project-doctor`; PMO/Krypton owns recurring review queue. Schedule: weekly full `project-doctor` portfolio audit; nightly artifact-health remains a fast drift probe. Failure action: missing hard-required artifact = NC/YELLOW or RED for active projects; auto-create only safe scaffolds after human/Forge approval; otherwise file remediation to project BACKLOG. |

## Existing Tooling Notes

### `project-layout.yaml`

Current required artifacts:

- `intent.md` with `docs/intent.md` accepted as alt path.
- `status.md` with `docs/status.md` accepted as alt path.
- `BACKLOG.md`.
- `lessons.md` with `docs/lessons.md` accepted as alt path.
- `CLAUDE.md`.
- `docs/active/`.

Current recommended artifacts:

- `decisions.md` or `docs/decisions/`.
- `AGENTS.md`.

Implication: the new contract cannot be enforced until this standard changes or a separate contract overlay is added.

### `project-doctor`

`project-doctor` is the right enforcement engine to reuse. It already reads AWS standards and checks:

- required artifact presence;
- CLAUDE.md conformance;
- artifact frontmatter;
- freshness thresholds;
- lessons.md size;
- recommended `decisions.md` / `AGENTS.md` presence.

It has fix mode for safe scaffolds, but stale artifacts and lessons promotion are report-only. That is appropriate. The needed change is to add a "contract" profile or update standards so the tool treats owner, AGENTS, decisions, resolver, and 30-day status freshness as first-class checks.

### `probe-artifact-health.sh`

This is the only clearly active scheduled portfolio artifact-health sweep found. It checks 15 hardcoded projects and flags:

- missing/bloated CLAUDE.md;
- missing/stale/bloated status.md;
- missing BACKLOG.md as WARN;
- missing/bloated lessons.md.

It deliberately removed the `decisions.md` check on 2026-04-11 because decisions were not in the standard then. That is now stale relative to the new proposed contract.

Logs show it ran on 2026-05-21, 2026-05-22, 2026-05-23, and 2026-05-24. On 2026-05-24 it found 17 issues across 15 projects, including stale status files and missing lessons/backlog. Slack notification was skipped that night because `SLACK_WEBHOOK` was not set.

### Nerve Center jobs

`jobs.yaml` does not currently include `artifact-health`; it says `artifact-health` moved to laptop launchd at 22:15. Archived jobs include `session-discipline` and `backlog-health`; the archive says `session-discipline` was noisy/limited value.

Implication: the contract should not depend on old NC YAML job names unless they are restored. The active route is launchd -> probe -> NC/log/Slack wrapper.

### IL classifier and IL lint sweep

`il-classifier.sh` is active and useful for durability after decisions/lessons exist. It discovers `captures.md`, `lessons.md`, and `decisions.md`, routes entries to KB/Memory, and logs every 4h sweep.

`il-lint-sweep.sh` runs weekly and checks KB/Memory contradictions, stale entries, boundary violations, orphaned entries, and hot-buffer overflow. It does not enforce per-project artifact contracts, but it helps keep the downstream knowledge stores healthy.

## Smallest Wiring Set

Do these in order, reusing what exists:

1. Assign enforcement ownership:
   - Forge owns standards/tooling changes (`project-layout.yaml`, `project-doctor`, artifact-health probe).
   - PMO/Krypton owns weekly review/triage of contract findings.
   - Project PM owns remediation inside each project.

2. Make one standard update or overlay:
   - Encode the active-project contract in `project-layout.yaml` v1.2.0 or a narrow `project-contract` overlay.
   - Required checks: `AGENTS.md` canonical context, owner field, `decisions.md`, resolver entry, status freshness <30 days, existing artifact set.
   - Preserve exceptions for paused/archived projects.

3. Wire `project-doctor` as the weekly full audit:
   - Schedule weekly portfolio run.
   - Output a dated report under `aws/docs/active/` or `~/.logs/`.
   - Emit NC/YELLOW findings for missing required contract elements.
   - Do not autofix without approval.

4. Update nightly `artifact-health` as the fast drift probe:
   - Add owner, AGENTS, intent, decisions, resolver-entry checks.
   - Align status freshness to the new 30-day active-project threshold.
   - Keep output terse: only DRIFT/WARN lines.

5. Keep IL jobs as downstream durability:
   - `il-classifier` remains the route for decisions/lessons once present.
   - `il-lint-sweep` remains weekly KB/Memory hygiene.
   - Do not treat IL jobs as contract enforcement; they are post-capture hygiene.

6. Define failure handling:
   - Missing owner/resolver/required artifact on active project: NC/YELLOW, assigned to PMO/Krypton for routing within 48h.
   - `status.md` >30 days stale: NC/YELLOW, assigned to project PM; action is refresh, mark paused/archived, or document why no update is needed.
   - Missing `decisions.md`: NC/YELLOW; create ledger scaffold through Forge/project PM.
   - Empty/unused `decisions.md`: NC/BLUE for inactive projects, NC/YELLOW for active projects; owner must either add current decisions or mark "no material decisions yet" with date.

## Bottom Line

The process answer is: use `project-doctor` for the weekly full contract audit, use `artifact-health` for nightly drift warnings, and route failures through NC to the project PM/PMO with explicit action requirements. The harness exists in pieces; the contract is not self-enforcing until the new requirements are encoded in `project-layout.yaml`/`project-doctor` and the launchd artifact-health probe is updated to match.
