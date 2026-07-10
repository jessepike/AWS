#!/usr/bin/env python3
"""il-entries.py — structural entry model for il-classifier.sh (F2).

Part of the F2 promotion-receipts rework. Pure stdlib. Owns every operation
that touches captures.md / lessons.md / decisions.md content or the
`.il-receipts` sidecar: collecting candidates, matching classifier output back
to them, deciding the final per-entry outcome, applying that outcome to disk,
and garbage-collecting old machine-marked entries.

Entry model (F2 design D1/R1): an entry is a line matching ^- followed by zero
or more immediately-following continuation lines matching ^[ \\t]+\\S. A blank
line, a new ^- line, a heading, or any other non-indented line ends the entry.
Every operation here works on whole entries, never bare physical lines — this
is what closes the historical defect where a lexical (line-only) model split
multi-line bullets and orphaned continuation lines (see f3a0a19 / 48670e7 /
9d6bad5 / 9cbb5f3 in this repo's git log — the guard comment in
il-classifier.sh's apply_transformations predecessor said not to lift the
append-only guard on decisions.md "without first making the entry model
structural"; this file is that).

decisions.md is READ-ONLY here, full stop — no code path in this file ever
opens it for writing. State for decisions.md entries lives entirely in the
`.il-receipts` sidecar (D3), keyed by sha256 of the entry's stripped text.

Subcommands (each reads/writes JSON; see each cmd_* docstring for shape):
  collect   --project-dir DIR
  match     --candidates FILE --manifest FILE
  finalize  --candidates FILE (--matched FILE [--router-results FILE] | --batch-fail) [--now YYYY-MM-DD]
  apply     --project-dir DIR --candidates FILE --results FILE
  gc        --project-dir DIR --files a.md,b.md [--max-age-days 14] [--now YYYY-MM-DD]
"""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import re
import sys
import tempfile
from datetime import date

MUTABLE_FILES = ("captures.md", "lessons.md")
ALL_SOURCE_FILES = ("captures.md", "lessons.md", "decisions.md")
SIDECAR_NAME = ".il-receipts"

ENTRY_START_RE = re.compile(r"^- ")
CONTINUATION_RE = re.compile(r"^[ \t]+\S")

PROMOTED_RE = re.compile(r"^- \[promoted:(kb|mem):([^:\]]+):(\d{4}-\d{2}-\d{2})\] ?(.*)$")
DISCARDED_RE = re.compile(r"^- \[discarded:(\d{4}-\d{2}-\d{2})\] ?(.*)$")
PENDING_RE = re.compile(r"^- \[pending(?::(\d+))?\] ?(.*)$")
FAILED_RE = re.compile(r"^- \[failed\] ?(.*)$")

TERMINAL_OUTCOMES = {"promoted", "discarded", "failed_terminal"}


# ---------------------------------------------------------------------------
# File I/O — atomic, trailing-newline preserving
# ---------------------------------------------------------------------------

def read_file(path):
    """Return (lines, ends_with_newline) or None if the file does not exist."""
    if not os.path.isfile(path):
        return None
    with open(path, "r", encoding="utf-8") as f:
        text = f.read()
    ends_with_nl = text.endswith("\n") or text == ""
    lines = text.splitlines()
    return lines, ends_with_nl


def atomic_write(path, text):
    directory = os.path.dirname(os.path.abspath(path)) or "."
    fd, tmp_path = tempfile.mkstemp(prefix=".il-tmp-", dir=directory)
    try:
        with os.fdopen(fd, "w", encoding="utf-8") as f:
            f.write(text)
        os.replace(tmp_path, path)
    except Exception:
        try:
            os.unlink(tmp_path)
        except OSError:
            pass
        raise


def write_lines(path, lines, ends_with_nl):
    if not lines:
        text = ""
    else:
        text = "\n".join(lines)
        if ends_with_nl:
            text += "\n"
    atomic_write(path, text)


# ---------------------------------------------------------------------------
# Sidecar (.il-receipts) — tab-separated: sha256:<hash> TAB <state> TAB <date>
# ---------------------------------------------------------------------------

def sha256_hex(text):
    return hashlib.sha256(text.encode("utf-8")).hexdigest()


