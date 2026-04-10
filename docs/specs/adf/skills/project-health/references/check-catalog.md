# Check Catalog

Detailed reference for all 19 project health checks. Organized by category with per-language commands.

---

## 1. Test Health

### 1.1 Coverage Gaps

**What:** Measures line/branch coverage to identify untested code paths. Low coverage correlates with undetected bugs, especially in critical paths like authentication, payment, and data validation.

**How:**

| Language | Command | Notes |
|----------|---------|-------|
| Python | `pytest --cov=<src> --cov-report=term-missing` | Requires `pytest-cov` |
| TypeScript | `npx vitest --coverage --reporter=text` | Or `npx jest --coverage` |
| Go | `go test -cover ./...` | Built-in |
| Rust | `cargo tarpaulin --out stdout` | Requires `cargo-tarpaulin` |

**Parse:** Look for the summary line with total coverage percentage. For per-file detail, scan for files below threshold.

**Severity:**
- FAIL: Overall coverage <60%
- WARN: Overall coverage 60-79%
- PASS: Overall coverage >=80%
- Per-file: Flag any file <30% as HIGH regardless of overall

**Remediation:** Add tests for uncovered files, prioritizing: (1) files with recent changes, (2) files in critical paths (auth, payments, data), (3) files with highest complexity.

---

### 1.2 Skipped Tests

**What:** Tests marked with skip/todo decorators that were meant to be temporary. Skipped tests accumulate and mask coverage gaps.

**How:**

Use Grep to find skip markers:

| Language | Patterns |
|----------|----------|
| Python | `@pytest.mark.skip`, `@unittest.skip`, `pytest.skip()` |
| TypeScript | `it.skip(`, `describe.skip(`, `test.skip(`, `xit(`, `xdescribe(` |
| Go | `t.Skip()` |
| Rust | `#[ignore]` |

Then age each match via git blame:
```bash
git blame -L <line>,<line> <file> --format='%ai'
```

**Parse:** Extract the date from git blame output. Calculate days since skip was added.

**Severity:**
- HIGH: Skip older than 60 days
- MEDIUM: Skip older than 30 days
- LOW: Skip younger than 30 days

**Remediation:** For each skipped test, either: (1) fix the underlying issue and unskip, (2) delete if the test is no longer relevant, (3) add a tracking issue/backlog item if the fix is non-trivial.

---

### 1.3 Collection Errors

**What:** Tests that fail to import or collect, meaning they never run. Silent failures in test suites give false confidence.

**How:**

| Language | Command |
|----------|---------|
| Python | `pytest --collect-only 2>&1` |
| TypeScript | `npx vitest --reporter=verbose --run 2>&1` (check stderr) |
| Go | `go test -list '.*' ./... 2>&1` |
| Rust | `cargo test --no-run 2>&1` |

**Parse:** Look for:
- Python: `ERROR collecting` or `ModuleNotFoundError` in output
- TypeScript: `Error:` or `Cannot find module` in stderr
- Go: `build` or `import` errors
- Rust: `error[E` in output

**Severity:**
- HIGH: Any collection error (tests are silently not running)

**Remediation:** Fix import paths, install missing dependencies, or remove broken test files.

---

### 1.4 Test Staleness

**What:** Test files not modified recently while their corresponding source files have changed. Indicates tests may not reflect current behavior.

**How:**

1. Use Glob to find test files: `**/*test*.*`, `**/test_*.*`, `**/*_test.*`, `**/*.spec.*`
2. Use Glob to find corresponding source files (strip test prefix/suffix)
3. Compare modification dates:
```bash
git log -1 --format='%ai' -- <test_file>
git log -1 --format='%ai' -- <src_file>
```

**Parse:** Flag pairs where source was modified more recently than test AND test hasn't been modified in 30+ days.

**Severity:**
- MEDIUM: Test file >30 days stale while source changed since last test update

**Remediation:** Review the source changes and update tests to match current behavior.

---

## 2. Dependency Health

### 2.1 Outdated Packages

**What:** Dependencies behind their latest versions. Major version gaps often mean missing security patches and breaking API changes that compound over time.

**How:**

| Language | Command |
|----------|---------|
| Python | `pip list --outdated --format=columns` |
| TypeScript | `npm outdated` |
| Go | `go list -u -m all` |
| Rust | `cargo outdated` (requires `cargo-outdated`) |

