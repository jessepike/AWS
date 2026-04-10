---
name: Security Review
description: This skill should be used when the user asks to "security review", "run security check", "check for vulnerabilities", "OWASP check", "security audit", "find security issues", "threat model check", "supply chain check", "check for injection", "crypto review", or when the user needs code-level or design-level security analysis beyond what project-health and security-guidance cover.
version: 1.0.0
user_invocable: true
arguments:
  - name: dimension
    description: "Analysis dimension: all, code, design (default: all)"
    required: false
  - name: scope
    description: "Check scope: all, injection, crypto, unsafe, supply-chain, design-posture (default: all)"
    required: false
  - name: file-backlog
    description: "Auto-append Critical/High findings to BACKLOG.md (default: false)"
    required: false
---

# Security Review

Code-level and design-level security analysis for any project. Complements project-health (code health metrics, secrets, CVEs) and security-guidance (runtime prevention of 8 dangerous patterns). Runs pattern matching and structural analysis — no scripts, no MCP dependencies.

## Relationship to Other Tools

| Tool | Layer | Focus |
|------|-------|-------|
| security-guidance | Runtime prevention | 8 dangerous patterns during edits (PreToolUse hook) |
| project-health | Code health | Hardcoded secrets, CVEs, deps, tests, design drift |
| adf-review | Artifact quality | Design/spec review via Ralph Loop + external models |
| **security-review** | **Security analysis** | **OWASP patterns, crypto, unsafe ops, supply chain, design security posture** |

No duplication. Explicit boundaries:
- Does NOT re-check hardcoded secrets (project-health 4.1-4.3 covers this)
- Does NOT re-run CVE detection (project-health 2.2 covers this)
- Does NOT duplicate security-guidance's 8 runtime patterns (eval, exec, innerHTML, etc.)

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
which <tool>
```
If missing, skip that specific check and note it in the report as SKIPPED.

## Check Categories

Five categories, 22 total checks. Two dimensions: Code (categories 1-4, 18 checks) and Design (category 5, 4 checks). Details and exact patterns in `references/security-checks.md`.

### 1. Injection & Input Validation (Code)

| ID | Check | Severity |
|----|-------|----------|
| INJ-01 | SQL Injection — string concat/interpolation in SQL queries | Critical |
| INJ-02 | Command Injection — user input in shell commands | High |
| INJ-03 | Path Traversal — unvalidated input in file paths | High |
| INJ-04 | XSS Patterns — server-side template injection, unsafe HTML rendering | High |
| INJ-05 | SSRF Indicators — user-controlled URLs in server-side HTTP requests | High |

### 2. Cryptography & Secrets (Code)

| ID | Check | Severity |
|----|-------|----------|
| CRY-01 | Weak Hashing for Auth — MD5/SHA1 for passwords | Critical |
| CRY-02 | Insecure Randomness — Math.random/random for security-sensitive values | High |
| CRY-03 | Hardcoded Crypto Material — hardcoded IVs, salts, encryption keys | Critical |
| CRY-04 | Insecure TLS Configuration — disabled cert verification, old TLS versions | High |

### 3. Unsafe Operations (Code)

| ID | Check | Severity |
|----|-------|----------|
| UNS-01 | Unsafe Deserialization — deserializing untrusted data | Critical |
| UNS-02 | Unrestricted File Upload — uploads without type/size validation | High |
| UNS-03 | Race Conditions (TOCTOU) — check-then-act without locking | Medium |
| UNS-04 | Information Leakage — stack traces/detailed errors exposed to users | Medium |
| UNS-05 | Prototype Pollution — object property assignment from user input (JS/TS) | High |

### 4. Supply Chain (Code)

| ID | Check | Severity |
|----|-------|----------|
| SUP-01 | Lockfile Integrity — manifest edited without lockfile update | High |
| SUP-02 | Typosquatting Indicators — deps similar to popular packages | Medium |
| SUP-03 | Post-Install Scripts — package.json install hooks with network/shell calls | Medium |
| SUP-04 | Pinning Strategy — deps using ranges instead of exact versions | Low |

### 5. Design Security Posture (Design)

| ID | Check | Severity |
|----|-------|----------|
| DSG-01 | Threat Model Presence — design.md includes threat analysis | High |
| DSG-02 | Auth/Authz Strategy — authentication/authorization approach defined | High |
| DSG-03 | Data Classification — sensitive data identified with protection strategy | Medium |
| DSG-04 | Input Validation Strategy — defined approach to validating external input | Medium |

Skip this entire category if `docs/design.md` does not exist.

## Stage Awareness

Check categories vary by project stage:

| Stage | Categories Run | Rationale |
|-------|---------------|-----------|
| **Develop** | All 5 (22 checks) | Full security posture before build completion |
| **Design** | Design Security Posture only (4 checks) | No code yet; validate design has security thinking |
| **Deliver** | Code categories only (18 checks) | Deployment readiness, design should be done |
| **Discover** | None (skip gracefully) | Too early for security analysis |

If no stage is detected (non-ADF project), run all 5 categories.

## Execution Order

1. **Pre-flight** — language detection, stage detection, tool availability
2. **Apply filters** — dimension (`--dimension code/design`) and scope (`--scope injection/crypto/...`) narrow the check set
3. **Run checks** — iterate categories per stage awareness, skip unavailable tools
4. **Classify findings** — assign severity (Critical > High > Medium > Low)
5. **Generate report** — structured output per category with dimension column
6. **File backlog** (if `--file-backlog`) — append Critical/High to BACKLOG.md

## Report Format

Output a structured report with this format:

```
## Security Review Report

