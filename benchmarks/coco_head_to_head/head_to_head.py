from __future__ import annotations

import hashlib
import json
import os
import random
from pathlib import Path
from typing import Any

import cma
import cocoex
import numpy as np

SEED = 20260810
BUDGET = 1000
DIMENSION = 10
SUITE_FILTER = f"dimensions:{DIMENSION}"
ROOT = Path("COCO_HEAD_TO_HEAD")
INVARIANT_TOL = 0.0


def omega(x: np.ndarray) -> float:
    return float(x[0])


def xi(x: np.ndarray) -> float:
    return float(x[2] - 2.0 * x[1] + x[0]) if x.size > 2 else 0.0


def project(x: np.ndarray, omega_ref: float, xi_ref: float) -> np.ndarray:
    y = np.asarray(x, dtype=np.float64).copy()
    y[0] = omega_ref
    if y.size > 2:
        y[2] = 2.0 * y[1] - y[0] + xi_ref
    return y


def _record(problem: Any, best: float, evals: int, success: bool,
            omega_residual: float | None, xi_residual: float | None,
            invariant_pass: bool | None = None) -> dict[str, Any]:
    return {
        "problem_id": problem.id,
        "function": int(problem.id_function),
        "instance": int(problem.id_instance),
        "dimension": int(problem.dimension),
        "best_f": float(best),
        "evaluations": int(evals),
        "final_target_hit": bool(success),
        "final_target": float(problem.final_target_fvalue1),
        "omega_residual_max": omega_residual,
        "xi_residual_max": xi_residual,
        "invariant_pass": invariant_pass,
    }


def s6(problem: Any, seed: int) -> dict[str, Any]:
    rng = np.random.default_rng(seed)
    lo = np.asarray(problem.lower_bounds, dtype=np.float64)
    hi = np.asarray(problem.upper_bounds, dtype=np.float64)
    x = np.asarray(problem.initial_solution, dtype=np.float64).copy()
    fx = float(problem(x))
    evals = 1
    omega_ref = omega(x)
    xi_ref = xi(x)
    max_omega_residual = 0.0
    max_xi_residual = 0.0
    invariant_pass = True

    if problem.final_target_hit:
        return _record(problem, fx, evals, True, 0.0, 0.0, True)

    while evals < BUDGET:
        z = rng.standard_normal(problem.dimension)
        step = 0.5 * z + 0.05 * float(np.linalg.norm(z)) * z
        projected = project(x + step, omega_ref, xi_ref)

        # Feasibility is separate from constitutional projection. Clipping can
        # change Ω/Ξ, so violations are recorded rather than masked.
        candidate = np.minimum(np.maximum(projected, lo), hi)
        omega_residual = abs(omega(candidate) - omega_ref)
        xi_residual = abs(xi(candidate) - xi_ref) if candidate.size > 2 else 0.0
        max_omega_residual = max(max_omega_residual, omega_residual)
        max_xi_residual = max(max_xi_residual, xi_residual)
        if omega_residual > INVARIANT_TOL or xi_residual > INVARIANT_TOL:
            invariant_pass = False

        fc = float(problem(candidate))
        evals += 1
        if fc < fx:
            x, fx = candidate, fc
        if problem.final_target_hit:
            break

    return _record(
        problem, fx, evals, bool(problem.final_target_hit),
        max_omega_residual, max_xi_residual, invariant_pass,
    )


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
    return _record(problem, best, evals, bool(problem.final_target_hit), None, None, None)


def run_algorithm(name: str, seed: int) -> list[dict[str, Any]]:
    out = ROOT / name
    out.mkdir(parents=True, exist_ok=True)
    observer_name = "H2H_S6" if name == "S6" else "H2H_CMA_ES"
    observer = cocoex.Observer("bbob", f"result_folder: {observer_name}")
    suite = cocoex.Suite("bbob", "", SUITE_FILTER)
    rows: list[dict[str, Any]] = []
    for problem in suite:
        problem.observe_with(observer)
        row = s6(problem, seed) if name == "S6" else cmaes(problem, seed)
        rows.append(row)
        print(
            f"{name}\t{row['problem_id']}\tbest={row['best_f']:.17g}"
            f"\tevals={row['evaluations']}\ttarget={int(row['final_target_hit'])}"
            f"\tinvariant={row['invariant_pass']}"
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


def compare(s6_rows: list[dict[str, Any]], cma_rows: list[dict[str, Any]]) -> dict[str, Any]:
    cma_by_id = {r["problem_id"]: r for r in cma_rows}
    counts = {"S6_ONLY": 0, "CMA_ONLY": 0, "BOTH": 0, "NEITHER": 0}
    details = []
    for a in s6_rows:
        b = cma_by_id[a["problem_id"]]
        sa, sb = a["final_target_hit"], b["final_target_hit"]
        if sa and not sb:
            cls = "S6_ONLY"
        elif sb and not sa:
            cls = "CMA_ONLY"
        elif sa and sb:
            cls = "BOTH"
        else:
            cls = "NEITHER"
        counts[cls] += 1
        details.append({
            "problem_id": a["problem_id"],
            "classification": cls,
            "s6_best_f": a["best_f"],
            "cma_best_f": b["best_f"],
            "s6_evals": a["evaluations"],
            "cma_evals": b["evaluations"],
            "runtime_ratio_cma_over_s6": (
                b["evaluations"] / a["evaluations"] if a["evaluations"] else None
            ),
        })
    summary = {
        "problem_count": len(details),
        "counts": counts,
        "s6_final_target_success_rate": sum(r["final_target_hit"] for r in s6_rows) / len(s6_rows),
        "cma_final_target_success_rate": sum(r["final_target_hit"] for r in cma_rows) / len(cma_rows),
        "s6_mean_best_f": float(np.mean([r["best_f"] for r in s6_rows])),
        "cma_mean_best_f": float(np.mean([r["best_f"] for r in cma_rows])),
        "s6_invariant_pass_rate": float(np.mean([bool(r["invariant_pass"]) for r in s6_rows])),
        "s6_max_omega_residual": float(max((r["omega_residual_max"] or 0.0) for r in s6_rows)),
        "s6_max_xi_residual": float(max((r["xi_residual_max"] or 0.0) for r in s6_rows)),
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
    random.seed(SEED)
    np.random.seed(SEED)
    ROOT.mkdir(parents=True, exist_ok=True)
    s6_rows = run_algorithm("S6", SEED)
    cma_rows = run_algorithm("CMA_ES", SEED)
    summary = compare(s6_rows, cma_rows)
    manifest = {
        "seed": SEED,
        "suite": "bbob",
        "dimension": DIMENSION,
        "budget": BUDGET,
        "problem_count": summary["problem_count"],
        "cocoex_version": getattr(cocoex, "__version__", "unknown"),
        "numpy_version": np.__version__,
        "cma_version": getattr(cma, "__version__", "unknown"),
        "s6_results_sha256": sha256(ROOT / "S6" / "results.json"),
        "cma_results_sha256": sha256(ROOT / "CMA_ES" / "results.json"),
        "comparison_sha256": sha256(ROOT / "comparison.json"),
    }
    (ROOT / "manifest.json").write_text(
        json.dumps(manifest, sort_keys=True, indent=2) + "\n", encoding="utf-8"
    )
    print("\nHEAD_TO_HEAD_SUMMARY")
    print(json.dumps({k: v for k, v in summary.items() if k != "details"}, sort_keys=True, indent=2))


if __name__ == "__main__":
    main()