**Parse:**
- Python: Table with Current and Latest columns
- TypeScript: Table with Current, Wanted, Latest columns
- Go: Lines with `[v...]` showing available updates
- Rust: Table with Project and Latest columns

**Severity:**
- HIGH: Major version behind (e.g., v3 vs v5)
- MEDIUM: Minor version behind
- LOW: Patch version behind

**Remediation:** Update dependencies incrementally. Major versions require changelog review for breaking changes. Run tests after each update.

---

### 2.2 Security Vulnerabilities

**What:** Known CVEs in project dependencies. The most critical code health check — vulnerable dependencies are the #1 attack vector for applications.

**How:**

| Language | Command |
|----------|---------|
| Python | `pip-audit` (requires `pip-audit`) |
| TypeScript | `npm audit --json` |
| Go | `govulncheck ./...` (requires `govulncheck`) |
| Rust | `cargo audit` (requires `cargo-audit`) |

**Parse:**
- Python: JSON output with vulnerability details and fix versions
- TypeScript: JSON with `vulnerabilities` object, severity levels
- Go: Vulnerability descriptions with affected packages
- Rust: Advisory details with patched versions

**Severity:**
- CRITICAL: Any Critical or High severity CVE
- HIGH: Medium severity CVE
- MEDIUM: Low severity CVE

**Remediation:** Update to patched version listed in advisory. If no patch exists, evaluate workarounds or alternative packages.

---

### 2.3 Unused Dependencies

**What:** Packages declared in manifest but never imported in source code. Bloats install size, increases attack surface, and slows CI.

**How:**

| Language | Method |
|----------|--------|
| Python | Cross-reference `requirements.txt`/`pyproject.toml` deps with Grep for `import <pkg>` or `from <pkg>` across `*.py` files |
| TypeScript | `npx depcheck` (requires `depcheck`) or cross-reference `package.json` dependencies with Grep for `import.*from ['"]<pkg>` and `require\(['"]<pkg>` |
| Go | `go mod tidy -v 2>&1` (reports unused) |
| Rust | Manual: cross-reference `Cargo.toml` `[dependencies]` with Grep for `use <crate>` |

**Parse:** List packages that appear in manifest but not in any import statement.

**Severity:**
- LOW: Any unused dependency (usually harmless but indicates maintenance neglect)

**Remediation:** Remove unused dependencies. For packages used only in build/dev tooling, verify they're in the correct dependency group (devDependencies, build-dependencies, etc.).

---

### 2.4 Missing Lockfile

**What:** No lockfile means builds are not reproducible. Different environments may resolve different dependency versions, causing "works on my machine" bugs.

**How:**

Use Glob to check for:

| Language | Expected Lockfile |
|----------|-------------------|
| Python (Poetry) | `poetry.lock` |
| Python (pip) | `requirements.txt` (pinned versions) |
| TypeScript | `package-lock.json` or `yarn.lock` or `pnpm-lock.yaml` |
| Go | `go.sum` |
| Rust | `Cargo.lock` |

**Parse:** File exists or doesn't.

**Severity:**
- HIGH: No lockfile present for detected language

**Remediation:** Generate lockfile: `poetry lock`, `npm install`, `cargo generate-lockfile`, `go mod tidy`.

---

## 3. Code Hygiene

### 3.1 Stale TODOs/FIXMEs

**What:** TODO and FIXME comments that were meant as temporary markers but have persisted. They accumulate into undocumented technical debt.

**How:**

1. Use Grep to find markers:
   ```
   pattern: "TODO|FIXME|HACK|XXX"
   ```
   Exclude: `node_modules`, `.git`, `vendor`, `__pycache__`, lockfiles

2. Age each match via git blame:
   ```bash
   git blame -L <line>,<line> --format='%ai' <file>
   ```

**Parse:** Extract date from blame output. Calculate days elapsed.

**Severity:**
- HIGH: >60 days old
- MEDIUM: 30-60 days old
- LOW: <30 days old

**Remediation:** For each stale TODO: (1) complete the task if small, (2) file a backlog item if non-trivial, (3) remove if no longer relevant. Include the TODO text in backlog items for context.

---

