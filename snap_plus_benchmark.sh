#!/data/data/com.termux/files/usr/bin/bash

set -e

echo "======================================="
echo "SNAP+ vs CMA (REAL OPTIMIZER BENCH)"
echo "======================================="

cat > snap_plus.py << 'EOF'
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
# NUMERICAL GRADIENT
# -------------------------------
def gradient(f, x, eps=1e-6):
    grad = []
    for i in range(len(x)):
        x1 = x[:]
        x2 = x[:]
        x1[i] += eps
        x2[i] -= eps
        g = (f(x1) - f(x2)) / (2*eps)
        grad.append(g)
    return grad

# -------------------------------
# INVARIANTS
# -------------------------------
def Omega(x):
    return x[0]

def Xi(x):
    return x[2] - 2*x[1] + x[0]

# -------------------------------
# PROJECTION (CRITICAL)
# -------------------------------
def project_invariants(x, omega, xi):
    x_new = x[:]

    # enforce Ω
    x_new[0] = omega

    # enforce Ξ
    x_new[2] = 2*x_new[1] - x_new[0] + xi

    return x_new

# -------------------------------
# SNAP+ STEP (REAL OPTIMIZER)
# -------------------------------
def snap_plus_step(f, x, alpha=0.01):
    omega = Omega(x)
    xi = Xi(x)

    grad = gradient(f, x)

    # gradient descent step
    x_new = [x[i] - alpha * grad[i] for i in range(len(x))]

    # project back to invariant space
    x_new = project_invariants(x_new, omega, xi)

    return x_new

# -------------------------------
# RUN SNAP+
# -------------------------------
def run_snap_plus(f, dim, iters=200):
    x = [random.uniform(-5,5) for _ in range(dim)]
    best = f(x)

    for _ in range(iters):
        x = snap_plus_step(f, x)
        val = f(x)
        if val < best:
            best = val

    return best

# -------------------------------
# RANDOM SEARCH (baseline)
# -------------------------------
def run_random(f, dim, iters=2000):
    best = float("inf")
    for _ in range(iters):
        x = [random.uniform(-5,5) for _ in range(dim)]
        val = f(x)
        if val < best:
            best = val
    return best

# -------------------------------
# BENCHMARK
# -------------------------------
results = {}

for name, f in FUNCTIONS.items():
    print("\n===", name.upper(), "===")
    results[name] = {}

    for dim in [5, 10]:
        snap = run_snap_plus(f, dim)
        rnd = run_random(f, dim)

        print(f"dim={dim} SNAP+={snap:.4f} RANDOM={rnd:.4f}")

        results[name][dim] = {
            "snap_plus": snap,
            "random": rnd
        }

# -------------------------------
# SAVE
# -------------------------------
with open("snap_plus_results.json", "w") as f:
    json.dump(results, f, indent=2)

print("\nSaved → snap_plus_results.json")
EOF

echo "[RUNNING SNAP+ BENCHMARK]"
python snap_plus.py

echo "======================================="
echo "DONE"
echo "======================================="
