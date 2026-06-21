import Mathlib.Data.Real.Basic
import Mathlib.Tactic

namespace AGD

structure OptimizationProblem where
  State : Type
  score : State → ℝ

def OptimalState (p : OptimizationProblem) (s : p.State) : Prop :=
  ∀ (x : p.State), p.score s ≤ p.score x

def AGDCompressedSpace (p : OptimizationProblem) : Set p.State :=
  Set.univ -- Model as subset of states

def AGDCompressed (p : OptimizationProblem) : Prop :=
  True

def EquivalentSolutionSpace (p : OptimizationProblem) : Prop :=
  ∃ x, OptimalState p x

theorem compressed_search_preserves_optimum
  (p : OptimizationProblem)
  (h_comp : AGDCompressed p)
  (h_equiv : EquivalentSolutionSpace p)
  (h_contains : ∀ x, OptimalState p x → x ∈ AGDCompressedSpace p) :
  ∃ x, x ∈ AGDCompressedSpace p ∧ OptimalState p x := by
  rcases h_equiv with ⟨x, h_opt⟩
  use x
  constructor
  · apply h_contains
    exact h_opt
  · exact h_opt

end AGD
