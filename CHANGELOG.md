# AWS Changelog

All notable changes to the Agentic Work System governance layer are
logged here. Versioning follows semver. Every change routes through
Forge and references an ADR.

## [1.1.0] — 2026-04-10

### Added
- `/project-doctor` skill — governance audit + autofix for projects
- `workflow-change-detector` UserPromptSubmit hook — routes workflow changes to Forge
- Portfolio baseline audit report (18 projects, `docs/active/baseline-audit-2026-04-09.md`)
- Client template extraction plan (`docs/active/client-template-extraction-plan.md`)
- Bulk conformance fix: 13 files created, 5 modified, 10 dirs across 11 projects

### Changed
- `project-layout.yaml` v1.0.0 → v1.1.0: added `alt_paths: [docs/intent.md]`

### Decision log
- Day 2 of governance activation sprint (ADR-001 continuation)

### Maturity
- Dev-system maturity: 6/10 (Day 1) → 7/10 (Day 2 operational tooling)
- Portfolio conformance: 0% → ~73% (1 clean + 7 minor = 8/11 fix-required at minor-or-better)

## [1.0.0] — 2026-04-09

### Added
- `docs/standards/` populated with initial 4 YAML manifests
- `docs/decisions/` with ADR-001 (AWS governance activation)
- `VERSION` file (1.0.0)
- `CHANGELOG.md` (this file)
- Forge exclusive write-authority rule in global CLAUDE.md

### Changed
- Directory renamed: `_shared/agentic-work-system/` → `_shared/aws/`
  (symlink at old path for reversibility)
- ADF specs folded into `docs/specs/adf/` (symlink at old path)

### Decision log
- ADR-001: AWS governance activation

### Maturity
- Dev-system maturity: 5/10 → 6/10 (structural). Day 2 targets 8/10.