def read_sidecar(path):
    rows = {}
    if not os.path.isfile(path):
        return rows
    with open(path, "r", encoding="utf-8") as f:
        for line in f:
            line = line.rstrip("\n")
            if not line.strip():
                continue
            parts = line.split("\t")
            if len(parts) != 3:
                continue
            h, state, d = parts
            if h.startswith("sha256:"):
                h = h[len("sha256:"):]
            rows[h] = (state, d)
    return rows


def write_sidecar(path, rows):
    lines = [f"sha256:{h}\t{state}\t{d}" for h, (state, d) in sorted(rows.items())]
    text = "\n".join(lines)
    if lines:
        text += "\n"
    atomic_write(path, text)


def upsert_sidecar(path, updates):
    rows = read_sidecar(path)
    rows.update(updates)
    write_sidecar(path, rows)


def sidecar_state_is_terminal(state):
    return state.startswith("kb:") or state.startswith("mem:") or state in ("discarded", "failed")


# ---------------------------------------------------------------------------
# Structural entry parsing
# ---------------------------------------------------------------------------

def parse_blocks(lines):
    """Split lines into blocks of {"type": "entry"|"other", "lines": [...]}.

    An entry block starts at a line matching ^- and extends through any
    immediately-following lines matching ^[ \\t]+\\S (continuations). Anything
    else — blank lines, headings, prose, HTML comments, numbered lists — is an
    "other" block, preserved verbatim and never touched by any writer here.
    """
    blocks = []
    i, n = 0, len(lines)
    while i < n:
        if ENTRY_START_RE.match(lines[i]):
            j = i + 1
            while j < n and CONTINUATION_RE.match(lines[j]):
                j += 1
            blocks.append({"type": "entry", "lines": lines[i:j]})
            i = j
        else:
            j = i + 1
            while j < n and not ENTRY_START_RE.match(lines[j]):
                j += 1
            blocks.append({"type": "other", "lines": lines[i:j]})
            i = j
    return blocks


def classify_first_line(line):
    """Classify a `^- ...` first line. Returns a dict with at least "marker"
    and "content" (the text after the marker/bullet is stripped). Caller
    guarantees `line` matches ENTRY_START_RE.
    """
    m = PROMOTED_RE.match(line)
    if m:
        return {"marker": "promoted", "store": m.group(1), "id": m.group(2),
                "date": m.group(3), "content": m.group(4)}
    m = DISCARDED_RE.match(line)
    if m:
        return {"marker": "discarded", "date": m.group(1), "content": m.group(2)}
    m = PENDING_RE.match(line)
    if m:
        attempts = int(m.group(1)) if m.group(1) else 1
        return {"marker": "pending", "attempts": attempts, "content": m.group(2)}
    m = FAILED_RE.match(line)
    if m:
        return {"marker": "failed", "content": m.group(1)}
    return {"marker": "unmarked", "content": line[2:]}


def entry_text_and_flat(block_lines, first_line_content):
    """Build (text, flat) for an entry given its raw lines and the already-
    marker-stripped content of the first line.

    text: content-only, newline-preserved (first line stripped of bullet/
          marker, continuation lines verbatim) — this is the "original full
          text" sent to the router (R1).
    flat: every line stripped and joined with a single space — this is the
          rendering used in the classification prompt and for fuzzy matching
          (R1: "render a multi-line entry as its lines joined with a space").
    """
    all_lines = [first_line_content] + list(block_lines[1:])
    text = "\n".join(all_lines)
    flat = " ".join(l.strip() for l in all_lines)
    return text, flat


# ---------------------------------------------------------------------------
# collect
# ---------------------------------------------------------------------------

