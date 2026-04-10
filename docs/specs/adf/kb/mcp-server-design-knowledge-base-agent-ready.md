---
title: MCP Server Design Knowledge Base (Agent-Ready)
version: "1.0"
last_updated: "2026-01-31"
intended_audience: "LLM agents designing/building MCP servers"
scope: "Design + implementation guidelines, constraints, and review checklists"
---

# MCP Server Design Knowledge Base (Agent-Ready)

This document is a **normative**, agent-ingestible synthesis of MCP server design tips, patterns, and constraints. It is written as **instructions** for an agent that will design or implement MCP servers.

## How to use this document

- Use **Section 2 (Non‑negotiables)** as system-level constraints.
- Use **Section 3 (Design workflow)** as the step-by-step method.
- Use **Section 8 (Review gates)** as acceptance criteria for PR reviews.
- Use **Section 12 (Prompt snippets)** to seed generator/reviewer agents.

---

## 1) Mental model

### 1.1 MCP server = “UI for an AI”
An MCP server is not a 1:1 REST wrapper. It is an **interaction surface optimized for LLM tool-selection and tool-use**.

**Primary implication:** expose **intent/outcome** tools, not atomic operations.

### 1.2 MCP server = capability adapter, not business logic monolith
Prefer **bounded contexts**. If you need many distinct domains, split into multiple servers.

### 1.3 The agent is stochastic
Design as if:
- requests will be retried,
- requests will be parallelized,
- inputs will be malformed,
- tool calls may be cancelled mid-flight,
- “almost correct” outputs will happen.

---

## 2) Non‑negotiables (MUST)

### 2.1 Minimize tool surface area
- MUST keep the tool list small and high-impact (target **5–15** tools per server).
- MUST NOT mirror entire downstream APIs.
- MUST remove “nice-to-have” and redundant tools.

**Reason:** large tool catalogs reduce tool-selection accuracy and waste context budget.

### 2.2 Stateless server layer
- MUST treat the MCP server as **stateless** at the protocol layer.
- MUST NOT store conversation history/session context in the server.
- If state is required, MUST store it in proper backends (DB/CRM/etc.) and reference it via stable identifiers.

### 2.3 Idempotency and safety
- MUST make tools safe to retry where feasible.
- MUST include an **idempotency key**/consistency token for mutating tools (client-provided UUID or stable business key).
- MUST avoid side-effects on partial failure; compensate or rollback when possible.

### 2.4 Authentication and authorization
- MUST enforce strong auth for any remote server (TLS + modern auth).
- MUST implement **least privilege** and scope separation.
- MUST NOT accept a token and pass it blindly to downstream systems (“token passthrough”).

### 2.5 Logging rule
- MUST NOT write logs to STDOUT for stdio transport (it corrupts JSON-RPC).
- MUST write logs to STDERR or a file sink.

### 2.6 Input validation & sanitization
- MUST validate and sanitize all tool inputs.
- MUST treat agent-provided input as untrusted (SQL/command/template injection risk).

---

## 3) Design workflow (agent procedure)

### Step 0 — Define the bounded context
- Identify domain, data sources, and what **must NOT** be accessible.
- Decide whether this should be a separate server.

### Step 1 — Write “Agent Stories”
For each story:
- Goal (what outcome is needed)
- Required inputs
- Required permissions
- Success criteria
- Failure modes & recovery hints

### Step 2 — Tool shaping (outcome-first)
For each agent story, propose **1 tool** that satisfies the outcome in a single round trip.

Rules:
- If the agent must know an algorithm or ordering to succeed, **encapsulate it inside the tool**.
- Prefer “do the thing” tools over “fetch primitives then compute” sequences.

### Step 3 — Tool schema design (strict and flat)
- Flatten arguments: prefer top-level primitives.
- Use enums/literals wherever possible.
- Minimize optional fields.
- Add explicit preconditions/postconditions in descriptions.

### Step 4 — Output contracts (typed)
- Prefer structured outputs (typed JSON).
- Use a defined output schema when supported by your MCP implementation.
- Include both human-readable summary and machine-readable fields.

