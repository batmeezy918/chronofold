import Mathlib.Data.List.Basic

/-- AGDState contains the state x, signatures, and memory fiber. -/
structure AGDState (H : Type*) where
  x : H
  omega : H → Prop
  cov : H → Prop
  memory : List H

/-- Admissible if omega and cov hold for x. -/
def Admissible {H : Type*} (s : AGDState H) : Prop :=
  s.omega s.x ∧ s.cov s.x
