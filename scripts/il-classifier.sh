#!/bin/bash

set -uo pipefail

STALE_LOCK_SECONDS=1800
COMMIT_MESSAGE="chore(il): classify and route hot buffer entries"
ROOTS=(
  "$HOME/code/_shared"
  "$HOME/code/tools"
  "$HOME/code/clients"
)

# F2 (2026-07-10): entry collection/matching/marking/GC moved to il-entries.py
# and the deterministic store-write pass moved to il-router.py, both alongside
# this script. Both are pure-stdlib and take no dependency on this repo beyond
# stdlib python3. See their module docstrings for the full design. This file
# stays the orchestrator: lock, branch guard, git plumbing, and the PASS-1
# classification prompt/call are unchanged in spirit from the pre-F2 script.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENTRIES_PY="${SCRIPT_DIR}/il-entries.py"
ROUTER_PY="${SCRIPT_DIR}/il-router.py"
PYTHON_BIN="python3"
SIDECAR_FILE=".il-receipts"

log() {
  printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*" >&2
}

usage() {
  cat >&2 <<'EOF'
Usage: il-classifier.sh [--sweep] [--dry-run] [project_dir]
EOF
}

cleanup_lock() {
  if [[ -n "${CURRENT_LOCK:-}" && -f "${CURRENT_LOCK}" ]]; then
    rm -f "${CURRENT_LOCK}"
  fi
}

trap cleanup_lock EXIT

md5_hash() {
  # macOS md5 is at /sbin/md5 — not in default launchd PATH
  local md5_bin
  if command -v md5 >/dev/null 2>&1; then
    md5_bin="md5"
  elif [ -x "/sbin/md5" ]; then
    md5_bin="/sbin/md5"
  elif command -v md5sum >/dev/null 2>&1; then
    printf '%s' "$1" | md5sum | awk '{print $1}'
    return 0
  else
    log "md5 command not found"
    return 1
  fi

  "$md5_bin" -qs "$1"
}

acquire_lock() {
  local project_dir="$1"
  local project_hash lock_path now mtime

  if ! project_hash="$(md5_hash "$project_dir")"; then
    return 1
  fi
  lock_path="/tmp/il-classifier-${project_hash}.lock"
  now="$(date +%s)"

  if [[ -f "$lock_path" ]]; then
    mtime="$(stat -f '%m' "$lock_path" 2>/dev/null || printf '0')"
    if [[ $((now - mtime)) -gt $STALE_LOCK_SECONDS ]]; then
      log "Removing stale lock: $lock_path"
      rm -f "$lock_path"
    else
      log "Project locked, skipping: $project_dir"
      return 1
    fi
  fi

  if ( set -o noclobber; printf '%s %s\n' "$$" "$now" > "$lock_path" ) 2>/dev/null; then
    CURRENT_LOCK="$lock_path"
    return 0
  fi

  log "Unable to acquire lock, skipping: $project_dir"
  return 1
}

release_lock() {
  if [[ -n "${CURRENT_LOCK:-}" ]]; then
    rm -f "$CURRENT_LOCK"
    CURRENT_LOCK=""
  fi
}

discover_projects() {
  local root

  # Exclude: templates, references, drafts, node_modules, .venv, .ctx, archive dirs
  for root in "${ROOTS[@]}"; do
    [[ -d "$root" ]] || continue
    find "$root" -type f \( -name 'captures.md' -o -name 'lessons.md' -o -name 'decisions.md' \) \
      -not -path '*/templates/*' \
      -not -path '*/references/*' \
      -not -path '*/drafts/*' \
      -not -path '*/node_modules/*' \
      -not -path '*/.venv/*' \
      -not -path '*/.ctx/*' \
      -not -path '*/_archive/*' \
      -not -path '*/archive/*' \
      -print 2>/dev/null
  done | while IFS= read -r path; do
    dirname "$path"
  done | sort -u
}

render_candidates_for_prompt() {
  local candidates_json="$1"
  local source_file="$2"
  local out

  out="$(jq -r --arg src "$source_file" '.candidates[] | select(.source_file == $src) | "- " + .flat' "$candidates_json")"
  if [[ -z "$out" ]]; then
    printf '(none)\n'
  else
    printf '%s\n' "$out"
  fi
}

