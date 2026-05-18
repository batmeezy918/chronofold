#!/data/data/com.termux/files/usr/bin/bash

set -e

echo "==================================="
echo "FIX + CREATE LEAN PROJECT + PUSH"
echo "==================================="

cd ~/chronofold || exit

########################################
# CREATE MAIN.lean
########################################
cat <<'LEAN' > Main.lean
import Verify

def main : IO Unit :=
  IO.println "ChronoFold system active"
LEAN

########################################
# CREATE VERIFY.lean
########################################
cat <<'LEAN' > Verify.lean
theorem t1 : 1 + 1 = 2 := by decide
LEAN

########################################
# CREATE lakefile.lean (CORRECT)
########################################
cat <<'LEAN' > lakefile.lean
import Lake
open Lake DSL

package chronofold

lean_lib Verify

@[default_target]
lean_exe Main where
  root := `Main
LEAN

########################################
# CREATE lean-toolchain
########################################
echo "leanprover/lean4:stable" > lean-toolchain

########################################
# VERIFY FILES
########################################
echo "=== PROJECT FILES ==="
ls -1

########################################
# LOAD TOKEN
########################################
TOKEN=$(cat ~/.git_token | tr -d '\n' | tr -d '\r')

########################################
# COMMIT + PUSH
########################################
git add .

git commit -m "Fix: complete Lean project (Main, Verify, lakefile, toolchain)" || echo "No changes"

git push https://batmeezy918:$TOKEN@github.com/batmeezy918/chronofold.git

echo "==================================="
echo "PROJECT FIXED + PUSHED"
echo "==================================="

