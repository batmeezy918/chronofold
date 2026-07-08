import Chronofold.BenchmarkCertificate

-- THEOREM_ID: THM_000106
-- TITLE: AGD Benchmark Claim Validity
-- AUTHOR: Jules
-- STATUS: verified_by_lean

namespace AGD

theorem benchmark_claim_valid :
  ∀ c, valid_certificate c → c.baseline_runtime = c.speedup * c.agd_runtime := by
  intro c h
  unfold valid_certificate at h
  rcases h with ⟨_, ha, hs⟩
  rw [hs]
  unfold measured_speedup
  field_simp [ne_of_gt ha]

end AGD
