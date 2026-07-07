import AGD.Core.Axioms
import Mathlib

namespace AGD.Core

/-!
# AGD Core Notation

This file defines custom notations for the AGD system.
-/

/-- Notation for operator application -/
notation:max op " ▹ " s => op s

/-- Notation for admissibility check -/
notation:max s " ⊧ " adm => adm s

/-- Notation for identity operator -/
notation:max "𝟙" => Identity

end AGD.Core
