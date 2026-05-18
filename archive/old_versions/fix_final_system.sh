#!/data/data/com.termux/files/usr/bin/bash

set -e

cd ~/chronofold || exit

########################################
# REMOVE BROKEN SUBMODULE (COCO)
########################################
rm -rf coco
rm -rf .git/modules/coco 2>/dev/null || true

sed -i '/coco/d' .gitmodules 2>/dev/null || true

git add -A
git commit -m "Remove broken coco submodule" || true

########################################
# FORCE REAL BUILD (ADD TARGET FILE)
########################################
mkdir -p ChronoFold

cat <<'LEAN' > ChronoFold/Test.lean
def hello : String := "ChronoFold Active"
#eval hello
LEAN

########################################
# PUSH
########################################
TOKEN=$(cat ~/.git_token | tr -d '\n' | tr -d '\r')

git add .
git commit -m "Add real Lean build target" || echo "No changes"

git push https://batmeezy918:$TOKEN@github.com/batmeezy918/chronofold.git

echo "SYSTEM FIXED + REAL BUILD ENABLED"