def cmd_collect(args):
    project_dir = args.project_dir
    sidecar = read_sidecar(os.path.join(project_dir, SIDECAR_NAME))

    candidates = []
    cid = 0

    for source_file in MUTABLE_FILES:
        result = read_file(os.path.join(project_dir, source_file))
        if result is None:
            continue
        lines, _ = result
        for block in parse_blocks(lines):
            if block["type"] != "entry":
                continue
            cls = classify_first_line(block["lines"][0])
            marker = cls["marker"]
            if marker in ("promoted", "discarded", "failed"):
                continue  # terminal — never a candidate again
            if marker == "pending":
                state, attempts = "pending", cls["attempts"]
            else:
                state, attempts = "new", 0
            text, flat = entry_text_and_flat(block["lines"], cls["content"])
            candidates.append({
                "cid": cid, "source_file": source_file, "state": state,
                "attempts": attempts, "lines": block["lines"],
                "text": text, "flat": flat, "hash": sha256_hex(text),
            })
            cid += 1

    # decisions.md: read-only, always. State comes from the sidecar, never
    # from in-file markers (the append-only guard means none can exist there
    # unless a human typed one by coincidence — treated as plain content).
    result = read_file(os.path.join(project_dir, "decisions.md"))
    if result is not None:
        lines, _ = result
        for block in parse_blocks(lines):
            if block["type"] != "entry":
                continue
            first_line = block["lines"][0]
            content = first_line[2:] if first_line.startswith("- ") else first_line
            text, flat = entry_text_and_flat(block["lines"], content)
            h = sha256_hex(text)
            row = sidecar.get(h)
            if row is not None:
                state_str, _d = row
                if state_str.startswith("pending:"):
                    state, attempts = "pending", int(state_str.split(":", 1)[1])
                else:
                    continue  # terminal per sidecar — skip
            else:
                state, attempts = "new", 0
            candidates.append({
                "cid": cid, "source_file": "decisions.md", "state": state,
                "attempts": attempts, "lines": block["lines"],
                "text": text, "flat": flat, "hash": h,
            })
            cid += 1

    json.dump({"candidates": candidates}, sys.stdout)


# ---------------------------------------------------------------------------
# match
# ---------------------------------------------------------------------------

def _norm(s):
    return re.sub(r"[^a-z0-9]", "", s.lower())


def fuzzy_match(manifest_text, candidate_flat):
    """Mirrors the original awk matcher: lowercase + strip non-alnum on both
    sides, bound the manifest text to a 50-char prefix, require >=12 chars,
    substring test. Tolerates haiku's markdown-stripping / em-dash rewriting /
    truncation without requiring verbatim equality.
    """
    want = _norm(manifest_text)
    if len(want) > 50:
        want = want[:50]
    if len(want) < 12:
        return False
    return want in _norm(candidate_flat)


def cmd_match(args):
    with open(args.candidates, "r", encoding="utf-8") as f:
        candidates = json.load(f)["candidates"]
    with open(args.manifest, "r", encoding="utf-8") as f:
        manifest = json.load(f)

    by_source = {}
    for c in candidates:
        by_source.setdefault(c["source_file"], []).append(c)

    used = set()
    matched = []
    unmatched = []

    for m in manifest:
        source_file = m.get("source_file")
        action = m.get("action")
        entry_text = m.get("entry", "")
        pool = by_source.get(source_file, [])
        hit = None
        for c in pool:
            if c["cid"] in used:
                continue
            if fuzzy_match(entry_text, c["flat"]):
                hit = c
                break
        if hit is None:
            unmatched.append({"source_file": source_file, "entry": entry_text, "action": action})
            print(f"Manifest entry not found in candidates: {source_file}:{entry_text[:60]}", file=sys.stderr)
            continue
        used.add(hit["cid"])
        item = {"cid": hit["cid"], "source_file": source_file, "action": action, "text": hit["text"]}
        if action == "kb":
            item["kb_type"] = m.get("kb_type") or "learning"
            item["domain"] = m.get("domain") or "general"
        elif action == "memory":
            item["memory_type"] = m.get("memory_type") or "observation"
            item["namespace"] = m.get("namespace") or "global"
        matched.append(item)

    json.dump({"matched": matched, "unmatched_manifest_entries": unmatched}, sys.stdout)


# ---------------------------------------------------------------------------
# finalize
# ---------------------------------------------------------------------------

def next_attempt_outcome(attempts):
    """3-strike rule, ported verbatim from mark_failed_or_pending: the NEXT
    attempt number that would result from one more failure; >=3 is terminal.
    """
    next_attempt = attempts + 1
    if next_attempt >= 3:
        return "failed_terminal", next_attempt
    return "failed_retry", next_attempt


