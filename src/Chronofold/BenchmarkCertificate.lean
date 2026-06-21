import Mathlib.Data.Real.Basic
import Mathlib.Tactic

namespace AGD

structure BenchmarkCertificate where
  baseline_runtime : ℝ
  agd_runtime : ℝ
  speedup : ℝ

noncomputable def measured_speedup (c : BenchmarkCertificate) : ℝ :=
  c.baseline_runtime / c.agd_runtime

def valid_certificate (c : BenchmarkCertificate) : Prop :=
  c.baseline_runtime > 0 ∧
  c.agd_runtime > 0 ∧
  c.speedup = measured_speedup c

theorem speedup_positive :
  ∀ c, valid_certificate c → 0 < c.speedup := by
  intro c h
  unfold valid_certificate at h
  rcases h with ⟨hb, ha, hs⟩
  rw [hs]
  unfold measured_speedup
  exact div_pos hb ha

theorem benchmark_claim_valid :
  ∀ c, valid_certificate c → c.baseline_runtime = c.speedup * c.agd_runtime := by
  intro c h
  unfold valid_certificate at h
  rcases h with ⟨_, ha, hs⟩
  rw [hs]
  unfold measured_speedup
  field_simp [ne_of_gt ha]

theorem certificate_soundness :
  ∀ c, valid_certificate c → c.speedup = c.baseline_runtime / c.agd_runtime := by
  intro c h
  unfold valid_certificate at h
  exact h.2.2

end AGD
