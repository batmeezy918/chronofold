import Chronofold.AgdCore
import Chronofold.AgdOperators
import Chronofold.AgdInvariants

namespace AGD

structure CertifiedOperatorTransition where
  state_before : AgdState
  state_after : AgdState
  operator : AgdOperator

def operator_preserves_AGD (t : CertifiedOperatorTransition) (inv : AgdInvariant) : Prop :=
  inv.property t.state_before → inv.property (t.operator.apply t.state_before)

theorem AGD_operator_soundness
  (inv : AgdInvariant) (t : CertifiedOperatorTransition)
  (h_preserved : operator_preserves_AGD t inv)
  (h_before : inv.property t.state_before)
  : inv.property (t.operator.apply t.state_before) := by
  apply h_preserved
  exact h_before

end AGD
