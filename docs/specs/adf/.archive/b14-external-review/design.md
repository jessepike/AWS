---
type: "design"
description: "Design for the external-review skill + MCP server — automated Phase 2 review via external LLM APIs"
version: "1.4.0"
updated: "2026-02-01"
status: "complete"
review_cycle: 3
scope: "acm"
lifecycle: "draft"
location: "acm/docs/design.md"
implements: "ACM-REVIEW-SPEC v1.2.0"
brief_ref: "docs/discover-brief.md"
backlog_ref: "B14"
---

# External Review Skill + MCP Server — Design

## Purpose

Define the `external-review` skill — an MCP-based automation that executes Phase 2 external reviews by calling external LLM APIs (Kimi K2, Gemini, DeepSeek, etc.) within Ralph Loop cycles, with Claude Code as the orchestrating synthesizer.

## Problem Statement

Phase 2 external review currently requires manual effort:
1. Copy artifact + prompt to external model interface
2. Copy response back to Claude Code
3. Repeat for each model
4. Manually trigger synthesis

This friction discourages external review usage. Automation removes the friction while preserving the review quality.

---

## Design Goals

| Goal | Description |
|------|-------------|
| **One-command execution** | User runs `/external-review`, everything else is inferred or configured |
| **Confirm before execute** | Show resolved configuration, wait for user confirmation |
| **Same rules apply** | Cycle rules, severity, complexity, action matrix from ACM-REVIEW-SPEC |
| **Provider-abstracted** | Swap models by editing config, not code |
| **Parallel execution** | Multiple models called simultaneously |
| **Claude Code synthesizes** | External models provide feedback; Claude Code decides actions |

---

## Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                     EXTERNAL REVIEW SYSTEM                          │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ~/.claude/                                                         │
│  └── models.yaml ─────────┐    (API keys, user-specific, gitignored)│
│                           │                                         │
│  acm/skills/external-review/                                        │
│  ├── SKILL.md             │                                         │
│  ├── config.yaml ─────────┼──▶ ┌─────────────────────────────────┐ │
│  └── server/              │    │       MCP SERVER                │ │
│      ├── external_review_server.py     (external-review)         │ │
│      └── providers/       │    │                                 │ │
│          ├── base.py      │    │  Tools:                         │ │
│          ├── openai_compat.py  │  • list_models()                │ │
│          └── google.py   ◀┘    │  • review(models[], artifact,   │ │
│                                │          prompt) → parallel     │ │
│                                │          calls → aggregated     │ │
│                                └─────────────────────────────────┘ │
│                                              │                      │
│  acm/prompts/                                │                      │
│  ├── external-review-prompt.md              │                      │
│  ├── design-external-review-prompt.md       │                      │
│  └── develop-external-review-prompt.md      │                      │
│                                              ▼                      │
│  ┌───────────────────────────────────────────────────────────────┐ │
│  │                      CLAUDE CODE                              │ │
│  │  ┌─────────────────────────────────────────────────────────┐ │ │
│  │  │  Ralph Loop (external review cycle)                     │ │ │
│  │  │                                                         │ │ │
│  │  │  1. Resolve stage, artifact, prompt, models             │ │ │
│  │  │  2. Display configuration, wait for confirmation        │ │ │
│  │  │  3. Call MCP: review(["kimi-k2","gemini"], ...)        │ │ │
│  │  │  4. Receive aggregated feedback from all models         │ │ │
│  │  │  5. Synthesize (cross-reference, consensus weight)      │ │ │
│  │  │  6. Classify severity/complexity per ACM-REVIEW-SPEC    │ │ │
│  │  │  7. Auto-fix Low/Medium complexity, flag High to user   │ │ │
│  │  │  8. Update artifact + Issue Log + Review Log            │ │ │
│  │  │  9. Check stop conditions → loop or exit                │ │ │
│  │  └─────────────────────────────────────────────────────────┘ │ │
│  └───────────────────────────────────────────────────────────────┘ │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Skill Structure

```
acm/skills/external-review/
├── SKILL.md                          # Instructions, usage, when to invoke
├── config.yaml                       # Stage→prompt mapping, artifact conventions, defaults
└── server/
    ├── external_review_server.py     # MCP server implementation
    ├── providers/
    │   ├── __init__.py
    │   ├── base.py                   # Abstract provider interface
    │   ├── openai_compat.py          # OpenAI-compatible (Kimi K2, DeepSeek, Together, etc.)
    │   └── google.py                 # Gemini (non-OpenAI API)
    └── requirements.txt

~/.claude/
└── models.yaml                       # API keys — user-specific, NEVER in git
```

