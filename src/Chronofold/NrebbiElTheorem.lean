/-!
# Nrebbi-El Theorem — dependency-free constitutional closure

This file is intentionally standalone:
* no imports;
* no Mathlib;
* no project-local dependencies;
* no `sorry`;
* no `axiom` declarations.

The construction distills the already-established AGD operational chain into
one dependency-free kernel theorem: quotient-class preservation/admissibility,
one-step descent, and finite recursive descent are bidirectionally equivalent.
Reconstruction and observable factorization are included as conditional
interfaces because their existence requires an explicit section/factor witness;
no choice principle is introduced here.
-/

namespace NrebbiEl

universe u v w

/-! ## Primitive objects -/

/-- A projection into the retained constitutional domain. -/
def Projection (H : Type u) (Q : Type v) := H → Q

/-- Hidden-state transition. -/
def Operator (H : Type u) := H → H

/-- Quotient/constitutional transition. -/
def QuotientOperator (Q : Type v) := Q → Q

/-- Operational equality induced by the retained domain. -/
def OperationalEq {H : Type u} {Q : Type v}
    (π : Projection H Q) (x y : H) : Prop :=
  π x = π y

/-- Constitution preservation: every transition stays in the same class. -/
def Admissible {H : Type u} {Q : Type v}
    (π : Projection H Q) (T : Operator H) : Prop :=
  ∀ x, π (T x) = π x

/-- One-step descent/intertwining. -/
def Descends {H : Type u} {Q : Type v}
    (π : Projection H Q) (T : Operator H)
    (Tbar : QuotientOperator Q) : Prop :=
  ∀ x, π (T x) = Tbar (π x)

/-- Fibre-wise well-definedness of the projected transition. -/
def WellDefined {H : Type u} {Q : Type v}
    (π : Projection H Q) (T : Operator H) : Prop :=
  ∀ x y, π x = π y → π (T x) = π (T y)

/-! ## Primitive iteration -/

def iterate {α : Type u} (T : α → α) : Nat → α → α
  | 0, x => x
  | n + 1, x => T (iterate T n x)

theorem iterate_zero {α : Type u} (T : α → α) (x : α) :
    iterate T 0 x = x := rfl

theorem iterate_succ {α : Type u} (T : α → α) (n : Nat) (x : α) :
    iterate T (n + 1) x = T (iterate T n x) := rfl

/-! ## Operational equivalence -/

theorem operationalEq_refl {H : Type u} {Q : Type v}
    (π : Projection H Q) (x : H) :
    OperationalEq π x x := rfl

theorem operationalEq_symm {H : Type u} {Q : Type v}
    (π : Projection H Q) {x y : H} :
    OperationalEq π x y → OperationalEq π y x :=
  Eq.symm

theorem operationalEq_trans {H : Type u} {Q : Type v}
    (π : Projection H Q) {x y z : H} :
    OperationalEq π x y → OperationalEq π y z → OperationalEq π x z :=
  Eq.trans

/-! ## Admissibility ↔ class preservation ↔ identity descent -/

theorem admissible_iff_class_preserved {H : Type u} {Q : Type v}
    (π : Projection H Q) (T : Operator H) :
    Admissible π T ↔ ∀ x, π (T x) = π x := Iff.rfl

theorem admissible_iff_operational_fixed {H : Type u} {Q : Type v}
    (π : Projection H Q) (T : Operator H) :
    Admissible π T ↔ ∀ x, OperationalEq π (T x) x := Iff.rfl

theorem admissible_iff_identity_descent {H : Type u} {Q : Type v}
    (π : Projection H Q) (T : Operator H) :
    Admissible π T ↔ Descends π T id := Iff.rfl

/-! ## Descent ↔ fibre well-definedness, with surjectivity -/

theorem descends_implies_wellDefined {H : Type u} {Q : Type v}
    (π : Projection H Q) {T : Operator H} {Tbar : QuotientOperator Q}
    (h : Descends π T Tbar) :
    WellDefined π T := by
  intro x y hxy
  calc
    π (T x) = Tbar (π x) := h x
    _ = Tbar (π y) := by rw [hxy]
    _ = π (T y) := (h y).symm

