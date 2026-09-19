import Verify

/--
THEOREM_ID: THM_000004
TITLE: spectral_adaptive_control
AUTHOR: user
STATUS: candidate
-/

theorem spectral_adaptive_control
    (α : Type u) (inv : AGD.Invariants α) (ctrl : AGD.AdaptiveControlOperator α inv) (s : AGD.State α) :
    inv.omega (ctrl.adaptOp s) = inv.omega s ∧ inv.covariant (ctrl.adaptOp s) = inv.covariant s :=
  AGD.adaptive_control_step_preserves_invariants α inv ctrl s
