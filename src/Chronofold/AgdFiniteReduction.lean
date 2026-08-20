import Chronofold.AgdFibreClosure

/-!
# AGD Finite Quotient Reduction

Finite operational-domain version of the constructive reduction implication.
-/

namespace Chronofold.AGD

universe u

/-- If a surjective map between finite types is noninjective, its codomain
    has strictly smaller cardinality. -/
theorem strict_card_of_surjective_not_injective
    {S : Type u} {Q : Type u}
    [Fintype S] [Fintype Q]
    (p : S → Q)
    (hsurj : Function.Surjective p)
    (hninj : ¬ Function.Injective p) :
    Fintype.card Q < Fintype.card S := by
  exact Fintype.card_lt_of_surjective_of_not_injective p hsurj hnin j

/-- AGD's canonical quotient projection is surjective by construction. -/
theorem pi_surjective
    (α : Type u)
    (Ω : Omega α)
    (C : Covariant α) :
    Function.Surjective (pi α Ω C) := by
  intro q
  refine Quotient.inductionOn q ?_
  intro s
  exact ⟨s, rfl⟩

/-- On any finite operational state type carrying the AGD quotient map,
    a nontrivial fibre yields strict quotient reduction. -/
theorem nontrivial_fibre_strict_reduction
    {S : Type u}
    (α : Type u)
    (Ω : Omega α)
    (C : Covariant α)
    [Fintype S]
    [Fintype (QStar α Ω C)]
    (embed : S → State α)
    (cover : Function.Surjective (fun s : S => pi α Ω C (embed s)))
    (hF : ∃ s₁ s₂ : S,
      s₁ ≠ s₂ ∧
      Ω (embed s₁) = Ω (embed s₂) ∧
      C (embed s₁) = C (embed s₂)) :
    Fintype.card (QStar α Ω C) < Fintype.card S := by
  let p : S → QStar α Ω C := fun s => pi α Ω C (embed s)
  have hp : ¬ Function.Injective p := by
    intro hinj
    rcases hF with ⟨s₁, s₂, hne, hΩ, hC⟩
    have hPi : p s₁ = p s₂ := by
      apply Quotient.sound
      exact ⟨hΩ, hC⟩
    exact hne (hinj hPi)
  exact strict_card_of_surjective_not_injective p cover hp

end Chronofold.AGD
