import Chronofold.AgdInformationGeometry

-- THEOREM_ID: THM_000108
-- TITLE: AGD Information Curvature Convergence
-- AUTHOR: Jules
-- STATUS: verified_by_lean

namespace AGD

theorem curvature_convergence
  (J : ℝ → ℝ) (Xi : ℝ)
  (h_Xi : Xi > 0)
  (h_dynamics : ∀ t, J t = Real.exp (-Real.sqrt Xi * t)) :
  ∀ t, t > 0 → J t < J 0 := by
  intro t ht
  rw [h_dynamics, h_dynamics]
  simp
  apply mul_pos
  · exact Real.sqrt_pos.mpr h_Xi
  · exact ht

end AGD