### Step 5 — Safety and auth boundary review
- Determine required scopes per tool.
- Add progressive scope elevation if some actions are privileged.
- Confirm there is no ambient authority (filesystem/shell/network primitives) unless explicitly required.

### Step 6 — Failure semantics and error design
- Errors returned are “next prompts”: make them actionable.
- Include stable machine-readable error codes + human guidance.
- For “no results,” return hints or alternatives, not just “Not Found.”

### Step 7 — Operationalization
- Package in Docker where appropriate.
- Add observability (structured logs, correlation IDs, tracing).
- Add versioning for tools and schemas.
- Add kill switches / feature flags.

---

## 4) Tool design rubric

### 4.1 Naming
- Use **snake_case** tool names.
- Names MUST be distinct and disambiguated (avoid collisions like `search`, `lookup`, `get_info`).
- Use verbs and domain nouns: `check_order_status`, `create_customer_invoice`.

### 4.2 “One tool = one intent”
A tool should map to **one unambiguous action** with:
- clear inputs,
- deterministic outputs,
- bounded side effects.

### 4.3 Arguments
**Prefer**
- `customer_email: string`
- `order_number: string`
- `include_line_items: boolean`
- `status_filter: enum["open","closed","all"]`

**Avoid**
- nested configuration dicts
- free-form JSON objects
- “magic” query languages unless strictly necessary

### 4.4 Tool descriptions are prompts
Descriptions SHOULD include:
- when to use the tool
- when NOT to use it
- required permissions/scopes
- edge cases
- retry semantics / idempotency expectations
- example calls (sparingly)

**Example-overfitting caution:** examples bias the agent; include variety if you include any.

### 4.5 Outputs
A good tool output includes:
- `ok: boolean`
- `result: {...}` (typed)
- `summary: string` (short natural language)
- `warnings: [string]`
- `correlation_id: string`
- optional `next_actions: [enum|string]`

---

## 5) Runtime architecture and state

### 5.1 Stateless transport layer
- Do not keep conversational state in memory beyond a single request.
- Use backend systems for persistence.

### 5.2 Concurrency and cancellation
- Support timeouts.
- Respect request cancellation (especially for HTTP/SSE transports).
- Avoid stranded long-running tasks; use job patterns if needed.

### 5.3 Determinism and repeatability
- Validate inputs and outputs with schemas.
- Avoid nondeterministic fields unless necessary (timestamps should be explicit).

---

## 6) Security baseline (agent constraints)

### 6.1 Identity & auth
- Prefer OAuth/OIDC for remote servers.
- Ensure tokens are intended for this server and validated.
- Use short-lived tokens; avoid long-lived shared secrets.

### 6.2 Least privilege and scoped tools
- Define scopes per tool (read vs write vs admin).
- Avoid wildcard scopes.
- Use progressive scope elevation for high-risk operations.

### 6.3 Deny-by-default capability posture
- No filesystem, shell, or general network primitives unless explicitly required.
- If local servers execute code or access files, run in containers/sandboxes and restrict privileges.

### 6.4 Injection resistance
- Sanitize tool inputs.
- Use parameterized queries.
- Apply allowlists for file paths, domains, and commands if any are allowed at all.

---

## 7) Transport and deployment patterns

### 7.1 Local vs remote
- **Stdio**: best for local/private use; lowest latency; co-located with client.
- **HTTP (streamable)**: best for enterprise/scaled deployments; requires TLS + auth + gateway patterns.

### 7.2 Deployment defaults
- Containerize for consistency (especially when shipping to others).
- Provide a minimal config surface; secure defaults.
- Include explicit versioning in a manifest.

### 7.3 Gateway pattern (recommended for remote)
Put a gateway in front for:
- authentication
- rate limiting
- CORS
- audit logging

Keep server logic focused on tool implementation.

---

## 8) Review gates (checklists)

