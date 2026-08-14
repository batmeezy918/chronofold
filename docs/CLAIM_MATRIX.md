# CLAIM_MATRIX.md

## Technical Claim Classification Matrix

Every technical claim in the AGD/CTG repository is classified into exactly one of three permitted constitutional categories:
1. `FORMALLY_PROVED`
2. `EMPIRICALLY_VERIFIED`
3. `CONJECTURE`

---

## Claim Classifications

| Claim ID | Claim Description | Target Artifact / Source | Constitutional Classification |
| :--- | :--- | :--- | :--- |
| **CLM-001** | Equivalence relation `AGDEquiv` is reflexive, symmetric, and transitive | `Verify.lean` (`AGDEquiv.refl`, `symm`, `trans`) | `FORMALLY_PROVED` |
| **CLM-002** | Operator $T$ admissibility descends to $Q^*$ via `TBar` operator | `Verify.lean` (`TBar`, `TBar_sound`, `descends`) | `FORMALLY_PROVED` |
| **CLM-003** | $Q^*$ satisfies universal initiality (`uniqueMorph` and `uniqueMorph_unique`) | `Verify.lean` (`uniqueMorph`, `uniqueMorph_unique`) | `FORMALLY_PROVED` |
| **CLM-004** | State interchangeability is logically equivalent to `AGDEquiv` | `Verify.lean` (`interchangeable_iff`) | `FORMALLY_PROVED` |
| **CLM-005** | An operator is admissible if and only if its descended map on $Q^*$ behaves as identity | `Verify.lean` (`admission_iff_descends`) | `FORMALLY_PROVED` |
| **CLM-006** | Natural addition identity $1 + 1 = 2$ smoke verification | `theorems_proven/THM_000001__smoke_test.lean` | `FORMALLY_PROVED` |
| **CLM-007** | Algebraic probe $\Omega$ divides state magnitude $n$ | `ChronoFold/Auto.lean` (`omega_divides_n`) | `FORMALLY_PROVED` |
| **CLM-008** | Algebraic probe $\Omega$ is non-negative and bounded by $n$ | `ChronoFold/Auto.lean` (`omega_nonneg`, `omega_le_n`) | `FORMALLY_PROVED` |
| **CLM-009** | Basic arithmetic identity $1 + 1 = 2$ in auto suite | `ChronoFold/Auto/T1.lean` (`t1`) | `FORMALLY_PROVED` |
| **CLM-010** | SNAP optimization performance on 5D & 10D Sphere benchmark | `benchmark.py` / `real_results.json` | `EMPIRICALLY_VERIFIED` |
| **CLM-011** | SNAP optimization performance on 5D & 10D Rastrigin benchmark | `benchmark.py` / `real_results.json` | `EMPIRICALLY_VERIFIED` |
| **CLM-012** | SNAP optimization performance on 5D & 10D Rosenbrock benchmark | `benchmark.py` / `real_results.json` | `EMPIRICALLY_VERIFIED` |
| **CLM-013** | Polynomial time global convergence of SNAP on ill-conditioned non-convex manifolds | Future theoretical expansion | `CONJECTURE` |
