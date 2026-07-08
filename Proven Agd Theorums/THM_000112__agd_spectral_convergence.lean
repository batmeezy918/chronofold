import Chronofold.AgdSpectral

-- THEOREM_ID: THM_000112
-- TITLE: AGD Spectral Radius Convergence
-- AUTHOR: Jules
-- STATUS: verified_by_lean

namespace AGD

theorem agd_spectral_convergence
  (O : AgdOperator) (ψ_star : AgdState) (k : ℝ) (ψ : AgdState)
  (h_fix : O.apply ψ_star = ψ_star)
  (h_contract : is_contraction O k) :
  ∀ n, |(iterate_operator O n ψ).data - ψ_star.data| ≤ (k^n) * |ψ.data - ψ_star.data| := by
  intro n
  induction n with
  | zero =>
    unfold iterate_operator
    simp
  | succ n ih =>
    unfold iterate_operator
    rw [← h_fix]
    rcases h_contract with ⟨hk0, hk1, hO⟩
    calc |(O.apply (iterate_operator O n ψ)).data - (O.apply ψ_star).data|
      ≤ k * |(iterate_operator O n ψ).data - ψ_star.data| := hO (iterate_operator O n ψ) ψ_star
      _ ≤ k * ((k^n) * |ψ.data - ψ_star.data|) := mul_le_mul_of_nonneg_left ih hk0
      _ = (k^(n+1)) * |ψ.data - ψ_star.data| := by
        rw [pow_succ, mul_assoc]

end AGD
