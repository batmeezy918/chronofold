#!/data/data/com.termux/files/usr/bin/bash
set -e

echo "======================================="
echo "SNAP FINAL (CONDITIONAL INVARIANT)"
echo "======================================="

cat > snap_fixed.py << 'EOF'
import numpy as np
import random

def f(x):
    return np.sum(x**2)

def grad(x, eps=1e-6):
    g = np.zeros_like(x)
    for i in range(len(x)):
        x1 = x.copy()
        x2 = x.copy()
        x1[i]+=eps
        x2[i]-=eps
        g[i] = (f(x1)-f(x2))/(2*eps)
    return g

class SnapOpt:

    def __init__(self, x0):
        self.x = np.array(x0, dtype=float)
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

    def snap(self, x):
        x_new = x.copy()
        x_new[0] = self.omega
        x_new[2] = 2*x_new[1] - x_new[0] + self.xi
        return x_new

    def invariant_error(self, x):
        xi_now = x[2] - 2*x[1] + x[0]
        return abs(xi_now - self.xi)

    def step(self):
        g = grad(self.x)
        v = self.descent(g)

        alpha = 0.05
        x_new = self.x - alpha*v

        # ONLY apply SNAP if drift too large
        if self.invariant_error(x_new) > 1e-3:
            x_new = self.snap(x_new)

        self.x = x_new
        return self.x, f(self.x)

# RUN
x0 = np.random.uniform(-5,5, size=10)
opt = SnapOpt(x0)

print("Initial:", f(x0))

for i in range(200):
    x,val = opt.step()
    if i % 20 == 0:
        print(f"Iter {i}: {val}")

print("Final:", val)
EOF

python3 snap_fixed.py

echo "======================================="
echo "DONE"
echo "======================================="