---

## Configuration Files

### models.yaml (User-specific, ~/.claude/models.yaml)

```yaml
# API credentials for external review models
# This file contains secrets — NEVER commit to git

models:
  kimi-k2:
    provider: openai_compat
    endpoint: https://api.moonshot.cn/v1
    model: kimi-k2-0905
    api_key_env: MOONSHOT_API_KEY      # Or inline: api_key: "sk-..."
    
  gemini:
    provider: google
    endpoint: https://generativelanguage.googleapis.com/v1beta
    model: gemini-2.0-flash
    api_key_env: GOOGLE_API_KEY
    
  deepseek:
    provider: openai_compat
    endpoint: https://api.deepseek.com/v1
    model: deepseek-chat
    api_key_env: DEEPSEEK_API_KEY

# Optional: model-specific settings
settings:
  kimi-k2:
    temperature: 0.6
    min_p: 0.01
  gemini:
    temperature: 0.7
  deepseek:
    temperature: 0.7
```

### config.yaml (Skill defaults, acm/skills/external-review/config.yaml)

```yaml
# External Review Skill Configuration
# Versioned with skill — safe to commit

version: "1.0.0"
implements: "ACM-REVIEW-SPEC v1.2.0"

# Stage → prompt mapping (relative to acm/)
prompts:
  discover: "../prompts/external-review-prompt.md"
  design: "../prompts/design-external-review-prompt.md"
  develop: "../prompts/develop-external-review-prompt.md"

# Stage → default artifact path (relative to project root)
artifacts:
  discover: "docs/discover-brief.md"
  design: "docs/design.md"
  develop: "docs/design.md"

# Default models if --models not specified
default_models:
  - kimi-k2
  - gemini

# Cycle rules (embedded from ACM-REVIEW-SPEC v1.2.0)
cycles:
  min: 1                            # Per reviewer, per ACM-REVIEW-SPEC v1.2.0
  max: 10
  structural_problem_signal: 4    # If past N cycles and still finding Critical
  stuck_signal: 3                 # If same issue persists for N iterations

# Execution settings
execution:
  parallel: true                  # Call models in parallel
  timeout_seconds: 120            # Per-model timeout
  retry_attempts: 2               # Retry on transient failure
  # Retry policy: exponential backoff with jitter for 429/5xx/timeouts only.
  # Never retry non-transient failures (4xx other than 429).
  # Max total retry time per model: 60s. Retries are per-model, not global.
```

---

## MCP Server Specification

### Tools

#### `list_models`

Returns available models from `models.yaml`.

**Parameters:** None

**Response:**
```json
{
  "models": [
    {
      "id": "kimi-k2",
      "provider": "openai_compat",
      "model": "kimi-k2-0905",
      "available": true
    },
    {
      "id": "gemini",
      "provider": "google", 
      "model": "gemini-2.0-flash",
      "available": true
    }
  ]
}
```

#### `review`

Sends artifact + prompt to specified models in parallel, returns aggregated responses. The server reads artifact content from disk to avoid doubling context usage in the orchestrator.

**Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `models` | string[] | Yes | Model IDs from models.yaml |
| `artifact_path` | string | Yes | Absolute path to artifact file — server reads content from disk |
| `prompt` | string | Yes | Review prompt with instructions |
| `timeout` | number | No | Override default timeout (seconds) |

**Response:**
```json
{
  "reviews": [
    {
      "model": "kimi-k2",
      "status": "success",
      "response": "## Review Feedback\n\n### Critical Issues\n...",
      "tokens_used": { "input": 2341, "output": 892 },
      "latency_ms": 4521,
      "timestamp": "2026-01-31T14:23:45Z"
    },
    {
      "model": "gemini",
      "status": "success",
      "response": "## Review Feedback\n\n### Critical Issues\n...",
      "tokens_used": { "input": 2341, "output": 756 },
      "latency_ms": 3892,
      "timestamp": "2026-01-31T14:23:44Z"
    }
  ],
  "models_called": ["kimi-k2", "gemini"],
  "parallel": true,
  "total_latency_ms": 4521
}
```

