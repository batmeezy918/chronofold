import Verify

/--
THEOREM_ID: THM_000011
TITLE: continuous_maintenance_invariants
AUTHOR: operator
STATUS: candidate
-/

theorem continuous_maintenance_invariants
    (α : Type u) (inv : AGD.Invariants α) (mo : AGD.MaintenanceOperator α inv) (s : AGD.State α) :
    inv.omega (mo.maintOp s) = inv.omega s ∧ inv.covariant (mo.maintOp s) = inv.covariant s :=
  AGD.maintenance_step_preserves_invariants α inv mo s
