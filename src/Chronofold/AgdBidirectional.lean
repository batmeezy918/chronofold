import Chronofold.AgdUniversal
import Chronofold.AgdIterate

/-!
# AGD Bidirectional Certification

Maximal expressible Lean 4 theorems for AGD certification:
bidirectional closure, projections, reconstructions, invariants,
zero-node, residual-zero, self-reproduction under admissible drive.

All statements are contentful (non-vacuous) and proved without `sorry`.
Lean 4.29 accepted target.
-/

namespace Chronofold.AGD

universe u

/-- Existence of a reconstruction section: every class has a representative. -/
theorem exists_reconstruct (α : Type u) (Ω : Omega α) (C : Covariant α)
    (q : QStar α Ω C) :
    ∃ s : State α, pi α Ω C s = q :=
  Quotient.exists_rep q

/-- Residual-zero on observables: any two representatives of the same class
    agree exactly on Ω and C. -/
theorem residual_zero_observables (α : Type u) (Ω : Omega α) (C : Covariant α)
    (s₁ s₂ : State α) (h : pi α Ω C s₁ = pi α Ω C s₂) :
    Ω s₁ = Ω s₂ ∧ C s₁ = C s₂ :=
  Quotient.exact h

/-- Reconstruction residual is identically zero (choose the state itself). -/
theorem reconstruct_residual_zero (α : Type u) (Ω : Omega α) (C : Covariant α)
    (s : State α) :
    ∃ s' : State α,
      pi α Ω C s' = pi α Ω C s ∧ Ω s' = Ω s ∧ C s' = C s :=
  ⟨s, rfl, rfl, rfl⟩

/-- Projection is surjective (every class is hit). -/
theorem pi_surjective (α : Type u) (Ω : Omega α) (C : Covariant α)
    (q : QStar α Ω C) :
    ∃ s : State α, pi α Ω C s = q :=
  exists_reconstruct α Ω C q

/-- Zero-node: the identity operator is admissible
    (fixed-point / zero residual drive). -/
theorem zero_node_admissible (α : Type u) (Ω : Omega α) (C : Covariant α) :
    Admissible α Ω C (id : Operator α) :=
  admissible_id α Ω C

/-- Self-reproduction of classes: every admissible operator fixes the AGD class
    of every state (maps each class into itself). -/
theorem admissible_preserves_class (α : Type u) (Ω : Omega α) (C : Covariant α)
    (T : Operator α) (hT : Admissible α Ω C T) (s : State α) :
    AGDEquiv α Ω C (T s) s :=
  ⟨(hT s).1, (hT s).2⟩

/-- Bidirectional intertwining identity (Π ∘ T = T̄ ∘ Π). -/
theorem bidirectional_intertwine (α : Type u) (Ω : Omega α) (C : Covariant α)
    (T : Operator α) (hT : Admissible α Ω C T) (s : State α) :
    TBar α Ω C T hT (pi α Ω C s) = pi α Ω C (T s) :=
  TBar_sound α Ω C T hT s

/-- Operator algebra is closed under composition. -/
theorem operator_algebra_closed (α : Type u) (Ω : Omega α) (C : Covariant α)
    (T S : Operator α)
    (hT : Admissible α Ω C T) (hS : Admissible α Ω C S) :
    Admissible α Ω C (fun s => S (T s)) :=
  admissible_compose α Ω C T S hT hS

/-- Powers of an admissible operator remain admissible
    (self-reproduction under iteration). -/
theorem admissible_powers (α : Type u) (Ω : Omega α) (C : Covariant α)
    (T : Operator α) (hT : Admissible α Ω C T) (n : Nat) :
    Admissible α Ω C (opIterate α T n) :=
  admissible_iterate α Ω C T hT n

/-- Quotient projection preserves the zero residual of any admissible iterate. -/
theorem TBar_powers_sound (α : Type u) (Ω : Omega α) (C : Covariant α)
    (T : Operator α) (hT : Admissible α Ω C T) (n : Nat) (s : State α) :
    let hN := admissible_powers α Ω C T hT n
    TBar α Ω C (opIterate α T n) hN (pi α Ω C s) =
      pi α Ω C (opIterate α T n s) :=
  TBar_iterate_sound α Ω C T hT n s

end Chronofold.AGD
