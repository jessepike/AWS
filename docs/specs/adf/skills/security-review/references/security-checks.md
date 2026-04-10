# Security Checks Catalog

Detailed reference for all 22 security checks. Organized by category with per-language Grep patterns for Python and TypeScript (primary), plus Go and Rust where applicable.

---

## 1. Injection & Input Validation

### INJ-01: SQL Injection

**What:** String concatenation or interpolation used to build SQL queries. Allows attackers to manipulate query logic, extract data, or modify/delete records. The most exploited vulnerability class in web applications.

**How:**

Use Grep across source files (exclude tests, migrations, node_modules, vendor):

| Language | Pattern |
|----------|---------|
| Python | `execute\(.*[f"'].*\{` , `execute\(.*%s.*%` , `execute\(.*\+.*\+` , `cursor\.\w+\(.*[f"']` |
| TypeScript | `query\(.*\$\{` , `query\(.*\+.*\+` , `raw\(.*\$\{` , `exec\(.*\$\{` |
| Go | `Exec\(.*fmt\.Sprintf` , `Query\(.*fmt\.Sprintf` , `Query\(.*\+` |
| Rust | `execute\(.*format!` , `query\(.*format!` |

**Parse:** For each match, inspect context:
- Is the variable user-controlled (from request params, body, headers)?
- Is parameterized binding used? (`?`, `$1`, `:param` — these are safe)
- String concat/interpolation with external input = finding

**Severity:** Critical — direct database compromise

**Remediation:**
- Use parameterized queries / prepared statements
- Python: `cursor.execute("SELECT * FROM users WHERE id = %s", (user_id,))`
- TypeScript: `db.query("SELECT * FROM users WHERE id = $1", [userId])`
- Go: `db.Query("SELECT * FROM users WHERE id = ?", userId)`
- ORMs with proper binding are safe (SQLAlchemy, Prisma, GORM)

**Boundary:** security-guidance does NOT check for SQL injection. project-health does NOT check for SQL injection. This is unique to security-review.

---

### INJ-02: Command Injection

**What:** User input passed to shell execution functions without sanitization. Allows arbitrary command execution on the server. Distinct from security-guidance which blocks eval/exec at edit-time — this check finds existing patterns in code.

**How:**

| Language | Pattern |
|----------|---------|
| Python | `subprocess\.(call\|run\|Popen)\(.*[f"']` , `os\.system\(.*[f"']` , `os\.popen\(.*[f"']` |
| TypeScript | `child_process\.\w+\(.*\$\{` , `exec\(.*\$\{` , `execSync\(.*\$\{` , `spawn\(.*\$\{` |
| Go | `exec\.Command\(.*\+` , `exec\.Command\(.*fmt\.Sprintf` |
| Rust | `Command::new\(.*format!` , `Command::new\(.*&` |

**Parse:** Inspect whether the interpolated/concatenated value comes from user input (request params, env vars from untrusted source, file content).

**Severity:** High — arbitrary command execution

**Remediation:**
- Use array-based command construction: `subprocess.run(["cmd", arg1, arg2])`
- Never pass user input through shell interpretation
- Use allowlists for valid command arguments
- Python: `shlex.quote()` for unavoidable shell strings
- TypeScript: `execFile` instead of `exec`

**Boundary:** security-guidance blocks exec/eval usage at edit-time (PreToolUse). This check finds existing instances in codebase and covers subprocess, os.system, child_process — broader scope than security-guidance's 8 patterns.

---

### INJ-03: Path Traversal

**What:** User-controlled input used to construct file paths without validation. Attackers use `../` sequences to access files outside the intended directory.

**How:**

| Language | Pattern |
|----------|---------|
| Python | `open\(.*[f"'].*\{` , `Path\(.*[f"'].*\{` , `os\.path\.join\(.*request` , `send_file\(.*request` |
| TypeScript | `readFile.*\$\{` , `createReadStream.*\$\{` , `path\.join\(.*req\.` , `path\.resolve\(.*req\.` |
| Go | `os\.Open\(.*\+` , `filepath\.Join\(.*r\.` , `http\.ServeFile\(.*r\.` |
| Rust | `File::open\(.*format!` , `Path::new\(.*&` |

**Parse:** Check whether file path includes user-controlled segments. Look for:
- Request parameters in file paths
- Missing `../` filtering or path canonicalization
- No base directory restriction

