import cocoex
import numpy as np

def Omega(x): return x[0]
def Xi(x): return x[2] - 2*x[1] + x[0] if len(x) > 2 else 0

def project(x, omega_ref, xi_ref):
    x = x.copy()
    x[0] = omega_ref
    if len(x) > 2:
        x[2] = 2*x[1] - x[0] + xi_ref
    return x

def s6_optimize(problem, budget=1000):
    dim = problem.dimension
    x = np.random.uniform(problem.lower_bounds, problem.upper_bounds)

    omega_ref = Omega(x)
    xi_ref = Xi(x)

    for _ in range(budget):
        z = np.random.randn(dim)
        candidate = x + 0.5*z + 0.05*np.linalg.norm(z)*z
        candidate = project(candidate, omega_ref, xi_ref)

        if problem(candidate) < problem(x):
            x = candidate
        else:
            x = 0.7*x + 0.3*candidate

    return problem(x)

observer = cocoex.Observer("bbob", "result_folder: S6_RESULTS")
suite = cocoex.Suite("bbob", "", "dimensions:10", observer)

print("RUNNING S6 COCO")

for problem in suite:
    print(problem.id)
    print("Final:", s6_optimize(problem))

print("DONE")
