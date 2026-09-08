namespace Chronofold.CoqcZetaForcingBidirectional

universe u v w

/-!
# COQC zeta forcing / bidirectional collapse

Strictly internal kernel. No Hilbert space, inner product, self-adjointness,
external spectral operator, or complex analysis is assumed.
Does not prove RH. Remaining obligations are explicit in `ZetaDynamicsCertificate`.
-/

variable {H : Type u} {Y : Type w}

def IsInvolution (S : H → H) : Prop := ∀ x, S (S x) = x

def Phi (T : H → H) (R : H → H → Prop) : H → H → Prop :=
  fun x y => R x y ∧ R (T x) (T y)

def R0 (C : H → Y) : H → H → Prop :=
  fun x y => C x = C y

def Rn (C : H → Y) (T : H → H) : Nat → H → H → Prop
  | 0 => R0 C
  | n + 1 => Phi T (Rn C T n)

def RInf (C : H → Y) (T : H → H) : H → H → Prop :=
  fun x y => ∀ n, Rn C T n x y

def PiEq (C : H → Y) (T : H → H) (x y : H) : Prop := RInf C T x y

def Equivariant (T S : H → H) : Prop := ∀ x, T (S x) = S (T x)

def ConstitutionInvariant (C : H → Y) (S : H → H) : Prop :=
  ∀ x, C (S x) = C x

def DefectAntisymmetric (D : H → Int) (S : H → H) : Prop :=
  ∀ x, D (S x) = -D x

def FiberConstant (D : H → Int) (R : H → H → Prop) : Prop :=
  ∀ x y, R x y → D x = D y

theorem Rn_refl (C : H → Y) (T : H → H) : ∀ n x, Rn C T n x x
  | 0, x => rfl
  | n + 1, x => ⟨Rn_refl C T n x, Rn_refl C T n (T x)⟩

theorem RInf_refl (C : H → Y) (T : H → H) (x : H) : RInf C T x x := by
  intro n
  exact Rn_refl C T n x

theorem reflection_mem_Rn
    (C : H → Y) (T S : H → H)
    (hC : ConstitutionInvariant C S)
    (hT : Equivariant T S)
    (_hS : IsInvolution S) :
    ∀ n x, Rn C T n x (S x) := by
  intro n
  induction n with
  | zero =>
      intro x
      exact hC x
  | succ n ih =>
      intro x
      constructor
      · exact ih x
      · have hEq : T (S x) = S (T x) := hT x
        rw [hEq]
        exact ih (T x)

theorem reflection_mem_RInf
    (C : H → Y) (T S : H → H)
    (hC : ConstitutionInvariant C S)
    (hT : Equivariant T S)
    (hS : IsInvolution S) :
    ∀ x, PiEq C T x (S x) := by
  intro x n
  exact reflection_mem_Rn C T S hC hT hS n x

theorem reflection_projection_identity
    (C : H → Y) (T S : H → H)
    (hC : ConstitutionInvariant C S)
    (hT : Equivariant T S)
    (hS : IsInvolution S) :
    ∀ x, PiEq C T x (S x) :=
  reflection_mem_RInf C T S hC hT hS

theorem int_eq_neg_self_zero (a : Int) (h : a = -a) : a = 0 := by
  have h2 : a + a = 0 := by
    calc
      a + a = a + (-a) := by rw [h]
      _     = 0 := Int.add_neg_cancel a
  have : (2 : Int) * a = 0 := by
    simpa [Int.two_mul] using h2
  exact Int.eq_of_mul_eq_zero this (by decide : (2 : Int) ≠ 0)

theorem reflection_collapse_forces_defect_zero
    (D : H → Int) (C : H → Y) (T S : H → H)
    (hD : DefectAntisymmetric D S)
    (hFactor : FiberConstant D (RInf C T))
    (hCollapse : ∀ x, PiEq C T x (S x)) :
    ∀ x, D x = 0 := by
  intro x
  have hSame : D x = D (S x) := hFactor x (S x) (hCollapse x)
  have hAnti : D (S x) = -D x := hD x
  exact int_eq_neg_self_zero (D x) (hSame.trans hAnti)

theorem defect_zero_forces_reflection_projection
    (S : H → H) (D : H → Int)
    (hFixed : ∀ x, D x = 0 → S x = x)
    (C : H → Y) (T : H → H)
    (hZero : ∀ x, D x = 0) :
    ∀ x, PiEq C T x (S x) := by
  intro x
  have hx : S x = x := hFixed x (hZero x)
  rw [hx]
  exact RInf_refl C T x

theorem rh_iff_reflection_collapse
    (S : H → H) (D : H → Int) (C : H → Y) (T : H → H)
    (hD : DefectAntisymmetric D S)
    (hFactor : FiberConstant D (RInf C T))
    (hFixed : ∀ x, D x = 0 → S x = x) :
    (∀ x, D x = 0) ↔ (∀ x, PiEq C T x (S x)) := by
  constructor
  · intro hZero
    exact defect_zero_forces_reflection_projection S D hFixed C T hZero
  · intro hCollapse
    exact reflection_collapse_forces_defect_zero D C T S hD hFactor hCollapse

theorem equivariant_constitutional_forcing
    (C : H → Y) (T S : H → H)
    (hC : ConstitutionInvariant C S)
    (hT : Equivariant T S)
    (hS : IsInvolution S) :
    ∀ x, PiEq C T x (S x) :=
  reflection_mem_RInf C T S hC hT hS

theorem coqc_forcing_contract
    (C : H → Y) (T S : H → H) (D : H → Int)
    (hC : ConstitutionInvariant C S)
    (hT : Equivariant T S)
    (hS : IsInvolution S)
    (hD : DefectAntisymmetric D S)
    (hFactor : FiberConstant D (RInf C T)) :
    ∀ x, D x = 0 :=
  reflection_collapse_forces_defect_zero D C T S hD hFactor
    (reflection_mem_RInf C T S hC hT hS)

structure ZetaDynamicsCertificate where
  carrier : Type u
  T : carrier → carrier
  S : carrier → carrier
  C : carrier → Y
  defect : carrier → Int
  reflection_involution : IsInvolution S
  constitution_invariant : ConstitutionInvariant C S
  equivariant : Equivariant T S
  defect_antisymmetric : DefectAntisymmetric defect S
  defect_factor : FiberConstant defect (RInf C T)

theorem certificate_forces_zero
    (Z : ZetaDynamicsCertificate (Y := Y)) :
    ∀ x, Z.defect x = 0 :=
  coqc_forcing_contract Z.C Z.T Z.S Z.defect
    Z.constitution_invariant Z.equivariant Z.reflection_involution
    Z.defect_antisymmetric Z.defect_factor

end Chronofold.CoqcZetaForcingBidirectional
