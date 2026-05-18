import numpy as np
import json
import time

# =========================
# FUNCTIONS (COCO-EQUIVALENT)
# =========================

def sphere(x): return np.sum(x**2)
def rastrigin(x): return 10*len(x)+np.sum(x**2-10*np.cos(2*np.pi*x))
def rosenbrock(x): return np.sum(100*(x[1:]-x[:-1]**2)**2+(1-x[:-1])**2)
def ackley(x): return -20*np.exp(-0.2*np.sqrt(np.mean(x**2))) - np.exp(np.mean(np.cos(2*np.pi*x))) + 20 + np.e
def schwefel(x): return 418.9829*len(x)-np.sum(x*np.sin(np.sqrt(np.abs(x))))

FUNCTIONS = {
    "SPHERE": sphere,
    "RASTRIGIN": rastrigin,
    "ROSENBROCK": rosenbrock,
    "ACKLEY": ackley,
    "SCHWEFEL": schwefel
}

# =========================
# S8 OPTIMIZER (COVARIANCE)
# =========================

class S8Optimizer:
    def __init__(self, dim, pop=20):
        self.dim = dim
        self.pop = pop

        self.population = np.random.uniform(-5,5,(pop,dim))
        self.best = None
        self.best_score = float("inf")

        # covariance matrix (identity start)
        self.C = np.eye(dim)

    def eval(self, f):
        scores = np.array([f(x) for x in self.population])
        idx = np.argmin(scores)
        if scores[idx] < self.best_score:
            self.best_score = scores[idx]
            self.best = self.population[idx].copy()
        return scores

    # directional operator
    def directional(self, x, f, eps=0.1):
        u = np.random.multivariate_normal(np.zeros(self.dim), self.C)
        u /= (np.linalg.norm(u) + 1e-8)

        fx = f(x)
        fx2 = f(x + eps*u)

        return (fx2 - fx) * u

    # covariance update (elite directions)
    def update_covariance(self, directions, weights):
        C_new = np.zeros((self.dim, self.dim))
        for d, w in zip(directions, weights):
            C_new += w * np.outer(d, d)
        self.C = 0.9 * self.C + 0.1 * C_new  # smooth update

    def step(self, f):
        new_pop = []
        directions = []

        for x in self.population:
            d = self.directional(x, f)
            directions.append(d)

            x_new = x - 0.5 * d
            x_new += np.random.normal(0, 0.05, size=x.shape)
            x_new = np.clip(x_new, -5, 5)

            new_pop.append(x_new)

        new_pop = np.array(new_pop)

        old_scores = self.eval(f)
        new_scores = np.array([f(x) for x in new_pop])

        combined = np.vstack([self.population, new_pop])
        scores = np.concatenate([old_scores, new_scores])

        idx = np.argsort(scores)[:self.pop]
        self.population = combined[idx]

        # update covariance using best half
        elite_idx = idx[:self.pop//2]
        elite_dirs = [directions[i % len(directions)] for i in elite_idx]

        weights = np.linspace(1, 0.1, len(elite_dirs))
        weights /= np.sum(weights)

        self.update_covariance(elite_dirs, weights)

    def run(self, f, iters=150):
        for _ in range(iters):
            self.step(f)
        return self.best_score

# =========================
# BENCHMARK RUNNER
# =========================

def run_benchmark():
    results = {}

    print("="*50)
    print("S8 COVARIANCE OPTIMIZER BENCHMARK")
    print("="*50)

    start = time.time()

    for name, f in FUNCTIONS.items():
        print(f"\n=== {name} ===")

        opt = S8Optimizer(10)
        score = opt.run(f)

        print("FINAL:", score)
        results[name] = float(score)

    end = time.time()

    with open("S8_RESULTS.json","w") as f:
        json.dump(results,f,indent=2)

    print("\n=======================================")
    print("DONE")
    print("TIME:", end-start)
    print("Saved → S8_RESULTS.json")
    print("=======================================")

if __name__ == "__main__":
    run_benchmark()
