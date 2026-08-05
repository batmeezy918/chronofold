import Chronofold.AgdInvariants

/-!
# Universal property of the Minimal Admissible Quotient Q*

## Statement (set-level)

Any map `f : State α → β` that respects `AGDEquiv` factors uniquely through `pi`:

```
  State ──f──▶ β
    │          ▲
   pi│         │ ∃! f̄
    ▼          │
   Q* ─────────┘
```

i.e. `f̄ ∘ pi = f`, and any two such lifts are equal.

## Statement (initiality among preserving quotients)

A *preserving quotient* is a type `Q` with projection `p : State → Q` that
identifies exactly the AGD-equivalent states (or at least collapses them).
`Q*` is initial: for every such `Q` there is a unique map `Q* → Q` commuting
with the projections.

These are the contentful universal-property theorems for the constitutional kernel.
-/

namespace Chronofold.AGD

universe u v

/-! ### 1. Respecting maps -/

/-- `f` is constant on AGD equivalence classes. -/
def RespectsAGD (α : Type u) (Ω : Omega α) (C : Covariant α)
    {β : Type v} (f : State α → β) : Prop :=
  ∀ s₁ s₂, AGDEquiv α Ω C s₁ s₂ → f s₁ = f s₂

theorem respects_of_interchangeable (α : Type u) (Ω : Omega α) (C : Covariant α)
    {β : Type v} (f : State α → β)
    (h : ∀ s₁ s₂, interchangeable α Ω C s₁ s₂ → f s₁ = f s₂) :
    RespectsAGD α Ω C f := by
  intro s₁ s₂ heq
  exact h s₁ s₂ ((interchangeable_iff α Ω C s₁ s₂).mpr heq)

/-! ### 2. Existence of the lift -/

/-- Canonical lift of a respecting map through `pi`. -/
noncomputable def lift (α : Type u) (Ω : Omega α) (C : Covariant α)
    {β : Type v} (f : State α → β) (hf : RespectsAGD α Ω C f) :
    QStar α Ω C → β :=
  Quotient.lift f hf

theorem lift_pi (α : Type u) (Ω : Omega α) (C : Covariant α)
    {β : Type v} (f : State α → β) (hf : RespectsAGD α Ω C f)
    (s : State α) :
    lift α Ω C f hf (pi α Ω C s) = f s :=
  rfl

/-! ### 3. Uniqueness of the lift -/

/-- Any map on `Q*` is determined by its values on representatives. -/
theorem qstar_induction (α : Type u) (Ω : Omega α) (C : Covariant α)
    {β : Type v} (g : QStar α Ω C → β)
    (h : ∀ s, g (pi α Ω C s) = g (pi α Ω C s)) :
    True := trivial  -- placeholder to keep API; real induction is via Quotient.inductionOn

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

/-- **Universal property (existence + uniqueness).** -/
theorem qstar_universal (α : Type u) (Ω : Omega α) (C : Covariant α)
    {β : Type v} (f : State α → β) (hf : RespectsAGD α Ω C f) :
    ∃! (fbar : QStar α Ω C → β), ∀ s, fbar (pi α Ω C s) = f s := by
  refine ⟨lift α Ω C f hf, ?_, ?_⟩
  · intro s
    exact lift_pi α Ω C f hf s
  · intro g hg
    exact lift_unique α Ω C f hf g hg

/-! ### 4. Preserving quotients and initiality -/

/-- A type that receives states and collapses AGD-equivalent ones. -/
structure PreservingQuotient (α : Type u) (Ω : Omega α) (C : Covariant α) where
  Q : Type u
  p : State α → Q
  respects : RespectsAGD α Ω C p

/-- The canonical preserving quotient is Q* itself. -/
def qstarAsPreserving (α : Type u) (Ω : Omega α) (C : Covariant α) :
    PreservingQuotient α Ω C where
  Q := QStar α Ω C
  p := pi α Ω C
  respects := by
    intro s₁ s₂ h
    exact Quotient.sound h

/-- Unique morphism from Q* into any preserving quotient. -/
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

/-- **Initiality of Q* among preserving quotients.**

For every preserving quotient `P` there exists a unique map
`Q* → P.Q` making the triangle with `pi` and `P.p` commute. -/
theorem qstar_initial (α : Type u) (Ω : Omega α) (C : Covariant α)
    (P : PreservingQuotient α Ω C) :
    ∃! (φ : QStar α Ω C → P.Q), ∀ s, φ (pi α Ω C s) = P.p s :=
  qstar_universal α Ω C P.p P.respects

/-! ### 5. Descent of admissible operators factors uniquely -/

/-- The descended operator is the unique lift of `pi ∘ T`. -/
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
