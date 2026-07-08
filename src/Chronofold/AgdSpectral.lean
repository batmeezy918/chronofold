import Chronofold.AgdCore
import Chronofold.AgdOperators
import Mathlib.Data.Real.Basic
import Mathlib.Tactic

namespace AGD

/- THEOREM 1 — SPECTRAL RADIUS CONVERGENCE -/

def is_contraction (O : AgdOperator) (k : ℝ) : Prop :=
  0 ≤ k ∧ k < 1 ∧ ∀ s1 s2, |(O.apply s1).data - (O.apply s2).data| ≤ k * |s1.data - s2.data|

def iterate_operator (O : AgdOperator) (n : ℕ) (s : AgdState) : AgdState :=
  match n with
  | 0 => s
  | n + 1 => O.apply (iterate_operator O n s)

/--
  Banach-like Fixed Point Convergence Theorem for AGD Operators.
  If O is a contraction with factor k and ψ_star is a fixed point,
  then the iterates O^n ψ converge to ψ_star at a geometric rate.
-/
theorem AGD_Spectral_Convergence
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
  refine ⟨hk0, hk1, ?_⟩
  intro s1_bar s2_bar
  rcases h_P_surj s1_bar with ⟨s1, hs1⟩
  rcases h_P_surj s2_bar with ⟨s2, hs2⟩
  rw [← hs1, ← hs2]
  repeat rw [← h_commute]
  repeat rw [h_P_data]
  apply hO

end AGD
