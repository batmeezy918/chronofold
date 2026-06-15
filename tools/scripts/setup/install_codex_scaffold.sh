#!/usr/bin/env bash
set -euo pipefail

mkdir -p .github/workflows docs scripts templates theorems_inbox theorems_checked theorems_proven theorems_rejected theorem_receipts logs

cat > AGENTS.md <<'EOT'
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
EOT

cat > codex_prompt.txt <<'EOT'
Read AGENTS.md first and obey it fully.

Goal:
Build and harden a deterministic theorem-intake pipeline for this repo.

Create and verify all of the following:
- scripts/validate_theorem.py
- scripts/process_inbox.sh
- scripts/self_test_pipeline.sh
- .github/workflows/build.yml
- .github/workflows/theorem-intake.yml
- .github/workflows/pages.yml
- templates/theorem_candidate.lean
- docs/index.html
- docs/theorem_ui_contract.md
- theorems_inbox/README.md

Requirements:
1. scripts/process_inbox.sh must export PATH="$HOME/.elan/bin:$PATH".
2. Create one guaranteed smoke theorem:
   theorems_inbox/THM_000001__smoke_test.lean
3. The smoke theorem must compile in the current repo state.
4. Add deterministic validation rules:
   - filename THM_######__name.lean
   - one theorem per file
   - theorem name must match filename
   - reject sorry/admit/axiom/unsafe
5. Add a self-test script that runs:
   - theorem validation
   - inbox processing
   - find theorems_proven theorems_rejected theorem_receipts logs -maxdepth 1 -type f | sort
   - lake build
   - lake exe Main
6. If something fails, inspect logs and fix the repo until it passes.
7. Replace docs/index.html with a static GitHub Pages-compatible theorem UI.
8. Commit all changes in one clean commit.
9. Leave the worktree clean.
EOT

cat > scripts/verify_codex_prereqs.sh <<'EOT'
#!/usr/bin/env bash
set -euo pipefail

echo "repo: $(pwd)"
echo "lean: $(command -v lean || true)"
echo "lake: $(command -v lake || true)"
echo "python3: $(command -v python3 || true)"
echo "git: $(command -v git || true)"

test -f lean-toolchain
test -f lakefile.lean
test -f Main.lean

echo "PREREQS OK"
EOT
chmod +x scripts/verify_codex_prereqs.sh

cat > theorems_inbox/THM_000001__smoke_test.lean <<'EOT'
import Verify

/--
THEOREM_ID: THM_000001
TITLE: smoke_test
AUTHOR: user
STATUS: candidate
-/

theorem smoke_test : 1 + 1 = 2 := by
  decide
EOT

echo "SCAFFOLD COMPLETE"
