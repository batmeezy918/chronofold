import Mathlib

/-!
# T1 — AGD Controlled Quotient / Bisimulation Kernel

First Mathlib-backed core theorem for the operational AGD layer.

Dependency spine:

  Setoid information quotient
      ↓
  controlled congruence of admissible transitions
      ↓
  well-defined quotient transition
      ↓
  exact controlled bisimulation
      ↓
  finite-trace invariant preservation

This file deliberately separates logical certification from empirical model
identification. A telemetry/Koopman experiment may propose a relation; Lean
certifies the consequences only after the relation satisfies these hypotheses.
-/

universe u v

namespace Chronofold
namespace AGD

/-- Deterministic controlled transition system. -/
structure ControlledSystem where
  State : Type u
  Act   : Type v
  step  : Act → State → State

/-- Every common control action preserves the proposed information equivalence. -/
def ControlledCongruence
    (Sys : ControlledSystem)
    (R : Sys.State → Sys.State → Prop) : Prop :=
  ∀ ⦃x y : Sys.State⦄, R x y → ∀ a : Sys.Act,
    R (Sys.step a x) (Sys.step a y)

/-- Deterministic controlled bisimulation: symmetry plus successor preservation. -/
def ControlledBisimulation
    (Sys : ControlledSystem)
    (R : Sys.State → Sys.State → Prop) : Prop :=
  (∀ ⦃x y : Sys.State⦄, R x y → R y x) ∧
  ControlledCongruence Sys R

/-- The quotient transition induced by a congruent controlled system. -/
def quotientStep
    {Sys : ControlledSystem}
    (S : Setoid Sys.State)
    (hcong : ControlledCongruence Sys S.r)
    (a : Sys.Act) : Quotient S → Quotient S :=
  Quotient.lift
    (fun x => Quotient.mk' (Sys.step a x))
    (by
      intro x y hxy
      exact Quotient.sound (hcong hxy a))

/-- One-step quotient commutation: project-after-step equals step-on-quotient. -/
theorem quotientStep_commutes
    {Sys : ControlledSystem}
    (S : Setoid Sys.State)
    (hcong : ControlledCongruence Sys S.r)
    (a : Sys.Act) (x : Sys.State) :
    quotientStep S hcong a (Quotient.mk' x) =
      Quotient.mk' (Sys.step a x) := by
  rfl

/-- The central T1 result.

A Setoid information equivalence preserved by every control action induces
well-defined quotient dynamics and an exact controlled bisimulation. The
commutation law is explicit because it is the algebraic bridge required by
the downstream AGD chain:

    π ∘ Tₐ = T̄ₐ ∘ π.
-/
theorem agd_controlled_bisimulation
    {Sys : ControlledSystem}
    (S : Setoid Sys.State)
    (hcong : ControlledCongruence Sys S.r) :
    ControlledBisimulation Sys S.r ∧
      (∀ (a : Sys.Act) (x : Sys.State),
        quotientStep S hcong a (Quotient.mk' x) =
          Quotient.mk' (Sys.step a x)) := by
  constructor
  · constructor
    · intro x y hxy
      exact S.symm hxy
    · exact hcong
  · intro a x
    exact quotientStep_commutes S hcong a x

/-- A state predicate is invariant under the information equivalence. -/
def RelationInvariant
    {α : Type u}
    (R : α → α → Prop)
    (P : α → Prop) : Prop :=
  ∀ ⦃x y : α⦄, R x y → (P x ↔ P y)

/-- One-step invariance under every control action. -/
def StepInvariant
    (Sys : ControlledSystem)
    (P : Sys.State → Prop) : Prop :=
  ∀ ⦃x : Sys.State⦄, P x → ∀ a : Sys.Act,
    P (Sys.step a x)

/-- Finite control traces preserve any predicate that is one-step invariant. -/
theorem finite_trace_invariant
    {Sys : ControlledSystem}
    (P : Sys.State → Prop)
    (hP : StepInvariant Sys P)
    {x0 : Sys.State}
    (hx0 : P x0) :
    ∀ actions : List Sys.Act,
      P (actions.foldl (fun x a => Sys.step a x) x0) := by
  intro actions
  induction actions generalizing x0 with
  | nil =>
      simpa using hx0
  | cons a as ih =>
      apply ih (x0 := Sys.step a x0)
      exact hP hx0 a

/-- A predicate on the quotient induced by an invariant state predicate. -/
def quotientPredicate
    {Sys : ControlledSystem}
    (S : Setoid Sys.State)
    (P : Sys.State → Prop) : Quotient S → Prop :=
  fun q => ∀ x : Sys.State, q = Quotient.mk' x → P x

/-- Relation invariance is the exact condition needed for a quotient predicate
not to depend on the chosen representative. -/
theorem quotientPredicate_wellDefined
    {Sys : ControlledSystem}
    (S : Setoid Sys.State)
    (P : Sys.State → Prop)
    (hP : RelationInvariant S.r P)
    {x y : Sys.State}
    (hxy : S.r x y) :
    P x ↔ P y := by
  exact hP hxy

/-- Operational corollary: an initially admissible state remains admissible
under any finite action trace whenever admissibility is step-invariant. -/
theorem admissible_trajectory_preservation
    {Sys : ControlledSystem}
    (Admissible : Sys.State → Prop)
    (hAdmissible : StepInvariant Sys Admissible)
    {x0 : Sys.State}
    (hx0 : Admissible x0) :
    ∀ actions : List Sys.Act,
      Admissible (actions.foldl (fun x a => Sys.step a x) x0) := by
  exact finite_trace_invariant Admissible hAdmissible hx0

end AGD
end Chronofold
