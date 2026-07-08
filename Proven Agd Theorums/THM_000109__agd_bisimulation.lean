import Chronofold.AgdInformationGeometry

-- THEOREM_ID: THM_000109
-- TITLE: AGD Dynamical Bisimulation
-- AUTHOR: Jules
-- STATUS: verified_by_lean

namespace AGD

theorem agd_bisimulation
  (T : ℝ → Q → Q)
  (h_transport : ∀ t q, Ω_inv (T t q) = Ω_inv q)
  (q1 q2 : Q) (h_init : AGDEquiv q1 q2) :
  ∀ t, AGDEquiv (T t q1) (T t q2) := by
  intro t
  unfold AGDEquiv at *
  rw [h_transport, h_transport]
  exact h_init

end AGD
