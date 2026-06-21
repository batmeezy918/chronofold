import Chronofold.AgdCore
import Mathlib.Algebra.Group.Basic

namespace AGD

@[ext]
structure AgdOperator where
  apply : AgdState → AgdState

structure OperatorCertificate where
  closed : Prop
  associative : Prop
  identity : Prop

/--
  Verify AGD operators form a closed system.
  We model the space of operators as a Monoid.
-/
instance : Monoid AgdOperator where
  mul o1 o2 := { apply := o1.apply ∘ o2.apply }
  one := { apply := id }
  mul_assoc o1 o2 o3 := by
    ext s
    rfl
  one_mul o := by
    ext s
    rfl
  mul_one o := by
    ext s
    rfl

theorem operator_closure (o1 o2 : AgdOperator) :
  (o1 * o2) ∈ (Set.univ : Set AgdOperator) := by
  simp

end AGD
