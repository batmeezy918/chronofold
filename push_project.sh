#!/data/data/com.termux/files/usr/bin/bash

set -e

echo "==================================="
echo "PUSHING LEAN PROJECT TO GITHUB"
echo "==================================="

cd ~/chronofold || {
  echo "[ERROR] chronofold repo not found"
  exit 1
}

########################################
# VERIFY REQUIRED FILES EXIST
########################################
REQUIRED_FILES=("lakefile.lean" "Main.lean" "Verify.lean" "lean-toolchain")

for file in "${REQUIRED_FILES[@]}"; do
  if [ ! -f "$file" ]; then
    echo "[ERROR] Missing file: $file"
    exit 1
  fi
done

echo "[INFO] All required files present"

########################################
# LOAD TOKEN
########################################
if [ ! -f ~/.git_token ]; then
  echo "[ERROR] ~/.git_token missing"
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

git commit -m "Add Lean project structure (lakefile, Main, Verify, toolchain)" || echo "[INFO] No changes to commit"

########################################
# PUSH
########################################
echo "[INFO] Pushing..."

git push https://batmeezy918:$TOKEN@github.com/batmeezy918/chronofold.git

echo "==================================="
echo "PUSH COMPLETE"
echo "==================================="

