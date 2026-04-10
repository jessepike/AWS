---
type: "design"
project: "ACM MCP Server"
version: "0.3"
status: "internal-review-complete"
created: "2026-01-31"
updated: "2026-01-31"
brief_ref: "docs/inbox/acm-mcp-server-brief.md"
intent_ref: "intent.md"
---

# Design: ACM MCP Server

## Summary

A read-only TypeScript MCP server that exposes ACM's process knowledge — specs, prompts, stubs, project validation, and capabilities registry — as 13 tools over stdio transport. Paired with a companion ACM Workflow skill that teaches agents when and how to use each tool. Together, they allow any agent in a consumer project to query ACM framework knowledge without the ACM repo being open.

**Classification:** App · personal · mvp · standalone
**Primary deliverables:** `acm/acm-server/` (MCP server) + `acm/skills/acm-workflow/` (companion skill)

---

## Architecture

### System Context

```
┌─────────────────────────────────┐
│  Consumer Project               │
│  (e.g., link-triage-pipeline)   │
│                                 │
│  Claude Code ──stdio──► ACM     │
│  Agent                  MCP     │
│                         Server  │
│                                 │
│  .mcp.json wires up server      │
│  CLAUDE.md references ACM skill │
└─────────────────────────────────┘
         │
         │ reads files at request time
         ▼
┌─────────────────────────────────┐
│  ~/code/_shared/acm/            │
│  ├── ACM-*-SPEC.md              │
│  ├── prompts/                   │
│  ├── stubs/                     │
│  └── kb/                        │
│                                 │
│  ~/code/_shared/                │
│  └── capabilities-registry/     │
│      └── inventory.json         │
└─────────────────────────────────┘
```

### Directory Structure

```
acm/acm-server/
├── src/
│   ├── index.ts              # Server entry point, transport setup
│   ├── server.ts             # McpServer instance, tool registration
│   ├── tools/
│   │   ├── orchestration.ts  # get_stage, get_review_prompt, get_transition_prompt
│   │   ├── artifacts.ts      # get_artifact_spec, get_artifact_stub
│   │   ├── project.ts        # get_project_type_guidance, check_project_structure, check_project_health
│   │   ├── governance.ts     # get_rules_spec, get_context_spec
│   │   ├── capabilities.ts   # query_capabilities, get_capability_detail
│   │   └── knowledge.ts      # query_knowledge
│   ├── lib/
│   │   ├── paths.ts          # Path resolution (ACM_ROOT, REGISTRY_ROOT)
│   │   ├── files.ts          # File reading utilities (readFile, readFrontmatter, fileExists)
│   │   └── errors.ts         # Error response helpers
│   └── types.ts              # Shared TypeScript types
├── package.json
├── tsconfig.json
└── README.md
```

### Data Flow

All tools follow the same pattern:

1. Agent calls tool via MCP protocol (JSON-RPC over stdio)
2. Server resolves file path(s) using `lib/paths.ts`
3. Server reads file(s) from disk at request time (no caching)
4. Server processes content (parse frontmatter, extract sections, validate structure)
5. Server returns text content via MCP response

**No caching.** Files are read fresh on every request. ACM specs are actively evolving; stale cache would violate the spec-stability constraint. Given local file I/O, latency is negligible (<50ms per read).

---

## Tech Stack

| Component | Choice | Rationale |
|-----------|--------|-----------|
| **Language** | TypeScript | MCP SDK is TypeScript-first; type safety for schemas |
| **Runtime** | Node.js (≥18) | Required by MCP SDK |
| **MCP SDK** | `@modelcontextprotocol/sdk` | Official SDK; provides McpServer, StdioServerTransport |
| **Schema validation** | `zod` (v3) | SDK's registerTool uses zod for input schemas |
| **Transport** | stdio | Local, co-located with Claude Code; lowest latency |
| **Build** | `tsc` | Simple TypeScript compilation; no bundler needed for local server |
| **Package manager** | npm | Standard; no need for alternatives at this scale |

### Dependencies (production)

- `@modelcontextprotocol/sdk` — MCP protocol implementation
- `zod` — Schema validation (required by SDK)
- `gray-matter` — YAML frontmatter parsing (for spec/stub metadata)

### Dependencies (dev)

- `typescript` — Compiler
- `@types/node` — Node.js type definitions

---

## Tool Schemas

**Note on schema syntax:** All tool schemas use `z.object({...})` as required by the MCP SDK's `registerTool`. The pattern below applies to all 13 tools.

### Orchestration (3 tools)

#### `get_stage`

Returns stage requirements, phases, entry/exit criteria, and review dimensions.

