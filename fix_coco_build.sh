#!/data/data/com.termux/files/usr/bin/bash
set -e

echo "======================================="
echo "CHRONOFOLD COCO BUILD FIX"
echo "======================================="

cd $HOME/chronofold

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

    - name: Install system deps
      run: |
        sudo apt-get update
        sudo apt-get install -y build-essential cmake git python3-pip

    - name: Install Python deps
      run: |
        pip install numpy

    - name: Clone COCO
      run: |
        git clone https://github.com/numbbo/coco.git

    - name: Build COCO (FIXED)
      run: |
        cd coco/code-experiments
        rm -rf build
        mkdir build
        cd build
        cmake ..
        make -j4

    - name: Install cocoex
      run: |
        cd coco/code-experiments/build/python
        pip install .

    - name: Run S6 Benchmark
      run: |
        python coco_s6_benchmark.py

    - name: Upload Results
      uses: actions/upload-artifact@v4
      with:
        name: s6-coco-results
        path: S6_RESULTS/
EOF

git add .
git commit -m "FIX: COCO build idempotent" || true
git pull origin main --rebase
git push origin main

echo "======================================="
echo "FIX DEPLOYED"
echo "======================================="
