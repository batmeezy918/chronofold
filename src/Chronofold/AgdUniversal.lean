import Chronofold.AgdInvariants

/-!
# Universal property of the Minimal Admissible Quotient Q*

Lean 4.29 accepted: lake build Chronofold succeeded (2026-08-05).
-/

namespace Chronofold.AGD

universe u v

def RespectsAGD (α : Type u) (Ω : Omega α) (C : Covariant α)
    {β : Type v} (f : State α → β) : Prop :=
  ∀ s₁ s₂, AGDEquiv α Ω C s₁ s₂ → f s₁ = f s₂

theorem respects_of_interchangeable (α : Type u) (Ω : Omega α) (C : Covariant α)
    {β : Type v} (f : State α → β)
    (h : ∀ s₁ s₂, interchangeable α Ω C s₁ s₂ → f s₁ = f s₂) :
    RespectsAGD α Ω C f := by
  intro s₁ s₂ heq
  exact h s₁ s₂ ((interchangeable_iff α Ω C s₁ s₂).mpr heq)

noncomputable def lift (α : Type u) (Ω : Omega α) (C : Covariant α)
    {β : Type v} (f : State α → β) (hf : RespectsAGD α Ω C f) :
    QStar α Ω C → β :=
  Quotient.lift f hf

theorem lift_pi (α : Type u) (Ω : Omega α) (C : Covariant α)
    {β : Type v} (f : State α → β) (hf : RespectsAGD α Ω C f)
    (s : State α) :
    lift α Ω C f hf (pi α Ω C s) = f s :=
  rfl

theorem lift_unique (α : Type u) (Ω : Omega α) (C : Covariant α)
    {β : Type v} (f : State α → β) (hf : RespectsAGD α Ω C f)
    (g : QStar α Ω C → β)
    (hg : ∀ s, g (pi α Ω C s) = f s) :
    g = lift α Ω C f hf := by
  funext q
  refine Quotient.inductionOn q ?_
  intro s
  calc g (pi α Ω C s)
      = f s := hg s
    _ = lift α Ω C f hf (pi α Ω C s) := (lift_pi α Ω C f hf s).symm

theorem qstar_universal_exists (α : Type u) (Ω : Omega α) (C : Covariant α)
    {β : Type v} (f : State α → β) (hf : RespectsAGD α Ω C f) :
    ∃ fbar : QStar α Ω C → β, ∀ s, fbar (pi α Ω C s) = f s :=
  ⟨lift α Ω C f hf, fun s => lift_pi α Ω C f hf s⟩

theorem qstar_universal_unique (α : Type u) (Ω : Omega α) (C : Covariant α)
    {β : Type v} (f : State α → β) (hf : RespectsAGD α Ω C f)
    (g₁ g₂ : QStar α Ω C → β)
    (h₁ : ∀ s, g₁ (pi α Ω C s) = f s)
    (h₂ : ∀ s, g₂ (pi α Ω C s) = f s) :
    g₁ = g₂ := by
  calc g₁ = lift α Ω C f hf := lift_unique α Ω C f hf g₁ h₁
    _ = g₂ := (lift_unique α Ω C f hf g₂ h₂).symm

theorem qstar_universal (α : Type u) (Ω : Omega α) (C : Covariant α)
    {β : Type v} (f : State α → β) (hf : RespectsAGD α Ω C f) :
    (∃ fbar : QStar α Ω C → β, ∀ s, fbar (pi α Ω C s) = f s) ∧
    (∀ g₁ g₂ : QStar α Ω C → β,
      (∀ s, g₁ (pi α Ω C s) = f s) →
      (∀ s, g₂ (pi α Ω C s) = f s) → g₁ = g₂) :=
  ⟨qstar_universal_exists α Ω C f hf, qstar_universal_unique α Ω C f hf⟩

structure PreservingQuotient (α : Type u) (Ω : Omega α) (C : Covariant α) where
  Q : Type u
  p : State α → Q
  respects : RespectsAGD α Ω C p

def qstarAsPreserving (α : Type u) (Ω : Omega α) (C : Covariant α) :
    PreservingQuotient α Ω C where
  Q := QStar α Ω C
  p := pi α Ω C
  respects := by
    intro s₁ s₂ h
    exact Quotient.sound h

noncomputable def morphTo (α : Type u) (Ω : Omega α) (C : Covariant α)
    (P : PreservingQuotient α Ω C) :
    QStar α Ω C → P.Q :=
  lift α Ω C P.p P.respects

theorem morphTo_commutes (α : Type u) (Ω : Omega α) (C : Covariant α)
    (P : PreservingQuotient α Ω C) (s : State α) :
    morphTo α Ω C P (pi α Ω C s) = P.p s :=
  lift_pi α Ω C P.p P.respects s

theorem morphTo_unique (α : Type u) (Ω : Omega α) (C : Covariant α)
    (P : PreservingQuotient α Ω C)
    (g : QStar α Ω C → P.Q)
    (hg : ∀ s, g (pi α Ω C s) = P.p s) :
    g = morphTo α Ω C P :=
  lift_unique α Ω C P.p P.respects g hg

theorem qstar_initial (α : Type u) (Ω : Omega α) (C : Covariant α)
    (P : PreservingQuotient α Ω C) :
    (∃ φ : QStar α Ω C → P.Q, ∀ s, φ (pi α Ω C s) = P.p s) ∧
    (∀ g₁ g₂ : QStar α Ω C → P.Q,
      (∀ s, g₁ (pi α Ω C s) = P.p s) →
      (∀ s, g₂ (pi α Ω C s) = P.p s) → g₁ = g₂) :=
  qstar_universal α Ω C P.p P.respects

theorem TBar_is_lift (α : Type u) (Ω : Omega α) (C : Covariant α)
    (T : Operator α) (hT : Admissible α Ω C T) :
    TBar α Ω C T hT =
      lift α Ω C (fun s => pi α Ω C (T s))
        (by
          intro s₁ s₂ h
          apply Quotient.sound
          have ⟨hΩ, hC⟩ := h
          have ⟨a₁, b₁⟩ := hT s₁
          have ⟨a₂, b₂⟩ := hT s₂
          exact ⟨a₁.trans (hΩ.trans a₂.symm), b₁.trans (hC.trans b₂.symm)⟩) := by
  funext q
  refine Quotient.inductionOn q ?_
  intro s
  rfl

end Chronofold.AGD
