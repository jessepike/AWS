---
type: "plan"
project: "ACM MCP Server"
version: "1.2"
status: "internal-review-complete"
created: "2026-01-31"
design_ref: "docs/design.md"
manifest_ref: "docs/manifest.md"
capabilities_ref: "docs/capabilities.md"
---

# Plan: ACM MCP Server

## Overview

Build a 13-tool read-only TypeScript MCP server at `acm/acm-server/` plus a companion workflow skill at `acm/skills/acm-workflow/`. Follows the build order from design.md Section "Implementation Guidance".

## Phases

### Phase A: Scaffold & Infrastructure

Set up the project structure, dependencies, and shared utilities including path sandboxing.

1. **Scaffold** — `npm init`, directory structure, `tsconfig.json`, `package.json`
2. **Server entry point** — `src/index.ts` (stdio transport setup), `src/server.ts` (McpServer instance)
3. **Path resolution + sandboxing** — `src/lib/paths.ts` with `normalizePath()`, tilde expansion, env var fallback, and `validatePathWithinBase()` using `fs.realpath()` + prefix check
4. **File utilities** — `src/lib/files.ts` (readFile, readFrontmatter, fileExists)
5. **Error helpers** — `src/lib/errors.ts` (isError response builder)
6. **Types** — `src/types.ts` (shared TypeScript types)

**Exit:** Server compiles, starts, and responds to MCP `initialize` handshake. Shared libs importable. Path sandboxing functional.

### Phase B: Tool Implementation

Implement all 13 tools in category order. Each tool file follows the same pattern: import libs, register tools with `z.object()` schemas, implement handlers. All file reads go through sandboxed path resolution from Phase A.

1. **Orchestration** — `src/tools/orchestration.ts` (3 tools: `get_stage`, `get_review_prompt`, `get_transition_prompt`)
2. **Artifacts** — `src/tools/artifacts.ts` (2 tools: `get_artifact_spec`, `get_artifact_stub`)
3. **Project** — `src/tools/project.ts` (3 tools: `get_project_type_guidance`, `check_project_structure`, `check_project_health`)
4. **Governance** — `src/tools/governance.ts` (2 tools: `get_rules_spec`, `get_context_spec`)
5. **Capabilities** — `src/tools/capabilities.ts` (2 tools: `query_capabilities`, `get_capability_detail`)
6. **Knowledge** — `src/tools/knowledge.ts` (1 tool: `query_knowledge`)

**Exit:** All 13 tools registered, compile clean, handle happy path and error cases. Sandbox enforced on all file reads.

### Phase C: Automated Testing

Comprehensive E2E test suite using vitest. Tests call tools programmatically through the McpServer instance and assert on responses. One test file per tool category plus lib tests.

1. **Test setup** — Install vitest, configure `vitest.config.ts`, add `npm test` script, create test helper that instantiates server and calls tools
2. **Lib tests** — `src/lib/__tests__/paths.test.ts` (normalizePath, validatePathWithinBase, sandbox rejection), `files.test.ts` (readFile, readFrontmatter, fileExists), `errors.test.ts` (errorResponse format)
3. **Orchestration tests** — `src/tools/__tests__/orchestration.test.ts` (get_stage for each stage, get_review_prompt for each stage+phase combo, get_transition_prompt with and without validate, brief fallback logic)
4. **Artifacts tests** — `src/tools/__tests__/artifacts.test.ts` (get_artifact_spec for each artifact enum, get_artifact_stub for each stub, claude_md with project_type variants)
5. **Project tests** — `src/tools/__tests__/project.test.ts` (get_project_type_guidance, check_project_structure against ACM repo, check_project_health with regex header validation)
6. **Governance tests** — `src/tools/__tests__/governance.test.ts` (get_rules_spec, get_context_spec for global and project levels)
7. **Capabilities tests** — `src/tools/__tests__/capabilities.test.ts` (query_capabilities with type/tags/keyword filters, get_capability_detail with valid and invalid IDs)
8. **Knowledge tests** — `src/tools/__tests__/knowledge.test.ts` (query_knowledge with matching and non-matching queries, empty results)
9. **Edge case tests** — across all test files: missing files → `isError`, invalid inputs → `isError`, sandbox violations → `isError`, no crashes

**Exit:** `npm test` passes. All 13 tools tested for happy path and error cases. Edge cases covered.

### Phase D: Companion Skill

Build the ACM Workflow skill that teaches agents when/how to use tools.

1. **skill.md** — Skill definition with triggers and instructions
2. **references/tool-guide.md** — Per-tool when-to-use guide with common workflow sequences

**Exit:** Skill files complete, consumer wiring documented.

### Phase E: Integration & Verification

End-to-end verification against success criteria.

1. **Build verification** — `npm run build` produces working `build/index.js`
2. **Test verification** — `npm test` passes with all tests green
3. **Consumer wiring** — Wire into a consumer project via `.mcp.json`, verify server starts and tools respond
4. **README.md** — Usage, installation, tool reference, test instructions

**Exit:** All success criteria from Brief verified. `npm test` passes. Server ready for use.

## Testing Strategy

Automated E2E testing using vitest. All 13 tools tested programmatically.

**Framework:** vitest — native ESM + TypeScript support, no build step needed for tests.

