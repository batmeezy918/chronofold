import Mathlib.Data.Real.Basic
import Mathlib.Data.Fin.Basic
import Mathlib.Analysis.NormedSpace.Basic

namespace Chronofold

def H (n : Nat) := Fin n → ℝ

variable {n : Nat}
variable (O : H n → H n)

def Ω (x : H n) : ℝ :=
  ‖x‖

theorem T1_invariant_exact
  (hO : ∀ x : H n, ‖O x‖ = ‖x‖) :
  ∀ x : H n, Ω (O x) = Ω x := by
  intro x
  unfold Ω
  exact hO x

theorem T1_invariant_eps
  (ε : ℝ)
  (hε : ε ≥ 0)
  (hO : ∀ x : H n, |‖O x‖ - ‖x‖| ≤ ε) :
  ∀ x : H n, |Ω (O x) - Ω x| ≤ ε := by
  intro x
  unfold Ω
  exact hO x

end Chronofold
