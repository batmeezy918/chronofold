import Mathlib

namespace AGD.Core

/-!
# AGD Core Definitions

This file contains the canonical mathematical definitions for the AGD framework.
Each definition corresponds to a fundamental primitive of the system.
-/

universe u v

/--
Mathematical Meaning: The fundamental set of rules governing the system.
Forward: Prop → Constitution
Reverse: Constitution → Prop
-/
def Constitution := Prop

/--
Mathematical Meaning: The collection of all possible states.
Forward: Type → StateSpace
Reverse: StateSpace → Type
-/
def StateSpace (H : Type u) := H

/--
Mathematical Meaning: A transformation mapping one state to another.
Forward: (H → H) → Operator H
Reverse: Operator H → (H → H)
-/
def Operator (H : Type u) := H → H

/--
Mathematical Meaning: Data supporting the validity of a receipt or state.
Forward: Prop → Evidence
Reverse: Evidence → Prop
-/
def Evidence := Prop

/--
Mathematical Meaning: A relation that partitions the state space.
Forward: (H → H → Prop) → EquivalenceRelation H
Reverse: EquivalenceRelation H → (H → H → Prop)
-/
def EquivalenceRelation (H : Type u) := H → H → Prop

/--
Mathematical Meaning: A property that remains unchanged under specific transformations.
Forward: (H → Prop) → Invariant H
Reverse: Invariant H → (H → Prop)
-/
def Invariant (H : Type u) := H → Prop

end AGD.Core
