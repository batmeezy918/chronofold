import AGD.Core.Notation
import Mathlib

namespace AGD.Core

/-!
# AGD Core Registry

This file tracks the formal registration of definitions, axioms, and theorems.
-/

/-- Registry Entry for individual mathematical objects -/
structure RegistryEntry where
  id : String
  type : String
  status : String

/-- The canonical theorem registry -/
def TheoremRegistry : List RegistryEntry := [
  ⟨"T00", "Theorem", "verified"⟩
]

/-- The canonical implementation registry -/
def ImplementationRegistry : List RegistryEntry := [
  ⟨"Constitution", "Definition", "Julia::Constitution"⟩
]

end AGD.Core
