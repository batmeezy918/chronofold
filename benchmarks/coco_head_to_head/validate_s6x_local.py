"""Local validation: S6X vs S6 on the repo's classic BBOB-style functions.

Numpy-only (no cocoex, no cma) so it can run locally. Uses the same functions
and budgets as experiments/benchmarks/optimizer_evolution/*.

Deterministic: both optimizers get np.random.default_rng(seed) via their own
seeded loops; each problem is minimised from the SAME random start (drawn from
a fixed per-problem generator) so the comparison is apples-to-apples.

Checks:
  1. S6X best_f < S6 best_f on at least 4 of 5 functions (the improvement bar).
  2. Full suite replay is byte-identical across two runs (determinism gate).
"""

from __future__ import annotations

import hashlib
import json
import sys
import zlib

import numpy as np

sys.path.insert(0, ".")
import s6x  # noqa: E402


def sphere(x): return float(np.sum(x ** 2))

def rastrigin(x):
    return float(10 * x.size + np.sum(x ** 2 - 10 * np.cos(2 * np.pi * x)))

def rosenbrock(x):
    return float(np.sum(100 * (x[1:] - x[:-1] ** 2) ** 2 + (1 - x[:-1]) ** 2))

def ackley(x):
    return float(-20 * np.exp(-0.2 * np.sqrt(np.mean(x ** 2))) - np.exp(np.mean(np.cos(2 * np.pi * x))) + 20 + np.e)

def schwefel(x):
    return float(418.9829 * x.size - np.sum(x * np.sin(np.sqrt(np.abs(x)))))

FUNCTIONS = {
    "SPHERE": sphere,
    "RASTRIGIN": rastrigin,
    "ROSENBROCK": rosenbrock,
    "ACKLEY": ackley,
    "SCHWEFEL": schwefel,
}
DIM = 10
BUDGET = 1000


FUNCTION_IDS = {
    "SPHERE": 1,
    "RASTRIGIN": 2,
    "ROSENBROCK": 3,
    "ACKLEY": 10,
    "SCHWEFEL": 15,
}


class Problem:
    def __init__(self, f, name, seed):
        self.f = f
        self.name = name
        self.rng = np.random.default_rng(seed)
        self.dimension = DIM
        self.lower_bounds = np.full(DIM, -5.0)
        self.upper_bounds = np.full(DIM, 5.0)
        self.initial_solution = self.rng.uniform(-5, 5, DIM)
        self.final_target_hit = False
        self.id_function = FUNCTION_IDS[name]
        self.id_instance = seed % 15
        self.id = f"{name}-inst{seed}"

    def __call__(self, x):
        return self.f(np.asarray(x, dtype=np.float64))


class S6Ref:
    """Reference S6: fixed fiber x0[0], x2=2x1-x0+xi, random walk."""
    def __init__(self, p, seed):
        self.p = p
        self.rng = np.random.default_rng(seed + 31337)

    def run(self, budget):
        d = self.p.dimension
        lo, hi = self.p.lower_bounds, self.p.upper_bounds
        x0 = self.p.initial_solution
        omega_ref = np.clip(x0[0], lo[0], hi[0])
        xi_ref = (x0[2] - 2 * x0[1] + x0[0]) if d > 2 else 0.0
        x = x0.copy()
        fx = self.p(x)
        evals = 1

        def project_feasible(xx):
            y = xx.copy()
            y = np.clip(y, lo, hi)
            y[0] = omega_ref
            if y[0] < lo[0] or y[0] > hi[0]:
                return None
            if d > 2:
                y2 = 2.0 * y[1] - omega_ref + xi_ref
                if y2 < lo[2] or y2 > hi[2]:
                    return None
                y[2] = y2
            if np.any(y < lo) or np.any(y > hi):
                return None
            return y

        while evals < budget:
            z = self.rng.standard_normal(d)
            step = 0.5 * z + 0.05 * float(np.linalg.norm(z)) * z
            c = project_feasible(x + step)
            if c is None:
                continue
            fc = self.p(c)
            evals += 1
            if fc < fx:
                x, fx = c, fc
        return fx, evals


def run_once(seed):
    rows = []
    for name, f in FUNCTIONS.items():
        p = Problem(f, name, seed)
        rng_starts = np.random.default_rng(seed * 7 + 1)
        best_s6 = "inf"; best_s6x = "inf"
        s6_opt = S6Ref(p, seed)
        fx6, ev6 = s6_opt.run(BUDGET)
        best_s6 = fx6
        r = s6x.minimize(p, seed, BUDGET)
        best_s6x = r["best_f"]
        rows.append({
            "function": name,
            "s6_best_f": float(best_s6),
            "s6x_best_f": float(best_s6x),
            "s6x_wins": float(best_s6x) < float(best_s6),
            "s6x_evals": r["evaluations"],
            "s6x_restarts": r["restarts"],
        })
    return rows


def main():
    results = run_once(20260810)
    wins = sum(1 for r in results if r["s6x_wins"])
    print(json.dumps({"mode": "S6_vs_S6X_classic_d10", "budget": BUDGET, "results": results,
                      "s6x_wins_count": wins}, indent=1))
    payload = json.dumps(results, sort_keys=True).encode()
    print("results_sha256=", hashlib.sha256(payload).hexdigest())
    # determinism replay
    results2 = run_once(20260810)
    same = json.dumps(results, sort_keys=True) == json.dumps(results2, sort_keys=True)
    print("DETERMINISM_REPLAY=PASS" if same else "DETERMINISM_REPLAY=FAIL")
    if wins < 4:
        print("BAR=FAIL (s6x must win >=4/5)")
        raise SystemExit(1)
    print("BAR=PASS")


if __name__ == "__main__":
    main()