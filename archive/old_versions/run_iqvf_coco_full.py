import cocoex
import numpy as np

# =========================
# CONFIG
# =========================
MAX_EVALS_PER_DIM = 2000
POP_SIZE = 16
TOP_K = 4

# =========================
# IQVF OPTIMIZER (STRONG)
# =========================
def iqvf_optimize(problem):
    dim = problem.dimension
    max_evals = MAX_EVALS_PER_DIM * dim

    x = np.random.randn(dim)
    sigma = 0.5
    best_val = problem(x)
    evals = 1

    prev_x = x.copy()

    while evals < max_evals:

        candidates = []
        scores = []

        for _ in range(POP_SIZE):
            noise = np.random.randn(dim) * sigma
            c = x + noise
            val = problem(c)

            candidates.append(c)
            scores.append(val)

        evals += POP_SIZE

        idx = np.argsort(scores)
        top = [candidates[i] for i in idx[:TOP_K]]
        top_scores = [scores[i] for i in idx[:TOP_K]]

        weights = np.linspace(1.0, 0.5, TOP_K)
        weights /= np.sum(weights)

        x_new = np.zeros(dim)
        for w, t in zip(weights, top):
            x_new += w * t

        best_local = min(top_scores)

        momentum = 0.2
        x = (1 - momentum) * x_new + momentum * prev_x
        x = np.clip(x, -5, 5)

        if best_local < best_val:
            sigma *= 1.05
            best_val = best_local
        else:
            sigma *= 0.95

        sigma = np.clip(sigma, 1e-3, 2.0)

        prev_x = x.copy()

    return best_val

# =========================
# COCO RUNNER (FIXED API)
# =========================
def main():
    suite = cocoex.Suite("bbob", "", "")
    observer = cocoex.Observer(
        "bbob",
        "result_folder: IQVF_FULL_RESULTS algorithm_name: IQVF_STRONG"
    )

    for problem in suite:
        observer.observe(problem)   # ✅ correct API
        print("Running:", problem.id)
        iqvf_optimize(problem)

if __name__ == "__main__":
    main()
