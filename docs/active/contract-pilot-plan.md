---
title: Per-Project Contract Pilot Plan
type: pilot-plan
status: draft
created: 2026-05-25
owner: forge
related:
  - docs/decisions/ADR-007-agent-org-charter-ratification.md
  - docs/standards/project-layout.yaml
  - docs/active/per-project-contract-proposal.md
---

# Per-Project Contract Pilot Plan

Pilot for ADR-007 R10: apply the full per-project contract (R1–R10) to 2-3 projects before
standardizing. This doc identifies the pilots, explains the selection rationale, and defines
the pilot scope. Forge executes after Jesse approves the selection.

> **Status: DRAFT — awaiting Jesse approval before modifying any pilot project.**

---

## Selection rationale

The charter calls for a mix: one `_shared` component, one client, one sandbox. The selection
criteria: (a) clean-enough working tree to pilot without entangling other debt; (b) active
enough to validate the contract under real agent use; (c) distinct enough to surface any
contract brittleness across project types.

---

## Recommended pilots

### Pilot 1 — `_shared` component: `capabilities-registry`

**Path:** `/Users/jessepike/code/_shared/capabilities-registry`
**Owner (pre-pilot):** Forge
**Why:**
- Forge-owned, so Forge has write authority without routing approval.
- Has `CLAUDE.md` already — adding the `owner:` frontmatter field and `@AGENTS.md` import
  is low-risk surgery.
- No `AGENTS.md` currently — creating it is the primary pilot deliverable.
- No `decisions.md` — adding it tests the R3 requirement on a real substrate project.
- Active registry work means the contract gets exercised under real conditions quickly.
- Clean working tree per portfolio-map sweep.

**Contract gaps to close:**
- Create `AGENTS.md` as canonical context source.
- Update `CLAUDE.md` to import `@AGENTS.md` + add `owner: forge` in frontmatter.
- Add `decisions.md` at root.
- Add resolver entry in portfolio-map with all 7 R5 fields.
- Verify `status.md` freshness (should exist; confirm updated within 30 days).

---

### Pilot 2 — Client project: `krypton`

**Path:** `/Users/jessepike/code/_shared/krypton`
**Owner (pre-pilot):** Krypton
**Why:**
- Krypton is both the chief-of-staff agent AND a real project with active agent use — the
  contract will be exercised on every orient. If the contract works here, it works anywhere.
- Has `CLAUDE.md` (no owner: frontmatter), `BACKLOG.md`, `decisions.md`, `lessons.md`,
  `status.md` — most of the required artifacts already exist.
- No `AGENTS.md` currently — this is the key pilot deliverable.
- Active enough that agents land here regularly; stale contract would surface immediately.
- Owner is Krypton (not Forge), so this tests the contract on a non-Forge-owned project
  and validates the ownership declaration + resolver pattern under a different owner.

**Note:** Krypton's write authority means Forge handles the AGENTS.md/CLAUDE.md surgery;
owner field names `krypton`. Krypton reviews and approves changes before Forge commits.

**Contract gaps to close:**
- Create `AGENTS.md` as canonical context source (adapt CLAUDE.md content).
- Update `CLAUDE.md` to import `@AGENTS.md` + add `owner: krypton` in frontmatter.
- Confirm `decisions.md` at root or `docs/decisions.md` exists and is active.
- Add resolver entry in portfolio-map with all 7 R5 fields.
- Verify `status.md` freshness.

---

### Pilot 3 — Sandbox/internal: `capabilities-registry` is already Pilot 1 above.
### Pilot 3 — AWS governance itself

**Path:** `/Users/jessepike/code/_shared/aws`
**Owner (pre-pilot):** Krypton + Forge (governance project)
**Why:**
- Meta-project: if the contract describes itself correctly, it proves the model works
  end-to-end. The governance project applying its own standard is a strong signal.
- Has `CLAUDE.md` (project instructions), `docs/decisions/`, `docs/active/`, `BACKLOG.md`.
- No `AGENTS.md` currently — needs to be created.
- `CLAUDE.md` has no `owner:` frontmatter field.
- Clean working tree; actively used by Forge and Krypton.
- Validates the contract on a Forge+Krypton co-owned project — the most common ownership
  pattern for governance work.

**Contract gaps to close:**
- Create `AGENTS.md` as canonical context (adapt `.claude/CLAUDE.md` project content).
- Update root `CLAUDE.md` and `.claude/CLAUDE.md` to import `@AGENTS.md` + `owner: forge`.
- Verify `status.md` exists at `docs/status.md` and is fresh.
- Add/update resolver entry in portfolio-map with all 7 R5 fields.

---

## Execution sequence

Apply in order (not in parallel) to catch contract brittleness early:

1. **capabilities-registry** (Pilot 1) — simplest, Forge-owned, no approval routing.
2. **aws** (Pilot 3) — Forge applies to its own governance project; validates reflexivity.
3. **krypton** (Pilot 2) — non-Forge owner; validates cross-owner delegation pattern.

---

## Success criteria

After all three pilots, the contract is proven if:
- All 7 R5 resolver fields are populated and accurate for each project.
- Agents landing in each project can orient correctly using `AGENTS.md` without reading `CLAUDE.md` for project context.
- `CLAUDE.md` correctly imports `@AGENTS.md` and adds only Claude-specific rules.
- `owner:` field in `CLAUDE.md` frontmatter matches portfolio-map resolver entry.
- `decisions.md` exists and has at least one entry.
- `status.md` is within 30 days.
- No regressions: existing agent workflows (Krypton orient, Forge build, Codex sessions) continue to work.

---

## What is NOT in pilot scope

- Modifying any other project (R10: pilot first, then fold into standard).
- Changing ownership assignments beyond declaring the known owner (R7 rubric work is separate).
- Wiring freshness enforcement jobs (R6 enforcement is a follow-on).
- Applying to client projects outside the _shared stack (depends on pilot learnings).

---

## Next step

Jesse approves or modifies pilot selection → Forge executes pilot 1 in its own session.
