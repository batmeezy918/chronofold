#!/data/data/com.termux/files/usr/bin/bash

set -e

echo "=== ChronoFold FULL FIX + PUSH ==="

cd ~/chronofold || exit

# ----------------------------
# 1. HARD SYNC (clean slate)
# ----------------------------
git fetch origin
git reset --hard origin/main

# ----------------------------
# 2. FIX WORKFLOW YAML
# ----------------------------
mkdir -p .github/workflows

cat << 'YAML' > .github/workflows/chronofold.yml
name: ChronoFold Lean Pipeline

on:
  push:
    branches: ["main"]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Install Lean
        run: |
          curl https://raw.githubusercontent.com/leanprover/elan/master/elan-init.sh -sSf | sh -s -- -y
          echo "$HOME/.elan/bin" >> $GITHUB_PATH

      - name: Build
        run: |
          lake update
          lake build | tee build.log

      - name: Extract Errors
        if: failure()
        run: |
          grep -i "error" build.log > errors.txt || true

      - name: Debug Output
        if: failure()
        run: |
          echo "=== BUILD ERRORS ==="
          cat errors.txt || true
          echo "===================="
YAML

echo "✔ YAML fixed"

# ----------------------------
# 3. COMMIT + PUSH
# ----------------------------
git add .

git commit -m "fix: workflow YAML syntax error resolved" || echo "No changes"

git push origin main

echo "✔ PUSH COMPLETE"
echo ""
echo "👉 Check build:"
echo "https://github.com/batmeezy918/chronofold/actions"

echo "=== DONE ==="

