import numpy as np
import random

# -------------------------------
# FUNCTION (Sphere for now)
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
        x1[i]+=eps
        x2[i]-=eps
        g[i] = (f(x1)-f(x2))/(2*eps)
    return g

# -------------------------------
# SNAP OPTIMIZER (HYBRID)
# -------------------------------
class SnapOpt:

    def __init__(self, x0):
        self.x = np.array(x0, dtype=float)

        # Lean-verified invariants
        self.omega = self.x[0]
        self.xi = self.x[2] - 2*self.x[1] + self.x[0]

    def project(self, g):
        g = g.copy()
        g[0] = 0

        g1 = (g[1] + g[2]/2)/2
        g2 = 2*g1

        g[1] = g1
        g[2] = g2
        return g

    def descent(self, g):
        v = self.project(g)
        if np.dot(g,v) <= 0:
            return g
        return v

    def snap_correction(self, x):
        x_new = x.copy()

        # Lean invariants softly enforced
        x_new[0] = self.omega
        x_new[2] = 2*x_new[1] - x_new[0] + self.xi

        return x_new

    def step(self):

        g = grad(self.x)
        v = self.descent(g)

        alpha = 0.05
        x_new = self.x - alpha*v

        # SOFT SNAP (key)
        lam = 0.1
        snap_x = self.snap_correction(x_new)

        self.x = (1-lam)*x_new + lam*snap_x

        return self.x, f(self.x)

# -------------------------------
# RUN
# -------------------------------
x0 = np.random.uniform(-5,5, size=10)

opt = SnapOpt(x0)

print("Initial:", f(x0))

for i in range(200):
    x, val = opt.step()
    if i % 20 == 0:
        print(f"Iter {i}: {val}")

print("Final:", val)
