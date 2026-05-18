import numpy as np
import json
import time

class SPME_Optimizer:
    def __init__(self, dim, pop=20, seed=445964509):
        self.dim = dim
        self.pop = pop
        np.random.seed(seed) # FIXED SEED FOR DETERMINISM
        self.stable_manifolds = np.random.uniform(-1, 1, (pop, dim))
        self.psi_u = np.random.normal(0, 0.1, (pop, dim))
        self.best_score = float('inf')
        self.best_x = None

    def Xi(self, psi):
        return np.linalg.norm(psi)

    def cgtr(self, psi):
        xi = self.Xi(psi)
        return np.exp(xi)

    def step(self, f):
        new_pop = []
        for i in range(self.pop):
            gain = self.cgtr(self.psi_u[i])
            self.psi_u[i] += -0.01 * gain * np.random.normal(0, 0.1, self.dim)
            x = self.stable_manifolds[i] + self.psi_u[i]
            x = np.clip(x, -5, 5)
            new_pop.append(x)

        new_pop = np.array(new_pop)
        scores = np.array([f(x) for x in new_pop])
        idx = np.argmin(scores)
        if scores[idx] < self.best_score:
            self.best_score = scores[idx]
            self.best_x = new_pop[idx].copy()
            self.stable_manifolds[idx] = self.best_x - self.psi_u[idx]

    def run(self, f, iters=100):
        for _ in range(iters):
            self.step(f)
        return self.best_score

def sphere(x): return np.sum(x**2)

if __name__ == "__main__":
    opt = SPME_Optimizer(dim=128)
    score = opt.run(sphere)
    print(f"SPME Optimized Result: {score:.6f}")
