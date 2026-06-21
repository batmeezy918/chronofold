import Chronofold.MeasurementCertificate
import Chronofold.PerformanceCertificate
import Chronofold.SearchCompressionCertificate
import Chronofold.AgdFullClosure
import Mathlib.Tactic

namespace AGD

structure AGDCertificate where
  equivalence : Prop
  invariant_valid : Prop
  compression_valid : Prop
  performance_valid : Prop

def agd_complete_certificate
  (h_equiv : Prop) (h_inv : Prop) (h_comp : Prop) (h_perf : Prop)
  (he : h_equiv) (hi : h_inv) (hc : h_comp) (hp : h_perf) :
  AGDCertificate :=
{
  equivalence := h_equiv,
  invariant_valid := h_inv,
  compression_valid := h_comp,
  performance_valid := h_perf
}

end AGD
