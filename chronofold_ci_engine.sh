#!/usr/bin/env bash
set -euo pipefail

AUTO="ChronoFold/Auto"
UNPROVEN="theorems_unproven"
PROVEN="theorems_proven"
LOG="build.log"

########################################
# INJECT
########################################

for f in "$UNPROVEN"/*.lean; do
  [ -e "$f" ] || continue

  name=$(basename "$f")

  cat > "$AUTO/$name" <<EOF
import Mathlib
set_option maxHeartbeats 1000000

$(cat "$f")
EOF

done

########################################
# BUILD
########################################

if lake build > "$LOG" 2>&1; then
  echo "[✓] ALL PROVEN"

  for f in "$UNPROVEN"/*.lean; do
    [ -e "$f" ] || continue
    mv "$f" "$PROVEN/"
  done

  exit 0
fi

########################################
# ANALYZE FAILURES
########################################

FAILS=$(grep -o 'Auto/[^:]*\.lean' "$LOG" | sort -u || true)

########################################
# PROMOTE SUCCESS
########################################

for f in "$UNPROVEN"/*.lean; do
  [ -e "$f" ] || continue

  name=$(basename "$f")

  if ! grep -q "$name" <<< "$FAILS"; then
    mv "$f" "$PROVEN/"
  fi
done

########################################
# OUTPUT FAILURES (for Codex)
########################################

echo "FAILURES:"
echo "$FAILS"

tail -n 50 "$LOG"
