import Chronofold.AgdBidirectional
import Chronofold.AgdInvariantSafety
import Chronofold.AgdUniversal
import Chronofold.AgdIterate

namespace Verified_01_MasterBidirectionalOperationalClosure

open Chronofold.AGD

/- Re-export of the exact kernel theorem already present on main. -/
 theorem admissible_iff_preservesClass := Chronofold.AGD.admissible_iff_preservesClass
 theorem admissible_iff_class_eq := Chronofold.AGD.admissible_iff_class_eq
 theorem TBar_unique := Chronofold.AGD.TBar_unique
 theorem master_bidirectional_operational_closure := Chronofold.AGD.master_bidirectional_operational_closure

end Verified_01_MasterBidirectionalOperationalClosure
