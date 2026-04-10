---
type: "specification"
description: "Defines the .claude/rules/ enforcement layer — hard constraints that govern agent behavior"
version: "1.0.0"
updated: "2026-01-30"
scope: "adf"
lifecycle: "reference"
location: "adf/ADF-RULES-SPEC.md"
---

# ADF Rules Specification

## Summary

Defines `.claude/rules/` — the enforcement layer for non-negotiable constraints. Rules are hard policy that Claude must not creatively reinterpret or work around. They complement `CLAUDE.md` (contextual guidance) and sit above it in precedence.

---

## Two-Layer Governance Model

ADF separates **policy** from **guidance**:

| Layer | Location | Purpose | Who Controls | Precedence |
|-------|----------|---------|--------------|------------|
| **Rules** | `.claude/rules/` | Hard constraints — non-negotiable behavior | Human only | Wins on conflict |
| **Context** | `CLAUDE.md` | Working norms, orientation, project understanding | Human + Agent | Defers to rules |

If a rule in `.claude/rules/` conflicts with guidance in `CLAUDE.md`, the rule wins.

---

## How Rules Work

Claude Code automatically loads all files in `.claude/rules/` at session start. They are applied implicitly — Claude treats them as policy, not suggestions.

**Key behaviors:**
- Rules are loaded before any other project context
- Claude should not "creatively reinterpret" rules
- Rules are persistent across sessions
- Rules are not conversational — they are enforcement

---

## Scope Levels

### Global Constraints

Location: `~/.claude/CLAUDE.md` (in `<constraints>` block)

Universal safety constraints that apply to all projects. These are the baseline — every project inherits them.

```markdown
<constraints>
- Never commit secrets, credentials, or API keys
- Never modify `.claude/rules/` without explicit human approval
- Confirm before destructive operations (delete, drop, overwrite)
- Ask when uncertain rather than assume
</constraints>
```

### Project Rules

Location: `.claude/rules/`

Project-specific hard constraints that extend global constraints. These add policy appropriate to the project's domain, architecture, and governance needs.

Project rules do not repeat global constraints — they extend them.

---

## File Organization

Start with a single file. Split only when a file exceeds ~50 lines or covers clearly separate domains.

### Single File (default — most projects)

```
.claude/rules/
└── constraints.md
```

### Multi-File (larger projects with distinct domains)

```
.claude/rules/
├── security.md          # Credential handling, data exposure
├── architecture.md      # Structural boundaries, coupling rules
├── governance.md        # Approval gates, protected artifacts
└── domain.md            # Business rules, domain-specific constraints
```

**Splitting criteria:**
- File exceeds ~50 lines
- Rules cover clearly separate concerns
- Different stakeholders own different rule sets

---

## Content Categories

Rules fall into five categories. Not every project needs all five.

### Security

Prevent accidental exposure of sensitive data.

Examples:
- Never commit secrets, credentials, or API keys
- Never expose sensitive data in logs, comments, or documentation
- Never store passwords in plaintext

### Governance

Define approval gates and protected artifacts.

Examples:
- Never modify `.claude/rules/` without human approval
- Never modify `docs/intent.md` without human approval
- Do not modify specs without human approval
- Do not merge to main without review

### Safety

Prevent irreversible or destructive actions.

Examples:
- Confirm before destructive operations (delete, drop, overwrite)
- Ask when uncertain rather than assume
- Never drop database tables without explicit approval

### Session Discipline

Enforce consistent work habits that prevent drift and lost work.

Examples:
- Commit atomically at each completed unit of work — do not ask, just commit
- Update `status.md` before ending a session — do not ask, just update
- Use conventional commit format: `type(scope): description`

**Enforcement:** The adf-env plugin's `Stop` hook checks for uncommitted changes and stale `status.md` before allowing session end.

### Architectural Boundaries

Enforce structural decisions and design constraints.

