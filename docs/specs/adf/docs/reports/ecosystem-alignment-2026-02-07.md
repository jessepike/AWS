# Ecosystem Alignment Report
**Date:** 2026-02-07
**Scope:** Full (all 6 checks)
**Governing doc:** docs/ecosystem-architecture.md v0.1.0

---

## Summary

- 6 checks run
- 1 aligned, 4 drift findings, 1 gap

| Check | Status | Findings |
|-------|--------|----------|
| 1. Governing Documents | **Drift** | 2 issues |
| 2. Interface Contracts | **Drift** | 5 issues |
| 3. Dependency Chain | **Aligned** | 0 issues |
| 4. Terminology | **Drift** | 5 issues |
| 5. Intent Alignment | **Drift** | 2 issues |
| 6. Open Decisions | **Gap** | 3 issues |

---

## Check 1: Governing Documents Exist and Are Current

**Status: Drift**

### 1.1 — System Map lists `~/code/_shared/memory/` but repo doesn't exist
The ecosystem architecture doc and ADF-ARCHITECTURE-SPEC.md both reference `~/code/_shared/memory/` as the planned location for the Memory Layer. The directory does not exist. This is expected (status is "planned"), but the ecosystem doc should explicitly note this is a placeholder, not a live location.

**Severity:** Low (known, but should be explicit)

### 1.2 — Knowledge Base repo exists but is not listed as a separate repo in ecosystem architecture
`~/code/_shared/knowledge-base/` exists as a standalone repo with 393 tests, its own status.md, and an MCP server. The ecosystem architecture doc lists it as a "Shared Service" but references it only by its MCP server identity — it doesn't list the repo location (`~/code/_shared/knowledge-base/`).

**Severity:** Medium — any agent trying to find the KB codebase from the ecosystem doc would miss it.

**Recommendation:** Add repo location to the KB entry in the System Map table.

---

## Check 2: Interface Contract Consistency

**Status: Drift** — 5 contract mismatches found

### 2.1 — Task status values: ADF spec vs Work OS entity model
- **ADF-TASKS-SPEC:** `pending` / `in-progress` / `done` / `blocked`
- **Work OS Brief:** `pending` / `in_progress` / `blocked` / `done`

**Mismatch:** `in-progress` (hyphen) vs `in_progress` (underscore). The ADF connector in Work OS will need to normalize these. If the connector does strict parsing (Work OS brief says "Strict — specs are the contract"), this is a breaking mismatch.

**Severity:** High — this is on the critical integration path (ADF → Work OS connector).

### 2.2 — Backlog status values and casing
- **ADF-BACKLOG-SPEC:** `Pending` / `In Progress` / `Blocked` (title case)
- **Work OS Brief BacklogItem:** `pending` / `in_progress` / `blocked` (lowercase, snake_case)

**Mismatch:** Case convention and formatting differ. Title case in markdown display vs lowercase enum in database schema is normal for different layers, but the parsing contract needs to handle this translation explicitly.

**Severity:** Medium — needs explicit mapping in connector spec.

### 2.3 — Backlog "done" status handling differs
- **ADF-BACKLOG-SPEC:** Items with status `Done` move to Archive section. No `Done` enum value in the Queue.
- **Work OS Brief BacklogItem:** Has `promoted_to_task_id` field for graduation. Status only has `pending` / `in_progress` / `blocked`. Completion tracked via `completed_at` timestamp.

**Mismatch:** ADF tracks completion by moving rows to an Archive section in markdown. Work OS tracks completion via a timestamp field. The connector needs to handle this semantic difference.

**Severity:** Medium — needs explicit mapping logic.

### 2.4 — ADF frontmatter field naming
- **ADF-BACKLOG-SPEC frontmatter:** Has `type: "tracking"` with field `ACM` in the description (line 41: "Standard ACM frontmatter"). This is a stale ACM→ADF rename remnant.

**Severity:** Low — cosmetic, but shows the rename wasn't fully completed in this spec.

