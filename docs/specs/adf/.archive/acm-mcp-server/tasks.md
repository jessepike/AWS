---
type: "tasks"
project: "ACM MCP Server"
version: "1.2"
status: "draft"
created: "2026-01-31"
plan_ref: "docs/plan.md"
---

# Tasks: ACM MCP Server

## Phase A: Scaffold & Infrastructure

| ID | Task | Status | Acceptance Criteria | Depends | Capability |
|----|------|--------|---------------------|---------|------------|
| A1 | Initialize project — `npm init`, create directory structure per design | pending | `acm-server/` exists with `src/`, `src/tools/`, `src/lib/`, `package.json` | — | npm CLI |
| A2 | Configure TypeScript — `tsconfig.json` with strict mode, ES2022 target, `build/` outDir | pending | `tsconfig.json` exists, `npx tsc --noEmit` passes on empty project | A1 | typescript |
| A3 | Install dependencies — `@modelcontextprotocol/sdk`, `zod`, `gray-matter`, `typescript`, `@types/node` | pending | All packages in `node_modules/`, `package-lock.json` generated | A1 | npm CLI |
| A4 | Implement `src/lib/paths.ts` — `normalizePath()` with tilde expansion, `ACM_ROOT`/`REGISTRY_ROOT` constants with env var fallback, `validatePathWithinBase()` with safe base check | pending | Exports `normalizePath`, `ACM_ROOT`, `REGISTRY_ROOT`, `validatePathWithinBase`. Tilde expansion works. Sandbox uses `path.relative(base, candidate)` — rejects if starts with `..` or is absolute. Uses `fs.realpath()` for existing paths only; non-existent paths return `isError` not crash. Prefix check uses path separator awareness (no `/base/foo2` matching `/base/foo`). | A2, A3 | — |
| A5 | Implement `src/lib/files.ts` — `readFile()`, `readFrontmatter()`, `fileExists()` utilities | pending | All three functions exported, `readFrontmatter` parses YAML via gray-matter | A4 | — |
| A6 | Implement `src/lib/errors.ts` — `errorResponse()` helper returning MCP `isError` format | pending | Exported function returns `{ content: [{ type: "text", text }], isError: true }` | A2 | — |
| A7 | Implement `src/types.ts` — shared types (ToolResponse, etc.) | pending | Types compile, importable from other modules | A2 | — |
| A8 | Implement `src/server.ts` — McpServer instance creation, tool registration imports | pending | Exports server instance with name "acm", version "1.0.0" | A3, A6, A7 | — |
| A9 | Implement `src/index.ts` — StdioServerTransport setup, server start | pending | `npm run build && node build/index.js` starts without error, responds to MCP initialize | A8 | — |
| A10 | Verify scaffold — `npm run build` compiles clean, server starts and handles MCP initialize | pending | Build produces `build/index.js`, server process starts and exits cleanly | A9 | — |

## Phase B: Tool Implementation

