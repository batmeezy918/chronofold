#!/data/data/com.termux/files/usr/bin/bash

set -e

echo "==================================="
echo "CHRONOFOLD BASELINE SYNC"
echo "==================================="

cd ~/chronofold || {
  echo "[ERROR] Repo not found"
  exit 1
}

########################################
# CREATE REQUIRED FILES
########################################

# lakefile.lean
cat <<'LEAN' > lakefile.lean
import Lake
open Lake DSL

package chronofold

lean_lib Verify

@[default_target]
lean_exe Main where
  root := `Main
LEAN

# Main.lean
cat <<'LEAN' > Main.lean
import Verify

def main : IO Unit :=
  IO.println "ChronoFold system active"
LEAN

# Verify.lean
cat <<'LEAN' > Verify.lean
theorem t1 : 1 + 1 = 2 := by decide
LEAN

# lean-toolchain
echo "leanprover/lean4:stable" > lean-toolchain

########################################
# VERIFY FILES
########################################
echo "=== VERIFYING FILES ==="
ls -1 lakefile.lean Main.lean Verify.lean lean-toolchain

########################################
# LOAD TOKEN
########################################
if [ ! -f ~/.git_token ]; then
  echo "[ERROR] Missing ~/.git_token"
  exit 1
fi

TOKEN=$(cat ~/.git_token | tr -d '\n' | tr -d '\r')

########################################
# GIT CONFIG
########################################
git config user.name "chronofold-bot"
git config user.email "bot@chronofold.ai"

########################################
# ADD + COMMIT
########################################
git add lakefile.lean Main.lean Verify.lean lean-toolchain

git commit -m "SYNC: Lean baseline (lakefile, Main, Verify, toolchain)" || echo "[INFO] No changes"

########################################
# PUSH
########################################
echo "[INFO] Pushing to GitHub..."

git push https://batmeezy918:$TOKEN@github.com/batmeezy918/chronofold.git

echo "==================================="
echo "BASELINE SYNC COMPLETE"
echo "==================================="
echo "→ Go to your app"
echo "→ Click Run Pipeline"
echo "→ Expect Ω = 1 (green)"
