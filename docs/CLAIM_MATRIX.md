# CLAIM_MATRIX.md

## Constitutional Claim Reconciliation Matrix

Every technical claim in the system is classified strictly into one of three allowed categories:
- `FORMALLY_PROVED`
- `EMPIRICALLY_VERIFIED`
- `CONJECTURE`

---

| Claim ID | Claim Description | Target Domain | Classification | Evidence / Proof Source |
|----------|-------------------|---------------|----------------|-------------------------|
| CLM-001 | Minimal Admissible Quotient ($Q^*$) exists and is unique up to isomorphism | Lean Metamodel | FORMALLY_PROVED | `Verify.lean` (`uniqueMorph`, `uniqueMorph_unique`) |
| CLM-002 | Operator admissibility is equivalent to descending as identity on $Q^*$ | Lean Metamodel | FORMALLY_PROVED | `Verify.lean` (`admission_iff_descends`) |
| CLM-003 | Sequential operator replay preserves state invariants | Lean Metamodel | FORMALLY_PROVED | `Verify.lean` (`replay_preserves_invariants`) |
| CLM-004 | SNAP Optimizer converges on 5D/10D Sphere function | Optimization Runtime | EMPIRICALLY_VERIFIED | `real_results.json` (`SPHERE`) |
| CLM-005 | SNAP Optimizer achieves competitive error bounds on 5D/10D Rastrigin | Optimization Runtime | EMPIRICALLY_VERIFIED | `real_results.json` (`RASTRIGIN`) |
| CLM-006 | SNAP Optimizer execution on ill-conditioned Rosenbrock valley | Optimization Runtime | EMPIRICALLY_VERIFIED | `real_results.json` (`ROSENBROCK`) |
| CLM-007 | High-dimensional Riemannian curvature bounds for general non-convex manifolds | Global Continuum | CONJECTURE | Open Research Problem |

---

## Reconciliation Summary
- `FORMALLY_PROVED`: 3
- `EMPIRICALLY_VERIFIED`: 3
- `CONJECTURE`: 1
- **Unclassified Claims**: 0
