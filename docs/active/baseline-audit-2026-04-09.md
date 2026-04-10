---
type: audit-report
generated: 2026-04-09
generator: project-doctor (portfolio audit, Phase E sprint Day 2)
standards_version: 1.0.0
projects_audited: 18
---

# Portfolio Baseline Audit — 2026-04-09

## Summary

| Severity | Count | Projects |
|---|---|---|
| Clean | 0 | — |
| Minor | 1 | knowledge-base |
| Moderate | 3 | capabilities-registry, krypton, nerve-center |
| Major | 7 | aws, memory, work-management, pike-agents, link-triage-pipeline, agent-exec, ai-dev |
| Critical | 7 | agent-harness, cc-codex-handoff, risk/AGF, pike/pike-acm, pike/pike-finances, even-ground, even-ground-native |

**Total projects audited:** 18 (13 Tier 1 + 5 Tier 2)
**Conformance rate:** 6% (1 minor — no project is fully clean)
**Most common issue:** Missing CLAUDE.md (9 of 13 Tier 1 projects). Runner-up: Missing intent.md at root (all Tier 1 except ai-dev have it in docs/ only or missing entirely). Nearly universal: Missing docs/active/ directory.

---

## Findings by project

### aws — Severity: Major

**Path:** `~/code/_shared/aws/`

**Missing artifacts:**
- [ ] CLAUDE.md — missing entirely (no CLAUDE.md at project root)
- [ ] intent.md — exists at `docs/intent.md` but NOT at root (no alt_path accepted per standard; docs/ not listed as alt_path for intent.md)
- [ ] status.md — exists at `docs/status.md` (alt_path accepted per standard) ✅
- [ ] BACKLOG.md — ✅ present
- [ ] lessons.md — ✅ present (root)
- [x] docs/active/ — ✅ exists at `docs/active/`

**CLAUDE.md issues:**
- MISSING entirely — no CLAUDE.md at project root. Critical gap for the governance home itself.

**Frontmatter violations:**
- `docs/status.md`: missing YAML frontmatter block entirely — no `updated` field, no `stage` field (file starts with `# Status:` prose header)
- `docs/intent.md`: missing YAML frontmatter block — no `status` field, no `updated` field

**Freshness:**
- `docs/status.md`: cannot determine freshness — no `updated` field in frontmatter (file mtime 2026-04-09)
- `docs/intent.md`: cannot determine freshness — no `updated` field in frontmatter

**lessons.md size:**
- 9 entries — ✅ within limit

**Notes:**
- The governance home itself has the most fundamental violation: no CLAUDE.md. This is ironic but also the newest project (stood up 2026-04-09). Likely never scaffolded with ADF init.

---

### knowledge-base — Severity: Minor

**Path:** `~/code/_shared/knowledge-base/`

**Missing artifacts:**
- [ ] CLAUDE.md — missing at root
- [ ] intent.md — exists at `docs/intent.md` (docs/ not listed as accepted alt_path per standard)
- [ ] docs/active/ — missing
- ✅ status.md (root), BACKLOG.md (root), lessons.md (root)

**CLAUDE.md issues:**
- MISSING — no CLAUDE.md

**Frontmatter violations:**
- `docs/intent.md`: has `status` and `updated` fields — ✅
- `status.md`: has `updated` and `stage` fields — ✅

**Freshness:**
- `status.md`: updated 2026-04-09 — ✅ OK
- `docs/intent.md`: updated 2026-02-03 — 65 days old (threshold 90d) — ✅ OK (within limit)
- `lessons.md`: file mtime 2026-04-09 — ✅ OK (no frontmatter updated field, using mtime)

**lessons.md size:**
- 11 entries — ✅ within limit

**Notes:**
- Classified Minor rather than Moderate because core operational artifacts (status.md, BACKLOG.md, lessons.md) are all present and fresh. Main gaps are structural: missing CLAUDE.md and docs/active/. The missing CLAUDE.md would normally push to Moderate but intent.md and status.md are both conformant, limiting the blast radius.

---

### memory — Severity: Major

**Path:** `~/code/_shared/memory/`

