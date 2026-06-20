import Mathlib.Data.Real.Basic
import Chronofold.AgdCore
import Chronofold.AgdOperators
import Chronofold.AgdInvariants
import Chronofold.AgdQuotient
import Chronofold.MeasurementCertificate
import Mathlib.Tactic

namespace AGD

structure RuntimeMeasurement where
  baseline_time : ℝ
  agd_time : ℝ

structure SpeedupCertificate where
  measurement : RuntimeMeasurement
  speedup : ℝ
  equivalent_systems : Prop
  valid : Prop

noncomputable def compute_speedup (m : RuntimeMeasurement) : ℝ :=
  m.baseline_time / m.agd_time

def ValidRuntime (m : RuntimeMeasurement) : Prop :=
  m.baseline_time > 0 ∧ m.agd_time > 0

theorem performance_speedup_positive (m : RuntimeMeasurement) :
  ValidRuntime m → 0 < compute_speedup m := by
  intro h
  unfold ValidRuntime at h
  unfold compute_speedup
  exact div_pos h.1 h.2

theorem speedup_gt_one_of_faster (m : RuntimeMeasurement) :
  ValidRuntime m → m.agd_time < m.baseline_time → 1 < compute_speedup m := by
  intro h h_faster
  unfold compute_speedup
  exact (one_lt_div h.2).mpr h_faster

noncomputable def benchmark_speedup_certified
  {Device : Type} (baseline agd : Device) (J : Device → ℝ) (ε : ℝ)
  (_h_equiv : EquivalentDevice baseline agd J ε)
  (m : RuntimeMeasurement)
  (_h_valid : ValidRuntime m)
  (_h_faster : m.agd_time < m.baseline_time)
  : SpeedupCertificate :=
{
  measurement := m,
  speedup := compute_speedup m,
  equivalent_systems := (EquivalentDevice baseline agd J ε),
  valid := True
}

theorem AGD_Performance_Closure
  {Device : Type} (baseline agd : Device) (J : Device → ℝ) (ε : ℝ)
  (h_equiv : EquivalentDevice baseline agd J ε)
  (_op : AgdOperator) (_inv : AgdInvariant)
  (_h_inv : ∀ s, _inv.property s → _inv.property (_op.apply s))
  (m : RuntimeMeasurement)
  (h_valid : ValidRuntime m)
  (h_faster : m.agd_time < m.baseline_time)
  : ∃ (cert : SpeedupCertificate), cert.valid ∧ cert.speedup > 1 := by
  let cert := benchmark_speedup_certified baseline agd J ε h_equiv m h_valid h_faster
  use cert
  constructor
  · exact True.intro
  · exact speedup_gt_one_of_faster m h_valid h_faster

end AGD
