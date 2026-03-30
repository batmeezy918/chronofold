#!/data/data/com.termux/files/usr/bin/bash

set -e

echo "======================================="
echo "CHRONOFOLD FINAL FIX (MANIFEST + CI)"
echo "======================================="

cd ~/chronofold || exit

# -------------------------------
# O_init: ENSURE TOOLCHAIN
# -------------------------------
echo "[1] Setting toolchain"
echo "leanprover/lean4:stable" > lean-toolchain

# -------------------------------
# O_init: GENERATE MANIFEST
# -------------------------------
echo "[2] Running lake update"
lake update

# -------------------------------
# VERIFY FILES
# -------------------------------
echo "[3] Verifying"
ls | grep lake-manifest.json

# -------------------------------
# COMMIT CORE FIX
# -------------------------------
echo "[4] Commit manifest"
git add lean-toolchain lake-manifest.json
git commit -m "O_init: add lake-manifest for CI stability" || true

# -------------------------------
# SAFE SYNC
# -------------------------------
echo "[5] Sync"
git pull origin main --rebase || true

# -------------------------------
# PUSH CORE
# -------------------------------
echo "[6] Push"
git push origin main

# -------------------------------
# FORCE CI TRIGGER
# -------------------------------
echo "[7] Trigger CI"
echo "# final fix $(date)" >> README.md

git add README.md
git commit -m "Trigger CI after O_init integration" || true
git push origin main

# -------------------------------
# DONE
# -------------------------------
echo "======================================="
echo "PIPELINE COMPLETE"
echo "======================================="
echo "CHECK:"
echo "https://github.com/Batmeezy918/chronofold/actions"
echo "======================================="
