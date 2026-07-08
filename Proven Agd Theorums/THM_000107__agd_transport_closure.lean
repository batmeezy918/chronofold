import Chronofold.AgdInformationGeometry

-- THEOREM_ID: THM_000107
-- TITLE: AGD Information Transport Closure
-- AUTHOR: Jules
-- STATUS: verified_by_lean

namespace AGD

theorem agd_transport_closure
  (T : ℝ → ℝ → ℝ) (q : ℝ)
  (h_flow : ∀ t, T t q = q)
  : ∀ t, Ω_inv (T t q) = Ω_inv q := by
  intro t
  rw [h_flow]

end AGD
