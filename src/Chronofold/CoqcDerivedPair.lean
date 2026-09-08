import Chronofold.CoqcZetaForcingBidirectional
import Chronofold.SIM2XR_Universal_Costless_Logic

/-!
# Derived pair from the closed system

The merged forcing kernel treats `(T, S)` as certificate inputs.
This module *constructs* the pair from objects already inside the
closed package and then applies the newest operational theorems.

Does not prove RH. Does not invent an analytic `T_Z` on non-trivial zeros.
It derives the only pairs the strict kernel can currently inhabit.
-/

namespace Chronofold.CoqcDerivedPair

open Chronofold.CoqcZetaForcingBidirectional
open SIM2XR.UniversalCostless

set_option linter.unusedVariables false

/-! ## Identity pair (T0 / SIM2XR inheritance)

`S = id` is the unique involution that exists on every carrier without
adding structure. Equivariance and constitutional invariance are free.
Antisymmetry of `D` under `id` is `D = -D`, hence `D ≡ 0` by the
already-verified `int_eq_neg_self_zero`.
-/

theorem id_involution {H : Type} : IsInvolution (id : H → H) := by
  intro x
  rfl

theorem id_equivariant {H : Type} (T : H → H) : Equivariant T (id : H → H) := by
  intro x
  rfl

theorem id_constitution {H Y : Type} (C : H → Y) :
    ConstitutionInvariant C (id : H → H) := by
  intro x
  rfl

/-- Operational effect of the newest theorems: identity reflection plus
antisymmetry annihilates defect with no fibre hypothesis. -/
theorem id_antisym_forces_zero {H : Type} (D : H → Int)
    (h : DefectAntisymmetric D (id : H → H)) :
    ∀ x, D x = 0 := by
  intro x
  exact int_eq_neg_self_zero (D x) (h x)

theorem id_reflection_class {H Y : Type} (C : H → Y) (T : H → H) :
    ∀ x, PiEq C T x ((id : H → H) x) :=
  reflection_mem_RInf C T id (id_constitution C) (id_equivariant T) id_involution

/-! ## Signed cell pair

Carrier constructed internally: height (constitutional observable) and
a boolean side (reflection coordinate). No analysis, no zeta zeros.
-/

structure Cell where
  height : Nat
  side : Bool
  deriving DecidableEq, Repr

def S : Cell → Cell :=
  fun x => { x with side := !x.side }

def T : Cell → Cell :=
  fun x => { x with height := x.height + 1 }

def C : Cell → Nat :=
  fun x => x.height

def D : Cell → Int :=
  fun x => if x.side then - (x.height : Int) else (x.height : Int)

theorem S_involution : IsInvolution S := by
  intro x
  cases x with
  | mk _ s =>
    cases s <;> rfl

theorem T_equivariant : Equivariant T S := by
  intro x
  cases x with
  | mk _ s =>
    cases s <;> rfl

theorem C_invariant : ConstitutionInvariant C S := by
  intro x
  rfl

theorem D_antisymmetric : DefectAntisymmetric D S := by
  intro x
  cases x with
  | mk h s =>
    cases s <;> simp [D, S]

theorem signed_reflection_class :
    ∀ x, PiEq C T x (S x) :=
  reflection_mem_RInf C T S C_invariant T_equivariant S_involution

theorem signed_descends : Descends C T Nat.succ := by
  intro x
  rfl

theorem signed_descends_recursive :
    ∀ n x, C (iterate T n x) = iterate Nat.succ n (C x) :=
  (descends_iff_recursive C T Nat.succ).mp signed_descends

theorem Rn_iff_height :
    ∀ n x y, Rn C T n x y ↔ C x = C y := by
  intro n
  induction n with
  | zero =>
      intro x y
      rfl
  | succ n ih =>
      intro x y
      constructor
      · intro h
        exact (ih x y).mp h.1
      · intro h
        refine ⟨(ih x y).mpr h, (ih (T x) (T y)).mpr ?_⟩
        calc
          C (T x) = x.height + 1 := rfl
          _       = y.height + 1 := by
            have : x.height = y.height := h
            exact congrArg Nat.succ this
          _       = C (T y) := rfl

