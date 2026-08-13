# CLAIM RECONCILIATION MATRIX

All technical and mathematical claims in the ChronoFold repository are strictly classified under exactly one of three categories: `FORMALLY_PROVED`, `EMPIRICALLY_VERIFIED`, or `CONJECTURE`.

| Claim ID | Claim Description | Status / Classification | Evidence / Source File |
|---|---|---|---|
| **CLM-001** | **Quotient Soundness** (`TBar_sound`): The quotient-lifted operator $\bar{T}$ corresponds exactly to the original operator $T$ under projection $\pi$. | `FORMALLY_PROVED` | `Verify.lean` (`AGD.TBar_sound`) |
| **CLM-002** | **Information Preservation** (`descends`): A descending state map exists for any admissible operator. | `FORMALLY_PROVED` | `Verify.lean` (`AGD.descends`) |
| **CLM-003** | **Quotient Minimality** (`uniqueMorph_unique`): The quotient $Q^*$ is the universal minimal/initial state space respecting $\Omega$ and $C$. | `FORMALLY_PROVED` | `Verify.lean` (`AGD.uniqueMorph_unique`) |
| **CLM-004** | **Operator Algebra Closure** (`admission_iff_descends`): An operator $T$ is admissible if and only if its descended map behaves as the identity. | `FORMALLY_PROVED` | `Verify.lean` (`AGD.admission_iff_descends`) |
| **CLM-005** | **Sequential Replay Stability** (`replay_preserves_invariants`): Sequential execution of any sequence of admissible operators preserves the invariants. | `FORMALLY_PROVED` | `Verify.lean` (`AGD.replay_preserves_invariants`) |
| **CLM-006** | **SNAP Gradient Optimization** (`snap_optimize`): The adaptive gradient step using curvature signal ($\Xi$) successfully converges on target functions. | `EMPIRICALLY_VERIFIED` | `benchmark.py` & `real_results.json` |
| **CLM-007** | **Deterministic Step Replay** (`snap_step`): The SNAP state transformation is perfectly deterministic and invariant-preserving over repeated trials. | `EMPIRICALLY_VERIFIED` | `benchmark_snap.py` & `snap_result.json` |
| **CLM-008** | **CMA-ES Baseline Comparison**: CMA-ES provides a baseline against SNAP for dimensional evaluation (dims 5, 10) on Sphere, Rastrigin, Rosenbrock. | `EMPIRICALLY_VERIFIED` | `benchmark.py` & `real_results.json` |
| **CLM-009** | **Full Compiler Correctness**: Proof that the compiled bytecode / binary is semantic-preserving under arbitrary execution contexts. | `CONJECTURE` | Documented Future Work (to be formalized in a future operator) |
| **CLM-010** | **Asymptotic Curve Exponential Convergence**: Curve trajectories with positive curvature ($\Xi > 0$) strictly converge exponentially to the manifold. | `CONJECTURE` | Documented Future Work |

No other classification categories are permitted or used.