### 3.2 Commented-Out Code

**What:** Blocks of commented-out code (>5 consecutive lines). These are noise — they confuse readers and are better served by version control history.

**How:**

Use Grep with multiline patterns per language:

| Language | Pattern Indicator |
|----------|-------------------|
| Python | 5+ consecutive lines starting with `#` that contain code-like patterns (assignments, function calls, imports) |
| TypeScript | `/* ... */` blocks >5 lines, or 5+ consecutive `//` lines with code patterns |
| Go | Same as TypeScript |
| Rust | Same as TypeScript |

Heuristic: Look for commented lines containing `=`, `(`, `{`, `import`, `def`, `func`, `fn`, `class`, `return`.

**Parse:** Report file, start line, and approximate line count of each block.

**Severity:**
- LOW: Any block of 5+ commented-out code lines

**Remediation:** Delete commented-out code. If there's concern about losing it, verify it's in git history first (`git log -p -- <file>`).

---

### 3.3 Print Debugging

**What:** Debug print statements left in production code. Leaks internal state to logs/console in production, and adds noise to output.

**How:**

Use Grep across non-test source files:

| Language | Pattern | Exclude |
|----------|---------|---------|
| Python | `print\(` | `*test*`, `*_test.py`, `conftest.py` |
| TypeScript | `console\.(log\|debug\|info\|warn\|error)` | `*.test.*`, `*.spec.*`, logging utility files |
| Go | `fmt\.Print(ln\|f)?` | `*_test.go` |
| Rust | `println!\|dbg!` | Test modules (`#[cfg(test)]`) |

**Parse:** File and line for each match. Exclude matches inside structured logging frameworks (e.g., `logger.info()` is fine, `print()` is not).

**Severity:**
- MEDIUM: Any print debug statement in non-test source

**Remediation:** Replace with structured logging (Python: `logging`, TS: configured logger, Go: `log` or `slog`, Rust: `log` or `tracing`), or remove if truly debug-only.

---

### 3.4 Placeholder Implementations

**What:** Code that explicitly declares it's not implemented. These are landmines — they compile/import fine but fail at runtime.

**How:**

Use Grep:

| Language | Pattern |
|----------|---------|
| Python | `raise NotImplementedError`, `pass  # TODO`, `...  # TODO` |
| TypeScript | `throw new Error\(.*not implemented`, `// TODO.*implement` |
| Go | `panic\(.*not implemented\|"implement` |
| Rust | `unimplemented!\(\)`, `todo!\(\)` |

**Parse:** File, line, and the surrounding context (function/method name).

**Severity:**
- HIGH: Any placeholder in non-test code (runtime failure risk)

**Remediation:** Implement the function, or if intentionally deferred, add a backlog item with clear acceptance criteria.

---

## 4. Secrets & Config

### 4.1 Hardcoded Secrets

**What:** API keys, passwords, tokens, and credentials with literal values in source code. The most critical code hygiene issue — committed secrets are immediately compromised.

**How:**

Use Grep with these patterns (case-insensitive):

```
# API keys and tokens
(api_key|apikey|api_secret|access_token|auth_token|secret_key)\s*[=:]\s*['"][a-zA-Z0-9]{16,}['"]

# Password assignments
(password|passwd|pwd)\s*[=:]\s*['"][^'"]{4,}['"]

# AWS patterns
(AKIA[0-9A-Z]{16})
(aws_secret_access_key|aws_access_key_id)\s*[=:]\s*['"][^'"]+['"]

# Generic secrets
(private_key|secret|token|credential)\s*[=:]\s*['"][a-zA-Z0-9/+=]{20,}['"]

# Connection strings
(mysql|postgres|mongodb|redis):\/\/[^@\s]+@
```

Exclude: `*.example`, `*.template`, `*.md`, `*.test.*`, test fixtures with obviously fake values.

**Parse:** File, line, and matched pattern. Do NOT include the actual secret value in the report — just indicate the type and location.

**Severity:**
- CRITICAL: Any match (secrets in source code are always critical)

**Remediation:** (1) Remove the secret from code immediately, (2) rotate the compromised credential, (3) move to environment variables or a secrets manager, (4) check git history — if committed, the secret is compromised regardless of current state.

---

### 4.2 .env Safety

