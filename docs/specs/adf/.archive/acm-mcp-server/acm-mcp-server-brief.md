---
type: "brief"
project: "ACM MCP Server"
version: "0.5"
status: "complete"
review_cycle: 2
created: "2026-01-31"
updated: "2026-01-31"
intent_ref: "../intent.md"
---

# Brief: ACM MCP Server

## Classification

- **Type:** App
- **Scale:** personal
- **Scope:** mvp
- **Complexity:** standalone

## Summary

Build an MCP server that exposes ACM's environment layer — specs, prompts, stubs, and project validation — as queryable tools for any agent working on an ACM-governed project. This solves the core problem of consumer projects (link-triage-pipeline, knowledge-base, etc.) having no access to ACM process knowledge when opened in isolation. The server is the interface through which agents consume the ACM framework, replacing the current dependency on multi-root IDE workspaces or manual spec reading.

This directly serves ACM's intent: stages that guide work, specs as contracts, and progressive disclosure. The MCP server is the delivery mechanism.

## Scope

### In Scope

- **Orchestration tools:** Query stage requirements, review prompts, transition prompts from ACM specs and prompts/
- **Artifact tools:** Retrieve artifact specs and starter stubs
- **Project tools:** Validate project structure and health against ACM specs
- **Governance tools:** Query rules and CLAUDE.md specs
- **Capability tools:** Query the capabilities registry (read-only, from inventory.json)
- **Knowledge tools:** Query KB entries from acm/kb/ (read-only, simple text search)
- **Transport:** stdio (local, co-located with Claude Code)
- **Language:** TypeScript (MCP SDK + Node.js)
- **Configuration:** Installable via `.mcp.json` in any consumer project
- **Location:** `acm/acm-server/` — inside ACM repo, not a sibling

### Out of Scope

- **Environment management** — acm-env plugin owns this (status, audit, setup, reset, hooks)
- **Maintenance primitive** — distributed per ACM-ARCHITECTURE-SPEC.md; acm-env handles component freshness checks. No maintenance tools in this server. (Backlog: B36)
- **Write operations to specs/prompts** — server is read-only against ACM artifacts
- **External review execution** — separate MCP server (`acm/skills/external-review/server/`), separate bounded context (API calls to external LLMs)
- **Internal review orchestration** — Ralph Loop plugin handles Phase 1
- **Knowledge base MCP server** — separate project, separate bounded context (planned within weeks)
- **Memory MCP server** — separate project, not yet designed
- **Capability installation/promotion** — acm-env's `/capabilities` command handles interactive installs
- **HTTP/SSE transport** — stdio sufficient for personal local use
- **Authentication** — local stdio, no auth needed
- **Project initialization** — acm-env's `/setup` command and `init-project.sh` handle this

## Success Criteria

- [ ] Agent in a consumer project (e.g., link-triage-pipeline) can query stage requirements without ACM repo being open
- [ ] Agent can retrieve the correct review prompt for any supported stage + phase combination (discover, design, develop)
- [ ] Agent can validate a project's folder structure against ACM-FOLDER-STRUCTURE-SPEC
- [ ] Agent can query capabilities registry by tags, type, or keyword
- [ ] Agent can retrieve KB entries by topic
- [ ] Tool count stays within 5-15 range (target: 13)
- [ ] Server starts in <2 seconds, tool responses return in <500ms
- [ ] No stdout logging (stderr only, per MCP stdio requirements)
- [ ] Consumer project wires up via a single `.mcp.json` entry

## Open Questions

None — all resolved during Discover. See Decisions table.

## Constraints

- **Read-only:** The server reads ACM artifacts but never modifies them. Write operations stay in human-controlled workflows.
- **File-based backend:** All data comes from files on disk (specs, prompts, stubs, inventory.json, kb/ entries). No database.
- **Hardcoded paths:** MVP can hardcode `~/code/_shared/acm/` and `~/code/_shared/capabilities-registry/` paths, with config override for portability later.
- **Single user:** No multi-tenant concerns. Runs locally for one developer.
- **Spec stability:** ACM specs are actively evolving. The server should read files at request time, not cache at startup, so it always reflects current spec state.
- **Tool surface discipline:** Follow MCP server design KB — outcome-oriented tools, flat schemas, actionable errors, 5-15 tool maximum.

## Decisions

| Decision | Options Considered | Chosen | Rationale |
|----------|-------------------|--------|-----------|
| Server location | Inside `acm/acm-server/` vs sibling repo `acm-server/` | Inside `acm/acm-server/` | Server is the interface to ACM's own artifacts. Sibling repo creates coupling dependency with no benefit. Only downside is `node_modules/` in ACM repo (gitignored). |
| Project path arguments | Explicit `project_path` param vs infer from cwd | Default to cwd, optional `project_path` override | MCP server is loaded into the consumer project — cwd is already that project. Override exists for validating other projects. |
| KB search strategy | Simple text match vs semantic search | Simple text match | Only 7 KB entries today. Knowledge base MCP server (planned) will handle sophisticated search. Revisit if KB grows beyond ~20 entries. |
| Relationship to external review server | Merge review tools into ACM server vs keep separate | Keep separate | External review server has fundamentally different concerns: API keys, network calls, provider abstractions, cost. ACM server is read-only local file access. Different bounded contexts, different risk profiles, different languages (TS vs Python). |

