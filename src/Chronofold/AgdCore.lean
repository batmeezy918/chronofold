/-!
# AGD Core — Minimal state and observables
-/

namespace Chronofold.AGD

universe u

structure State (α : Type u) where
  id : Nat
  payload : α
  deriving DecidableEq, Repr

abbrev Omega (α : Type u) := State α → Nat
abbrev Covariant (α : Type u) := State α → Nat
abbrev Operator (α : Type u) := State α → State α

def Admissible (α : Type u) (Ω : Omega α) (C : Covariant α)
    (T : Operator α) : Prop :=
  ∀ s, Ω (T s) = Ω s ∧ C (T s) = C s

end Chronofold.AGD