# decisions.md collection RESUMES here (F2, 2026-07-10) after the 9cbb5f3
# interim pause. What made the pause necessary — collection with no memory of
# what was already routed, causing infinite re-promotion — is now closed by
# the `.il-receipts` sidecar (il-entries.py: collect skips any decisions.md
# entry whose content-hash has a terminal sidecar row; finalize/apply write
# the sidecar, never the file). decisions.md itself is still never opened for
# writing anywhere in this pipeline — see the note in commit_hot_buffers.
build_prompt_from_candidates() {
  local project_name="$1"
  local candidates_json="$2"
  local captures_content lessons_content decisions_content

  captures_content="$(render_candidates_for_prompt "$candidates_json" "captures.md")"
  lessons_content="$(render_candidates_for_prompt "$candidates_json" "lessons.md")"
  decisions_content="$(render_candidates_for_prompt "$candidates_json" "decisions.md")"

  cat <<EOF
You are a knowledge classifier for the Agentic Work System. Your job is to route entries from session hot buffers to the correct permanent store.

## Stores

**Knowledge Base (KB)** — via send_to_kb tool
- Patterns, learnings, reference content, debugging insights
- Structured knowledge that benefits from semantic search
- Cross-project value: "Would another project's agent benefit from knowing this?"

**Memory** — via write_memory tool
- Atomic facts, decisions, preferences
- Operational context: hostnames, ports, tool behaviors
- Cross-project or cross-session facts

## Routing Rules

For each entry, decide:
1. Cross-project learning, pattern, or reference → KB (send_to_kb with type "learning", domain inferred from content)
2. Fact, preference, or decision about how we work → Memory (write_memory with namespace "global", type inferred: "decision", "observation", or "preference")
3. Project-specific only (convention, local config) → KEEP (stays in hot buffer)
4. Low-signal noise (typo fixes, trivial observations) → DISCARD

## Instructions

Classify each entry below. Do NOT call any tools — just output a JSON array with your classification.
For KB entries, include kb_type and domain. For Memory entries, include memory_type and namespace.

## Quality Rules
- Default to KEEP when uncertain — false negatives (missed routes) are better than false positives (wrong store)
- A debugging insight that saved time = KB (learning)
- "This repo uses X" = KEEP (project-specific)
- "Tool X behaves Y way" = KB if cross-project, Memory if it's a single fact
- Decisions with rationale from decisions.md = Memory (type: decision)
- Do NOT expand, summarize, or modify entry content — route the original text

## Entries to Classify

### From captures.md (${project_name}):
${captures_content}

### From lessons.md (${project_name}):
${lessons_content}

### From decisions.md (${project_name}):
${decisions_content}

## Output Format

Return ONLY a JSON array:
[
  {"entry": "original entry text", "source_file": "captures.md", "action": "kb", "kb_type": "learning", "domain": "mcp"},
  {"entry": "original entry text", "source_file": "decisions.md", "action": "memory", "memory_type": "decision", "namespace": "global"},
  {"entry": "original entry text", "source_file": "captures.md", "action": "keep", "reason": "project-specific"},
  {"entry": "original entry text", "source_file": "lessons.md", "action": "discard", "reason": "low-signal"}
]
EOF
}

extract_json_array() {
  # Extract a JSON array from claude -p --output-format json output.
  # Handles: direct array, wrapped in {"result":"..."}, markdown code fences.
  local raw_file="$1"
  local out_file="$2"
  local extract_script="${out_file}.py"

  # Case 1: Direct JSON array
  if jq -e 'type == "array"' "$raw_file" >/dev/null 2>&1; then
    cp "$raw_file" "$out_file"
    return 0
  fi

  # Case 2: Wrapped in {"result": "...text..."}
  if ! jq -e '.result' "$raw_file" >/dev/null 2>&1; then
    return 1
  fi

  # Use Python to robustly extract JSON array from text (avoids bash backtick issues)
  cat > "$extract_script" << 'PYEOF'
import sys, json, re
text = sys.stdin.read()
text = re.sub(r'```json?\s*\n?', '', text)
text = re.sub(r'\n?```\s*$', '', text, flags=re.MULTILINE)
depth = 0
start = -1
for i, c in enumerate(text):
    if c == '[' and start == -1:
        start = i
        depth = 1
    elif c == '[' and start >= 0:
        depth += 1
    elif c == ']' and start >= 0:
        depth -= 1
        if depth == 0:
            candidate = text[start:i+1]
            try:
                arr = json.loads(candidate)
                if isinstance(arr, list):
                    json.dump(arr, sys.stdout)
                    sys.exit(0)
            except json.JSONDecodeError:
                start = -1
sys.exit(1)
PYEOF

  if jq -r '.result' "$raw_file" | python3 "$extract_script" > "$out_file" 2>/dev/null; then
    rm -f "$extract_script"
    return 0
  fi
  rm -f "$extract_script"
  return 1
}

