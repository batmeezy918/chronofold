#!/usr/bin/env bash
set -euo pipefail

FILE="${1:-Main.lean}"
MAX_DEPTH=6

RUN_ID="cfpc_v7_$(date +%Y%m%dT%H%M%SZ)"
WORKDIR="./cfpc_runs/$RUN_ID"

mkdir -p "$WORKDIR"

echo "===================================="
echo "CFPC-v7 SEMANTIC PROVER"
echo "RUN_ID: $RUN_ID"
echo "TARGET: $FILE"
echo "===================================="

cp "$FILE" "$WORKDIR/root.lean"

########################################
# SEMANTIC GOAL INSPECTOR (LIGHTWEIGHT)
########################################
extract_goal_hint() {
  local log="$1"

  if echo "$log" | grep -qi "⊢.*="; then
    echo "EQUALITY"
  elif echo "$log" | grep -qi "⊢.*∑\|sum"; then
    echo "SUM"
  elif echo "$log" | grep -qi "⊢.*∀"; then
    echo "UNIVERSAL"
  elif echo "$log" | grep -qi "⊢.*∃"; then
    echo "EXISTS"
  else
    echo "GENERIC"
  fi
}

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
# SEMANTIC BRANCH GENERATOR
########################################
expand() {
  local file="$1"
  local outdir="$2"
  local hint="$3"

  mkdir -p "$outdir"

  cp "$file" "$outdir/a.lean"

  case "$hint" in

    EQUALITY)
      cp "$file" "$outdir/b.lean"
      echo "by simp" >> "$outdir/b.lean"

      cp "$file" "$outdir/c.lean"
      echo "by ring" >> "$outdir/c.lean"
      ;;

    SUM)
      cp "$file" "$outdir/b.lean"
      echo "by simp [Finset.sum_range_succ]" >> "$outdir/b.lean"

      cp "$file" "$outdir/c.lean"
      echo "by induction" >> "$outdir/c.lean"
      ;;

    UNIVERSAL)
      cp "$file" "$outdir/b.lean"
      echo "by intro" >> "$outdir/b.lean"

      cp "$file" "$outdir/c.lean"
      echo "by aesop" >> "$outdir/c.lean"
      ;;

    EXISTS)
      cp "$file" "$outdir/b.lean"
      echo "by use" >> "$outdir/b.lean"

      cp "$file" "$outdir/c.lean"
      echo "by aesop" >> "$outdir/c.lean"
      ;;

    *)
      cp "$file" "$outdir/b.lean"
      echo "by simp" >> "$outdir/b.lean"

      cp "$file" "$outdir/c.lean"
      echo "by aesop" >> "$outdir/c.lean"
      ;;
  esac
}

########################################
# LEAN RUNNER
########################################
run_lean() {
  lake env lean "$1" 2>&1
  return $?
}

########################################
# STATE INIT
########################################
PREVS=( "$WORKDIR/root.lean" )

########################################
# BEAM SEARCH LOOP
########################################
for depth in $(seq 1 "$MAX_DEPTH"); do

  echo ""
  echo "================ DEPTH $depth ================"

  NEXT_DIR="$WORKDIR/depth_$depth"
  mkdir -p "$NEXT_DIR"

  BEST_SCORE=-1
  BEST_FILE=""
  BEST_HINT=""

  for prev in "${PREVS[@]}"; do

    OUT=$(run_lean "$prev")
    CODE=$?

    if [ "$CODE" -eq 0 ]; then
      echo ""
      echo "===================================="
      echo "✔ PROOF FOUND"
      echo "FILE: $prev"
      echo "===================================="
      exit 0
    fi

    HINT=$(extract_goal_hint "$OUT")
    ERR=$(classify_error "$OUT")

    expand "$prev" "$NEXT_DIR" "$HINT"

  done

  CANDS=( "$NEXT_DIR"/*.lean )

  if [ ${#CANDS[@]} -eq 0 ]; then
    echo "✘ NO CANDIDATES GENERATED"
    exit 1
  fi

  for cand in "${CANDS[@]}"; do

    OUT=$(run_lean "$cand")
    CODE=$?

    if [ "$CODE" -eq 0 ]; then
      echo ""
      echo "===================================="
      echo "✔ PROOF FOUND"
      echo "FILE: $cand"
      echo "===================================="
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

  echo "BEST AT DEPTH $depth: $BEST_FILE (score=$BEST_SCORE)"

  PREVS=( "$BEST_FILE" )

done

echo ""
echo "✘ FAILED: no proof found"
exit 1
