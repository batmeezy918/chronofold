import Chronofold.AgdCore
import Chronofold.AgdOperators

/-!
# Tethered Operators

A minimal, fully constructive kernel for the fixed-operator/bounded-state
pattern developed in the research thread.

The results below are actual Lean theorems: no `sorry`, `admit`, or axioms
are used in this file.
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

/-- Every finite iterate of a tethered operator preserves Ω. -/
theorem TetheredOperator.iterate_preserve_omega
    {α : Type u} {Ω : Omega α} {C : Covariant α}
    (T : TetheredOperator α Ω C) :
    ∀ n s, Ω (Function.iterate T.step n s) = Ω s := by
  intro n
  induction n with
  | zero =>
      intro s
      simp
  | succ n ih =>
      intro s
      simpa [Function.iterate_succ_apply] using ih (T.step s)

end Chronofold.AGD