`tokens_used` per model is taken directly from the LLM provider API response. `total_latency_ms` is wall-clock time from first request to last response (parallel execution).

**Partial Failure Response (mixed success/error):**
```json
{
  "reviews": [
    {
      "model": "kimi-k2",
      "status": "error",
      "error": "API rate limit exceeded",
      "retries_attempted": 2,
      "tokens_used": null,
      "latency_ms": 5200
    },
    {
      "model": "gemini",
      "status": "success",
      "response": "## Review Feedback\n\n...",
      "tokens_used": { "input": 2341, "output": 756 },
      "latency_ms": 3892,
      "timestamp": "2026-01-31T14:23:44Z"
    }
  ],
  "models_called": ["kimi-k2", "gemini"],
  "parallel": true,
  "total_latency_ms": 5200
}
```

### Provider Interface

```python
# base.py
from abc import ABC, abstractmethod
from dataclasses import dataclass

@dataclass
class ReviewResponse:
    status: str                    # "success" | "error"
    response: str | None           # Model response text
    error: str | None              # Error message if failed
    tokens_used: dict | None       # {"input": N, "output": N}
    latency_ms: int

class BaseProvider(ABC):
    """Abstract base class for LLM providers."""
    
    @abstractmethod
    async def review(
        self,
        artifact_content: str,
        prompt: str,
        model: str,
        settings: dict,
        extra_params: dict | None = None
    ) -> ReviewResponse:
        """Send review request to provider.

        extra_params: provider-specific settings from models.yaml settings block
        (e.g., min_p, top_k) — merged into API call parameters.
        """
        pass
    
    @abstractmethod
    async def health_check(self) -> bool:
        """Verify API connectivity."""
        pass
```

---

## User Experience

### Invocation

```bash
# Use defaults (models from config, auto-detect stage/artifact)
/external-review

# Specify models
/external-review --models kimi-k2,gemini

# Override stage detection
/external-review --stage design

# Override artifact path
/external-review --artifact docs/custom-brief.md

# Full override
/external-review --stage design --artifact docs/design-brief.md --models kimi-k2,gemini,deepseek
```

### Confirmation Flow

```
> /external-review

External Review Configuration
─────────────────────────────
Stage:     Design
Artifact:  docs/design-brief.md
Prompt:    acm/prompts/design-external-review-prompt.md
Models:    kimi-k2, gemini (parallel)
Cycles:    min 1 per reviewer, max 10

Proceed? (y/n): y

Starting external review cycle 1/10...
  → Calling kimi-k2... done (4.2s)
  → Calling gemini... done (3.8s)

Synthesizing feedback from 2 models...

Issues found:
  • [Critical/Medium] Missing error handling for API timeout — auto-fixing
  • [High/Low] Success criteria not measurable — auto-fixing  
  • [High/High] Unclear data model for user sessions — flagging for user

Auto-fixed 2 issues. 1 issue requires your input.

───────────────────────────────────────────────────────────
Flagged Issue: Unclear data model for user sessions
Severity: High | Complexity: High

Multiple reviewers flagged this:
  • kimi-k2: "Session state structure undefined, could cause inconsistency"
  • gemini: "No schema for session data, blocking for implementation"

This needs investigation. Options:
  1. Define session schema in design-brief.md
  2. Defer to implementation with explicit spike task
  3. Mark as out-of-scope with rationale

Your decision: 
```

### Cycle Progression

After user resolves flagged issues, cycle continues:

```
Continuing external review cycle 2/10...
  → Calling kimi-k2... done (3.9s)
  → Calling gemini... done (4.1s)

Synthesizing feedback from 2 models...

Issues found:
  • [Low/N/A] Consider adding sequence diagram — logged only

No Critical or High issues found. Minimum cycles met.

External review complete.
  Cycles: 2
  Issues resolved: 3 (2 auto-fixed, 1 user-resolved)
  Issues logged: 1 (Low severity)

Updating artifact status to 'external-review-complete'...
Done.
```

---

## Integration with ACM MCP Server

The external review skill is a **consumer** of the ACM MCP server. Before executing a review cycle, it retrieves the correct prompt via:

```
acm-server.get_review_prompt(stage: "design", phase: "external")
```

