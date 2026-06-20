import Mathlib.Data.Real.Basic
import Mathlib.Tactic

namespace AGD

structure BenchmarkCertificate where
  runtime : ℝ
  baseline_runtime : ℝ
  speedup : ℝ
  verified : Prop

noncomputable def speedup_ratio (c : BenchmarkCertificate) : ℝ :=
  c.baseline_runtime / c.runtime

theorem speedup_positive (c : BenchmarkCertificate)
  (h1 : c.runtime > 0) (h2 : c.baseline_runtime > 0) :
  speedup_ratio c > 0 := by
  unfold speedup_ratio
  exact div_pos h2 h1

theorem benchmark_claim_valid (c : BenchmarkCertificate)
  (h : c.speedup = speedup_ratio c) :
  c.speedup = speedup_ratio c := h

end AGD
