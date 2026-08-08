# O∞ Claim Reconciliation Matrix (CLAIM_MATRIX.md)

Under the AGD/CTG Constitutional mandate, all technical claims must be strictly and uniquely classified into exactly one of three categories: `FORMALLY_PROVED`, `EMPIRICALLY_VERIFIED`, or `CONJECTURE`. No other categories are permitted.

| Claim ID | Claim Description | Classification | Evidence / Verification Method |
| :--- | :--- | :--- | :--- |
| **CLM-001** | The Minimal Admissible Quotient ($Q^*$) exists, represents the minimal quotient state space, and preserves both the invariant ($\Omega$) and covariant ($C$) laws. | **FORMALLY_PROVED** | Proved in `Verify.lean` (`QStar`, `pi`, `OmegaBar`, `CBar`). |
| **CLM-002** | Any admissible operator $T$ descends uniquely to a quotient operator $\bar{T}$ on $Q^*$, preserving the system equivalence classes. | **FORMALLY_PROVED** | Proved in `Verify.lean` (`TBar`, `TBar_sound`, `descends`). |
| **CLM-003** | An operator is admissible if and only if its descended operator on the minimal quotient is the identity function. | **FORMALLY_PROVED** | Proved in `Verify.lean` (`admission_iff_descends`). |
| **CLM-004** | Sequential application of admissible operators (system replay) preserves the invariant $\Omega$ and covariant $C$ properties of the starting state. | **FORMALLY_PROVED** | Proved in `Verify.lean` (`replay_preserves_invariants`). |
| **CLM-005** | The algebraic probe $\Omega$ divides $n$ for any state index $x$ and modulus $n$. | **FORMALLY_PROVED** | Proved in `ChronoFold/Auto.lean` (`omega_divides_n`). |
| **CLM-006** | The algebraic probe $\Omega$ is non-negative and bounded above by $n$. | **FORMALLY_PROVED** | Proved in `ChronoFold/Auto.lean` (`omega_nonneg`, `omega_le_n`). |
| **CLM-007** | Quotient state space compression reduces search state cardinality and accelerates optimization tasks. | **EMPIRICALLY_VERIFIED** | Verified via CMA-ES and gradient optimizer benchmarks (`benchmark.py`), with logs stored in `real_results.json`. |
| **CLM-008** | The quotient space minimality property can be constructed constructively under Fintype cardinality bounds. | **CONJECTURE** | Sketched as a placeholder in `Verify.lean` (`minimality_sketch`). |
