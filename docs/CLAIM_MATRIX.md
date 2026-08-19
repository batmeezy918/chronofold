# AGD Claim Matrix

Every technical claim across Lean specifications, Python optimizer implementations, workflows, and benchmarks is constitutionally classified into exactly one of three permitted categories: `FORMALLY_PROVED`, `EMPIRICALLY_VERIFIED`, or `CONJECTURE`.

---

## 1. Formally Proved Claims (`FORMALLY_PROVED`)

| Claim ID | Specification / File | Description | Verification Method |
| :--- | :--- | :--- | :--- |
| **CLM-001** | `Verify.lean` | Minimal Admissible Quotient $Q^*$ initiality (`uniqueMorph`, `uniqueMorph_unique`) | Lean 4 Theorem |
| **CLM-002** | `Verify.lean` | Admissibility descent equivalence (`admission_iff_descends`) | Lean 4 Theorem |
| **CLM-003** | `Verify.lean` | Replay invariant preservation under admissible operator chains (`replay_preserves_invariants`) | Lean 4 Theorem |
| **CLM-004** | `ChronoFold/Auto.lean` | $\Omega$-operator divides state modulo ($n$) (`omega_divides_n`) | Lean 4 Theorem |
| **CLM-005** | `ChronoFold/Auto.lean` | Non-negativity and upper bound of $\Omega$ (`omega_nonneg`, `omega_le_n`) | Lean 4 Theorem |
| **CLM-006** | `theorems_proven/THM_000001__smoke_test.lean` | Automated intake pipeline sanity check (`smoke_test`) | Lean 4 Intake Pipeline Receipt |

---

## 2. Empirically Verified Claims (`EMPIRICALLY_VERIFIED`)

| Claim ID | Artifact / Benchmark | Description | Evidence |
| :--- | :--- | :--- | :--- |
| **CLM-101** | `benchmark.py` | SNAP gradient optimizer convergence on Sphere benchmark (dim 5 & 10) | `real_results.json` |
| **CLM-102** | `benchmark.py` | SNAP vs CMA-ES comparative performance on Rastrigin & Rosenbrock benchmarks | `real_results.json` |
| **CLM-103** | `scripts/process_inbox.sh` | Automated inbox theorem validation and receipt generation | `theorem_receipts/*.json` & `logs/*.log` |

---

## 3. Conjectures (`CONJECTURE`)

| Claim ID | Topic | Description | Target Closure |
| :--- | :--- | :--- | :--- |
| **CLM-201** | Global Convergence Bound | Polynomial time global convergence bound of SNAP on non-convex Rastrigin landscape | Next Operator Iteration |
