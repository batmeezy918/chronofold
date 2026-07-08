import Chronofold.MeasurementCertificate

-- THEOREM_ID: THM_000102
-- TITLE: Jitter Equivalence Symmetry
-- AUTHOR: Jules
-- STATUS: verified_by_lean

namespace AGD

theorem jitter_close_symmetric :
  ∀ A B, jitter_close J ε A B → jitter_close J ε B A := by
  intro A B h
  unfold jitter_close at *
  rw [abs_sub_comm]
  exact h

end AGD
