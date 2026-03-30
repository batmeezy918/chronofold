#!/data/data/com.termux/files/usr/bin/bash

set -e

echo "======================================="
echo "SNAP vs CMA-ES OFFICIAL STYLE BENCH"
echo "======================================="

# -------------------------------
# ENV SETUP
# -------------------------------
echo "[1] Setup Python env"

python3 -m venv snap_env
source snap_env/bin/activate

pip install --upgrade pip >/dev/null
pip install numpy cma tqdm >/dev/null

# -------------------------------
# WRITE BENCHMARK
# -------------------------------
echo "[2] Writing benchmark script"

cat > snap_vs_cma.py << 'EOF'
import numpy as np
import cma
from tqdm import tqdm
import json

# =========================================
# TEST FUNCTIONS (COCO-style core set)
# =========================================

def sphere(x):
    return np.sum(x**2)

def rastrigin(x):
    return 10*len(x) + np.sum(x**2 - 10*np.cos(2*np.pi*x))

def rosenbrock(x):
    return np.sum(100*(x[1:] - x[:-1]**2)**2 + (1 - x[:-1])**2)

FUNCTIONS = {
    "sphere": sphere,
    "rastrigin": rastrigin,
    "rosenbrock": rosenbrock
}

# =========================================
# SNAP OPTIMIZER
# =========================================

def snap_step(x):
    # SNAP-like invariant-preserving step
    x_new = x.copy()

    # Δ = small deterministic push
    delta = 0.1

    # preserve x[0]
    x_new[0] = x[0]

    # update second coordinate
    x_new[1] = x[1] - delta

    # preserve curvature (Ξ)
    xi = x[2] - 2*x[1] + x[0]
    x_new[2] = 2*x_new[1] - x_new[0] + xi

    # rest small contraction
    for i in range(3, len(x)):
        x_new[i] = x[i] * 0.99

    return x_new


def run_snap(f, dim, iters=200):
    x = np.random.randn(dim)
    best = f(x)

    for _ in range(iters):
        x = snap_step(x)
        val = f(x)
        if val < best:
            best = val

    return best


# =========================================
# CMA-ES
# =========================================

def run_cma(f, dim, iters=200):
    es = cma.CMAEvolutionStrategy(dim * [0], 0.5, {'maxiter': iters, 'verb_log': 0, 'verbose': -9})
    res = es.optimize(f)
    return res.result.fbest


# =========================================
# BENCHMARK LOOP
# =========================================

results = {}

dims = [5, 10]

for fname, f in FUNCTIONS.items():
    print(f"\n=== FUNCTION: {fname.upper()} ===")

    results[fname] = {}

    for dim in dims:
        print(f"\nDIM = {dim}")

        snap_score = run_snap(f, dim)
        cma_score = run_cma(f, dim)

        print(f"SNAP: {snap_score:.6f}")
        print(f"CMA : {cma_score:.6f}")

        results[fname][dim] = {
            "snap": float(snap_score),
            "cma": float(cma_score)
        }

# =========================================
# SAVE RESULTS
# =========================================

with open("benchmark_results.json", "w") as f:
    json.dump(results, f, indent=2)

print("\n=======================================")
print("FINAL RESULTS SAVED → benchmark_results.json")
print("=======================================")
EOF

# -------------------------------
# RUN BENCHMARK
# -------------------------------
echo "[3] Running benchmark..."

python3 snap_vs_cma.py

# -------------------------------
# DONE
# -------------------------------
echo "======================================="
echo "DONE"
echo "Check benchmark_results.json"
echo "================================
