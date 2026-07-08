import Chronofold.AgdCore
import Chronofold.AgdOperators
import Chronofold.AgdInvariants
import Chronofold.AgdQuotient
import Mathlib.Data.Real.Basic
import Mathlib.Tactic

namespace AGD

/-
  State Space: H
  Invariant: Ω
  Operator Algebra: A = {O | Ω(Oψ) = Ω(ψ)}
  Adaptive Selector: pick an operator from A.
-/

variable {H : Type}
variable (Ω : H → ℝ)
variable (Loss : H → ℝ)

def IsAdmissible (O : H → H) : Prop :=
  ∀ ψ, Ω (O ψ) = Ω ψ

structure OperatorAlgebra (H : Type) (Ω : H → ℝ) where
  op : H → H
  admissible : IsAdmissible Ω op

/--
  Adaptive selection formalized as a property:
  An operator O is adaptive for ψ if it is admissible and no other O' in the set A
  has a strictly better loss.
-/
def IsAdaptive (ψ : H) (A : Set (OperatorAlgebra H Ω)) (O : OperatorAlgebra H Ω) : Prop :=
  O ∈ A ∧ ∀ O' ∈ A, Loss (O.op ψ) ≤ Loss (O'.op ψ)

theorem adaptive_operator_preservation
  (ψ : H) (A : Set (OperatorAlgebra H Ω)) (O_adapt : OperatorAlgebra H Ω)
  (h_sel : IsAdaptive Ω Loss ψ A O_adapt) :
  (Ω (O_adapt.op ψ) = Ω ψ) ∧
  (∀ O' ∈ A, Loss (O_adapt.op ψ) ≤ Loss (O'.op ψ)) := by
  constructor
  · exact O_adapt.admissible ψ
  · exact h_sel.2

end AGD
