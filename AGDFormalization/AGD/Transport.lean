import AGD.Operator
import AGD.Quotient

variable {H : Type*}

/-- Transport function Φ that transforms the Covariant signature. -/
def PhiType (H : Type*) := (H → Prop) → AGDState H → (H → Prop)

/-- An AGDOperator preserves Ω and transforms C via Φ. -/
structure AGDOperator (H : Type*) (Phi : PhiType H) extends Operator H where
  omega_preservation : ∀ s : AGDState H, (apply s).omega = s.omega
  cov_transport : ∀ s : AGDState H, (apply s).cov = Phi s.cov s
  phi_well_defined : ∀ {s1 s2 : AGDState H}, s1 ≈ s2 → ∀ cov, Phi cov s1 = Phi cov s2

namespace AGDOperator

theorem invariant {Phi : PhiType H} (T : AGDOperator H Phi) (s : AGDState H) :
  (T.apply s).omega = s.omega :=
  T.omega_preservation s

theorem covariant {Phi : PhiType H} (T : AGDOperator H Phi) (s : AGDState H) :
  (T.apply s).cov = Phi s.cov s :=
  T.cov_transport s

end AGDOperator