**Severity:** High — arbitrary file read/write

**Remediation:**
- Canonicalize paths and verify they stay within an allowed base directory
- Python: `os.path.realpath()` then check prefix
- TypeScript: `path.resolve()` then verify starts with base dir
- Never use raw user input in file paths
- Use allowlists for valid filenames when possible

**Boundary:** Not covered by security-guidance or project-health.

---

### INJ-04: XSS Patterns

**What:** Server-side template injection or unsafe HTML rendering that allows attacker-controlled content to execute as script in user browsers.

**How:**

| Language | Pattern |
|----------|---------|
| Python | `\|safe` (Jinja2), `mark_safe\(` (Django), `Markup\(.*[f"']` , `render_template_string\(` |
| TypeScript | `dangerouslySetInnerHTML` , `innerHTML\s*=` , `document\.write\(` , `\.html\(.*\$\{` , `res\.send\(.*\$\{.*<` |
| Go | `template\.HTML\(` , `Fprintf\(w,.*<` , `Write\(\[\]byte\(.*<` |
| Rust | `PreEscaped\(` (Maud), `Raw\(` (Askama) |

**Parse:** Distinguish between:
- Static HTML (safe) vs dynamic content with user input (unsafe)
- Template engine auto-escaping disabled vs enabled
- Explicit raw/unsafe markers on user-controlled content = finding

**Severity:** High — client-side code execution

**Remediation:**
- Use template engine auto-escaping (enabled by default in most frameworks)
- Never bypass escaping for user-controlled content
- Use Content Security Policy headers
- Sanitize HTML with allowlisted tags if rich text is needed (DOMPurify, bleach)

**Boundary:** security-guidance blocks innerHTML at edit-time. This check finds existing instances plus broader patterns (template safe filters, mark_safe, dangerouslySetInnerHTML, server-side rendering with interpolation).

---

### INJ-05: SSRF Indicators

**What:** User-controlled URLs passed to server-side HTTP request functions. Allows attackers to make the server request internal resources, cloud metadata endpoints, or other internal services.

**How:**

| Language | Pattern |
|----------|---------|
| Python | `requests\.(get\|post\|put\|delete)\(.*[f"'].*\{` , `urllib\.request\.urlopen\(.*[f"']` , `httpx\.\w+\(.*[f"']` |
| TypeScript | `fetch\(.*\$\{` , `axios\.\w+\(.*\$\{` , `http\.request\(.*\$\{` , `got\(.*\$\{` |
| Go | `http\.Get\(.*\+` , `http\.NewRequest\(.*\+` , `http\.Get\(.*fmt\.Sprintf` |
| Rust | `reqwest::get\(.*format!` , `Client::new\(\).*get\(.*format!` |

**Parse:** Check if the URL being requested includes user-controlled components:
- Full URL from user input
- Host/domain from user input
- Path segments from user input

**Severity:** High — internal network access, cloud metadata exposure

**Remediation:**
- Validate/allowlist URLs before making requests
- Block requests to private IP ranges (10.x, 172.16-31.x, 192.168.x, 169.254.x)
- Block cloud metadata endpoints (169.254.169.254)
- Use URL parsing to validate host before requesting
- DNS rebinding protection: resolve hostname and validate IP before connecting

**Boundary:** Not covered by security-guidance or project-health.

---

## 2. Cryptography & Secrets

### CRY-01: Weak Hashing for Auth

**What:** MD5 or SHA1 used for password hashing. These algorithms are fast by design, making brute-force attacks trivial. Password hashing requires intentionally slow algorithms.

**How:**

| Language | Pattern |
|----------|---------|
| Python | `hashlib\.md5\(` , `hashlib\.sha1\(` (in auth/user/password context), `md5\(.*password` , `sha1\(.*password` |
| TypeScript | `createHash\(['"]md5['"]\)` , `createHash\(['"]sha1['"]\)` (near password handling), `md5\(.*password` |
| Go | `md5\.New\(\)` , `sha1\.New\(\)` (in auth context), `md5\.Sum\(.*pass` |
| Rust | `Md5::new\(\)` , `Sha1::new\(\)` (in auth context) |

**Parse:** Context matters — MD5/SHA1 for checksums or non-security purposes is acceptable. Flag only when:
- Used in auth/login/password/credential handling code
- Variable names suggest password hashing (hash, digest + password, credential, auth)

