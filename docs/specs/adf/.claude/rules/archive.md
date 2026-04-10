# Archive Directory Rules

These are non-negotiable rules for the `.archive/` directory.

## Purpose

The `.archive/` directory at project root stores historical artifacts that are no longer active in the project context.

## Non-Negotiable Rules

- **Write-only for agents**: Agents may move artifacts TO `.archive/` during stage transitions or cleanup
- **No reads without explicit instruction**: Agents MUST NOT read from, search in, reference, or pull context from `.archive/` unless the user explicitly instructs "pull from archive" or "look in archive"
- **Do not assume**: Even if information might be in archive, do not assume the user wants you to access it — wait for explicit instruction
- **Not for active context**: Archived artifacts are not part of current project state
- **Naming convention**: `.archive/YYYY-MM-DD-<artifact-name>.md`

## When to Archive

- **Stage transitions**: Move ephemeral/working artifacts that are no longer needed
- **Artifact supersession**: When a new version replaces an old one completely
- **Context cleanup**: When artifacts are valuable but not actively needed

## Rationale

Archived artifacts represent prior states of thinking. Reading from archive pollutes current context with potentially outdated or superseded information.
