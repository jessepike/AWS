#!/bin/bash

set -uo pipefail

ROOTS=(
  "$HOME/code/_shared"
  "$HOME/code/tools"
  "$HOME/code/clients"
)

REPORT_DIR="$HOME/.logs"
TODAY="$(date '+%Y-%m-%d')"
REPORT_PATH="${REPORT_DIR}/il-lint-${TODAY}.md"
DRY_RUN=0

log() {
  printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*" >&2
}

usage() {
  cat >&2 <<'EOF'
Usage: il-lint-sweep.sh [--dry-run]
EOF
}

extract_json_array() {
  # Extract a JSON array from claude -p --output-format json output.
  # Handles: direct array, wrapped in {"result":"..."}, markdown code fences.
  local raw_file="$1"
  local out_file="$2"
  local extract_script="${out_file}.py"

  if jq -e 'type == "array"' "$raw_file" >/dev/null 2>&1; then
    cp "$raw_file" "$out_file"
    return 0
  fi

  if ! jq -e '.result' "$raw_file" >/dev/null 2>&1; then
    return 1
  fi

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

run_claude_array() {
  local allowed_tools="$1"
  local prompt_file="$2"
  local output_file="$3"
  local label="$4"
  local raw_output="${output_file}.raw"

  if [[ "$DRY_RUN" == "1" ]]; then
    log "Dry run: ${label}"
    cat "$prompt_file"
    return 2
  fi

  if ! command -v claude >/dev/null 2>&1; then
    log "claude command not found for ${label}"
    return 1
  fi

  if ! claude -p \
    --model haiku \
    --output-format json \
    --allowedTools "$allowed_tools" \
    < "$prompt_file" > "$raw_output"; then
    log "claude -p failed for ${label}"
    rm -f "$raw_output"
    return 1
  fi

  if ! extract_json_array "$raw_output" "$output_file"; then
    log "Could not extract JSON array for ${label}"
    log "Raw result preview: $(jq -r '.result // .' "$raw_output" | head -5)"
    rm -f "$raw_output"
    return 1
  fi

  rm -f "$raw_output"
  return 0
}

discover_hot_buffer_dirs() {
  local root

  for root in "${ROOTS[@]}"; do
    [[ -d "$root" ]] || continue
    find "$root" -type f \( -name 'captures.md' -o -name 'lessons.md' -o -name 'decisions.md' \) -print 2>/dev/null
  done | while IFS= read -r path; do
    dirname "$path"
  done | sort -u
}

count_entries() {
  local file_path="$1"
  [[ -f "$file_path" ]] || {
    printf '0\n'
    return 0
  }

  awk '/^- / { count++ } END { print count + 0 }' "$file_path"
}

run_contradictions_check() {
  local output_file="$1"
  local prompt_file="${output_file}.prompt"

  cat > "$prompt_file" <<'EOF'
Search KB for recent learnings (last 30 days). Search Memory for recent decisions. Identify any contradictions where a KB learning conflicts with a Memory decision. Report contradictions only — not similarities.

Return ONLY a JSON array. If none, return [].
Each item must include:
- kb_item
- memory_item
- contradiction
- severity
EOF

  run_claude_array \
    "mcp__knowledge-base__search_knowledge,mcp__memory__search_memories" \
    "$prompt_file" \
    "$output_file" \
    "Contradictions check"
}

run_staleness_check() {
  local output_file="$1"
  local prompt_file="${output_file}.prompt"

  cat > "$prompt_file" <<'EOF'
Check KB and Memory for stale entries.

1. Use knowledge-base get_stats to assess corpus health and last write date.
2. Search Memory for entries older than 90 days without recent access.

Return ONLY a JSON array. If there are no stale findings, return [].
Include an item when:
- KB last write date or corpus health indicates staleness risk
- A Memory entry appears older than 90 days without recent access

Each item must include:
- store
- issue
- details
- count
- examples
EOF

  run_claude_array \
    "mcp__knowledge-base__get_stats,mcp__memory__search_memories" \
    "$prompt_file" \
    "$output_file" \
    "Staleness check"
}

run_boundary_check() {
  local output_file="$1"
  local prompt_file="${output_file}.prompt"

  cat > "$prompt_file" <<'EOF'
Search KB for atomic facts that should be in Memory (for example hostnames, ports, specific decisions). Search Memory for structured knowledge that should be in KB (for example patterns, multi-step learnings). Report misplacements only.

Return ONLY a JSON array. If none, return [].
Each item must include:
- wrong_store
- suggested_store
- item
- reason
EOF

  run_claude_array \
    "mcp__knowledge-base__search_knowledge,mcp__memory__search_memories" \
    "$prompt_file" \
    "$output_file" \
    "Boundary violations check"
}

run_orphaned_check() {
  local output_file="$1"
  local prompt_file="${output_file}.prompt"

  cat > "$prompt_file" <<'EOF'
Use get_stats to check the KB corpus health. Look at the stats for any signs of:
- Large numbers of entries with zero reuse (never accessed after creation)
- Entries stuck in non-active states
- Corpus size anomalies

Return ONLY a JSON array summarizing findings. If the corpus looks healthy, return [].
Each item must include:
- issue: description of the problem
- details: specific numbers or examples
- severity: high/medium/low
EOF

  run_claude_array \
    "mcp__knowledge-base__get_stats,mcp__knowledge-base__search_knowledge" \
    "$prompt_file" \
    "$output_file" \
    "Orphaned entries check"
}

run_hot_buffer_check() {
  local output_file="$1"
  local tmp_file
  local project_dir captures_count lessons_count decisions_count
  local project_count=0

  tmp_file="$(mktemp)"
  : > "$tmp_file"

  while IFS= read -r project_dir; do
    [[ -n "$project_dir" ]] || continue
    captures_count="$(count_entries "${project_dir}/captures.md")"
    lessons_count="$(count_entries "${project_dir}/lessons.md")"
    decisions_count="$(count_entries "${project_dir}/decisions.md")"

    if [[ "$captures_count" -gt 50 || "$lessons_count" -gt 15 ]]; then
      project_count=$((project_count + 1))
      jq -n \
        --arg project_dir "$project_dir" \
        --argjson captures_count "$captures_count" \
        --argjson lessons_count "$lessons_count" \
        --argjson decisions_count "$decisions_count" \
        --arg overflow_reason "$(
          if [[ "$captures_count" -gt 50 && "$lessons_count" -gt 15 ]]; then
            printf 'captures.md > 50 and lessons.md > 15'
          elif [[ "$captures_count" -gt 50 ]]; then
            printf 'captures.md > 50'
          else
            printf 'lessons.md > 15'
          fi
        )" \
        '{
          project_dir: $project_dir,
          captures_count: $captures_count,
          lessons_count: $lessons_count,
          decisions_count: $decisions_count,
          overflow_reason: $overflow_reason
        }' >> "$tmp_file"
      printf '\n' >> "$tmp_file"
    fi
  done < <(discover_hot_buffer_dirs)

  if [[ "$project_count" -eq 0 ]]; then
    printf '[]\n' > "$output_file"
  else
    jq -s '.' "$tmp_file" > "$output_file"
  fi

  rm -f "$tmp_file"

  if [[ "$DRY_RUN" == "1" ]]; then
    log "Dry run: Hot buffer overflow check across ${ROOTS[*]}"
  fi
}

