import Verify

/--
THEOREM_ID: THM_000005
TITLE: manifold_rollback_bounds
AUTHOR: operator
STATUS: candidate
-/

theorem manifold_rollback_bounds
    (α : Type u) (inv : AGD.Invariants α) (rb : AGD.ManifoldRollbackOperator α inv) (s : AGD.State α) :
    inv.omega (rb.rollbackOp s) = inv.omega s ∧ inv.covariant (rb.rollbackOp s) = inv.covariant s :=
  AGD.manifold_rollback_step_preserves_invariants α inv rb s
