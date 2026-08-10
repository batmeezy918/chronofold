from __future__ import annotations

import hashlib
import json
import os
import random
from pathlib import Path
from typing import Any

import numpy as np
import cocoex

SEED = 20260810
BUDGET = 1000
DIMENSIONS = 10
RESULT_DIR = Path("S6_RESULTS")


def seed_all(seed: int) -> None:
    random.seed(seed)
    np.random.seed(seed)


def Omega(x: np.ndarray) -> float:
    return float(x[0])


def Xi(x: np.ndarray) -> float:
    return float(x[2] - 2 * x[1] + x[0]) if x.size > 2 else 0.0


def project(x: np.ndarray, omega_ref: float, xi_ref: float) -> np.ndarray:
    out = x.copy()
    out[0] = omega_ref
    if out.size > 2:
        out[2] = 2 * out[1] - out[0] + xi_ref
    return out


def s6_optimize(problem: Any, rng: np.random.Generator, budget: int = BUDGET) -> float:
    dim = int(problem.dimension)
    x = rng.uniform(np.asarray(problem.lower_bounds), np.asarray(problem.upper_bounds))
    fx = float(problem(x))

    omega_ref = Omega(x)
    xi_ref = Xi(x)

    for _ in range(budget):
        z = rng.standard_normal(dim)
        candidate = x + 0.5 * z + 0.05 * np.linalg.norm(z) * z
        candidate = project(candidate, omega_ref, xi_ref)
        fc = float(problem(candidate))
        if fc < fx:
            x, fx = candidate, fc
        else:
            x = 0.7 * x + 0.3 * candidate
            fx = float(problem(x))
    return fx


def canonical_sha256(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


def main() -> None:
    seed_all(SEED)
    RESULT_DIR.mkdir(parents=True, exist_ok=True)
    stdout_lines: list[str] = ["RUNNING DETERMINISTIC S6 COCO", f"seed={SEED}", f"dimension={DIMENSIONS}", f"budget={BUDGET}"]

    observer = cocoex.Observer("bbob", f"result_folder: {RESULT_DIR.as_posix()}")
    suite = cocoex.Suite("bbob", "", f"dimensions:{DIMENSIONS}")
    rng = np.random.default_rng(SEED)

    results = []
    for problem in suite:
        value = s6_optimize(problem, rng)
        row = {"problem_id": problem.id, "final_f": value}
        results.append(row)
        stdout_lines.append(f"{problem.id}\t{value:.17g}")

    payload = {
        "seed": SEED,
        "budget": BUDGET,
        "dimension": DIMENSIONS,
        "problem_count": len(results),
        "results": results,
    }
    json_path = RESULT_DIR / "deterministic_results.json"
    json_path.write_text(json.dumps(payload, sort_keys=True, indent=2) + "\n")
    trace_path = RESULT_DIR / "trace.txt"
    trace_path.write_text("\n".join(stdout_lines) + "\n")

    manifest = {
        "seed": SEED,
        "numpy_seed": SEED,
        "python_hash_seed": os.environ.get("PYTHONHASHSEED", "unset"),
        "suite": "bbob",
        "dimension": DIMENSIONS,
        "budget": BUDGET,
        "results_sha256": canonical_sha256(json_path),
        "trace_sha256": canonical_sha256(trace_path),
    }
    (RESULT_DIR / "determinism_manifest.json").write_text(json.dumps(manifest, sort_keys=True, indent=2) + "\n")

    print("\n".join(stdout_lines))
    print(f"RESULT_SHA256={manifest['results_sha256']}")
    print(f"TRACE_SHA256={manifest['trace_sha256']}")


if __name__ == "__main__":
    main()
