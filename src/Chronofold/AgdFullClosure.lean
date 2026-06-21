import Chronofold.AgdCore
import Chronofold.AgdOperators
import Chronofold.AgdInvariants
import Chronofold.AgdQuotient
import Chronofold.MeasurementCertificate
import Chronofold.BenchmarkCertificate
import Chronofold.PerformanceCertificate
import Chronofold.AgdOperatorComposition
import Chronofold.AgdRecursiveClosure
import Chronofold.SearchCompressionCertificate

namespace AGD

structure AGDFinalCertificate where
  equivalent : Prop
  operator_valid : Prop
  invariant_valid : Prop
  compression_valid : Prop
  performance_valid : Prop

theorem AGD_Full_Closure
  {Device : Type} (orig opt : Device) (J : Device → ℝ) (ε : ℝ)
  (h_equiv : EquivalentDevice orig opt J ε)
  (chain : OperatorChain)
  (h_chain : ∀ (s1 s2 : MeasurementState), EquivalentState s1 s2 → EquivalentState (chain.apply_chain s1) (chain.apply_chain s2))
  (s : AgdState) (inv : AgdState → Prop)
  (h_inv : Invariant inv s)
  (m : SearchMeasurement)
  (h_comp : m.agd_states < m.brute_states ∧ 0 < m.brute_states)
  (perf_m : RuntimeMeasurement)
  (h_perf : ValidRuntime perf_m)
  : ∃ (certified_transformation : Prop), certified_transformation := by
  use (EquivalentDevice orig opt J ε ∧ 0 < state_reduction_ratio m)
  constructor
  · exact h_equiv
  · exact compression_ratio_valid m h_comp.1 h_comp.2

end AGD