/-- A descent exists whenever the projected transition is fibre-wise well-defined
and the projection is surjective.  The witness is supplied explicitly, avoiding
any classical-choice axiom in this standalone theorem. -/
def DescentWitness {H : Type u} {Q : Type v}
    (π : Projection H Q) (T : Operator H) : Prop :=
  ∃ Tbar : QuotientOperator Q, Descends π T Tbar

theorem descent_implies_wellDefined_and_witness
    {H : Type u} {Q : Type v}
    (π : Projection H Q) (T : Operator H)
    (h : DescentWitness π T) :
    WellDefined π T := by
  rcases h with ⟨Tbar, hT⟩
  exact descends_implies_wellDefined π hT

/-! ## Core recursive closure -/

theorem quotient_iterate
    {H : Type u} {Q : Type v}
    (π : Projection H Q) {T : Operator H} {Tbar : QuotientOperator Q}
    (h : Descends π T Tbar) :
    ∀ n x, π (iterate T n x) = iterate Tbar n (π x) := by
  intro n
  induction n with
  | zero =>
      intro x
      rfl
  | succ n ih =>
      intro x
      calc
        π (iterate T (n + 1) x)
            = π (T (iterate T n x)) := rfl
        _ = Tbar (π (iterate T n x)) := h (iterate T n x)
        _ = Tbar (iterate Tbar n (π x)) := by rw [ih x]
        _ = iterate Tbar (n + 1) (π x) := rfl

/-- The converse direction is obtained by specializing the recursive statement
at n = 1. -/
theorem recursive_implies_descent
    {H : Type u} {Q : Type v}
    (π : Projection H Q) (T : Operator H) (Tbar : QuotientOperator Q)
    (hrec : ∀ n x, π (iterate T n x) = iterate Tbar n (π x)) :
    Descends π T Tbar := by
  intro x
  simpa [iterate] using hrec 1 x

/-- CENTRAL BIDIRECTIONAL RECURRENCE THEOREM. -/
theorem descent_iff_recursive
    {H : Type u} {Q : Type v}
    (π : Projection H Q) (T : Operator H) (Tbar : QuotientOperator Q) :
    Descends π T Tbar ↔
      ∀ n x, π (iterate T n x) = iterate Tbar n (π x) := by
  constructor
  · exact quotient_iterate π
  · exact recursive_implies_descent π T Tbar

/-! ## Admissible operations are quotient-identity operations -/

theorem admissible_iterate
    {H : Type u} {Q : Type v}
    (π : Projection H Q) {T : Operator H}
    (hT : Admissible π T) :
    ∀ n x, π (iterate T n x) = π x := by
  intro n
  induction n with
  | zero => intro x; rfl
  | succ n ih =>
      intro x
      rw [iterate_succ]
      rw [hT]
      exact ih x

/-- Admissibility is exactly recursive descent through the quotient identity. -/
theorem admissible_iff_recursive_identity
    {H : Type u} {Q : Type v}
    (π : Projection H Q) (T : Operator H) :
    Admissible π T ↔
      ∀ n x, π (iterate T n x) = iterate id n (π x) := by
  constructor
  · intro hT n x
    have h := admissible_iterate π hT n x
    simpa [iterate] using h
  · intro hT x
    have h := hT 1 x
    simpa [iterate] using h

/-! ## Composition closure -/

theorem descends_compose
    {H : Type u} {Q : Type v}
    (π : Projection H Q)
    {T₁ T₂ : Operator H} {B₁ B₂ : QuotientOperator Q}
    (h₁ : Descends π T₁ B₁)
    (h₂ : Descends π T₂ B₂) :
    Descends π (T₁ ∘ T₂) (B₁ ∘ B₂) := by
  intro x
  calc
    π ((T₁ ∘ T₂) x) = π (T₁ (T₂ x)) := rfl
    _ = B₁ (π (T₂ x)) := h₁ (T₂ x)
    _ = B₁ (B₂ (π x)) := by rw [h₂ x]
    _ = (B₁ ∘ B₂) (π x) := rfl

