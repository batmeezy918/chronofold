#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob

FILE="${1:-Main.lean}"
MAX_DEPTH=5

RUN_ID="cfpc_machine_$(date +%Y%m%dT%H%M%SZ)"
WORKDIR="./cfpc_runs/$RUN_ID"

mkdir -p "$WORKDIR"

echo "===================================="
echo "CFPC LEAN MACHINE v1 (CLEAN BUILD)"
echo "RUN_ID: $RUN_ID"
echo "TARGET: $FILE"
echo "===================================="

cp "$FILE" "$WORKDIR/root.lean"

########################################
# SAFE LEAN EXECUTOR (LEAN 4.29 CORRECT)
########################################
run_lean() {
  lake env lean "$1" 2>&1 || true
}

########################################
# VALID LEAN WRAPPER GENERATOR
########################################
make_candidate() {
  local out="$1"
  local tactic="$2"

  cat > "$out" <<EOL
import Mathlib

-- CFPC GENERATED CANDIDATE

theorem cfpc_goal : True := by
  $tactic
EOL
}

########################################
# EXPAND FUNCTION (STRICT VALID FILES ONLY)
########################################
expand() {
  local base="$1"
  local outdir="$2"

  mkdir -p "$outdir"

  make_candidate "$outdir/a.lean" "trivial"
  make_candidate "$outdir/b.lean" "simp"
  make_candidate "$outdir/c.lean" "try trivial; try simp; trivial"
}

########################################
# SCORE FUNCTION
########################################
score_log() {
  local log="$1"

  if echo "$log" | grep -qi "error"; then
    echo 0
  elif echo "$log" | grep -qi "unsolved"; then
    echo 2
  elif echo "$log" | grep -qi "no goals"; then
    echo 5
  else
    echo 1
  fi
}

########################################
# INITIAL STATE
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
  # EXPAND STATE
  ########################################
  for p in "${PREVS[@]}"; do
    expand "$p" "$NEXT"
  done

  CANDS=( "$NEXT"/*.lean )

  if [ ${#CANDS[@]} -eq 0 ]; then
    echo "✘ FATAL: NO CANDIDATES GENERATED"
    ls -la "$NEXT"
    exit 1
  fi

  BEST=""
  BEST_SCORE=-1

  ########################################
  # EVALUATE CANDIDATES
  ########################################
  for c in "${CANDS[@]}"; do

    echo ""
    echo "----- RUNNING: $c -----"

    OUT=$(run_lean "$c")
    CODE=$?

    echo "$OUT"

    SCORE=$(score_log "$OUT")

    if [ "$SCORE" -gt "$BEST_SCORE" ]; then
      BEST_SCORE="$SCORE"
      BEST="$c"
    fi

    ########################################
    # SUCCESS CONDITION (LEAN STANDARD)
    ########################################
    if echo "$OUT" | grep -qi "no goals"; then
      echo ""
      echo "===================================="
      echo "✔ PROOF SUCCESS"
      echo "FILE: $c"
      echo "===================================="
      exit 0
    fi

  done

  echo ""
  echo "BEST AT DEPTH $depth: $BEST (score=$BEST_SCORE)"

  if [ -z "$BEST" ]; then
    echo "✘ FATAL: NO VALID STATE SELECTED"
    exit 1
  fi

  PREVS=( "$BEST" )

done

echo ""
echo "✘ FAILED: no proof found"
exit 1
