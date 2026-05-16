#!/usr/bin/env bash
set -euo pipefail

export PATH="$HOME/.elan/bin:$PATH"

./scripts/verify_codex_prereqs.sh

TMP_FILE="/tmp/THM_000001__example_theorem.lean"
cp templates/theorem_candidate.lean "$TMP_FILE"
python3 scripts/validate_theorem.py "$TMP_FILE"
rm -f "$TMP_FILE"

lake update
lake build
lake exe Main

echo "SELF TEST PASSED"
