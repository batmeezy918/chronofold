# AGENTS.md

## Repo purpose
ChronoFold is a Lean-based theorem and verification repository.

## Mission
Build a deterministic theorem-intake pipeline with:
- scripts/validate_theorem.py
- scripts/process_inbox.sh
- scripts/self_test_pipeline.sh
- .github/workflows/build.yml
- .github/workflows/theorem-intake.yml
- .github/workflows/pages.yml
- templates/theorem_candidate.lean
- docs/index.html
- docs/theorem_ui_contract.md

## Required setup
Before changes, ensure:
- Lean/Lake available on PATH
- export PATH="$HOME/.elan/bin:$PATH"

## Hard rules
- Do not write directly into theorems_proven/
- Only promote theorem files through scripts/process_inbox.sh
- Prefer minimal deterministic patches
- Leave worktree clean

## Success criteria
A successful task must leave:
- local verification passing
- lake build passing
- lake exe Main passing
- worktree clean
