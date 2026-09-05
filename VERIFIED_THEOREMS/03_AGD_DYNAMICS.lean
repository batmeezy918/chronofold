import Chronofold.AgdIterate
import Chronofold.AgdUniversal
import Chronofold.AgdRank
import Chronofold.AgdMultiOmega
import Chronofold.AgdClassGraph

namespace Chronofold.AGD

/-! Verified capsule for iterative, universal, rank and graph dynamics. -/

 theorem VERIFIED_agd_admissible_iterate := admissible_iterate
 theorem VERIFIED_agd_lift_pi := lift_pi
 theorem VERIFIED_agd_projective_collapse := projective_collapse
 theorem VERIFIED_agd_multi_equiv := MultiEquiv
 theorem VERIFIED_agd_certified_edge_class_step := certifiedEdge_class_step

end Chronofold.AGD
