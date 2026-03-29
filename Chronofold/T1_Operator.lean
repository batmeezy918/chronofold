import Mathlib.Data.Real.Basic
import Mathlib.Data.Fin.Basic
import Mathlib.Analysis.NormedSpace.Basic

-- State space
def H (n : Nat) := Fin n → ℝ

-- Operator
variable {n : Nat}
variable (O : H n → H n)

-- Ω invariant (norm-based for provability)
def Ω (x : H n) : ℝ :=
  ‖x‖

-- Invariance theorem (exact)
theorem T1_invariant_exact
  (hO : ∀ x : H n, ‖O x‖ = ‖x‖) :
  ∀ x : H n, Ω (O x) = Ω x := by
  intro x
  unfold Ω
  exact hO x

-- Approximate invariance (epsilon bound)
theorem T1_invariant_eps
  (ε : ℝ)
  (hε : ε ≥ 0)
  (hO : ∀ x : H n, |‖O x‖ - ‖x‖| ≤ ε) :
  ∀ x : H n, |Ω (O x) - Ω x| ≤ ε := by
  intro x
  unfold Ω
  exact hO x
