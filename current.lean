import Mathlib

variable (P Q R : Prop)

theorem cfpc_goal :
  (P → Q) → (Q → R) → P → R := by
  intro h1 h2 p
  exact h2 (h1 p)
