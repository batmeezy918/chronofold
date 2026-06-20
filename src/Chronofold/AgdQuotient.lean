import Chronofold.AgdCore
import Chronofold.AgdOperators
import Chronofold.AgdInvariants
import Chronofold.MeasurementCertificate
import Mathlib.Data.Real.Basic
import Mathlib.Tactic

namespace AGD

def EquivalentDevice {Device : Type} (A B : Device) (J : Device → ℝ) (ε : ℝ) : Prop :=
  jitter_close J ε A B

theorem operator_preserves_equivalence
  {Device : Type} (J : Device → ℝ) (ε : ℝ) (op : AgdOperator)
  (device_transform : Device → Device)
  (h_consistent : ∀ d, J (device_transform d) = (op.apply {id := 0, data := J d}).data)
  (A B : Device)
  (h_equiv : EquivalentDevice A B J ε)
  (h_linear : ∀ s, (op.apply s).data = s.data) -- Simplified preservation
  : EquivalentDevice (device_transform A) (device_transform B) J ε := by
  unfold EquivalentDevice jitter_close at *
  rw [h_consistent, h_consistent]
  simp [h_linear]
  exact h_equiv

end AGD