```typescript
server.registerTool("get_stage", {
  description: "Get ACM stage requirements and workflow. Use when an agent needs to understand what a stage involves, its phases, entry/exit criteria, and expected outputs. Do NOT use for transition guidance (use get_transition_prompt instead).",
  inputSchema: z.object({
    stage: z.enum(["discover", "design", "develop"]).describe("ACM stage name"),
  }),
}, handler);
```

**Source files:**
- `ACM-DISCOVER-SPEC.md` → discover
- `ACM-DESIGN-SPEC.md` → design
- `ACM-DEVELOP-SPEC.md` → develop

**Response:** Full spec content as text. Returns `isError` with actionable message for unsupported stages (e.g., "deliver" → "Stage 'deliver' is not yet supported. Supported stages: discover, design, develop. See backlog item B15.").

#### `get_review_prompt`

Returns the review prompt for a given stage and phase.

```typescript
server.registerTool("get_review_prompt", {
  description: "Get the review prompt for a stage and review phase. Use when preparing to run an internal (Ralph Loop) or external review. Returns the full prompt text ready for use.",
  inputSchema: z.object({
    stage: z.enum(["discover", "design", "develop"]).describe("ACM stage"),
    phase: z.enum(["internal", "external"]).describe("Review phase"),
  }),
}, handler);
```

**Source files (prompt map):**

| Stage | Internal | External |
|-------|----------|----------|
| discover | `prompts/ralph-review-prompt.md` | `prompts/external-review-prompt.md` |
| design | `prompts/design-ralph-review-prompt.md` | `prompts/design-external-review-prompt.md` |
| develop | `prompts/develop-ralph-review-prompt.md` | `prompts/develop-external-review-prompt.md` |

**Response:** Raw prompt content as text.

#### `get_transition_prompt`

Returns the transition prompt for moving between stages, with optional prerequisite validation.

```typescript
server.registerTool("get_transition_prompt", {
  description: "Get guidance for transitioning between ACM stages. Returns the transition prompt content. Set validate=true to also check prerequisites against the project's current state (reads status.md and brief).",
  inputSchema: z.object({
    transition: z.enum(["discover_to_design", "design_to_develop"]).describe("Stage transition"),
    project_path: z.string().optional().describe("Project root path. Defaults to cwd."),
    validate: z.boolean().optional().describe("If true, reads project status.md and brief to check prerequisites. Default: false."),
  }),
}, handler);
```

**Source files:**
- `prompts/start-design-prompt.md` → discover_to_design
- `prompts/start-develop-prompt.md` → design_to_develop

**When `validate: true`:** Reads `{project_path}/status.md` and the project's brief file. Brief resolution: check `{project_path}/docs/brief.md` first; if missing, glob `{project_path}/docs/inbox/*-brief.md` and use the first match. Checks stage/phase/status from status.md frontmatter against transition prerequisites. Returns prompt content plus a validation summary (prerequisites met/not met, with specifics). Returns `isError` if status.md or brief cannot be found.

### Artifacts (2 tools)

#### `get_artifact_spec`

Returns the specification for a named ACM artifact type.

```typescript
server.registerTool("get_artifact_spec", {
  description: "Get the ACM specification for an artifact type. Use when you need to understand what a valid artifact looks like — required sections, frontmatter, formatting rules.",
  inputSchema: z.object({
    artifact: z.enum([
      "brief", "intent", "status", "readme", "context",
      "rules", "design", "backlog", "folder_structure",
      "project_types", "stages", "review"
    ]).describe("Artifact type"),
  }),
}, handler);
```

**Source file map:**

| Artifact | File |
|----------|------|
| brief | `ACM-BRIEF-SPEC.md` |
| intent | `ACM-INTENT-SPEC.md` |
| status | `ACM-STATUS-SPEC.md` |
| readme | `ACM-README-SPEC.md` |
| context | `ACM-CONTEXT-ARTIFACT-SPEC.md` |
| rules | `ACM-RULES-SPEC.md` |
| design | `ACM-DESIGN-SPEC.md` |
| backlog | `ACM-BACKLOG-SPEC.md` |
| folder_structure | `ACM-FOLDER-STRUCTURE-SPEC.md` |
| project_types | `ACM-PROJECT-TYPES-SPEC.md` |
| stages | `ACM-STAGES-SPEC.md` |
| review | `ACM-REVIEW-SPEC.md` |

**Response:** Full spec content as text.

#### `get_artifact_stub`

Returns a starter template for a named artifact.

