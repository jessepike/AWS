---
type: "reference"
description: "Architecture decisions for ACM MCP server, acm-env integration, and project organization"
created: "2026-01-31"
lifecycle: "ephemeral"
---

# ACM MCP Server — Architecture Decisions

## Project Organization

```
~/code/_shared/
├── acm/                        # Orchestration framework + ACM MCP server
├── capabilities-registry/      # Capability catalog (consumed by ACM server)
├── knowledge-base/             # Future: KB system + KB MCP server
│   └── (link-triage-pipeline becomes a component/subproject)
├── memory/                     # Future: Memory layer + Memory MCP server
└── link-triage-pipeline/       # Currently standalone, future: subordinate to KB
```

## MCP Server Strategy

- **One ACM MCP server** covering orchestration + capability queries + KB queries
- **Knowledge base** gets its own MCP server when built (design doc exists)
- **Memory** gets its own MCP server when built (still conceptual)
- Capabilities registry does NOT need its own server yet — queried through ACM server
- Split criteria: when a primitive needs 5+ distinct tools of its own

## acm-env Plugin vs. ACM MCP Server

These are distinct bounded contexts that coexist:

| Concern | acm-env plugin | ACM MCP server |
|---------|---------------|----------------|
| Environment health | Status, audit, reset, baseline | Not its job |
| Plugin/config management | Capabilities, refresh, setup | Not its job |
| Session hooks | SessionStart, Stop | Not its job |
| Stage workflow | Not covered | get_stage, get_review_prompt |
| Artifact specs | Not covered | get_artifact_spec, get_artifact_stub |
| Spec-level validation | Not covered | check_project_structure, check_project_health |
| Capability queries (interactive) | /acm-env:capabilities | Not its job |
| Capability queries (agent use) | Not covered | query_capabilities |

**acm-env owns environment management** — "is your tooling configured correctly?"
**ACM MCP server owns process knowledge** — "what do you need to do and how?"

## acm-env Integration Points

- acm-env stays as-is, no changes needed immediately
- `/acm-env:audit` could delegate project structure checks to MCP server later
- `baseline.yaml` should add ACM MCP server to available MCP servers once built
- SessionStart hook could optionally warn if ACM MCP server not configured
- acm-env's deferred items (spec validation, prompt management, drift detection) belong in the MCP server

## Skills + MCP Composition

- One ACM skill provides narrative workflow instructions
- Skill references MCP tool names; agent calls them as needed
- Skill is the "how to manage a project" manual; MCP is the data access layer
- Consumer projects wire up via `.mcp.json` (MCP server) + CLAUDE.md reference (skill)

## Link Triage Pipeline

- Subordinate to knowledge base, not to ACM
- Will merge into or sit alongside KB project when KB is built
- The KB design doc (link-triage-pipeline/docs/inbox/knowledge-base-design-doc.md) already defines the KB MCP server tool surface

## ACM MCP Server Tool Surface (13 tools)

### Orchestration
- `get_stage` — stage requirements, phases, gates
- `get_review_prompt` — review prompt for stage + phase
- `get_transition_prompt` — how to move between stages

### Artifacts
- `get_artifact_spec` — what a valid artifact looks like
- `get_artifact_stub` — starter template

### Project
- `get_project_type_guidance` — Software vs Artifact vs Workflow differences
- `check_project_structure` — folder/artifact validation against spec
- `check_project_health` — alignment with intent, drift detection

### Governance
- `get_rules_spec` — what rules a project should have
- `get_context_spec` — what goes in CLAUDE.md (global or project level)

### Capabilities
- `query_capabilities` — search registry by need/tags
- `get_capability_detail` — full details on a specific capability

### Knowledge
- `query_knowledge` — search KB entries by topic

## Three-Server Architecture Within ACM

ACM repo contains two MCP servers with distinct bounded contexts:

```
acm/
├── acm-server/                          # ACM MCP server (TypeScript)
│   └── Process knowledge: specs, prompts, stubs, validation
│
└── skills/external-review/server/       # External Review MCP server (Python)
    └── Review execution: API calls to Kimi K2, Gemini, DeepSeek
```

| | ACM Server | External Review Server |
|--|-----------|----------------------|
| Nature | Knowledge server (read-only) | Execution engine (API calls) |
| Language | TypeScript | Python |
| Data | Local files (specs, prompts, stubs) | External LLM API responses |
| Risk | Zero — reads local files | API keys, network, cost |
| Transport | stdio | stdio |

**How they connect (not overlap):**
- ACM server serves review prompts via `get_review_prompt(stage, phase)`
- External review server consumes those prompts and sends them to external models
- Ralph Loop plugin orchestrates internal review cycles using prompts from ACM server
- Claude Code orchestrates all three during a review workflow

**Future servers (separate repos):**
- Knowledge Base MCP server — `~/code/_shared/knowledge-base/`
- Memory MCP server — `~/code/_shared/memory/`

## Resolved Decisions

| Decision | Chosen | Rationale |
|----------|--------|-----------|
| Server location | `acm/acm-server/` | Interface to ACM's own artifacts; sibling repo adds coupling with no benefit |
| Project path args | Default cwd, optional override | MCP server loaded into consumer project; cwd is already correct |
| KB search | Simple text match | 7 entries; KB MCP server handles rich search later |
| External review separation | Keep as separate server | Different bounded context, risk profile, language, concerns |
