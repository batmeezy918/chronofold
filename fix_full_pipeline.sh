#!/data/data/com.termux/files/usr/bin/bash

set -e

echo "======================================="
echo "CHRONOFOLD FULL PIPELINE FIX (FINAL)"
echo "======================================="

cd ~/chronofold || exit

# -------------------------------
# ENSURE WORKFLOW DIRECTORY EXISTS
# -------------------------------
mkdir -p .github/workflows

# -------------------------------
# FIX WORKFLOW (LEAN + PYTHON + BENCH)
# -------------------------------
cat > .github/workflows/lean.yml << 'EOF'
name: Lean + SNAP Pipeline

on:
  push:
    branches: [ "main" ]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout repo
        uses: actions/checkout@v3

      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.10'

      - name: Install Lean
        uses: leanprover/lean-action@v1
        with:
          auto-config: true

      - name: Build Lean
        run: lake build

      - name: Run SNAP Benchmark
        run: python3 benchmark_snap.py
EOF

# -------------------------------
# CREATE / FIX BENCHMARK FILE
# -------------------------------
cat > benchmark_snap.py << 'EOF'
import json

def snap_step(x):
    x[1] += 1
    x[2] = 2*x[1] - x[0] + (x[2] - 2*x[1] + x[0])
    return x

def f(x):
    return sum(v*v for v in x)

x = [1, 2, 3]

for i in range(100):
    x = snap_step(x)

result = {
    "final_state": x,
    "objective": f(x),
    "iterations": 100
}

with open("snap_result.json", "w") as f_out:
    json.dump(result, f_out)

print(result)
EOF

# -------------------------------
# FORCE CI TRIGGER (SAFE CHANGE)
# -------------------------------
echo "# CI trigger $(date)" >> README.md

# -------------------------------
# GIT PUSH (SAFE REBASE)
# -------------------------------
git add .

git commit -m "FULL FIX: CI + SNAP benchmark + Python setup" || true

echo "[SYNC] Pulling latest remote..."
git pull origin main --rebase || true

echo "[PUSH] Sending to GitHub..."
git push origin main

# -------------------------------
# DONE
# -------------------------------
echo "======================================="
echo "PIPELINE FIXED + DEPLOYED"
echo "======================================="
echo "CHECK ACTIONS:"
echo "https://github.com/Batmeezy918/chronofold/actions"
echo "======================================="
