#!/data/data/com.termux/files/usr/bin/bash

set -e

echo "==================================="
echo "CHRONOFOLD FINAL CYCLE PUSH"
echo "==================================="

cd ~/chronofold || {
  echo "[ERROR] Repo not found"
  exit 1
}

########################################
# ENSURE REQUIRED FILES (BASELINE)
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
# VERIFY STRUCTURE
########################################
echo "=== FILES ==="
ls -1

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
git add .

git commit -m "FINAL SYNC: ChronoFold baseline + strict Ω pipeline" || echo "[INFO] No changes"

########################################
# PUSH
########################################
echo "[INFO] Pushing..."

git push https://batmeezy918:$TOKEN@github.com/batmeezy918/chronofold.git

echo "==================================="
echo "CYCLE COMPLETE"
echo "==================================="
echo "→ Check GitHub Actions"
echo "→ Expect Ω = 1 (real build)"