```typescript
server.registerTool("get_artifact_stub", {
  description: "Get a starter template for an ACM artifact. Use when initializing a new project or creating a new artifact. Returns the template with placeholder values ready to fill in.",
  inputSchema: z.object({
    artifact: z.enum([
      "brief", "intent", "status", "rules_constraints", "claude_md"
    ]).describe("Artifact to get stub for"),
    project_type: z.enum(["app", "workflow", "artifact"]).optional().describe("Project type — used to select the correct claude_md stub. Defaults to 'app'. Ignored for non-claude_md artifacts."),
  }),
}, handler);
```

**Source files:** `stubs/{artifact}.md` — direct file mapping (`brief` → `stubs/brief.md`, etc.). Note: `rules_constraints` maps to `stubs/rules-constraints.md` (underscore → hyphen conversion). The `claude_md` stub maps to `stubs/claude-md/` directory — returns the file matching the `project_type` input (`app.md`, `workflow.md`, or `artifact.md`). Defaults to `app.md` when `project_type` is omitted.

### Project (3 tools)

#### `get_project_type_guidance`

Returns guidance for a project classification.

```typescript
server.registerTool("get_project_type_guidance", {
  description: "Get ACM guidance for a project type classification. Use during Discover or Design to understand what outputs, review focus, and structure a project type requires.",
  inputSchema: z.object({
    type: z.enum(["app", "workflow", "artifact"]).describe("Project type"),
    scale: z.enum(["personal", "commercial"]).optional().describe("Project scale modifier"),
    scope: z.enum(["mvp", "full"]).optional().describe("Project scope modifier"),
  }),
}, handler);
```

**Source file:** `ACM-PROJECT-TYPES-SPEC.md` — reads spec, extracts relevant section for the requested type + modifiers.

#### `check_project_structure`

Validates a project's folder structure against ACM-FOLDER-STRUCTURE-SPEC.

```typescript
server.registerTool("check_project_structure", {
  description: "Validate a project's folder structure against ACM spec. Checks for required directories and files. Use when auditing a project or after scaffolding.",
  inputSchema: z.object({
    project_path: z.string().optional().describe("Project root path. Defaults to cwd."),
  }),
}, handler);
```

**Logic:**
1. Resolve project path (cwd or explicit)
2. Check base structure existence: `.claude/`, `.claude/CLAUDE.md`, `.claude/rules/`, `docs/`, `docs/intent.md`, `docs/brief.md`, `docs/inbox/`, `_archive/`, `README.md`
3. Return per-item pass/fail with overall summary

**Response format:**
```
Project Structure Check: /path/to/project
✓ .claude/CLAUDE.md
✓ .claude/rules/
✓ docs/
✓ docs/intent.md
✗ docs/brief.md — missing
✓ docs/inbox/
✓ _archive/
✓ README.md

Result: 7/8 passed. Missing: docs/brief.md
```

#### `check_project_health`

Structural health checks — file presence, frontmatter validation, required sections.

```typescript
server.registerTool("check_project_health", {
  description: "Run structural health checks on an ACM project. Checks file presence, frontmatter validity, and required sections in key artifacts. Does NOT perform semantic analysis. Use for project audits or pre-review validation.",
  inputSchema: z.object({
    project_path: z.string().optional().describe("Project root path. Defaults to cwd."),
  }),
}, handler);
```

**Checks performed:**
1. **File presence** — same as `check_project_structure`
2. **Frontmatter validation** — key artifacts (`intent.md`, `brief.md`, `status.md`, `CLAUDE.md`) have valid YAML frontmatter
3. **Required sections** — brief has: Summary, Scope, Success Criteria, Constraints, Decisions; intent has: Problem, Outcome, Why It Matters; status has: Current State; CLAUDE.md has: Context Map or Orientation

**Response:** Grouped by check category with pass/fail per item and overall health summary.

### Governance (2 tools)

#### `get_rules_spec`

```typescript
server.registerTool("get_rules_spec", {
  description: "Get the ACM rules governance specification. Use when setting up or auditing a project's .claude/rules/ directory — covers what rules are, categories, file organization, and lifecycle.",
  inputSchema: z.object({}),
}, handler);
```

**Source file:** `ACM-RULES-SPEC.md`

#### `get_context_spec`

```typescript
server.registerTool("get_context_spec", {
  description: "Get the ACM specification for CLAUDE.md context artifacts. Use when creating or auditing CLAUDE.md files — covers required sections, what belongs in global vs project level.",
  inputSchema: z.object({
    level: z.enum(["global", "project"]).describe("Which CLAUDE.md spec to return"),
  }),
}, handler);
```

**Source files:**
- `ACM-GLOBAL-CLAUDE-MD-SPEC.md` → global
- `ACM-PROJECT-CLAUDE-MD-SPEC.md` → project

