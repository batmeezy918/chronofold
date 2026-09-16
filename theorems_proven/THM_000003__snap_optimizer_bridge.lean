import Verify

/--
THEOREM_ID: THM_000003
TITLE: snap_optimizer_bridge
AUTHOR: user
STATUS: candidate
-/

theorem snap_optimizer_bridge
    (α : Type u) (inv : AGD.Invariants α) (bridge : AGD.SnapOptimizerBridge α inv) (s : AGD.State α) :
    inv.omega (bridge.stepOp s) = inv.omega s ∧ inv.covariant (bridge.stepOp s) = inv.covariant s :=
  AGD.snap_optimizer_step_preserves_invariants α inv bridge s
