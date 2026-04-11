#!/usr/bin/env bash
set -euo pipefail

AUTO="ChronoFold/Auto"
UNPROVEN="theorems_unproven"
PROVEN="theorems_proven"
LOG="build.log"

mkdir -p "$AUTO" "$UNPROVEN" "$PROVEN"

for f in "$UNPROVEN"/*.lean; do
  [ -e "$f" ] || continue
  name=$(basename "$f")

  cat > "$AUTO/$name" <<EOF2
import Mathlib
set_option maxHeartbeats 1000000

$(cat "$f")
EOF2
done

if lake build > "$LOG" 2>&1; then
  for f in "$UNPROVEN"/*.lean; do
    [ -e "$f" ] || continue
    mv "$f" "$PROVEN/"
  done
  exit 0
fi

FAILS=$(grep -o 'Auto/[^:]*\.lean' "$LOG" | sort -u || true)

for f in "$UNPROVEN"/*.lean; do
  [ -e "$f" ] || continue
  name=$(basename "$f")
  if ! grep -q "$name" <<< "$FAILS"; then
    mv "$f" "$PROVEN/"
  fi
done

echo "FAILURES:"
echo "$FAILS"
tail -n 50 "$LOG"