### Capabilities (2 tools)

#### `query_capabilities`

```typescript
server.registerTool("query_capabilities", {
  description: "Search the capabilities registry by keyword, type, or tags. Use when an agent needs to find available tools, skills, agents, or plugins for a task. Returns matching capability summaries.",
  inputSchema: z.object({
    query: z.string().optional().describe("Keyword search across name, description, tags"),
    type: z.enum(["skill", "tool", "agent", "plugin"]).optional().describe("Filter by capability type"),
    tags: z.array(z.string()).optional().describe("Filter by tags (AND logic)"),
  }),
}, handler);
```

**Source file:** `~/code/_shared/capabilities-registry/inventory.json`

**Logic:** Load inventory.json, filter by type/tags/keyword, return matching entries with name, type, description, tags, install_level.

#### `get_capability_detail`

```typescript
server.registerTool("get_capability_detail", {
  description: "Get full details for a specific capability by ID. Use when you need installation instructions, configuration, or complete metadata for a capability found via query_capabilities.",
  inputSchema: z.object({
    capability_id: z.string().regex(/^[a-z0-9][a-z0-9-]*$/).describe("Capability ID (e.g., 'acm-env', 'claude-md-management'). Must match pattern: lowercase alphanumeric with hyphens."),
  }),
}, handler);
```

**Source file:** Reads the capability's `capability.yaml` from `~/code/_shared/capabilities-registry/capabilities/{id}/capability.yaml`.

### Knowledge (1 tool)

#### `query_knowledge`

```typescript
server.registerTool("query_knowledge", {
  description: "Search ACM knowledge base entries by topic. Simple text match across KB article titles and content. Use for finding process learnings and design patterns. For rich semantic search, use the Knowledge Base MCP server (when available).",
  inputSchema: z.object({
    query: z.string().describe("Search term or topic"),
  }),
}, handler);
```

**Source directory:** `~/code/_shared/acm/kb/`

**Logic:**
1. List all `.md` files in `kb/` (excluding `README.md`)
2. For each file: read content, check if query appears in filename or content (case-insensitive)
3. Return matching entries with title (from frontmatter or filename), relevance snippet (first match context), and file path

---

## Path Configuration

### Mechanism

Two environment variables control path resolution, with hardcoded defaults for MVP:

| Variable | Default | Purpose |
|----------|---------|---------|
| `ACM_ROOT` | `~/code/_shared/acm` | Root of ACM repository |
| `ACM_REGISTRY_ROOT` | `~/code/_shared/capabilities-registry` | Root of capabilities registry |

### Path Normalization

All path inputs — env vars, tool arguments, and internal defaults — are normalized before use:

1. **Tilde expansion:** Replace leading `~/` with `os.homedir() + '/'` (Node.js does not expand `~` automatically)
2. **Resolution:** Apply `path.resolve()` to produce absolute paths
3. **Validation:** Verify resolved path is within its expected base directory (see Path Sandboxing below)

### Resolution Order

```typescript
// lib/paths.ts
function normalizePath(p: string): string {
  if (p.startsWith('~/')) {
    p = path.join(os.homedir(), p.slice(2));
  }
  return path.resolve(p);
}

const ACM_ROOT = normalizePath(
  process.env.ACM_ROOT || '~/code/_shared/acm'
);

const REGISTRY_ROOT = normalizePath(
  process.env.ACM_REGISTRY_ROOT || '~/code/_shared/capabilities-registry'
);
```

### Path Sandboxing

Every file read is validated against allowed base directories before execution:

| Tool Category | Allowed Base(s) |
|---------------|----------------|
| Orchestration, Artifacts, Governance, Knowledge | `ACM_ROOT` only |
| Capabilities | `REGISTRY_ROOT` only |
| Project (`check_project_structure`, `check_project_health`, `get_transition_prompt` with validate) | Resolved `project_path` only |

**Enforcement:** After resolving a file path, call `fs.realpath()` and verify the result starts with the expected base directory. Reject with `isError` and actionable message if path escapes bounds. Constrain `capability_id` to pattern `^[a-z0-9][a-z0-9-]*$` before path construction.

### Consumer Wiring

`.mcp.json` in consumer project:

```json
{
  "mcpServers": {
    "acm": {
      "command": "node",
      "args": ["/Users/jessepike/code/_shared/acm/acm-server/build/index.js"],
      "env": {}
    }
  }
}
```

For non-default paths:

```json
{
  "mcpServers": {
    "acm": {
      "command": "node",
      "args": ["/Users/jessepike/code/_shared/acm/acm-server/build/index.js"],
      "env": {
        "ACM_ROOT": "/custom/path/to/acm",
        "ACM_REGISTRY_ROOT": "/custom/path/to/capabilities-registry"
      }
    }
  }
}
```

