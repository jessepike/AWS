#!/bin/bash

set -uo pipefail

STALE_LOCK_SECONDS=1800
COMMIT_MESSAGE="chore(il): classify and route hot buffer entries"
ROOTS=(
  "$HOME/code/_shared"
  "$HOME/code/tools"
  "$HOME/code/clients"
)

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

is_pending_line() {
  [[ "$1" =~ ^-\ \[pending(:[0-9]+)?\]\  ]]
}

is_failed_line() {
  [[ "$1" =~ ^-\ \[failed\]\  ]]
}

is_unmarked_line() {
  [[ "$1" =~ ^-\  ]] && ! is_pending_line "$1" && ! is_failed_line "$1"
}

extract_entry_text() {
  local line="$1"

  if [[ "$line" =~ ^-\ \[pending\]\ (.*)$ ]]; then
    printf '%s\n' "${BASH_REMATCH[1]}"
    return 0
  fi

  if [[ "$line" =~ ^-\ \[pending:([0-9]+)\]\ (.*)$ ]]; then
    printf '%s\n' "${BASH_REMATCH[2]}"
    return 0
  fi

  if [[ "$line" =~ ^-\ \[failed\]\ (.*)$ ]]; then
    printf '%s\n' "${BASH_REMATCH[1]}"
    return 0
  fi

  printf '%s\n' "${line#- }"
}

extract_pending_attempts() {
  local line="$1"

  if [[ "$line" =~ ^-\ \[pending:([0-9]+)\]\  ]]; then
    printf '%s\n' "${BASH_REMATCH[1]}"
    return 0
  fi

  if [[ "$line" =~ ^-\ \[pending\]\  ]]; then
    printf '1\n'
    return 0
  fi

  printf '0\n'
}

pending_label() {
  local attempt="$1"

  if [[ "$attempt" -le 1 ]]; then
    printf '[pending]'
  else
    printf '[pending:%s]' "$attempt"
  fi
}

mark_failed_or_pending() {
  local suffix="$1"
  local current_attempt="$2"
  local next_attempt=$((current_attempt + 1))

  if [[ "$next_attempt" -ge 3 ]]; then
    printf -- '- [failed] %s\n' "$suffix"
  else
    printf -- '- %s %s\n' "$(pending_label "$next_attempt")" "$suffix"
  fi
}

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

collect_candidates() {
  local project_dir="$1"
  local candidates_file="$2"
  local snapshot_file="$3"
  local file_path file line source_file entry attempts kind

  : > "$candidates_file"
  : > "$snapshot_file"

  for source_file in captures.md lessons.md decisions.md; do
    file_path="${project_dir}/${source_file}"
    [[ -f "$file_path" ]] || continue

    while IFS= read -r line || [[ -n "$line" ]]; do
      if is_unmarked_line "$line"; then
        entry="$(extract_entry_text "$line")"
        printf '%s\tnew\t0\t%s\t%s\n' "$source_file" "$line" "$entry" >> "$candidates_file"
        printf '%s\t%s\n' "$source_file" "$entry" >> "$snapshot_file"
      elif is_pending_line "$line"; then
        entry="$(extract_entry_text "$line")"
        attempts="$(extract_pending_attempts "$line")"
        printf '%s\tpending\t%s\t%s\t%s\n' "$source_file" "$attempts" "$line" "$entry" >> "$candidates_file"
        printf '%s\t%s\n' "$source_file" "$entry" >> "$snapshot_file"
      fi
    done < "$file_path"
  done
}

render_entries_for_prompt() {
  local snapshot_file="$1"
  local source_file="$2"

  awk -F '\t' -v source="$source_file" '
    $1 == source { print "- " $2; found = 1 }
    END {
      if (!found) {
        print "(none)"
      }
    }
  ' "$snapshot_file"
}

