#!/usr/bin/env bash
set -e

echo "===================================="
echo "LEAN THEOREM PUSH PIPELINE"
echo "===================================="

FILE="${1:-AutoTheorem.lean}"
BRANCH="${2:-main}"

#####################################
# 1. CREATE LEAN FILE
#####################################

mkdir -p .

cat > "$FILE" <<'LEAN'
import Mathlib

theorem auto_theorem_1 : True := by
  trivial

theorem auto_theorem_2 : 2 + 2 = 4 := by
  norm_num

-- Replace with your real goal:
-- theorem my_goal : ... := by
--   ...
LEAN

echo "[OK] Created $FILE"

#####################################
# 2. GIT ADD
#####################################

git add "$FILE"

#####################################
# 3. COMMIT
#####################################

git commit -m "add Lean theorem: $FILE" || echo "[SKIP] nothing to commit"

#####################################
# 4. PUSH
#####################################

git push origin "$BRANCH"

echo "===================================="
echo "PUSH COMPLETE"
echo "CI WILL RUN AUTOMATICALLY"
echo "===================================="
