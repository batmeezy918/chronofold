# CLAIM MATRIX REPORT

All technical claims within the repository are classified into exactly one of three permitted categories: `FORMALLY_PROVED`, `EMPIRICALLY_VERIFIED`, or `CONJECTURE`.

| Claim ID | Description | Module / Source | Classification |
| :--- | :--- | :--- | :--- |
| **CLM-001** | Minimal Quotient $Q^*$ Initiality & Universality | `Verify.lean` (`uniqueMorph`, `uniqueMorph_unique`) | `FORMALLY_PROVED` |
| **CLM-002** | Operator Descent Condition on $Q^*$ | `Verify.lean` (`admission_iff_descends`, `TBar_sound`) | `FORMALLY_PROVED` |
| **CLM-003** | Replay Invariant Preservation | `Verify.lean` (`replay_preserves_invariants`) | `FORMALLY_PROVED` |
| **CLM-004** | $\Omega$-Operator Divisibility & Bounds | `ChronoFold/Auto.lean` (`omega_divides_n`, `omega_le_n`) | `FORMALLY_PROVED` |
| **CLM-005** | SNAP Optimization Convergence | `benchmark.py`, `real_results.json` | `EMPIRICALLY_VERIFIED` |
| **CLM-006** | Deterministic Toolchain Execution | `.github/workflows/build.yml` | `EMPIRICALLY_VERIFIED` |

## Classification Matrix Rule
No claim exists outside these three formal categories.
