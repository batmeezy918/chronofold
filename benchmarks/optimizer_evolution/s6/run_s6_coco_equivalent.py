import numpy as np
import json
import time

# =========================
# COCO EQUIVALENT FUNCTIONS
# =========================

def sphere(x):
    return np.sum(x**2)

def rastrigin(x):
    return 10*len(x) + np.sum(x**2 - 10*np.cos(2*np.pi*x))

def rosenbrock(x):
    return np.sum(100*(x[1:] - x[:-1]**2)**2 + (1 - x[:-1])**2)

def ackley(x):
    return -20*np.exp(-0.2*np.sqrt(np.mean(x**2))) \
           - np.exp(np.mean(np.cos(2*np.pi*x))) + 20 + np.e

def schwefel(x):
    return 418.9829*len(x) - np.sum(x*np.sin(np.sqrt(np.abs(x))))

FUNCTIONS = {
    "SPHERE": sphere,
    "RASTRIGIN": rastrigin,
    "ROSENBROCK": rosenbrock,
    "ACKLEY": ackley,
    "SCHWEFEL": schwefel
}

# =========================
# S6 SNAP EVOLUTION SYSTEM
# =========================

class S6Optimizer:
    def __init__(self, dim, pop_size=20):
        self.dim = dim
        self.pop_size = pop_size
        self.population = np.random.uniform(-5, 5, (pop_size, dim))
        self.fitness = None
        self.best = None
        self.best_score = float("inf")

    def evaluate(self, f):
        self.fitness = np.array([f(x) for x in self.population])
        idx = np.argmin(self.fitness)
        if self.fitness[idx] < self.best_score:
            self.best_score = self.fitness[idx]
            self.best = self.population[idx].copy()

    def mutate(self):
        noise = np.random.normal(0, 0.5, self.population.shape)
        return self.population + noise

    def curvature(self, x):
        return np.mean(np.abs(x[2:] - 2*x[1:-1] + x[:-2]))

    def stabilize(self, x):
        return np.clip(x, -5, 5)

    def step(self, f):
        candidates = self.mutate()
        curvatures = np.array([self.curvature(x) for x in candidates])
        candidates -= curvatures[:, None] * 0.1
        candidates = self.stabilize(candidates)

        new_fitness = np.array([f(x) for x in candidates])

        combined = np.vstack([self.population, candidates])
        combined_fit = np.concatenate([self.fitness, new_fitness])

        idx = np.argsort(combined_fit)[:self.pop_size]
        self.population = combined[idx]
        self.fitness = combined_fit[idx]

    def run(self, f, iters=150):
        self.evaluate(f)
        for _ in range(iters):
            self.step(f)
        return self.best_score

# =========================
# BENCHMARK RUNNER
# =========================

def run_benchmark():
    dim = 10
    results = {}

    print("="*50)
    print("S6 SNAP COCO-EQUIVALENT BENCHMARK")
    print("="*50)

    start = time.time()

    for name, func in FUNCTIONS.items():
        print(f"\n=== {name} ===")
        opt = S6Optimizer(dim)
        score = opt.run(func)
        print(f"FINAL: {score:.6f}")
        results[name] = float(score)

    end = time.time()

    with open("S6_RESULTS.json", "w") as f:
        json.dump(results, f, indent=2)

    print("\n=======================================")
    print("DONE")
    print(f"TIME: {end - start:.2f}s")
    print("Saved → S6_RESULTS.json")
    print("=======================================")

if __name__ == "__main__":
    run_benchmark()