**Test architecture:** Tests instantiate the McpServer directly and call tool handlers programmatically. No stdio transport needed — tests call the server's internal tool dispatch. This tests the actual tool logic without process spawning overhead.

**Coverage per tool category:**
- **Happy path** — call each tool with valid inputs, assert response contains expected content (file content, correct structure, expected fields)
- **Error path** — invalid enum values, missing files, sandbox violations → assert `isError: true` with actionable message
- **Edge cases** — empty results, no frontmatter, missing status.md/brief, `..` traversal attempts

**Lib coverage:**
- `paths.ts` — normalizePath tilde expansion, validatePathWithinBase accepts valid / rejects invalid, path separator edge cases
- `files.ts` — readFile returns content, readFrontmatter parses YAML, fileExists returns boolean
- `errors.ts` — errorResponse returns correct MCP format

**Run:** `npm test` executes full suite. Target: all tests pass before Phase E integration.

## Build Principles

- **Compile early, compile often** — verify TypeScript compiles after each file
- **One tool category at a time** — implement, test, commit, move on
- **Sandbox from the start** — path validation built into lib/paths.ts, used by all tools
- **Spec comments** — add `// Per ACM-{SPEC}-SPEC vX.Y.Z` comments where validation logic references spec content
- **Atomic commits** — one logical change per commit
- **No stdout** — all logging to stderr

## Risk Mitigations

| Risk | Mitigation |
|------|-----------|
| MCP SDK API mismatch | Check SDK docs/types for `registerTool` signature before implementing first tool |
| gray-matter edge cases | Test with actual ACM spec files that have complex frontmatter |
| Path sandboxing false positives | Test with symlinked directories and relative paths |

## Issue Log

| # | Issue | Source | Severity | Status | Resolution |
|---|-------|--------|----------|--------|------------|
| 1 | Tasks format doesn't match ACM-DEVELOP-SPEC — missing acceptance criteria, dependencies, capability columns | Ralph-Develop | High | Resolved | Converted tasks.md to table format with all required columns |
| 2 | Plan missing testing strategy section required by ACM-DEVELOP-SPEC | Ralph-Develop | High | Resolved | Added Testing Strategy section |
| 3 | Path sandboxing in separate Phase C is error-prone — should be built into lib/paths.ts from Phase A | Ralph-Develop | High | Resolved | Merged sandbox into Phase A (task A4) and Phase B (all tools use it). Phase C narrowed to edge case verification only. |
| 4 | Plan missing milestones section | Ralph-Develop | Low | Open | Phase exit criteria serve this purpose adequately for MVP |
| 5 | Plan missing parallelization opportunities section | Ralph-Develop | Low | Open | Build is largely sequential; limited parallelization opportunity |
| 6 | Manifest uses "latest" for MCP SDK version | Ralph-Develop | Low | Open | Acceptable for MVP personal project |
| 7 | Phase 1 internal review complete | Ralph-Develop | - | Complete | 2 cycles: 3 High resolved in cycle 1, zero Critical/High in cycle 2 |
| 8 | `validatePathWithinBase()` can crash on missing paths — `fs.realpath()` throws if target doesn't exist; also naive prefix check has edge cases (`/base/foo2` matching `/base/foo`) | External-GPT | High | Resolved | Updated A4 acceptance criteria: use `path.relative(base, candidate)` check (no `..`, not absolute) + `fs.realpath()` only for existing paths + handle non-existent gracefully with `isError` |
| 9 | Task dependencies incomplete — A8/A9 need A3 (SDK install) as dependency | External-GPT | Medium | Resolved | Added A3 as dependency for A8 |
| 10 | `get_transition_prompt` brief glob fallback is non-deterministic — `*-brief.md` glob order is arbitrary | External-Gemini | Medium | Resolved | Updated B1: sort glob results by mtime desc (newest first), or error if multiple candidates |
| 11 | `check_project_health` section verification method unspecified — `content.includes()` is prone to false positives | External-Gemini | Medium | Resolved | Updated B3: use regex header check (`/^#+\s+SectionName/m`) not string inclusion |
| 12 | Strict capability_id regex may block legacy IDs with underscores/uppercase | External-Gemini | Medium | Closed | Verified: all 39 IDs in inventory.json match strict `^[a-z0-9][a-z0-9-]*$` pattern. No change needed. |
| 13 | Phase 2 external review complete | External-Gemini, External-GPT | - | Complete | 2 reviewers: 1 High resolved, 3 Medium resolved, 1 Medium closed (no risk). Questions answered. |

## Questions Answered for Build

**GPT Q1 — Sandbox vs existence check ordering:** Sandbox checks run first (validate path is within allowed base), then existence checks. If a path is within bounds but doesn't exist, return `isError` with "file not found" message. If a path escapes bounds, return `isError` with "path not allowed" message. Never throw.

**GPT Q2 — Relative `project_path`:** Relative paths are allowed. Resolve against `process.cwd()` via `path.resolve()`, then sandbox-check the resolved absolute path. This matches the design spec.

**Gemini Q1 — Capability ID format:** Verified — all 39 IDs in `inventory.json` match strict `^[a-z0-9][a-z0-9-]*$`. No relaxation needed.

**Gemini Q2 — Preventing console.log stdout pollution:** Add a lint-level check during build: redirect `console.log` to `console.error` in `src/index.ts` before server starts (`console.log = console.error`). This is a one-line safety net. No lint rule needed for MVP.
