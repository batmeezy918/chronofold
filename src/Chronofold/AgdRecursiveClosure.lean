import Chronofold.AgdCore
import Chronofold.AgdOperators

namespace AGD

def recursive_iterate_operator (n : ℕ) (f : AgdState → AgdState) (s : AgdState) : AgdState :=
  match n with
  | 0 => s
  | n + 1 => f (recursive_iterate_operator n f s)

def Invariant (inv : AgdState → Prop) (s : AgdState) : Prop :=
  inv s

theorem recursive_invariant_preservation
  (n : ℕ) (f : AgdState → AgdState) (s : AgdState) (inv : AgdState → Prop)
  (h_init : Invariant inv s)
  (h_step : ∀ (x : AgdState), Invariant inv x → Invariant inv (f x)) :
  Invariant inv (recursive_iterate_operator n f s) := by
  induction n with
  | zero =>
    unfold recursive_iterate_operator
    exact h_init
  | succ n ih =>
    unfold recursive_iterate_operator
    apply h_step
    exact ih

end AGD
