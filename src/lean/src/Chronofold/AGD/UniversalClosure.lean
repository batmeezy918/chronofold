import Chronofold.AGD.Invariants

namespace Chronofold

section Closure

variable {H : Type*} [NormedAddCommGroup H] [NormedSpace ℝ H]
variable {Q : Type*} [NormedAddCommGroup Q] [NormedSpace ℝ Q]

/-- AGD Universal Closure Theorem -/
theorem AGD_Universal_Closure
  (ψ : H)
  (O : Operator H)
  (p : H → Q)
  (reconstruct : Q → H)
  (ε : ℝ)
  (h_inv : Invariant (O ψ) = Invariant ψ)
  (h_recon : reconstruction_valid (O ψ) p reconstruct ε) :
  ∃ ψ', ψ' = O ψ ∧ Invariant ψ' = Invariant ψ ∧ reconstruction_valid ψ' p reconstruct ε :=
  ⟨O ψ, rfl, h_inv, h_recon⟩

end Closure

end Chronofold
