import Chronofold.CoqcZetaForcingBidirectional
import Chronofold.SIM2XR_Universal_Costless_Logic
import Chronofold.CoqcDerivedPair

/-!
# Fibre-constancy derived from operational consequences

`FiberConstant` is not an extra axiom. It is the SIM2XR statement that a
defect respects the constitutional projection, transported along the
already-proved inclusion `RInf ⊆ R0`.

This module derives that fact in general, then instantiates it on the
closed pair. It does not prove RH.
-/

namespace Chronofold.CoqcFiberConstancy

open Chronofold.CoqcZetaForcingBidirectional
open SIM2XR.UniversalCostless
open Chronofold.CoqcDerivedPair

set_option linter.unusedVariables false

universe u w

variable {H : Type u} {Y : Type w}

/-! ## Tower inclusion already guaranteed by the kernel -/

theorem Rn_imp_R0 (C : H → Y) (T : H → H) :
    ∀ n x y, Rn C T n x y → R0 C x y := by
  intro n
  induction n with
  | zero =>
      intro x y h
      exact h
  | succ n ih =>
      intro x y h
      exact ih x y h.1

theorem RInf_imp_R0 (C : H → Y) (T : H → H) {x y : H} :
    RInf C T x y → R0 C x y :=
  fun h => Rn_imp_R0 C T 0 x y (h 0)

/-! ## Operational origin of fibre-constancy

SIM2XR `Respects π f` is constancy of `f` on `ker π`.
`R0 C` *is* `ker C`. Therefore any defect that respects `C` is
fibre-constant on every refinement, including `RInf`.
-/

theorem respects_implies_fiber_R0
    (C : H → Y) (D : H → Int)
    (h : Respects C D) :
    FiberConstant D (R0 C) :=
  h

theorem respects_implies_fiber_RInf
    (C : H → Y) (T : H → H) (D : H → Int)
    (h : Respects C D) :
    FiberConstant D (RInf C T) := by
  intro x y hR
  exact h x y (RInf_imp_R0 C T hR)

theorem zero_respects (C : H → Y) :
    Respects C (fun _ : H => (0 : Int)) := by
  intro x y _
  rfl

theorem zero_fiber (C : H → Y) (T : H → H) :
    FiberConstant (fun _ : H => (0 : Int)) (RInf C T) :=
  respects_implies_fiber_RInf C T (fun _ => 0) (zero_respects C)

/-- Any defect that is identically zero is fibre-constant.
This is the defect the forcing contract itself produces. -/
theorem annihilated_defect_is_fiber_constant
    (C : H → Y) (T : H → H) (D : H → Int)
    (hZero : ∀ x, D x = 0) :
    FiberConstant D (RInf C T) := by
  intro x y _
  exact (hZero x).trans (hZero y).symm

/-! ## Compatibility: antisymmetry + respects ⇒ annihilation

Once `D` respects `C` and `C` is `S`-invariant, `x` and `Sx` share a
fibre, so antisymmetry collapses `D`. No extra certificate field. -/

theorem respects_antisym_forces_zero
    (C : H → Y) (S : H → H) (D : H → Int)
    (hC : ConstitutionInvariant C S)
    (hD : DefectAntisymmetric D S)
    (hR : Respects C D) :
    ∀ x, D x = 0 := by
  intro x
  have hSame : D x = D (S x) := hR x (S x) (hC x).symm
  exact int_eq_neg_self_zero (D x) (hSame.trans (hD x))

/-- Closed-system derivation of the forcing contract when the defect is
a constitutional observable (SIM2XR `Respects`). Equivariance is used
only to name the same collapse already proved for `RInf`. -/
theorem forcing_from_respects
    (C : H → Y) (T S : H → H) (D : H → Int)
    (hC : ConstitutionInvariant C S)
    (hT : Equivariant T S)
    (hS : IsInvolution S)
    (hD : DefectAntisymmetric D S)
    (hR : Respects C D) :
    ∀ x, D x = 0 :=
  coqc_forcing_contract C T S D hC hT hS hD
    (respects_implies_fiber_RInf C T D hR)

/-! ## Instantiation on the derived pair -/

theorem cell_height_respects :
    Respects C (fun x : Cell => (x.height : Int)) := by
  intro x y h
  exact congrArg (fun n : Nat => (n : Int)) h

theorem cell_height_fiber :
    FiberConstant (fun x : Cell => (x.height : Int)) (RInf C T) :=
  respects_implies_fiber_RInf C T (fun x => (x.height : Int)) cell_height_respects

theorem cell_zero_fiber :
    FiberConstant D0 (RInf C T) :=
  D0_fiber

theorem cell_signed_not_respects :
    ¬ Respects C D := by
  intro h
  have : D pos1 = D neg1 := h pos1 neg1 rfl
  simp [D, pos1, neg1] at this

/-- The operational calculus guarantees fibre-constancy exactly for
defects that respect `C`. The signed height defect does not. The
zero defect and the raw height observable do. -/
theorem fiber_constancy_derived :
    (∀ {H : Type} {Y : Type} (C : H → Y) (T : H → H) (D : H → Int),
      Respects C D → FiberConstant D (RInf C T)) ∧
    FiberConstant D0 (RInf C T) ∧
    FiberConstant (fun x : Cell => (x.height : Int)) (RInf C T) ∧
    ¬ Respects C D ∧
    ¬ FiberConstant D (RInf C T) ∧
    (Respects C D0) :=
  ⟨fun _ _ C T D h => respects_implies_fiber_RInf C T D h,
   cell_zero_fiber,
   cell_height_fiber,
   cell_signed_not_respects,
   signed_D_not_fiber_constant,
   zero_respects C⟩

end Chronofold.CoqcFiberConstancy
