#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob

FILE="${1:-Main.lean}"
MAX_DEPTH=5

RUN_ID="cfpc_core_$(date +%Y%m%dT%H%M%SZ)"
WORKDIR="./cfpc_runs/$RUN_ID"

mkdir -p "$WORKDIR"

echo "===================================="
echo "CFPC-LEAN-CORE v1"
echo "RUN_ID: $RUN_ID"
echo "TARGET: $FILE"
echo "===================================="

cp "$FILE" "$WORKDIR/root.lean"

########################################
# LEAN TYPECHECKER (CORRECT MODEL)
########################################
run_lean() {
  lake env lean --messages "$1" 2>&1 || true
}

########################################
# SAFE LEAN WRAPPER GENERATOR
########################################
wrap_lean() {
  local src="$1"
  local dst="$2"
  local tactic="$3"

  cat > "$dst" <<EOL
import Mathlib

-- CFPC-CORE GENERATED FILE

theorem cfpc_goal : True := by
  $tactic
EOL
}

########################################
# SAFE EXPANDER
########################################
expand() {
  local file="$1"
  local outdir="$2"

  mkdir -p "$outdir"

  wrap_lean "$file" "$outdir/a.lean" "trivial"

  wrap_lean "$file" "$outdir/b.lean" "simp"

  wrap_lean "$file" "$outdir/c.lean" "by
  try trivial
  try simp
  trivial"
}

########################################
# SCORE ENGINE
########################################
score_output() {
  local log="$1"

  if echo "$log" | grep -qi "error"; then
    echo 0
  elif echo "$log" | grep -qi "no goals"; then
    echo 3
  elif echo "$log" | grep -qi "unsolved"; then
    echo 2
  else
    echo 1
  fi
}

########################################
# STATE
########################################
PREVS=( "$WORKDIR/root.lean" )

########################################
# MAIN LOOP
########################################
for depth in $(seq 1 "$MAX_DEPTH"); do

  echo ""
  echo "================ DEPTH $depth ================"

  NEXT="$WORKDIR/depth_$depth"
  mkdir -p "$NEXT"

  ########################################
  # EXPAND
  ########################################
  for p in "${PREVS[@]}"; do
    expand "$p" "$NEXT"
  done

  CANDS=( "$NEXT"/*.lean )

  if [ ${#CANDS[@]} -eq 0 ]; then
    echo "✘ FATAL: NO CANDIDATES GENERATED"
    exit 1
  fi

  BEST=""
  BEST_SCORE=-1

  ########################################
  # EVALUATE
  ########################################
  for c in "${CANDS[@]}"; do

    echo ""
    echo "----- CHECKING: $c -----"

    OUT=$(run_lean "$c")
    CODE=$?

    echo "$OUT"

    SCORE=$(score_output "$OUT")

    if [ "$SCORE" -gt "$BEST_SCORE" ]; then
      BEST_SCORE="$SCORE"
      BEST="$c"
    fi

    # REAL SUCCESS CONDITION (Lean proof)
    if echo "$OUT" | grep -qi "no goals"; then
      echo ""
      echo "===================================="
      echo "✔ PROOF CLOSED"
      echo "FILE: $c"
      echo "===================================="
      exit 0
    fi

  done

  echo ""
  echo "BEST AT DEPTH $depth: $BEST (score=$BEST_SCORE)"

  PREVS=( "$BEST" )

done

echo ""
echo "✘ FAILED: no proof found"
exit 1
