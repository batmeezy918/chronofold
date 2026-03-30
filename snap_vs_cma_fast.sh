#!/data/data/com.termux/files/usr/bin/bash

set -e

echo "======================================="
echo "SNAP vs CMA (FAST STABLE BENCH)"
echo "======================================="

# -------------------------------
# INSTALL (LIGHTWEIGHT)
# -------------------------------
echo "[1] Installing minimal deps..."

pkg update -y >/dev/null 2>&1
pkg install -y python >/dev/null 2>&1

pip install --upgrade pip >/dev/null 2>&1

# use prebuilt versions only
pip install numpy --only-binary=:all: || true
pip install cma tqdm || true

# fallback if numpy fails binary
pip install numpy --no-cache-dir || true

# -------------------------------
# WRITE BENCHMARK
# -------------------------------
echo "[2] Writing benchmark..."

cat > snap_vs_cma.py << 'EOF'
import numpy as np
import cma
import json

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

# SNAP (simplified stable)
def snap_step(x):
    x = x.copy()
    x[1:] *= 0.98
    return x

def run_snap(f, dim, iters=100):
    x = np.random.randn(dim)
    best = f(x)
    for _ in range(iters):
        x = snap_step(x)
        val = f(x)
        if val < best:
            best = val
    return best

def run_cma(f, dim):
    es = cma.CMAEvolutionStrategy(dim * [0], 0.5, {'verbose': -9})
    res = es.optimize(f)
    return res.result.fbest

results = {}

for name, f in FUNCTIONS.items():
    print("\n===", name.upper(), "===")
    results[name] = {}

    for dim in [5, 10]:
        snap = run_snap(f, dim)
        cma_res = run_cma(f, dim)

        print(f"dim={dim} SNAP={snap:.4f} CMA={cma_res:.4f}")

        results[name][dim] = {"snap": snap, "cma": cma_res}

with open("results.json", "w") as f:
    json.dump(results, f, indent=2)

print("\nSaved → results.json")
EOF

# -------------------------------
# RUN
# -------------------------------
echo "[3] Running..."

python snap_vs_cma.py

echo "======================================="
echo "DONE"
echo "======================================="