theorem RInf_iff_height (x y : Cell) :
    RInf C T x y ↔ C x = C y := by
  constructor
  · intro h
    exact (Rn_iff_height 0 x y).mp (h 0)
  · intro h n
    exact (Rn_iff_height n x y).mpr h

def pos1 : Cell := { height := 1, side := false }
def neg1 : Cell := { height := 1, side := true }

theorem signed_D_not_fiber_constant :
    ¬ FiberConstant D (RInf C T) := by
  intro h
  have hr : RInf C T pos1 neg1 :=
    (RInf_iff_height pos1 neg1).mpr rfl
  have hD : D pos1 = D neg1 := h pos1 neg1 hr
  simp [D, pos1, neg1] at hD

def D0 (_ : Cell) : Int := 0

theorem D0_antisymmetric : DefectAntisymmetric D0 S := by
  intro x
  rfl

theorem D0_fiber : FiberConstant D0 (RInf C T) := by
  intro x y _
  rfl

def zeroDefectCertificate : ZetaDynamicsCertificate (Y := Nat) where
  carrier := Cell
  T := T
  S := S
  C := C
  defect := D0
  reflection_involution := S_involution
  constitution_invariant := C_invariant
  equivariant := T_equivariant
  defect_antisymmetric := D0_antisymmetric
  defect_factor := D0_fiber

theorem zero_certificate_annihilates :
    ∀ x, zeroDefectCertificate.defect x = 0 :=
  certificate_forces_zero zeroDefectCertificate

theorem zero_certificate_reflection :
    ∀ x, PiEq zeroDefectCertificate.C zeroDefectCertificate.T x
      (zeroDefectCertificate.S x) :=
  certificate_forces_reflection_class zeroDefectCertificate

theorem derived_pair_closed_system :
    IsInvolution S ∧
    Equivariant T S ∧
    ConstitutionInvariant C S ∧
    DefectAntisymmetric D S ∧
    (∀ x, PiEq C T x (S x)) ∧
    Descends C T Nat.succ ∧
    ¬ FiberConstant D (RInf C T) ∧
    (∀ x, zeroDefectCertificate.defect x = 0) :=
  ⟨S_involution,
   T_equivariant,
   C_invariant,
   D_antisymmetric,
   signed_reflection_class,
   signed_descends,
   signed_D_not_fiber_constant,
   zero_certificate_annihilates⟩

/-! ## Remaining obligation, derived

Fibre-constancy of the signed defect is not an extra axiom.
On this pair it is equivalent to the zero-height slice.
The stepping map `T` does not preserve that slice.
The only endomorphism the closed system can put on the slice is `id`.
-/

def opposite (x : Cell) : Cell := { height := x.height, side := !x.side }

theorem opposite_same_height (x : Cell) : C x = C (opposite x) := rfl

theorem opposite_RInf (x : Cell) : RInf C T x (opposite x) :=
  (RInf_iff_height x (opposite x)).mpr (opposite_same_height x)

theorem D_opposite (x : Cell) : D (opposite x) = - D x := by
  cases x with
  | mk h s =>
    cases s <;> simp [D, opposite]

theorem nat_cast_eq_neg_zero (n : Nat) (h : (n : Int) = - (n : Int)) : n = 0 := by
  have : (n : Int) = 0 := int_eq_neg_self_zero (n : Int) h
  exact Int.ofNat_eq_zero.mp this

theorem D_eq_zero_of_height_zero (x : Cell) (h : C x = 0) : D x = 0 := by
  cases x with
  | mk height side =>
    simp [C] at h
    cases side <;> simp [D, h]

theorem height_zero_of_D_eq_neg (x : Cell) (h : D x = D (opposite x)) : C x = 0 := by
  have hAnti : D (opposite x) = - D x := D_opposite x
  have hZero : D x = 0 := int_eq_neg_self_zero (D x) (h.trans hAnti)
  cases x with
  | mk height side =>
    cases side <;> simp [D, C] at hZero ⊢
    · exact nat_cast_eq_neg_zero height (by
        have : (height : Int) = 0 := hZero
        simp [this])
    · have : - (height : Int) = 0 := hZero
      have hN : (height : Int) = 0 := by omega
      exact Int.ofNat_eq_zero.mp hN

