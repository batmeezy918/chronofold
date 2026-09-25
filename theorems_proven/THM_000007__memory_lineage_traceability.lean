import Verify

/--
THEOREM_ID: THM_000007
TITLE: memory_lineage_traceability
AUTHOR: operator
STATUS: candidate
-/

theorem memory_lineage_traceability
    (α : Type u) (inv : AGD.Invariants α) (ml : AGD.MemoryLineageOperator α inv) (s : AGD.State α) :
    inv.omega (ml.lineageOp s) = inv.omega s ∧ inv.covariant (ml.lineageOp s) = inv.covariant s :=
  AGD.memory_lineage_step_preserves_invariants α inv ml s
