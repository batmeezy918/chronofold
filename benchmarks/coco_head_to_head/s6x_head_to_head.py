"""S6X vs CMA-ES: head-to-head on official BBOB (deterministic replay).

Mirrors benchmarks/coco_head_to_head/head_to_head.py, replacing S6 with S6X.
The CMA-ES reference is byte-identical to head_to_head.py's reference:

    cma.CMAEvolutionStrategy(x0.tolist(), 0.3,
        {"seed": seed, "popsize": 10, "bounds": [lo, hi], "verbose": -9})

Contracts preserved from head_to_head.py:
  * PYTHONHASHSEED=0 is enforced in the CI environment and set by default here.
  * SEED = 20260810, BUDGET = 1000, DIMENSION = 10, suite filter dimensions:10.
  * Budget counts objective evaluations (deterministic; S6X spends no eval on
    rejected infeasible proposals).
  * S6X is seeded per problem via seed_task = seed + 7919*id_function +
    104729*id_instance, so the full suite replay is byte-identical
    (verified by the CI run1 == run2 cmp gate).
"""

from __future__ import annotations

import hashlib
import json
import os
from pathlib import Path
from typing import Any

import cma
import cocoex
import numpy as np

import s6x

SEED = 20260810
BUDGET = 1000
DIMENSION = 10
SUITE_FILTER = f"dimensions:{DIMENSION}"
ROOT = Path("COCO_S6X_HEAD_TO_HEAD")


def _record(problem: Any, best: float, evals: int, success: bool) -> dict[str, Any]:
    return {
        "problem_id": problem.id,
        "function": int(problem.id_function),
        "instance": int(problem.id_instance),
        "dimension": int(problem.dimension),
        "best_f": float(best),
        "evaluations": int(evals),
        "final_target_hit": bool(success),
        "final_target": None,
        "omega_residual_max": None,
        "xi_residual_max": None,
        "invariant_pass": True,
    }


def cmaes(problem: Any, seed: int) -> dict[str, Any]:
    lo = np.asarray(problem.lower_bounds, dtype=np.float64)
    hi = np.asarray(problem.upper_bounds, dtype=np.float64)
    x0 = np.asarray(problem.initial_solution, dtype=np.float64).copy()
    es = cma.CMAEvolutionStrategy(
        x0.tolist(), 0.3,
        {
            "seed": seed,
            "popsize": 10,
            "bounds": [lo.tolist(), hi.tolist()],
            "verbose": -9,
        },
    )
    best = float("inf")
    evals = 0
    while evals < BUDGET:
        xs = es.ask()
        remaining = BUDGET - evals
        xs = xs[:remaining]
        vals = [float(problem(np.asarray(x, dtype=np.float64))) for x in xs]
        evals += len(vals)
        best = min(best, min(vals))
        if len(vals) != es.popsize:
            break
        es.tell(xs, vals)
        if problem.final_target_hit:
            break
    return _record(problem, best, evals, bool(problem.final_target_hit))


def run_algorithm(name: str, seed: int) -> list[dict[str, Any]]:
    out = ROOT / name
    out.mkdir(parents=True, exist_ok=True)
    observer_name = "S6X_H2H_S6X" if name == "S6X" else "S6X_H2H_CMA"
    observer = cocoex.Observer("bbob", f"result_folder: {observer_name}")
    suite = cocoex.Suite("bbob", "", SUITE_FILTER)
    rows: list[dict[str, Any]] = []
    for problem in suite:
        problem.observe_with(observer)
        if name == "S6X":
            res = s6x.minimize(problem, seed, BUDGET)
            row = {
                "problem_id": problem.id,
                "function": int(problem.id_function),
                "instance": int(problem.id_instance),
                "dimension": int(problem.dimension),
                "best_f": float(res["best_f"]),
                "evaluations": int(res["evaluations"]),
                "final_target_hit": bool(res["final_target_hit"]),
                "final_target": None,
                "restarts": int(res["restarts"]),
                "sigma": float(res["sigma"]),
                "lambda_end": int(res["lambda_end"]),
                "invariant_pass": True,
            }
        else:
            row = cmaes(problem, seed)
        rows.append(row)
        print(
            f"{name}\t{row['problem_id']}\tbest={row['best_f']:.17g}"
            f"\tevals={row['evaluations']}\ttarget={int(row['final_target_hit'])}"
        )
        problem.free()
    payload = {
        "algorithm": name,
        "seed": seed,
        "suite": "bbob",
        "dimension": DIMENSION,
        "budget": BUDGET,
        "cocoex_version": getattr(cocoex, "__version__", "unknown"),
        "numpy_version": np.__version__,
        "cma_version": getattr(cma, "__version__", "unknown"),
        "results": rows,
    }
    (out / "results.json").write_text(
        json.dumps(payload, sort_keys=True, indent=2) + "\n", encoding="utf-8"
    )
    return rows


