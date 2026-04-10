---
type: "knowledge"
description: "How to create, validate, and install custom Claude Code plugins via a local marketplace"
updated: "2026-01-30"
scope: "adf"
lifecycle: "reference"
---

# Custom Plugin Installation Guide

## Overview

Claude Code plugins must be installed through a **marketplace**. Custom plugins require a local marketplace to act as a registry. This guide covers creating a marketplace, validating plugins, and installing them.

## Architecture

```
~/.claude/plugins/
├── acm-plugins/                    # Local marketplace (source of truth)
│   ├── .claude-plugin/
│   │   └── marketplace.json        # Marketplace manifest — lists all plugins
│   └── plugins/
│       └── <plugin-name>/          # Plugin source directory
│           ├── .claude-plugin/
│           │   └── plugin.json     # Plugin manifest
│           ├── commands/           # Slash commands (auto-discovered)
│           ├── skills/            # Skills (auto-discovered)
│           ├── hooks/             # Hooks
│           │   ├── hooks.json     # Hook definitions
│           │   └── scripts/       # Hook scripts
│           ├── agents/            # Agents (auto-discovered)
│           ├── scripts/           # Utility scripts
│           └── README.md
├── cache/                          # Claude Code copies plugins here on install
│   └── acm-plugins/
│       └── <plugin-name>/
│           └── <version>/          # Snapshot at install time
├── marketplaces/                   # Marketplace metadata (managed by CLI)
│   └── claude-plugins-official/
├── installed_plugins.json          # Install registry
└── known_marketplaces.json         # Marketplace registry
```

## Step-by-Step

### 1. Create the marketplace directory

```bash
mkdir -p ~/.claude/plugins/acm-plugins/.claude-plugin
mkdir -p ~/.claude/plugins/acm-plugins/plugins
```

### 2. Create marketplace.json

File: `~/.claude/plugins/acm-plugins/.claude-plugin/marketplace.json`

```json
{
  "$schema": "https://anthropic.com/claude-code/marketplace.schema.json",
  "name": "acm-plugins",
  "description": "Custom ACM framework plugins",
  "owner": {
    "name": "Your Name"
  },
  "plugins": [
    {
      "name": "plugin-name",
      "description": "What the plugin does",
      "version": "1.0.0",
      "author": {
        "name": "Your Name"
      },
      "source": "./plugins/plugin-name",
      "category": "productivity"
    }
  ]
}
```

### 3. Create the plugin

Place plugin source at `~/.claude/plugins/acm-plugins/plugins/<plugin-name>/`.

**Plugin manifest** (`.claude-plugin/plugin.json`) — keep it minimal:

```json
{
  "name": "plugin-name",
  "description": "What the plugin does",
  "version": "1.0.0",
  "author": {
    "name": "Your Name"
  }
}
```

### 4. Hooks format

File: `hooks/hooks.json`

```json
{
  "description": "What these hooks do",
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/hooks/scripts/my-script.sh"
          }
        ]
      }
    ]
  }
}
```

### 5. Validate, register, and install

```bash
# Validate plugin structure first
claude plugin validate ~/.claude/plugins/acm-plugins/plugins/plugin-name/

# Register the marketplace (first time only)
claude plugin marketplace add ~/.claude/plugins/acm-plugins

# Install the plugin (scope: user by default)
claude plugin install plugin-name@acm-plugins

# Verify — must show "enabled", not "failed to load"
claude plugin list

# Restart Claude Code session to activate
```

## Adding more plugins to the marketplace

1. Add plugin source to `~/.claude/plugins/acm-plugins/plugins/<new-plugin>/`
2. Add entry to `marketplace.json` plugins array
3. Validate: `claude plugin validate <path>`
4. Run: `claude plugin marketplace update acm-plugins`
5. Run: `claude plugin install new-plugin@acm-plugins`
6. Restart session

## Updating an existing plugin

After modifying plugin source files:
1. Bump version in both `marketplace.json` and the plugin's `plugin.json`
2. Run: `claude plugin marketplace update acm-plugins`
3. Run: `claude plugin update plugin-name@acm-plugins`
4. Restart session

**Critical**: The cache (`~/.claude/plugins/cache/`) is a snapshot copied at install time. Editing source files alone does nothing — you must bump version and update/reinstall to propagate changes. During development, you can also manually copy changed files into the cache directory for faster iteration.

## Common Pitfalls

