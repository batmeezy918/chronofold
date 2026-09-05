import Chronofold.AgdBidirectional
import Chronofold.AgdFibreClosure
import Chronofold.AgdFiniteReduction
import Chronofold.AgdInvariantSafety
import Chronofold.AgdSicConstitutional
import Chronofold.AgdWitness
import Chronofold.AgdProductionWitness
import Chronofold.AgdOperationalQuotient

namespace Chronofold.AGD

/-! Verified capsule for quotient, reconstruction, fibre, witness, SIC,
measurement-adjacent and invariant-safety theorem families. -/

 theorem VERIFIED_agd_exists_reconstruct := exists_reconstruct
 theorem VERIFIED_agd_fibre_witness_collapses := fibre_witness_collapses
 theorem VERIFIED_agd_pi_surjective := pi_surjective
 theorem VERIFIED_agd_invariantSafe_omega_and_C := invariantSafe_omega_and_C
 theorem VERIFIED_agd_sic_operational_equality := sic_operational_equality
 theorem VERIFIED_agd_quotient_of_full_chain := quotient_of_full_chain

end Chronofold.AGD