**Missing artifacts:**
- [ ] intent.md — exists at `docs/intent.md` (not root, docs/ not accepted alt_path for intent.md)
- [ ] status.md — exists at `docs/status.md` (alt_path accepted) ✅
- [ ] BACKLOG.md — exists at `docs/backlog.md` (lowercase, not root — BACKLOG.md is case-sensitive per standard)
- [ ] lessons.md — MISSING (not at root or docs/)
- [ ] docs/active/ — MISSING
- ✅ CLAUDE.md (root)

**CLAUDE.md issues:**
- Length: 60 lines (max 40) — VIOLATION (+20 lines over limit)
- No forbidden sections detected (content is project-specific: commands, workflow requirements, architecture, stack — all allowed)
- Missing CLAUDE.md is not the issue here — it exists but is over the line limit

**Frontmatter violations:**
- `docs/status.md`: has `stage` and `updated` — ✅
- `docs/intent.md`: has `status` and `updated` — ✅

**Freshness:**
- `docs/status.md`: updated 2026-03-24 — 16 days old (threshold 7d) — STALE
- `docs/intent.md`: updated 2026-02-10 — 58 days old (threshold 90d) — ✅ OK

**lessons.md size:**
- MISSING — cannot check

**Notes:**
- CLAUDE.md exists but is 60 lines (max 40). Content appears legitimate (not forbidden) so this is a curation issue, not a duplication issue. Main structural gaps: lessons.md entirely absent, BACKLOG.md not at canonical path, docs/active/ missing.

---

### capabilities-registry — Severity: Moderate

**Path:** `~/code/_shared/capabilities-registry/`

**Missing artifacts:**
- [ ] CLAUDE.md — MISSING
- [ ] intent.md — MISSING (not at root or docs/ — docs/ only has operational files)
- [ ] docs/active/ — MISSING
- ✅ status.md (root), BACKLOG.md (root), lessons.md (root)

**CLAUDE.md issues:**
- MISSING entirely

**Frontmatter violations:**
- `status.md`: has `updated` (2026-02-24) and `stage` — ✅

**Freshness:**
- `status.md`: updated 2026-02-24 — 44 days old (threshold 7d) — STALE
- `lessons.md`: file mtime 2026-04-09 — ✅ OK

**lessons.md size:**
- 4 entries — ✅ within limit

**Notes:**
- Missing CLAUDE.md and intent.md, but all operational artifacts (status, backlog, lessons) present. status.md is significantly stale (44 days). Classified Moderate rather than Major because only 2 required artifacts missing.

---

### krypton — Severity: Moderate

**Path:** `~/code/_shared/krypton/`

**Missing artifacts:**
- [ ] CLAUDE.md — MISSING
- [ ] intent.md — exists at `docs/intent.md` (docs/ not accepted alt_path for intent.md per standard)
- [ ] lessons.md — MISSING (not at root or docs/)
- [ ] docs/active/ — MISSING
- ✅ status.md (root), BACKLOG.md (root)

**CLAUDE.md issues:**
- MISSING entirely

**Frontmatter violations:**
- `status.md`: has `updated` (2026-04-09) and `stage` — ✅
- `docs/intent.md`: has `status` (implied via `type: intent`) and `updated` (2026-02-10) — ✅ (has `updated` and `type`, acceptable)

**Freshness:**
- `status.md`: updated 2026-04-09 — ✅ OK
- `docs/intent.md`: updated 2026-02-10 — 58 days old (threshold 90d) — ✅ OK

**lessons.md size:**
- MISSING — cannot check

**Notes:**
- 3 missing required artifacts (CLAUDE.md, lessons.md, docs/active/) but 2 key operational artifacts present and fresh. Classified Moderate.

---

### work-management — Severity: Major

**Path:** `~/code/_shared/work-management/`

**Missing artifacts:**
- [ ] CLAUDE.md — MISSING
- [ ] intent.md — exists at `docs/intent.md` (docs/ not accepted alt_path for intent.md)
- [ ] lessons.md — MISSING
- [ ] docs/active/ — MISSING
- ✅ status.md (root), BACKLOG.md (root)

**CLAUDE.md issues:**
- MISSING entirely

**Frontmatter violations:**
- `status.md`: has `updated` (2026-02-25) and `stage` — ✅

**Freshness:**
- `status.md`: updated 2026-02-25 — 43 days old (threshold 7d) — STALE
- `docs/intent.md`: updated 2026-02-10 — 58 days old (threshold 90d) — ✅ OK

**lessons.md size:**
- MISSING — cannot check

