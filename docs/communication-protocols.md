# Inter-Component Communication Protocols

> Reference document mapping every component pair's actual communication interfaces, data flow patterns, and integration gaps.

---

## 1. Interface Registry

### MCP Servers (4 operational)

| Server | Location | Tools | Transport |
|--------|----------|-------|-----------|
| ADF | `adf/adf-server/` | 16 | stdio (Node.js) |
| Knowledge Base | `knowledge-base/kb_core/access/mcp_server.py` | 16 | stdio (Python) |
| Memory | `memory/src/memory_core/access/mcp_server.py` | 15 | stdio (Python) |
| Work Management | `work-management/mcp-server/` | 40+ | stdio (Node.js) → Supabase REST |

### Connection Map

| From | To | Mechanism | Tools/Endpoints | Direction | Status |
|------|-----|-----------|----------------|-----------|--------|
| Krypton | KB | MCP | `search_knowledge`, `get_item`, `get_items`, `get_recent`, `get_focus_topics`, `get_stats`, `get_unprocessed`, `get_backlog`, `get_ideas`, `get_learnings`, `get_to_read`, `send_to_kb`, `update_item`, `archive_item`, `mark_complete`, `set_focus_topics` | Read/Write (writes gated) | Operational |
| Krypton | Memory | MCP | `search_memories`, `get_memory`, `get_recent`, `get_session_context`, `write_memory`, `update_memory`, `archive_memory`, `get_stats`, `health` | Read/Write | Operational |
| Krypton | ADF | MCP | `get_stage`, `get_review_prompt`, `get_transition_prompt`, `get_artifact_spec`, `get_artifact_stub`, `get_project_type_guidance`, `check_project_structure`, `check_project_health`, `get_rules_spec`, `get_context_spec`, `query_capabilities`, `get_capability_detail`, `query_knowledge` | Read-only | Operational |
| Krypton | Work Mgmt | MCP | `get_project`, `list_projects`, `get_portfolio_status`, `whats_next`, `search_work`, `list_tasks`, `get_task`, `list_backlog`, `get_activity`, `get_blockers`, `get_deadlines` | Read-only | Operational |
| ADF | KB | MCP | `search_knowledge`, `get_item`, `get_recent`, `get_focus_topics` | Read-only | Operational |
| ADF | Capabilities Registry | MCP (ADF server wraps) | `query_capabilities`, `get_capability_detail` | Read-only | Operational |
| ADF | External Review | MCP | `review`, `list_models` | Read-only | Operational |
| ADF | Memory | MCP | `search_memories`, `get_session_context` (via `.mcp.json`) | Read-only | Operational |
| Work Mgmt | ADF | MCP (adapter) | `discover_local_projects`, `connect_local_project`, `sync_adf_project` | One-way sync | Operational (basic) |
| Capabilities Registry | ADF | File → MCP | `capabilities/*.yaml` → ADF server reads at startup | Embedded | Operational |
| Link Triage | KB | Direct integration | Captures → `send_to_kb` via Claude Code session | Write-only | Operational |
| KB | Memory | None | No cross-querying | — | Gap |
| Work Mgmt | Krypton | None | No direct interface | — | Gap |
| Work Mgmt | KB | None | No direct access | — | By design (Krypton mediates) |
| Work Mgmt | Memory | None | No direct access | — | By design (Krypton mediates) |
| Link Triage | Krypton | None | No routing integration | — | Gap (B3 planned) |

### Autonomy Gates (Krypton Hooks)

Krypton enforces approval gates on KB writes via PreToolUse hooks:

| Tool | Gate |
|------|------|
| `send_to_kb` | User confirmation required |
| `update_item` | User confirmation required |
| `archive_item` | User confirmation required |
| `mark_complete` | User confirmation required |
| `set_focus_topics` | User confirmation required |

PostToolUse hooks log all KB and ADF operations to audit trail.

---

## 2. Data Flow Patterns

### Pattern 1: Capture → Storage (Krypton routing)

User provides content → Krypton analyzes type and destination → routes to KB or Memory.

```
User Input
    │
    ▼
Krypton /capture skill
    │
    ├── KB-worthy (learnings, ideas, references)
    │   └── send_to_kb ──► [approval gate] ──► KB
    │
    └── Memory-worthy (preferences, patterns, decisions)
        └── write_memory ──► Memory
```

**Routing rule:** Cross-project, cross-client knowledge → Memory. Structured research, learnings → KB. Session state → status.md.

### Pattern 2: Focus Synthesis (parallel gathering → recommendation)

