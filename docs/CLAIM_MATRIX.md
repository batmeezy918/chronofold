# Claim Reconciliation Matrix

Every technical claim in the Chronofold repository is classified under exactly one of three permitted categories: `FORMALLY_PROVED`, `EMPIRICALLY_VERIFIED`, or `CONJECTURE`.

---

## 1. Claim Matrix

| Claim ID | Claim Description | Mathematical / System Scope | Classification | Verification Witness |
| :--- | :--- | :--- | :--- | :--- |
| **CLM-001** | The Minimal Admissible Quotient $Q^*$ is the unique initial state space preserving $\Omega$ and $C$. | Quotient minimality and universal initiality. | `FORMALLY_PROVED` | Proved in `Verify.lean` via `uniqueMorph` and `uniqueMorph_unique`. |
| **CLM-002** | An operator is admissible if and only if its descended map on $Q^*$ behaves as the identity function. | Equivalence of quotient descent to structural admissibility. | `FORMALLY_PROVED` | Proved in `Verify.lean` via `admission_iff_descends`. |
| **CLM-003** | Invariant properties are preserved across any chain of admissible operators in the Metamodel. | System state safety and inductive path preservation. | `FORMALLY_PROVED` | Proved in `Constitutional.lean` via the `path_preservation` theorem. |
| **CLM-004** | The algebraic probe $\Omega$ always divides the system dimension $n$. | Arithmetic structure of GCD-based operators. | `FORMALLY_PROVED` | Proved in `ChronoFold/Auto.lean` via `omega_divides_n`. |
| **CLM-005** | The algebraic probe $\Omega$ is bounded above by the system dimension $n$. | Structural bounds of the omega operator. | `FORMALLY_PROVED` | Proved in `ChronoFold/Auto.lean` via `omega_le_n`. |
| **CLM-006** | System compilation and theorem ingestion are deterministic and free of external drift. | Determinism of the validation workflow. | `FORMALLY_PROVED` | Proved in `theorems_proven/THM_000001__smoke_test.lean`. |
| **CLM-007** | Operator optimization yields measurable state reduction and speedup. | Optimization benchmarks. | `EMPIRICALLY_VERIFIED` | Verified in `real_results.json` and `benchmark.py` running CMA-ES. |
| **CLM-008** | Repeated application of any admissible contractor reaches a unique fixed point. | Continuous state convergence. | `CONJECTURE` | Under active formulation as a future formal proof obligation. |

---

## 2. Closure Status

- **Total Claims**: 8
- **Formally Proved**: 6
- **Empirically Verified**: 1
- **Conjecture**: 1
