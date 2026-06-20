import Chronofold.AGD.Operators
namespace Chronofold
section Reconstruction
variable {H : Type*} [NormedAddCommGroup H] [NormedSpace ℝ H]
variable {Q : Type*} [NormedAddCommGroup Q] [NormedSpace ℝ Q]
def reconstruction_bound (ψ : H) (F : H → H) (R : H → H) (ε : ℝ) : Prop :=
  ‖R (F ψ) - ψ‖ ≤ ε
end Reconstruction
end Chronofold
