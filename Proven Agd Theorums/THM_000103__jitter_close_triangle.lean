import Chronofold.MeasurementCertificate

-- THEOREM_ID: THM_000103
-- TITLE: Jitter Equivalence Triangle Inequality
-- AUTHOR: Jules
-- STATUS: verified_by_lean

namespace AGD

theorem jitter_close_triangle :
  ∀ A B C, jitter_close J ε A B → jitter_close J ε B C → |J A - J C| ≤ 2*ε := by
  intro A B C hAB hBC
  unfold jitter_close at *
  have h := abs_sub_le (J A) (J B) (J C)
  linarith

end AGD
