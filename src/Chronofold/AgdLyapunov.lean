import Chronofold.AgdCore
import Mathlib.Data.Real.Basic
import Mathlib.Tactic

namespace AGD

/- THEOREM 3 — LYAPUNOV STABILITY CERTIFICATE -/

def iterate_operator (O : AgdState → AgdState) (n : ℕ) (ψ : AgdState) : AgdState :=
  match n with
  | 0 => ψ
  | n + 1 => O (iterate_operator O n ψ)

def LyapunovFunction (V : AgdState → ℝ) (O : AgdState → AgdState) : Prop :=
  ∀ ψ, V (O ψ) ≤ V ψ

theorem AGD_Lyapunov_Stability
  (V : AgdState → ℝ) (O : AgdState → AgdState)
  (h_lyap : LyapunovFunction V O)
  (ψ : AgdState) (n : ℕ) :
  V (iterate_operator O n ψ) ≤ V ψ := by
  induction n with
  | zero =>
    unfold iterate_operator
    simp
  | succ n ih =>
    unfold iterate_operator
    calc V (O (iterate_operator O n ψ))
      ≤ V (iterate_operator O n ψ) := h_lyap (iterate_operator O n ψ)
      _ ≤ V ψ := ih

end AGD