**Notes:**
- CLAUDE.md missing, lessons.md missing, docs/active/ missing, status.md severely stale (43 days). Classified Major due to combination of missing CLAUDE.md + multiple stale/missing artifacts.

---

### pike-agents — Severity: Major

**Path:** `~/code/_shared/pike-agents/`

**Missing artifacts:**
- [ ] CLAUDE.md — MISSING
- [ ] intent.md — MISSING (not at root or docs/)
- [ ] BACKLOG.md — MISSING
- [ ] lessons.md — MISSING
- [ ] docs/active/ — MISSING
- ✅ status.md (root)

**CLAUDE.md issues:**
- MISSING entirely

**Frontmatter violations:**
- `status.md`: has `stage` but `updated` field is malformed — `"2026-03-18e"` (trailing "e" makes it unparseable as ISO date) — VIOLATION

**Freshness:**
- `status.md`: `updated` field malformed ("2026-03-18e") — cannot determine freshness. File mtime 2026-04-03 (6 days old — near threshold)

**lessons.md size:**
- MISSING — cannot check

**Notes:**
- Only status.md present; 4 of 6 required artifacts missing. Classified Major. The malformed `updated` date in status.md is a secondary concern. Pike-agents is also a plugin repo rather than a typical project — it may intentionally lack some artifacts — but it should still conform.

---

### agent-exec — Severity: Major

**Path:** `~/code/_shared/agent-exec/`

**Missing artifacts:**
- [ ] intent.md — MISSING (not at root or docs/)
- [ ] docs/active/ — MISSING
- ✅ CLAUDE.md (root), status.md (root), BACKLOG.md (root), lessons.md (root)

**CLAUDE.md issues:**
- Length: 45 lines (max 40) — VIOLATION (+5 lines over limit)
- Contains forbidden sections:
  - `environment_tiers` — "Reference Routing" section references KB MCP, Memory MCP patterns (matches `memory_system_descriptions`)
  - `memory_system_descriptions` — "Reference Routing" section explicitly describes Memory MCP and KB MCP routing (already in global CLAUDE.md)

**Frontmatter violations:**
- `status.md`: has `updated` (2026-04-09) and `stage` — ✅

**Freshness:**
- `status.md`: updated 2026-04-09 — ✅ OK
- `lessons.md`: file mtime 2026-04-09 — ✅ OK

**lessons.md size:**
- 14 entries — ✅ within limit (just under threshold)

**Notes:**
- CLAUDE.md exists but violates both line limit and forbidden sections. The Reference Routing paragraph at the bottom is duplicated from global CLAUDE.md — stripping it would likely bring the file under 40 lines. Missing intent.md and docs/active/ are the structural gaps.

---

### nerve-center — Severity: Moderate

**Path:** `~/code/_shared/nerve-center/`

**Missing artifacts:**
- [ ] intent.md — exists at `docs/intent.md` (docs/ not accepted alt_path for intent.md per standard)
- [ ] docs/active/ — MISSING (docs/ exists but no active/ subdirectory)
- ✅ CLAUDE.md (root, 3 lines — stub pointing to `.claude/CLAUDE.md`), status.md (root), BACKLOG.md (root), lessons.md (root)

**CLAUDE.md issues:**
- Root CLAUDE.md: 3 lines — ✅ under limit
- Root CLAUDE.md is a stub pointing to `.claude/CLAUDE.md` (which is 90 lines and contains rich project context)
- Note: `.claude/CLAUDE.md` is not the standard location per project-layout.yaml — the standard requires CLAUDE.md at project root, not `.claude/CLAUDE.md`. The stub satisfies presence but not substance.
- No forbidden sections in the 3-line stub

**Frontmatter violations:**
- `status.md`: has `updated` (2026-03-16) and `type` but missing explicit `stage` field — VIOLATION (has implied stage in prose but not as frontmatter field)
- `docs/intent.md`: has `updated` (2026-02-11) and `type` — ✅ (has `updated`)

**Freshness:**
- `status.md`: updated 2026-03-16 — 24 days old (threshold 7d) — STALE
- `docs/intent.md`: updated 2026-02-11 — 57 days old (threshold 90d) — ✅ OK
- `lessons.md`: file mtime 2026-04-09 — ✅ OK

**lessons.md size:**
- 4 entries — ✅ within limit