run_classifier() {
  # PASS 1: Classify entries (JSON manifest only, no MCP tool calls)
  local prompt_file="$1"
  local output_file="$2"

  if [[ "${DRY_RUN}" == "1" ]]; then
    log "Dry run: classifier prompt prepared"
    cat "$prompt_file"
    return 0
  fi

  # Test seam (R7, F2): copy a canned manifest instead of calling claude.
  # Inert unless IL_TEST_MANIFEST is explicitly set — production path below
  # is untouched.
  if [[ -n "${IL_TEST_MANIFEST:-}" ]]; then
    if [[ ! -f "$IL_TEST_MANIFEST" ]]; then
      log "IL_TEST_MANIFEST set but file not found: $IL_TEST_MANIFEST"
      return 1
    fi
    cp "$IL_TEST_MANIFEST" "$output_file"
    log "Test seam: classifier output from IL_TEST_MANIFEST (no claude call)"
    return 0
  fi

  if ! command -v claude >/dev/null 2>&1; then
    log "claude command not found"
    return 1
  fi

  local raw_output="${output_file}.raw"

  # No --allowedTools: classification only, no tool calls
  if ! claude -p \
    --model haiku \
    --output-format json \
    < "$prompt_file" > "$raw_output"; then
    log "claude -p classify failed"
    rm -f "$raw_output"
    return 1
  fi

  if ! extract_json_array "$raw_output" "$output_file"; then
    log "Could not extract JSON array from classifier response"
    log "Raw result preview: $(jq -r '.result // .' "$raw_output" | head -5)"
    rm -f "$raw_output"
    return 1
  fi

  rm -f "$raw_output"
}

validate_manifest() {
  local output_file="$1"

  # Structural validation only — don't require exact entry text matching.
  # Haiku may truncate, skip entries, or slightly rephrase. Unmatched entries
  # simply stay in hot buffers (safe default — picked up next run).

  if ! jq -e 'type == "array" and length > 0' "$output_file" >/dev/null 2>&1; then
    log "Manifest is not a non-empty JSON array"
    return 1
  fi

  if ! jq -e 'all(.[]; has("source_file") and has("action") and has("entry"))' "$output_file" >/dev/null 2>&1; then
    log "Manifest entries missing required fields (source_file, action, entry)"
    return 1
  fi

  if ! jq -e 'all(.[]; .action == "kb" or .action == "memory" or .action == "discard" or .action == "keep")' "$output_file" >/dev/null 2>&1; then
    log "Manifest contained invalid action values"
    return 1
  fi

  return 0
}

# Echo the repo's default branch name, or return 1 if it genuinely cannot be determined.
# stderr is suppressed on the probes below because ABSENCE is an expected, explicitly-handled
# outcome here (no remote / no origin/HEAD symref) -- not a diagnostic path being silenced.
# Repos in this fleet differ: pike-agents uses `master`, most others use `main`. Never hardcode.
resolve_default_branch() {
  local project_dir="$1" ref b

  # A remote can exist WITHOUT origin/HEAD being set (fresh clones, or `set-head` never run),
  # so a failure here does not imply "no remote" -- fall through to the local probe.
  if ref="$(git -C "$project_dir" symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null)"; then
    printf '%s\n' "${ref#origin/}"
    return 0
  fi

  for b in main master; do
    if git -C "$project_dir" show-ref --verify --quiet "refs/heads/${b}"; then
      printf '%s\n' "$b"
      return 0
    fi
  done

  return 1
}

