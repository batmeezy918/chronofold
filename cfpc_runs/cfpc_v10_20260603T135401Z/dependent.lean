import Mathlib

variable (P Q : Prop)

theorem cfpc_goal :
  (P → Q) → P → Q := by
  intro h p
  exact h p
