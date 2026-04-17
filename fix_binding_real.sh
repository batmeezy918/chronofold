#!/data/data/com.termux/files/usr/bin/bash

set -e

cd ~/chronofold || exit

########################################
# CLEAN + RESET STRUCTURE
########################################
mkdir -p ChronoFold/Auto
mkdir -p theorems_unproven

########################################
# CREATE REAL THEOREM FILE
########################################
cat <<'LEAN' > ChronoFold/Auto/T1.lean
namespace ChronoFold.Auto

theorem t1 : 1 + 1 = 2 := by decide

end ChronoFold.Auto
LEAN

########################################
# ROOT MODULE (CRITICAL)
########################################
cat <<'LEAN' > ChronoFold.lean
import ChronoFold.Auto.T1
LEAN

########################################
# FIX LAKEFILE (ENSURE PACKAGE BUILDS)
########################################
cat <<'LEAN' > lakefile.lean
import Lake
open Lake DSL

package chronofold

lean_lib ChronoFold
LEAN

########################################
# VERIFY STRUCTURE
########################################
echo "=== STRUCTURE ==="
find ChronoFold

########################################
# PUSH
########################################
TOKEN=$(cat ~/.git_token | tr -d '\n' | tr -d '\r')

git add .
git commit -m "Fix: proper Lean module binding (forces real build)" || echo "No changes"

git push https://batmeezy918:$TOKEN@github.com/batmeezy918/chronofold.git

echo "==================================="
echo "REAL BUILD FIX APPLIED"
echo "==================================="
