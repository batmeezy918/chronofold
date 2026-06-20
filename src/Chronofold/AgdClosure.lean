import Chronofold.AgdOperators
import Chronofold.MeasurementCertificate

namespace AGD

structure AGDCertifiedState where
  state : MeasurementState
  invariant_ok : Prop
  measurement_ok : Prop

structure AGDTransition where
  before : AGDCertifiedState
  after : AGDCertifiedState
  preserves_invariant : Prop
  measurement_mapping_ok : before.measurement_ok → after.measurement_ok
  invariant_transition_ok : before.invariant_ok → after.invariant_ok

def CertificationPreserved (t : AGDTransition) : Prop :=
  t.before.measurement_ok →
  t.before.invariant_ok →
  t.after.measurement_ok ∧ t.after.invariant_ok

/--
Theorem: Certified AGD transformations preserve certification.
Establishing: certified input -> AGD transformation -> certified output.
-/
theorem AGD_certification_closure :
  ∀ t : AGDTransition, CertificationPreserved t := by
  intro t hm hi
  constructor
  · exact t.measurement_mapping_ok hm
  · exact t.invariant_transition_ok hi

end AGD
