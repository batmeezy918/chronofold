# AGD Claim Matrix

Every technical claim across Lean specifications, Python optimizer implementations, workflows, and benchmarks is constitutionally classified into exactly one of three permitted categories: `FORMALLY_PROVED`, `EMPIRICALLY_VERIFIED`, or `CONJECTURE`.

---

## 1. Formally Proved Claims (`FORMALLY_PROVED`)

| Claim ID | Specification / File | Description | Verification Method |
| :--- | :--- | :--- | :--- |
| **CLM-001** | `Verify.lean` | Minimal Admissible Quotient $Q^*$ initiality (`uniqueMorph`, `uniqueMorph_unique`) | Lean 4 Theorem |
| **CLM-002** | `Verify.lean` | Admissibility descent equivalence (`admission_iff_descends`) | Lean 4 Theorem |
| **CLM-003** | `Verify.lean` | Replay invariant preservation under admissible operator chains (`replay_preserves_invariants`) | Lean 4 Theorem |
| **CLM-004** | `Chronofold/Auto.lean` | $\Omega$-operator divides state modulo ($n$) (`omega_divides_n`) | Lean 4 Theorem |
| **CLM-005** | `Chronofold/Auto.lean` | Non-negativity and upper bound of $\Omega$ (`omega_nonneg`, `omega_le_n`) | Lean 4 Theorem |
| **CLM-006** | `theorems_proven/THM_000001__smoke_test.lean` | Automated intake pipeline sanity check (`smoke_test`) | Lean 4 Intake Pipeline Receipt |
| **CLM-007** | `theorems_proven/THM_000002__t1.lean` | Arithmetic soundness check (`t1`) | Lean 4 Intake Pipeline Receipt |
| **CLM-008** | `Verify.lean` | SNAP continuous parameter update step invariant preservation (`snap_optimizer_step_preserves_invariants`) | Lean 4 Theorem |
| **CLM-009** | `theorems_proven/THM_000003__snap_optimizer_bridge.lean` | SNAP optimizer formal bridge receipt (`snap_optimizer_bridge`) | Lean 4 Intake Pipeline Receipt |
| **CLM-010** | `Verify.lean` | Spectral adaptive control operator step invariant preservation (`adaptive_control_step_preserves_invariants`) | Lean 4 Theorem |
| **CLM-011** | `theorems_proven/THM_000004__spectral_adaptive_control.lean` | Spectral adaptive control formal receipt (`spectral_adaptive_control`) | Lean 4 Intake Pipeline Receipt |
| **CLM-012** | `Verify.lean` | Manifold rollback bounds operator step invariant preservation (`manifold_rollback_step_preserves_invariants`) | Lean 4 Theorem |
| **CLM-013** | `theorems_proven/THM_000005__manifold_rollback_bounds.lean` | Manifold rollback bounds formal receipt (`manifold_rollback_bounds`) | Lean 4 Intake Pipeline Receipt |
| **CLM-014** | `Verify.lean` | Learning manifold operator step invariant preservation (`learning_manifold_step_preserves_invariants`) | Lean 4 Theorem |
| **CLM-015** | `theorems_proven/THM_000006__learning_manifold_stability.lean` | Learning manifold stability formal receipt (`learning_manifold_stability`) | Lean 4 Intake Pipeline Receipt |
| **CLM-016** | `Verify.lean` | Memory lineage traceability operator step invariant preservation (`memory_lineage_step_preserves_invariants`) | Lean 4 Theorem |
| **CLM-017** | `theorems_proven/THM_000007__memory_lineage_traceability.lean` | Memory lineage traceability formal receipt (`memory_lineage_traceability`) | Lean 4 Intake Pipeline Receipt |

---

## 2. Empirically Verified Claims (`EMPIRICALLY_VERIFIED`)

| Claim ID | Artifact / Benchmark | Description | Evidence |
| :--- | :--- | :--- | :--- |
| **CLM-101** | `benchmark.py` | SNAP gradient optimizer convergence on Sphere benchmark (dim 5 & 10) | `real_results.json` |
| **CLM-102** | `benchmark.py` | SNAP vs CMA-ES comparative performance on Rastrigin & Rosenbrock benchmarks | `real_results.json` |
| **CLM-103** | `scripts/process_inbox.sh` & `scripts/self_test_pipeline.sh` | Automated inbox theorem validation, pipeline self-test, and receipt generation | `theorem_receipts/*.json` & `logs/*.log` |

---

## 3. Conjectures (`CONJECTURE`)

| Claim ID | Topic | Description | Target Closure |
| :--- | :--- | :--- | :--- |
| **CLM-201** | Global Convergence Bound | Polynomial time global convergence bound of SNAP on non-convex Rastrigin landscape | Next Operator Iteration |
