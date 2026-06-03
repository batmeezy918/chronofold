#!/usr/bin/env bash
set -euo pipefail

FILE="${1:-Main.lean}"
BEAM_SIZE=3
MAX_DEPTH=5
RUN_ID="cfpc_branch_$(date +%Y%m%dT%H%M%SZ)"
WORKDIR="./cfpc_runs/$RUN_ID"

mkdir -p "$WORKDIR"

echo "===================================="
echo "CFPC BRANCH SYSTEM (HARD FIXED)"
echo "RUN_ID: $RUN_ID"
echo "TARGET: $FILE"
echo "===================================="

cp "$FILE" "$WORKDIR/root.lean"

########################################
# SAFE LOOP STATE EXPANSION
########################################
shopt -s nullglob

########################################
# ERROR CLASSIFIER
########################################
classify_error() {
  local log="$1"

  if echo "$log" | grep -qi "unknown constant"; then
    echo "MISSING_IMPORT"
  elif echo "$log" | grep -qi "unsolved goals"; then
    echo "INCOMPLETE_TACTIC"
  elif echo "$log" | grep -qi "type mismatch"; then
    echo "TYPE_CONFLICT"
  else
    echo "OTHER"
  fi
}

########################################
# BRANCH EXPANDER
########################################
expand() {
  local file="$1"
  local outdir="$2"

  mkdir -p "$outdir"

  # Branch A: raw
  cp "$file" "$outdir/a.lean"

  # Branch B: simp attempt
  cp "$file" "$outdir/b.lean"
  echo "" >> "$outdir/b.lean"
  echo "by simp" >> "$outdir/b.lean"

  # Branch C: aesop attempt
  cp "$file" "$outdir/c.lean"
  echo "" >> "$outdir/c.lean"
  echo "by aesop" >> "$outdir/c.lean"
}

########################################
# LEAN RUNNER
########################################
run_lean() {
  lake env lean "$1" 2>&1
  return $?
}

########################################
# INITIAL STATE
########################################
PREVS=( "$WORKDIR/root.lean" )

########################################
# BEAM SEARCH
########################################
for depth in $(seq 1 "$MAX_DEPTH"); do

  echo ""
  echo "================ DEPTH $depth ================"

  NEXT_DIR="$WORKDIR/depth_$depth"
  mkdir -p "$NEXT_DIR"

  BEST_SCORE=-1
  BEST_FILE=""

  # expand all previous states safely
  for prev in "${PREVS[@]}"; do

    expand "$prev" "$NEXT_DIR"

    for cand in "$NEXT_DIR"/*.lean; do

      OUT=$(run_lean "$cand")
      CODE=$?

      if [ "$CODE" -eq 0 ]; then
        echo ""
        echo "✔ PROOF FOUND"
        echo "FILE: $cand"
        exit 0
      fi

      ERR=$(classify_error "$OUT")

      SCORE=0
      case "$ERR" in
        INCOMPLETE_TACTIC) SCORE=3 ;;
        TYPE_CONFLICT) SCORE=2 ;;
        MISSING_IMPORT) SCORE=1 ;;
        *) SCORE=0 ;;
      esac

      if [ "$SCORE" -gt "$BEST_SCORE" ]; then
        BEST_SCORE="$SCORE"
        BEST_FILE="$cand"
      fi

    done
  done

  echo "BEST AT DEPTH $depth: $BEST_FILE (score=$BEST_SCORE)"

  PREVS=( "$BEST_FILE" )

done

echo ""
echo "✘ FAILED: no proof found in search space"
exit 1