This ensures prompts are always current without hardcoding file paths in the skill. The `config.yaml` stage→prompt mapping serves as a fallback if the ACM MCP server is unavailable (direct file read).

**Prompt resolution order:**
1. ACM MCP server `get_review_prompt()` (preferred)
2. `config.yaml` relative path mapping (fallback)

## Integration with Ralph Loop

The skill invokes Ralph Loop with the resolved external review prompt. The prompt instructs Claude Code to:

1. Call the MCP `review` tool with configured models
2. Process aggregated responses
3. Apply ACM-REVIEW-SPEC rules (severity, complexity, action matrix)
4. Update artifact
5. Check stop conditions

**Ralph Loop invocation pattern:**

```bash
/ralph-loop:ralph-loop "$(cat ~/code/_shared/acm/prompts/{stage}-external-review-prompt.md)" \
  --max-iterations 10 \
  --completion-promise "EXTERNAL_REVIEW_COMPLETE"
```

The SKILL.md assembles context before invocation:
- Stage detection (from project status.md or --stage override)
- Prompt retrieval (via ACM MCP server or config fallback)
- Model resolution (from --models override or config defaults)
- Confirmation display

---

## Cycle Rules (from ACM-REVIEW-SPEC v1.2.0)

### Minimum Cycles
- **Phase 2 (External):** Minimum 1 cycle per reviewer (if Phase 2 is conducted). Per ACM-REVIEW-SPEC v1.2.0.

### Stop Conditions
After each cycle:
> "Did this cycle surface any Critical or High severity issues?"

- **If yes:** Fix issues (or flag High complexity to user), run another cycle
- **If no (and minimum met):** Review phase complete

### Maximum Cycles
- **Hard maximum:** 10 cycles
- **Structural problem signal:** If past 4 cycles and still finding Critical issues, stop and flag
- **Stuck signal:** If same issue persists for 3+ iterations, stop and flag

---

## Severity & Complexity Definitions (from ACM-REVIEW-SPEC v1.2.0)

### Severity

| Severity | Definition | Action |
|----------|------------|--------|
| **Critical** | Must resolve. Blocks next stage or fundamentally flawed. | Fix before proceeding |
| **High** | Should resolve. Significant gap or weakness. | Fix before proceeding |
| **Low** | Minor. Polish, cosmetic, or implementation detail. | Log only |

### Complexity

| Complexity | Definition | Examples |
|------------|------------|----------|
| **Low** | Direct edit, no research, clear fix | Fix typo, add missing field |
| **Medium** | Design thinking, small refactor, clear path | Restructure section, add table |
| **High** | Needs research, investigation, architectural rethinking | Evaluate alternatives, resolve conflicts |

### Action Matrix

| Severity | Complexity | Action |
|----------|------------|--------|
| Critical | Low | Auto-fix |
| Critical | Medium | Auto-fix |
| Critical | High | **Flag for user** |
| High | Low | Auto-fix |
| High | Medium | Auto-fix |
| High | High | **Flag for user** |
| Low | Any | Log only |

---

## Cross-Reviewer Synthesis

When processing responses from multiple models:

1. **Extract issues** from each model's response
2. **Deduplicate** — same issue flagged by multiple models counts once
3. **Consensus weight** — issues flagged by multiple models are higher confidence
4. **Classify severity** — apply definitions, not model's assessment
5. **Classify complexity** — based on fix effort, not model's opinion
6. **Apply action matrix** — auto-fix or flag based on classification

### Consensus Rules

| Flagged By | Treatment |
|------------|-----------|
| All models | High confidence — likely real issue |
| Majority of models | Medium confidence — investigate |
| Single model | Lower confidence — verify before acting |

Single-model issues that aren't clearly blocking may be logged rather than acted on.

---

## Artifact Updates

After each cycle, update:

### Issue Log

| # | Issue | Source | Severity | Complexity | Status | Resolution |
|---|-------|--------|----------|------------|--------|------------|
| N | [description] | External-Kimi-K2, External-Gemini | Critical | Medium | Resolved | [what was done] |

### Review Log

