#!/data/data/com.termux/files/usr/bin/bash
set -e

echo "======================================="
echo "CHRONOFOLD S6 COCO FULL PIPELINE (FIXED)"
echo "======================================="

GITHUB_USER="Batmeezy918"
REPO_NAME="chronofold"

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

    - name: Build COCO
      run: |
        cd coco/code-experiments
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

cat > coco_s6_benchmark.py << 'EOF'
import cocoex
import numpy as np

def Omega(x): return x[0]
def Xi(x): return x[2] - 2*x[1] + x[0] if len(x) > 2 else 0

def project(x, omega_ref, xi_ref):
    x = x.copy()
    x[0] = omega_ref
    if len(x) > 2:
        x[2] = 2*x[1] - x[0] + xi_ref
    return x

def s6_optimize(problem, budget=1000):
    dim = problem.dimension
    x = np.random.uniform(problem.lower_bounds, problem.upper_bounds)

    omega_ref = Omega(x)
    xi_ref = Xi(x)

    for _ in range(budget):
        z = np.random.randn(dim)
        candidate = x + 0.5*z + 0.05*np.linalg.norm(z)*z
        candidate = project(candidate, omega_ref, xi_ref)

        if problem(candidate) < problem(x):
            x = candidate
        else:
            x = 0.7*x + 0.3*candidate

    return problem(x)

observer = cocoex.Observer("bbob", "result_folder: S6_RESULTS")
suite = cocoex.Suite("bbob", "", "dimensions:10", observer)

print("RUNNING S6 COCO")

for problem in suite:
    print(problem.id)
    print("Final:", s6_optimize(problem))

print("DONE")
EOF

git add .
git commit -m "FIX: clean EOF + working COCO pipeline" || true
git pull origin main --rebase
git push origin main

echo "======================================="
echo "PIPELINE DEPLOYED"
echo "======================================="
echo "https://github.com/$GITHUB_USER/$REPO_NAME/actions"

