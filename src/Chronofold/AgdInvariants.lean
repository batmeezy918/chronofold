import Chronofold.AgdOperators

/-!
# AGD Invariants — interchangeability and admission
-/

namespace Chronofold.AGD

universe u

def interchangeable (α : Type u) (Ω : Omega α) (C : Covariant α)
    (s₁ s₂ : State α) : Prop :=
  pi α Ω C s₁ = pi α Ω C s₂

theorem interchangeable_iff (α : Type u) (Ω : Omega α) (C : Covariant α)
    (s₁ s₂ : State α) :
    interchangeable α Ω C s₁ s₂ ↔ AGDEquiv α Ω C s₁ s₂ := by
  unfold interchangeable
  constructor
  · intro h
    exact Quotient.exact h
  · intro h
    exact Quotient.sound h

theorem admission_iff_TBar (α : Type u) (Ω : Omega α) (C : Covariant α)
    (T : Operator α) :
    Admissible α Ω C T ↔
      ∃ (h : Admissible α Ω C T),
        ∀ s, TBar α Ω C T h (pi α Ω C s) = pi α Ω C (T s) := by
  constructor
  · intro hT
    exact ⟨hT, fun _ => TBar_sound α Ω C T hT _⟩
  · intro ⟨hT, _⟩
    exact hT

theorem admissible_implies_descends (α : Type u) (Ω : Omega α) (C : Covariant α)
    (T : Operator α) (hT : Admissible α Ω C T) :
    ∃ Tbar : QStar α Ω C → QStar α Ω C,
      ∀ s, Tbar (pi α Ω C s) = pi α Ω C (T s) :=
  ⟨TBar α Ω C T hT, fun _ => rfl⟩

end Chronofold.AGD