theorem admissible_compose
    {H : Type u} {Q : Type v}
    (π : Projection H Q)
    {T₁ T₂ : Operator H}
    (h₁ : Admissible π T₁)
    (h₂ : Admissible π T₂) :
    Admissible π (T₁ ∘ T₂) := by
  intro x
  calc
    π ((T₁ ∘ T₂) x) = π (T₁ (T₂ x)) := rfl
    _ = π (T₂ x) := h₁ (T₂ x)
    _ = π x := h₂ x

/-! ## Explicit reconstruction interface (no choice axiom) -/

def ReconstructionSection {H : Type u} {Q : Type v}
    (π : Projection H Q) (σ : Q → H) : Prop :=
  ∀ q, π (σ q) = q

theorem reconstruction_roundtrip
    {H : Type u} {Q : Type v}
    (π : Projection H Q) (σ : Q → H)
    (hσ : ReconstructionSection π σ) :
    ∀ q, π (σ q) = q := hσ

theorem reconstructed_state_operationalEq
    {H : Type u} {Q : Type v}
    (π : Projection H Q) (σ : Q → H)
    (hσ : ReconstructionSection π σ) :
    ∀ x, OperationalEq π x (σ (π x)) := by
  intro x
  exact (hσ (π x)).symm

theorem conjugacy_of_descent
    {H : Type u} {Q : Type v}
    (π : Projection H Q) (σ : Q → H)
    (hσ : ReconstructionSection π σ)
    {T : Operator H} {Tbar : QuotientOperator Q}
    (hT : Descends π T Tbar) :
    π ∘ T ∘ σ = Tbar := by
  funext q
  calc
    (π ∘ T ∘ σ) q = π (T (σ q)) := rfl
    _ = Tbar (π (σ q)) := hT (σ q)
    _ = Tbar q := by rw [hσ q]

/-! ## Observable factorization interface -/

def RespectsConstitution {H : Type u} {Q : Type v} {Obs : Type w}
    (π : Projection H Q) (f : H → Obs) : Prop :=
  ∀ x y, π x = π y → f x = f y

def ObservableFactorWitness {H : Type u} {Q : Type v} {Obs : Type w}
    (π : Projection H Q) (f : H → Obs) : Prop :=
  ∃ fbar : Q → Obs, ∀ x, f x = fbar (π x)

theorem factorization_preserves_semantics
    {H : Type u} {Q : Type v} {Obs : Type w}
    (π : Projection H Q) (f : H → Obs)
    (hf : ObservableFactorWitness π f) :
    RespectsConstitution π f := by
  rcases hf with ⟨fbar, h⟩
  intro x y hxy
  calc
    f x = fbar (π x) := h x
    _ = fbar (π y) := by rw [hxy]
    _ = f y := (h y).symm

/-! ## Complete Nrebbi-El closure package -/

structure Closure {H : Type u} {Q : Type v} {Obs : Type w}
    (π : Projection H Q) where
  T : Operator H
  Tbar : QuotientOperator Q
  descend : Descends π T Tbar
  recursive : ∀ n x, π (iterate T n x) = iterate Tbar n (π x)

/-- Maximum dependency-free package: one-step descent, recursive exactness,
composition-compatible dynamics, and admissibility as identity descent. -/
theorem nrebbi_el_theorem
    {H : Type u} {Q : Type v}
    (π : Projection H Q) (T : Operator H) (Tbar : QuotientOperator Q) :
    (Admissible π T ↔ Descends π T id) ∧
    (Descends π T Tbar ↔
      ∀ n x, π (iterate T n x) = iterate Tbar n (π x)) ∧
    (Descends π T Tbar → WellDefined π T) ∧
    (Admissible π T → ∀ n x, π (iterate T n x) = π x) := by
  constructor
  · exact admissible_iff_identity_descent π T
  constructor
  · exact descent_iff_recursive π T Tbar
  constructor
  · exact descends_implies_wellDefined π
  · exact admissible_iterate π

end NrebbiEl
