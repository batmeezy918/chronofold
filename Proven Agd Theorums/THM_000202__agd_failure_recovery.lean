import Chronofold.AgdRollback

-- THEOREM_ID: THM_000202
-- TITLE: AGD Error Recovery Rollback Theorem
-- AUTHOR: Jules
-- STATUS: verified_by_lean

namespace AGD

theorem agd_failure_recovery
  (Ω : H → ℝ)
  (t : Transition H)
  (expected_Ω : ℝ)
  (h_before_stable : IsStable Ω t.before expected_Ω)
  (h_after_unstable : ¬ IsStable Ω t.after expected_Ω) :
  IsStable Ω (rollback t) expected_Ω ∧ (rollback t ≠ t.after) := by
  constructor
  · unfold rollback
    exact h_before_stable
  · intro h_eq
    unfold rollback at h_eq
    rw [h_eq] at h_before_stable
    contradiction

end AGD
