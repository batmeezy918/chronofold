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
# GRADIENT
# -------------------------------
def gradient(f, x, eps=1e-6):
    grad = []
    for i in range(len(x)):
        x1 = x[:]
        x2 = x[:]
        x1[i] += eps
        x2[i] -= eps
        grad.append((f(x1)-f(x2))/(2*eps))
    return grad

# -------------------------------
# PROJECT GRADIENT (KEY FIX)
# -------------------------------
def project_gradient(g):
    g_new = g[:]

    # enforce Ω invariant → no change to x[0]
    g_new[0] = 0

    # enforce Ξ invariant
    # constraint: g2 - 2*g1 + g0 = 0
    # since g0=0 → g2 = 2*g1
    g_new[2] = 2 * g_new[1]

    return g_new

# -------------------------------
# SNAP++ STEP
# -------------------------------
def snap_pp_step(f, x, alpha=0.01):
    g = gradient(f, x)
    g_proj = project_gradient(g)

    x_new = [x[i] - alpha * g_proj[i] for i in range(len(x))]
    return x_new

# -------------------------------
# RUN SNAP++
# -------------------------------
def run_snap_pp(f, dim, iters=200):
    x = [random.uniform(-5,5) for _ in range(dim)]
    best = f(x)

    for _ in range(iters):
        x = snap_pp_step(f, x)
        val = f(x)
        if val < best:
            best = val

    return best

# -------------------------------
# RANDOM BASELINE
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
# BENCH
# -------------------------------
results = {}

for name, f in FUNCTIONS.items():
    print("\n===", name.upper(), "===")
    results[name] = {}

    for dim in [5,10]:
        snap = run_snap_pp(f, dim)
        rnd = run_random(f, dim)

        print(f"dim={dim} SNAP++={snap:.4f} RANDOM={rnd:.4f}")

        results[name][dim] = {
            "snap_pp": snap,
            "random": rnd
        }

with open("snap_pp_results.json", "w") as f:
    json.dump(results, f, indent=2)

print("\nSaved → snap_pp_results.json")