---

## Tool Surface

13 tools across 6 categories:

| Category | Tools | Purpose |
|----------|-------|---------|
| **Orchestration** (3) | `get_stage`, `get_review_prompt`, `get_transition_prompt` | Query stage requirements, review prompts, transition guidance |
| **Artifacts** (2) | `get_artifact_spec`, `get_artifact_stub` | Retrieve artifact specifications and starter templates |
| **Project** (3) | `get_project_type_guidance`, `check_project_structure`, `check_project_health` | Project classification guidance, structure validation, structural health checks (file presence, frontmatter, required sections — not semantic alignment) |
| **Governance** (2) | `get_rules_spec`, `get_context_spec` | Query rules governance model and CLAUDE.md specs |
| **Capabilities** (2) | `query_capabilities`, `get_capability_detail` | Search and inspect capabilities registry entries |
| **Knowledge** (1) | `query_knowledge` | Search ACM knowledge base entries by topic (interim — KB MCP server will supersede for rich search) |

**Known gap:** `deliver` stage is a valid input for `get_stage` but ACM-DELIVER-SPEC.md does not exist yet. Returns actionable error. (Backlog: B15, B39)

**Design principle:** All tools are read-only, outcome-oriented, with flat schemas and actionable errors per MCP server design KB.

---

## Relationship to Other Components

### acm-env Plugin

- **No overlap in tools** — acm-env manages environment config (plugins, settings, hooks, baseline); this serves process knowledge (specs, prompts, validation)
- **Shared data sources** — both read from capabilities-registry and ACM specs
- **Future integration** — acm-env:audit could delegate spec-level validation to this server's `check_project_health` tool
- **baseline.yaml update** — add ACM MCP server to available MCP servers list once built
- See: `docs/inbox/acm-mcp-server-architecture-decisions.md` for full analysis

### External Review MCP Server (ACM-EXTERNAL-REVIEW-SKILL-SPEC.md)

- **Distinct bounded context** — external review server handles API calls to external LLMs (Kimi K2, Gemini, DeepSeek); this server handles local file reads
- **Consumer relationship** — external review workflow can use this server's `get_review_prompt(stage, "external")` to retrieve the correct prompt before calling `external-review.review()` to send it to external models
- **No tool overlap** — this server serves prompts; external review server executes them
- **Different tech stacks** — this server is TypeScript/Node; external review is Python (provider abstractions, async HTTP)
- **Different risk profiles** — this server has zero external dependencies; external review has API keys, network calls, cost

### Ralph Loop Plugin (Internal Review)

- **No overlap** — Ralph Loop is a plugin that orchestrates iterative review cycles; this server provides the prompts Ralph Loop consumes
- **Consumption pattern** — Ralph Loop uses `get_review_prompt(stage, "internal")` to get the right prompt, then runs its cycle

### Future MCP Servers

| Server | Bounded Context | Relationship to ACM Server |
|--------|----------------|---------------------------|
| Knowledge Base | Semantic search, ingestion pipeline, vector store | Supersedes `query_knowledge` for rich queries. ACM server's `query_knowledge` remains for ACM-specific process learnings in `kb/`. |
| Memory | Session logs, cross-project state, history | ACM server's `check_project_health` could read memory for session recency. Deferred. |

### Self-Improvement Loop (ACM-ARCHITECTURE-SPEC.md)

The architecture spec defines a self-improvement loop: capture → distill → apply → validate. This server supports the **apply** step — agents query `query_knowledge` to reuse captured learnings during project work. The **capture** and **distill** steps are future concerns owned by the Memory and Knowledge Base MCP servers respectively. (Backlog: B38)

---

## Issue Log

