#!/data/data/com.termux/files/usr/bin/bash

set -e

echo "==================================="
echo "CHRONOFOLD FULL AUTO FIX"
echo "==================================="

cd ~/chronofold || exit

########################################
# CLEAN BROKEN COCO SUBMODULE
########################################
rm -rf coco 2>/dev/null || true
rm -rf .git/modules/coco 2>/dev/null || true
sed -i '/coco/d' .gitmodules 2>/dev/null || true

########################################
# ENSURE STRUCTURE
########################################
mkdir -p ChronoFold/Auto
mkdir -p theorems_unproven
mkdir -p theorems_proven

########################################
# SAMPLE THEOREM (IF EMPTY)
########################################
if [ ! "$(ls -A theorems_unproven 2>/dev/null)" ]; then
cat <<'LEAN' > theorems_unproven/T1.lean
theorem t1 : 1 + 1 = 2 := by decide
LEAN
fi

########################################
# COPY INTO BUILD SPACE
########################################
cp theorems_unproven/*.lean ChronoFold/Auto/ 2>/dev/null || true

########################################
# GENERATE AUTO MODULE FILE (CRITICAL FIX)
########################################
AUTO_FILE="ChronoFold/Auto.lean"
echo "" > $AUTO_FILE

for f in ChronoFold/Auto/*.lean; do
  name=$(basename "$f" .lean)
  echo "import ChronoFold.Auto.$name" >> $AUTO_FILE
done

########################################
# ENSURE LAKEFILE LINKS PACKAGE
########################################
if ! grep -q "ChronoFold" lakefile.lean 2>/dev/null; then
cat <<'LEAN' >> lakefile.lean

lean_lib ChronoFold where

LEAN
fi

########################################
# VERIFY FILE TREE
########################################
echo "=== FILE STRUCTURE ==="
ls ChronoFold/Auto || true
echo "=== AUTO MODULE ==="
cat ChronoFold/Auto.lean

########################################
# COMMIT + PUSH
########################################
TOKEN=$(cat ~/.git_token | tr -d '\n' | tr -d '\r')

git add .
git commit -m "AUTO FIX: bind theorems + fix build graph + clean submodule" || echo "No changes"

git push https://batmeezy918:$TOKEN@github.com/batmeezy918/chronofold.git

echo "==================================="
echo "AUTO FIX COMPLETE"
echo "==================================="
