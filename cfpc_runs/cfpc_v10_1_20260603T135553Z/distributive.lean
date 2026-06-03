import Mathlib

variable (P Q R : Prop)

theorem cfpc_goal :
  P ∧ (Q ∨ R) → (P ∧ Q) ∨ (P ∧ R) := by
  intro h
  cases h with
  | intro p qr =>
    cases qr
    · left; constructor <;> assumption
    · right; constructor <;> assumption
