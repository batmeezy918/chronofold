import Chronofold.AgdCore

/-!
# AGD Operators — equivalence, quotient, descent
-/

namespace Chronofold.AGD

universe u

def AGDEquiv (α : Type u) (Ω : Omega α) (C : Covariant α)
    (s₁ s₂ : State α) : Prop :=
  Ω s₁ = Ω s₂ ∧ C s₁ = C s₂

theorem AGDEquiv.refl (α : Type u) (Ω : Omega α) (C : Covariant α)
    (s : State α) : AGDEquiv α Ω C s s := ⟨rfl, rfl⟩

theorem AGDEquiv.symm (α : Type u) (Ω : Omega α) (C : Covariant α)
    {s₁ s₂ : State α} (h : AGDEquiv α Ω C s₁ s₂) :
    AGDEquiv α Ω C s₂ s₁ := ⟨h.1.symm, h.2.symm⟩

theorem AGDEquiv.trans (α : Type u) (Ω : Omega α) (C : Covariant α)
    {s₁ s₂ s₃ : State α}
    (h₁₂ : AGDEquiv α Ω C s₁ s₂) (h₂₃ : AGDEquiv α Ω C s₂ s₃) :
    AGDEquiv α Ω C s₁ s₃ :=
  ⟨h₁₂.1.trans h₂₃.1, h₁₂.2.trans h₂₃.2⟩

def agdSetoid (α : Type u) (Ω : Omega α) (C : Covariant α) : Setoid (State α) where
  r := AGDEquiv α Ω C
  iseqv := ⟨AGDEquiv.refl α Ω C, AGDEquiv.symm α Ω C, AGDEquiv.trans α Ω C⟩

def QStar (α : Type u) (Ω : Omega α) (C : Covariant α) : Type u :=
  Quotient (agdSetoid α Ω C)

def pi (α : Type u) (Ω : Omega α) (C : Covariant α) : State α → QStar α Ω C :=
  Quotient.mk (agdSetoid α Ω C)

noncomputable def TBar (α : Type u) (Ω : Omega α) (C : Covariant α)
    (T : Operator α) (hT : Admissible α Ω C T) :
    QStar α Ω C → QStar α Ω C :=
  Quotient.lift (fun s => pi α Ω C (T s))
    (by
      intro s₁ s₂ h
      apply Quotient.sound
      have ⟨hΩ, hC⟩ := h
      have ⟨hTΩ₁, hTC₁⟩ := hT s₁
      have ⟨hTΩ₂, hTC₂⟩ := hT s₂
      constructor
      · rw [hTΩ₁, hTΩ₂, hΩ]
      · rw [hTC₁, hTC₂, hC])

theorem TBar_sound (α : Type u) (Ω : Omega α) (C : Covariant α)
    (T : Operator α) (hT : Admissible α Ω C T) (s : State α) :
    TBar α Ω C T hT (pi α Ω C s) = pi α Ω C (T s) := rfl

end Chronofold.AGD
