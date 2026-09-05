import Chronofold.AgdCore
import Chronofold.AgdOperators
import Chronofold.AgdIterate

/-!
# Tethered Operators

A constructive kernel for the fixed-operator/bounded-state pattern.
Finite-iterate preservation reuses the repository's existing `opIterate`
and `admissible_iterate` definitions rather than introducing a second
iteration semantics.
-/

namespace Chronofold.AGD

universe u

/-- A tethered operator is an operator together with its admissibility proof. -/
structure TetheredOperator (α : Type u) (Ω : Omega α) (C : Covariant α) where
  op : Operator α
  admissible : Admissible α Ω C op

/-- One execution step of a tethered operator. -/
def TetheredOperator.step
    {α : Type u} {Ω : Omega α} {C : Covariant α}
    (T : TetheredOperator α Ω C) (s : State α) : State α :=
  T.op s

/-- A tethered step preserves the invariant observable Ω. -/
theorem TetheredOperator.preserve_omega
    {α : Type u} {Ω : Omega α} {C : Covariant α}
    (T : TetheredOperator α Ω C) (s : State α) :
    Ω (T.step s) = Ω s := by
  exact (T.admissible s).1

/-- A tethered step preserves the covariant observable C. -/
theorem TetheredOperator.preserve_covariant
    {α : Type u} {Ω : Omega α} {C : Covariant α}
    (T : TetheredOperator α Ω C) (s : State α) :
    C (T.step s) = C s := by
  exact (T.admissible s).2

/-- Every finite iterate of a tethered operator preserves both observables. -/
theorem TetheredOperator.iterate_preserves
    {α : Type u} {Ω : Omega α} {C : Covariant α}
    (T : TetheredOperator α Ω C) (n : Nat) :
    Admissible α Ω C (opIterate α T.op n) := by
  exact admissible_iterate α Ω C T.op T.admissible n

/-- Every finite iterate preserves the invariant observable Ω. -/
theorem TetheredOperator.iterate_preserve_omega
    {α : Type u} {Ω : Omega α} {C : Covariant α}
    (T : TetheredOperator α Ω C) (n : Nat) (s : State α) :
    Ω (opIterate α T.op n s) = Ω s := by
  exact (T.iterate_preserves n s).1

/-- Every finite iterate preserves the covariant observable C. -/
theorem TetheredOperator.iterate_preserve_covariant
    {α : Type u} {Ω : Omega α} {C : Covariant α}
    (T : TetheredOperator α Ω C) (n : Nat) (s : State α) :
    C (opIterate α T.op n s) = C s := by
  exact (T.iterate_preserves n s).2

end Chronofold.AGD
