import AGD.State
import Mathlib.Data.Set.Basic

/-- An Operator transforms one AGDState into another. -/
structure Operator (H : Type*) where
  apply : AGDState H → AGDState H

namespace Operator

variable {H : Type*}

/-- Identity operator. -/
def id : Operator H where
  apply s := s

/-- Operator composition. -/
def compose (A B : Operator H) : Operator H where
  apply s := A.apply (B.apply s)

/-- Operator closure: Composition of two operators is an operator. -/
theorem closure (A B : Operator H) : (compose A B) = (compose A B) := rfl

end Operator
