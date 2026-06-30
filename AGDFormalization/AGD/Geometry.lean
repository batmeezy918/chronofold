import AGD.Transport

namespace AGDOperator

variable {H : Type*}
variable {Phi : PhiType H}

/-- Quotient descent barT. -/
def barT (T : AGDOperator H Phi) : AGDQuotient H → AGDQuotient H :=
  Quotient.map T.apply (by
    intro s1 s2 h
    constructor
    · rw [T.omega_preservation, T.omega_preservation]
      exact h.1
    · rw [T.cov_transport, T.cov_transport]
      rw [h.2]
      exact T.phi_well_defined h s2.cov
  )

/-- Quotient descent proof. -/
theorem descent_commute (T : AGDOperator H Phi) (s : AGDState H) :
  Pi (T.apply s) = barT T (Pi s) :=
  rfl

/-- Fixed point transport. -/
def Fixed {α : Type*} (f : α → α) (x : α) : Prop := f x = x

theorem fixed_point_transport (T : AGDOperator H Phi) (s : AGDState H) :
  Fixed T.apply s → Fixed (barT T) (Pi s) := by
  intro h
  unfold Fixed at h ⊢
  rw [← descent_commute, h]

/-- Reconstruction -/
noncomputable def R (H : Type*) : AGDQuotient H → AGDState H := Quotient.out

/-- For exact quotient, R(Pi(s)) = s only under canonical representative condition. -/
theorem reconstruction_exact (s : AGDState H) :
  R H (Pi s) = s ↔ (Quotient.mk (AGD_Setoid H) s).out = s :=
  Iff.rfl

end AGDOperator