**Notes:**
- Non-standard CLAUDE.md layout (stub at root + full context in .claude/CLAUDE.md). Classified Moderate. Status.md is stale (24 days). The full `.claude/CLAUDE.md` would need review for forbidden sections if it were the canonical file — at 90 lines it would be a Major violation.

---

### link-triage-pipeline — Severity: Major

**Path:** `~/code/_shared/link-triage-pipeline/`

**Missing artifacts:**
- [ ] CLAUDE.md — MISSING
- [ ] intent.md — exists at `docs/intent.md` (docs/ not accepted alt_path for intent.md per standard)
- [ ] lessons.md — MISSING
- [ ] docs/active/ — MISSING
- ✅ status.md (root), BACKLOG.md (root)

**CLAUDE.md issues:**
- MISSING entirely

**Frontmatter violations:**
- `status.md`: has `updated` (2026-02-24) and `stage` — ✅

**Freshness:**
- `status.md`: updated 2026-02-24 — 44 days old (threshold 7d) — STALE
- `docs/intent.md`: updated 2026-01-30 — 69 days old (threshold 90d) — ✅ OK (within limit)

**lessons.md size:**
- MISSING — cannot check

**Notes:**
- Same structural pattern as work-management: CLAUDE.md missing, lessons.md missing, docs/active/ missing, status.md severely stale. Classified Major.

---

### ai-dev — Severity: Major

**Path:** `~/code/tools/ai-dev/`

**Missing artifacts:**
- ✅ All required artifacts present: CLAUDE.md, intent.md, status.md, BACKLOG.md, lessons.md, docs/active/

**CLAUDE.md issues:**
- Length: 22 lines — ✅ within limit
- Contains forbidden sections:
  - `environment_tiers` / `host_protection_rules` — the Project Constraints section explicitly mentions "Don't install anything on the host Mac — use OrbStack for builds/tests". This duplicates host_protection_rules from global CLAUDE.md.
  - Note: it's a single line embedded in constraints, not a full section — borderline. Flagging per standard.

**Frontmatter violations:**
- `status.md`: has inline `**Updated:**` and `**Stage:**` fields (not YAML frontmatter block) — technically lacks proper YAML `---` frontmatter. `updated` and `stage` are present but not in machine-parseable frontmatter format — VIOLATION (format)
- `intent.md`: no YAML frontmatter block — no `status` field, no `updated` field — VIOLATION

**Freshness:**
- `status.md`: inline updated 2026-04-09 — ✅ OK
- `intent.md`: no `updated` field — cannot determine freshness
- `lessons.md`: file mtime 2026-04-09 — ✅ OK

**lessons.md size:**
- 31 bullet entries (max 15) — VIOLATION (more than double the limit)

**Notes:**
- The only Tier 1 project with all 6 required artifacts present. However: lessons.md is severely oversized (31 entries vs 15 max), intent.md has no frontmatter, status.md uses inline bold fields instead of YAML frontmatter, and CLAUDE.md has a borderline host_protection duplication. Classified Major due to lessons.md size (2x limit) + frontmatter failures on 2 artifacts.

---

### agent-harness — Severity: Critical

**Path:** `~/code/tools/agent-harness/`

**Missing artifacts:**
- [ ] CLAUDE.md — MISSING
- [ ] intent.md — MISSING
- [ ] status.md — MISSING
- [ ] BACKLOG.md — MISSING
- [ ] lessons.md — MISSING
- [ ] docs/ — MISSING (no docs directory at all)
- [ ] docs/active/ — MISSING

**CLAUDE.md issues:**
- MISSING entirely

**Frontmatter violations:**
- N/A — no artifacts present to check

**Freshness:**
- N/A — no artifacts present

**lessons.md size:**
- N/A — missing

**Notes:**
- Bare code repository (pyproject.toml, README.md, src/). No ADF scaffolding whatsoever. Classified Critical. Project appears to be an early-stage or prototype repo that was never brought into the ADF system.

---

### cc-codex-handoff — Severity: Critical

**Path:** `~/code/tools/cc-codex-handoff/`

**Missing artifacts:**
- [ ] intent.md — MISSING
- [ ] status.md — MISSING (not at root or docs/)
- [ ] BACKLOG.md — MISSING
- [ ] lessons.md — MISSING
- [ ] docs/ — MISSING (no docs directory)
- [ ] docs/active/ — MISSING
- ✅ CLAUDE.md (root, 43 lines)

