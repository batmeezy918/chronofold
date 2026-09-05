import Chronofold.NrebbiElSimulation

namespace Chronofold.NrebbiEl

/-! Compact examination capsule for the machine-checked simulation kernel. -/

 theorem VERIFIED_descends_iff_simulates := descends_iff_simulates
 theorem VERIFIED_descends_implies_recursive := descends_implies_recursive
 theorem VERIFIED_recursive_implies_simulates := recursive_implies_simulates
 theorem VERIFIED_descends_iff_exact_trajectory := descends_iff_exact_trajectory
 theorem VERIFIED_nrebbi_el_simulation_theorem := nrebbi_el_simulation_theorem

end Chronofold.NrebbiEl
