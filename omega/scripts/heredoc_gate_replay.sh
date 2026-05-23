#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

export LC_ALL=C
export TZ=UTC

ROOT="${1:-$PWD}"
TARGET="$ROOT/omega/theorems/HeredocRepro.lean"
HASHFILE="$ROOT/omega/snapshots/heredoc_gate.sha256"

if [ ! -f "$TARGET" ]; then
  echo "[OMEGA_HEREDOC_REPLAY][FAIL] missing target: $TARGET"
  exit 1
fi

if [ ! -f "$HASHFILE" ]; then
  echo "[OMEGA_HEREDOC_REPLAY][FAIL] missing hashfile: $HASHFILE"
  exit 1
fi

CURRENT="$(sha256sum "$TARGET" | awk '{print $1}')"
EXPECTED="$(cat "$HASHFILE" | awk '{print $1}')"

echo "[OMEGA_HEREDOC_REPLAY][INFO] expected=$EXPECTED"
echo "[OMEGA_HEREDOC_REPLAY][INFO] current=$CURRENT"

if [ "$CURRENT" = "$EXPECTED" ]; then
  echo "[OMEGA_HEREDOC_REPLAY][PASS] replay hash stable"
  exit 0
else
  echo "[OMEGA_HEREDOC_REPLAY][FAIL] replay hash mismatch"
  exit 2
fi
