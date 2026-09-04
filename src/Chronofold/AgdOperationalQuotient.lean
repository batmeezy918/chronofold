/-!
# Constitutional operational quotient
Lean 4 core only. No Mathlib. No `sorry`.
-/

namespace Chronofold.AgdOperationalQuotient

variable {H Q U : Type}

structure System where
  R : H → Q
  O : H → H
  Obar : Q → Q
  V : H → H
  Vbar : Q → Q
  admissible : H → Prop
  admissibleQ : Q → Prop
  Vstar : H → U
  VbarStar : Q → U
  Theta : H → H

namespace System

variable (S : System (H := H) (Q := Q) (U := U))

def OperationalEq (x y : H) : Prop := S.R x = S.R y

def AdmissibilityFactors : Prop :=
  ∀ x, S.admissible x ↔ S.admissibleQ (S.R x)

def OperatorIntertwining : Prop :=
  ∀ x, S.R (S.O x) = S.Obar (S.R x)

def VolterraIntertwining : Prop :=
  ∀ x, S.R (S.V x) = S.Vbar (S.R x)

def ControlFactors : Prop :=
  ∀ x, S.Vstar x = S.VbarStar (S.R x)

def ThetaIdempotent : Prop :=
  ∀ x, S.Theta (S.Theta x) = S.Theta x

def ThetaQuotientCompatible : Prop :=
  ∀ x, S.R (S.Theta x) = S.R x

structure Closure : Prop where
  admissibility : S.AdmissibilityFactors
  operator : S.OperatorIntertwining
  volterra : S.VolterraIntertwining
  control : S.ControlFactors
  theta_idempotent : S.ThetaIdempotent
  theta_quotient : S.ThetaQuotientCompatible

theorem admissibility_sufficient
    (h : S.AdmissibilityFactors)
    {x y : H} (hxy : S.OperationalEq x y) :
    S.admissible x ↔ S.admissible y := by
  rw [h x, h y, hxy]

theorem operationalEq_refl (x : H) : S.OperationalEq x x := rfl

theorem operationalEq_symm {x y : H}
    (hxy : S.OperationalEq x y) :
    S.OperationalEq y x := hxy.symm

theorem operationalEq_trans {x y z : H}
    (hxy : S.OperationalEq x y)
    (hyz : S.OperationalEq y z) :
    S.OperationalEq x z := hxy.trans hyz

theorem operationalEq_preserved_by_operator
    (hO : S.OperatorIntertwining)
    {x y : H} (hxy : S.OperationalEq x y) :
    S.OperationalEq (S.O x) (S.O y) := by
  unfold OperationalEq at *
  rw [hO x, hO y, hxy]

theorem control_preserved
    (hV : S.ControlFactors)
    {x y : H} (hxy : S.OperationalEq x y) :
    S.Vstar x = S.Vstar y := by
  rw [hV x, hV y, hxy]

theorem theta_projected_fixed
    (hθ : S.ThetaIdempotent) (x : H) :
    S.Theta (S.Theta x) = S.Theta x :=
  hθ x

theorem quotient_of_full_chain (C : S.Closure) (x : H) :
    S.R (S.Theta (S.V (S.O x))) = S.Vbar (S.Obar (S.R x)) := by
  calc
    S.R (S.Theta (S.V (S.O x)))
        = S.R (S.V (S.O x)) := C.theta_quotient _
    _ = S.Vbar (S.R (S.O x)) := C.volterra _
    _ = S.Vbar (S.Obar (S.R x)) := by rw [C.operator x]

def opPow (O : α → α) : Nat → α → α :=
  fun n x =>
    match n with
    | 0 => x
    | n + 1 => O (opPow O n x)

theorem quotient_iterate_operator
    (hO : S.OperatorIntertwining) :
    ∀ (n : Nat) (x : H),
      S.R (opPow S.O n x) = opPow S.Obar n (S.R x) := by
  intro n
  induction n with
  | zero =>
    intro x
    rfl
  | succ n ih =>
    intro x
    simp only [opPow]
    rw [hO]
    exact congrArg S.Obar (ih x)

end System

structure CostModel where
  dense : Nat → Nat
  reduced : Nat → Nat → Nat

def faster (C : CostModel) (d r : Nat) : Prop :=
  C.reduced d r < C.dense d

theorem speedup_implies_faster (C : CostModel) {d r : Nat}
    (h : C.reduced d r < C.dense d) :
    faster C d r :=
  h

end Chronofold.AgdOperationalQuotient