**Severity:** Critical — trivially brute-forceable password storage

**Remediation:**
- Python: `bcrypt.hashpw()` or `argon2.PasswordHasher()`
- TypeScript: `bcrypt.hash()` or `argon2.hash()`
- Go: `golang.org/x/crypto/bcrypt`
- Rust: `argon2` or `bcrypt` crate
- Never roll custom password hashing

**Boundary:** project-health checks for hardcoded secret values (4.1). This check focuses on weak algorithm choice — different concern.

---

### CRY-02: Insecure Randomness

**What:** Non-cryptographic random number generators used for security-sensitive values (tokens, session IDs, nonces, keys). Predictable output allows attackers to guess generated values.

**How:**

| Language | Pattern |
|----------|---------|
| Python | `random\.(random\|randint\|choice\|randrange)` (near token/session/key/nonce/secret context) |
| TypeScript | `Math\.random\(\)` (near token/session/key/nonce/secret context) |
| Go | `math/rand` (imported in files with security context), `rand\.Intn\|rand\.Int\(\)` |
| Rust | `rand::thread_rng\(\)` is actually CSPRNG (safe) — flag `rand::rngs::SmallRng` or seeded non-crypto RNG |

**Parse:** Context is critical — Math.random() for UI randomization is fine. Flag when:
- Used to generate tokens, session IDs, API keys, nonces, OTPs
- Variable names suggest security purpose (token, session, secret, key, nonce, otp, csrf)

**Severity:** High — predictable security tokens

**Remediation:**
- Python: `secrets.token_hex()`, `secrets.token_urlsafe()`
- TypeScript: `crypto.randomBytes()`, `crypto.randomUUID()`
- Go: `crypto/rand` instead of `math/rand`
- Rust: `rand::rngs::OsRng` or `getrandom` crate

**Boundary:** Not covered by security-guidance or project-health.

---

### CRY-03: Hardcoded Crypto Material

**What:** Encryption keys, IVs (initialization vectors), salts, or other cryptographic material hardcoded in source code. Unlike secrets (API keys, passwords) which project-health checks, this covers cryptographic primitives that should be generated at runtime.

**How:**

| Language | Pattern |
|----------|---------|
| Python | `(iv\|IV\|salt\|SALT\|key\|KEY\|nonce)\s*=\s*b['"]` , `AES\.new\(b['"]` , `Fernet\(b['"]` |
| TypeScript | `(iv\|salt\|key\|nonce)\s*=\s*Buffer\.from\(['"]` , `createCipheriv\(.*,\s*['"]` |
| Go | `(iv\|salt\|key\|nonce)\s*:?=\s*\[\]byte\{` , `(iv\|salt\|key\|nonce)\s*:?=\s*\[\]byte\(['"]` |
| Rust | `(iv\|salt\|key\|nonce).*=.*\[(\d+,?\s*)+\]` , `(iv\|salt\|key\|nonce).*=.*b"` |

**Parse:** Flag hardcoded byte strings or arrays assigned to crypto-related variable names. Exclude test fixtures and example/documentation files.

**Severity:** Critical — reused crypto material compromises all encrypted data

**Remediation:**
- Generate IVs/nonces randomly for each encryption operation
- Derive keys from passwords using KDFs (PBKDF2, scrypt, Argon2)
- Generate salts randomly per-user
- Store keys in environment variables or key management service
- Never reuse IVs with the same key

**Boundary:** project-health 4.1 checks for hardcoded secrets (API keys, passwords, tokens). This check targets cryptographic material specifically (IVs, salts, encryption keys) — different pattern, different remediation.

---

### CRY-04: Insecure TLS Configuration

**What:** Disabled certificate verification or use of deprecated TLS versions. Allows man-in-the-middle attacks on HTTPS connections.

**How:**

| Language | Pattern |
|----------|---------|
| Python | `verify=False` , `CERT_NONE` , `check_hostname\s*=\s*False` , `SSLv2\|SSLv3\|TLSv1_0\|TLSv1_1` |
| TypeScript | `rejectUnauthorized:\s*false` , `NODE_TLS_REJECT_UNAUTHORIZED.*0` , `secureProtocol.*SSLv\|TLSv1_method` |
| Go | `InsecureSkipVerify:\s*true` , `tls\.VersionSSL\|tls\.VersionTLS10\|tls\.VersionTLS11` |
| Rust | `danger_accept_invalid_certs\(true\)` , `danger_accept_invalid_hostnames\(true\)` |

