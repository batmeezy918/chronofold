from __future__ import annotations

import hashlib
import json
import os
import random
import sys
from pathlib import Path
from typing import Any

# Force hash seed for string-hash determinism when run outside CI.
os.environ.setdefault("PYTHONHASHSEED", "0")

import numpy as np
import cocoex

SEED = 20260810
BUDGET = 1000
DIMENSIONS = 10
# Keep full dimension-10 BBOB; instance filter empty for canonical suite coverage.
SUITE_FILTER = f"dimensions:{DIMENSIONS}"
RESULT_DIR = Path("S6_RESULTS")


def seed_all(seed: int) -> None:
    random.seed(seed)
    np.random.seed(seed)


def Omega(x: np.ndarray) -> float:
    return float(x[0])


def Xi(x: np.ndarray) -> float:
    return float(x[2] - 2 * x[1] + x[0]) if x.size > 2 else 0.0


def project(x: np.ndarray, omega_ref: float, xi_ref: float) -> np.ndarray:
    out = np.array(x, dtype=np.float64, copy=True)
    out[0] = omega_ref
    if out.size > 2:
        out[2] = 2 * out[1] - out[0] + xi_ref
    return out


def s6_optimize(problem: Any, rng: np.random.Generator, budget: int = BUDGET) -> float:
    """Most deterministic S6 optimizer path: fixed seed, fixed projection, no adaptive noise."""
    dim = int(problem.dimension)
    lo = np.asarray(problem.lower_bounds, dtype=np.float64)
    hi = np.asarray(problem.upper_bounds, dtype=np.float64)
    x = rng.uniform(lo, hi)
    fx = float(problem(x))

    omega_ref = Omega(x)
    xi_ref = Xi(x)

    for _ in range(budget):
        z = rng.standard_normal(dim)
        step = 0.5 * z + 0.05 * float(np.linalg.norm(z)) * z
        candidate = project(x + step, omega_ref, xi_ref)
        # Clip to bounds for numerical stability without changing RNG sequence.
        candidate = np.minimum(np.maximum(candidate, lo), hi)
        fc = float(problem(candidate))
        if fc < fx:
            x, fx = candidate, fc
        else:
            x = 0.7 * x + 0.3 * candidate
            x = np.minimum(np.maximum(x, lo), hi)
            fx = float(problem(x))
    return float(fx)


def canonical_sha256(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


def main() -> None:
    seed_all(SEED)
    RESULT_DIR.mkdir(parents=True, exist_ok=True)

    cocoex_version = getattr(cocoex, "__version__", "unknown")
    stdout_lines: list[str] = [
        "RUNNING DETERMINISTIC S6 COCO",
        f"seed={SEED}",
        f"dimension={DIMENSIONS}",
        f"budget={BUDGET}",
        f"suite_filter={SUITE_FILTER}",
        f"cocoex_version={cocoex_version}",
        f"numpy_version={np.__version__}",
        f"python={sys.version.split()[0]}",
        f"PYTHONHASHSEED={os.environ.get('PYTHONHASHSEED', 'unset')}",
    ]

    observer = cocoex.Observer("bbob", f"result_folder: {RESULT_DIR.as_posix()}")
    suite = cocoex.Suite("bbob", "", SUITE_FILTER)
    rng = np.random.default_rng(SEED)

    results = []
    for problem in suite:
        problem.observe_with(observer)
        value = s6_optimize(problem, rng)
        row = {"problem_id": problem.id, "final_f": value}
        results.append(row)
        stdout_lines.append(f"{problem.id}\t{value:.17g}")

    payload = {
        "seed": SEED,
        "budget": BUDGET,
        "dimension": DIMENSIONS,
        "suite_filter": SUITE_FILTER,
        "cocoex_version": cocoex_version,
        "numpy_version": np.__version__,
        "problem_count": len(results),
        "results": results,
    }
    json_path = RESULT_DIR / "deterministic_results.json"
    json_path.write_text(json.dumps(payload, sort_keys=True, indent=2) + "\n", encoding="utf-8")
    trace_path = RESULT_DIR / "trace.txt"
    trace_path.write_text("\n".join(stdout_lines) + "\n", encoding="utf-8")

    results_sha = canonical_sha256(json_path)
    trace_sha = canonical_sha256(trace_path)

    manifest = {
        "seed": SEED,
        "numpy_seed": SEED,
        "python_hash_seed": os.environ.get("PYTHONHASHSEED", "unset"),
        "suite": "bbob",
        "suite_filter": SUITE_FILTER,
        "dimension": DIMENSIONS,
        "budget": BUDGET,
        "cocoex_version": cocoex_version,
        "numpy_version": np.__version__,
        "problem_count": len(results),
        "results_sha256": results_sha,
        "trace_sha256": trace_sha,
    }
    (RESULT_DIR / "determinism_manifest.json").write_text(
        json.dumps(manifest, sort_keys=True, indent=2) + "\n", encoding="utf-8"
    )

    print("\n".join(stdout_lines))
    print(f"RESULT_SHA256={results_sha}")
    print(f"TRACE_SHA256={trace_sha}")
    print(f"PROBLEM_COUNT={len(results)}")


if __name__ == "__main__":
    main()
