import Chronofold.ConstitutionalKernelT0

namespace Chronofold.VerifiedTheorems
open Chronofold.ConstitutionalKernelT0

-- Canonical GREEN theorem capsule; kernel proof remains in the imported source.
#check T0_1_namespace_preservation
#check T0_2_version_preservation
#check T0_3_provenance_preservation
#check T0_4_relationship_resolution_preservation
#check T0_5_acyclicity_preservation
#check T0_6_omega_preservation
#check T0_6_omega_characterization
#check admissibility_closure
#check operator_composition_closed
#check iterate_admissible
#check constitutional_closure
#check initial_omega
#check stampVersion_admissible
#check addNode_admissible
#check wipeNs_not_namespace_preserving
#check wipeNs_breaks_omega
#check t0_maximal_operational_kernel

end Chronofold.VerifiedTheorems