Krypton `/focus` skill gathers from all sources in parallel, then synthesizes.

```
┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐
│ krypton-kb-     │  │ krypton-adf-    │  │ krypton-memory- │
│ gatherer agent  │  │ gatherer agent  │  │ reader agent    │
│                 │  │                 │  │                 │
│ search_knowledge│  │ get_stage       │  │ search_memories │
│ get_focus_topics│  │ check_project_  │  │ get_session_    │
│ get_recent      │  │   health        │  │   context       │
│ get_stats       │  │ check_project_  │  │                 │
│                 │  │   structure     │  │                 │
└────────┬────────┘  └────────┬────────┘  └────────┬────────┘
         │                    │                    │
         └────────────────────┼────────────────────┘
                              │
                              ▼
                    Krypton synthesis
                    (Opus-level reasoning)
                              │
                              ▼
                    Priority recommendation
                    to human
```

### Pattern 3: ADF Review Orchestration

ADF review cycle uses internal review (Claude) then optional external review (other models).

```
Artifact ready for review
    │
    ▼
ADF get_review_prompt (internal phase)
    │
    ▼
Claude reviews artifact
    │
    ▼
ADF get_review_prompt (external phase)
    │
    ▼
external-review MCP: review tool
(routes to configured model)
    │
    ▼
Combined review feedback
```

### Pattern 4: Session Protocol (file convention)

Not MCP-based — uses file conventions for state continuity.

```
Session Start:
    read docs/status.md → understand current state
    search_memories → cross-project context
    read BACKLOG.md → understand priorities

Session End:
    update docs/status.md → log what happened
    write_memory → cross-project learnings
```

### Pattern 5: Work Intake (designed, partially built)

ADF project state syncs to Work Management via MCP adapter tools.

```
ADF project (local files)
    │
    ▼
discover_local_projects → finds ADF projects
connect_local_project → links to WM
sync_adf_project → reads ADF artifacts, creates WM tasks
    │
    ▼
Work Management (Supabase)
    │
    ▼
whats_next → smart next-action recommendation
```

**Current limitation:** Sync is manual (tool invocation required). No automated event-driven sync.

---

## 3. Protocol Standards

### MCP as Primary Integration

All inter-component communication uses MCP (Model Context Protocol) over stdio transport. This provides:
- Tool discovery via MCP protocol
- Consistent invocation pattern across all servers
- Natural integration with Claude Code and other MCP clients

### Naming Conventions

| Convention | Example | Usage |
|-----------|---------|-------|
| `verb_noun` | `search_knowledge`, `get_item` | Standard tool naming |
| `get_*` | `get_stage`, `get_memory` | Single-item retrieval |
| `list_*` | `list_projects`, `list_tasks` | Collection retrieval |
| `search_*` | `search_knowledge`, `search_work` | Query-based search |
| `create_*` / `update_*` | `create_task`, `update_item` | Write operations |

### Permission Model

| Access Level | Description | Examples |
|-------------|-------------|----------|
| Read-only | Component queries another's state | Krypton → ADF, Krypton → Work Mgmt |
| Gated write | Writes require human approval | Krypton → KB (via PreToolUse hooks) |
| Direct write | Writes proceed without approval | Krypton → Memory, Work Mgmt internal |
| No access | By architecture decision | Work Mgmt → KB (Krypton mediates) |

### Error Handling

- MCP servers return structured error responses
- Callers should handle: connection failures, tool not found, invalid parameters
- No retry loops — surface errors to user/caller
- Health checks available: Memory `health` tool

---

## 4. Integration Gaps

| Gap | Components | Impact | Resolution Path |
|-----|-----------|--------|-----------------|
| **KB ↔ Memory no cross-query** | KB, Memory | Cannot find related KB entries from a memory or vice versa. Synthesis requires Krypton to query both separately. | Low priority — Krypton already bridges this. Consider a `related_items` tool if pattern detection across stores becomes needed. |
| **Work Mgmt → Krypton no interface** | Work Mgmt, Krypton | Work Manager cannot request strategic context from Krypton. Must rely on human to relay. | Medium priority — needed when Work Manager becomes autonomous. Could expose Krypton as MCP server or use shared state file. |
| **Link Triage → Krypton no routing** | Link Triage, Krypton | Link captures go directly to KB, bypassing Krypton's routing intelligence. | Planned in B3 — evolve `/capture` to handle link triage output. |
| **No event-driven sync (ADF → WM)** | ADF, Work Mgmt | ADF state changes don't automatically propagate to Work Management. Manual sync required. | Medium priority — add file watcher or hook-based trigger when ADF artifacts change. |
| **No cross-project observability bus** | All | No unified event stream across components. Each component logs independently. | Planned in B4 — system-level dashboard. Could use shared activity log or lightweight event bus. |
| **Governance layer mostly unbuilt** | Krypton (Autonomy Governor) | Governance checks are manual. No automated drift detection. | Planned in B2 — Krypton governance health check skill. |