```markdown
### Phase 2: External Review

**Date:** 2026-01-31
**Mechanism/Reviewers:** External-Kimi-K2, External-Gemini (parallel, 2 cycles)
**Issues Found:** 1 Critical, 2 High, 1 Low
**Complexity Assessment:** 1 Low, 2 Medium, 1 High
**Actions Taken:**
- **Auto-fixed (2 issues):**
  - Missing error handling (Critical/Medium) — Added timeout handling section
  - Non-measurable success criteria (High/Low) — Rewrote with specific metrics
- **Flagged for user (1 issue):**
  - Unclear session data model (High/High) — User chose to define schema
- **Logged only (1 issue):**
  - Consider sequence diagram (Low/N/A) — Deferred to implementation

**Cross-Reviewer Consensus:**
- Session data model flagged by both reviewers (high confidence)
- Error handling flagged by kimi-k2 only but clearly blocking

**Outcome:** Phase 2 complete, design approved for Develop
```

---

## Installation & Setup

### Prerequisites

- Claude Code with MCP support
- Ralph Loop plugin installed
- Python 3.11+
- API keys for desired models

### Step 1: Install Skill

```bash
# Clone/copy skill to ACM
cp -r external-review ~/code/_shared/acm/skills/

# Install Python dependencies
cd ~/code/_shared/acm/skills/external-review/server
pip install -r requirements.txt
```

### Step 2: Configure API Keys

Create `~/.claude/models.yaml`:

```yaml
models:
  kimi-k2:
    provider: openai_compat
    endpoint: https://api.moonshot.cn/v1
    model: kimi-k2-0905
    api_key: "your-moonshot-api-key"
    
  gemini:
    provider: google
    endpoint: https://generativelanguage.googleapis.com/v1beta
    model: gemini-2.0-flash
    api_key: "your-google-api-key"
```

Or use environment variables:

```bash
export MOONSHOT_API_KEY="your-key"
export GOOGLE_API_KEY="your-key"
```

And reference in models.yaml:

```yaml
models:
  kimi-k2:
    api_key_env: MOONSHOT_API_KEY
```

### Step 3: Register MCP Server

Add to Claude Code MCP configuration:

```json
{
  "mcpServers": {
    "external-review": {
      "command": "python",
      "args": ["~/code/_shared/acm/skills/external-review/server/external_review_server.py"],
      "env": {}
    }
  }
}
```

### Step 4: Verify Installation

```bash
# In Claude Code
/external-review --help

# Should show available models
> MCP: list_models()
```

---

## Capability Registry Entry

```yaml
# capabilities-registry/capabilities/skills/external-review/capability.yaml

name: external-review
type: skill
description: >-
  MCP-based external review automation — calls external LLMs (Kimi K2, Gemini, DeepSeek)
  for Phase 2 review within Ralph Loop cycles. Claude Code synthesizes feedback and
  applies ACM-REVIEW-SPEC rules.
source: internal
upstream: ""
version: "1.0.0"
quality: 100
tags: [review, acm, mcp, validation, multi-model, external]
status: staging
install_level: user
added: "2026-01-31"
updated: "2026-01-31"
```

---

## Model Recommendations

| Model | Provider | Input Cost | Output Cost | Notes |
|-------|----------|------------|-------------|-------|
| **Kimi K2** | Moonshot | $0.60/M | $2.50/M | Strong reasoning, auto-caching to $0.15/M, OpenAI-compatible |
| **Gemini 2.0 Flash** | Google | $0.32/M | $2.63/M | Fast, different perspective |
| **DeepSeek V3** | DeepSeek | $0.28/M | $1.14/M | Excellent value, good reasoning |

**Default pair:** Kimi K2 + Gemini (different training data = diverse perspectives)

**Estimated cost per external review phase:** $0.02–$0.10 depending on artifact size and cycles.

---

## Security Considerations

| Concern | Mitigation |
|---------|------------|
| API keys in config | `models.yaml` at `~/.claude/`, gitignored, user-specific |
| Artifact content sent to external APIs | User confirms before execution; same trust model as manual review |
| API key exposure in logs | Server strips keys from error messages |
| Rate limiting | Configurable retry with backoff; graceful degradation |

---

## Future Enhancements

- [ ] Support for aggregator providers (OpenRouter, Together AI)
- [ ] Cost tracking and budget limits
- [ ] Response caching for identical artifact+prompt combinations
- [ ] Webhook notifications on completion
- [ ] Integration with CI/CD for automated review gates

---

## References

