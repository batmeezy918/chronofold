#!/data/data/com.termux/files/usr/bin/bash

set -e

echo "======================================="
echo "SNAP REAL OPTIMIZER (INVARIANT + DESCENT)"
echo "======================================="

cat > snap_real_optimizer.py << 'EOF'
import numpy as np
import math
import random

# -------------------------------
# TEST FUNCTION (SPHERE)
# -------------------------------
def f(x):
    return np.sum(x**2)

# -------------------------------
# GRADIENT
# -------------------------------
def grad(x, eps=1e-6):
    g = np.zeros_like(x)
    for i in range(len(x)):
        x1 = x.copy()
        x2 = x.copy()
        x1[i] += eps
        x2[i] -= eps
        g[i] = (f(x1) - f(x2)) / (2 * eps)
    return g

# -------------------------------
# SNAP OPTIMIZER
# -------------------------------
class SnapOptimizer:

    def __init__(self, x0):
        self.x = np.array(x0, dtype=float)

        # invariants
        self.omega = self.x[0]
        self.xi = self.x[2] - 2*self.x[1] + self.x[0]

    # ---------------------------
    # PROJECT GRADIENT (TANGENT)
    # ---------------------------
    def project(self, g):
        g = g.copy()

        # enforce Ω invariant
        g[0] = 0

        # enforce Ξ invariant
        g1 = (g[1] + g[2]/2)/2
        g2 = 2*g1

        g[1] = g1
        g[2] = g2

        return g

    # ---------------------------
    # DESCENT SAFE DIRECTION
    # ---------------------------
    def descent_direction(self, g):
        v = self.project(g)
        dot = np.dot(g, v)

        if dot <= 0:
            return g  # fallback

        return v

    # ---------------------------
    # SNAP (INVARIANT ENFORCER)
    # ---------------------------
    def snap(self):
        self.x[0] = self.omega
        self.x[2] = 2*self.x[1] - self.x[0] + self.xi

    # ---------------------------
    # STEP
    # ---------------------------
    def step(self):
        g = grad(self.x)
        v = self.descent_direction(g)

        # line search
        alpha = 0.1
        best = self.x.copy()
        best_val = f(self.x)

        for _ in range(10):
            x_new = self.x - alpha * v
            val = f(x_new)

            if val < best_val:
                best = x_new
                best_val = val

            alpha *= 0.5

        self.x = best

        # enforce invariants AFTER move
        self.snap()

        return self.x, best_val

# -------------------------------
# RUN
# -------------------------------
x0 = np.random.uniform(-5,5, size=10)

opt = SnapOptimizer(x0)

print("Initial:", f(x0))

for i in range(200):
    x, val = opt.step()
    if i % 20 == 0:
        print(f"Iter {i}: {val}")

print("Final:", val)
EOF

python3 snap_real_optimizer.py

echo "======================================="
echo "DONE"
echo "======================================="
