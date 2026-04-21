import json
from pathlib import Path

import numpy as np

try:
    import cma  # type: ignore
except Exception:
    cma = None

try:
    import cocoex  # type: ignore
except Exception:
    cocoex = None


def objective(x):
    x = np.asarray(x, dtype=float)
    return float(np.sum(x * x))


def run_cma_es(dim=5):
    x0 = np.zeros(dim)
    sigma0 = 0.5
    if cma is None:
        return {
            "optimizer": "fallback",
            "best_f": objective(x0),
            "iterations": 0,
        }

    es = cma.CMAEvolutionStrategy(x0, sigma0, {"verbose": -9})
    while not es.stop() and es.countiter < 20:
        xs = es.ask()
        es.tell(xs, [objective(x) for x in xs])
    best = es.result.fbest if es.result is not None else objective(x0)
    return {
        "optimizer": "cma-es",
        "best_f": float(best),
        "iterations": int(es.countiter),
    }


def main():
    out = Path("results")
    out.mkdir(parents=True, exist_ok=True)

    payload = {
        "snap": run_cma_es(),
        "coco_available": cocoex is not None,
        "numpy_version": np.__version__,
    }

    (out / "snap_results.json").write_text(json.dumps(payload, indent=2))
    (out / "summary.txt").write_text(
        "SNAP benchmark completed\n"
        f"optimizer={payload['snap']['optimizer']}\n"
        f"best_f={payload['snap']['best_f']}\n"
        f"iterations={payload['snap']['iterations']}\n"
        f"coco_available={payload['coco_available']}\n"
    )
    print(json.dumps(payload))


if __name__ == "__main__":
    main()
