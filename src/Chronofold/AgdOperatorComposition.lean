import Chronofold.MeasurementCertificate
import Mathlib.Data.Real.Basic
import Mathlib.Tactic

namespace AGD

structure OperatorChain where
  apply_chain : MeasurementState → MeasurementState

def EquivalentState (A B : MeasurementState) : Prop :=
  A.jitter = B.jitter ∧ A.error = B.error

theorem operator_chain_preserves_equivalence
  (chain : OperatorChain) (A B : MeasurementState)
  (h_equiv : EquivalentState A B)
  (h_chain_preserves : ∀ (s1 s2 : MeasurementState), EquivalentState s1 s2 → EquivalentState (chain.apply_chain s1) (chain.apply_chain s2)) :
  EquivalentState (chain.apply_chain A) (chain.apply_chain B) := by
  apply h_chain_preserves
  exact h_equiv

end AGD
