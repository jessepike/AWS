#!/usr/bin/env python3
"""il-router.py — deterministic routing pass for il-classifier.sh (F2 / D4).

Writes classified hot-buffer entries directly to the KB and Memory stores via
each store's own storage API (kb_core.storage.api.KBStorage /
memory_core.storage.api.MemoryStorage), invoked as a subprocess under that
store's own venv. This script's OWN top-level logic is stdlib-only — it never
imports kb_core or memory_core itself; those only get imported inside the
snippet strings below, which run as a separate `python3 -c ...` process using
each repo's own `.venv/bin/python3` (D4/R5: "their own venv/uv environment via
subprocess is fine").

Replaces the old PASS-2 haiku tool-calling routing pass, which:
  - had no way to report per-entry success/failure (a single haiku turn either
    "succeeded" or the whole batch was marked pending/failed);
  - built a routing prompt with `domain` and `source_type` params for
    send_to_kb that do not exist in that tool's real inputSchema (content,
    title, content_type, topics, source_project, source_url, source_entry_ids)
    — dead params, silently dropped by the MCP handler since inception;
  - hardcoded `writer_type: "automation"` for write_memory, which is not a
    valid memory_core WriterType (agent|user|system) — every "memory" routing
    attempt under the old script would have failed Pydantic validation inside
    MemoryStorage.write_memory. This router uses "system", the closest valid
    value, and preserves writer_id="il-classifier" (R4).

KB embedding is OpenAI (text-embedding-3-small) and is currently quota-
exhausted (429). The real send_to_kb MCP handler swallows embedding failures
(logs + continues) so a KB write still succeeds and returns a usable id; the
kb-writer snippet below replicates that exact swallow. Memory embedding is
local (ChromaDB ONNX / sentence-transformers) and is not affected.

Subcommands:
  route    stdin: JSON array of
             {"rid": <int>, "store": "kb"|"memory", "content": "<text>",
              "content_type": "..."      (kb only, must be learning|idea|note),
              "memory_type": "...",       (memory only, must be one of
                                            observation|preference|decision|
                                            progress|relationship),
              "namespace": "..."          (memory only, default "global"),
              "source_project": "..."}
           stdout: JSON array of {"rid": ..., "status": "ok"|"error",
                                   "id": "<full store id>", "error": "..."}
           `id` is the FULL store id; il-entries.py truncates to 8 chars for
           the in-file/sidecar marker (D1 permits either).

  archive  stdin: {"kb_ids": [...], "memory_ids": [...], "memory_namespace": "global"}
           stdout: {"kb_archived": [...], "memory_archived": [...], "errors": [...]}
           Used for R9 cleanup of the one production acceptance round-trip —
           not part of the routine sweep.

Test seams (inert unless the env var is set — R7):
  IL_TEST_KB_CONFIG          absolute path to an alternate kb_config.yaml,
                              passed straight through to kb_core.config.load_config
  IL_TEST_MEMORY_CONFIG      absolute path to an alternate memory_config.yaml,
                              passed straight through to MemoryStorage.from_config_path
  IL_TEST_FORCE_FAIL_PREFIX  if an entry's content starts with this exact
                              string, route it to a synthetic failure without
                              touching either store (used to test per-entry
                              partial-failure semantics deterministically)
"""

from __future__ import annotations

import json
import os
import subprocess
import sys

KB_REPO = os.path.expanduser("~/code/_shared/knowledge-base")
KB_VENV_PY = os.path.join(KB_REPO, ".venv", "bin", "python3")
MEMORY_REPO = os.path.expanduser("~/code/_shared/memory")
MEMORY_VENV_PY = os.path.join(MEMORY_REPO, ".venv", "bin", "python3")

VALID_KB_CONTENT_TYPES = {"learning", "idea", "note"}
VALID_MEMORY_TYPES = {"observation", "preference", "decision", "progress", "relationship"}

SUBPROCESS_TIMEOUT_SECONDS = 180


# ---------------------------------------------------------------------------
# Store-side snippets — executed via `<store venv python> -c <snippet>`,
# never imported into this process. Communicate over stdin/stdout JSON.
# ---------------------------------------------------------------------------

