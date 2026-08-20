import Chronofold.AgdUniversal

/-!
# AGD Fibre Closure

This file proves the exact implication chain available from the existing
constitution:

  nontrivial AGD fibre
    -> noninjective canonical quotient projection.

No new observable, operator, invariant, or approximation is introduced.
-/

namespace Chronofold.AGD

universe u

/-- A concrete witness of a non-singleton AGD observational fibre. -/
def NontrivialAGDFibre
    (α : Type u)
    (Ω : Omega α)
    (C : Covariant α) : Prop :=
  ∃ s₁ s₂ : State α,
    s₁ ≠ s₂ ∧
    Ω s₁ = Ω s₂ ∧
    C s₁ = C s₂

/-- A nontrivial AGD fibre makes the canonical quotient projection
    non-injective. -/
theorem nontrivial_fibre_pi_not_injective
    (α : Type u)
    (Ω : Omega α)
    (C : Covariant α)
    (hF : NontrivialAGDFibre α Ω C) :
    ¬ Function.Injective (pi α Ω C) := by
  intro hInjective
  rcases hF with ⟨s₁, s₂, hne, hΩ, hC⟩
  have hPi : pi α Ω C s₁ = pi α Ω C s₂ := by
    apply Quotient.sound
    exact ⟨hΩ, hC⟩
  exact hne (hInjective hPi)

/-- A concrete fibre witness gives exact quotient equality. -/
theorem fibre_witness_collapses
    (α : Type u)
    (Ω : Omega α)
    (C : Covariant α)
    {s₁ s₂ : State α}
    (hΩ : Ω s₁ = Ω s₂)
    (hC : C s₁ = C s₂) :
    pi α Ω C s₁ = pi α Ω C s₂ := by
  apply Quotient.sound
  exact ⟨hΩ, hC⟩

end Chronofold.AGD