build_prompt() {
  local project_name="$1"
  local snapshot_file="$2"
  local captures_content lessons_content decisions_content

  captures_content="$(render_entries_for_prompt "$snapshot_file" "captures.md")"
  lessons_content="$(render_entries_for_prompt "$snapshot_file" "lessons.md")"
  decisions_content="$(render_entries_for_prompt "$snapshot_file" "decisions.md")"

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

route_entries() {
  # PASS 2: Route classified entries to KB/Memory via MCP tool calls
  local output_file="$1"
  local kb_count memory_count

  kb_count="$(jq '[.[] | select(.action == "kb")] | length' "$output_file")"
  memory_count="$(jq '[.[] | select(.action == "memory")] | length' "$output_file")"

  if [[ "$((kb_count + memory_count))" -eq 0 ]]; then
    log "No entries to route (all keep/discard)"
    return 0
  fi

  log "Routing ${kb_count} to KB, ${memory_count} to Memory"

  # Build routing prompt with explicit tool call instructions
  local route_prompt="${output_file}.route-prompt"
  local route_raw="${output_file}.route-raw"

  python3 - "$output_file" > "$route_prompt" << 'PYEOF'
import sys, json

with open(sys.argv[1]) as f:
    entries = json.load(f)

print("You MUST call the tools below. Do NOT skip any. Do NOT just describe them — actually call them.\n")

idx = 0
for e in entries:
    if e["action"] == "kb":
        idx += 1
        content = e["entry"]
        kb_type = e.get("kb_type", "learning")
        domain = e.get("domain", "general")
        print(f"CALL {idx}: Use send_to_kb tool with:")
        print(f'  content: "{content}"')
        print(f'  content_type: "{kb_type}"')
        print(f'  domain: "{domain}"')
        print(f'  source_type: "session_capture"')
        print()
    elif e["action"] == "memory":
        idx += 1
        content = e["entry"]
        mem_type = e.get("memory_type", "observation")
        namespace = e.get("namespace", "global")
        print(f"CALL {idx}: Use write_memory tool with:")
        print(f'  content: "{content}"')
        print(f'  memory_type: "{mem_type}"')
        print(f'  namespace: "{namespace}"')
        print(f'  writer_id: "il-classifier"')
        print(f'  writer_type: "automation"')
        print()

print(f"\nYou must make exactly {idx} tool calls. After all calls, say 'ROUTING COMPLETE'.")
PYEOF

  if ! claude -p \
    --model haiku \
    --output-format json \
    --allowedTools "mcp__knowledge-base__send_to_kb,mcp__memory__write_memory" \
    < "$route_prompt" > "$route_raw" 2>/dev/null; then
    log "Routing pass failed"
    rm -f "$route_prompt" "$route_raw"
    return 1
  fi

  local num_turns
  num_turns="$(jq -r '.num_turns // 0' "$route_raw" 2>/dev/null)"
  log "Routing complete: ${num_turns} turns (expected ~$((kb_count + memory_count)) tool calls)"

  rm -f "$route_prompt" "$route_raw"
  return 0
}

validate_manifest() {
  local candidates_file="$1"
  local output_file="$2"

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

build_failure_replacements() {
  local candidates_file="$1"
  local replace_file="$2"
  local source kind attempts original entry suffix replacement

  : > "$replace_file"

  while IFS=$'\t' read -r source kind attempts original entry; do
    suffix="$(extract_entry_text "$original")"
    replacement="$(mark_failed_or_pending "$suffix" "$attempts")"
    printf '%s\t%s\n' "$original" "$replacement" >> "$replace_file"
  done < "$candidates_file"
}

build_success_actions() {
  local candidates_file="$1"
  local output_file="$2"
  local remove_file="$3"
  local source action entry original_line

  : > "$remove_file"

  # For each manifest entry with action kb/memory/discard, find the matching
  # original line in candidates. Match by: source_file matches AND entry text
  # is a substring of the candidate's entry text (handles Haiku truncation).
  # Entries with action "keep" are left in place.

  while IFS=$'\t' read -r source action entry; do
    [[ "$action" == "keep" ]] && continue

    # Find matching candidate line — first match wins
    original_line="$(awk -F '\t' -v src="$source" -v entry="$entry" '
      $1 == src && index($5, entry) > 0 && !found {
        print $4
        found = 1
      }
    ' "$candidates_file")"

    if [[ -n "$original_line" ]]; then
      printf '%s\n' "$original_line" >> "$remove_file"
    else
      log "Manifest entry not found in candidates: ${source}:${entry:0:60}"
    fi
  done < <(jq -r '.[] | [.source_file, .action, .entry] | @tsv' "$output_file")
}

apply_transformations() {
  local file_path="$1"
  local remove_file="$2"
  local replace_file="$3"
  local tmp_file

  [[ -f "$file_path" ]] || return 0

  tmp_file="$(mktemp)"

  awk -v remove_file="$remove_file" -v replace_file="$replace_file" '
    BEGIN {
      while ((getline line < remove_file) > 0) {
        remove_count[line]++
      }
      close(remove_file)

      while ((getline line < replace_file) > 0) {
        split(line, parts, "\t")
        replace_count[parts[1]]++
        replace_value[parts[1], replace_count[parts[1]]] = parts[2]
      }
      close(replace_file)
    }
    {
      if (replaced[$0] < replace_count[$0]) {
        idx = replaced[$0] + 1
        print replace_value[$0, idx]
        replaced[$0] = idx
        next
      }
      if (remove_count[$0] > 0) {
        remove_count[$0]--
        next
      }
      print
    }
  ' "$file_path" > "$tmp_file"

  if ! cmp -s "$file_path" "$tmp_file"; then
    mv "$tmp_file" "$file_path"
  else
    rm -f "$tmp_file"
  fi
}

trim_lessons_file() {
  local lessons_file="$1"
  local active_count excess trim_file

  [[ -f "$lessons_file" ]] || return 0

  active_count="$(awk '
    /^- / {
      if ($0 !~ /^- \[pending(:[0-9]+)?\] / && $0 !~ /^- \[failed\] /) {
        count++
      }
    }
    END { print count + 0 }
  ' "$lessons_file")"

  if [[ "$active_count" -le 15 ]]; then
    return 0
  fi

  excess=$((active_count - 15))
  trim_file="$(mktemp)"

  awk -v limit="$excess" '
    /^- / && $0 !~ /^- \[pending(:[0-9]+)?\] / && $0 !~ /^- \[failed\] / {
      if (count < limit) {
        print $0
        count++
      }
    }
  ' "$lessons_file" > "$trim_file"

  apply_transformations "$lessons_file" "$trim_file" /dev/null

  rm -f "$trim_file"
}

commit_hot_buffers() {
  local project_dir="$1"
  local staged_paths=()
  local path status_output

  if [[ ! -d "${project_dir}/.git" ]] && ! git -C "$project_dir" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    log "Not a git repository, skipping commit: $project_dir"
    return 0
  fi

  if git -C "$project_dir" ls-files -u -- captures.md lessons.md decisions.md | grep -q .; then
    log "Hot buffer files have merge conflicts, skipping commit: $project_dir"
    return 1
  fi

  status_output="$(git -C "$project_dir" status --porcelain -- captures.md lessons.md decisions.md)"
  [[ -n "$status_output" ]] || return 0

  for path in captures.md lessons.md decisions.md; do
    if [[ -e "${project_dir}/${path}" ]]; then
      staged_paths+=("$path")
    fi
  done

  [[ "${#staged_paths[@]}" -gt 0 ]] || return 0

  git -C "$project_dir" add -- "${staged_paths[@]}"

  if git -C "$project_dir" diff --cached --quiet -- "${staged_paths[@]}"; then
    return 0
  fi

  git -C "$project_dir" commit --only -m "$COMMIT_MESSAGE" -- "${staged_paths[@]}" >/dev/null 2>&1 || {
    log "Commit failed for project: $project_dir"
    return 1
  }

  log "Committed hot buffer changes: $project_dir"
  return 0
}

process_project() {
  local project_dir="$1"
  local project_name tmp_dir candidates_file snapshot_file prompt_file output_file remove_file replace_file

  if [[ -f "${project_dir}/.il-exclude" ]]; then
    log "Skipping excluded project: $project_dir"
    return 0
  fi

  if ! acquire_lock "$project_dir"; then
    return 0
  fi

  tmp_dir="$(mktemp -d)"
  candidates_file="${tmp_dir}/candidates.tsv"
  snapshot_file="${tmp_dir}/snapshot.tsv"
  prompt_file="${tmp_dir}/prompt.txt"
  output_file="${tmp_dir}/classifier.json"
  remove_file="${tmp_dir}/remove.txt"
  replace_file="${tmp_dir}/replace.tsv"

  collect_candidates "$project_dir" "$candidates_file" "$snapshot_file"

  if [[ ! -s "$candidates_file" ]]; then
    log "No entries to process: $project_dir"
    rm -rf "$tmp_dir"
    release_lock
    return 0
  fi

  project_name="$(basename "$project_dir")"
  build_prompt "$project_name" "$snapshot_file" > "$prompt_file"

  if ! run_classifier "$prompt_file" "$output_file"; then
    build_failure_replacements "$candidates_file" "$replace_file"
    : > "$remove_file"
    apply_transformations "${project_dir}/captures.md" "$remove_file" "$replace_file"
    apply_transformations "${project_dir}/lessons.md" "$remove_file" "$replace_file"
    apply_transformations "${project_dir}/decisions.md" "$remove_file" "$replace_file"
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

  if ! validate_manifest "$candidates_file" "$output_file"; then
    build_failure_replacements "$candidates_file" "$replace_file"
    : > "$remove_file"
    apply_transformations "${project_dir}/captures.md" "$remove_file" "$replace_file"
    apply_transformations "${project_dir}/lessons.md" "$remove_file" "$replace_file"
    apply_transformations "${project_dir}/decisions.md" "$remove_file" "$replace_file"
    commit_hot_buffers "$project_dir" || true
    rm -rf "$tmp_dir"
    release_lock
    return 0
  fi

  # PASS 2: Route entries to KB/Memory via MCP tools
  if ! route_entries "$output_file"; then
    log "Routing failed — marking entries as pending (will retry next run)"
    build_failure_replacements "$candidates_file" "$replace_file"
    : > "$remove_file"
    apply_transformations "${project_dir}/captures.md" "$remove_file" "$replace_file"
    apply_transformations "${project_dir}/lessons.md" "$remove_file" "$replace_file"
    apply_transformations "${project_dir}/decisions.md" "$remove_file" "$replace_file"
    commit_hot_buffers "$project_dir" || true
    rm -rf "$tmp_dir"
    release_lock
    return 0
  fi

  build_success_actions "$candidates_file" "$output_file" "$remove_file"
  : > "$replace_file"

  apply_transformations "${project_dir}/captures.md" "$remove_file" "$replace_file"
  apply_transformations "${project_dir}/lessons.md" "$remove_file" "$replace_file"
  apply_transformations "${project_dir}/decisions.md" "$remove_file" "$replace_file"
  trim_lessons_file "${project_dir}/lessons.md"
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
