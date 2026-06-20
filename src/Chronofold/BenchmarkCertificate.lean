import Mathlib.Data.Real.Basic
import Mathlib.Tactic

import Chronofold.AgdCore
import Chronofold.AgdOperators
import Chronofold.AgdInvariants
import Chronofold.AgdQuotient
import Chronofold.MeasurementCertificate

namespace AGD

structure RuntimeMeasurement where
  baseline_time : ℝ
  agd_time : ℝ

def ValidRuntime (m : RuntimeMeasurement) : Prop :=
  m.baseline_time > 0 ∧ m.agd_time > 0

noncomputable def compute_speedup (m : RuntimeMeasurement) : ℝ :=
  m.baseline_time / m.agd_time

structure SpeedupCertificate where
  measurement : RuntimeMeasurement
  speedup : ℝ
  equivalent_systems : Prop
  runtime_valid : ValidRuntime measurement
  speedup_correct : speedup = compute_speedup measurement

def CertifiedAcceleration (c : SpeedupCertificate) : Prop :=
  c.measurement.agd_time < c.measurement.baseline_time

theorem speedup_positive :
  ∀ c : SpeedupCertificate, CertifiedAcceleration c → 0 < c.speedup := by
  intro c _
  have h_valid := c.runtime_valid
  unfold ValidRuntime at h_valid
  rcases h_valid with ⟨hb, ha⟩
  rw [c.speedup_correct]
  unfold compute_speedup
  exact div_pos hb ha

theorem speedup_gt_one :
  ∀ c : SpeedupCertificate, CertifiedAcceleration c → 1 < c.speedup := by
  intro c h_accel
  have h_valid := c.runtime_valid
  unfold ValidRuntime at h_valid
  rcases h_valid with ⟨_, ha⟩
  rw [c.speedup_correct]
  unfold compute_speedup
  unfold CertifiedAcceleration at h_accel
  exact (one_lt_div ha).mpr h_accel

theorem benchmark_claim_valid :
  ∀ c : SpeedupCertificate, CertifiedAcceleration c →
  c.measurement.baseline_time = c.speedup * c.measurement.agd_time := by
  intro c _
  have h_valid := c.runtime_valid
  unfold ValidRuntime at h_valid
  rcases h_valid with ⟨_, ha⟩
  rw [c.speedup_correct]
  unfold compute_speedup
  field_simp [ne_of_gt ha]

end AGD