---

## 5. Component Tool Reference

### ADF MCP Server (16 tools)

| Category | Tool | Description |
|----------|------|-------------|
| Orchestration | `get_stage` | Retrieve stage specs (discover/design/develop/deliver) |
| Orchestration | `get_review_prompt` | Review prompts (internal/external phases) |
| Orchestration | `get_transition_prompt` | Stage transition guidance with validation |
| Artifacts | `get_artifact_spec` | Artifact type specifications |
| Artifacts | `get_artifact_stub` | Starter templates for artifacts |
| Project | `get_project_type_guidance` | Project type classification guidance |
| Project | `check_project_structure` | Folder structure validation |
| Project | `check_project_health` | Structural health checks |
| Governance | `get_rules_spec` | Rules governance specification |
| Governance | `get_context_spec` | CLAUDE.md specification |
| Capabilities | `query_capabilities` | Search capabilities registry |
| Capabilities | `get_capability_detail` | Full capability metadata |
| Knowledge | `query_knowledge` | Search ADF knowledge base |

### Knowledge Base MCP Server (16 tools)

| Category | Tool | Description |
|----------|------|-------------|
| Query | `search_knowledge` | Semantic similarity search |
| Query | `get_item` | Single item by UUID |
| Query | `get_items` | Batch retrieval (max 20) |
| Query | `get_backlog` | Items with action_state=to_implement |
| Query | `get_ideas` | Items with content_type=idea |
| Query | `get_learnings` | Items with content_type=learning |
| Query | `get_to_read` | Items with action_state=to_read |
| Query | `get_recent` | Items within time window |
| Query | `get_focus_topics` | Current focus topics |
| Query | `get_stats` | KB statistics |
| Query | `get_unprocessed` | Unprocessed items |
| Write | `send_to_kb` | Unified entry point |
| Manage | `update_item` | Update metadata |
| Manage | `archive_item` | Archive item |
| Manage | `mark_complete` | Mark backlog item complete |
| Manage | `set_focus_topics` | Update focus topics |

### Memory MCP Server (15 tools)

| Category | Tool | Description |
|----------|------|-------------|
| Write | `write_memory` | Store memory with type/namespace/confidence |
| Query | `search_memories` | Search with filtering |
| Query | `get_memory` | Single memory by ID |
| Query | `get_recent` | Recent memories |
| Query | `get_session_context` | Session-contextual memories |
| Manage | `update_memory` | Update metadata |
| Manage | `archive_memory` | Archive memory |
| Manage | `review_candidates` | Candidates for review |
| Manage | `get_stats` | Store statistics |
| Manage | `reconcile_dual_store` | Storage consistency check |
| Admin | `list_failed_memories` | Failed operations |
| Admin | `retry_failed_memory` | Retry failed operation |
| Admin | `archive_failed_memory` | Archive failed record |
| Admin | `get_usage_report` | Usage metrics |
| Health | `health` | Service health check |

### Work Management MCP Server (40+ tools)

| Category | Tools |
|----------|-------|
| ADF Integration | `discover_local_projects`, `connect_local_project`, `sync_adf_project` |
| Projects | `list_projects`, `create_project`, `get_project`, `update_project`, `get_portfolio_status` |
| Plans | `list_plans`, `create_plan`, `update_plan`, `approve_plan` |
| Phases | `list_phases`, `create_phase`, `update_phase`, `start_phase`, `complete_phase` |
| Tasks | `list_tasks`, `get_task`, `create_task`, `update_task`, `complete_task`, `validate_task` |
| Backlog | `list_backlog`, `create_backlog_item`, `promote_backlog_item`, `promote_backlog` |
| Activity | `get_activity`, `get_blockers`, `get_deadlines` |
| Search | `search_work`, `whats_next` |

### External Review MCP Server (2 tools)

| Tool | Description |
|------|-------------|
| `review` | Send artifact for external model review |
| `list_models` | List available review models |

---

## Revision History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2026-02-11 | Initial — complete interface registry, data flow patterns, protocol standards, gap analysis |
