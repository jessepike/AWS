# ADF Stubs

Minimal starter files for `init-project.sh`. These are NOT templates — they're bare scaffolds that agents flesh out per specs.

## Contents

| File | Purpose | Spec Reference |
|------|---------|----------------|
| intent.md | Intent stub | ADF-INTENT-SPEC.md |
| brief.md | Brief stub | ADF-BRIEF-SPEC.md |
| status.md | Status stub | ADF-STATUS-SPEC.md |
| claude-md/ | CLAUDE.md stubs by type | ADF-PROJECT-CLAUDE-MD-SPEC.md |
| agents/ | AGENTS.md stubs by type | ADF-CODEX-COMPAT-SPEC.md |
| rules-constraints.md | Rules stub (→ `.claude/rules/constraints.md`) | ADF-RULES-SPEC.md |

## Usage

These files are copied by `init-project.sh` during project initialization. Agents then populate them according to the relevant specs.

## Note

Per ADF design decision: Agents generate content from specs, not templates. These stubs provide minimal structure; specs define requirements.
