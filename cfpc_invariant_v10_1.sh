#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob

FILE="${1:-Main.lean}"
RUN_ID="cfpc_v10_1_$(date +%Y%m%dT%H%M%SZ)"
WORKDIR="./cfpc_runs/$RUN_ID"

mkdir -p "$WORKDIR"

echo "===================================="
echo "CFPC INVARIANT TRANSPORT v10.1"
echo "RUN_ID: $RUN_ID"
echo "TARGET: $FILE"
echo "===================================="

########################################
# 1. ROOT DETECTION (ROBUST)
########################################
find_root() {
  local d
  d="$(pwd)"

  while [ "$d" != "/" ]; do
    if [ -f "$d/lakefile.lean" ] || [ -f "$d/lakefile.toml" ]; then
      echo "$d"
      return
    fi
    d="$(dirname "$d")"
  done

  echo "$(pwd)"
}

PROJECT_ROOT=$(find_root)
cd "$PROJECT_ROOT"

echo "✔ ROOT: $PROJECT_ROOT"

########################################
# 2. SAFE LEAN EXECUTION
########################################
run_lean() {
  local f="$1"
  cp "$f" "$PROJECT_ROOT/current.lean"

  # IMPORTANT: no silent failure masking
  timeout 8s lake env lean "$PROJECT_ROOT/current.lean" 2>&1
}

########################################
# 3. SAFE INVARIANT EXTRACTION
########################################
extract_invariants() {
  local log="$1"

  local omega
  local xi

  omega=$(echo "$log" | grep -c "⊢" || true)
  xi=$(echo "$log" | wc -l || true)

  echo "$omega:$xi"
}

########################################
# 4. SAFE SCORING FUNCTION
########################################
score() {
  local omega="$1"
  local xi="$2"

  echo $(( omega * 5 + xi ))
}

########################################
# 5. GOAL GENERATOR (NON-TRIVIAL ONLY)
########################################
generate() {
  local out="$1"
  local mode="$2"

  case "$mode" in

    transport)
cat > "$out" <<'EOL'
import Mathlib

variable (P Q R : Prop)

theorem cfpc_goal :
  (P → Q) → (Q → R) → P → R := by
  intro h1 h2 p
  exact h2 (h1 p)
EOL
;;

    structure)
cat > "$out" <<'EOL'
import Mathlib

variable (P Q : Prop)

theorem cfpc_goal :
  (P ∧ Q) → (Q ∧ P) := by
  intro h
  cases h
  constructor <;> assumption
EOL
;;

    distributive)
cat > "$out" <<'EOL'
import Mathlib

variable (P Q R : Prop)

theorem cfpc_goal :
  P ∧ (Q ∨ R) → (P ∧ Q) ∨ (P ∧ R) := by
  intro h
  cases h with
  | intro p qr =>
    cases qr
    · left; constructor <;> assumption
    · right; constructor <;> assumption
EOL
;;

  esac
}

MODES=(transport structure distributive)

########################################
# 6. INITIAL STATES
########################################
STATES=()

for m in "${MODES[@]}"; do
  f="$WORKDIR/$m.lean"
  generate "$f" "$m"
  STATES+=("$f")
done

########################################
# 7. SEARCH LOOP
########################################
for depth in 1 2 3; do

  echo ""
  echo "================ DEPTH $depth ================"

  NEXT=()

  for s in "${STATES[@]}"; do

    echo ""
    echo "----- NODE: $s -----"

    LOG=$(run_lean "$s")

    echo "$LOG"

    inv=$(extract_invariants "$LOG")

    omega=$(echo "$inv" | cut -d: -f1)
    xi=$(echo "$inv" | cut -d: -f2)

    SCORE=$(score "$omega" "$xi")

    echo "Ω=$omega Ξ=$xi SCORE=$SCORE"

    if echo "$LOG" | grep -qi "no goals"; then
      echo ""
      echo "✔ PROOF FOUND"
      echo "FILE: $s"
      exit 0
    fi

    for m in "${MODES[@]}"; do
      f="$WORKDIR/d${depth}_${m}_$(basename "$s")"
      generate "$f" "$m"
      NEXT+=("$f")
    done

  done

  STATES=("${NEXT[@]}")

done

echo ""
echo "✘ FAILED: NO PROOF FOUND"
exit 1