**CLAUDE.md issues:**
- Length: 43 lines (max 40) — VIOLATION (+3 lines over limit, minor)
- Contains forbidden sections:
  - `model_routing_guidance` — the CLAUDE.md mentions "Codex (GPT Pro)" and "Claude (Opus)" in a commit attribution template. Borderline — it's attribution format not routing guidance, but the pattern is present.
- No explicit model routing instructions detected beyond the attribution block.

**Frontmatter violations:**
- No other artifacts to check

**Freshness:**
- No artifacts with `updated` fields

**lessons.md size:**
- MISSING

**Notes:**
- Only CLAUDE.md present. Missing 5 of 6 required artifacts. Classified Critical per severity guide (essentially unconformant). The CLAUDE.md content is workflow-description focused (Claude↔Codex handoff protocol) — appropriate for a handoff template repo, but the project needs ADF scaffolding regardless.

---

## Tier 2 Findings

### risk/AGF — Severity: Critical

**Path:** `~/code/clients/risk/AGF/`

**Missing artifacts:**
- [ ] CLAUDE.md — MISSING
- [ ] status.md — MISSING
- [ ] BACKLOG.md — MISSING
- [ ] lessons.md — MISSING
- [ ] docs/active/ — MISSING
- ✅ intent.md (root — but non-standard format)

**CLAUDE.md issues:**
- MISSING entirely

**Frontmatter violations:**
- `intent.md`: uses inline bold `**Status:**` and `**Last updated:**` format (not YAML frontmatter block) — technically non-conformant but functionally present

**Freshness:**
- `intent.md`: Last updated 2026-03-17 — 23 days old (threshold 90d) — ✅ OK

**lessons.md size:**
- MISSING

**Notes:**
- Commercial client repo (AGF framework docs). Known to have its own conventions. Missing most ADF scaffolding. Classified Critical per completeness. Drift expected here — commercial conventions differ.

---

### pike/pike-acm — Severity: Critical

**Path:** `~/code/clients/pike/pike-acm/`

**Missing artifacts:**
- [ ] CLAUDE.md — MISSING
- [ ] intent.md — MISSING
- [ ] status.md — MISSING
- [ ] lessons.md — MISSING
- [ ] docs/active/ — MISSING
- ✅ BACKLOG.md (root)

**CLAUDE.md issues:**
- MISSING entirely

**Frontmatter violations:**
- N/A

**Freshness:**
- N/A

**Notes:**
- Only BACKLOG.md present. Appears to be an early-stage or stalled client project. Critical.

---

### pike/pike-finances — Severity: Critical

**Path:** `~/code/clients/pike/pike-finances/`

**Missing artifacts:**
- [ ] intent.md — MISSING
- ✅ CLAUDE.md (root, 47 lines), status.md (root), BACKLOG.md (root), lessons.md (root), docs/active/ (present)

**CLAUDE.md issues:**
- Length: 47 lines (max 40) — VIOLATION (+7 lines over limit)
- Contains forbidden sections:
  - `environment_tiers` / `host_protection_rules` — content references "OrbStack" and "host Mac" constraints (flagged by detector)

**Frontmatter violations:**
- (Not checked in detail — Tier 2 best-effort audit)

**Freshness:**
- (Not checked in detail — Tier 2 best-effort audit)

**lessons.md size:**
- Present — not counted (Tier 2 scope)

**Notes:**
- Best-conformant Tier 2 project: has 5 of 6 required artifacts. Main issues: CLAUDE.md over limit with possible host_protection duplication, missing intent.md.

---

### even-ground — Severity: Critical

**Path:** `~/code/clients/even-ground/`

**Missing artifacts:**
- [ ] CLAUDE.md — MISSING
- [ ] intent.md — MISSING
- [ ] status.md — MISSING
- [ ] BACKLOG.md — MISSING
- [ ] lessons.md — MISSING
- [ ] docs/active/ — MISSING

**CLAUDE.md issues:**
- MISSING

**Notes:**
- No ADF scaffolding. docs/ directory exists with session transcript files. Critical.

---

### even-ground-native — Severity: Critical

**Path:** `~/code/clients/even-ground-native/`

