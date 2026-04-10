---
type: "specification"
description: "Defines artifact structure, frontmatter schema, progressive disclosure, and lifecycle"
version: "1.0.1"
updated: "2026-02-04"
scope: "adf"
lifecycle: "reference"
location: "adf/ADF-CONTEXT-ARTIFACT-SPEC.md"
---

# ADF Context Artifact Specification

## Purpose

Define the standard structure for all ADF artifacts: frontmatter schema, progressive disclosure, artifact classes, and lifecycle management.

---

## Frontmatter Schema

All governed artifacts include YAML frontmatter.

### Required Fields

```yaml
---
type: "specification"
description: "Human-readable purpose"
version: "1.0.0"
updated: "YYYY-MM-DD"
---
```

| Field | Format | Purpose |
|-------|--------|---------|
| `type` | controlled vocabulary | Document category |
| `description` | string | What this artifact is for |
| `version` | SemVer X.Y.Z | Track meaning changes |
| `updated` | ISO 8601 date | Last modification |

### Optional Fields

```yaml
---
# Required fields...

# Optional
scope: "project"
lifecycle: "reference"
location: "docs/brief.md"
depends_on: ["intent.md"]
---
```

| Field | When Used |
|-------|-----------|
| `scope` | CLAUDE.md files (global/project/local) |
| `lifecycle` | Artifact class (see below) |
| `location` | Canonical path for this artifact |
| `depends_on` | Artifacts this references |

### Type Vocabulary

**Core types:**
- `intent` — North Star statement
- `brief` — Detailed scope and criteria
- `specification` — Defines structure or rules
- `rule` — Governing constraint
- `plan` — Implementation plan
- `decision` — ADR or recorded decision

**Scope modifiers (for rules):**
- `rule_architecture` — Structural decisions
- `rule_stack` — Technology-specific
- `rule_domain` — Business rules

---

## Progressive Disclosure

Artifacts follow a three-part structure for scanability:

```markdown
---
[frontmatter]
---

# Title

## Summary
[2-4 sentences — the TL;DR]

## Details
[Full content, organized by sections]

## References
[Links to related artifacts, external docs]
```

### Principles

1. **Summary first** — Reader knows what this is in 10 seconds
2. **Details expand** — Full content for those who need it
3. **References link** — Connect to related context

### When to Use

| Artifact Size | Structure |
|---------------|-----------|
| < 50 lines | Summary may be the whole thing |
| 50-200 lines | Summary + Details |
| > 200 lines | Summary + Details + References (or split artifact) |

---

## Artifact Classes

Every artifact belongs to one of three classes:

### 1. Deliverable

**What:** Output that IS the project — code, final documents, working systems.

**Examples:** Source code, compiled output, final presentations, deployed workflows

**Lifecycle:** Lives as long as the project runs

**Location:** `src/`, `output/`, `workflows/` (by project type)

**Prune rule:** Never auto-prune; removal is intentional

---

### 2. Reference

**What:** Context that supports understanding and decision-making.

**Examples:** Specs, briefs, ADRs, research, documentation

**Lifecycle:** Lives as long as it's relevant

**Location:** `docs/`

**Prune rule:** Review when project phase changes; archive if obsolete

---

### 3. Ephemeral

**What:** Temporary artifacts used once or briefly.

**Examples:** Migration scripts, imported context, one-time analysis, scratch work

**Lifecycle:** Short — use and discard

**Location:** `docs/inbox/` (pre-processing) or created ad-hoc

**Prune rule:** Delete after use, or move to `.archive/` if uncertain

---

## Lifecycle Field Values

Use in frontmatter:

```yaml
lifecycle: "deliverable"  # Core output
lifecycle: "reference"    # Supporting context
lifecycle: "ephemeral"    # Temporary, prune soon
```

If omitted, default assumption by location:
- `src/`, `output/`, `workflows/` → deliverable
- `docs/` → reference
- `docs/inbox/`, `tmp/` → ephemeral

---

## Lifecycle Management

### Inbox Flow

```
New context arrives
        ↓
    docs/inbox/
        ↓
   [Process it]
        ↓
    ┌───┴───┐
    ↓       ↓
  docs/   delete
(reference) (ephemeral)
```

### Archive Flow

```
Artifact no longer active
        ↓
   Still valuable?
        ↓
    ┌───┴───┐
    ↓       ↓
.archive/  delete
```

### Prune Triggers

| Trigger | Action |
|---------|--------|
| Stage transition | Review `docs/inbox/`, clear ephemeral |
| Project milestone | Review `docs/`, archive obsolete |
| Context bloat | Audit artifacts, prune aggressively |

---

## Artifact Locations (Summary)

| Artifact | Location |
|----------|----------|
| Global CLAUDE.md | `~/.claude/CLAUDE.md` |
| Project CLAUDE.md | `.claude/CLAUDE.md` |
| Local CLAUDE.md | `./CLAUDE.local.md` |
| Project rules | `.claude/rules/` |
| Intent | `docs/intent.md` |
| Brief | `docs/brief.md` |
| Decisions/ADRs | `docs/decisions/` |
| Research | `docs/research/` |
| Inbox (triage) | `docs/inbox/` |
| Archive | `.archive/` |

---

## Validation Checklist

For any governed artifact:

- [ ] Has frontmatter with required fields
- [ ] Type is from controlled vocabulary
- [ ] Version incremented if meaning changed
- [ ] Location field matches actual path
- [ ] Lifecycle field set (or default is appropriate)
- [ ] Summary section exists (if > 50 lines)

---

## Meta-Maintenance: adf-env

Artifact validation and context pruning are handled by the **adf-env** plugin (`~/.claude/plugins/adf-plugins/plugins/adf-env/`).

adf-env absorbs the previously deferred `adf-validate` and `adf-prune` concepts into a single environment management plugin:

| Capability | adf-env Skill | Description |
|------------|-----------------|-------------|
| **Validation** | `/adf-env:audit` | Check artifacts against specs — frontmatter, structure, lifecycle compliance, drift detection |
| **Pruning** | `/adf-env:audit` + `/adf-env:reset` | Identify stale context, clean CLAUDE.md dynamic sections, archive ephemeral artifacts |
| **Drift detection** | SessionStart hook | Lightweight file-existence checks on every session start |
| **Baseline enforcement** | `/adf-env:status` | Compare current state against machine-parseable baseline |

See: `ADF-ENV-PLUGIN-SPEC.md` for full specification.

---

## References

- ADF-GLOBAL-PRIMITIVES-v0.1.md
- ADF-FOLDER-STRUCTURE-SPEC.md
- TIER1_KIT_SPEC.md (frontmatter origin)
