#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob

FILE="${1:-Main.lean}"
MAX_DEPTH=6

RUN_ID="cfpc_machine_$(date +%Y%m%dT%H%M%SZ)"
WORKDIR="./cfpc_runs/$RUN_ID"

mkdir -p "$WORKDIR"

echo "===================================="
echo "CFPC MACHINE PROVER (HARDENED)"
echo "RUN_ID: $RUN_ID"
echo "TARGET: $FILE"
echo "===================================="

cp "$FILE" "$WORKDIR/root.lean"

########################################
# LEAN RUNNER (FORCED OUTPUT)
########################################
run_lean() {
  lake env lean "$1" 2>&1
}

########################################
# SAFE EXPAND (NO SILENT FAILURES)
########################################
expand() {
  local file="$1"
  local outdir="$2"

  mkdir -p "$outdir"

  cp "$file" "$outdir/a.lean"

  cp "$file" "$outdir/b.lean"
  printf "\n-- CFPC SIMP\nby simp\n" >> "$outdir/b.lean"

  cp "$file" "$outdir/c.lean"
  printf "\n-- CFPC AESOP\nby aesop\n" >> "$outdir/c.lean"

  # HARD INVARIANT: must exist
  local count
  count=$(ls "$outdir"/*.lean 2>/dev/null | wc -l)

  if [ "$count" -eq 0 ]; then
    echo "✘ FATAL: expansion produced no candidates"
    exit 1
  fi
}

########################################
# CLASSIFIER
########################################
classify() {
  local log="$1"

  if echo "$log" | grep -qi "unknown constant"; then
    echo "MISSING_IMPORT"
  elif echo "$log" | grep -qi "unsolved goals"; then
    echo "INCOMPLETE"
  elif echo "$log" | grep -qi "type mismatch"; then
    echo "TYPE_ERROR"
  else
    echo "OTHER"
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
  # EXPAND STATE (STRICT)
  ########################################
  for p in "${PREVS[@]}"; do
    expand "$p" "$NEXT"
  done

  ########################################
  # COLLECT CANDIDATES (STRICT CHECK)
  ########################################
  CANDS=( "$NEXT"/*.lean )

  if [ ${#CANDS[@]} -eq 0 ] || [ ! -e "${CANDS[0]}" ]; then
    echo "✘ FATAL: NO CANDIDATES GENERATED"
    echo "DIR: $NEXT"
    ls -la "$NEXT" || true
    exit 1
  fi

  BEST=""
  BEST_SCORE=-1

  ########################################
  # EVALUATE
  ########################################
  for c in "${CANDS[@]}"; do

    echo ""
    echo "----- EXECUTING: $c -----"

    OUT=$(run_lean "$c")
    CODE=$?

    echo "$OUT"

    if [ "$CODE" -eq 0 ]; then
      echo ""
      echo "===================================="
      echo "✔ PROOF FOUND"
      echo "FILE: $c"
      echo "===================================="
      exit 0
    fi

    ERR=$(classify "$OUT")

    SCORE=0
    case "$ERR" in
      INCOMPLETE) SCORE=3 ;;
      TYPE_ERROR) SCORE=2 ;;
      MISSING_IMPORT) SCORE=1 ;;
      *) SCORE=0 ;;
    esac

    if [ "$SCORE" -gt "$BEST_SCORE" ]; then
      BEST_SCORE="$SCORE"
      BEST="$c"
    fi

  done

  echo ""
  echo "BEST AT DEPTH $depth: $BEST (score=$BEST_SCORE)"

  ########################################
  # STRICT PRUNING (NO EMPTY STATE ALLOWED)
  ########################################
  if [ -z "$BEST" ]; then
    echo "✘ FATAL: NO VALID BEST STATE"
    exit 1
  fi

  PREVS=( "$BEST" )

done

echo ""
echo "✘ FAILED: no proof found in search space"
exit 1