| ID | Task | Status | Acceptance Criteria | Depends | Capability |
|----|------|--------|---------------------|---------|------------|
| B1 | Implement `src/tools/orchestration.ts` — `get_stage`, `get_review_prompt`, `get_transition_prompt` (with validate mode + brief resolution) | pending | 3 tools registered, each returns correct file content. `get_transition_prompt` validate mode reads status.md + brief. Brief fallback: glob `docs/inbox/*-brief.md`, sort by mtime desc (newest first); error if multiple candidates found. Sandbox enforced on all paths. | A10 | — |
| B2 | Implement `src/tools/artifacts.ts` — `get_artifact_spec`, `get_artifact_stub` (with project_type param for claude_md) | pending | 2 tools registered, correct spec/stub returned per artifact enum. `claude_md` stub respects `project_type` param. Sandbox enforced. | A10 | — |
| B3 | Implement `src/tools/project.ts` — `get_project_type_guidance`, `check_project_structure`, `check_project_health` (with spec version comments) | pending | 3 tools registered. Structure check reports per-item pass/fail. Health check validates frontmatter + required sections using regex header check (`/^#+\s+SectionName/m`), not string inclusion. Spec version comments in validation logic. | A10 | — |
| B4 | Implement `src/tools/governance.ts` — `get_rules_spec`, `get_context_spec` | pending | 2 tools registered, return correct spec content for rules and context (global/project). Sandbox enforced. | A10 | — |
| B5 | Implement `src/tools/capabilities.ts` — `query_capabilities`, `get_capability_detail` (with capability_id regex) | pending | 2 tools registered. `query_capabilities` filters by type/tags/keyword. `get_capability_detail` validates `capability_id` pattern. Sandbox enforced against REGISTRY_ROOT. | A10 | — |
| B6 | Implement `src/tools/knowledge.ts` — `query_knowledge` | pending | 1 tool registered. Lists kb/*.md, case-insensitive text match, returns title + snippet + path. Sandbox enforced against ACM_ROOT. | A10 | — |
| B7 | Wire all tool modules into `server.ts`, verify compile + 13 tools registered | pending | `npm run build` compiles clean. Server starts. All 13 tools appear in MCP tool listing. | B1, B2, B3, B4, B5, B6 | — |

## Phase C: Automated Testing

| ID | Task | Status | Acceptance Criteria | Depends | Capability |
|----|------|--------|---------------------|---------|------------|
| C1 | Test setup — install vitest, configure `vitest.config.ts`, add `npm test` script, create test helper for calling tools programmatically | pending | `npm test` runs (even if no tests yet). vitest config resolves TypeScript. Test helper can instantiate server and invoke tool handlers. | B7 | vitest |
| C2 | Lib tests — `src/lib/__tests__/paths.test.ts`, `files.test.ts`, `errors.test.ts` | pending | Tests pass for: normalizePath tilde expansion, validatePathWithinBase accept/reject, readFile/readFrontmatter/fileExists, errorResponse format | C1 | — |
| C3 | Orchestration tests — `src/tools/__tests__/orchestration.test.ts` | pending | Tests pass for: get_stage (each stage + invalid), get_review_prompt (each stage+phase combo), get_transition_prompt (with/without validate, brief fallback) | C1 | — |
| C4 | Artifacts tests — `src/tools/__tests__/artifacts.test.ts` | pending | Tests pass for: get_artifact_spec (each artifact enum), get_artifact_stub (each stub + claude_md project_type variants) | C1 | — |
| C5 | Project tests — `src/tools/__tests__/project.test.ts` | pending | Tests pass for: get_project_type_guidance, check_project_structure (against ACM repo), check_project_health (regex header validation) | C1 | — |
| C6 | Governance tests — `src/tools/__tests__/governance.test.ts` | pending | Tests pass for: get_rules_spec, get_context_spec (global + project levels) | C1 | — |
| C7 | Capabilities tests — `src/tools/__tests__/capabilities.test.ts` | pending | Tests pass for: query_capabilities (type/tags/keyword filters, empty results), get_capability_detail (valid ID, invalid ID pattern, nonexistent ID) | C1 | — |
| C8 | Knowledge tests — `src/tools/__tests__/knowledge.test.ts` | pending | Tests pass for: query_knowledge (matching query, non-matching query, empty results) | C1 | — |
| C9 | Edge case sweep — verify all error paths across all test files | pending | All edge cases return `isError` with actionable message: missing files, invalid inputs, sandbox violations, no crashes. `npm test` all green. | C2, C3, C4, C5, C6, C7, C8 | — |

## Phase D: Companion Skill

| ID | Task | Status | Acceptance Criteria | Depends | Capability |
|----|------|--------|---------------------|---------|------------|
| D1 | Create `skills/acm-workflow/skill.md` — skill definition with triggers and workflow instructions | pending | File exists with description, triggers, stage workflow overview, tool reference table, common workflow sequences | B7 | — |
| D2 | Create `skills/acm-workflow/references/tool-guide.md` — per-tool usage guide with common sequences | pending | All 13 tools documented with when-to-use guidance and common workflow sequences | D1 | — |

## Phase E: Integration & Verification

| ID | Task | Status | Acceptance Criteria | Depends | Capability |
|----|------|--------|---------------------|---------|------------|
| E1 | Full build verification — `npm run build` produces `build/index.js` | pending | Clean build, no errors, `build/index.js` exists and is runnable | C9 | — |
| E2 | Test verification — `npm test` passes with all tests green | pending | All test files pass, zero failures | C9 | — |
| E3 | Consumer wiring — wire into consumer project via `.mcp.json`, verify server starts and tools respond | pending | `.mcp.json` added to consumer project, server starts, at least one tool from each category responds | E1 | — |
| E4 | Create `acm-server/README.md` — installation, usage, tool reference, test instructions | pending | README covers: installation, consumer wiring (.mcp.json), tool reference table, env var configuration, `npm test` instructions | E3 | — |
| E5 | Verify all success criteria from Brief | pending | All 9 success criteria from brief checked and passing | E3 | — |
| E6 | Update `.gitignore` — exclude `acm-server/node_modules/` and `acm-server/build/` | pending | `.gitignore` updated, `git status` shows no node_modules or build artifacts | A1 | — |
