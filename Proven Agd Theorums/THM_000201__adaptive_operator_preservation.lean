import Chronofold.AgdAdaptiveOperator

-- THEOREM_ID: THM_000201
-- TITLE: AGD Adaptive Operator Selection Preservation
-- AUTHOR: Jules
-- STATUS: verified_by_lean

namespace AGD

theorem adaptive_operator_preservation
  (ψ : H) (A : Set (OperatorAlgebra H Ω)) (O_adapt : OperatorAlgebra H Ω)
  (h_sel : IsAdaptive Ω Loss ψ A O_adapt) :
  (Ω (O_adapt.op ψ) = Ω ψ) ∧
  (∀ O' ∈ A, Loss (O_adapt.op ψ) ≤ Loss (O'.op ψ)) := by
  constructor
  · exact O_adapt.admissible ψ
  · exact h_sel.2

end AGD
