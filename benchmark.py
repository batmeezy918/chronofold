import numpy as np
import cma
import json

# ===============================
# TEST FUNCTIONS (COCO STYLE)
# ===============================

def sphere(x):
    return np.sum(x**2)

def rastrigin(x):
    return 10*len(x) + np.sum(x**2 - 10*np.cos(2*np.pi*x))

def rosenbrock(x):
    return np.sum(100*(x[1:] - x[:-1]**2)**2 + (1 - x[:-1])**2)

functions = {
    "SPHERE": sphere,
    "RASTRIGIN": rastrigin,
    "ROSENBROCK": rosenbrock
}

# ===============================
# SNAP OPTIMIZER (FIXED VERSION)
# ===============================

def snap_optimize(f, dim, steps=200, lr=0.01, seed=42):
    np.random.seed(seed)
    x = np.random.randn(dim)

    def grad(x):
        eps = 1e-6
        g = np.zeros_like(x)
        for i in range(dim):
            xp = x.copy()
            xp[i] += eps
            xm = x.copy()
            xm[i] -= eps
            g[i] = (f(xp) - f(xm)) / (2*eps)
        return g

    # initialize invariant tracker (Ξ approx)
    x_hist = [x.copy(), x.copy(), x.copy()]

    for k in range(steps):
        g = grad(x)

        # compute curvature signal (Ξ)
        xi = np.linalg.norm(x_hist[2] - 2*x_hist[1] + x_hist[0])

        # adaptive step
        alpha = lr / (1 + xi)

        x = x - alpha * g

        # update history
        x_hist.pop(0)
        x_hist.append(x.copy())

    return f(x)

# ===============================
# CMA-ES BASELINE
# ===============================

def cma_optimize(f, dim, seed=42):
    np.random.seed(seed)
    x0 = np.random.randn(dim)
    es = cma.CMAEvolutionStrategy(x0, 0.5, {'verbose': -9, 'seed': seed})
    res = es.optimize(f, iterations=200)
    return res.result.fbest

# ===============================
# RUN BENCHMARK
# ===============================

results = {}
base_seed = 42

for fn_idx, (name, func) in enumerate(functions.items()):
    print(f"\n=== {name} ===")
    results[name] = {}

    for dim_idx, dim in enumerate([5, 10]):
        run_seed = base_seed + fn_idx * 10 + dim_idx
        snap_score = snap_optimize(func, dim, seed=run_seed)
        cma_score = cma_optimize(func, dim, seed=run_seed)

        print(f"dim={dim} SNAP={snap_score:.4f} CMA={cma_score:.4f}")

        results[name][dim] = {
            "SNAP": float(snap_score),
            "CMA": float(cma_score)
        }

# save results
with open("real_results.json", "w") as f:
    json.dump(results, f, indent=2)

print("\n=======================================")
print("DONE → real_results.json")
print("=======================================")
