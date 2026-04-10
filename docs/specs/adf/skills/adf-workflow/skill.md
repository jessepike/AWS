# ADF Workflow Skill

This skill teaches agents how to use ADF MCP server tools within the context of ADF stage workflows (Discover, Design, Develop, Deliver).

## When to Use

- Starting or scaffolding a new ADF project
- Navigating stage transitions
- Preparing for or running reviews
- Auditing project structure or health
- Looking up ADF specs, stubs, or governance rules
- Searching capabilities or knowledge base

## ADF Stage Workflow

| Stage | Purpose | Key Activities |
|-------|---------|----------------|
| Discover | Understand the problem | Define intent, write brief, classify project type |
| Design | Plan the solution | Create specs, define architecture, validate approach |
| Develop | Build it | Implement, test, iterate against spec |
| Deliver | Ship it | Final review, documentation, handoff |

Each stage has phases: **Align** (prepare), **Build** (execute), **Review** (validate).

## Tool Reference

| Category | Tools | When to Use |
|----------|-------|-------------|
| Orchestration | `get_stage`, `get_review_prompt`, `get_transition_prompt` | Understanding stages, running reviews, transitioning |
| Artifacts | `get_artifact_spec`, `get_artifact_stub` | Creating or validating artifacts |
| Project | `get_project_type_guidance`, `check_project_structure`, `check_project_health` | Scaffolding, auditing, pre-review checks |
| Governance | `get_rules_spec`, `get_context_spec` | Setting up rules or CLAUDE.md files |
| Capabilities | `query_capabilities`, `get_capability_detail` | Finding tools/skills/plugins for a task |
| Knowledge | `query_knowledge` | Looking up process learnings and patterns |

## Common Workflows

### Start a New Project

1. `get_artifact_stub("brief")` — get the brief template
2. `get_artifact_stub("intent")` — get the intent template
3. `get_artifact_stub("claude_md", project_type)` — get project CLAUDE.md template
4. `get_project_type_guidance(type)` — understand what the project type requires
5. `check_project_structure(path)` — verify scaffold is correct

### Prepare for Review

1. `check_project_health(path)` — pre-flight structural checks
2. `get_review_prompt(stage, phase)` — get the review prompt for current stage
3. Run review via Ralph Loop with the returned prompt

### Transition Between Stages

1. `get_transition_prompt(transition, validate=true)` — check prerequisites and get guidance
2. Address any validation failures
3. `get_stage(target_stage)` — understand what the next stage involves

### Audit a Project

1. `check_project_structure(path)` — folder structure validation
2. `check_project_health(path)` — artifact health checks
3. `get_artifact_spec(type)` — look up specs for any failing artifacts

### Find Capabilities

1. `query_capabilities(keyword/type/tags)` — search for matching capabilities
2. `get_capability_detail(id)` — get full details for a specific capability

## Tool Naming

All tools use flat names (no dots or slashes). When the MCP server is registered, tools appear as `get_stage`, `check_project_health`, etc. No namespace prefix collisions with other MCP servers.

## Reference

For per-tool parameter details and usage examples, see `references/tool-guide.md`.