---

## ACM Workflow Skill (Companion)

### Location

`acm/skills/acm-workflow/` — follows the existing `acm/skills/external-review/` pattern.

### Purpose

The MCP server provides data access; the skill provides narrative workflow instructions. The skill teaches agents when and how to use each tool in the context of ACM stage workflows.

### Structure

```
acm/skills/acm-workflow/
├── skill.md          # Skill definition (description, triggers, instructions)
└── references/
    └── tool-guide.md # When-to-use guide for each MCP tool
```

### Skill Content (skill.md)

The skill is a markdown document that Claude Code loads as context. It covers:

1. **ACM stage workflow overview** — stages, phases, what happens in each
2. **Tool reference table** — which tool to call for which task
3. **Common workflows** — step-by-step sequences using MCP tools:
   - "Start a new project" → `get_artifact_stub(brief)` + `get_artifact_stub(intent)` + `check_project_structure`
   - "Prepare for review" → `get_review_prompt(stage, phase)` + validation
   - "Transition between stages" → `get_transition_prompt(transition, validate=true)`
   - "Audit a project" → `check_project_structure` + `check_project_health`
4. **Tool naming conventions** — all tools are prefixed-namespaced (no collisions)

### Consumer Wiring

Consumer project's `.claude/CLAUDE.md` references the skill:

```markdown
## ACM Integration

This project uses ACM for project management.
See: ~/code/_shared/acm/skills/acm-workflow/skill.md
```

---

## Data Model

This server has no persistent data model. All data comes from files on disk, read at request time.

### Source File Inventory

| Category | Source Location | Format |
|----------|---------------|--------|
| Stage specs | `ACM-{STAGE}-SPEC.md` | Markdown with YAML frontmatter |
| Review prompts | `prompts/*.md` | Markdown with YAML frontmatter |
| Transition prompts | `prompts/start-{stage}-prompt.md` | Markdown with YAML frontmatter |
| Artifact specs | `ACM-*-SPEC.md` | Markdown with YAML frontmatter |
| Stubs | `stubs/*.md`, `stubs/claude-md/` | Markdown templates |
| Project type spec | `ACM-PROJECT-TYPES-SPEC.md` | Markdown with YAML frontmatter |
| Rules spec | `ACM-RULES-SPEC.md` | Markdown with YAML frontmatter |
| Context specs | `ACM-GLOBAL-CLAUDE-MD-SPEC.md`, `ACM-PROJECT-CLAUDE-MD-SPEC.md` | Markdown with YAML frontmatter |
| Capabilities inventory | `capabilities-registry/inventory.json` | JSON |
| Capability details | `capabilities-registry/capabilities/{id}/capability.yaml` | YAML |
| KB entries | `kb/*.md` | Markdown with YAML frontmatter |
| Project status | `{project}/status.md` | Markdown with YAML frontmatter |
| Project brief | `{project}/docs/brief.md` or `{project}/docs/inbox/*-brief.md` | Markdown with YAML frontmatter |

### Frontmatter Parsing

All ACM markdown files use YAML frontmatter. The `gray-matter` library parses this consistently. Key fields used by tools:

- `type` — artifact type classification
- `version` — spec version
- `status` — artifact status (draft, complete, etc.)
- `stage` — current stage (in status.md)
- `phase` — current phase (in status.md)

---

## Security

This server has a minimal security surface:

| Concern | Mitigation |
|---------|------------|
| **No network access** | Server reads local files only; no HTTP, no APIs |
| **No auth needed** | stdio transport, single local user |
| **Read-only** | Server never writes to any file |
| **Path traversal** | `project_path` inputs are resolved and validated against expected base directories; reject paths containing `..` that escape project roots |
| **No secrets** | Server handles no credentials, tokens, or sensitive data |
| **Logging** | stderr only, never stdout (would corrupt JSON-RPC) |
| **Input validation** | All inputs validated via zod schemas before processing |

---

## Capabilities

### Runtime Requirements

- Node.js ≥ 18
- npm (for dependency installation)

### Library Dependencies

- `@modelcontextprotocol/sdk` — MCP protocol
- `zod` (v3) — Schema validation
- `gray-matter` — Frontmatter parsing

### No External Services

Zero external dependencies at runtime. No network calls, no APIs, no databases.

---

## Interface & Format

### Protocol

MCP (Model Context Protocol) over stdio. JSON-RPC 2.0 messages on stdin/stdout.

### Tool Response Format

All tools return MCP `TextContent`:

```typescript
{
  content: [{ type: "text", text: "..." }]
}
```

