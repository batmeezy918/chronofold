"""Graph500-style quotient projection sweep on COCO for S6X vs CMA-ES.

Mirrors the discipline of the repo's graph500 projection sweeps: run the
official benchmark across a scale ladder, and emit per-scale evidence
(manifest, hashes, verdict) so the highest validated scale and the per-scale
win rates are auditable.

Here "scale" = BBOB dimension. The quotient rank r_quotient and step budget
scale with dimension the way graph500's vertex count scales with scale:

    BUDGET   = dim * 100                      (per-problem eval budget)
    r_quotient = min(6, dim)                  (lean quotient in low dim)

Both algorithms are run with the *exact* observer/seed/cma-config protocol
of the head-to-head harness. Every dimension produces:

  * results.json per algorithm   (same schema as the head-to-head)
  * evals-to-target trajectory   (cocoex observer, consumed by ert_report.py)
  * manifest row: dim, funcs, instances, budget, r_quotient, algorithm hashes

The sweep is deterministic: single SEED, no global RNG, PYTHONHASHSEED=0.

Usage:
    python coco_projection_sweep.py --dims 2,3,5,10,20,40 --root COCO_PROJECTION
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
ROOT = Path("COCO_S6X_PROJECTION")
DIM_BUDGET_MULT = 100
QUOTIENT_CAP = 6


def sha256(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def record(problem: Any, best: float, evals: int, success: bool,
           restarts: int | None, sigma: float | None, lambd_end: int | None) -> dict[str, Any]:
    return {
        "problem_id": problem.id,
        "function": int(problem.id_function),
        "instance": int(problem.id_instance),
        "dimension": int(problem.dimension),
        "best_f": float(best),
        "evaluations": int(evals),
        "final_target_hit": bool(success),
        "restarts": restarts,
        "sigma": sigma,
        "lambda_end": lambd_end,
    }


def run_cmaes(problem: Any, budget: int) -> dict[str, Any]:
    lo = np.asarray(problem.lower_bounds, dtype=np.float64)
    hi = np.asarray(problem.upper_bounds, dtype=np.float64)
    x0 = np.asarray(problem.initial_solution, dtype=np.float64).copy()
    es = cma.CMAEvolutionStrategy(
        x0.tolist(), 0.3,
        {"seed": SEED, "popsize": 10, "bounds": [lo.tolist(), hi.tolist()], "verbose": -9},
    )
    best = float("inf")
    evals = 0
    while evals < budget:
        xs = es.ask()
        remaining = budget - evals
        xs = xs[:remaining]
        vals = [float(problem(np.asarray(x, dtype=np.float64))) for x in xs]
        evals += len(vals)
        best = min(best, min(vals))
        if len(vals) != es.popsize:
            break
        es.tell(xs, vals)
        if problem.final_target_hit:
            break
    return record(problem, best, evals, bool(problem.final_target_hit), None, None, None)


def run_algorithm(name: str, dim: int, budget: int, rq: int) -> tuple[dict[str, Any], list[dict[str, Any]]]:
    out = ROOT / f"dim{dim}" / name
    out.mkdir(parents=True, exist_ok=True)
    exroot = ROOT / f"dim{dim}" / "exdata"
    exroot.mkdir(parents=True, exist_ok=True)
    observer_dir = exroot / name
    observer_dir.mkdir(parents=True, exist_ok=True)
    observer_name = str(observer_dir.resolve())
    observer = cocoex.Observer("bbob", f"result_folder: {observer_name}")
    suite = cocoex.Suite("bbob", "", f"dimensions:{dim}")
    rows: list[dict[str, Any]] = []
    for problem in suite:
        problem.observe_with(observer)
        if name == "S6X":
            res = s6x.minimize(problem, SEED, budget, r_quotient=rq)
            row = record(problem, res["best_f"], res["evaluations"],
                         res["final_target_hit"], res["restarts"], res["sigma"], res["lambda_end"])
        else:
            row = run_cmaes(problem, budget)
        rows.append(row)
        print(f"{name}\tdim={dim}\t{row['problem_id']}\tbest={row['best_f']:.17g}\tevals={row['evaluations']}", flush=True)
        problem.free()
    payload = {
        "algorithm": name, "seed": SEED, "suite": "bbob", "dimension": dim,
        "budget": budget, "r_quotient": rq,
        "cocoex_version": getattr(cocoex, "__version__", "unknown"),
        "numpy_version": np.__version__,
        "cma_version": getattr(cma, "__version__", "unknown"),
        "results": rows,
    }
    (out / "results.json").write_text(json.dumps(payload, sort_keys=True, indent=2) + "\n", encoding="utf-8")
    return payload, rows


def compare_dim(s6x_rows: list[dict[str, Any]], cma_rows: list[dict[str, Any]]) -> dict[str, Any]:
    cma_by_id = {r["problem_id"]: r for r in cma_rows}
    s6x_wins = 0
    cma_wins = 0
    hits = {"S6X_ONLY": 0, "CMA_ONLY": 0, "BOTH": 0, "NEITHER": 0}
    details = []
    for a in s6x_rows:
        b = cma_by_id[a["problem_id"]]
        cls = ("BOTH" if a["final_target_hit"] and b["final_target_hit"]
               else "S6X_ONLY" if a["final_target_hit"]
               else "CMA_ONLY" if b["final_target_hit"] else "NEITHER")
        hits[cls] += 1
        if a["best_f"] < b["best_f"]:
            s6x_wins += 1
        elif b["best_f"] < a["best_f"]:
            cma_wins += 1
        details.append({"problem_id": a["problem_id"], "classification": cls,
                        "s6x_best_f": a["best_f"], "cma_best_f": b["best_f"],
                        "s6x_evals": a["evaluations"], "cma_evals": b["evaluations"]})
    return {"problem_count": len(details), "hits": hits,
            "s6x_win_count": s6x_wins, "cma_win_count": cma_wins,
            "details": details}


def sweep(dims: list[int]) -> dict[str, Any]:
    manifest = {"seed": SEED, "dims": dims, "max_dim": max(dims),
                "budget_per_dim": {d: d * DIM_BUDGET_MULT for d in dims},
                "r_quotient_per_dim": {d: min(d, QUOTIENT_CAP) for d in dims}}
    verdicts = {}
    for dim in dims:
        d2 = ROOT / f"dim{dim}"
        d2.mkdir(parents=True, exist_ok=True)
        budget = dim * DIM_BUDGET_MULT
        rq = min(dim, QUOTIENT_CAP)
        print(f"\n=== DIM {dim}  budget={budget}  rq={rq} ===", flush=True)
        sx_payload, sx_rows = run_algorithm("S6X", dim, budget, rq)
        cm_payload, cm_rows = run_algorithm("CMA_ES", dim, budget, rq)
        comp = compare_dim(sx_rows, cm_rows)
        (d2 / "comparison.json").write_text(json.dumps(comp, indent=2, sort_keys=True) + "\n")
        sha_sx = sha256(d2 / "S6X" / "results.json")
        sha_cm = sha256(d2 / "CMA_ES" / "results.json")
        verdicts[str(dim)] = {
            "budget": budget, "r_quotient": rq,
            "s6x_win_count": comp["s6x_win_count"],
            "cma_win_count": comp["cma_win_count"],
            "problem_count": comp["problem_count"],
            "s6x_results_sha256": sha_sx,
            "cma_results_sha256": sha_cm,
        }
        print(f"DIMV{dim}\ts6x_wins={comp['s6x_win_count']}/{comp['problem_count']}"
              f"\tcma_wins={comp['cma_win_count']}"
              f"\thits={comp['hits']}\tsha_s6x={sha_sx[:12]}", flush=True)
    manifest["verdicts"] = verdicts
    max_dim_w = max((d for d in dims), key=lambda d: verdicts[str(d)]["s6x_win_count"])
    manifest["best_win_dim"] = max_dim_w
    (ROOT / "manifest.json").write_text(json.dumps(manifest, indent=2, sort_keys=True) + "\n")
    print("\nPROJECTION_MANIFEST")
    print(json.dumps(manifest, indent=1, sort_keys=True))
    return manifest


def verify_replay(dim: int) -> bool:
    """Re-run the S6X pass for `dim` into a scratch root and byte-compare the
    S6X results.json against the recorded manifest hash. Mirrors the harness's
    two-pass determinism gate at sweep level."""
    global ROOT
    recorded = json.loads((ROOT / "manifest.json").read_text())["verdicts"][str(dim)]
    scratch = ROOT / f".replay_verify"
    saved, ROOT = ROOT, scratch
    try:
        sx_payload, sx_rows = run_algorithm("S6X", dim, recorded["budget"], recorded["r_quotient"])
    finally:
        ROOT = saved
    new_hash = sha256(scratch / f"dim{dim}" / "S6X" / "results.json")
    ok = new_hash == recorded["s6x_results_sha256"]
    print(f"REPLAY{dim}\t{'PASS' if ok else 'FAIL'}\t{new_hash} (recorded {recorded['s6x_results_sha256']})")
    import shutil
    shutil.rmtree(scratch, ignore_errors=True)
    return ok


def main() -> None:
    import argparse
    ap = argparse.ArgumentParser()
    ap.add_argument("--dims", default="2,3,5,10,20,40")
    ap.add_argument("--root", type=Path, default=ROOT)
    ap.add_argument("--verify-dim", type=int, default=2,
                    help="replay S6X for this dim at the end and compare hashes (determinism gate)")
    args = ap.parse_args()
    dims = [int(x) for x in args.dims.split(",")]
    # bind module-global ROOT (used by run_algorithm/verify_replay) from CLI
    globals()["ROOT"] = args.root
    os.environ.setdefault("PYTHONHASHSEED", "0")
    sweep(dims)
    if args.verify_dim in dims:
        if not verify_replay(args.verify_dim):
            raise SystemExit(f"REPLAY{args.verify_dim} failed: deterministic replay mismatch")
    else:
        raise SystemExit(f"--verify-dim {args.verify_dim} not in {dims}")


if __name__ == "__main__":
    main()