- ACM-REVIEW-SPEC.md (Phase 2 mechanism, severity definitions, cycle rules)
- ACM-STAGES-SPEC.md (Stage definitions, phase transitions)
- REGISTRY-SPEC.md (Capability registration)

---

## Issue Log

| # | Issue | Source | Severity | Complexity | Status | Resolution |
|---|-------|--------|----------|------------|--------|------------|
| 1 | Frontmatter says "specification" with wrong location path | Ralph-Design | Critical | Low | Resolved | Updated to type: "design", correct location, added brief_ref and backlog_ref |
| 2 | Default artifact paths in config.yaml don't match ACM conventions | Ralph-Design | Critical | Low | Resolved | Fixed to discover-brief.md, design.md |
| 3 | Missing Issue Log and Review Log sections | Ralph-Design | Critical | Low | Resolved | Added both sections |
| 4 | Phase 2 minimum cycles says 2 but ACM-REVIEW-SPEC says 1 per reviewer | Ralph-Design | High | Low | Resolved | Fixed to match ACM-REVIEW-SPEC v1.2.0 |
| 5 | No consumer relationship with ACM MCP server documented | Ralph-Design | High | Medium | Resolved | Added Integration with ACM MCP Server section, prompt resolution order |
| 6 | Separate moonshot.py provider unnecessary — Kimi K2 is OpenAI-compatible | Ralph-Design | High | Low | Resolved | Collapsed into openai_compat.py, removed moonshot.py |
| 7 | assembled-prompt.md referenced but not defined in Skill Structure | Ralph-Design | Low | N/A | Open | — |
| 8 | Capability registry entry has install_level: user but skill lives in ACM repo | Ralph-Design | Low | N/A | Open | — |
| 9 | UX example still showed "min 2" after cycle rules fix | Ralph-Design | Low | N/A | Resolved | Fixed confirmation flow and cycle progression examples |
| 10 | Phase 1 review complete | Ralph-Design | - | - | Complete | 2 cycles: 3 Critical, 3 High resolved |
| 11 | Provider ID "moonshot" doesn't map to implementation after moonshot.py removal | External-GPT | Critical | Low | Resolved | Changed provider to openai_compat in models.yaml examples |
| 12 | artifact_content as string doubles context usage, risks payload limits | External-Gemini, External-GPT | High | Medium | Resolved | Changed to artifact_path — server reads file from disk |
| 13 | Provider-specific params (min_p, etc.) have no pass-through mechanism | External-Gemini | High | Low | Resolved | Added extra_params to BaseProvider.review interface |
| 14 | Retry policy underspecified — no backoff, no retriable error definition | External-GPT | High | Low | Resolved | Added retry policy to execution settings |
| 15 | Hardcoded ~/.claude/ config path brittle in containers | External-Gemini | Low | N/A | Open | MVP personal-scale — env var override deferred |
| 16 | Secret redaction only covers error messages, not logs/traces | External-GPT | Low | N/A | Open | Implementation detail, not design-blocking |
| 17 | Phase 2 review complete | External-Gemini, External-GPT | - | - | Complete | 1 cycle: 1 Critical, 3 High resolved |
| 18 | tokens_used output calculation unspecified — unclear how per-model token counts are derived | External-Gemini | High | Low | Resolved | Added clarification that tokens_used comes directly from LLM API response |
| 19 | Error response doesn't show mixed success/error across models | External-Gemini | High | Low | Resolved | Replaced error example with partial failure response showing mixed statuses |
| 20 | requirements.txt contents not specified | External-Gemini | Low | N/A | Open | Implementation detail — dependencies determined during Develop |
| 21 | extra_params merge behavior with provider settings unspecified | External-Gemini | Low | N/A | Open | Implementation detail — merge strategy determined during Develop |

---

## Review Log

### Phase 1: Internal Review

**Date:** 2026-01-31
**Mechanism:** Ralph Loop (cycle 1 of 10)
**Issues Found:** 3 Critical, 3 High, 2 Low
**Complexity Assessment:** 4 Low, 1 Medium (for Critical/High issues)
**Actions Taken:**
- **Auto-fixed (6 issues):**
  - Frontmatter type/location wrong (Critical/Low) — Updated to design type
  - Artifact paths don't match ACM conventions (Critical/Low) — Fixed paths
  - Missing Issue Log and Review Log (Critical/Low) — Added sections
  - Phase 2 min cycles contradicts ACM-REVIEW-SPEC (High/Low) — Fixed to 1 per reviewer
  - No ACM MCP server consumer relationship (High/Medium) — Added integration section
  - Unnecessary moonshot.py provider (High/Low) — Collapsed into openai_compat
