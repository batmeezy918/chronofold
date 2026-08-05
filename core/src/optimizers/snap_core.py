"""
SNAP core — dimension-safe projected descent
============================================
Fixes: previous `project()` hard-coded indices 0,1,2 and was
meaningless for n!=3 while the demo used n=10.
"""

import random
import math


def sphere(x):
    return sum(v * v for v in x)


def grad(f, x, eps=1e-6):
    g = []
    for i in range(len(x)):
        x1 = x[:]
        x2 = x[:]
        x1[i] += eps
        x2[i] -= eps
        g.append((f(x1) - f(x2)) / (2 * eps))
    return g


def project(g, mode="mean_zero"):
    """
    Dimension-generic projection of a search direction.
    mode='mean_zero': remove the mean component (common sphere/simplex tangent).
    mode='none': identity.
    """
    if not g:
        return g
    if mode == "none":
        return g[:]
    mu = sum(g) / len(g)
    return [gi - mu for gi in g]


def descent_direction(g, mode="mean_zero"):
    v = project(g, mode=mode)
    dot = sum(g[i] * v[i] for i in range(len(g)))
    # If projection kills descent, fall back to raw gradient
    if dot <= 0:
        return g[:]
    return v


def step(f, x, mode="mean_zero"):
    g = grad(f, x)
    v = descent_direction(g, mode=mode)
    alpha = 0.1
    best = x[:]
    best_val = f(x)
    for _ in range(8):
        x_new = [x[i] - alpha * v[i] for i in range(len(x))]
        val = f(x_new)
        if val < best_val:
            best = x_new
            best_val = val
        alpha *= 0.5
    return best


if __name__ == "__main__":
    x = [random.uniform(-5, 5) for _ in range(10)]
    best = sphere(x)
    for _ in range(200):
        x = step(sphere, x)
        val = sphere(x)
        if val < best:
            best = val
    print("FINAL:", best)
