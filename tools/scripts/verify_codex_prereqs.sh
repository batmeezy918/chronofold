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
