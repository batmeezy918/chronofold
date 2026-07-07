import Mathlib.Data.List.Basic

namespace AGD

/-- A lineage is a sequence of states -/
def Lineage (H : Type*) := List H

/-- An operator transforms one state into another -/
def Operator (H : Type*) := H → H

/--
The lineage function computes a child lineage from a parent lineage,
an operator, and a transition from pre-state to post-state.
Convention: If the pre-state is the last element of the parent lineage,
the post-state is appended to form the child lineage.
-/
def compute_lineage {H : Type*} [DecidableEq H] (parent : List H) (op : Operator H) (pre post : H) : List H :=
  if op pre = post ∧ parent.getLast? = some pre then
    parent ++ [post]
  else
    parent

/--
A lineage receipt records the transformation.
-/
structure Receipt (H : Type*) where
  parent : List H
  op : Operator H
  pre : H
  post : H
  child : List H

/--
A receipt is constitutionally valid if it correctly records a valid transformation.
-/
def is_valid_receipt {H : Type*} [DecidableEq H] (r : Receipt H) : Prop :=
  r.op r.pre = r.post ∧ r.parent.getLast? = some r.pre ∧ r.child = r.parent ++ [r.post]

/--
T00 — Lineage Reconstruction Soundness
Every constitutionally valid receipt reconstructs the same lineage relation from which it was generated.
-/
theorem lineage_reconstruction_soundness {H : Type*} [DecidableEq H] (r : Receipt H) (h : is_valid_receipt r) :
    compute_lineage r.parent r.op r.pre r.post = r.child := by
  -- Phase 1: Identify symbols and types
  -- r : Receipt H
  -- h : is_valid_receipt r

  -- Phase 2: Forward Proof
  unfold compute_lineage
  -- Extract hypotheses from validity
  have h_op := h.1
  have h_pre := h.2.1
  have h_child := h.2.2

  -- The if-condition (op pre = post ∧ parent.getLast? = some pre) is true
  have cond : r.op r.pre = r.post ∧ r.parent.getLast? = some r.pre := ⟨h_op, h_pre⟩

  -- Apply the true branch of compute_lineage
  rw [if_pos cond]

  -- Finally, show it matches r.child
  exact h_child.symm

end AGD
