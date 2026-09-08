import Chronofold.CoqcZetaForcingBidirectional
import Chronofold.SIM2XR_Universal_Costless_Logic
import Chronofold.CoqcDerivedPair

/-!
# Fibre-constancy derived from operational consequences

`FiberConstant` is the SIM2XR statement that a defect respects the
constitutional projection, transported along `RInf ⊆ R0`.
No `sorry`. No extra axioms. Does not prove RH.
-/

namespace Chronofold.CoqcFiberConstancy

open Chronofold.CoqcZetaForcingBidirectional
open SIM2XR.UniversalCostless

set_option linter.unusedVariables false

universe u w

/-! ## Tower inclusion -/

theorem Rn_imp_R0 {H : Type u} {Y : Type w}
    (obs : H → Y) (step : H → H) :
    ∀ n x y, Rn obs step n x y → R0 obs x y := by
  intro n
  induction n with
  | zero =>
      intro x y h
      exact h
  | succ n ih =>
      intro x y h
      exact ih x y h.1

theorem RInf_imp_R0 {H : Type u} {Y : Type w}
    (obs : H → Y) (step : H → H) {x y : H} :
    RInf obs step x y → R0 obs x y :=
  fun h => Rn_imp_R0 obs step 0 x y (h 0)

/-! ## Operational origin of fibre-constancy -/

theorem respects_implies_fiber_R0 {H : Type u} {Y : Type w}
    (obs : H → Y) (defc : H → Int)
    (h : Respects obs defc) :
    FiberConstant defc (R0 obs) :=
  h

theorem respects_implies_fiber_RInf {H : Type u} {Y : Type w}
    (obs : H → Y) (step : H → H) (defc : H → Int)
    (h : Respects obs defc) :
    FiberConstant defc (RInf obs step) := by
  intro x y hR
  exact h x y (RInf_imp_R0 obs step hR)

theorem zero_respects {H : Type u} {Y : Type w} (obs : H → Y) :
    Respects obs (fun _ : H => (0 : Int)) := by
  intro x y _
  rfl

theorem zero_fiber {H : Type u} {Y : Type w}
    (obs : H → Y) (step : H → H) :
    FiberConstant (fun _ : H => (0 : Int)) (RInf obs step) :=
  respects_implies_fiber_RInf obs step (fun _ => (0 : Int)) (zero_respects obs)

theorem annihilated_defect_is_fiber_constant {H : Type u} {Y : Type w}
    (obs : H → Y) (step : H → H) (defc : H → Int)
    (hZero : ∀ x, defc x = 0) :
    FiberConstant defc (RInf obs step) := by
  intro x y _
  exact (hZero x).trans (hZero y).symm

/-! ## Compatibility: respects + antisymmetry ⇒ annihilation -/

theorem respects_antisym_forces_zero {H : Type u} {Y : Type w}
    (obs : H → Y) (refl : H → H) (defc : H → Int)
    (hC : ConstitutionInvariant obs refl)
    (hD : DefectAntisymmetric defc refl)
    (hR : Respects obs defc) :
    ∀ x, defc x = 0 := by
  intro x
  have hSame : defc x = defc (refl x) := hR x (refl x) (hC x).symm
  exact int_eq_neg_self_zero (defc x) (hSame.trans (hD x))

theorem forcing_from_respects {H : Type u} {Y : Type w}
    (obs : H → Y) (step refl : H → H) (defc : H → Int)
    (hC : ConstitutionInvariant obs refl)
    (hT : Equivariant step refl)
    (hS : IsInvolution refl)
    (hD : DefectAntisymmetric defc refl)
    (hR : Respects obs defc) :
    ∀ x, defc x = 0 :=
  coqc_forcing_contract obs step refl defc hC hT hS hD
    (respects_implies_fiber_RInf obs step defc hR)

/-! ## Instantiation on the derived Cell pair -/

open Chronofold.CoqcDerivedPair

def heightInt (x : Cell) : Int := (x.height : Int)

theorem cell_height_respects : Respects C heightInt := by
  intro x y h
  exact congrArg (fun n : Nat => (n : Int)) h

theorem cell_height_fiber :
    FiberConstant heightInt (RInf C T) :=
  respects_implies_fiber_RInf C T heightInt cell_height_respects

theorem cell_zero_fiber :
    FiberConstant D0 (RInf C T) :=
  D0_fiber

theorem cell_D0_respects : Respects C D0 :=
  zero_respects C

theorem cell_signed_not_respects : ¬ Respects C D := by
  intro h
  have hx : D pos1 = D neg1 := h pos1 neg1 rfl
  simp [D, pos1, neg1] at hx

theorem cell_forcing_from_zero_respects :
    ∀ x, D0 x = 0 :=
  forcing_from_respects C T S D0
    C_invariant T_equivariant S_involution D0_antisymmetric cell_D0_respects

theorem cell_respects_antisym_zero :
    ∀ x, D0 x = 0 :=
  respects_antisym_forces_zero C S D0 C_invariant D0_antisymmetric cell_D0_respects

/-- Maximal operational package for fibre-constancy.
General transport, Cell witnesses, signed obstruction, derived forcing. -/
theorem fiber_constancy_maximal_operational_closure :
    FiberConstant heightInt (RInf C T) ∧
    FiberConstant D0 (RInf C T) ∧
    Respects C heightInt ∧
    Respects C D0 ∧
    ¬ Respects C D ∧
    ¬ FiberConstant D (RInf C T) ∧
    (∀ x, D0 x = 0) ∧
    (FiberConstant D (RInf C T) ↔ ∀ x, C x = 0) :=
  ⟨cell_height_fiber,
   cell_zero_fiber,
   cell_height_respects,
   cell_D0_respects,
   cell_signed_not_respects,
   signed_D_not_fiber_constant,
   cell_forcing_from_zero_respects,
   fiber_constant_iff_height_zero⟩

end Chronofold.CoqcFiberConstancy