**Parse:** Check context:
- Development/test environment bypass (with env check) = informational
- Production code without env guard = finding
- Deprecated protocol versions = always finding

**Severity:** High — man-in-the-middle attacks

**Remediation:**
- Never disable certificate verification in production
- If needed for development, guard with explicit environment checks
- Use TLS 1.2+ minimum; prefer TLS 1.3
- Remove SSLv2, SSLv3, TLS 1.0, TLS 1.1 references

**Boundary:** Not covered by security-guidance or project-health.

---

## 3. Unsafe Operations

### UNS-01: Unsafe Deserialization

**What:** Deserializing data from untrusted sources using formats that can execute code. Attackers craft malicious serialized objects that execute arbitrary code on deserialization.

**How:**

| Language | Pattern |
|----------|---------|
| Python | `pickle\.load` , `pickle\.loads` , `yaml\.load\(` (without `Loader=SafeLoader`), `marshal\.load` , `shelve\.open` |
| TypeScript | `unserialize\(` , `deserialize\(` (non-JSON), `node-serialize` import, `js-yaml\.load\(` (without `schema: SAFE_SCHEMA`) |
| Go | `gob\.NewDecoder` (from untrusted source), `encoding/gob` with network input |
| Rust | `bincode::deserialize` (from untrusted source), serde with untrusted format and deny_unknown_fields missing |

**Parse:** Key distinction:
- JSON deserialization is generally safe (no code execution)
- pickle, yaml.load, marshal, node-serialize are dangerous
- Safe alternatives exist for each (yaml.safe_load, SafeLoader)

**Severity:** Critical — remote code execution

**Remediation:**
- Python: `yaml.safe_load()` instead of `yaml.load()`, avoid pickle for untrusted data
- TypeScript: Use JSON.parse() for data interchange, avoid node-serialize
- Use schema validation after deserialization
- Never deserialize untrusted data with formats that support code execution

**Boundary:** Not covered by security-guidance or project-health.

---

### UNS-02: Unrestricted File Upload

**What:** File upload handlers that don't validate file type, size, or content. Allows attackers to upload executable files, web shells, or oversized files for denial of service.

**How:**

| Language | Pattern |
|----------|---------|
| Python | `request\.files` , `UploadFile` , `FileField` — then check for missing content_type / allowed_extensions / max_size validation |
| TypeScript | `multer\(` , `req\.file` , `formidable` — then check for missing fileFilter / limits configuration |
| Go | `r\.FormFile\(` , `multipart\.Reader` — then check for missing content-type / size validation |
| Rust | `Multipart` , `multipart::Field` — then check for missing validation |

**Parse:** Two-step check:
1. Find file upload handlers
2. Within the handler (surrounding ~30 lines), look for validation:
   - Content-type / MIME type checking
   - File extension allowlisting
   - File size limits
   - If none found = finding

**Severity:** High — web shell upload, denial of service