For errors, use MCP's `isError` flag:

```typescript
{
  content: [{ type: "text", text: "Stage 'deliver' is not yet supported. Supported stages: discover, design, develop. See backlog item B15." }],
  isError: true
}
```

**Error message guidelines** (per MCP design KB — errors are "next prompts"):
- State what went wrong
- State what the agent can do instead
- Reference relevant backlog items or alternatives when applicable
- Never return raw stack traces or internal errors

### Server Metadata

```typescript
new McpServer({
  name: "acm",
  version: "1.0.0",
});
```

---

## Decision Log

| # | Decision | Options Considered | Chosen | Rationale |
|---|----------|-------------------|--------|-----------|
| D1 | No caching | Per-request reads vs startup cache vs TTL cache | Per-request reads | Specs actively evolving; local file I/O is fast enough (<50ms); eliminates cache invalidation complexity |
| D2 | Path config via env vars | Env vars vs .mcp.json args vs config file | Env vars with hardcoded defaults | .mcp.json already supports `env` field; env vars are portable across shells; config file adds unnecessary complexity for MVP |
| D3 | Companion skill as separate deliverable | Skill in server dir vs separate skills/ dir vs no skill | Separate `skills/acm-workflow/` | Follows existing `skills/external-review/` pattern; skill is markdown (not code); different lifecycle from server |
| D4 | `get_transition_prompt` validate mode | Always validate vs never validate vs optional | Optional `validate` param (default false) | Static return is faster and simpler for most uses; validation available when needed; single tool instead of two |
| D5 | Error responses | Structured JSON errors vs MCP isError + text vs plain text | MCP `isError` flag + actionable text | Follows protocol conventions; actionable messages per KB guidance; avoids over-engineering for read-only server |
| D6 | Frontmatter parsing library | gray-matter vs custom regex vs js-yaml | gray-matter | Battle-tested, handles edge cases, small footprint, already standard in the ecosystem |
| D7 | Health checks scope | Semantic alignment vs structural only | Structural only (file presence, frontmatter, required sections) | Semantic alignment requires LLM; structural checks are deterministic and sufficient for MVP |
| D8 | Tool module organization | One file per tool vs one file per category vs single file | One file per category (6 files) | Matches the 6 categories from the brief; each file stays under ~200 lines; easy to navigate |

---

## Backlog

Items deferred from this design, for future consideration:

| # | Item | Priority | Rationale for Deferral |
|---|------|----------|----------------------|
| DB1 | HTTP/SSE transport | Low | stdio sufficient for personal use; add when multi-user or remote needed |
| DB2 | Tool response caching | Low | Not needed until performance proves insufficient |
| DB3 | Semantic health checks | Medium | Requires LLM; add when ACM server composes with external review server |
| DB4 | `deliver` stage support | Medium | Depends on ACM-DELIVER-SPEC.md (B15) |
| DB5 | Skill installation automation | Low | Consumer wiring is manual for now (.mcp.json + CLAUDE.md reference) |
| DB6 | Tool usage analytics | Low | Structured logging to stderr; analyze when needed |

---

## Open Questions

None — all resolved during intake.

---

## Issue Log

| # | Issue | Source | Severity | Complexity | Status | Resolution |
|---|-------|--------|----------|------------|--------|------------|