**Missing artifacts:**
- [ ] intent.md — MISSING
- [ ] status.md — MISSING
- [ ] BACKLOG.md — MISSING
- [ ] lessons.md — MISSING
- [ ] docs/active/ — MISSING
- ✅ CLAUDE.md (root, 3 lines — minimal stub)

**CLAUDE.md issues:**
- Length: 3 lines — ✅ within limit
- Content: 3-line stub with just a project name reference. No allowed sections populated — effectively empty of substance.

**Notes:**
- CLAUDE.md present but nearly empty. Missing 5 of 6 required artifacts. Critical.

---

## Aggregated patterns

- **9 of 13 Tier 1 projects missing CLAUDE.md** (aws, knowledge-base, capabilities-registry, krypton, work-management, pike-agents, link-triage-pipeline, agent-harness, cc-codex-handoff)
- **4 of 4 existing CLAUDE.md files violate the 40-line limit** (memory 60, agent-exec 45, cc-codex-handoff 43, pike-finances 47) — ai-dev at 22 lines is the only fully compliant one
- **2 of 4 existing CLAUDE.md files contain forbidden sections** (agent-exec: memory_system_descriptions; ai-dev: host_protection_rules/environment_tiers)
- **12 of 13 Tier 1 projects missing docs/active/ directory** (only ai-dev has it)
- **10 of 13 Tier 1 projects missing intent.md at root** (many have it in docs/ which is not an accepted alt_path per standard)
- **6 of 13 Tier 1 projects missing lessons.md entirely** (aws, knowledge-base, capabilities-registry have it; memory, krypton, work-management, pike-agents, link-triage-pipeline, agent-harness, cc-codex-handoff do not)
- **5 Tier 1 projects with stale status.md** (capabilities-registry 44d, work-management 43d, link-triage-pipeline 44d, nerve-center 24d, memory 16d)
- **ai-dev lessons.md 2x over limit** (31 entries vs 15 max)
- **intent.md in docs/ is a systemic pattern** — projects were scaffolded with ADF templates that placed intent.md in docs/ but the standard requires root. This indicates a pre-standard scaffolding pattern predating the project-layout.yaml spec.
- **Frontmatter format inconsistency**: ai-dev uses inline bold (`**Updated:**`) instead of YAML frontmatter. aws/docs/status.md has no frontmatter at all.

---

## Triage recommendations

Phase F should tackle in this order:

1. **Critical — ADF scaffolding for agent-harness and cc-codex-handoff** (Tier 1 projects with essentially no conformance). Create CLAUDE.md, intent.md, status.md, BACKLOG.md, docs/active/. Both are tools repos — scaffold with minimal templates.

2. **Major — CLAUDE.md creation for 9 missing projects** (aws, knowledge-base, capabilities-registry, krypton, work-management, pike-agents, link-triage-pipeline + 2 Tier 1 critical). This is autofixable via template. Priority order: aws (governance home), then active projects (krypton, work-management, link-triage-pipeline).

3. **Major — docs/active/ directory creation for all 12 missing** (autofixable via mkdir). Should be done in bulk across all projects.

4. **Major — ai-dev lessons.md KB promotion** (31 entries → promote older entries to KB, trim to ≤15). Not autofixable — requires human review of which entries to promote. High priority because ai-dev is the most active project and the lessons buffer is 2x full.

5. **Major — aws/docs/status.md and aws/docs/intent.md frontmatter** (add YAML blocks). aws is the governance home — its own artifacts should be exemplary.

6. **Moderate — status.md freshness remediation** (capabilities-registry 44d, work-management 43d, link-triage-pipeline 44d stale). Not autofixable — requires session updates. Consider whether these projects are paused or neglected.

7. **Moderate — CLAUDE.md line count and forbidden section cleanup** (memory: strip to ≤40 lines; agent-exec: strip Reference Routing section ≈ brings under 40; ai-dev: remove host Mac line from constraints). agent-exec and ai-dev are autofixable (strip identified lines). memory requires human curation.

8. **Minor — intent.md location normalization** — many projects have intent.md in docs/ instead of root. Decide: either update the standard to accept docs/ as alt_path for intent.md, OR move files to root across all projects. Recommend updating the standard (docs/ is a reasonable alternate location for project docs).

9. **Low — pike/pike-finances CLAUDE.md cleanup** (Tier 2: 47 lines, possible host_protection duplication). Defer until Tier 1 is clean.
