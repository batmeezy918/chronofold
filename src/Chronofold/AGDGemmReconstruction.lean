import Chronofold.SIM2XR_Universal_Costless_Logic
import Chronofold.AGDGemmProjection

/-!
# AGD-GEMM Reconstruction

A section σ of π recovers a representative of each quotient class.
This does not recover discarded fibre coordinates unless they are
constant on the class. No sorry. No Mathlib. No extra axioms.
-/

namespace Chronofold.AGDGemmReconstruction

open SIM2XR.UniversalCostless
open Chronofold.AGDGemmProjection

universe u v w

/-- σ is a right inverse of π. -/
def Section {State : Type u} {Reduced : Type v}
    (π : State → Reduced) (σ : Reduced → State) : Prop :=
  ReconstructionCorrect π σ

theorem section_is_right_inverse {State : Type u} {Reduced : Type v}
    (π : State → Reduced) (σ : Reduced → State)
    (h : Section π σ) :
    π ∘ σ = id :=
  reconstruction_is_section π σ h

theorem recovered_class {State : Type u} {Reduced : Type v}
    (π : State → Reduced) (σ : Reduced → State)
    (h : Section π σ) :
    ∀ x, Equivalent π x (σ (π x)) :=
  reconstruction_modulo_equivalence π σ h

/-- Quotient operator recovered from a section is unique when descent holds. -/
theorem reconstructed_operator {State : Type u} {Reduced : Type v}
    (π : State → Reduced) (σ : Reduced → State)
    (T : State → State) (Tbar : Reduced → Reduced)
    (hσ : Section π σ)
    (hI : Intertwines T Tbar π) :
    π ∘ T ∘ σ = Tbar :=
  conjugate_of_descent π σ hσ hI

theorem reconstructed_iterate {State : Type u} {Reduced : Type v}
    (π : State → Reduced) (σ : Reduced → State)
    (T : State → State) (Tbar : Reduced → Reduced)
    (hσ : Section π σ)
    (hI : Intertwines T Tbar π) :
    ∀ n q, π (iterate T n (σ q)) = iterate Tbar n q := by
  intro n q
  calc
    π (iterate T n (σ q))
        = iterate Tbar n (π (σ q)) := projection_iterate T Tbar π hI n (σ q)
    _   = iterate Tbar n q := by rw [hσ q]

theorem reconstruction_closure {State : Type u} {Reduced : Type v}
    (π : State → Reduced) (σ : Reduced → State)
    (T : State → State) (Tbar : Reduced → Reduced)
    (hσ : Section π σ)
    (hI : Intertwines T Tbar π) :
    (π ∘ σ = id) ∧
    (π ∘ T ∘ σ = Tbar) ∧
    (∀ n q, π (iterate T n (σ q)) = iterate Tbar n q) :=
  ⟨section_is_right_inverse π σ hσ,
   reconstructed_operator π σ T Tbar hσ hI,
   reconstructed_iterate π σ T Tbar hσ hI⟩

end Chronofold.AGDGemmReconstruction
