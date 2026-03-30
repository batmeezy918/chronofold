#!/data/data/com.termux/files/usr/bin/bash

set -e

echo "======================================="
echo "FIX: LAKE MANIFEST + CI"
echo "======================================="

cd ~/chronofold || exit

# -------------------------------
# GENERATE MANIFEST LOCALLY
# -------------------------------
echo "[1] Generating lake-manifest.json"
lake update

# -------------------------------
# ENSURE TOOLCHAIN FILE EXISTS
# -------------------------------
echo "[2] Ensuring lean-toolchain"
echo "leanprover/lean4:stable" > lean-toolchain

# -------------------------------
# ADD + COMMIT
# -------------------------------
echo "[3] Commit manifest"
git add lake-manifest.json lean-toolchain
git commit -m "Fix: add lake-manifest for CI" || true

# -------------------------------
# SAFE SYNC + PUSH
# -------------------------------
echo "[4] Push"
git pull origin main --rebase || true
git push origin main

# -------------------------------
# TRIGGER CI
# -------------------------------
echo "# manifest fix $(date)" >> README.md
git add README.md
git commit -m "Trigger CI (manifest fix)" || true
git push origin main

echo "======================================