These are mistakes we encountered building the adf-env plugin. Learn from them.

### plugin.json must be minimal

The manifest only needs `name`, `description`, `version`, and `author`. Everything else is auto-discovered.

**Wrong** — do not list commands in plugin.json:
```json
{
  "name": "my-plugin",
  "author": "Jesse Pike",
  "commands": [
    { "name": "status", "description": "..." }
  ]
}
```

**Right**:
```json
{
  "name": "my-plugin",
  "author": { "name": "Jesse Pike" }
}
```

Errors this prevents:
- `author: Invalid input: expected object, received string`
- `commands: Invalid input`

### hooks.json must be a record, not an array

**Wrong**:
```json
{
  "hooks": [
    { "event": "SessionStart", "command": "..." }
  ]
}
```

**Right**:
```json
{
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          { "type": "command", "command": "${CLAUDE_PLUGIN_ROOT}/hooks/scripts/my-script.sh" }
        ]
      }
    ]
  }
}
```

Error this prevents: `Hook load failed: expected record, received array`

### Use ${CLAUDE_PLUGIN_ROOT} in hooks, marketplace paths in commands

- **Hook scripts**: Use `${CLAUDE_PLUGIN_ROOT}` — resolved at runtime by Claude Code
- **Command markdown** (prompts read by the agent): Use the full marketplace path `~/.claude/plugins/acm-plugins/plugins/<name>/...` because `${CLAUDE_PLUGIN_ROOT}` is NOT expanded in prompt text
- **Shell scripts**: Use `$HOME` or resolve paths from `installed_plugins.json`

### Scripts that check for other plugins must use the registry

Plugins installed via marketplace live in `~/.claude/plugins/cache/<marketplace>/<name>/<version>/`, NOT at `~/.claude/plugins/<name>/`. To check if a dependency plugin is installed:

```bash
# Check installed_plugins.json, not filesystem paths
INSTALLED="$HOME/.claude/plugins/installed_plugins.json"
python3 -c "
import json, sys
with open('$INSTALLED') as f:
    data = json.load(f)
for key in data.get('plugins', {}):
    if key.startswith('plugin-name@'):
        print(key); sys.exit(0)
sys.exit(1)
"
```

### Cache is a snapshot — source edits don't auto-propagate

After editing source files during development:
- **Quick iteration**: Copy changed files directly into `~/.claude/plugins/cache/acm-plugins/<name>/<version>/`
- **Proper update**: Bump version → `claude plugin marketplace update` → `claude plugin update`
- Always restart the Claude Code session after changes

### Plugin source must live inside the marketplace directory

Plugin `source` in marketplace.json must be a relative path within the marketplace (e.g., `./plugins/my-plugin`). Absolute paths and paths outside the marketplace directory will fail with `Invalid input` on source.

## Troubleshooting

| Symptom | Cause | Fix |
|---------|-------|-----|
| "Unknown skill" when running `/plugin:command` | Plugin not installed or not enabled | `claude plugin list` to check status |
| "failed to load" + hook error | hooks.json uses array instead of record | Rewrite hooks as record keyed by event name |
| "Invalid input" on author | `author` is a string | Change to `{ "name": "..." }` |
| "Invalid input" on commands | `commands` array in plugin.json | Remove it — commands are auto-discovered |
| "Invalid input" on source | Absolute or external path in marketplace.json | Use relative path within marketplace dir |
| Plugin installed but changes not visible | Cache is stale | Bump version, update, restart session |
| Script can't find dependency plugins | Checking filesystem paths instead of registry | Query `installed_plugins.json` |
| Plugin shows "enabled" but commands don't work | Session not restarted after install | Exit and restart Claude Code |

## CLI Reference

```bash
# Marketplace management
claude plugin marketplace add <path>          # Register marketplace
claude plugin marketplace list                # Show marketplaces
claude plugin marketplace update [name]       # Refresh from source
claude plugin marketplace remove <name>       # Unregister marketplace

# Plugin management
claude plugin install <name>@<marketplace>    # Install plugin
claude plugin uninstall <name>@<marketplace>  # Remove plugin
claude plugin enable <name>@<marketplace>     # Enable disabled plugin
claude plugin disable <name>@<marketplace>    # Disable plugin
claude plugin update <name>@<marketplace>     # Update to latest version

# Validation and inspection
claude plugin validate <path>                 # Validate manifest
claude plugin list                            # List all plugins with status
```
