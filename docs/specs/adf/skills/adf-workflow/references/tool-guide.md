# ADF MCP Server — Tool Guide

Per-tool usage reference. All tools are read-only and return text content.

---

## Orchestration Tools

### get_stage

Get stage requirements and workflow details.

| Parameter | Type | Required | Values |
|-----------|------|----------|--------|
| `stage` | string | yes | `discover`, `design`, `develop`, `deliver` |

**Use when:** An agent needs to understand what a stage involves — phases, entry/exit criteria, expected outputs.
**Do not use for:** Transition guidance (use `get_transition_prompt`).

### get_review_prompt

Get the review prompt for a stage and review phase.

| Parameter | Type | Required | Values |
|-----------|------|----------|--------|
| `stage` | string | yes | `discover`, `design`, `develop`, `deliver` |
| `phase` | string | yes | `internal`, `external` |

**Use when:** Preparing to run a Ralph Loop (internal) or external review.
**Returns:** Full prompt text ready to pass to the review mechanism.

### get_transition_prompt

Get guidance for transitioning between stages.

| Parameter | Type | Required | Values |
|-----------|------|----------|--------|
| `transition` | string | yes | `discover_to_design`, `design_to_develop`, `develop_to_deliver` |
| `validate` | boolean | no | `true` to check prerequisites against project state |
| `project_path` | string | when validate=true | Path to the project root |

**Use when:** Moving a project from one stage to the next.
**Validate mode:** Reads `status.md` and `brief` to check prerequisites. Brief fallback: globs `docs/inbox/*-brief.md`, picks newest; errors if multiple candidates.

---

## Artifact Tools

### get_artifact_spec

Get the ADF specification for an artifact type.

| Parameter | Type | Required | Values |
|-----------|------|----------|--------|
| `artifact` | string | yes | `brief`, `intent`, `status`, `claude_md`, `rules`, `backlog` |

**Use when:** You need to know what a valid artifact looks like — required sections, frontmatter, formatting.

### get_artifact_stub

Get a starter template for an artifact.

| Parameter | Type | Required | Values |
|-----------|------|----------|--------|
| `artifact` | string | yes | `brief`, `intent`, `status`, `claude_md`, `rules`, `backlog` |
| `project_type` | string | no | For `claude_md` only: `framework`, `library`, `application`, `pipeline`, `integration` |

**Use when:** Initializing a new project or creating a new artifact.
**Note:** `claude_md` stubs vary by project type. Other artifacts ignore `project_type`.

---

## Project Tools

### get_project_type_guidance

Get guidance for a project type classification.

| Parameter | Type | Required | Values |
|-----------|------|----------|--------|
| `project_type` | string | yes | `framework`, `library`, `application`, `pipeline`, `integration` |

**Use when:** During Discover or Design to understand what outputs, review focus, and structure a project type requires.

### check_project_structure

Validate folder structure against ADF spec.

| Parameter | Type | Required |
|-----------|------|----------|
| `project_path` | string | yes |

**Use when:** After scaffolding a project or during audits.
**Returns:** Per-item pass/fail for required directories and files.

### check_project_health

Run structural health checks on a project.

| Parameter | Type | Required |
|-----------|------|----------|
| `project_path` | string | yes |

**Use when:** Pre-review validation or project audits.
**Checks:** File presence, frontmatter validity, required sections (via regex header matching).
**Does not:** Perform semantic analysis of content quality.

---

## Governance Tools

### get_rules_spec

Get the ADF rules governance specification. No parameters.

**Use when:** Setting up or auditing `.claude/rules/` — covers categories, file organization, lifecycle.

### get_context_spec

Get the CLAUDE.md context specification.

| Parameter | Type | Required | Values |
|-----------|------|----------|--------|
| `level` | string | yes | `global`, `project` |

**Use when:** Creating or auditing CLAUDE.md files — covers required sections, global vs project differences.

---

## Capabilities Tools

### query_capabilities

Search the capabilities registry.

| Parameter | Type | Required |
|-----------|------|----------|
| `keyword` | string | no |
| `type` | string | no |
| `tags` | string | no |

**Use when:** Finding available tools, skills, agents, or plugins for a task.
**At least one** parameter should be provided. Filters are AND-combined.

### get_capability_detail

Get full details for a specific capability.

| Parameter | Type | Required |
|-----------|------|----------|
| `capability_id` | string | yes |

**Use when:** You need installation instructions, configuration, or full metadata.
**ID format:** Must match the registry ID pattern (e.g., `skill-external-review`).

---

## Knowledge Tools

### query_knowledge

Search ADF knowledge base entries.

| Parameter | Type | Required |
|-----------|------|----------|
| `query` | string | yes |

**Use when:** Looking up process learnings, design patterns, or operational knowledge.
**Matching:** Case-insensitive text match across KB article titles and content.
**Returns:** Title, snippet, and file path for each match.

---

## Common Sequences

### New project setup
```
get_artifact_stub("intent") → fill in intent.md
get_artifact_stub("brief") → fill in brief.md
get_project_type_guidance(type) → understand requirements
get_artifact_stub("claude_md", type) → create CLAUDE.md
check_project_structure(path) → verify
```

### Pre-review checklist
```
check_project_health(path) → fix any failures
get_review_prompt(stage, "internal") → run Ralph Loop
```

### Stage transition
```
get_transition_prompt(transition, validate=true) → check readiness
get_stage(next_stage) → understand what's ahead
```