json_array_length() {
  local file_path="$1"
  [[ -f "$file_path" ]] || {
    printf '0\n'
    return 0
  }

  jq 'length' "$file_path" 2>/dev/null || printf '0\n'
}

format_json_details() {
  local file_path="$1"
  local none_message="$2"

  if [[ ! -f "$file_path" ]]; then
    printf '%s\n' "$none_message"
    return 0
  fi

  if [[ "$(jq 'length' "$file_path" 2>/dev/null)" == "0" ]]; then
    printf '%s\n' "$none_message"
    return 0
  fi

  python3 -c "
import json, sys
with open(sys.argv[1]) as f:
    items = json.load(f)
for item in items:
    parts = []
    for k, v in item.items():
        if isinstance(v, list):
            v = '; '.join(str(x) for x in v)
        parts.append(f'{k}: {v}')
    print(f'- {\" | \".join(parts)}')
" "$file_path"
}

write_report() {
  local contradictions_file="$1"
  local staleness_file="$2"
  local hot_buffer_file="$3"
  local boundary_file="$4"
  local orphaned_file="$5"
  local contradictions_count stale_count hot_buffer_count boundary_count orphaned_count

  contradictions_count="$(json_array_length "$contradictions_file")"
  stale_count="$(json_array_length "$staleness_file")"
  hot_buffer_count="$(json_array_length "$hot_buffer_file")"
  boundary_count="$(json_array_length "$boundary_file")"
  orphaned_count="$(json_array_length "$orphaned_file")"

  mkdir -p "$REPORT_DIR"

  cat > "$REPORT_PATH" <<EOF
# IL Lint Sweep — ${TODAY}

## Summary
- Contradictions: ${contradictions_count}
- Stale entries: ${stale_count}
- Hot buffer overflow: ${hot_buffer_count}
- Boundary violations: ${boundary_count}
- Orphaned entries: ${orphaned_count}

## Details

### Contradictions
$(format_json_details "$contradictions_file" "None found")

### Staleness
$(format_json_details "$staleness_file" "None found")

### Hot Buffer Overflow
$(format_json_details "$hot_buffer_file" "All within limits")

### Boundary Violations
$(format_json_details "$boundary_file" "None found")

### Orphaned Entries
$(format_json_details "$orphaned_file" "None found")
EOF
}

