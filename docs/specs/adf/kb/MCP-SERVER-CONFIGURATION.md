# MCP Server Configuration in Claude Code

## Overview

MCP servers and plugins are **separate subsystems** in Claude Code. Plugins are managed via `enabledPlugins` in `settings.json`. MCP servers have their own configuration and lifecycle.

## Configuration Locations

| Scope | File | Purpose |
|-------|------|---------|
| User | `~/.claude.json` → `mcpServers` key | Cross-project personal servers |
| Project (shared) | `.mcp.json` at project root | Team-shared, checked into git |
| Project (local) | `~/.claude.json` → `projects.<path>.mcpServers` | Per-project personal overrides |
| Managed | `/Library/Application Support/ClaudeCode/managed-mcp.json` (macOS) | IT-administered |

### Priority (highest to lowest)

1. Local project scope (`~/.claude.json` → `projects.<path>.mcpServers`)
2. Shared project scope (`.mcp.json`)
3. User scope (`~/.claude.json` → `mcpServers`)

## Plugin-Bundled MCP Servers

Plugins from the marketplace can bundle MCP servers. These are stored at:

```
~/.claude/plugins/marketplaces/claude-plugins-official/external_plugins/<name>/.mcp.json
```

These activate automatically when their parent plugin is enabled in `settings.json`. They are **not** listed in `~/.claude.json`.

### Currently Available (marketplace)

| Server | Transport | URL/Command |
|--------|-----------|-------------|
| github | http | `https://api.githubcopilot.com/mcp/` |
| supabase | http | `https://mcp.supabase.com/mcp` |
| stripe | http | `https://mcp.stripe.com` |
| context7 | stdio | `npx -y @upstash/context7-mcp` |
| playwright | stdio | `npx @playwright/mcp@latest` |
| firebase | stdio | `npx -y firebase-tools@latest mcp` |
| gitlab | http | `https://gitlab.com/api/v4/mcp` |
| greptile | http | `https://api.greptile.com/mcp` |
| linear | http | `https://mcp.linear.app/mcp` |
| asana | sse | `https://mcp.asana.com/sse` |
| slack | sse | `https://mcp.slack.com/sse` |
| laravel-boost | stdio | `php artisan boost:mcp` |
| serena | stdio | `uvx --from git+... serena start-mcp-server` |

## Key Settings

| Setting | Location | Purpose |
|---------|----------|---------|
| `enableAllProjectMcpServers` | `~/.claude/settings.json` | If `true`, auto-approves project `.mcp.json` servers. Default `false` (prompts for approval). |
| `enabledPlugins.<name>` | `~/.claude/settings.json` | Controls plugin-bundled MCP servers indirectly. |

## CLI Commands

```bash
claude mcp add <name> --transport <type> --scope <user|project> <url>
claude mcp remove <name>
claude mcp list
claude mcp reset-project-choices   # Reset approval for project MCP servers
```

## How to Check MCP State Programmatically

**User-level standalone servers:**
```bash
python3 -c "import json; data=json.load(open('$HOME/.claude.json')); print(json.dumps(data.get('mcpServers', {}), indent=2))"
```

**Project-level servers (local overrides):**
```bash
python3 -c "
import json, os
data=json.load(open(os.path.expanduser('~/.claude.json')))
proj = data.get('projects', {}).get(os.getcwd(), {})
print(json.dumps(proj.get('mcpServers', {}), indent=2))
"
```

**Project-level servers (shared):**
```bash
cat .mcp.json 2>/dev/null || echo "none"
```

**Plugin-bundled servers (enabled state via parent plugin):**
```bash
python3 -c "
import json
data=json.load(open(os.path.expanduser('~/.claude/settings.json')))
for k,v in sorted(data.get('enabledPlugins', {}).items()):
    print(f'{k}: {\"enabled\" if v else \"disabled\"}')"
```

## Subagent Visibility Issue

**Problem:** MCP servers configured at project level (`.mcp.json`) may not be visible to subagents launched via the Task tool.

**Symptom:** Main session can access MCP tools, but subagents (e.g., ralph-loop, external-review agents) report "MCP server not available."

**Root cause:** Subagents don't inherit project-level MCP server connections when launched via Task tool.

**Solution:** Configure MCP servers at **user level** in `~/.claude.json` → `mcpServers` instead of project-level `.mcp.json`.

### Configuration Format

User-level MCP servers in `~/.claude.json`:

```json
{
  "mcpServers": {
    "adf": {
      "type": "stdio",
      "command": "node",
      "args": ["/Users/username/code/_shared/adf/adf-server/build/index.js"],
      "env": {
        "ADF_ROOT": "/Users/username/code/_shared/adf"
      }
    },
    "external-review": {
      "type": "stdio",
      "command": "/path/to/venv/bin/python",
      "args": ["/path/to/external_review_server.py"],
      "env": {}
    }
  }
}
```

**After making changes:** Restart Claude Code completely (quit and relaunch) for user-level MCP config to take effect.

**Verification:** Run `/mcp` command. You should see:
- **Project MCPs** section (from `.mcp.json`)
- **User MCPs** section (from `~/.claude.json` → `mcpServers`) ← should include your servers
- **Built-in MCPs** section

## Implications for adf-env Status

The status check should report:

1. **User-level MCP servers** — read `~/.claude.json` → `mcpServers`
2. **Project-level MCP servers** — read `.mcp.json` + `~/.claude.json` → `projects.<cwd>.mcpServers`
3. **Plugin-bundled MCP servers** — cross-reference `external_plugins/` with `enabledPlugins` in `settings.json`
4. **Remove list** — flag any configured server that matches the baseline `remove` list

---

*Created: 2026-01-31*
*Updated: 2026-02-02 — Added subagent visibility troubleshooting*
*Source: Research during B34 implementation + troubleshooting session*
