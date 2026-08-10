# CLAIM MATRIX

All mathematical and technical claims in the ChronoFold repository are strictly classified below into exactly one of three categories: `FORMALLY_PROVED`, `EMPIRICALLY_VERIFIED`, or `CONJECTURE`.

## 1. FORMALLY_PROVED

Claims whose correctness is proved inside Lean 4 specification files and verified by the Lean compiler.

| Claim ID | Title / Definition | Source File | Status |
| --- | --- | --- | --- |
| CLAIM_001 | `TBar_sound` (Well-defined descended operators) | `Verify.lean` | FORMALLY_PROVED |
| CLAIM_002 | `descends` (Existence of quotient operator) | `Verify.lean` | FORMALLY_PROVED |
| CLAIM_003 | `uniqueMorph_unique` (Universal initiality of Q*) | `Verify.lean` | FORMALLY_PROVED |
| CLAIM_004 | `interchangeable_iff` (Interchangeability coincides with AGD Equivalence) | `Verify.lean` | FORMALLY_PROVED |
| CLAIM_005 | `admission_iff_descends` (Admissibility condition holds iff descended operator behaves as identity) | `Verify.lean` | FORMALLY_PROVED |
| CLAIM_006 | `replay_preserves_invariants` (Sequential operator replay preserves invariants via list induction) | `Verify.lean` | FORMALLY_PROVED |
| CLAIM_007 | `omega_divides_n` (Algebraic probe omega divides n) | `ChronoFold/Auto.lean` | FORMALLY_PROVED |
| CLAIM_008 | `omega_nonneg` (Omega bounds are nonnegative) | `ChronoFold/Auto.lean` | FORMALLY_PROVED |
| CLAIM_009 | `omega_le_n` (Omega is bounded from above by n) | `ChronoFold/Auto.lean` | FORMALLY_PROVED |

## 2. EMPIRICALLY_VERIFIED

Claims that are validated via physical measurement, benchmarks, or test replay.

| Claim ID | Title / Description | Verification Method | Status |
| --- | --- | --- | --- |
| CLAIM_101 | SNAP Gradient Optimizer Convergence | `benchmark.py` (real results in `real_results.json`) | EMPIRICALLY_VERIFIED |
| CLAIM_102 | CMA-ES Optimization Baselines | `benchmark.py` (benchmarked against Sphere, Rastrigin, Rosenbrock) | EMPIRICALLY_VERIFIED |

## 3. CONJECTURE

Claims that are postulated but have neither formal proofs nor physical measurements.

| Claim ID | Title / Description | Status |
| --- | --- | --- |
| CLAIM_201 | Universal Minimality of infinite quotient state spaces under arbitrary relational operations | CONJECTURE |