KB_WRITER_SNIPPET = r"""
import sys, json, uuid
from datetime import datetime

payload = json.load(sys.stdin)
config_path = payload.get("config_path")

from kb_core.config import load_config
from kb_core.models import SourceItem, Extraction
from kb_core.storage.api import KBStorage
from kb_core.utils.detection import extract_topics_from_content, detect_action_state
from kb_core.utils.priority import compute_priority_simple

config = load_config(config_path) if config_path else load_config()
storage = KBStorage(config)

results = []
for it in payload["entries"]:
    rid = it["rid"]
    try:
        content = it["content"]
        content_type = it["content_type"]
        source_project = it.get("source_project") or "unknown"

        topics = extract_topics_from_content(content)
        action_state = detect_action_state(content, content_type)
        title = content[:50].strip()
        if len(content) > 50:
            title += "..."

        source_id = str(uuid.uuid4())
        source_item = SourceItem(
            id=source_id, url=None, canonical_url=None, title=title, domain=None,
            source_type="manual", captured_at=datetime.now(),
            captured_by="il-classifier:" + source_project,
            raw_content=content, metadata={"source_project": source_project},
            status="staged",
        )
        storage.ingest_item(source_item)

        extraction = Extraction(
            source_id=source_id, content_type=content_type, action_state=action_state,
            summary=content[:500] if len(content) > 500 else content,
            key_points=[], actionables=[], concepts=[], quotes=[], topics=topics,
            priority_score=0.5, project_link=source_project, source_entry_ids=[],
        )
        extraction.priority_score = compute_priority_simple(extraction)
        extraction_id = storage.store_extraction(extraction)
        storage.commit_item(source_id)
        storage.commit_extraction(extraction_id)

        try:
            extraction.id = extraction_id
            storage.embed_and_index(extraction)
        except Exception as embed_err:
            # Matches _handle_send_to_kb's own swallow: embed failure is not a
            # routing failure. Known current condition: OpenAI quota exhausted.
            sys.stderr.write("kb-writer: embed failed for " + extraction_id +
                              " (non-fatal): " + str(embed_err) + "\n")

        results.append({"rid": rid, "status": "ok", "id": extraction_id, "source_id": source_id})
    except Exception as e:
        results.append({"rid": rid, "status": "error", "error": type(e).__name__ + ": " + str(e)})

json.dump(results, sys.stdout)
"""

MEMORY_WRITER_SNIPPET = r"""
import sys, json

payload = json.load(sys.stdin)
config_path = payload.get("config_path") or "config/memory_config.yaml"

from memory_core.storage.api import MemoryStorage

storage = MemoryStorage.from_config_path(config_path)
storage.initialize()

results = []
for it in payload["entries"]:
    rid = it["rid"]
    try:
        content = it["content"]
        memory_type = it["memory_type"]
        namespace = it.get("namespace") or "global"
        source_project = it.get("source_project")

        response = storage.write_memory({
            "content": content,
            "memory_type": memory_type,
            "namespace": namespace,
            "writer_id": "il-classifier",
            "writer_type": "system",
            "source_project": source_project,
            "confidence": 1.0,
        })

        receipt_id = response.id
        if response.action == "skipped" and response.similar_id:
            receipt_id = response.similar_id

        results.append({"rid": rid, "status": "ok", "id": str(receipt_id), "action": response.action})
    except Exception as e:
        results.append({"rid": rid, "status": "error", "error": type(e).__name__ + ": " + str(e)})

json.dump(results, sys.stdout)
"""

KB_ARCHIVER_SNIPPET = r"""
import sys, json

payload = json.load(sys.stdin)
config_path = payload.get("config_path")

from kb_core.config import load_config
from kb_core.storage.api import KBStorage

config = load_config(config_path) if config_path else load_config()
storage = KBStorage(config)

archived, errors = [], []
for item_id in payload.get("ids", []):
    try:
        ok = storage.update_extraction(extraction_id=item_id, action_state="archived")
        if ok:
            archived.append(item_id)
        else:
            errors.append({"id": item_id, "error": "not found"})
    except Exception as e:
        errors.append({"id": item_id, "error": str(e)})

json.dump({"archived": archived, "errors": errors}, sys.stdout)
"""

MEMORY_ARCHIVER_SNIPPET = r"""
import sys, json

payload = json.load(sys.stdin)
config_path = payload.get("config_path") or "config/memory_config.yaml"
namespace = payload.get("namespace")

from memory_core.storage.api import MemoryStorage

storage = MemoryStorage.from_config_path(config_path)
storage.initialize()

archived, errors = [], []
for mem_id in payload.get("ids", []):
    try:
        result = storage.archive_memory(mem_id, caller_id="il-classifier", namespace=namespace)
        rid = result["id"]
        archived.append(rid if isinstance(rid, str) else str(rid))
    except Exception as e:
        errors.append({"id": mem_id, "error": str(e)})

json.dump({"archived": archived, "errors": errors}, sys.stdout)
"""


# ---------------------------------------------------------------------------
# Orchestration (stdlib only)
# ---------------------------------------------------------------------------

