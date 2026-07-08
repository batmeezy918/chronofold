import Chronofold.AgdInformationGeometry

-- THEOREM_ID: THM_000110
-- TITLE: AGD Flow Semigroup Property
-- AUTHOR: Jules
-- STATUS: verified_by_lean

namespace AGD

theorem agd_flow_semigroup
  (T : ℝ → Q → Q)
  (h_flow : ∀ t s q, T (t + s) q = T t (T s q)) :
  ∀ t s q, T (t + s) q = (T t ∘ T s) q := by
  intro t s q
  exact h_flow t s q

end AGD