**What:** `.env` files containing secrets that aren't gitignored. If `.env` is tracked by git, secrets are in version history.

**How:**

1. Check if `.env` exists (Glob: `.env`)
2. If it exists, check `.gitignore` for `.env` entry:
   ```bash
   git check-ignore .env
   ```
   Exit code 0 = ignored (safe). Exit code 1 = not ignored (unsafe).

**Parse:** Git exit code.

**Severity:**
- CRITICAL: `.env` exists and is NOT gitignored

**Remediation:** Add `.env` to `.gitignore`. If already committed, remove from tracking: `git rm --cached .env`. Rotate any secrets that were in committed `.env` files.

---

### 4.3 Missing .env.example

**What:** A `.env` file exists but no `.env.example` template. New developers won't know which environment variables are required.

**How:**

1. Check if `.env` exists (Glob: `.env`)
2. Check if `.env.example` or `.env.template` or `.env.sample` exists

**Parse:** `.env` present without any example template.

**Severity:**
- LOW: Missing example file (onboarding friction, not a security issue)

**Remediation:** Create `.env.example` with all variable names from `.env` but placeholder values (e.g., `API_KEY=your_api_key_here`).

---

## 5. Build-to-Design Drift

> These checks only run for ADF projects with `docs/design.md`.

### 5.1 Component Alignment

**What:** Components specified in design.md that don't exist in code, or components in code not mentioned in design.md. Drift between design and implementation leads to outdated documentation and architectural confusion.

**How:**

1. Read `docs/design.md`
2. Extract component names from the Components/Architecture section (look for headers, tables, or lists under "Components", "Architecture", "Modules", "Services")
3. For each component name, use Glob/Grep to search for corresponding:
   - Directories: `src/<component>/`, `<component>/`
   - Files: `<component>.py`, `<component>.ts`, `<component>.go`, `<component>.rs`
   - Classes/modules: `class <Component>`, `module <component>`
4. Also scan `src/` for top-level directories/modules not mentioned in design.md

**Parse:** Two lists: (1) design components missing from code, (2) code components missing from design.

**Severity:**
- HIGH: Component in design.md with no corresponding code (promised but unbuilt)
- MEDIUM: Component in code with no mention in design.md (undocumented)

**Remediation:** For missing implementations, either build them or update design.md. For undocumented components, add them to design.md or evaluate if they should be removed.

---

### 5.2 API Contract Drift

**What:** API endpoints specified in design.md that don't match actual route definitions in code. Causes integration failures and misleading documentation.

**How:**

1. Read `docs/design.md`
2. Extract API endpoints (look for HTTP methods + paths: `GET /api/users`, `POST /auth/login`, etc.)
3. Search code for route definitions:

| Framework | Pattern |
|-----------|---------|
| Express/Fastify | `app\.(get\|post\|put\|delete\|patch)\(['"]` |
| Flask/FastAPI | `@app\.(get\|post\|put\|delete\|patch)\(['"]` or `@router\.(get\|post\|put\|delete\|patch)` |
| Go (net/http) | `http\.Handle(Func)?\(['"]` or router patterns |
| Rust (Actix/Axum) | `web::(get\|post\|put\|delete)` or route macros |

4. Compare design endpoints with code endpoints.

**Parse:** Two lists: (1) design endpoints missing from code, (2) code endpoints missing from design.

**Severity:**
- HIGH: Endpoint in design.md with no corresponding route (promised but unbuilt)
- MEDIUM: Route in code with no mention in design.md (undocumented)

**Remediation:** Align design.md with actual implementation. If design is intentional, implement missing endpoints. If code has evolved, update design.md.

---

## 6. Documentation Sync

### 6.1 Dead Internal Links

**What:** Markdown links in documentation that point to files or anchors that don't exist. Broken links frustrate readers and signal neglected documentation.

**How:**

1. Use Grep to find markdown links in `*.md` files:
   ```
   pattern: "\[.*?\]\((?!https?://|#)([^)]+)\)"
   ```
   This matches relative links (not URLs or same-file anchors).

2. For each match, extract the target path and resolve it relative to the linking file.

3. Check if the target file exists (Glob or Read).

**Parse:** List of broken links with source file, line, and target path.

**Severity:**
- MEDIUM: Any dead internal link

