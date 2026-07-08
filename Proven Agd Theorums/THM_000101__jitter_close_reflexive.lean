import Chronofold.MeasurementCertificate

-- THEOREM_ID: THM_000101
-- TITLE: Jitter Equivalence Reflexivity
-- AUTHOR: Jules
-- STATUS: verified_by_lean

namespace AGD

theorem jitter_close_reflexive (hε : 0 ≤ ε) :
  ∀ A, jitter_close J ε A A := by
  intro A
  unfold jitter_close
  simp
  exact hε

end AGD
