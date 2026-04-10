---
name: Project Health
description: This skill should be used when the user asks to "check code health", "audit codebase", "run health check", "check test coverage", "dependency audit", "find stale TODOs", "check for secrets", "design drift", "code hygiene", "pre-review health check", "codebase audit", or when the user needs code-level health metrics complementing adf-env governance checks.
version: 1.0.0
user_invocable: true
arguments:
  - name: scope
    description: "Check scope: all, tests, deps, hygiene, secrets, design-drift, docs, freshness (default: all)"
    required: false
  - name: file-backlog
    description: "Auto-append Critical/High findings to BACKLOG.md (default: false)"
    required: false
---

# Project Health Auditor

Code-level health auditing for any project. Complements adf-env (governance/environment layer) and adf-review (artifact quality). Runs standard language tools and pattern matching — no scripts, no MCP dependencies.

## Relationship to Other Tools

| Tool | Layer | Focus |
|------|-------|-------|
| adf-env:audit | Environment / governance | Artifacts, CLAUDE.md, plugins, hooks, MCP, session discipline |
| adf-review | Artifact quality | Design docs, specs, briefs — structural and semantic review |
| **project-health** | **Code / implementation** | **Tests, deps, code hygiene, secrets, design drift, docs sync** |

No overlap. They are complementary.

## Pre-flight

Before running checks, detect the project environment:

### 1. Language Detection

Scan project root for markers:

| Marker File | Language |
|-------------|----------|
| `package.json` | TypeScript / JavaScript |
| `pyproject.toml`, `requirements.txt`, `setup.py` | Python |
| `Cargo.toml` | Rust |
| `go.mod` | Go |

Multiple markers = polyglot project. Run checks for all detected languages.

### 2. Stage Detection

Read `status.md` frontmatter for `stage:` value. Determines which check categories run (see Stage Awareness below).

### 3. Tool Availability

Before running a check that requires a CLI tool, verify it exists:
```
which pytest  # or npm, cargo, go, etc.
```
If missing, skip that specific check and note it in the report as SKIPPED.

## Check Categories

Seven categories, 22 total checks. Details and exact commands in `references/check-catalog.md`.

### 1. Test Health

| Check | What | Severity Threshold |
|-------|------|-------------------|
| Coverage gaps | Lines/branches not covered by tests | <60% FAIL, <80% WARN |
| Skipped tests | Tests marked skip/TODO with age | >60d HIGH, >30d MEDIUM |
| Collection errors | Tests that fail to collect/import | Any = HIGH |
| Test staleness | Test files not modified in 30+ days while src changed | Informational MEDIUM |

### 2. Dependency Health

| Check | What | Severity Threshold |
|-------|------|-------------------|
| Outdated packages | Packages behind latest | Major version = HIGH |
| Security vulnerabilities | Known CVEs in deps | Critical/High CVE = CRITICAL |
| Unused deps | Declared but not imported | Any = LOW |
| Missing lockfile | No lockfile present | Missing = HIGH |

### 3. Code Hygiene

| Check | What | Severity Threshold |
|-------|------|-------------------|
| Stale TODOs/FIXMEs | TODO/FIXME comments aged via git blame | >60d HIGH, >30d MEDIUM |
| Commented-out code | Blocks of commented code (>5 lines) | Any = LOW |
| Print debugging | console.log/print()/fmt.Println in non-test files | Any = MEDIUM |
| Placeholder implementations | NotImplementedError/unimplemented!/TODO throws | Any = HIGH |

### 4. Secrets & Config

| Check | What | Severity Threshold |
|-------|------|-------------------|
| Hardcoded secrets | API keys, passwords, tokens with literal values | Any = CRITICAL |
| .env safety | .env exists but not gitignored | Not ignored = CRITICAL |
| Missing .env.example | .env exists without .env.example | Missing = LOW |

### 5. Build-to-Design Drift (ADF projects only)

| Check | What | Severity Threshold |
|-------|------|-------------------|
| Component alignment | Components in design.md not in code (and vice versa) | Missing impl = HIGH |
| API contract drift | Endpoints in design.md vs route definitions | Mismatch = HIGH |

Skip this entire category if `docs/design.md` does not exist.

### 6. Documentation Sync

| Check | What | Severity Threshold |
|-------|------|-------------------|
| Dead internal links | Markdown links pointing to nonexistent files | Any = MEDIUM |
| Version references | Doc version strings vs package version | Mismatch = LOW |

### 7. Doc Freshness (ADF projects only)

| Check | What | Severity Threshold |
|-------|------|-------------------|
| Stale docs (covers) | Doc has `covers:` frontmatter, covered code paths have commits newer than doc's `updated:` date | Code changed significantly = HIGH, minor changes = MEDIUM |
| Stale docs (age) | Doc has `updated:` but no `covers:` — pure age check | >30 days = MEDIUM, >60 days = HIGH |
| Missing freshness metadata | Doc in `docs/active/` or root artifact has no `updated:` field | Any = LOW |

**How it works:** Docs declare which code paths they cover via `covers:` frontmatter. The check compares `git log --since <updated_date> -- <covered_paths>` to detect when code moved but docs didn't.

**Example frontmatter:**
```yaml
---
type: "design"
updated: "2026-03-24"
covers: ["src/api/", "src/models/", "config/"]
---
```

