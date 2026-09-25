# AGD Proof Graph Architecture

```
                       +-------------------------------+
                       |      AGD State Space          |
                       |      State α / Invariants     |
                       +---------------+---------------+
                                       |
                                       v
                       +---------------+---------------+
                       | Minimal Admissible Quotient   |
                       |       QStar (Q*)              |
                       +---------------+---------------+
                                       |
                   +-------------------+-------------------+
                   |                                       |
                   v                                       v
     +-------------+-------------+           +-------------+-------------+
     |   Admissibility Descent   |           |  Replay Preservation       |
     |   admission_iff_descends  |           | replay_preserves_invariants|
     +-------------+-------------+           +-------------+-------------+
                   |                                       |
                   +-------------------+-------------------+
                                       |
                                       v
                       +---------------+---------------+
                       | Constitutional Metamodel      |
                       |  (Oracle - Single Source)     |
                       +---------------+---------------+
                                       |
       +-------------------------------+-------------------------------+
       |                               |                               |
       v                               v                               v
+------+--------------------+    +-----+---------------------+   +-----+---------------------+
| Chronofold Auto Theorems  |    | SNAP / Adaptive Control   |   | Intake Processing Pipeline|
|  (omega_divides_n, etc)   |    | snap_optimizer_step_...   |   | process_inbox.sh Receipts |
|                           |    | adaptive_control_step_... |   |                           |
|                           |    | learning_manifold_step_...|   |                           |
+---------------------------+    +---------------------------+   +---------------------------+
```

## Proof Node Registry

1. **`AGD.agdSetoid`**: Generates equivalence relation from invariant functions $(\Omega, C)$.
2. **`AGD.QStar`**: Minimal admissible quotient space constructed via pure Lean quotient primitives.
3. **`AGD.TBar`**: Descended state operator on $Q^*$.
4. **`AGD.admission_iff_descends`**: Proves an operator is admissible if and only if its descended map acts as the identity on $Q^*$.
5. **`AGD.replay_preserves_invariants`**: Proves list induction preservation of invariants across arbitrary operator replay chains.
6. **`AGD.snap_optimizer_step_preserves_invariants`**: Proves SNAP optimizer parameter update step preservation under system invariants.
7. **`theorems_proven.THM_000001__smoke_test`**: `smoke_test` verified via `process_inbox.sh` pipeline intake.
8. **`theorems_proven.THM_000002__t1`**: `t1` verified via `process_inbox.sh` pipeline intake.
9. **`theorems_proven.THM_000003__snap_optimizer_bridge`**: `snap_optimizer_bridge` verified via `process_inbox.sh` pipeline intake.
10. **`AGD.adaptive_control_step_preserves_invariants`**: Proves spectral adaptive control step preservation under system invariants.
11. **`theorems_proven.THM_000004__spectral_adaptive_control`**: `spectral_adaptive_control` verified via `process_inbox.sh` pipeline intake.
12. **`AGD.manifold_rollback_step_preserves_invariants`**: Proves manifold rollback step preservation under system invariants.
13. **`theorems_proven.THM_000005__manifold_rollback_bounds`**: `manifold_rollback_bounds` verified via `process_inbox.sh` pipeline intake.
14. **`AGD.learning_manifold_step_preserves_invariants`**: Proves learning manifold step preservation under system invariants.
15. **`theorems_proven.THM_000006__learning_manifold_stability`**: `learning_manifold_stability` verified via `process_inbox.sh` pipeline intake.
