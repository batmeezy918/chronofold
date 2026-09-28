import Verify

/--
THEOREM_ID: THM_000008
TITLE: autonomous_closure_integration
AUTHOR: operator
STATUS: candidate
-/

theorem autonomous_closure_integration
    (α : Type u) (inv : AGD.Invariants α) (ac : AGD.AutonomousClosureOperator α inv) (s : AGD.State α) :
    inv.omega (ac.closeOp s) = inv.omega s ∧ inv.covariant (ac.closeOp s) = inv.covariant s :=
  AGD.autonomous_closure_step_preserves_invariants α inv ac s