**Remediation:**
- Validate MIME type AND file extension (attackers can spoof either)
- Enforce maximum file size
- Store uploads outside web root
- Generate random filenames (don't use user-provided names)
- Scan uploads for malware if possible

**Boundary:** Not covered by security-guidance or project-health.

---

### UNS-03: Race Conditions (TOCTOU)

**What:** Time-of-check to time-of-use patterns where a resource is checked and then used without atomicity. Attackers exploit the gap between check and use.

**How:**

| Language | Pattern |
|----------|---------|
| Python | `os\.path\.exists\(.*\).*open\(` (check-then-open), `os\.access\(.*\).*open\(` |
| TypeScript | `existsSync\(.*\).*readFileSync\(` , `access\(.*\).*then.*readFile\(` |
| Go | `os\.Stat\(.*\).*os\.Open\(` , `os\.IsNotExist\(.*\).*os\.Create\(` |
| Rust | `Path::exists\(\).*File::open\(` , `metadata\(\).*File::create\(` |

**Parse:** Look for patterns where:
- File existence is checked, then file is opened (could be replaced between check and open)
- Permission is checked, then action is taken
- Resource availability is checked, then resource is used
- Multi-step operations without locking

**Severity:** Medium — data corruption, privilege escalation in specific scenarios

**Remediation:**
- Use atomic operations: open with create-exclusive flag (O_EXCL, x mode)
- Use file locking for multi-step file operations
- Use database transactions for check-then-act on DB resources
- Use compare-and-swap for concurrent data structures

**Boundary:** Not covered by security-guidance or project-health.

---

### UNS-04: Information Leakage

**What:** Stack traces, detailed error messages, debug information, or internal paths exposed to end users. Helps attackers understand internal architecture and find vulnerabilities.

**How:**

| Language | Pattern |
|----------|---------|
| Python | `traceback\.format_exc\(\)` in response handlers, `debug=True` in production Flask/Django config, `return.*str\(e\)` in API handlers |
| TypeScript | `stack.*res\.(json\|send)` , `err\.message.*res\.(json\|send)` , NODE_ENV production check absent near error responses |
| Go | `http\.Error\(w,\s*err\.Error\(\)` , `fmt\.Fprintf\(w,.*err` , `debug.*true` in production |
| Rust | `format!` with err in response builders, `.unwrap()` in handlers |

**Parse:** Context matters:
- Error details returned to client/user = finding
- Error details logged server-side only = safe
- Debug mode enabled without env guard = finding

**Severity:** Medium — information disclosure aids further attacks

**Remediation:**
- Return generic error messages to users ("An error occurred")
- Log detailed errors server-side only
- Ensure debug mode is disabled in production
- Use error IDs that map to detailed server logs
- Strip stack traces from API responses

**Boundary:** Not covered by security-guidance or project-health.

---

### UNS-05: Prototype Pollution

**What:** JavaScript/TypeScript-specific vulnerability where user-controlled input modifies Object.prototype properties, affecting all objects. Can lead to denial of service, property injection, or in some cases remote code execution.

**How:**

| Language | Pattern |
|----------|---------|
| TypeScript/JS | `Object\.assign\(.*req\.` , spread of req.body/query/params into objects , dynamic property assignment from req , `lodash\.merge\(.*req\.` , `_.merge\(.*req\.` , `deepMerge\(.*req\.` |

**Parse:** Flag when:
- User input (req.body, req.query, req.params) is directly spread into objects
- Dynamic property names from user input: `obj[userInput] = value`
- Deep merge utilities receiving user input without sanitization

**Severity:** High — property injection, potential RCE via gadgets

**Remediation:**
- Validate and allowlist properties before merging user input
- Use `Object.create(null)` for dictionaries to avoid prototype chain
- Freeze prototypes: `Object.freeze(Object.prototype)` (aggressive)
- Use schema validation (Zod, Joi) to strip unexpected properties
- Avoid lodash.merge/_.merge with untrusted input — use Object.assign with validated data

**Boundary:** Not covered by security-guidance (which checks for eval/innerHTML but not prototype pollution) or project-health.

---

## 4. Supply Chain

### SUP-01: Lockfile Integrity

**What:** Package manifest was edited (new dependency, version change) but the lockfile wasn't regenerated. Means the lockfile doesn't reflect actual resolved dependencies, breaking reproducibility and potentially pulling unexpected versions.

**How:**

1. Check git status for modified manifest files:
```bash
git diff --name-only HEAD~5 -- package.json pyproject.toml Cargo.toml go.mod
```

2. Check if corresponding lockfile was also modified in the same commits:
```bash
git diff --name-only HEAD~5 -- package-lock.json yarn.lock pnpm-lock.yaml poetry.lock Cargo.lock go.sum
```

3. Compare: if manifest changed but lockfile didn't = finding

**Parse:** Manifest file modified without corresponding lockfile modification in same or subsequent commit.

**Severity:** High — unreproducible builds, dependency confusion

**Remediation:**
- Run package manager install/lock command after editing manifests
- npm install, yarn install, poetry lock, cargo generate-lockfile, go mod tidy
- CI should fail if lockfile is out of sync (most package managers support this)

**Boundary:** project-health 2.4 checks for missing lockfiles. This check ensures lockfile stays in sync with manifest — different concern.

---

### SUP-02: Typosquatting Indicators

**What:** Dependencies with names suspiciously similar to popular packages. Typosquatting is a supply chain attack where malicious packages mimic popular ones.

**How:**

Read manifest files and check dependency names against known typosquatting patterns:

**Heuristic patterns:**
1. Single character swap: Levenshtein distance 1 from popular package
2. Character duplication: doubled characters in package names
3. Homoglyph substitution: `rn` for `m`, `0` for `o`, `1` for `l`
4. Namespace confusion: scoped packages mimicking unscoped ones

**Popular package list (check against):**
- npm: lodash, express, react, vue, axios, moment, webpack, babel, eslint, prettier, typescript, next, nuxt, chalk, commander, inquirer, yargs, debug, dotenv, cors
- PyPI: requests, django, flask, numpy, pandas, sqlalchemy, celery, boto3, pillow, cryptography, httpx, fastapi, pydantic, pytest, black, mypy

**Parse:** Flag any dependency within edit distance 1-2 of a popular package (excluding the popular package itself).

**Severity:** Medium — potential malicious code execution

**Remediation:**
- Verify package publisher and repository link
- Check package download counts (typosquats typically have low counts)
- Use `npm audit signatures` (npm) or verified publishers
- Pin exact versions and review new dependencies manually

**Boundary:** Not covered by security-guidance or project-health.

---

### SUP-03: Post-Install Scripts

**What:** Package.json lifecycle scripts (preinstall, install, postinstall) that execute shell commands or make network calls. These run automatically on `npm install` and can execute arbitrary code.

**How:**

1. Read `package.json` and check for `scripts` with these keys:
   - `preinstall`, `install`, `postinstall`
   - `preuninstall`, `uninstall`, `postuninstall`
   - `prepare` (runs on install for git dependencies)

2. For each lifecycle script found, check if it:
   - Makes network calls (curl, wget, fetch, http, https)
   - Executes shell commands (sh, bash, node -e)
   - Accesses environment variables
   - Writes to filesystem outside project directory

3. Also check `node_modules/*/package.json` for lifecycle scripts in dependencies (sample top 20 by size):
```bash
find node_modules -maxdepth 2 -name package.json -exec grep -l 'postinstall\|preinstall' {} \;
```

**Parse:** Flag lifecycle scripts with network access or shell execution. Informational for simple build scripts (tsc, node-gyp).

**Severity:** Medium — supply chain code execution during install

**Remediation:**
- Review all lifecycle scripts before installation
- Use `npm install --ignore-scripts` then selectively run needed scripts
- Use `npx can-i-ignore-scripts` to assess which scripts are needed
- For your own packages: avoid lifecycle scripts; use explicit build commands

**Boundary:** Not covered by security-guidance or project-health.

---

### SUP-04: Pinning Strategy

**What:** Dependencies using version ranges instead of exact versions. While lockfiles mitigate this for direct installs, ranges affect resolution in published packages and CI without lockfiles.

**How:**

| Language | Check |
|----------|-------|
| TypeScript/JS | In `package.json`, check dependencies and devDependencies for `^`, `~`, `>=`, `*`, `>`, `latest` prefixes |
| Python | In `requirements.txt`, check for `>=`, `~=`, `>`, `!=` constraints without upper bound. In `pyproject.toml`, check for `^`, `~`, `>=` |
| Go | go.mod — Go uses minimum version selection, generally safe. Flag indirect deps without explicit require |
| Rust | In `Cargo.toml`, check for `^`, `~`, `>=`, `*` in dependencies |

**Parse:** Count dependencies using ranges vs exact versions. Report ratio and list range-using deps.

**Severity:** Low — build reproducibility risk (lockfiles mitigate for most scenarios)

**Remediation:**
- Use exact versions for production dependencies in applications
- Ranges are acceptable for libraries (consumers need flexibility)
- Always maintain lockfiles (the primary defense)
- Use `npm ci` / `pip install --require-hashes` in CI for locked installs

**Boundary:** project-health 2.4 checks for missing lockfiles. This check evaluates the pinning strategy within manifests — complementary concern.

---

## 5. Design Security Posture

> These checks only run for ADF projects with `docs/design.md`.

### DSG-01: Threat Model Presence

**What:** Whether the design document includes threat analysis — identification of threat actors, attack vectors, and mitigations. A design without threat modeling produces code with security blind spots.

**How:**

1. Read `docs/design.md`
2. Search for sections indicating threat modeling:
   - Headers: `Threat`, `Security`, `Attack`, `Risk`, `Adversar`
   - Content patterns: `threat model`, `attack vector`, `attack surface`, `trust boundary`, `STRIDE`, `threat actor`, `adversary`, `mitigation`

**Parse:** Check for:
- Dedicated threat/security section (strong signal)
- Threat-related keywords in any section (weak signal)
- Neither = finding

**Severity:** High — design without security thinking leads to vulnerable implementation

**Remediation:**
- Add a "Security Considerations" or "Threat Model" section to design.md
- Identify: trust boundaries, threat actors, attack vectors
- For each threat: describe impact and planned mitigation
- Consider using STRIDE framework (Spoofing, Tampering, Repudiation, Information Disclosure, Denial of Service, Elevation of Privilege)

**Boundary:** adf-review checks design.md for structural completeness. This check specifically looks for security content — different dimension.

---

### DSG-02: Auth/Authz Strategy

**What:** Whether the design explicitly defines how authentication (who are you?) and authorization (what can you do?) work. Undefined auth leads to ad-hoc implementation with gaps.

**How:**

1. Read `docs/design.md`
2. Search for auth-related content:
   - Headers: `Auth`, `Authentication`, `Authorization`, `Access Control`, `Permissions`, `RBAC`, `Identity`
   - Content patterns: `JWT`, `OAuth`, `session`, `token`, `RBAC`, `role`, `permission`, `ACL`, `middleware.*auth`, `guard`, `policy`

**Parse:** Check for:
- Defined auth mechanism (JWT, OAuth, sessions, etc.)
- Authorization model (RBAC, ABAC, ACL, etc.)
- Both defined = pass
- One defined = medium finding
- Neither = high finding

**Severity:** High — undefined auth leads to inconsistent, bypassable access control

**Remediation:**
- Add "Authentication" section defining: mechanism, token lifecycle, session management
- Add "Authorization" section defining: model (RBAC/ABAC), permission enforcement points, default deny
- Document: which endpoints are public, which require auth, which require specific roles

**Boundary:** adf-review checks design structure. This specifically validates security strategy content.

---

### DSG-03: Data Classification

**What:** Whether the design identifies sensitive data types and their protection requirements. Without data classification, developers don't know which data needs encryption, access controls, or audit logging.

**How:**

1. Read `docs/design.md`
2. Search for data classification content:
   - Headers: `Data`, `Classification`, `Sensitive`, `PII`, `Privacy`, `Encryption`
   - Content patterns: `PII`, `PHI`, `sensitive data`, `personally identifiable`, `encrypt`, `at rest`, `in transit`, `data classification`, `GDPR`, `HIPAA`, `confidential`

**Parse:** Check for:
- Explicit data classification (what data is sensitive)
- Protection strategy (how sensitive data is protected)
- Both = pass, one = medium finding, neither = medium finding

**Severity:** Medium — undefined data classification leads to inconsistent protection

**Remediation:**
- Add "Data Classification" section listing data types with sensitivity levels
- For each sensitive data type: encryption at rest, encryption in transit, access controls, retention policy
- Identify regulatory requirements (GDPR, HIPAA, SOC2) if applicable

**Boundary:** Not covered by project-health or security-guidance. adf-review checks design structure but not security-specific content.

---

### DSG-04: Input Validation Strategy

**What:** Whether the design defines an approach to validating external input. Without a defined strategy, input validation is inconsistent — some endpoints validate, others don't.

**How:**

1. Read `docs/design.md`
2. Search for input validation content:
   - Headers: `Input`, `Validation`, `Sanitiz`, `Schema`
   - Content patterns: `input validation`, `sanitiz`, `schema validation`, `Zod`, `Joi`, `pydantic`, `marshmallow`, `validator`, `whitelist`, `allowlist`, `boundary`, `trust boundary`

**Parse:** Check for:
- Defined validation approach (schema validation, allowlisting, etc.)
- Validation boundary (where validation happens — API layer, service layer, etc.)
- Both = pass, one = medium finding, neither = medium finding

**Severity:** Medium — inconsistent input validation is the root cause of most injection vulnerabilities

**Remediation:**
- Add "Input Validation" section defining: validation library/approach, validation boundary, default behavior
- Specify: all external input validated at API boundary, schema validation for request bodies, parameterized queries for database access
- Document: which inputs are allowlisted vs validated vs sanitized

**Boundary:** Not covered by project-health or security-guidance (which prevents dangerous patterns but doesn't check for validation strategy).
