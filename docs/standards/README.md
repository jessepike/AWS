# AWS Standards

Standards are the machine-enforceable contracts for how work is structured
across every project governed by the Agentic Work System (AWS).

## What lives here

Each file in this directory is a YAML manifest defining a specific standard.
Current standards:

| Standard | File | Purpose |
|---|---|---|
| Project Layout | `project-layout.yaml` | Required artifacts every project must have |
| CLAUDE.md | `claude-md.yaml` | Project CLAUDE.md content rules (what's allowed, what's forbidden) |
| Artifact Frontmatter | `artifact-frontmatter.yaml` | Required frontmatter fields per artifact type |
| Session Lifecycle | `session-lifecycle.yaml` | Contract between orient, session-wrap, and session-handoff skills |

Unrelated files in this directory (`capture-envelope-*.md/json`,
`capture-pipeline-visual.md`) predate this standards layer and remain
as-is unless explicitly migrated.

## Write authority

**Forge is the sole write-authority for AWS standards.** No other agent
may create, modify, or delete files in this directory. This is enforced
via soft rule in `~/.claude/CLAUDE.md` (global). Hard enforcement via
pre-edit hooks is Day 2 work.

## Standard format

Every standard is a YAML manifest with:

- `standard`: machine name (kebab-case)
- `version`: semver (bumped on every change)
- `updated`: ISO date of last update
- `owner`: always `forge`
- `adr`: the ADR that created or last modified this standard

Standards are designed to be consumed by the `/project-doctor` audit skill
(Day 2 work, not yet built). The audit reads these manifests and checks each
project for conformance.

## How to propose a change

1. Open `claude-forge`
2. Describe the proposed change and why
3. Forge drafts a new ADR (incrementing from the last)
4. ADR gets accepted → Forge updates the relevant YAML, bumps version,
   updates CHANGELOG.md
5. If enforcement is needed, Forge adds or updates the relevant audit check
   in `/project-doctor`

Never modify these files directly. Every governance change must be logged
and traceable to an ADR.