commit_hot_buffers() {
  local project_dir="$1"
  local staged_paths=()
  local path status_output
  local default_branch current_branch

  if [[ ! -d "${project_dir}/.git" ]] && ! git -C "$project_dir" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    log "Not a git repository, skipping commit: $project_dir"
    return 0
  fi

  # --- BRANCH GUARD (2026-07-10, P1 forge-20260709-il-classifier-decisions-corruption)
  # This script is fired by a Claude Code `Stop` hook -- i.e. at the end of EVERY assistant turn,
  # in whatever repo the session happens to be in. With no branch check it committed onto users'
  # feature branches, and worse: a human reverted its damage at 18:36 and it re-applied the same
  # change at 18:39, because the next turn ended. A human cannot win a revert war against a process
  # triggered by their own keystrokes. Refuse to commit anywhere but the default branch, and leave
  # the tree exactly as found. This check MUST stay above `git add` -- a skipped project must have
  # zero git side effects.
  if ! default_branch="$(resolve_default_branch "$project_dir")"; then
    log "SKIP commit: cannot resolve default branch (no origin/HEAD symref, no local main/master), leaving tree untouched: $project_dir"
    return 0
  fi

  current_branch="$(git -C "$project_dir" branch --show-current)"
  if [[ -z "$current_branch" ]]; then
    log "SKIP commit: detached HEAD, leaving tree untouched: $project_dir"
    return 0
  fi

  if [[ "$current_branch" != "$default_branch" ]]; then
    log "SKIP commit: HEAD is on '${current_branch}', not default branch '${default_branch}' — leaving tree untouched: $project_dir"
    return 0
  fi

  if git -C "$project_dir" ls-files -u -- captures.md lessons.md decisions.md | grep -q .; then
    log "Hot buffer files have merge conflicts, skipping commit: $project_dir"
    return 1
  fi

  # decisions.md is deliberately absent below, and always will be: no code path in this
  # pipeline ever opens it for writing (il-entries.py's collect/apply/gc all treat it as
  # read-only; state for its entries lives entirely in the `.il-receipts` sidecar). ANY
  # diff decisions.md carries is by construction someone else's uncommitted work. Staging
  # it here made `git commit --only -- decisions.md` sweep a human's in-flight edits into
  # a machine-authored "chore(il)" commit -- observed as ciso-advisory 052cbd6, which
  # captured that agent's hand-repair of corruption this very script had caused.
  #
  # `.il-receipts` (F2, 2026-07-10) IS staged below, unlike decisions.md -- because unlike
  # decisions.md, this script is the sidecar's only writer. Never stage a file you did not
  # write; the sidecar is the one addition to that rule's file set, not an exception to it.
  status_output="$(git -C "$project_dir" status --porcelain -- captures.md lessons.md "$SIDECAR_FILE")"
  [[ -n "$status_output" ]] || return 0

  for path in captures.md lessons.md "$SIDECAR_FILE"; do
    if [[ -e "${project_dir}/${path}" ]]; then
      staged_paths+=("$path")
    fi
  done

  [[ "${#staged_paths[@]}" -gt 0 ]] || return 0

  git -C "$project_dir" add -- "${staged_paths[@]}"

  if git -C "$project_dir" diff --cached --quiet -- "${staged_paths[@]}"; then
    return 0
  fi

  # Distinct committer identity: machine writes must be greppable in `git log`. Previously these
  # commits were authored as the human, so nothing distinguished them. Per-invocation `-c` flags
  # only -- never mutate the repo's stored git config.
  git -C "$project_dir" -c user.name='il-classifier' -c user.email='il-classifier@localhost' \
    commit --only -m "$COMMIT_MESSAGE" -- "${staged_paths[@]}" >/dev/null 2>&1 || {
    log "Commit failed for project: $project_dir"
    return 1
  }

  log "Committed hot buffer changes: $project_dir"
  return 0
}

