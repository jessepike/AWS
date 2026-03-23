# Capture Envelope Standard

Status: active  
Version: `aws.capture-envelope.v1`  
Owner: Agentic Work System (umbrella)

## Purpose

Define one capture contract used across projects so parsing, routing, and downstream triage stay consistent.

## Core Decisions

- Backlog-first routing is default for work-capture channels.
- Capability keywords are topics (not dependencies): `mcp`, `skills`, `context`, `memory`, `plugins`, `agents`.
- Memory writes are opt-in (not automatic from capture).
- Namespace defaults to `global` unless project scope is explicitly set.

## Envelope Schema (v1)

```json
{
  "schema_version": "aws.capture-envelope.v1",
  "created_at": "2026-02-19T00:00:00.000Z",
  "source": "human|agent|automation|api",
  "source_ref": "string|null",
  "idempotency_key": "string|null",
  "raw_text": "string",
  "normalized_text": "string",
  "intents": ["task|learning|idea|note|unknown"],
  "topics": ["mcp", "diagram-forge", "skills"],
  "project_hint": "diagram-forge|null",
  "route": {
    "primary_target": "backlog|knowledge_base|memory",
    "strategy": "project_backlog|inbox_backlog|kb_ingest|memory_write",
    "project_slug": "diagram-forge|null",
    "project_id": "uuid|null"
  }
}
```

## Routing Rules

1. Parse hashtags into `topics[]`.
2. Match project by slug from topics (`#diagram-forge` => project slug candidate).
3. For work capture channels, always route to backlog:
- project match => `project_backlog`
- no match => `inbox_backlog`
Specialized ingestion channels (example: link triage) may set a different primary target (`knowledge_base`) with a channel-specific strategy (`kb_ingest`).
4. KB and Memory are secondary flows:
- KB via triage/promotion for learning/reference items.
- Memory only explicit/manual until memory reliability is finalized.

## Adoption Contract

Each project that captures work must:

1. Produce `capture_envelope` with `schema_version`.
2. Preserve envelope in its native metadata field.
3. Emit routing telemetry with `capture_schema_version` and `topics`.
4. Add fixture tests that validate parsing and route behavior.

## Conformance Fixtures

Minimal required fixture set:

1. `"need to validate diagram forge mcp server is ready #diagram-forge #mcp"`
- route: `project_backlog`
- topics include: `diagram-forge`, `mcp`

2. `"capture tip about prompt chaining #skills"`
- route: `inbox_backlog`
- topics include: `skills`

3. `"review memory consolidation approach #memory"`
- route: `inbox_backlog`
- topics include: `memory`

## References

- Pipeline visual: `docs/standards/capture-pipeline-visual.md`
- Shared fixtures: `docs/standards/capture-envelope-fixtures.json`
- Work-management implementation: `~/code/_shared/work-management/src/lib/capture/envelope.ts`