| 1 | `get_artifact_stub` for `claude_md` maps to directory with 3 files (app.md, artifact.md, workflow.md) but design doesn't specify selection logic | Ralph-Design | High | Low | Resolved | Added: stub returns file matching project type param, or concatenated index if no type provided |
| 2 | `check_project_health` required sections for intent says "Purpose/Vision" but ACM-INTENT-SPEC requires "Problem", "Outcome", "Why It Matters" | Ralph-Design | High | Low | Resolved | Corrected required sections to match ACM-INTENT-SPEC |
| 3 | Frontmatter `intent_ref` says `docs/intent.md` but intent.md is at project root `intent.md` | Ralph-Design | High | Low | Resolved | Fixed path to `intent.md` |
| 4 | `get_artifact_stub` enum value `rules_constraints` doesn't match filename `rules-constraints.md` (underscore vs hyphen) | Ralph-Design | High | Low | Resolved | Added explicit filename mapping note clarifying underscore-to-hyphen conversion |
| 5 | `get_transition_prompt` validate mode doesn't specify how to locate the project's brief file (could be `docs/brief.md` or `docs/inbox/*-brief.md`) | Ralph-Design | High | Low | Resolved | Added brief resolution logic: check `docs/brief.md` first, fall back to `docs/inbox/*-brief.md` |
| 6 | Phase 1 internal review complete | Ralph-Design | - | - | Complete | 2 cycles: 5 High resolved in cycle 1, zero Critical/High in cycle 2 |
| 7 | Missing tilde expansion for path inputs — Node.js doesn't expand `~` automatically | External-Gemini, External-GPT | High | Low | Resolved | Added normalizePath() with tilde expansion to lib/paths.ts spec |
| 8 | Path sandboxing underspecified — free-form path inputs could read arbitrary files | External-GPT | High | Medium | Resolved | Added Path Sandboxing section with per-category base directory enforcement via realpath prefix checks |
| 9 | Zod schema syntax wrong — `inputSchema: {...}` should be `inputSchema: z.object({...})` | External-GPT | High | Low | Resolved | Corrected all 13 tool schemas to use z.object() |
| 10 | `get_artifact_stub(claude_md)` has no input to select project type — stub selection not deterministic | External-GPT | Medium | Low | Resolved | Added optional `project_type` param to schema, defaults to 'app' |
| 11 | Validation logic in `check_project_health` is coupled to spec heading names — spec changes break code | External-Gemini | Medium | Low | Open | Valid concern; acceptable for MVP. Add code comment linking to spec versions during Develop. |
| 12 | Phase 2 external review complete | External-Gemini, External-GPT | - | - | Complete | 2 reviewers: 3 High resolved, 1 Medium resolved, 1 Medium logged |

---

## Develop Handoff

### Design Summary

A 13-tool read-only TypeScript MCP server (`acm/acm-server/`) paired with a companion ACM Workflow skill (`acm/skills/acm-workflow/`). The server reads ACM specs, prompts, stubs, and capabilities registry from disk at request time over stdio transport. All inputs validated with zod, all errors use MCP's `isError` flag with actionable text. Path resolution via `ACM_ROOT` and `ACM_REGISTRY_ROOT` env vars with hardcoded defaults.

### Key Design Decisions

| Decision | Rationale | Implication for Develop |
|----------|-----------|------------------------|
| No caching | Specs are evolving; local I/O is fast | Read files fresh every request; no cache invalidation logic needed |
| Env vars for paths | .mcp.json supports `env`; portable | Implement path resolution in `lib/paths.ts` with env var fallback |
| Structural health checks only | Semantic requires LLM | Health tool checks files, frontmatter, sections — no content analysis |
| One file per tool category | 6 categories, manageable size | Create 6 tool files in `src/tools/` |
| gray-matter for frontmatter | Standard library | Single dependency for all YAML frontmatter parsing |
| Optional validation in transition tool | Keep simple path fast | `validate` param triggers status.md + brief reads |

### Capabilities Needed

- Node.js ≥ 18, npm
- `@modelcontextprotocol/sdk`, `zod`, `gray-matter`
- TypeScript compiler (`tsc`)

### Open Questions for Develop

None.

### Success Criteria (Verify During Implementation)

- [ ] Agent in consumer project can query stage requirements without ACM repo open
- [ ] Agent can retrieve correct review prompt for any supported stage + phase (discover, design, develop)
- [ ] Agent can validate project folder structure against ACM-FOLDER-STRUCTURE-SPEC
- [ ] Agent can query capabilities registry by tags, type, or keyword
- [ ] Agent can retrieve KB entries by topic
- [ ] Tool count: 13 (within 5-15 range)
- [ ] Server starts in <2 seconds, tool responses in <500ms
- [ ] No stdout logging (stderr only)
- [ ] Consumer project wires up via single `.mcp.json` entry

### What Was Validated

- All 12 artifact spec file references verified against disk — all exist
- All 6 prompt file references verified — all exist
- All 5 stub file references verified — all exist (including claude-md/ directory with 3 type-specific stubs)
- Intent required sections corrected to match ACM-INTENT-SPEC
- Brief resolution logic specified for transition validation
- Stub filename mapping edge case (underscore → hyphen) documented
- Path normalization (tilde expansion) specified for all path inputs
- Path sandboxing enforcement specified per tool category
- All zod schemas corrected to `z.object({...})` syntax
- `capability_id` input constrained to safe pattern `^[a-z0-9][a-z0-9-]*$`
- `get_artifact_stub` now has explicit `project_type` discriminator for claude_md stubs

### Implementation Guidance

**Recommended build order:**

