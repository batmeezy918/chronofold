import Mathlib.Data.Real.Basic

/-!
# AGD Core — Minimal state and observables

Concrete carrier for the commercial Q* kernel:
states are finite-dimensional records identified by a Nat id,
with two decidable observables Ω and C (the constitutional pair).
-/

namespace Chronofold.AGD

universe u

/-- Operational state. Payload is abstract. -/
structure State (α : Type u) where
  id : Nat
  payload : α
  deriving DecidableEq, Repr

/-- Invariant observable (must be decidable for runtime). -/
abbrev Omega (α : Type u) := State α → Nat

/-- Covariant / constitutional law. -/
abbrev Covariant (α : Type u) := State α → Nat

/-- State transformer. -/
abbrev Operator (α : Type u) := State α → State α

/-- Admissible: preserves both observables. -/
def Admissible (α : Type u) (Ω : Omega α) (C : Covariant α)
    (T : Operator α) : Prop :=
  ∀ s, Ω (T s) = Ω s ∧ C (T s) = C s

end Chronofold.AGD
