import Mathlib.Data.Real.Basic
import Mathlib.Tactic

namespace AGD

structure SearchMeasurement where
  brute_states : ℕ
  agd_states : ℕ
  brute_score : ℝ
  agd_score : ℝ

noncomputable def state_reduction_ratio (m : SearchMeasurement) : ℝ :=
  1 - (m.agd_states : ℝ) / (m.brute_states : ℝ)

def solution_preserved (m : SearchMeasurement) : Prop :=
  m.brute_score = m.agd_score

theorem compression_ratio_valid :
  ∀ (m : SearchMeasurement), m.agd_states < m.brute_states → 0 < m.brute_states → 0 < state_reduction_ratio m := by
  intro m h_states h_brute
  unfold state_reduction_ratio
  have h_brute_real : 0 < (m.brute_states : ℝ) := by
    norm_cast
  have h_frac : (m.agd_states : ℝ) / (m.brute_states : ℝ) < 1 := by
    apply (div_lt_one h_brute_real).mpr
    norm_cast
  linarith

theorem optimality_preserved :
  ∀ (m : SearchMeasurement), solution_preserved m → m.agd_score = m.brute_score := by
  intro m h
  unfold solution_preserved at h
  rw [h]

end AGD