run_check() {
  local label="$1"
  local file_path="$2"
  local rc=0

  "$label" "$file_path"
  rc=$?

  if [[ "$rc" -eq 1 ]]; then
    log "${label} failed; continuing"
  fi

  return 0
}

main() {
  local tmp_dir contradictions_file staleness_file hot_buffer_file boundary_file orphaned_file

  [[ -n "${CODEX_SANDBOX:-}" ]] && exit 0

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --dry-run)
        DRY_RUN=1
        shift
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      *)
        usage
        exit 1
        ;;
    esac
  done

  tmp_dir="$(mktemp -d)"
  contradictions_file="${tmp_dir}/contradictions.json"
  staleness_file="${tmp_dir}/staleness.json"
  hot_buffer_file="${tmp_dir}/hot-buffer.json"
  boundary_file="${tmp_dir}/boundary.json"
  orphaned_file="${tmp_dir}/orphaned.json"

  printf '[]\n' > "$contradictions_file"
  printf '[]\n' > "$staleness_file"
  printf '[]\n' > "$hot_buffer_file"
  printf '[]\n' > "$boundary_file"
  printf '[]\n' > "$orphaned_file"

  log "Starting IL lint sweep"

  run_check run_contradictions_check "$contradictions_file"
  run_check run_staleness_check "$staleness_file"
  run_check run_hot_buffer_check "$hot_buffer_file"
  run_check run_boundary_check "$boundary_file"
  run_check run_orphaned_check "$orphaned_file"

  if [[ "$DRY_RUN" == "1" ]]; then
    log "Dry run complete; report would be written to ${REPORT_PATH}"
    rm -rf "$tmp_dir"
    exit 0
  fi

  write_report \
    "$contradictions_file" \
    "$staleness_file" \
    "$hot_buffer_file" \
    "$boundary_file" \
    "$orphaned_file"

  log "IL lint sweep report written to ${REPORT_PATH}"
  rm -rf "$tmp_dir"
  exit 0
}

main "$@"
