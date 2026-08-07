# Technical Claim Reconciliation Matrix

This document reconciles all technical claims within the ChronoFold repository against the three permitted constitutional categories: `FORMALLY_PROVED`, `EMPIRICALLY_VERIFIED`, and `CONJECTURE`. No other categories are utilized.

| Claim ID | Description | Classification | Evidence / Proof Artifact |
|---|---|---|---|
| **CL-01** | The Minimal Admissible Quotient ($Q^*$) exists, is initial/minimal, and can be constructed via standard Lean 4 quotient types. | `FORMALLY_PROVED` | `Verify.lean` (`QStar`, `pi`, `uniqueMorph`, `uniqueMorph_unique`) |
| **CL-02** | An operator is admissible if and only if its descended map on $Q^*$ behaves as the identity function. | `FORMALLY_PROVED` | `Verify.lean` (`admission_iff_descends`) |
| **CL-03** | Sequences of admissible operators preserve system invariants along the transition path. | `FORMALLY_PROVED` | `Constitutional.lean` (`path_preservation`) |
| **CL-04** | The algebraic probe $\Omega(x, n)$ divides $n$. | `FORMALLY_PROVED` | `ChronoFold/Auto.lean` (`omega_divides_n`) |
| **CL-05** | The algebraic probe $\Omega(x, n)$ is bounded above by $n$. | `FORMALLY_PROVED` | `ChronoFold/Auto.lean` (`omega_le_n`) |
| **CL-06** | The SNAP gradient optimizer outperforms baseline optimization algorithms (e.g., CMA-ES) in standard benchmarks. | `EMPIRICALLY_VERIFIED` | `real_results.json`, `S6_RESULTS.json`, `benchmark.py` |
| **CL-07** | Fully continuous, multi-agent automated proof generation is achievable deterministically via reinforcement learning. | `CONJECTURE` | Documented future work for automated theorem exploration. |
