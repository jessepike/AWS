---
type: "knowledge"
description: "Diagnosing and fixing stale ralph-loop state files that block session stops"
updated: "2026-01-31"
scope: "adf"
lifecycle: "reference"
tags: ["ralph-loop", "hooks", "troubleshooting", "stop-hook"]
---

# Ralph Loop Stale State File

## Symptom

Session cannot end. The stop hook repeatedly fires the same prompt (e.g., a design review prompt) as a blocking error, even though no Ralph Loop is actively running.

## Cause

The ralph-loop plugin uses a state file (`.claude/ralph-loop.local.md`) to track active loops. The Stop hook checks for this file — if present, it blocks the session stop and feeds the stored prompt back to Claude.

If a Ralph Loop is interrupted without completing (session crash, manual cancel, context overflow), the state file persists. Every subsequent stop attempt triggers the hook, which reads the stale prompt and blocks exit.

## Fix

```bash
rm .claude/ralph-loop.local.md
```

The file is in the project root's `.claude/` directory. Once removed, the stop hook passes (`exit 0` at the "no state file" check).

## Prevention

- Always let Ralph Loops complete or use `/ralph-loop:cancel-ralph` to cleanly terminate
- If a session crashes mid-loop, check for the state file at the start of the next session
- The file is `.gitignore`-safe (untracked) — it won't pollute commits

## How the Hook Works

1. Stop hook reads `.claude/ralph-loop.local.md`
2. If file missing → `exit 0` (allow stop)
3. If file present → parse frontmatter (iteration, max_iterations, completion_promise)
4. Check if completion promise was emitted in last assistant message
5. If not complete → block stop, feed stored prompt back as reason
6. If max iterations reached → clean up file, allow stop

## Related

- Ralph Loop plugin: `~/.claude/plugins/marketplaces/claude-plugins-official/plugins/ralph-loop/`
- Hook script: `ralph-loop/hooks/stop-hook.sh`
- State file format: YAML frontmatter (iteration, max_iterations, completion_promise) + prompt text body
