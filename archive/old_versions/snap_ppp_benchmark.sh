#!/data/data/com.termux/files/usr/bin/bash

set -e

echo "======================================="
echo "SNAP+++ (ORTHO + LINE SEARCH)"
echo "======================================="

cat > snap_ppp.py << 'EOF'
import random, math, json

# -------------------------------
# FUNCTIONS
# -------------------------------
def sphere(x):
    return sum(v*v for v in x)

def rastrigin(x):
    return 10*len(x) + sum(v*v - 10*math.cos(2*math.pi*v) for v in x)

def rosenbrock(x):
    return sum(100*(x[i+1]-x[i]**2)**2 + (1-x[i])**2 for i in range(len(x)-1))

FUNCTIONS = {"sphere": sphere, "rastrigin": rastrigin, "rosenbrock": rosenbrock}

# -------------------------------
# GRADIENT
# -------------------------------
def grad(f, x, eps=1e-6):
    g = []
    for i in range(len(x)):
        x1, x2 = x[:], x[:]
        x1[i]+=eps; x2[i]-=eps
        g.append((f(x1)-f(x2))/(2*eps))
    return g

# -------------------------------
# ORTHOGONAL PROJECTION
# -------------------------------
def project(g):
    g = g[:]

    # constraint system:
    # g0 = 0
    # g2 - 2g1 = 0

    g0 = g[0]
    g1 = g[1]
    g2 = g[2]

    # project onto constraint plane
    # solve least squares analytically

    # enforce g0=0
    g0_new = 0

    # solve for g1_new minimizing deviation
    g1_new = (g1 + g2/2) / 2
    g2_new = 2 * g1_new

    g_new = g[:]
    g_new[0] = g0_new
    g_new[1] = g1_new
    g_new[2] = g2_new

    return g_new

# -------------------------------
# LINE SEARCH
# -------------------------------
def step(f, x, g):
    alpha = 0.1
    best = x
    best_val = f(x)

    for _ in range(10):
        x_new = [x[i] - alpha*g[i] for i in range(len(x))]
        val = f(x_new)

        if val < best_val:
            best = x_new
            best_val = val

        alpha *= 0.5

    return best

# -------------------------------
# SNAP+++
# -------------------------------
def run_snap(f, dim):
    x = [random.uniform(-5,5) for _ in range(dim)]
    best = f(x)

    for _ in range(200):
        g = grad(f, x)
        g = project(g)
        x = step(f, x, g)
        val = f(x)
        if val < best:
            best = val

    return best

# -------------------------------
# RANDOM
# -------------------------------
def run_rand(f, dim):
    best = float("inf")
    for _ in range(2000):
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
        s = run_snap(f, dim)
        r = run_rand(f, dim)
        print(f"dim={dim} SNAP+++={s:.4f} RANDOM={r:.4f}")
        results[name][dim] = {"snap": s, "random": r}

with open("snap_ppp_results.json","w") as f:
    json.dump(results,f,indent=2)

print("\nSaved → snap_ppp_results.json")
EOF

python snap_ppp.py

echo "======================================="
echo "DONE"
echo "======================================="