### Gate A — Tool catalog quality
- [ ] Tools are outcome-oriented (not CRUD mirroring).
- [ ] Tool count is small; no redundant overlap.
- [ ] Each tool is single-intent and well-scoped.
- [ ] Names are snake_case and unambiguous.

### Gate B — Schemas and contracts
- [ ] Inputs are flat; minimal optional fields.
- [ ] Enums/literals constrain choices where applicable.
- [ ] Output is structured and typed.
- [ ] Schema validation exists at runtime.

### Gate C — Safety & auth boundaries
- [ ] Auth is explicit and strong for remote transports.
- [ ] No token passthrough.
- [ ] Least privilege scopes per tool.
- [ ] No ambient authority primitives unless justified.

### Gate D — Reliability
- [ ] Mutations are idempotent (idempotency keys).
- [ ] Timeouts/cancellation are handled.
- [ ] Errors are actionable + coded.
- [ ] “No result” responses include hints/alternatives.

### Gate E — Operations
- [ ] Logging does not corrupt protocol (no STDOUT logs for stdio).
- [ ] Structured logs with correlation IDs.
- [ ] Versioning is defined and communicated.
- [ ] Kill switch / disable controls exist.

---

## 9) Anti-patterns (“Don’t do this”)

- Wrapping a REST API 1:1 into tools.
- Exposing hundreds of tools (“god server”).
- Nested argument objects that the agent must invent.
- Generic errors (500 / “Not Found”) with no recovery guidance.
- Stateful server sessions / conversation history in the MCP server.
- Token passthrough to downstream systems.
- Wildcard admin scopes.
- Logging to STDOUT in stdio mode.

---

## 10) Minimal templates

### 10.1 Tool definition skeleton (conceptual)
Use this as a pattern when defining tools (adapt to your MCP SDK):

- **name:** `snake_case`
- **description:** includes use/avoid, inputs, scopes, edge cases, retry/idempotency
- **input schema:** flat primitives + enums
- **output schema:** `ok`, typed `result`, `summary`, `warnings`, `correlation_id`
- **error model:** `error_code`, `message`, `remediation`

### 10.2 Error code conventions (recommended)
- `INVALID_ARGUMENT`
- `UNAUTHORIZED`
- `FORBIDDEN`
- `NOT_FOUND`
- `CONFLICT`
- `RATE_LIMITED`
- `DOWNSTREAM_TIMEOUT`
- `DOWNSTREAM_ERROR`
- `INTERNAL_ERROR`

Each error MUST include:
- actionable message
- what the agent can change
- if retry is safe (and with what idempotency key)

---

## 11) Primary references (canonical links)
- https://modelcontextprotocol.io/docs/learn/server-concepts
- https://modelcontextprotocol.io/docs/develop/build-server
- https://modelcontextprotocol.info/docs/best-practices/
- https://code.visualstudio.com/docs/copilot/customization/mcp-servers
- https://workos.com/blog/mcp-security-risks-best-practices
- https://protocolguard.com/resources/mcp-server-hardening/
- https://aembit.io/blog/securing-mcp-server-communications-best-practices/
- https://learn.microsoft.com/en-us/azure/developer/azure-mcp-server/overview
- https://learn.microsoft.com/en-us/azure/developer/azure-mcp-server/tools/azure-best-practices
- https://learn.microsoft.com/en-us/azure/app-service/configure-authentication-mcp-server-vscode
- https://learn.microsoft.com/en-us/training/support/mcp-best-practices
- https://modelcontextprotocol.io/

---

## 12) Agent prompt snippets

### 12.1 Generator agent (system or developer)
> Design MCP servers as minimal, secure capability adapters. Prefer outcome-oriented tools, strict flat schemas, least-privilege auth scopes, stateless operation, idempotent mutations, actionable coded errors, and observable deployments. Do not mirror REST APIs 1:1. Keep tool count small.

### 12.2 Reviewer agent (design review)
> Review this MCP server design for tool-surface bloat, schema ambiguity, missing idempotency, weak auth boundaries, token passthrough, ambient authority, non-actionable errors, and protocol-corrupting logging. Block any issues that would harm reliability or security.
