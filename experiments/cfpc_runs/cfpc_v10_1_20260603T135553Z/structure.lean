import Mathlib

variable (P Q : Prop)

theorem cfpc_goal :
  (P ∧ Q) → (Q ∧ P) := by
  intro h
  cases h
  constructor <;> assumption
