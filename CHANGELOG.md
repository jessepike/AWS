# AWS Changelog

All notable changes to the Agentic Work System governance layer are
logged here. Versioning follows semver. Every change routes through
Forge and references an ADR.

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
