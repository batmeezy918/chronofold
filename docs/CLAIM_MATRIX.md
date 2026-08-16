# CLAIM_MATRIX.md

## Constitutional Claim Classification Taxonomy
Every technical claim in the ChronoFold repository is classified into exactly one of three permitted categories:
1. `FORMALLY_PROVED`
2. `EMPIRICALLY_VERIFIED`
3. `CONJECTURE`

---

## Claim Matrix

| Claim ID | Specification / Claim Title | Module / File | Category | Status |
|---|---|---|---|---|
| CLAIM-01 | Equivalence Relation Preservation | `Verify.lean` (`AGDEquiv.refl`, `symm`, `trans`) | `FORMALLY_PROVED` | Verified by Lean 4 |
| CLAIM-02 | Minimal Admissible Quotient Initiality | `Verify.lean` (`uniqueMorph`, `uniqueMorph_unique`) | `FORMALLY_PROVED` | Verified by Lean 4 |
| CLAIM-03 | Operator Descend Soundness | `Verify.lean` (`TBar_sound`, `descends`) | `FORMALLY_PROVED` | Verified by Lean 4 |
| CLAIM-04 | Interchangeability Characterization | `Verify.lean` (`interchangeable_iff`) | `FORMALLY_PROVED` | Verified by Lean 4 |
| CLAIM-05 | Admissibility Characterization | `Verify.lean` (`admission_iff_descends`) | `FORMALLY_PROVED` | Verified by Lean 4 |
| CLAIM-06 | Metamodel Replay Invariant Preservation | `Verify.lean` (`replay_preserves_invariants`) | `FORMALLY_PROVED` | Verified by Lean 4 |
| CLAIM-07 | Omega Probe Divisibility | `ChronoFold/Auto.lean` (`omega_divides_n`) | `FORMALLY_PROVED` | Verified by Lean 4 |
| CLAIM-08 | Omega Nonnegativity | `ChronoFold/Auto.lean` (`omega_nonneg`) | `FORMALLY_PROVED` | Verified by Lean 4 |
| CLAIM-09 | Omega Upper Boundedness | `ChronoFold/Auto.lean` (`omega_le_n`) | `FORMALLY_PROVED` | Verified by Lean 4 |
| CLAIM-10 | Theorem Intake Pipeline Correctness | `theorems_proven/THM_000001__smoke_test.lean` | `FORMALLY_PROVED` | Verified by Lean 4 |
| CLAIM-11 | SNAP Optimization Convergence (Sphere) | `benchmark.py` | `EMPIRICALLY_VERIFIED` | Measured (Loss < 1e-2) |
| CLAIM-12 | SNAP Optimization Convergence (Rastrigin) | `benchmark.py` | `EMPIRICALLY_VERIFIED` | Measured |
| CLAIM-13 | SNAP Optimization Convergence (Rosenbrock) | `benchmark.py` | `EMPIRICALLY_VERIFIED` | Measured |
| CLAIM-14 | Infinite Dimensional Manifold Transport Stability | System Architecture Specification | `CONJECTURE` | Pending Formal Proof |
