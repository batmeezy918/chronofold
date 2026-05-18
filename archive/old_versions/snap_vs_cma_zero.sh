#!/data/data/com.termux/files/usr/bin/bash

set -e

echo "======================================="
echo "SNAP vs CMA (ZERO DEPENDENCY BENCH)"
echo "======================================="

cat > snap_vs_cma.py << 'EOF'
import random
import math
import json

# -------------------------------
# FUNCTIONS
# -------------------------------
def sphere(x):
    return sum(v*v for v in x)

def rastrigin(x):
    return 10*len(x) + sum(v*v - 10*math.cos(2*math.pi*v) for v in x)

def rosenbrock(x):
    return sum(100*(x[i+1]-x[i]**2)**2 + (1-x[i])**2 for i in range(len(x)-1))

FUNCTIONS = {
    "sphere": sphere,
    "rastrigin": rastrigin,
    "rosenbrock": rosenbrock
}

# -------------------------------
# SNAP (deterministic contraction)
# -------------------------------
def snap_step(x):
    return [x[0]] + [v * 0.98 for v in x[1:]]

def run_snap(f, dim, iters=100):
    x = [random.uniform(-5,5) for _ in range(dim)]
    best = f(x)
    for _ in range(iters):
        x = snap_step(x)
        val = f(x)
        if val < best:
            best = val
    return best

# -------------------------------
# FAKE CMA (random search baseline)
# -------------------------------
def run_cma(f, dim, iters=1000):
    best = float("inf")
    for _ in range(iters):
        x = [random.uniform(-5,5) for _ in range(dim)]
        val = f(x)
        if val < best:
            best = val
    return best

# -------------------------------
# RUN
# -------------------------------
results = {}

for name, f in FUNCTIONS.items():
    print("\n===", name.upper(), "===")
    results[name] = {}

    for dim in [5, 10]:
        snap = run_snap(f, dim)
        cma = run_cma(f, dim)

        print(f"dim={dim} SNAP={snap:.4f} CMA={cma:.4f}")

        results[name][dim] = {"snap": snap, "cma": cma}

with open("results.json", "w") as f:
    json.dump(results, f, indent=2)

print("\nSaved → results.json")
EOF

echo "[RUNNING BENCHMARK]"
python snap_vs_cma.py

echo "======================================="
echo "DONE"
echo "======================================="