def run_subprocess_json(venv_python, cwd, snippet, payload):
    proc = subprocess.run(
        [venv_python, "-c", snippet],
        input=json.dumps(payload),
        capture_output=True,
        text=True,
        cwd=cwd,
        timeout=SUBPROCESS_TIMEOUT_SECONDS,
    )
    if proc.returncode != 0:
        raise RuntimeError(f"subprocess exited {proc.returncode}: {proc.stderr[-2000:]}")
    try:
        return json.loads(proc.stdout)
    except json.JSONDecodeError as e:
        raise RuntimeError(
            f"subprocess produced non-JSON stdout: {e}; "
            f"stderr={proc.stderr[-1000:]!r}; stdout={proc.stdout[:500]!r}"
        )


def cmd_route(argv):
    items = json.load(sys.stdin)
    force_fail_prefix = os.environ.get("IL_TEST_FORCE_FAIL_PREFIX")
    kb_config_override = os.environ.get("IL_TEST_KB_CONFIG")
    mem_config_override = os.environ.get("IL_TEST_MEMORY_CONFIG")

    kb_items, mem_items, results = [], [], []

    for it in items:
        rid = it["rid"]
        store = it.get("store")
        content = it.get("content", "")

        if force_fail_prefix and content.startswith(force_fail_prefix):
            results.append({"rid": rid, "status": "error", "error": "test-injected failure (IL_TEST_FORCE_FAIL_PREFIX)"})
            continue

        if store == "kb":
            ct = it.get("content_type")
            if ct not in VALID_KB_CONTENT_TYPES:
                results.append({"rid": rid, "status": "error", "error": f"invalid content_type: {ct!r}"})
                continue
            kb_items.append(it)
        elif store == "memory":
            mt = it.get("memory_type")
            if mt not in VALID_MEMORY_TYPES:
                results.append({"rid": rid, "status": "error", "error": f"invalid memory_type: {mt!r}"})
                continue
            mem_items.append(it)
        else:
            results.append({"rid": rid, "status": "error", "error": f"unknown store: {store!r}"})

    if kb_items:
        payload = {"config_path": kb_config_override, "entries": kb_items}
        try:
            results.extend(run_subprocess_json(KB_VENV_PY, KB_REPO, KB_WRITER_SNIPPET, payload))
        except Exception as e:
            for it in kb_items:
                results.append({"rid": it["rid"], "status": "error", "error": f"kb router subprocess failure: {e}"})

    if mem_items:
        payload = {"config_path": mem_config_override, "entries": mem_items}
        try:
            results.extend(run_subprocess_json(MEMORY_VENV_PY, MEMORY_REPO, MEMORY_WRITER_SNIPPET, payload))
        except Exception as e:
            for it in mem_items:
                results.append({"rid": it["rid"], "status": "error", "error": f"memory router subprocess failure: {e}"})

    json.dump(results, sys.stdout)
    return 0


def cmd_archive(argv):
    payload = json.load(sys.stdin)
    kb_config_override = os.environ.get("IL_TEST_KB_CONFIG")
    mem_config_override = os.environ.get("IL_TEST_MEMORY_CONFIG")

    out = {"kb_archived": [], "memory_archived": [], "errors": []}

    kb_ids = payload.get("kb_ids", [])
    if kb_ids:
        try:
            r = run_subprocess_json(KB_VENV_PY, KB_REPO, KB_ARCHIVER_SNIPPET,
                                     {"config_path": kb_config_override, "ids": kb_ids})
            out["kb_archived"] = r.get("archived", [])
            out["errors"].extend(r.get("errors", []))
        except Exception as e:
            out["errors"].append({"store": "kb", "error": str(e)})

    memory_ids = payload.get("memory_ids", [])
    if memory_ids:
        try:
            r = run_subprocess_json(MEMORY_VENV_PY, MEMORY_REPO, MEMORY_ARCHIVER_SNIPPET, {
                "config_path": mem_config_override,
                "ids": memory_ids,
                "namespace": payload.get("memory_namespace", "global"),
            })
            out["memory_archived"] = r.get("archived", [])
            out["errors"].extend(r.get("errors", []))
        except Exception as e:
            out["errors"].append({"store": "memory", "error": str(e)})

    json.dump(out, sys.stdout)
    return 0


def main():
    if len(sys.argv) < 2 or sys.argv[1] not in ("route", "archive"):
        sys.stderr.write("usage: il-router.py {route|archive}\n")
        return 2
    cmd = sys.argv[1]
    if cmd == "route":
        return cmd_route(sys.argv[2:])
    return cmd_archive(sys.argv[2:])


if __name__ == "__main__":
    sys.exit(main())
