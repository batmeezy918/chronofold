import Chronofold.MeasurementCertificate
import Mathlib.Data.List.Basic

namespace AGD

structure AGDConfiguration where
  state : MeasurementState
  rules : List ℕ
  operators : List ℕ

def reconstruct (config : AGDConfiguration) : MeasurementState :=
  config.state

theorem agd_reconstruction_deterministic (A B : AGDConfiguration) (h : A = B) :
  reconstruct A = reconstruct B := by
  rw [h]

end AGD
