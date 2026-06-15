import Mathlib.CategoryTheory.Category.Basic
import Mathlib.Order.Basic

universe u

/-

ChronoFold
Category of Dynamical Systems
Minimal Compiling Scaffold

-/

structure DynSys where
H : Type u
O : H → H

/-
Morphisms preserve dynamics:
f ∘ O = O' ∘ f
-/

structure DynHom (X Y : DynSys) where
f : X.H → Y.H
commute :
∀ x,
f (X.O x) = Y.O (f x)

namespace DynSys

instance : Category DynSys where
Hom X Y := DynHom X Y

id X :=
{
f := id
commute := by
intro x
rfl
}

comp f g :=
{
f := g.f ∘ f.f
commute := by
intro x
simp [Function.comp, f.commute, g.commute]
}

end DynSys

/-
Cost objects
-/

structure CostPoset where
Carrier : Type u
le : Carrier → Carrier → Prop

/-
Placeholder functor target
-/

structure CostFunctor where
obj : DynSys → CostPoset

/-
Compression / Refinement interface
-/

structure CompressionRefinement where
Compress : DynSys → DynSys
Refine : DynSys → DynSys

/-
Future theorem target:
Compress ⊣ Refine
-/

#check DynSys
#check DynHom
#check CostFunctor
#check CompressionRefinement

