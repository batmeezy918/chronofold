import Mathlib

variable (P Q R : Prop)

theorem cfpc_goal :
  (P ∧ Q) ∨ (P ∧ R) → P ∧ (Q ∨ R) := by
  intro h
  cases h
  · cases h <;> constructor <;> tauto
  · cases h <;> constructor <;> tauto
