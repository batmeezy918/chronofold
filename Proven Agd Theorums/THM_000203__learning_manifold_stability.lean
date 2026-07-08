import Chronofold.AgdLearning

-- THEOREM_ID: THM_000203
-- TITLE: AGD Learning Manifold Stability Theorem
-- AUTHOR: Jules
-- STATUS: verified_by_lean

namespace AGD

theorem learning_manifold_stability
  (T : H → H) (M0 : H) (target_Ω : ℝ)
  (h_manifold : ManifoldAdmissible Ω T)
  (h_init : InvariantStableRegion Ω M0 target_Ω) :
  ∀ n, InvariantStableRegion Ω (iterate_H T n M0) target_Ω := by
  intro n
  induction n with
  | zero =>
    unfold iterate_H
    exact h_init
  | succ n ih =>
    unfold iterate_H
    unfold InvariantStableRegion at *
    rw [h_manifold]
    exact ih

end AGD
