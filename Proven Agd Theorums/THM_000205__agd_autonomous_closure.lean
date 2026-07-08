import Chronofold.AgdAutonomousClosure

-- THEOREM_ID: THM_000205
-- TITLE: AGD Autonomous Optimization Closure Theorem
-- AUTHOR: Jules
-- STATUS: verified_by_lean

namespace AGD

theorem agd_autonomous_closure
  (c : AGDCycle H) :
  let ψ_final := execute_cycle c
  c.Ω ψ_final = c.Ω c.ψ_init := by
  unfold execute_cycle
  exact c.O_adapt.admissible c.ψ_init

end AGD
