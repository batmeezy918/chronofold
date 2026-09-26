# S6X Formal Gap Ledger — Closed-Loop Derivations

Living record of the operator-theoretic gaps found in S6X on the official COCO
head-to-head, the derivation that closes each one, and the CI evidence that
measured it. Rule of the ledger: **every gap is stated in operator form from
the loop's own state; every fix is derived, not borrowed; every fix is
measured on the official CI before the ledger advances.**

Current champion (v4): commit `d51300d` — official 83/360 per-instance wins
vs the pinned reference CMA-ES (popsize=10, sigma0=0.3, no restart),
S6X mean best_f 1083, ERL extractor at `ert_report.py`.

---

## The closed-loop operator model

State: `(m, σ, C=B·D²·Bᵀ, pc, ps, Q)`, `P_Q = Q·Qᵀ`, `P_Qp = I − P_Q`.

Sampling (per candidate, whitened):

    x − m = σ · C^{1/2} · (P_Q + α·P_Qp) · z,   z ~ N(0,I), α = 0.25, P=0.5

Elite orbit and curvature-normalized orbit:

    s_i = x_i − m_prev            (selection operator Ω)
    W   = S · C^{−1/2}            (curvature-normalized orbit, Ω∘Ξ)

Quotient adaptation (v4):

    Q ← top-r right singular vectors of (W − meancolspan(W))

Covariance (v2):

    C ← (1−c1−cmu)·C + c1·pc·pcᵀ + cmu·Σ w_i·y_i·y_iᵀ,  y_i = s_i/σ

All updates are deterministic functions of the loop's own state (single
seeded RNG, no global state).

---

## Gap log

### G0 — Missing curvature (baseline, pre-9a112da)
- **Gap**: C diagonal-only → sampling operator cannot whiten; quotient
  operates in raw geometry.
- **Fix**: full-rank CMA update (rank-one + rank-μ), eigh/B/D/invsqrtC,
  whitened quotient sampling.
- **Official evidence**: `9a112da`. 75/360 wins, 6 S6X_ONLY. Closed.

### G1 — Quotient aligned to variance, not progress
- **Gap (formal)**: step covariance `E[ΔΔᵀ] = σ²C^{1/2}(P_Q+α²P_Qp)C^{1/2}`.
  `Q` from raw elite steps converges to the dominant eigen-directions of C —
  the *flat, cheap* directions — while the complement P_Qp receives the
  stair/eigen-sensitive progress directions, each compressed by α every
  generation: per-gen signal `1−α² = 15/16` discarded on the directions the
  algorithm most needs. This is the divergence on rotated/ill-conditioned and
  "progress-on-stairs" functions (f002/f012/o‑direction families).
- **Fix (derivation)**: `Q` must track curvature-*mismatch*, i.e. the
  directions where the orbit exceeds the model's scale. Whitened orbit
  `W = S·C^{−1/2}` — the AGD composition Ω∘Ξ applied to the quotient.
- **Local gate**: BAR 4/5 deterministic; ACKLEY 0.069→0.042, SPHERE best-f
  improved. **Official evidence**: `d51300d` — 83/360 wins (was 75), S6X
  mean best_f 2436→1083. Closed.

### G2 (attempted, REJECTED) — Adaptive quotient rank
- **Gap**: r_quotient=6 fixed; full-rank-conditioned functions may need >6
  mismatch directions.
- **Fix (derivation)**: grow r_eff toward dim while the whitened orbit energy
  above rank r exceeds 10% (spectral coverage signal already inside
  `_adapt_basis`).
- **Official evidence**: `cfc0e93` — **81/360** (was 83). Rank growth tore
  3 wins from f023 (11→8) for +1 on f011. Lean Q is load-bearing on the
  multimodal families; the adaptive rank trades exactly the structure that
  wins. **REJECTED and reverted** to `d51300d`.

---

## Standing ERL (from `ert_report.py`, v4 exdata)

Budget 1000 evals, dim 10, ERT in evals (inf = not reached, failures count
at budget). S6X wins coarsest-precision rows on its strong families
(f01/f05/f14/f22 at p1–p2, f21 at all p2–p8 after losing p1); both
algorithms are `inf` at the strict 1e-6/1e-8 targets across most functions —
the head-to-head decisively remains at coarse precision under this budget.

---

## Next gap to attack (G3, candidates)

1. **Precision ladder reach**: wins currently live at p1–p4. The strict
   targets are unreachable for both → the honest ceiling is coarse precision
   at budget 1000. Raising `sigma` climb / restart budget semantics is the
   direct lever, but must not regress per-function wins.
2. **σ-runaway discipline**: divergence instances (f002/f012) trace to
   unbounded σ·D when the quotient can't tighten; the whitened-orbit fix
   reduced but did not eliminate this.
3. **α share**: 0.25 fixed. A spectral closed-form α(W) could recover
   complement signal without rank growth — but G1/G2 warn the quotient must
   stay lean; any α auto-tuning must be CI-measured before trust.