# GC (D2): remove only machine-marked [promoted:...]/[discarded:...] entries older than
# 14 days. Unmarked entries are never machine-deleted, regardless of count -- this
# replaces trim_lessons_file's unmarked-trim entirely. Deliberately independent of
# whether THIS sweep found any new/pending candidates: a project whose lessons.md holds
# only aged terminal markers has zero candidates (by design, terminal states are never
# collected) and would never reach GC if it were gated behind "had something to classify".
# IL_TEST_NOW (test-only, inert unless set) lets the harness pin "today" so aged-fixture
# GC assertions are deterministic without sleeping or faking mtimes.
run_gc() {
  local project_dir="$1"
  local tmp_dir="$2"
  local gc_now_args=()

  [[ -n "${IL_TEST_NOW:-}" ]] && gc_now_args=(--now "$IL_TEST_NOW")
  # NOTE: expanding a zero-element array as "${arr[@]}" under `set -u` throws
  # "unbound variable" on macOS's system /bin/bash (3.2 -- GNU bash 4.4+ does
  # not have this quirk, but this script must not assume a newer bash is on
  # PATH). Worse than a cosmetic warning: on 3.2 that error aborts the ENTIRE
  # script, not just this statement -- silently skipping every commit from
  # this point forward on every invocation. "${arr[@]+"${arr[@]}"}" is the
  # portable idiom that expands to nothing (not an error) when arr is empty
  # and to the normal element list otherwise. Verified against this host's
  # actual /bin/bash 3.2.57 before relying on it here.
  "$PYTHON_BIN" "$ENTRIES_PY" gc --project-dir "$project_dir" --files captures.md,lessons.md \
    --max-age-days 14 "${gc_now_args[@]+"${gc_now_args[@]}"}" > "${tmp_dir}/gc-summary.json" 2>"${tmp_dir}/gc.err"
  log "GC ($project_dir): $(cat "${tmp_dir}/gc-summary.json" 2>/dev/null)"
  [[ -s "${tmp_dir}/gc.err" ]] && cat "${tmp_dir}/gc.err" >&2
}