Examples:
- Do not introduce cross-component coupling
- Do not add dependencies without approval
- Do not build without a governing spec
- YAGNI — do not build beyond current requirements

---

## What Belongs in Rules vs CLAUDE.md

| Concern | Where It Belongs | Why |
|---------|-----------------|-----|
| "Never commit secrets" | Rules | Hard constraint — no exceptions |
| "We use TypeScript" | CLAUDE.md | Context — explains the stack |
| "Ask before changing public APIs" | Rules | Approval gate — enforcement |
| "Public APIs are in /api" | CLAUDE.md | Context — explains location |
| "Do not modify specs without approval" | Rules | Governance — protected artifacts |
| "Specs define good before building" | CLAUDE.md | Working norm — flexible guidance |
| "No new dependencies without approval" | Rules | Architectural boundary — enforcement |
| "Commit at each work unit, don't ask" | Rules | Session discipline — enforcement |
| "We prefer composition over inheritance" | CLAUDE.md | Style preference — guidance |

**Heuristic:** If violating it would cause harm, damage, or require rollback — it's a rule. If it's a preference, norm, or explanation — it's context.

---

## Writing Rules

### Format

Rules files are markdown. Use clear headings and bullet points.

```markdown
# [Category]

These are non-negotiable rules. Claude must not creatively reinterpret or work around them.

## [Subcategory]

- [Rule statement — imperative, unambiguous]
- [Rule statement]
```

### Frontmatter

Rules files use the standard ADF frontmatter with `type: "rule"`:

```yaml
---
type: "rule"
description: "Project constraints — security, governance, safety, architecture"
version: "1.0.0"
updated: "YYYY-MM-DD"
---
```

### Principles

- **Imperative voice** — "Never commit secrets" not "Secrets should not be committed"
- **Unambiguous** — No room for interpretation
- **Minimal** — Only include what must be enforced; guidance belongs in CLAUDE.md
- **Categorized** — Group by concern (security, governance, safety, architecture)
- **No rationale in rules** — Rules state what, not why. Rationale lives in CLAUDE.md or specs.

---

## Lifecycle

### Creation

Rules are created at project init. The scaffolding script creates `.claude/rules/` and optionally seeds a `constraints.md` stub.

### Modification

Rules are human-controlled only. Agents must not modify `.claude/rules/` without explicit human approval. This is itself a global constraint.

### Review

Rules should be reviewed at:
- Project stage transitions (do new constraints apply?)
- Architecture changes (do boundaries need updating?)
- Incident response (do new safety rules apply?)

### Deletion

Rules are removed when they no longer apply. Archive is not needed — rules are small and version-controlled via git.

---

## Validation

A well-formed rules directory:

- [ ] Exists at `.claude/rules/`
- [ ] Contains at least one `.md` file
- [ ] Each file uses imperative, unambiguous language
- [ ] No duplication of global constraints
- [ ] No contextual guidance (that belongs in CLAUDE.md)
- [ ] Rules are categorized (security, governance, safety, architecture)

---

## Relationship to Other Specs

| Spec | Relationship |
|------|-------------|
| ADF-GLOBAL-CLAUDE-MD-SPEC.md | Global constraints (baseline) that project rules extend |
| ADF-PROJECT-CLAUDE-MD-SPEC.md | Context layer that rules complement and override |
| ADF-FOLDER-STRUCTURE-SPEC.md | Defines `.claude/rules/` in project structure |
| ADF-CONTEXT-ARTIFACT-SPEC.md | Defines `rule` type in artifact vocabulary |
| ADF-ARCHITECTURE-SPEC.md | Rules are part of the governance model in the environment layer |

---

## References

- ADF-GLOBAL-CLAUDE-MD-SPEC.md
- ADF-PROJECT-CLAUDE-MD-SPEC.md
- ADF-ARCHITECTURE-SPEC.md
- ADF-CONTEXT-ARTIFACT-SPEC.md
- ADF-FOLDER-STRUCTURE-SPEC.md
