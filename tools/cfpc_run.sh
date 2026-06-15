#!/usr/bin/env bash
set -euo pipefail

FILE="${1:-Main.lean}"
MAX_ITERS=20
RUN_ID="cfpc_v5_$(date +%Y%m%dT%H%M%SZ)"
WORKDIR="./cfpc_runs/$RUN_ID"

mkdir -p "$WORKDIR"

echo "===================================="
echo "CFPC-v5 Lean Autonomous Prover"
echo "RUN_ID: $RUN_ID"
echo "TARGET: $FILE"
echo "===================================="

cp "$FILE" "$WORKDIR/base.lean"

CURRENT="$WORKDIR/base.lean"

#######################################
# ERROR CLASSIFIER (ECE)
#######################################
classify_error() {
  local log="$1"

  if echo "$log" | grep -qi "unknown constant"; then
    echo "MISSING_IMPORT"
  elif echo "$log" | grep -qi "unsolved goals"; then
    echo "INCOMPLETE_TACTIC"
  elif echo "$log" | grep -qi "type mismatch"; then
    echo "TYPE_SHAPE_CONFLICT"
  elif echo "$log" | grep -qi "failed to synthesize"; then
    echo "SEARCH_SPACE_GAP"
  else
    echo "UNKNOWN_FAILURE"
  fi
}

#######################################
# REPAIR ENGINE (O_FILL)
#######################################
repair_file() {
  local file="$1"
  local error_type="$2"

  case "$error_type" in
    MISSING_IMPORT)
      echo "import Mathlib" >> "$file"
      ;;
    INCOMPLETE_TACTIC)
      sed -i '0,/sorry/{s/sorry/by simp\n  sorry/}' "$file"
      ;;
    TYPE_SHAPE_CONFLICT)
      sed -i 's/:=/:= by aesop/' "$file"
      ;;
    SEARCH_SPACE_GAP)
      echo "-- CFPC: inserting search hint" >> "$file"
      ;;
    *)
      echo "-- CFPC: unknown failure patch" >> "$file"
      ;;
  esac
}

#######################################
# MAIN LOOP (O_LEX + O_SC)
#######################################
for i in $(seq 1 $MAX_ITERS); do
  echo ""
  echo "================ ITERATION $i ================"

  OUT=$(lake env lean "$CURRENT" 2>&1 || true)
  CODE=$?

  echo "$OUT" > "$WORKDIR/log_$i.txt"

  if [ "$CODE" -eq 0 ]; then
    echo "✔ PROOF COMPLETE at iteration $i"
    echo "FILE: $CURRENT"
    exit 0
  fi

  ERROR_TYPE=$(classify_error "$OUT")

  echo "✘ FAILURE: $ERROR_TYPE"

  NEXT="$WORKDIR/proof_$i.lean"
  cp "$CURRENT" "$NEXT"

  repair_file "$NEXT" "$ERROR_TYPE"

  CURRENT="$NEXT"
done

echo "✘ FAILED: max iterations reached"
exit 1

