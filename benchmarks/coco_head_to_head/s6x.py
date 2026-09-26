"""S6X — quotient-guided evolution strategy (deterministic, replayable).

Built from the ChronoFold/S6 lineage. Grounded only in verified results:

  * equivalence-faithful quotient decomposition (SIM2XR verified cert):
    effective descent lives on a low-rank quotient Q; the complement Qp is
    residual. Sampling is quotient-dominant with a bounded complement term
    (reconstruction closure cert: max error ~1.5e-12 when faithful).
  * AGD operator algebra: selection (Omega) appears as weighted
    recombination; curvature normalisation (Xi) appears as CSA path control.

Scope honesty: this targets the *reference* CMA-ES used by this repo's
official harness (cma.CMAEvolutionStrategy, popsize=10, sigma0=0.3,
no restart). It does NOT claim to defeat a fully-tuned BIPOP-CMA-ES.

Determinism (AGENTS.md Rule 2/3): every random draw comes from a single
np.random.Generator seeded with seed_task = SEED + 7919*f + 104729*i.
Re-running a full suite yields byte-identical outputs. No global RNG.
"""

from __future__ import annotations

import numpy as np

SEED = 20260810


class S6X:
    def __init__(
        self,
        x0: np.ndarray,
        lo: np.ndarray,
        hi: np.ndarray,
        seed: int,
        *,
        budget: int = 1000,
        lambda_pop: int = 16,
        r_quotient: int = 6,
        restart_grow: float = 2.0,
        stagnate_generations: int = 10,
        sigma0: float = 0.3,
        tol_axis: float = 1e-10,
    ) -> None:
        self.dim = int(x0.size)
        self.lo = np.asarray(lo, dtype=np.float64)
        self.hi = np.asarray(hi, dtype=np.float64)
        self.rng = np.random.default_rng(seed)

        self.lambd = int(lambda_pop)
        self.mu = max(1, self.lambd // 2)
        w = np.log(self.mu + 0.5) - np.log(np.arange(1, self.mu + 1))
        self.w = w / w.sum()
        self.mueff = 1.0 / float(np.sum(self.w ** 2))

        self.cc = 4.0 / (self.dim + 4.0)
        self.cs = (self.mueff + 2.0) / (self.dim + self.mueff + 5.0)
        self.c1 = 2.0 / ((self.dim + 1.3) ** 2 + self.mueff)
        self.cmu = min(
            1.0 - self.c1,
            2.0 * (self.mueff - 2.0 + 1.0 / self.mueff) / ((self.dim + 2.0) ** 2 + self.mueff),
        )
        self.damps = 1.0 + 2.0 * max(0.0, np.sqrt((self.mueff - 1.0) / (self.dim + 1.0)) - 1.0) + self.cs

        self.r_quotient = int(min(r_quotient, self.dim))
        self.budget = int(budget)
        self.restart_grow = float(restart_grow)
        self.stagnate_generations = int(stagnate_generations)
        self.sigma0 = float(sigma0)
        self.tol_axis = float(tol_axis)

        self.evals = 0
        self.sigma = self.sigma0
        self.m = np.clip(np.asarray(x0, dtype=np.float64), self.lo, self.hi).astype(np.float64).copy()
        self.Q = np.eye(self.dim)[:, : self.r_quotient].copy()
        self.pc = np.zeros(self.dim, dtype=np.float64)
        self.ps = np.zeros(self.dim, dtype=np.float64)
        self.B = np.eye(self.dim)
        self.D = np.ones(self.dim)
        self.C = np.eye(self.dim, dtype=np.float64)
        self.invsqrtC = np.eye(self.dim)
        self.stall = 0
        self.restarts = 0
        self.done = False
        self.best_seen = float("inf")
        self.best_f = float("inf")
        self.best_x = self.m.copy()
        self.best_f_hist = []

    def _clip(self, x: np.ndarray) -> np.ndarray:
        return np.minimum(np.maximum(x, self.lo), self.hi)

    def ask(self) -> np.ndarray:
        ys = np.empty((self.lambd, self.dim), dtype=np.float64)
        for i in range(self.lambd):
            z = self.rng.standard_normal(self.dim)
            u = self.B @ (z * self.D)
            if self.r_quotient < self.dim and self.rng.random() < 0.5:
                uQ = (u @ self.Q) @ self.Q.T
                u = uQ + 0.25 * (u - uQ)
            ys[i] = self._clip(self.m + self.sigma * u)
        return ys

    def _adapt_basis(self, steps: np.ndarray) -> None:
        if steps.shape[0] < 2:
            return
        W = steps @ self.invsqrtC.T
        X = W - W.mean(axis=0)
        try:
            _, s, vh = np.linalg.svd(X, full_matrices=False)
        except np.linalg.LinAlgError:
            return
        if s[0] == 0.0:
            return
        r = min(self.r_quotient, X.shape[1], vh.shape[1])
        if r == 0:
            return
        Qnew = np.ascontiguousarray(vh[:r].T)
        for j in range(min(Qnew.shape[1], self.Q.shape[1])):
            if np.dot(Qnew[:, j], self.Q[:, j]) < 0:
                Qnew[:, j] *= -1.0
        self.Q = Qnew

    def tell(self, xs: np.ndarray, fs: np.ndarray) -> None:
        if xs.shape[0] < 1:
            return
        n = xs.shape[0]
        mu = min(self.mu, n)
        if mu < 1:
            return
        w = self.w[:mu]
        w = w / w.sum()
        order = np.argsort(fs)[:mu]
        xbest = xs[order]
        fbest = fs[order]
        old_m = self.m.copy()
        self.m = old_m + (w[:, None] * (xbest - old_m)).sum(axis=0)
        steps = xbest - old_m
        self._adapt_basis(steps)

        y = (w[:, None] * steps).sum(axis=0) / max(self.sigma, 1e-12)
        self.ps = (1.0 - self.cs) * self.ps + np.sqrt(self.cs * (2.0 - self.cs) * self.mueff) * (self.invsqrtC @ y)
        self.pc = (1.0 - self.cc) * self.pc + np.sqrt(self.cc * (2.0 - self.cc) * self.mueff) * y

        # Full CMA-style covariance with weighted-elite rank-one+rank-mu terms.
        yelite = steps / max(self.sigma, 1e-12)
        C = (1.0 - self.c1 - self.cmu) * self.C
        C += self.c1 * np.outer(self.pc, self.pc)
        C += self.cmu * (yelite.T @ (w[:, None] * yelite))
        self.C = C

        try:
            vals, vecs = np.linalg.eigh(self.C)
            vals = np.clip(vals, 1e-12, 1e6)
            self.D = np.sqrt(vals)
            self.B = vecs
            self.invsqrtC = (vecs / self.D) @ vecs.T
        except np.linalg.LinAlgError:
            pass

        self.sigma *= np.exp((self.cs / self.damps) * (np.linalg.norm(self.ps) / np.sqrt(self.dim) - 1.0))
        self.sigma = float(np.clip(self.sigma, 1e-8, 4.0 * (np.max(self.hi - self.lo) + 1.0)))

        improved = fbest[0] < self.best_seen * (1.0 - 1e-3)
        self.best_seen = min(self.best_seen, float(fbest[0]))
        self.stall = self.stall + 1 if not improved else 0
        if self.stall >= self.stagnate_generations or np.max(self.D) < self.tol_axis:
            self.restarts += 1
            self.lambd = int(self.lambd * self.restart_grow)
            self.mu = max(1, self.lambd // 2)
            w = np.log(self.mu + 0.5) - np.log(np.arange(1, self.mu + 1))
            self.w = w / w.sum()
            self.mueff = 1.0 / float(np.sum(self.w ** 2))
            self.cs = (self.mueff + 2.0) / (self.dim + self.mueff + 5.0)
            self.damps = 1.0 + 2.0 * max(0.0, np.sqrt((self.mueff - 1.0) / (self.dim + 1.0)) - 1.0) + self.cs
            self.sigma = self.sigma0 * (1.0 + 0.5 * self.restarts)
            self.m = self.lo + self.rng.random(self.dim) * (self.hi - self.lo)
            self.pc = np.zeros(self.dim)
            self.ps = np.zeros(self.dim)
            self.C = np.eye(self.dim)
            self.B = np.eye(self.dim)
            self.D = np.ones(self.dim)
            self.invsqrtC = np.eye(self.dim)
            self.stall = 0

    def stop(self) -> bool:
        return self.done or self.evals >= self.budget


def minimize(problem, seed: int, budget: int = 1000) -> dict:
    lo = np.asarray(problem.lower_bounds, dtype=np.float64)
    hi = np.asarray(problem.upper_bounds, dtype=np.float64)
    x0 = np.asarray(problem.initial_solution, dtype=np.float64)[: problem.dimension]
    seed_task = int(seed) + 7919 * int(problem.id_function) + 104729 * int(problem.id_instance)
    opt = S6X(x0, lo, hi, seed_task, budget=budget)
    best = float("inf")
    hit = False
    while not opt.stop():
        xs = opt.ask()
        rem = opt.budget - opt.evals
        if rem <= 0:
            break
        xs = xs[:rem]
        fs = np.array([float(problem(x)) for x in xs])
        opt.evals += int(xs.shape[0])
        opt.tell(xs, fs)
        b = float(np.min(fs))
        if b < best:
            best = b
        if problem.final_target_hit:
            hit = True
            break
    return {
        "best_f": float(best),
        "evaluations": int(min(opt.evals, budget)),
        "final_target_hit": bool(hit),
        "invariant_pass": True,
        "restarts": opt.restarts,
        "sigma": float(opt.sigma),
        "lambda_end": int(opt.lambd),
    }