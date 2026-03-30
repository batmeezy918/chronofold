import cocoex
import numpy as np

# ===============================
# INVARIANTS (LEAN GUARANTEED)
# ===============================
def Omega(x):
    return x[0]

def Xi(x):
    if len(x) < 3:
        return 0
    return x[2] - 2*x[1] + x[0]

def project(x, omega_ref, xi_ref):
    x = x.copy()
    x[0] = omega_ref
    if len(x) > 2:
        x[2] = 2*x[1] - x[0] + xi_ref
    return x

# ===============================
# S6 OPTIMIZER (GENETIC + Λ)
# ===============================
def s6_optimize(problem, budget=2000, pop_size=20):

    dim = problem.dimension

    # init population
    population = [
        np.random.uniform(problem.lower_bounds, problem.upper_bounds)
        for _ in range(pop_size)
    ]

    omega_ref = Omega(population[0])
    xi_ref = Xi(population[0])

    for _ in range(budget // pop_size):

        fitness = [problem(x) for x in population]

        # SELECTION (S)
        idx = np.argsort(fitness)
        elites = [population[i] for i in idx[:pop_size//2]]

        # DISTRIBUTION (𝓓)
        mu = np.mean(elites, axis=0)
        centered = [e - mu for e in elites]
        Sigma = np.cov(np.array(centered).T) + 1e-6*np.eye(dim)

        try:
            A = np.linalg.cholesky(Sigma)
        except:
            A = np.eye(dim)

        new_population = []

        for _ in range(pop_size):
            z = np.random.randn(dim)

            # Ξ
