import numpy as np
import cma

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

def snap_optimize(f, dim, steps=200, lr=0.01):
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

def cma_optimize(f, dim):
    x0 = np.random.randn(dim)
    es = cma.CMAEvolutionStrategy(x0, 0.5, {'verbose': -9})
    res = es.optimize(f, iterations=200)
    return res.result.fbest

# ===============================
# RUN BENCHMARK
# ===============================

results = {}

for name, func in functions.items():
    print(f"\n=== {name} ===")
    results[name] = {}

    for dim in [5, 10]:
        snap_score = snap_optimize(func, dim)
        cma_score = cma_optimize(func, dim)

        print(f"dim={dim} SNAP={snap_score:.4f} CMA={cma_score:.4f}")

        results[name][dim] = {
            "SNAP": snap_score,
            "CMA": cma_score
        }

# save results
import json
with open("real_results.json", "w") as f:
    json.dump(results, f, indent=2)

print("\n=======================================")
print("DONE → real_results.json")
print("=======================================")
