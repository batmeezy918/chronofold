import Chronofold.BenchmarkCertificate

-- THEOREM_ID: THM_000105
-- TITLE: AGD Speedup Positivity
-- AUTHOR: Jules
-- STATUS: verified_by_lean

namespace AGD

theorem speedup_positive :
  ∀ c, valid_certificate c → 0 < c.speedup := by
  intro c h
  unfold valid_certificate at h
  rcases h with ⟨hb, ha, hs⟩
  rw [hs]
  unfold measured_speedup
  exact div_pos hb ha

end AGD
