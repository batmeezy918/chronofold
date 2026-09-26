"""ERL/ERT standings extractor for the S6X head-to-head.

Computes the official COCO-style ERT (expected runtime, in function
evaluations, to reach a target precision) per bh ob function from the raw
cocoex trajectory files collected by the harness observer:

    exdata/<ALG>/data_fN/bbobexp_fN_DIM10.dat

Each `%` comment line begins a new instance block; each data row is
`eval_count g_count best-noise-free-fitness-Fopt ...`. The precision to
target column is the third field: it is ACHIEVED when it drops to
<= 10^-p for p in 1..8 (bbob's default precision ladder, 1e-8 floor).

ERT follows the standard COCO convention:
    ERT(target) = (sum of successful runtimes + n_failed * budget) / n_success
    ERT = inf when n_success == 0.

The published BBOB tables that go on the leaderboards are exactly these
ERT numbers per (function, dimension, target). This extractor emits
`standings.json` so S6X and the pinned reference CMA-ES can be placed
against archived tables.

Deterministic: only reads CI-generated exdata; no randomness.
"""

from __future__ import annotations

import json
import re
from pathlib import Path

PRECISIONS = [1, 2, 3, 4, 5, 6, 7, 8]
TARGET_VALUES = {p: 10.0 ** (-p) for p in PRECISIONS}


def parse_instance_blocks(dat: Path) -> list[list[tuple[int, float]]]:
    """Return per-instance lists of (evals, best-Fopt) records."""
    blocks: list[list[tuple[int, float]]] = []
    cur: list[tuple[int, float]] = []
    for line in dat.read_text(errors="ignore").splitlines():
        if line.startswith("%"):
            if cur:
                blocks.append(cur)
                cur = []
            continue
        parts = line.split()
        if len(parts) < 3:
            continue
        try:
            evals = int(parts[0])
            val = float(parts[2])
        except ValueError:
            continue
        cur.append((evals, val))
    if cur:
        blocks.append(cur)
    return blocks


def evals_to_target(records: list[tuple[int, float]], target: float) -> int:
    """First eval where best noise-free fitness relative to Fopt <= target.

    A negative record means the optimum was crossed (or the f0 estimate is
    above the true value); it qualifies for every precision at that eval.
    """
    for evals, val in records:
        if val <= target:
            return evals
    return -1  # not reached within budget


def funct_name(func_id: int) -> str:
    """Authoritative BBOB noiseless-suite names (optuna/bbob docs & the bbob
    workshop paper, Hansen et al. 2009). Verified, not guessed."""
    base = {
        1: "Sphere Function",
        2: "Separable Ellipsoidal Function",
        3: "Rastrigin Function",
        4: "Bueche-Rastrigin Function",
        5: "Linear Slope",
        6: "Attractive Sector Function",
        7: "Step Ellipsoidal Function",
        8: "Rosenbrock Function, original",
        9: "Rosenbrock Function, rotated",
        10: "Ellipsoidal Function",
        11: "Discus Function",
        12: "Bent Cigar Function",
        13: "Sharp Ridge Function",
        14: "Different Powers Function",
        15: "Rastrigin Function",
        16: "Weierstrass Function",
        17: "Schaffer's F7 Function",
        18: "Schaffer's F7 Function, moderately ill-conditioned",
        19: "Composite Griewank-Rosenbrock Function F8F2",
        20: "Schwefel Function",
        21: "Gallagher's Gaussian 101-me Peaks Function",
        22: "Gallagher's Gaussian 21-hi Peaks Function",
        23: "Katsuura Function",
        24: "Lunacek bi-Rastrigin Function",
    }
    return base.get(func_id, f"f{func_id}")


def ert_rows(records_list: list[list[tuple[int, float]]], budget: int) -> dict:
    rows = {}
    for p in PRECISIONS:
        target = TARGET_VALUES[p]
        successes = 0
        total = 0.0
        for records in records_list:
            t = evals_to_target(records, target)
            if t < 0:
                total += float(budget)
            else:
                successes += 1
                total += float(t)
        rows[p] = {
            "target": target,
            "successes": successes,
            "total_runs": len(records_list),
            "ert_evaluations": (round(total / successes, 2) if successes else None),
        }
    return rows


def build(algo_dir: Path, budget: int = 1000) -> dict:
    data_root = algo_dir
    funcs = {}
    dims_seen: set[int] = set()
    for dat in sorted(data_root.glob("data_f*/bbobexp_f*_DIM*.dat")):
        m = re.search(r"data_f(\d+)", str(dat))
        f_ = int(m.group(1)) if m else None
        if f_ is None:
            continue
        dm = re.search(r"_DIM(\d+)\.dat", str(dat))
        if dm:
            dims_seen.add(int(dm.group(1)))
        blocks = parse_instance_blocks(dat)
        if not blocks:
            continue
        funcs[str(f_)] = {
            "function": f"f{f_:02d}",
            "name": funct_name(f_),
            "dimension": int(dm.group(1)) if dm else None,
            "instances": len(blocks),
            "ert": ert_rows(blocks, budget),
            "best_precision_reached": max(
                p for p in PRECISIONS if any(
                    evals_to_target(r, TARGET_VALUES[p]) >= 0 for r in blocks
                )
            ) if any(evals_to_target(r, 1e-8) >= 0 for r in blocks) else None,
        }
    return {
        "algo_dir": str(algo_dir),
        "budget": budget,
        "dimensions": sorted(dims_seen),
        "functions": funcs,
    }


def main() -> None:
    import argparse

    ap = argparse.ArgumentParser()
    ap.add_argument("exdata", type=Path)
    ap.add_argument("--budget", type=int, default=1000)
    ap.add_argument("--out", type=Path, default=Path("standings.json"))
    args = ap.parse_args()

    standings = {"budget": args.budget, "algorithms": {}}
    all_labs = {}
    for child in sorted(p for p in args.exdata.iterdir() if p.is_dir()):
        standings["algorithms"][child.name] = build(child, args.budget)
        all_labs.update(standings["algorithms"][child.name]["functions"])
    standings["compare"] = {}
    if len(standings["algorithms"]) >= 2:
        names = list(standings["algorithms"])
        for fid, info in all_labs.items():
            a = standings["algorithms"][names[0]]["functions"].get(fid)
            b = standings["algorithms"][names[1]]["functions"].get(fid)
            if not a or not b:
                continue
            wins = {p: 0 for p in PRECISIONS}
            for p in PRECISIONS:
                ea = a["ert"][p]["ert_evaluations"]
                eb = b["ert"][p]["ert_evaluations"]
                if ea is not None and eb is not None:
                    wins[p] = -1 if ea < eb else (1 if eb < ea else 0)
                elif ea is not None:
                    wins[p] = -1
                elif eb is not None:
                    wins[p] = 1
            standings["compare"][fid] = {
                "function": a["function"],
                "name": a["name"],
                "wins_naming": wins,
            }
    args.out.write_text(json.dumps(standings, indent=2, sort_keys=True) + "\n")
    print(f"STANDINGS_WRITTEN={args.out}")


if __name__ == "__main__":
    main()