def cmd_finalize(args):
    with open(args.candidates, "r", encoding="utf-8") as f:
        candidates = {c["cid"]: c for c in json.load(f)["candidates"]}
    today = args.now or date.today().isoformat()

    results = []

    if args.batch_fail:
        for cid, c in candidates.items():
            outcome, n = next_attempt_outcome(c["attempts"])
            results.append({"cid": cid, "outcome": outcome, "attempts": n})
        json.dump({"results": results}, sys.stdout)
        return

    with open(args.matched, "r", encoding="utf-8") as f:
        matched = json.load(f)["matched"]

    router_results = {}
    if args.router_results:
        with open(args.router_results, "r", encoding="utf-8") as f:
            for r in json.load(f):
                router_results[r["rid"]] = r

    for m in matched:
        cid = m["cid"]
        action = m["action"]
        c = candidates.get(cid)
        if c is None:
            continue
        if action == "discard":
            results.append({"cid": cid, "outcome": "discarded", "date": today})
        elif action == "keep":
            continue
        elif action in ("kb", "memory"):
            r = router_results.get(cid)
            if r is not None and r.get("status") == "ok":
                store = "kb" if action == "kb" else "mem"
                full_id = str(r.get("id", ""))
                short_id = full_id[:8] if full_id else "unknown"
                results.append({
                    "cid": cid, "outcome": "promoted", "store": store,
                    "id": short_id, "full_id": full_id, "date": today,
                })
            else:
                outcome, n = next_attempt_outcome(c["attempts"])
                results.append({"cid": cid, "outcome": outcome, "attempts": n})
        # unknown action values: no-op, safe default

    json.dump({"results": results}, sys.stdout)


# ---------------------------------------------------------------------------
# apply
# ---------------------------------------------------------------------------

def build_new_first_line(bare_content, outcome_entry):
    o = outcome_entry
    if o["outcome"] == "promoted":
        prefix = f"[promoted:{o['store']}:{o['id']}:{o['date']}]"
    elif o["outcome"] == "discarded":
        prefix = f"[discarded:{o['date']}]"
    elif o["outcome"] == "failed_retry":
        n = o["attempts"]
        prefix = "[pending]" if n <= 1 else f"[pending:{n}]"
    elif o["outcome"] == "failed_terminal":
        prefix = "[failed]"
    else:
        raise ValueError(f"unknown outcome: {o['outcome']!r}")
    return f"- {prefix} {bare_content}" if bare_content else f"- {prefix}"


def cmd_apply(args):
    project_dir = args.project_dir
    with open(args.candidates, "r", encoding="utf-8") as f:
        candidates = {c["cid"]: c for c in json.load(f)["candidates"]}
    with open(args.results, "r", encoding="utf-8") as f:
        results = json.load(f)["results"]

    sidecar_updates = {}
    per_file_outcomes = {}

    summary = {
        "promoted_kb": 0, "promoted_mem": 0, "discarded": 0,
        "failed_retry": 0, "failed_terminal": 0, "sidecar_rows": 0,
        "skipped_not_found": 0,
    }

    for o in results:
        c = candidates.get(o["cid"])
        if c is None:
            continue

        if o["outcome"] == "promoted":
            summary["promoted_kb" if o["store"] == "kb" else "promoted_mem"] += 1
        elif o["outcome"] in summary:
            summary[o["outcome"]] += 1

        if c["source_file"] == "decisions.md":
            h = c["hash"]
            if o["outcome"] == "promoted":
                state = f"{o['store']}:{o['id']}"
            elif o["outcome"] == "discarded":
                state = "discarded"
            elif o["outcome"] == "failed_retry":
                state = f"pending:{o['attempts']}"
            elif o["outcome"] == "failed_terminal":
                state = "failed"
            else:
                continue
            d = o.get("date", date.today().isoformat())
            sidecar_updates[h] = (state, d)
            summary["sidecar_rows"] += 1
        else:
            per_file_outcomes.setdefault(c["source_file"], []).append((c, o))

    # decisions.md is NEVER opened for writing — only its sidecar is touched.
    if sidecar_updates:
        upsert_sidecar(os.path.join(project_dir, SIDECAR_NAME), sidecar_updates)

    for source_file, items in per_file_outcomes.items():
        path = os.path.join(project_dir, source_file)
        result = read_file(path)
        if result is None:
            summary["skipped_not_found"] += len(items)
            continue
        lines, ends_with_nl = result
        blocks = parse_blocks(lines)

        targets = {tuple(c["lines"]): o for c, o in items}
        changed = False
        new_lines = []

        for block in blocks:
            key = tuple(block["lines"])
            if block["type"] == "entry" and key in targets:
                o = targets.pop(key)
                cls = classify_first_line(block["lines"][0])
                new_first = build_new_first_line(cls["content"], o)
                new_lines.append(new_first)
                new_lines.extend(block["lines"][1:])
                changed = True
            else:
                new_lines.extend(block["lines"])

        if targets:
            summary["skipped_not_found"] += len(targets)
            for o in targets.values():
                print(f"apply: candidate cid={o['cid']} not found in current {source_file} — skipped "
                      f"(file changed since collect?)", file=sys.stderr)

        if changed:
            write_lines(path, new_lines, ends_with_nl)

    json.dump({"summary": summary}, sys.stdout)