- **Logged only (2 issues):**
  - assembled-prompt.md not defined (Low/N/A)
  - Registry install_level mismatch (Low/N/A)

**Outcome:** Cycle 1 complete — 3 Critical + 3 High resolved. Proceeding to cycle 2.

**Cycle 2:**
**Issues Found:** 0 Critical, 0 High, 1 Low
**Actions Taken:**
- **Auto-fixed (1 issue):**
  - UX example showed stale "min 2" cycle count (Low/N/A) — Fixed both examples
- **Logged only:** None

**Outcome:** Phase 1 complete — 2 cycles, zero Critical/High in final cycle. Design ready for Phase 2 external review.

### Phase 2: External Review

**Date:** 2026-01-31
**Mechanism/Reviewers:** External-Gemini, External-GPT (parallel, 1 cycle)
**Issues Found:** 1 Critical, 3 High, 2 Low
**Complexity Assessment:** 2 Low, 1 Medium (for Critical/High issues)
**Actions Taken:**
- **Auto-fixed (4 issues):**
  - Provider ID "moonshot" unmapped after moonshot.py removal (Critical/Low) — Changed to openai_compat
  - artifact_content doubles context (High/Medium) — Changed to artifact_path, server reads from disk
  - Provider-specific params no pass-through (High/Low) — Added extra_params to BaseProvider
  - Retry policy underspecified (High/Low) — Added backoff/jitter policy for 429/5xx/timeouts
- **Logged only (2 issues):**
  - Hardcoded config path (Low/N/A) — MVP personal-scale, deferred
  - Incomplete secret redaction (Low/N/A) — Implementation detail

**Cross-Reviewer Consensus:**
- artifact_content/oversized artifact issue flagged by both reviewers (high confidence)
- Provider ID mapping flagged by GPT only but clearly blocking (auto-fix)
- Config path and redaction flagged by single reviewers, not blocking (Low)

**Outcome:** Phase 2 complete — 1 cycle, 1 Critical + 3 High resolved. Design approved for Develop.

### Phase 2b: External Review (Gemini re-review)

**Date:** 2026-02-01
**Mechanism/Reviewers:** External-Gemini (1 cycle)
**Issues Found:** 0 Critical, 2 High, 2 Low
**Complexity Assessment:** 2 Low (for High issues)
**Actions Taken:**
- **Auto-fixed (2 issues):**
  - tokens_used output calculation unspecified (High/Low) — Added clarification that values come from LLM API
  - Error response doesn't show mixed success/error (High/Low) — Replaced with partial failure response example
- **Logged only (2 issues):**
  - requirements.txt contents not specified (Low/N/A) — Implementation detail
  - extra_params merge behavior unspecified (Low/N/A) — Implementation detail
- **Discarded (1 issue):**
  - Claimed artifact_path redundant in response — false positive (artifact_path not in response JSON)

**Cross-Reviewer Consensus:** N/A (single model)

**Cost:** $0.0015 | Tokens: 8,196 in / 1,587 out

**Outcome:** Phase 2b complete — 0 Critical, 0 High remaining after fixes. Design validated.

---

## Revision History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2026-01-31 | Initial spec — architecture, MCP tools, UX flow, configuration |
| 1.1.0 | 2026-01-31 | Design review cycle 1: Fixed frontmatter, artifact paths, Phase 2 min cycles. Added ACM MCP server integration, Issue Log, Review Log. Collapsed moonshot provider into openai_compat. |
| 1.2.0 | 2026-01-31 | Design review cycle 2: Fixed stale UX examples. Phase 1 internal review complete — 2 cycles, 3 Critical + 3 High resolved. |
| 1.3.0 | 2026-01-31 | Phase 2 external review (Gemini + GPT): Fixed provider ID mapping, changed artifact_content to artifact_path, added extra_params pass-through, defined retry policy. Design complete. |
| 1.4.0 | 2026-02-01 | Phase 2b external review (Gemini): Clarified tokens_used sourcing, replaced error response with partial failure example showing mixed statuses. |
