#!/data/data/com.termux/files/usr/bin/bash
set -e

echo "======================================="
echo "CHRONOFOLD COCO FINAL PIPELINE (DO.PY)"
echo "======================================="

GITHUB_USER="Batmeezy918"
REPO_NAME="chronofold"

cd $HOME/chronofold

########################################
# 1. CLEAN COCO
########################################
rm -rf coco

########################################
# 2. CLONE COCO (CORRECT)
########################################
echo "[1] Cloning COCO..."
git clone https://github.com/numbbo/coco.git

cd coco
git submodule update --init --recursive

########################################
# 3. BUILD + ENABLE PYTHON (CORRECT)
########################################
echo "[2] Building cocoex via do.py..."
cd code-experiments

# THIS is the correct build system
python3 do.py run-python

########################################
# 4. VERIFY
########################################
echo "[3] Verifying install..."
python3 - << 'EOF'
import cocoex
print("COCO OK — Python interface active")
EOF

########################################
# 5. RETURN TO PROJECT ROOT
########################################
cd $HOME/chronofold

########################################
# 6. WRITE FINAL GITHUB WORKFLOW
########################################
mkdir -p .github/workflows

cat > .github/workflows/coco.yml << 'EOF'
name: S6 COCO Benchmark

on:
  push:
    branches: [ "main" ]

jobs:
  run-benchmark:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v4

    - name: Install deps
      run: |
        sudo apt-get update
        sudo apt-get install -y git python3-pip
        pip install numpy

    - name: Clone COCO
      run: |
        git clone https://github.com/numbbo/coco.git
        cd coco
        git submodule update --init --recursive

    - name: Build cocoex (DO.PY)
      run: |
        cd coco/code-experiments
        python3 do.py run-python

    - name: Run S6 Benchmark
      run: |
        python coco_s6_benchmark.py

    - name: Upload Results
      uses: actions/upload-artifact@v4
      with:
        name: s6-coco-results
        path: S6_RESULTS/
EOF

########################################
# 7. PUSH
########################################
git add .
git commit -m "FINAL: COCO do.py pipeline + S6 integration" || true
git pull origin main --rebase
git push origin main

########################################
# DONE
########################################
echo "======================================="
echo "PIPELINE READY"
echo "======================================="
echo "CHECK:"
echo "https://github.com/$GITHUB_USER/$REPO_NAME/actions"
echo "======================================="
