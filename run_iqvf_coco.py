import cocoex
import numpy as np

suite = cocoex.Suite("bbob", "", "")
observer = cocoex.Observer("bbob", "result_folder: results")
suite.attach_observer(observer)

def iqvf(problem, max_evals=1000):
    dim = problem.dimension
    x = np.random.randn(dim)

    for _ in range(max_evals):
        candidates = [x + np.random.randn(dim)*0.5 for _ in range(8)]
        scores = [problem(c) for c in candidates]

        x_new = candidates[np.argmin(scores)]
        x = 0.7 * x_new + 0.3 * x

for problem in suite:
    print("Running:", problem.id)
    iqvf(problem)
