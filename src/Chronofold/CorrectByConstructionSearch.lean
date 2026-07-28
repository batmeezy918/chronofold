import Mathlib

set_option linter.unusedSectionVars false

/-!
# Correct-by-Construction Search

This module formalizes the core AGD theorem "Correct-by-Construction Search".
It constructs the development from first principles, ensuring sound execution,
finite termination, and correct reconstruction of states.

## Outline
1. State Space `S` and equivalence relation `R`.
2. Quotient Space `Q` using Lean's Quotient machinery.
3. Invariant projection `Ω : S → Q` and proof of `x ~ y ↔ Ω x = Ω y`.
4. Admissible Transition `T : S → S` and its induced counterpart `T_bar : Q → Q`.
5. Section `σ : Q → S` and proof of `π ∘ σ = id`.
6. Ranking function `D : Q → Nat` and terminal predicate `terminal : Q → Prop`.
7. Termination proof of the step transition relation.
8. Master certificate `CorrectByConstructionSearch`.
-/

namespace Chronofold.CorrectByConstruction

section System

-- 1. State space S with its equivalence relation
variable (S : Type) [Setoid S]

-- 2. Quotient space Q constructed using Lean's Quotient machinery
def Q : Type := Quotient (by assumption)

-- 3. Invariant Ω : S → Q
def Ω (x : S) : Q S := Quotient.mk' x

-- 4. Equivalence relation notation and theorem: x ~ y ↔ Ω x = Ω y
local infix:50 " ~ " => Setoid.r

/-- Lemma establishing that the Setoid equivalence is exactly equality under the invariant projection. -/
theorem equiv_iff_invariant_eq (x y : S) : (x ~ y) ↔ Ω S x = Ω S y := by
  constructor
  · intro h
    dsimp [Ω]
    exact Quotient.sound h
  · intro h
    dsimp [Ω] at h
    exact Quotient.exact h

-- 5. Define an admissible transition T : S → S
variable (T : S → S)

/-- Theorem proving quotient compatibility: preserving Setoid equivalence induces equality under the invariant map. -/
theorem quotient_compatibility (h_T_compat : ∀ x y : S, x ~ y → T x ~ T y) (x y : S) (h : Ω S x = Ω S y) :
    Ω S (T x) = Ω S (T y) := by
  have h_equiv : x ~ y := (equiv_iff_invariant_eq S x y).mpr h
  have h_T_equiv : T x ~ T y := h_T_compat x y h_equiv
  exact (equiv_iff_invariant_eq S (T x) (T y)).mp h_T_equiv

-- 7. Define T_bar : Q S → Q S induced by compatibility
/-- The induced transition on the quotient space Q S. -/
def T_bar (h_T_compat : ∀ x y : S, x ~ y → T x ~ T y) : Q S → Q S :=
  Quotient.map T h_T_compat

-- 8. Define a section σ : Q S → S
/-- A section from the quotient space Q S back to the state space S. -/
noncomputable def σ (q : Q S) : S := Quotient.out q

/-- Theorem proving that Ω ∘ σ = id (correct quotient projection back and forth). -/
theorem pi_comp_sigma : (Ω S) ∘ (σ S) = id := by
  ext q
  dsimp [Ω, σ]
  exact Quotient.out_eq q

-- 9. Define a ranking function D : Q S → Nat
variable (D : Q S → Nat)

-- 10. Assume terminal states and rank decrease for non-terminal states
variable (terminal : Q S → Prop)
variable (h_T_compat : ∀ x y : S, x ~ y → T x ~ T y)
variable (h_decr : ∀ q : Q S, ¬ terminal q → D (T_bar S T h_T_compat q) < D q)

-- 11. Assume Finite Q S
variable [h_fin : Finite (Q S)]

-- 12. Define step and prove that every admissible execution terminates (using well-foundedness)
/-- A single step of the admissible transition on the quotient space.
    A step occurs from q to q' if q is not terminal and q' = T_bar q. -/
def step (terminal : Q S → Prop) (T_bar : Q S → Q S) (q' q : Q S) : Prop :=
  ¬ terminal q ∧ q' = T_bar q

/-- Lemma showing that the step relation is a subrelation of the inverse image of `<` under the ranking function. -/
lemma step_subrelation (D : Q S → Nat)
    (h_decr : ∀ q : Q S, ¬ terminal q → D (T_bar S T h_T_compat q) < D q) :
    Subrelation (step S terminal (T_bar S T h_T_compat)) (InvImage (· < ·) D) := by
  intro q' q h
  rcases h with ⟨h_not_term, rfl⟩
  dsimp [InvImage, step]
  exact h_decr q h_not_term

/-- Theorem proving that the step transition relation is well-founded, which guarantees finite termination. -/
theorem step_well_founded (D : Q S → Nat)
    (h_decr : ∀ q : Q S, ¬ terminal q → D (T_bar S T h_T_compat q) < D q) :
    WellFounded (step S terminal (T_bar S T h_T_compat)) := by
  have wf_inv : WellFounded (InvImage (· < ·) D) := InvImage.wf D Nat.lt_wfRel.wf
  exact Subrelation.wf (step_subrelation S T terminal h_T_compat D h_decr) wf_inv

-- 13. Prove that terminal quotients reconstruct to a valid concrete state through σ
/-- Predicate defining when a concrete state represents a given quotient state. -/
def ValidConcrete (q : Q S) (s : S) : Prop :=
  Ω S s = q

/-- Theorem proving that any terminal quotient state reconstructs to a valid concrete state. -/
theorem terminal_reconstructs_valid (q : Q S) (_h : terminal q) :
    ValidConcrete S q (σ S q) := by
  dsimp [ValidConcrete, σ]
  exact Quotient.out_eq q

-- 16. Separate Definitions, Lemmas, and Main Theorem under a Master Certificate
/-- The master Correct-by-Construction Search structure bundling the properties. -/
structure CorrectByConstructionSearch where
  /-- Sound execution: the lifted transition is well-defined and compatible. -/
  sound_execution : ∀ (x y : S), Ω S x = Ω S y → Ω S (T x) = Ω S (T y)

  /-- Finite termination: the step transition relation on the quotient is well-founded. -/
  finite_termination : WellFounded (step S terminal (T_bar S T h_T_compat))

  /-- Correct reconstruction: any terminal state reconstructs to a valid concrete state. -/
  correct_reconstruction : ∀ (q : Q S), terminal q → ValidConcrete S q (σ S q)

/-- The main Correct-by-Construction Search theorem, establishing correctness, termination, and reconstruction. -/
theorem correctByConstructionSearch (D : Q S → Nat)
    (h_decr : ∀ q : Q S, ¬ terminal q → D (T_bar S T h_T_compat q) < D q) :
    CorrectByConstructionSearch S T terminal h_T_compat := {
  sound_execution := quotient_compatibility S T h_T_compat
  finite_termination := step_well_founded S T terminal h_T_compat D h_decr
  correct_reconstruction := terminal_reconstructs_valid S terminal
}

end System

end Chronofold.CorrectByConstruction