**Remediation:** Fix the link target (file may have moved or been renamed), or remove the link if the target was intentionally deleted.

---

### 6.2 Version References

**What:** Version strings in documentation that don't match the package version. After version bumps, documentation often contains stale version references.

**How:**

1. Read the canonical version from:
   - `package.json` → `version` field
   - `pyproject.toml` → `[tool.poetry] version` or `[project] version`
   - `Cargo.toml` → `version` field
   - `go.mod` → no single version (skip for Go)

2. Use Grep to find version strings in `*.md` files:
   ```
   pattern: "v?[0-9]+\.[0-9]+\.[0-9]+"
   ```

3. Compare found versions with canonical version. Exclude obvious non-project versions (dependency versions, spec versions).

**Parse:** Documentation files referencing versions that don't match the canonical project version.

**Severity:**
- LOW: Version mismatch in docs (misleading but not harmful)

**Remediation:** Update version references to match current package version, or clarify that the version refers to something else (a dependency, a spec, etc.).

---

## 7. Doc Freshness

> These checks run for ADF projects. They use frontmatter metadata to detect when documentation has fallen behind code changes.

### 7.1 Stale Docs (covers-based)

**What:** Docs with `covers:` frontmatter that haven't been updated since the code paths they cover changed. This is the highest-signal staleness check — it pairs specific docs to specific code and detects drift.

**How:**

1. Find all `.md` files in `docs/active/` and root artifacts (`intent.md`, `README.md`)
2. For each file, parse YAML frontmatter for `updated:` and `covers:` fields
3. If both exist, run:
   ```bash
   git log --oneline --since="<updated_date>" -- <covers_path_1> <covers_path_2> ...
   ```
4. Count the commits returned. This is the "drift distance."

**Parse:** For each doc with `covers:`, report:
- Doc name and `updated:` date
- Covered paths
- Number of commits to covered paths since last update
- Most recent commit summary (first line of `git log`)

**Severity:**
- HIGH: >10 commits to covered paths since doc update (significant drift)
- MEDIUM: 1-10 commits to covered paths since doc update (some drift)
- PASS: 0 commits to covered paths (doc is current)

**Remediation:** Review the commits to covered paths and update the doc to reflect current state. Update the `updated:` date in frontmatter after review. If the commits are trivial (formatting, comments), the doc may still be current — use judgment.

**Example:**
```
[HIGH] design.md is stale
  Updated: 2026-03-10
  Covers: src/api/, src/models/, config/
  Drift: 14 commits since last update
  Latest: "refactor(api): switch from REST to GraphQL"
  → design.md likely no longer reflects the API architecture
```

---

### 7.2 Stale Docs (age-based)

**What:** Docs with `updated:` but no `covers:` field — a fallback age check. Less precise than covers-based (no code path pairing) but still useful for catching neglected docs.

**How:**

1. Find all `.md` files in `docs/active/` and root artifacts with `updated:` frontmatter but no `covers:` field
2. Calculate days since `updated:` date:
   ```bash
   # In the agent's context, compare updated date to today
   ```

**Parse:** Doc name, `updated:` date, days elapsed.

**Severity:**
- HIGH: >60 days since last update
- MEDIUM: 30-60 days since last update
- PASS: <30 days

**Remediation:** Review the doc for accuracy. If still current, update the `updated:` date. If stale, revise content and update date. Consider adding `covers:` frontmatter to enable more precise tracking.

---

### 7.3 Missing Freshness Metadata

**What:** Docs in `docs/active/` or root artifacts that have no `updated:` field at all. Without metadata, freshness can't be tracked.

**How:**

1. Find all `.md` files in `docs/active/` and root artifacts (`intent.md`, `README.md`, `BACKLOG.md`, `status.md`, `decisions.md`)
2. Parse frontmatter — check for `updated:` field
3. Exclude: `AGENTS.md`, `CLAUDE.md` (instruction files, not project docs), `.ctx/` (ephemeral)

**Parse:** List of docs missing `updated:` in frontmatter.

**Severity:**
- LOW: Missing `updated:` field (can't track freshness, but not blocking)

**Remediation:** Add YAML frontmatter with at minimum `updated: "YYYY-MM-DD"`. Optionally add `covers:` for code-paired tracking.