### 2.5 — Krypton "connectors to Work OS" vs Work OS connector definition
- **Krypton Brief:** "Agents finish work. Krypton notices via connectors to Work OS" (line 40)
- **Work OS Brief:** Connectors are "pluggable, inbound-only integrations that feed external data INTO Work OS" (line 355)

**Mismatch:** Krypton implies bidirectional awareness ("notices via connectors"), but Work OS explicitly states connectors are inbound-only. The mechanism by which Krypton detects changes in Work OS is undefined — it's not via a connector, it would be via the REST API or webhooks.

**Severity:** Medium — conceptual gap in how Krypton observes Work OS state changes.

---

## Check 3: Dependency Chain Health

**Status: Aligned**

All repos are at expected build stages:
- **ADF:** Develop stage, active. Building framework quality improvements.
- **KB:** Develop stage complete, post-MVP enhancements. 393 tests, operational.
- **Capabilities Registry:** Develop stage, operational. 48 entries registered.
- **Link Triage:** Develop stage complete, ready for Deliver. 160 tests, operational.
- **Work OS:** Concept (brief only). Not started — appropriate given it depends on ADF specs being stable.
- **Krypton:** Concept (brief only). Not started — appropriate given it depends on Work OS.
- **Memory Layer:** Research complete, design pending. Appropriately parallel to critical path.

No project is building against an unbuilt dependency. The critical path (ADF → Work OS → Krypton) is being followed correctly.

---

## Check 4: Terminology Consistency

**Status: Drift** — 5 terminology issues found

### 4.1 — "Connector" vs "Adapter" vs "Skill" — overloaded terms
- **Work OS:** "connector" = inbound data integration; "adapter" = MCP protocol wrapper
- **Krypton:** "skill" = modular capability; "adapter" = channel translation layer; "connector" used casually for Work OS awareness

These are not contradictions per se — they describe different architectural layers. But the term "adapter" is used differently in Work OS (MCP adapter = protocol bridge) vs Krypton (channel adapter = platform-specific translator). An agent reading both documents could conflate these.

**Recommendation:** Define in ecosystem architecture: Connector = data integration, Adapter = protocol/channel translation, Skill = modular capability package.

### 4.2 — "Context" is overloaded
Used for at least 3 distinct concepts:
1. Tier 1 file-based project state (CLAUDE.md, status.md) — ADF architecture spec
2. Conversational/session state — Krypton brief
3. General "additional information" — Work OS brief (casual usage)

**Recommendation:** Standardize in ecosystem vocabulary.

### 4.3 — `in-progress` vs `in_progress` vs `In Progress`
Three different representations of the same status value across ADF-TASKS-SPEC, Work OS entity model, and ADF-BACKLOG-SPEC.

**Recommendation:** Pick one canonical form. `in_progress` (snake_case) aligns with database conventions and Work OS.

### 4.4 — "Phase" means different things
- **ADF:** A subdivision within a stage (Discover → Design → Develop → Deliver). Phases are process steps.
- **Work OS:** An optional entity within a project for milestone-level grouping. Phases are data entities.

Both are valid but the ADF connector mapping table (Work OS brief line 76) maps ADF phases to Work OS Phase entities, which is the correct reconciliation.

**Severity:** Low — documented mapping exists, but terminology collision could confuse agents.

### 4.5 — ACM remnant in ADF-BACKLOG-SPEC
Line 41 references "Standard ACM frontmatter" — should be "Standard ADF frontmatter."

**Severity:** Low — cosmetic, but indicates incomplete ACM→ADF rename.

---

## Check 5: Intent Alignment

**Status: Drift** — 2 issues

### 5.1 — Krypton scope may subsume ADF orchestration
Krypton's brief describes a skill router, autonomy governor, and heartbeat/cron system that could eventually replicate what ADF's orchestration primitive does (stage management, gate enforcement, context management). The brief doesn't address this explicitly.

This isn't a problem today — Krypton is concept-stage and ADF is operational. But long-term, if Krypton manages stage workflows, does ADF's orchestration become redundant?

