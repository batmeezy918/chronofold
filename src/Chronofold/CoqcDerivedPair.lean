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

/-- Newest forcing theorem applied to the derived pair. -/
theorem signed_reflection_class :
    ∀ x, PiEq C T x (S x) :=
  reflection_mem_RInf C T S C_invariant T_equivariant S_involution

/-- SIM2XR operational effect: the derived `T` descends through `C`
to successor. One-step descent ⇔ recursive iterates. -/
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

/-- Fibre-constancy of the *signed* defect fails on the derived pair.
This is the explicit remaining obligation, not a hidden axiom. -/
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

/-- Zero-defect certificate inhabited entirely by derived objects. -/
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

/-- Packaged operational inheritance: the closed system produces a pair
`(T, S)` that satisfies the three structural hypotheses of the forcing
contract, yields reflection identification, descends in the SIM2XR sense,
and inhabits a zero-defect certificate. Signed defect remains non-factorizing. -/
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

end Chronofold.CoqcDerivedPair