process_project() {
  local project_dir="$1"
  local project_name tmp_dir
  local candidates_json prompt_file output_file matched_json route_input_json route_output_json results_json
  local candidate_count route_count

  if [[ -f "${project_dir}/.il-exclude" ]]; then
    log "Skipping excluded project: $project_dir"
    return 0
  fi

  if ! acquire_lock "$project_dir"; then
    return 0
  fi

  tmp_dir="$(mktemp -d)"
  candidates_json="${tmp_dir}/candidates.json"
  prompt_file="${tmp_dir}/prompt.txt"
  output_file="${tmp_dir}/classifier.json"
  matched_json="${tmp_dir}/matched.json"
  route_input_json="${tmp_dir}/route-input.json"
  route_output_json="${tmp_dir}/route-output.json"
  results_json="${tmp_dir}/results.json"

  if ! "$PYTHON_BIN" "$ENTRIES_PY" collect --project-dir "$project_dir" > "$candidates_json" 2>"${tmp_dir}/collect.err"; then
    log "collect failed for $project_dir: $(tail -5 "${tmp_dir}/collect.err" 2>/dev/null)"
    rm -rf "$tmp_dir"
    release_lock
    return 0
  fi

  candidate_count="$(jq '.candidates | length' "$candidates_json" 2>/dev/null || printf '0')"
  if [[ "$candidate_count" -eq 0 ]]; then
    log "No entries to process: $project_dir"
    run_gc "$project_dir" "$tmp_dir"
    commit_hot_buffers "$project_dir" || true
    rm -rf "$tmp_dir"
    release_lock
    return 0
  fi

  project_name="$(basename "$project_dir")"
  build_prompt_from_candidates "$project_name" "$candidates_json" > "$prompt_file"

  if ! run_classifier "$prompt_file" "$output_file"; then
    "$PYTHON_BIN" "$ENTRIES_PY" finalize --candidates "$candidates_json" --batch-fail > "$results_json"
    "$PYTHON_BIN" "$ENTRIES_PY" apply --project-dir "$project_dir" --candidates "$candidates_json" --results "$results_json" >/dev/null
    run_gc "$project_dir" "$tmp_dir"
    commit_hot_buffers "$project_dir" || true
    rm -rf "$tmp_dir"
    release_lock
    return 0
  fi

  if [[ "${DRY_RUN}" == "1" ]]; then
    rm -rf "$tmp_dir"
    release_lock
    return 0
  fi

  if ! validate_manifest "$output_file"; then
    "$PYTHON_BIN" "$ENTRIES_PY" finalize --candidates "$candidates_json" --batch-fail > "$results_json"
    "$PYTHON_BIN" "$ENTRIES_PY" apply --project-dir "$project_dir" --candidates "$candidates_json" --results "$results_json" >/dev/null
    run_gc "$project_dir" "$tmp_dir"
    commit_hot_buffers "$project_dir" || true
    rm -rf "$tmp_dir"
    release_lock
    return 0
  fi

  if ! "$PYTHON_BIN" "$ENTRIES_PY" match --candidates "$candidates_json" --manifest "$output_file" > "$matched_json" 2>"${tmp_dir}/match.err"; then
    log "match failed for $project_dir: $(tail -5 "${tmp_dir}/match.err" 2>/dev/null) -- leaving hot buffers untouched this sweep"
    run_gc "$project_dir" "$tmp_dir"
    commit_hot_buffers "$project_dir" || true
    rm -rf "$tmp_dir"
    release_lock
    return 0
  fi
  # Unmatched-manifest-entry warnings (haiku returned an entry we couldn't map back to a
  # candidate) are expected/benign and logged by `match` itself -- surface them same as before.
  [[ -s "${tmp_dir}/match.err" ]] && cat "${tmp_dir}/match.err" >&2

  # PASS 2: deterministic routing (il-router.py) — kb/memory actions only.
  # discard/keep never touch a store and are resolved entirely by `finalize`/`apply`.
  jq -c --arg proj "$project_name" \
    '[.matched[] | select(.action == "kb" or .action == "memory") | {
        rid: .cid,
        store: (if .action == "kb" then "kb" else "memory" end),
        content: .text,
        content_type: .kb_type,
        memory_type: .memory_type,
        namespace: .namespace,
        source_project: $proj
      }]' \
    "$matched_json" > "$route_input_json"

  route_count="$(jq 'length' "$route_input_json" 2>/dev/null || printf '0')"
  if [[ "$route_count" -gt 0 ]]; then
    log "Routing ${route_count} entries via il-router.py"
    if ! "$PYTHON_BIN" "$ROUTER_PY" route < "$route_input_json" > "$route_output_json" 2>"${tmp_dir}/route.err"; then
      log "router crashed for $project_dir (all routed entries in this sweep will retry as pending): $(tail -8 "${tmp_dir}/route.err" 2>/dev/null)"
      printf '[]' > "$route_output_json"
    elif [[ -s "${tmp_dir}/route.err" ]]; then
      # Non-fatal per-entry diagnostics (e.g. swallowed KB embed failures) land here.
      cat "${tmp_dir}/route.err" >&2
    fi
  else
    printf '[]' > "$route_output_json"
  fi

  "$PYTHON_BIN" "$ENTRIES_PY" finalize --candidates "$candidates_json" --matched "$matched_json" --router-results "$route_output_json" > "$results_json"

  "$PYTHON_BIN" "$ENTRIES_PY" apply --project-dir "$project_dir" --candidates "$candidates_json" --results "$results_json" > "${tmp_dir}/apply-summary.json"
  log "Applied ($project_dir): $(cat "${tmp_dir}/apply-summary.json")"

  run_gc "$project_dir" "$tmp_dir"
  commit_hot_buffers "$project_dir" || true

  rm -rf "$tmp_dir"
  release_lock
}

main() {
  local sweep_mode=0
  local project_arg="" project_dir

  [[ -n "${CODEX_SANDBOX:-}" ]] && exit 0

  DRY_RUN=0

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --sweep)
        sweep_mode=1
        shift
        ;;
      --dry-run)
        DRY_RUN=1
        shift
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      -*)
        usage
        exit 1
        ;;
      *)
        if [[ -n "$project_arg" ]]; then
          usage
          exit 1
        fi
        project_arg="$1"
        shift
        ;;
    esac
  done

  if [[ "$sweep_mode" -eq 1 ]]; then
    discover_projects | while IFS= read -r project_dir; do
      [[ -n "$project_dir" ]] || continue
      process_project "$project_dir"
    done
    exit 0
  fi

  if [[ -n "$project_arg" ]]; then
    if ! project_dir="$(cd "$project_arg" 2>/dev/null && pwd)"; then
      log "Invalid project directory: $project_arg"
      exit 1
    fi
  else
    project_dir="$(pwd)"
  fi

  process_project "$project_dir"
}

main "$@"
