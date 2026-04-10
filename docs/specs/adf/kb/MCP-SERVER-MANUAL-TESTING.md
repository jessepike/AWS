---
type: "knowledge"
description: "How to manually test MCP servers using the MCP Inspector and Claude in Chrome browser automation"
updated: "2026-01-31"
scope: "adf"
lifecycle: "reference"
tags: ["mcp", "testing", "inspector", "browser-automation"]
---

# MCP Server Manual Testing via Inspector

## When to Use

After building an MCP server (build passes, automated tests green), use the MCP Inspector for interactive manual testing before marking the build complete. This validates the server end-to-end over the real stdio transport, not just unit test handler calls.

## Setup

### 1. Start the Inspector

From the server's build directory:

```bash
cd <server-dir>
npx @modelcontextprotocol/inspector node build/index.js
```

The Inspector prints a URL with an auth token:

```
⚙️ Proxy server listening on localhost:6277
🔑 Session token: <token>
🚀 MCP Inspector is up and running at:
   http://localhost:6274/?MCP_PROXY_AUTH_TOKEN=<token>
```

**Use the full URL with the token** — the Inspector (v0.19.0+) requires it for authentication.

### 2. Port Conflicts

If you see `PORT IS IN USE`, kill existing Inspector processes:

```bash
kill $(lsof -t -i :6277 -i :6274) 2>/dev/null
sleep 2
npx @modelcontextprotocol/inspector node build/index.js
```

Or use alternate ports:

```bash
CLIENT_PORT=5199 SERVER_PORT=6299 npx @modelcontextprotocol/inspector node build/index.js
```

### 3. Connect

Open the URL in Chrome. Click **Connect**. You should see:
- Green "Connected" indicator
- Server name and version in the sidebar
- `initialize` in the History panel

Click **List Tools** to see all registered tools with descriptions.

## Testing with Claude in Chrome

If using Claude Code's browser automation (`mcp__claude-in-chrome__*` tools):

1. Start Inspector from the terminal (Bash tool with `run_in_background`)
2. Capture the full URL with auth token from stdout
3. Navigate to the URL using `mcp__claude-in-chrome__navigate`
4. Click Connect, then List Tools
5. For each tool: select it, fill parameters, click Run Tool, verify the result

### UI Interaction Notes

- **Enum fields** (like `stage`) render as **dropdowns** — click to open, then select the value
- **Text fields** (like `project_path`) are text inputs — click and type
- **Array fields** (like `tags`) have an "Add Item" button or "Switch to JSON" toggle
- **Boolean fields** may render as checkboxes
- **Results** appear below the Run Tool button — scroll down on the right panel to see them
- The **History panel** at the bottom tracks all JSON-RPC calls (initialize, tools/list, tools/call)

## Testing Strategy

Test **one tool per category** for breadth, then spot-check edge cases:

| What to Test | Why |
|--------------|-----|
| One tool per category | Verifies all tool modules are wired correctly |
| Path inputs with `~` | Validates tilde expansion |
| Enum values | Confirms zod schema enums match Inspector UI |
| Missing/invalid inputs | Confirms error responses (isError) work |
| Tools that read files | Validates file access from the server's working directory |

### Example Test Sequence (ACM Server)

| # | Tool | Input | Validates |
|---|------|-------|-----------|
| 1 | `get_stage` | `stage: discover` | Orchestration category, enum input, file reading |
| 2 | `check_project_structure` | `project_path: ~/code/_shared/acm` | Project category, tilde expansion, directory scanning |
| 3 | `query_capabilities` | `query: review` | Capabilities category, registry search, JSON parsing |
| 4 | `query_knowledge` | `query: plugin` | Knowledge category, KB text matching |

## Checklist

- [ ] Inspector starts and connects (server responds to `initialize`)
- [ ] `tools/list` returns expected tool count
- [ ] At least one tool per category returns Success
- [ ] Path inputs with tilde resolve correctly
- [ ] Invalid inputs return `isError: true` with actionable message (not a crash)
- [ ] No stdout pollution (all logging goes to stderr)
