#!/usr/bin/env bash
set -euo pipefail

FILE="${1:-cfpc_branch.sh}"

echo "===================================="
echo "CFPC-H HARDENED RUNTIME"
echo "FILE: $FILE"
echo "===================================="

########################################
# 1. SYNTAX VALIDATION LAYER
########################################
echo "[1] Bash syntax check..."

if ! bash -n "$FILE"; then
  echo "✘ SYNTAX ERROR: script is not valid bash"
  exit 2
fi

echo "✔ Bash syntax OK"

########################################
# 2. LOOP SAFETY CHECK (CFPC GUARD)
########################################
echo "[2] CFPC structural validation..."

if grep -nE "for .*; do$" "$FILE" >/dev/null; then
  echo "✘ UNSAFE LOOP DETECTED (missing safe array expansion)"
  echo "Fix required: use PREVS=(...) style iteration"
  exit 3
fi

if grep -n "while true; do" "$FILE" >/dev/null; then
  echo "✔ while-loop detected (allowed)"
fi

########################################
# 3. HEREDOC VALIDATION
########################################
echo "[3] heredoc sanity check..."

if grep -n "EOF" "$FILE" | wc -l | grep -q "1"; then
  echo "⚠ WARNING: possible unterminated heredoc risk"
fi

########################################
# 4. EXECUTION PHASE
########################################
echo "[4] executing CFPC..."

bash "$FILE"

echo "===================================="
echo "CFPC-H COMPLETE"
echo "===================================="