**Recommendation:** Add to ecosystem architecture open questions (already noted as Q2). Should also be addressed in Krypton's Design stage.

### 5.2 — Link Triage Pipeline's ecosystem role is narrower than expected
Ecosystem architecture lists Link Triage as a shared service with "Krypton (future trigger)" as a consumer. But Link Triage is actually a batch pipeline (fetch → extract → classify → route to KB), not a real-time service. Krypton wouldn't "trigger" it in the way the architecture implies — it would either run on a schedule or be invoked via CLI.

**Severity:** Low — the integration pattern is slightly mischaracterized but directionally correct.

---

## Check 6: Open Decisions Cross-Check

**Status: Gap** — 3 cross-project decision conflicts found

### 6.1 — ADF connector parsing: "strict" vs spec flexibility
- **Work OS Brief (Decision #5):** "Markdown parser tolerance: Strict — specs are the contract"
- **ADF status.md practice:** The actual ADF project's status.md uses a Session Log table format that differs from what ADF-STATUS-SPEC prescribes (spec shows "Last Session" as a single section, not a rolling table). The spec's own implementation drifts from the spec.

**Risk:** If the Work OS connector does strict parsing against ADF-STATUS-SPEC, it will fail on ADF's own status.md.

**Recommendation:** Either update ADF-STATUS-SPEC to match actual practice (Session Log table format), or ensure the connector tolerates both formats.

### 6.2 — Memory storage decision affects both Memory Layer and Krypton
- **Memory Research (Decision #1):** Storage engine: SQLite + Chroma (KB pattern) vs Postgres + pgvector
- **Krypton Brief (Decision #3):** Memory storage: Local files for MVP, Supabase for persistence later
- **Work OS Brief:** Uses Supabase (Postgres)

If Memory uses SQLite+Chroma and Work OS uses Supabase, Krypton will need to bridge two different storage backends. If Memory later moves to Supabase (as Krypton brief suggests), that's a migration.

**Recommendation:** Make this decision holistically. KB already uses SQLite+Chroma successfully. If Work OS uses Supabase, consider whether Memory should align with one or the other.

### 6.3 — Gateway language decision (Krypton) may constrain Work OS MCP adapter
- **Krypton Brief (Decision #1):** Leaning Node.js (TypeScript)
- **Work OS Brief:** API is "Next.js API routes or standalone service", MCP adapter is "thin wrapper"

If both use Node.js/TypeScript, good alignment. But if Work OS ends up as a Python service (not mentioned but possible), the MCP adapter pattern would differ.

**Severity:** Low — both are leaning TypeScript/Node.js, but not decided.

---

## Action Items

### High Priority
- [ ] **Resolve status value mismatch:** Standardize `in-progress` vs `in_progress` across ADF-TASKS-SPEC and Work OS brief before building the connector. Pick one canonical form.
- [ ] **Fix ACM remnant in ADF-BACKLOG-SPEC:** Line 41 still says "ACM" — should be "ADF."

### Medium Priority
- [ ] **Add KB repo location** to ecosystem-architecture.md System Map
- [ ] **Define standard vocabulary** in ecosystem architecture: Connector, Adapter, Skill, Context, Memory, Knowledge
- [ ] **Clarify Krypton ↔ Work OS observation mechanism:** Krypton brief says "via connectors" but Work OS connectors are inbound-only. Define how Krypton detects Work OS state changes (polling REST API? webhooks? event stream?).
- [ ] **Address status.md format drift:** ADF-STATUS-SPEC prescribes "Last Session" format but practice uses Session Log table. Update spec to match practice.
- [ ] **Make memory storage decision holistically:** SQLite+Chroma (KB pattern) vs Supabase (Work OS pattern) — affects migration burden later.

### Low Priority
- [ ] **Mark memory repo location as placeholder** in ecosystem architecture
- [ ] **Clarify Link Triage integration pattern** (batch pipeline, not real-time trigger)
- [ ] **Add long-term question** about Krypton potentially subsuming ADF orchestration to Krypton's design considerations