1. **Scaffold** — `npm init`, tsconfig, package.json, directory structure
2. **Server entry point** — `index.ts` (transport), `server.ts` (McpServer instance)
3. **Path resolution** — `lib/paths.ts` with env var support
4. **File utilities** — `lib/files.ts` (readFile, readFrontmatter, fileExists)
5. **Error helpers** — `lib/errors.ts` (isError response builder)
6. **Orchestration tools** — `get_stage`, `get_review_prompt`, `get_transition_prompt`
7. **Artifact tools** — `get_artifact_spec`, `get_artifact_stub`
8. **Governance tools** — `get_rules_spec`, `get_context_spec`
9. **Project tools** — `check_project_structure`, `check_project_health`, `get_project_type_guidance`
10. **Capabilities tools** — `query_capabilities`, `get_capability_detail`
11. **Knowledge tool** — `query_knowledge`
12. **Companion skill** — `skills/acm-workflow/skill.md`
13. **Consumer wiring** — `.mcp.json` template, test with consumer project

**Edge cases to test:**
- Missing spec files (graceful error, not crash)
- Empty capabilities registry
- Project with no frontmatter in artifacts
- `validate: true` on transition tool with incomplete project
- Tilde expansion in env var paths
- KB directory with no matching results

### Reference Documents

Read in this order:
1. `intent.md` — North Star
2. `docs/inbox/acm-mcp-server-brief.md` — Scope and criteria (v0.5)
3. `docs/design.md` — This document
4. `docs/inbox/acm-mcp-server-architecture-decisions.md` — Bounded context analysis
5. `kb/mcp-server-design-knowledge-base-agent-ready.md` — MCP design patterns

---

## Review Log

### Phase 1: Internal Review

**Date:** 2026-01-31
**Mechanism:** Ralph Loop (2 cycles)
**Issues Found:** 0 Critical, 5 High
**Actions Taken:**
- **Auto-fixed (5 issues):**
  - `claude_md` stub selection logic unspecified (High/Low) — Added project-type-based selection with app.md default
  - Health check required sections for intent wrong (High/Low) — Corrected to match ACM-INTENT-SPEC (Problem, Outcome, Why It Matters)
  - Frontmatter `intent_ref` path wrong (High/Low) — Fixed from `docs/intent.md` to `intent.md`
  - `rules_constraints` enum/filename mismatch (High/Low) — Added underscore-to-hyphen mapping note
  - Brief resolution for transition validation unspecified (High/Low) — Added docs/brief.md → docs/inbox/*-brief.md fallback logic

**Outcome:** Phase 1 complete — 2 cycles, zero Critical/High in cycle 2. Design ready for Phase 2 or Develop.

### Phase 2: External Review

**Date:** 2026-01-31
**Reviewers:** External-Gemini, External-GPT
**Issues Found:** 0 Critical, 3 High, 2 Medium
**Actions Taken:**
- **Auto-fixed (4 issues):**
  - Missing tilde expansion in path resolution (High/Low) — Added normalizePath() with `~/` → `os.homedir()` expansion
  - Path sandboxing underspecified (High/Medium) — Added per-category base directory enforcement with realpath prefix checks
  - Zod schema syntax incorrect (High/Low) — Corrected all 13 schemas to `z.object({...})`
  - `claude_md` stub selection not deterministic (Medium/Low) — Added optional `project_type` input param
- **Logged only (1 issue):**
  - Health check validation coupled to spec headings (Medium/Low) — Valid concern, acceptable for MVP with code comments

**Cross-Reviewer Consensus:**
- Both flagged tilde expansion independently (Gemini High, GPT Medium)
- GPT focused on security (path traversal, input sanitization); Gemini focused on runtime correctness
- Both praised bounded-context separation and no-caching strategy

**Questions Answered for Develop:**
- `process.cwd()`: MCP servers spawned by Claude Code inherit the consumer project's cwd — this is the expected behavior
- Relative `project_path` inputs: resolved via `path.resolve()` against `process.cwd()`, then sandboxed against the resolved base
- `capability_id`: constrained to `^[a-z0-9][a-z0-9-]*$` pattern — no path traversal possible
- Env var `~` usage: now explicitly handled via normalizePath()

**Outcome:** Phase 2 complete — 3 High and 1 Medium resolved. Design ready for Develop.

---

## Revision History

| Version | Date | Changes |
|---------|------|---------|
| 0.1 | 2026-01-31 | Initial draft — all 13 tool schemas, architecture, tech stack, companion skill, path config, health checks, develop handoff |
| 0.2 | 2026-01-31 | Ralph-Design cycle 1: Fixed intent_ref path, corrected health check required sections for intent, added claude_md stub selection logic, clarified rules_constraints filename mapping, added brief resolution logic for transition validation |
| 0.3 | 2026-01-31 | Phase 2 external review (Gemini + GPT): Added tilde expansion and path sandboxing, corrected all zod schemas to z.object(), added project_type param to get_artifact_stub, constrained capability_id input pattern |