/-- Derivation of the remaining obligation on the constructed pair. -/
theorem fiber_constant_iff_height_zero :
    FiberConstant D (RInf C T) ↔ ∀ x, C x = 0 := by
  constructor
  · intro hFactor x
    have hSame : D x = D (opposite x) := hFactor x (opposite x) (opposite_RInf x)
    exact height_zero_of_D_eq_neg x hSame
  · intro hZero x y hR
    have hx : D x = 0 := D_eq_zero_of_height_zero x (hZero x)
    have hy : D y = 0 := D_eq_zero_of_height_zero y (hZero y)
    exact hx.trans hy.symm

theorem T_escapes_zero_slice (x : Cell) (hx : C x = 0) : C (T x) ≠ 0 := by
  simp [C, T] at hx ⊢
  simp [C, T, hx]

theorem stepping_T_not_endomorphism_of_zero_slice :
    ¬ ∀ x, C x = 0 → C (T x) = 0 := by
  intro h
  have hx : C { height := 0, side := false } = 0 := rfl
  exact T_escapes_zero_slice { height := 0, side := false } hx (h _ hx)

/-! Zero-height slice: the only carrier on which signed `D` factors.
Stepping `T` is not an endomorphism. Identity is. -/

structure ZeroCell where
  side : Bool
  deriving DecidableEq, Repr

def S0 : ZeroCell → ZeroCell :=
  fun z => { side := !z.side }

def T0 : ZeroCell → ZeroCell := id

def C0 : ZeroCell → Nat := fun _ => 0

def D0slice : ZeroCell → Int := fun _ => 0

theorem S0_involution : IsInvolution S0 := by
  intro z
  cases z with
  | mk s =>
    cases s <;> rfl

theorem T0_equivariant : Equivariant T0 S0 := by
  intro z
  rfl

theorem C0_invariant : ConstitutionInvariant C0 S0 := by
  intro z
  rfl

theorem D0slice_antisymmetric : DefectAntisymmetric D0slice S0 := by
  intro z
  rfl

theorem D0slice_fiber : FiberConstant D0slice (RInf C0 T0) := by
  intro x y _
  rfl

def sliceCertificate : ZetaDynamicsCertificate (Y := Nat) where
  carrier := ZeroCell
  T := T0
  S := S0
  C := C0
  defect := D0slice
  reflection_involution := S0_involution
  constitution_invariant := C0_invariant
  equivariant := T0_equivariant
  defect_antisymmetric := D0slice_antisymmetric
  defect_factor := D0slice_fiber

theorem slice_certificate_annihilates :
    ∀ z, sliceCertificate.defect z = 0 :=
  certificate_forces_zero sliceCertificate

theorem slice_uses_forcing_contract :
    ∀ z, D0slice z = 0 :=
  coqc_forcing_contract C0 T0 S0 D0slice
    C0_invariant T0_equivariant S0_involution
    D0slice_antisymmetric D0slice_fiber

/-- Remaining obligation, conducted:
1. fibre-constancy of signed `D` ⇔ every cell has height 0;
2. stepping `T` leaves that slice;
3. identity on the slice inhabits the full forcing contract.
No analytic zero-to-zero map is produced. -/
theorem remaining_obligation_derived :
    (FiberConstant D (RInf C T) ↔ ∀ x, C x = 0) ∧
    (¬ ∀ x, C x = 0 → C (T x) = 0) ∧
    (∀ z, sliceCertificate.defect z = 0) ∧
    (∀ z, PiEq C0 T0 z (S0 z)) :=
  ⟨fiber_constant_iff_height_zero,
   stepping_T_not_endomorphism_of_zero_slice,
   slice_certificate_annihilates,
   reflection_mem_RInf C0 T0 S0 C0_invariant T0_equivariant S0_involution⟩

end Chronofold.CoqcDerivedPair
