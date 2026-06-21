import Chronofold.AgdCore
import Mathlib.Tactic

namespace AGD

def iterate_operator (O : AgdState → AgdState) (n : ℕ) (s : AgdState) : AgdState :=
  match n with
  | 0 => s
  | n + 1 => O (iterate_operator O n s)

def StableState (O : AgdState → AgdState) (s : AgdState) : Prop :=
  O s = s

def InvariantStable (O : AgdState → AgdState) (s : AgdState) : Prop :=
  ∃ n, StableState O (iterate_operator O n s)

theorem agd_iteration_converges
  (O : AgdState → AgdState) (s : AgdState)
  (h_stable : InvariantStable O s) :
  ∃ fixed, ∃ n, iterate_operator O n s = fixed ∧ O fixed = fixed := by
  rcases h_stable with ⟨n, h_fixed⟩
  use iterate_operator O n s
  use n
  constructor
  · rfl
  · exact h_fixed

end AGD
