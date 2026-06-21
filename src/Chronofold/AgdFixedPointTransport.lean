import Chronofold.AgdCore
import Chronofold.AgdOperators
import Mathlib.Tactic

namespace AGD

/- THEOREM 5 — FIXED POINT TRANSPORT -/

theorem AGD_Fixed_Point_Transport
  (O O_bar : AgdOperator) (P : AgdState → AgdState)
  (h_commute : ∀ ψ, P (O.apply ψ) = O_bar.apply (P ψ))
  (ψ_star : AgdState)
  (h_fix : O.apply ψ_star = ψ_star) :
  O_bar.apply (P ψ_star) = P ψ_star := by
  rw [← h_commute, h_fix]

end AGD
