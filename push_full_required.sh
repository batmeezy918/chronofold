#!/data/data/com.termux/files/usr/bin/bash

set -e

cd ~/chronofold || exit

########################################
# VERIFY REQUIRED FILES
########################################
FILES=("lakefile.lean" "Main.lean" "Verify.lean" "lean-toolchain")

for f in "${FILES[@]}"; do
  if [ ! -f "$f" ]; then
    echo "[ERROR] Missing $f"
    exit 1
  fi
done

########################################
# VERIFY WORKFLOW EXISTS
########################################
if [ ! -f ".github/workflows/chronofold.yml" ]; then
  echo "[ERROR] Missing workflow file"
  exit 1
fi

########################################
# CLEAN SUBMODULE (SAFE)
########################################
rm -f .gitmodules 2>/dev/null || true

########################################
# PUSH
########################################
TOKEN=$(cat ~/.git_token | tr -d '\n' | tr -d '\r')

git add .
git commit -m "FINAL: ensure strict Ω pipeline inputs" || echo "No changes"

git push https://batmeezy918:$TOKEN@github.com/batmeezy918/chronofold.git

echo "==================================="
echo "ALL REQUIRED FILES PUSHED"
echo "==================================="
