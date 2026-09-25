import Verify

/--
THEOREM_ID: THM_000006
TITLE: learning_manifold_stability
AUTHOR: operator
STATUS: candidate
-/

theorem learning_manifold_stability
    (α : Type u) (inv : AGD.Invariants α) (lm : AGD.LearningManifoldOperator α inv) (s : AGD.State α) :
    inv.omega (lm.learnOp s) = inv.omega s ∧ inv.covariant (lm.learnOp s) = inv.covariant s :=
  AGD.learning_manifold_step_preserves_invariants α inv lm s
