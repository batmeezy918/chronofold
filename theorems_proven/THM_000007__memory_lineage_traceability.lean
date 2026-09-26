import Verify

/--
THEOREM_ID: THM_000007
TITLE: memory_lineage_traceability
AUTHOR: operator
STATUS: candidate
-/

theorem memory_lineage_traceability
    (α : Type u) (inv : AGD.Invariants α) (mem : AGD.MemoryLineageOperator α inv) (s : AGD.State α) :
    inv.omega (mem.memoryOp s) = inv.omega s ∧ inv.covariant (mem.memoryOp s) = inv.covariant s :=
  AGD.memory_lineage_step_preserves_invariants α inv mem s