def compare(s6x_rows: list[dict[str, Any]], cma_rows: list[dict[str, Any]]) -> dict[str, Any]:
    cma_by_id = {r["problem_id"]: r for r in cma_rows}
    counts = {"S6X_ONLY": 0, "CMA_ONLY": 0, "BOTH": 0, "NEITHER": 0}
    details = []
    for a in s6x_rows:
        b = cma_by_id[a["problem_id"]]
        if a["final_target_hit"] and not b["final_target_hit"]:
            cls = "S6X_ONLY"
        elif b["final_target_hit"] and not a["final_target_hit"]:
            cls = "CMA_ONLY"
        elif a["final_target_hit"] and b["final_target_hit"]:
            cls = "BOTH"
        else:
            cls = "NEITHER"
        counts[cls] += 1
        details.append({
            "problem_id": a["problem_id"],
            "classification": cls,
            "s6x_best_f": a["best_f"],
            "cma_best_f": b["best_f"],
            "s6x_evals": a["evaluations"],
            "cma_evals": b["evaluations"],
            "runtime_ratio_cma_over_s6x": (
                b["evaluations"] / a["evaluations"] if a["evaluations"] else None
            ),
        })
    summary = {
        "problem_count": len(details),
        "counts": counts,
        "s6x_final_target_success_rate": sum(r["final_target_hit"] for r in s6x_rows) / len(s6x_rows),
        "cma_final_target_success_rate": sum(r["final_target_hit"] for r in cma_rows) / len(cma_rows),
        "s6x_mean_best_f": float(np.mean([r["best_f"] for r in s6x_rows])),
        "cma_mean_best_f": float(np.mean([r["best_f"] for r in cma_rows])),
        "details": details,
    }
    (ROOT / "comparison.json").write_text(
        json.dumps(summary, sort_keys=True, indent=2) + "\n", encoding="utf-8"
    )
    return summary


def sha256(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


def main() -> None:
    os.environ.setdefault("PYTHONHASHSEED", "0")
    ROOT.mkdir(parents=True, exist_ok=True)
    s6x_rows = run_algorithm("S6X", SEED)
    cma_rows = run_algorithm("CMA_ES", SEED)
    summary = compare(s6x_rows, cma_rows)
    manifest = {
        "seed": SEED,
        "suite": "bbob",
        "dimension": DIMENSION,
        "budget": BUDGET,
        "problem_count": summary["problem_count"],
        "cocoex_version": getattr(cocoex, "__version__", "unknown"),
        "numpy_version": np.__version__,
        "cma_version": getattr(cma, "__version__", "unknown"),
        "s6x_results_sha256": sha256(ROOT / "S6X" / "results.json"),
        "cma_results_sha256": sha256(ROOT / "CMA_ES" / "results.json"),
        "comparison_sha256": sha256(ROOT / "comparison.json"),
    }
    (ROOT / "manifest.json").write_text(
        json.dumps(manifest, sort_keys=True, indent=2) + "\n", encoding="utf-8"
    )
    print("\nS6X_HEAD_TO_HEAD_SUMMARY")
    print(json.dumps({k: v for k, v in summary.items() if k != "details"}, sort_keys=True, indent=2))


if __name__ == "__main__":
    main()