| # | Issue | Source | Severity | Complexity | Status | Resolution |
|---|-------|--------|----------|------------|--------|------------|
| 1 | Missing Open Questions section | Ralph-Design | Critical | Low | Resolved | Added section |
| 2 | Missing Review Log section | Ralph-Design | Critical | Low | Resolved | Added section |
| 3 | Issue Log columns used Impact/Priority instead of Severity/Complexity | Ralph-Design | High | Low | Resolved | Fixed column headers |
| 4 | Brief contains Design-stage content (implementation details, code samples, directory structure) | Ralph-Design | Critical | Medium | Resolved | Moved implementation details to Design Notes appendix; kept tool surface summary |
| 5 | Tool naming inconsistency between architecture decisions doc and brief | Ralph-Design | High | Low | Resolved | Standardized to `get_context_spec` |
| 6 | Architecture decisions doc heading says "Three-Server" but body says two | Ralph-Design | Low | N/A | Open | Minor — in ephemeral doc |
| 7 | Phase 1 review complete | Ralph-Design | - | - | Complete | 2 cycles: 3 Critical, 2 High resolved |
| 8 | `check_project_health` claims "alignment" checking — infeasible without LLM under no-external-LLM constraint | External-Gemini | High | Low | Resolved | Scoped tool description to structural checks only (file presence, frontmatter, required sections) |
| 9 | Success criteria says "any stage + phase" but `deliver` has no spec/prompt | External-GPT | High | Low | Resolved | Scoped success criterion to supported stages (discover, design, develop); known gap already documented |
| 10 | Hardcoded path assumption vs "installable" success criterion tension | External-GPT | Medium | Low | Open | Brief already states "config override for portability later"; MVP default acceptable |
| 11 | Missing ACM Skill (narrative instructions) scope | External-Gemini | Low | N/A | Open | Filtered — scope expansion; skill is a separate deliverable, not server scope |
| 12 | Phase 2 review complete | External-Gemini, External-GPT | - | - | Complete | 2 reviewers: 2 High resolved, 1 Medium logged, 1 Low logged |

## Review Log

### Phase 1: Internal Review

**Date:** 2026-01-31
**Mechanism:** Ralph Loop (2 cycles)
**Issues Found:** 3 Critical, 2 High, 1 Low
**Complexity Assessment:** 3 Low, 1 Medium (for Critical/High issues)
**Actions Taken:**
- **Auto-fixed (5 issues):**
  - Missing Open Questions section (Critical/Low) — Added section
  - Missing Review Log section (Critical/Low) — Added section
  - Issue Log wrong columns (High/Low) — Fixed to Severity/Complexity
  - Design-stage content in brief (Critical/Medium) — Moved to Design Notes appendix
  - Tool naming inconsistency (High/Low) — Standardized naming
- **Logged only (1 issue):**
  - Architecture decisions heading mismatch (Low/N/A) — Ephemeral doc, minor

**Outcome:** Phase 1 complete — 2 cycles, zero Critical/High in final cycle. Brief ready for Phase 2.

### Phase 2: External Review

**Date:** 2026-01-31
**Reviewers:** External-Gemini, External-GPT
**Issues Found:** 0 Critical, 2 High, 1 Medium, 1 Low
**Complexity Assessment:** 2 Low (for High issues)
**Actions Taken:**
- **Auto-fixed (2 issues):**
  - `check_project_health` alignment claim infeasible (High/Low) — Scoped tool description to structural checks only
  - Success criteria "any stage" includes unsupported `deliver` (High/Low) — Scoped to supported stages (discover, design, develop)
- **Logged only (2 issues):**
  - Hardcoded path vs installable tension (Medium/Low) — Brief already addresses with "config override for portability later"
  - Missing ACM Skill scope (Low/N/A) — Scope expansion; skill is a separate deliverable

**Cross-Reviewer Consensus:**
- Both reviewers praised bounded-context separation as architecturally sound
- No overlapping issues between reviewers; each found distinct gaps
- Gemini focused on implementation feasibility; GPT focused on contract consistency

**Outcome:** Phase 2 complete — 2 High issues resolved, brief ready for Design stage.

**Questions forwarded to Design:**
- What specific structural checks does `check_project_health` perform? (file existence, frontmatter validation, required sections)
- Source files/locations for `get_project_type_guidance` and `get_rules_spec`
- Does `get_transition_prompt` read project state or return static guidance?
- Error/response schema for missing spec cases (e.g., `deliver`)
- Path resolution strategy across shells/OS
- Caching policy (per-request memoization vs none)

## Revision History

| Version | Date | Changes |
|---------|------|---------|
| 0.1 | 2026-01-31 | Initial draft |
| 0.2 | 2026-01-31 | Resolved open questions (server location, path args, KB search). Added decisions table. Added external review alignment. Expanded tool descriptions with when-to-use/when-not. Added error response format. Added path configuration details. Added relationship to external review and Ralph Loop. |
| 0.3 | 2026-01-31 | Internal review fixes: added maintenance primitive exclusion note, standardized "environment layer" terminology, added self-improvement loop connection, added deliver stage known gap. Updated ACM-ENVIRONMENT-SPEC.md references to ACM-ARCHITECTURE-SPEC.md. Added backlog items B36-B40. |
| 0.4 | 2026-01-31 | Ralph-Design review cycle 1: Added missing Open Questions and Review Log sections. Fixed Issue Log columns to match ACM-REVIEW-SPEC. Moved implementation details (tool schemas, code samples, directory structure, consumer wiring) to design.md scope — replaced with tool surface summary table. Standardized tool naming. |
| 0.5 | 2026-01-31 | Phase 2 external review (Gemini + GPT): Scoped `check_project_health` to structural checks only. Scoped success criteria to supported stages. Logged path portability tension. Forwarded design questions. Brief complete. |
