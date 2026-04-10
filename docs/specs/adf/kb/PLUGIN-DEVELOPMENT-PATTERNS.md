---
type: "knowledge"
description: "Patterns and lessons learned from building Claude Code plugins — delegation, command prompts, hooks, and common mistakes"
updated: "2026-01-30"
scope: "adf"
lifecycle: "reference"
---

# Plugin Development Patterns

## Delegation Pattern

Plugins that orchestrate other plugins must use **explicit delegation** — vague instructions like "if available, delegate" result in agents choosing fallbacks every time.

### What doesn't work

```markdown
**If `claude-md-management` is available:**
- Delegate CLAUDE.md quality scoring to it
- Report the score and any recommendations
```

The agent has no concrete instructions for *how* to delegate. It takes the path of least resistance: the fallback.

### What works

```markdown
**If `claude-md-management` is installed and enabled** (check-deps.sh reports PASS):

You MUST delegate by using the claude-md-improver skill. Specifically:
1. Find all CLAUDE.md files
2. For each file, evaluate against the quality criteria...
3. Score each file (A-F grade, X/100)
4. List specific issues and recommended additions
```

Key elements:
- **"You MUST delegate"** — removes agent discretion
- **Name the specific skill/command** to invoke
- **List concrete steps** the agent should take when delegating
- **Gate fallbacks explicitly** — "ONLY if plugin is missing"

### Checking dependency availability

Don't check filesystem paths — marketplace plugins live in the cache, not at predictable paths. Use `installed_plugins.json`:

```bash
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

## Command Prompts vs Hook Scripts

Commands (`.md` files in `commands/`) are **prompts read by an LLM agent**. They are not executed code. This has implications:

| Feature | Commands (prompts) | Hooks (scripts) |
|---------|-------------------|-----------------|
| `${CLAUDE_PLUGIN_ROOT}` | NOT expanded — use full paths | Expanded at runtime |
| ANSI color codes | NOT rendered — agent outputs plain text | Work via `printf`/`echo -e` |
| Execution | Agent interprets and acts | Shell executes directly |
| File references | Use full marketplace paths | Use `${CLAUDE_PLUGIN_ROOT}` |

### Path strategy

- **In commands**: `~/.claude/plugins/acm-plugins/plugins/<name>/path/to/file`
- **In hooks**: `${CLAUDE_PLUGIN_ROOT}/path/to/file`
- **In shell scripts**: Query `installed_plugins.json` or use `$HOME` relative paths

## hooks.json Schema

Must be a **record keyed by event name**, not an array.

```json
{
  "description": "What these hooks do",
  "hooks": {
    "EventName": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/hooks/scripts/my-script.sh"
          }
        ],
        "matcher": "OptionalToolNamePattern"
      }
    ]
  }
}
```

Valid events: `PreToolUse`, `PostToolUse`, `Stop`, `SubagentStop`, `SessionStart`, `SessionEnd`, `UserPromptSubmit`, `PreCompact`, `Notification`.

## plugin.json Must Be Minimal

Only include: `name`, `description`, `version`, `author` (as object).

Do NOT include:
- `commands` array — auto-discovered from `commands/` directory
- `skills` array — auto-discovered from `skills/` directory
- `agents` array — auto-discovered from `agents/` directory

## Cache Is a Snapshot

The plugin cache (`~/.claude/plugins/cache/`) is copied at install time. Source edits don't propagate automatically.

**During development**: Copy changed files directly to cache for fast iteration.
**For releases**: Bump version → `claude plugin marketplace update` → `claude plugin update`.

Always restart the Claude Code session after changes.

## Capabilities Registry Integration

Plugins that manage the environment should cross-reference the capabilities registry at `~/code/_shared/capabilities-registry/INVENTORY.md` to validate that expected capabilities are installed and current.

This enables:
- Detecting uninstalled capabilities (opportunities)
- Detecting untracked capabilities (installed but not registered)
- Validating the environment matches the declared baseline
