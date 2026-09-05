import Chronofold.AgdCore
import Chronofold.AgdOperators
import Chronofold.AgdInvariants
import Chronofold.AgdClosure

namespace Chronofold.AGD

/-! Verified capsule for the core AGD algebra and operator layer. -/

 theorem VERIFIED_agd_core_equiv := AGDEquiv
 theorem VERIFIED_agd_tbar_sound := TBar_sound
 theorem VERIFIED_agd_interchangeable_iff := interchangeable_iff
 theorem VERIFIED_agd_admission_iff_tbar := admission_iff_TBar
 theorem VERIFIED_agd_admissible_compose := admissible_compose

end Chronofold.AGD