**Which docs are checked:**
- Root artifacts: `intent.md`, `brief.md` (from `docs/active/`), `design.md` (from `docs/active/`), `README.md`
- All docs in `docs/active/` with `updated:` frontmatter
- `AGENTS.md` and `CLAUDE.md` are excluded (instruction files, not project docs)

Skip this category if no ADF project structure is detected.

## Stage Awareness

Check categories vary by project stage:

| Stage | Categories Run |
|-------|---------------|
| **Develop** | All 7 categories |
| **Deliver** | Secrets, Deps, Docs, Doc Freshness (deployment readiness focus) |
| **Design / Discover** | Secrets, Deps baseline, Doc Freshness |

If no stage is detected (non-ADF project), run all 7 categories (skip Doc Freshness if no ADF structure).

## Execution Order

1. **Pre-flight** — language detection, stage detection, tool availability
2. **Run checks** — iterate categories per stage awareness, skip unavailable tools
3. **Classify findings** — assign severity (Critical > High > Medium > Low)
4. **Generate report** — structured output per category
5. **File backlog** (if `--file-backlog`) — append Critical/High to BACKLOG.md

## Report Format

Output a structured report with this format:

```
## Project Health Report

**Project:** <name from package.json/pyproject.toml/Cargo.toml>
**Language(s):** <detected>
**Stage:** <from status.md or "N/A">
**Date:** <today>
**Scope:** <all or specific category>

### Summary

| Category | Status | Critical | High | Medium | Low |
|----------|--------|----------|------|--------|-----|
| Test Health | WARN | 0 | 1 | 2 | 0 |
| Dependency Health | FAIL | 1 | 0 | 0 | 0 |
| Code Hygiene | PASS | 0 | 0 | 0 | 1 |
| Secrets & Config | PASS | 0 | 0 | 0 | 0 |
| Design Drift | SKIP | - | - | - | - |
| Documentation Sync | PASS | 0 | 0 | 0 | 0 |
| Doc Freshness | WARN | 0 | 1 | 0 | 0 |

**Overall: WARN** (1 Critical, 1 High, 2 Medium, 1 Low)

### Findings

#### [CRITICAL] Security vulnerability in dependency
- **Category:** Dependency Health
- **Detail:** lodash@4.17.15 has known prototype pollution (CVE-2021-23337)
- **Remediation:** Run `npm audit fix` or update to lodash@4.17.21+

#### [HIGH] Coverage below threshold
- **Category:** Test Health
- **Detail:** Overall coverage 58% (threshold: 60%)
- **Files:** src/auth/handler.ts (12%), src/api/routes.ts (34%)
- **Remediation:** Add tests for uncovered files, prioritize critical paths
```

**Status rules:**
- FAIL = any Critical finding
- WARN = any High finding (no Critical)
- PASS = Medium/Low only or no findings
- SKIP = category not run (stage filter or missing tools)

## Backlog Filing

When `--file-backlog` is set:

1. Read `BACKLOG.md`, find the highest B-number
2. For each Critical or High finding, append an entry:

```markdown
### B<next> — <finding title>
- **Type:** Bug | Tech Debt | Security
- **Size:** S | M | L (estimate based on remediation complexity)
- **Source:** Project Health Audit <date>
- **Detail:** <finding detail>
- **Remediation:** <suggested fix>
```

3. Map finding categories to types:
   - Secrets → Security
   - Vulnerabilities → Security
   - Coverage/test issues → Tech Debt
   - Stale TODOs → Tech Debt
   - Design drift → Bug
   - Placeholder implementations → Bug

## Integration Points

- **adf-env** — Governance complement. Run `adf-env:audit` for environment health + `project-health` for code health = complete picture.
- **design.md** — Source for design-drift checks. Component list and API contracts extracted from design.md sections.
- **BACKLOG.md** — Target for `--file-backlog` auto-filing.
- **status.md** — Source for stage detection (determines which categories run).
- **adf-review** — Pre-review health gate. Run `project-health` before `adf-review` to ensure code-level issues are captured before artifact review.

## Error Handling

| Scenario | Behavior |
|----------|----------|
| Tool not installed (pytest, npm, etc.) | Skip that check, mark SKIPPED in report, list in "Skipped Checks" section |
| No code detected (no language markers) | Exit gracefully: "No supported language detected. Nothing to audit." |
| Non-ADF project (no design.md) | Skip design-drift category, run everything else |
| Permission error on a file | Skip that file, continue, note in report |
| Empty test suite | Report as informational, not a failure |
| No BACKLOG.md for filing | Warn and output findings to console only |

## Quick Reference

**Trigger phrases:**
- "check code health", "audit codebase", "run health check"
- "check test coverage", "dependency audit", "find stale TODOs"
- "check for secrets", "design drift check", "code hygiene"
- "pre-review health check"

**Scope shortcuts:**
- `/project-health` — all categories
- `/project-health --scope tests` — test health only
- `/project-health --scope deps` — dependency health only
- `/project-health --scope hygiene` — code hygiene only
- `/project-health --scope secrets` — secrets & config only
- `/project-health --scope design-drift` — design drift only
- `/project-health --scope docs` — documentation sync only
- `/project-health --scope freshness` — doc freshness only

**Severity scale:** Critical > High > Medium > Low

**Language auto-detection:** Python, TypeScript/JavaScript, Go, Rust (polyglot supported)

**Backlog filing:** `--file-backlog` appends Critical/High findings to BACKLOG.md
