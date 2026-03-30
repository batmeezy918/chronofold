#!/data/data/com.termux/files/usr/bin/bash

set -e

echo "======================================="
echo "REAL COCO (BBOB) MINIMAL BENCH - DIM 10"
echo "======================================="

echo "[1] Install dependencies..."
pip install numpy cocoex >/dev/null 2>&1

cat << 'PYEOF' > coco_snap_run.py
import cocoex
import numpy as np

# ===============================
# YOUR OPTIMIZER (S6 CORE MINIMAL)
# ===============================
def snap_optimize(problem, budget=2000):
    dim = problem.dimension

    # init
    x = np.random.uniform(problem.lower_bounds, problem.upper_bounds)

    def Omega(x): return x[0]
    def Xi(x): return x[2] - 2*x[1] + x[0] if len(x) > 2 else 0

    omega_ref = Omega(x)
    xi_ref = Xi(x)

    sigma = 0.5

    for _ in range(budget):
        z = np.random.randn(dim)

        # mutation
        xi_signal = np.linalg.norm(z)
        candidate = x + sigma * z + 0.05 * xi_signal * z

        # projection (LEAN guarantees)
        candidate[0] = omega_ref
        if dim > 2:
            candidate[2] = 2*candidate[1] - candidate[0] + xi_ref

        # Λ (acceptance)
        if problem(candidate) < problem(x):
            x = candidate
        else:
            x = 0.7*x + 0.3*candidate

    return problem(x)

# ===============================
# COCO SETUP
# ===============================
suite = cocoex.Suite("bbob", "", "dimensions:10")

observer = cocoex.Observer("bbob", "result_folder: SNAP_MINIMAL")
suite.attach_observer(observer)

print("Running COCO (dim=10, all functions)...")

# ===============================
# RUN ALL FUNCTIONS
# ===============================
for problem in suite:
    print(f"Function {problem.id} | dim={problem.dimension}")

    snap_optimize(problem, budget=2000)

print("=======================================")
print("DONE → Results saved in SNAP_MINIMAL/")
print("=======================================")
PYEOF

echo "[2] Running COCO benchmark..."
python3 coco_snap_run.py

echo "======================================="
echo "COMPLETE"
echo "======================================="

