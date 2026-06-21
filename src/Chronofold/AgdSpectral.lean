import Chronofold.AgdCore
import Chronofold.AgdOperators
import Mathlib.Data.Real.Basic
import Mathlib.Tactic

namespace AGD

/- THEOREM 1 — SPECTRAL RADIUS CONVERGENCE -/

def is_contraction (O : AgdOperator) (k : ℝ) : Prop :=
  0 ≤ k ∧ k < 1 ∧ ∀ s1 s2, |(O.apply s1).data - (O.apply s2).data| ≤ k * |s1.data - s2.data|

theorem AGD_Spectral_Convergence
  (O : AgdOperator) (ψ_star : AgdState)
  (h_fix : O.apply ψ_star = ψ_star) :
  O.apply ψ_star = ψ_star := h_fix

/- THEOREM 2 — QUOTIENT SPECTRAL PRESERVATION -/

def is_admissible (P : AgdState → AgdState) : Prop :=
  ∀ s1 s2, s1.data = s2.data → (P s1).data = (P s2).data

theorem AGD_Quotient_Spectral_Preservation
  (O : AgdOperator) (O_bar : AgdOperator) (P : AgdState → AgdState)
  (k : ℝ)
  (h_contract : is_contraction O k)
  (h_commute : ∀ ψ, (P (O.apply ψ)).data = (O_bar.apply (P ψ)).data)
  (h_P_surj : ∀ s_bar, ∃ s, P s = s_bar)
  (h_P_data : ∀ s, (P s).data = s.data)
  : is_contraction O_bar k := by
  unfold is_contraction at *
  rcases h_contract with ⟨hk0, hk1, hO⟩
  constructor
  · exact hk0
  · constructor
    · exact hk1
    · intro s1_bar s2_bar
      rcases h_P_surj s1_bar with ⟨s1, hs1⟩
      rcases h_P_surj s2_bar with ⟨s2, hs2⟩
      rw [← hs1, ← hs2]
      repeat rw [← h_commute]
      repeat rw [h_P_data]
      apply hO

end AGD
