---
type: "documentation"
description: "ADF scripts documentation"
version: "1.1.0"
updated: "2026-02-10"
lifecycle: "reference"
location: "scripts/README.md"
---

# ADF Scripts

Automation scripts for ADF project management.

## init-project.sh

Initializes a new project with ADF scaffolding.

### Usage

```bash
./scripts/init-project.sh [--runtime dual|claude-only|codex-only]
```

`--runtime` default is `dual`.

### Runtime Modes

| Mode | Creates | Notes |
|------|---------|-------|
| `dual` | `.claude/CLAUDE.md` + `AGENTS.md` | Recommended coexistence mode |
| `claude-only` | `.claude/CLAUDE.md` | Existing Claude-native behavior |
| `codex-only` | `AGENTS.md` | Skips global CLAUDE.md bootstrap step |

`.claude/rules/constraints.md` is still created in all modes for shared governance constraints.

### What It Does

1. Checks/updates global `~/.claude/CLAUDE.md` (except `codex-only`)
2. Prompts for project type (`app`, `artifact`, `workflow`)
3. Prompts for scale (`personal`, `shared`, `community`, `commercial`)
4. Prompts for target path and project name
5. Creates base scaffolding and runtime instruction files

### Output Structure (Dual Mode)

```text
project/
├── AGENTS.md
├── .claude/
│   ├── CLAUDE.md
│   └── rules/
│       └── constraints.md
├── docs/
│   ├── intent.md
│   ├── discover-brief.md
│   ├── status.md
│   └── tasks.md
├── _archive/
└── README.md
```

Type-specific folders:
- `app`: `src/`, `tests/`, `config/`
- `artifact`: `assets/`, `output/`, `docs/research/`
- `workflow`: `workflows/`, `scripts/`