# ---------------------------------------------------------------------------
# gc
# ---------------------------------------------------------------------------

def cmd_gc(args):
    project_dir = args.project_dir
    files = [f.strip() for f in args.files.split(",") if f.strip()]
    max_age = args.max_age_days
    today = date.fromisoformat(args.now) if args.now else date.today()

    removed_summary = {}

    for source_file in files:
        path = os.path.join(project_dir, source_file)
        result = read_file(path)
        if result is None:
            continue
        lines, ends_with_nl = result
        blocks = parse_blocks(lines)

        removed = 0
        new_lines = []
        for block in blocks:
            if block["type"] == "entry":
                first = block["lines"][0]
                marker_date = None
                m = PROMOTED_RE.match(first)
                if m:
                    marker_date = m.group(3)
                else:
                    m = DISCARDED_RE.match(first)
                    if m:
                        marker_date = m.group(1)
                if marker_date:
                    try:
                        d = date.fromisoformat(marker_date)
                        if (today - d).days >= max_age:
                            removed += 1
                            continue  # drop whole entry block, continuations included
                    except ValueError:
                        pass  # malformed date — leave the entry alone, don't guess
            new_lines.extend(block["lines"])

        if removed:
            write_lines(path, new_lines, ends_with_nl)
        removed_summary[source_file] = removed

    json.dump({"removed": removed_summary}, sys.stdout)


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

def build_parser():
    p = argparse.ArgumentParser(description=__doc__)
    sub = p.add_subparsers(dest="cmd", required=True)

    sp = sub.add_parser("collect")
    sp.add_argument("--project-dir", required=True)
    sp.set_defaults(func=cmd_collect)

    sp = sub.add_parser("match")
    sp.add_argument("--candidates", required=True)
    sp.add_argument("--manifest", required=True)
    sp.set_defaults(func=cmd_match)

    sp = sub.add_parser("finalize")
    sp.add_argument("--candidates", required=True)
    sp.add_argument("--matched")
    sp.add_argument("--router-results")
    sp.add_argument("--batch-fail", action="store_true")
    sp.add_argument("--now", help="ISO date override for testing; defaults to real today")
    sp.set_defaults(func=cmd_finalize)

    sp = sub.add_parser("apply")
    sp.add_argument("--project-dir", required=True)
    sp.add_argument("--candidates", required=True)
    sp.add_argument("--results", required=True)
    sp.set_defaults(func=cmd_apply)

    sp = sub.add_parser("gc")
    sp.add_argument("--project-dir", required=True)
    sp.add_argument("--files", required=True, help="comma-separated filenames relative to project-dir")
    sp.add_argument("--max-age-days", type=int, default=14)
    sp.add_argument("--now", help="ISO date override for testing; defaults to real today")
    sp.set_defaults(func=cmd_gc)

    return p


def main():
    parser = build_parser()
    args = parser.parse_args()
    if args.cmd == "finalize" and not args.batch_fail and not args.matched:
        parser.error("finalize requires --matched unless --batch-fail is set")
    args.func(args)


if __name__ == "__main__":
    main()