**Project:** <name from package.json/pyproject.toml/Cargo.toml>
**Language(s):** <detected>
**Stage:** <from status.md or "N/A">
**Date:** <today>
**Dimension:** <all, code, or design>
**Scope:** <all or specific category>

### Summary

| Category | Dimension | Status | Critical | High | Medium | Low |
|----------|-----------|--------|----------|------|--------|-----|
| Injection & Input Validation | Code | WARN | 0 | 2 | 0 | 0 |
| Cryptography & Secrets | Code | FAIL | 1 | 0 | 0 | 0 |
| Unsafe Operations | Code | PASS | 0 | 0 | 1 | 0 |
| Supply Chain | Code | PASS | 0 | 0 | 0 | 1 |
| Design Security Posture | Design | WARN | 0 | 1 | 1 | 0 |

**Overall: FAIL** (1 Critical, 3 High, 2 Medium, 1 Low)

### Findings

#### [CRITICAL] CRY-01: Weak Hashing for Auth
- **Category:** Cryptography & Secrets
- **Dimension:** Code
- **Detail:** MD5 used for password hashing in src/auth/users.py:42
- **Remediation:** Replace with bcrypt, scrypt, or argon2

#### [HIGH] INJ-01: SQL Injection
- **Category:** Injection & Input Validation
- **Dimension:** Code
- **Detail:** String concatenation in SQL query at src/db/queries.ts:118
- **Remediation:** Use parameterized queries / prepared statements

### Cross-References

For complementary security checks not covered here:
- **Hardcoded secrets:** Run `/project-health --scope secrets`
- **Known CVEs:** Run `/project-health --scope deps`
- **Runtime dangerous patterns:** security-guidance plugin (PreToolUse hook, always active)
```

**Status rules:**
- FAIL = any Critical finding
- WARN = any High finding (no Critical)
- PASS = Medium/Low only or no findings
- SKIP = category not run (stage filter, dimension filter, or missing tools)

## Backlog Filing

When `--file-backlog` is set:

1. Read `BACKLOG.md`, find the highest B-number
2. For each Critical or High finding, append an entry:

```markdown
### B<next> — <finding title>
- **Type:** Security
- **Size:** S | M | L (estimate based on remediation complexity)
- **Source:** Security Review <date>
- **Detail:** <finding detail>
- **Remediation:** <suggested fix>
```

3. All security-review findings map to **Type: Security** (unlike project-health which maps across Bug/Tech Debt/Security).

## Integration Points

- **project-health** — Complementary code health. Run both for complete picture: security-review for OWASP/crypto/supply-chain, project-health for secrets/CVEs/tests/hygiene.
- **security-guidance** — Runtime prevention complement. security-guidance blocks 8 dangerous patterns during edits; security-review finds the same class of issues in existing code plus broader categories.
- **adf-review** — Pre-review security gate. Recommended chain: `security-review` then `project-health` then `adf-review`.
- **design.md** — Source for Design Security Posture checks (threat model, auth strategy, data classification, input validation).
- **BACKLOG.md** — Target for `--file-backlog` auto-filing.
- **status.md** — Source for stage detection (determines which categories run).

## Error Handling

| Scenario | Behavior |
|----------|----------|
| Tool not installed | Skip that check, mark SKIPPED in report |
| No code detected (no language markers) | Skip code dimension, run design checks only if design.md exists |
| Non-ADF project (no design.md) | Skip Design Security Posture category, run code categories |
| Permission error on a file | Skip that file, continue, note in report |
| No BACKLOG.md for filing | Warn and output findings to console only |
| Discover stage | Exit gracefully: "Discover stage — security review not applicable yet." |

## Quick Reference

**Trigger phrases:**
- "security review", "run security check", "check for vulnerabilities"
- "OWASP check", "security audit", "find security issues"
- "threat model check", "supply chain check"
- "check for injection", "crypto review"

**Dimension shortcuts:**
- `/security-review` — all dimensions
- `/security-review --dimension code` — code checks only (18 checks)
- `/security-review --dimension design` — design checks only (4 checks)

**Scope shortcuts:**
- `/security-review --scope all` — all categories
- `/security-review --scope injection` — Injection & Input Validation only
- `/security-review --scope crypto` — Cryptography & Secrets only
- `/security-review --scope unsafe` — Unsafe Operations only
- `/security-review --scope supply-chain` — Supply Chain only
- `/security-review --scope design-posture` — Design Security Posture only

**Severity scale:** Critical > High > Medium > Low

**Language auto-detection:** Python, TypeScript/JavaScript, Go, Rust (polyglot supported)

**Backlog filing:** `--file-backlog` appends Critical/High findings to BACKLOG.md as Type: Security
