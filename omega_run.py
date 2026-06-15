import numpy as np
import cma
from scipy.stats import wilcoxon
from tqdm import trange


# ==========================
# Test Functions
# ==========================

def sphere(x):
    return np.sum(x**2)

def ellipsoid(x):
    n = len(x)
    kappa = 1e6
    coeffs = kappa ** np.linspace(0,1,n)
    return np.sum(coeffs * x**2)

FUNCTIONS = {
    "sphere": sphere,
    "ellipsoid": ellipsoid
}


# ==========================
# Omega Optimizer
# ==========================

def omega_opt(f, n, budget, seed):

    rng = np.random.default_rng(seed)

    m = rng.normal(0,5,n)
    C = np.eye(n)
    R = 1.0
    sigma = 0.5
    beta = 0.2

    best = f(m)
    evals = 0

    while evals < budget:

        lam = 4 + int(3*np.log(n))
        samples = []

        for _ in range(lam):
            z = rng.normal(size=n)
            x = m + sigma * R * (C @ z)
            samples.append(x)

        values = np.array([f(x) for x in samples])
        evals += lam

        idx = np.argsort(values)
        m_new = np.mean(np.array(samples)[idx[:lam//2]], axis=0)

        # curvature estimator
        diffs = np.array(samples) - m
        H = np.zeros((n,n))

        for d in diffs:
            denom = np.linalg.norm(d)**2 + 1e-8
            H += np.outer(d,d)/denom

        H /= lam

        C = (1-beta)*C + beta*H

        # SPD eigenvalue clipping
        w,v = np.linalg.eigh(C)
        w = np.clip(w,1e-6,1e6)
        C = v @ np.diag(w) @ v.T

        improvement = best - f(m_new)
        predicted = sigma**2 * np.trace(C)
        rho = improvement/(predicted + 1e-12)

        if rho > 0.75:
            R *= 1.5
        elif rho < 0.25:
            R *= 0.5

        m = m_new
        best = min(best,f(m))

    return best


# ==========================
# CMA-ES baseline
# ==========================

def cma_opt(f,n,budget,seed):

    opts = {"seed":seed,"verbose":-9}
    es = cma.CMAEvolutionStrategy(n*[5.0],0.5,opts)

    while not es.stop() and es.countevals < budget:
        X = es.ask()
        es.tell(X,[f(x) for x in X])

    return es.best.f


# ==========================
# Benchmark Runner
# ==========================

dims = [10,30]
trials = 10
budget_factor = 2000

for name,f in FUNCTIONS.items():

    for n in dims:

        budget = budget_factor*n

        omega_scores=[]
        cma_scores=[]

        print(f"\nRunning {name} (n={n})")

        for t in trange(trials):

            omega_scores.append(
                omega_opt(f,n,budget,t)
            )

            cma_scores.append(
                cma_opt(f,n,budget,t)
            )

        stat,p = wilcoxon(omega_scores,cma_scores)

        print("\n--------------------------------")
        print("Function:",name)
        print("Dimension:",n)
        print("Omega median:",np.median(omega_scores))
        print("CMA median:",np.median(cma_scores))
        print("Wilcoxon p-value:",p)
        print("--------------------------------")
