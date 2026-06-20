import Mathlib.Analysis.Normed.Module.Basic
import Mathlib.Analysis.InnerProductSpace.Basic

/-!
# AGD Core Type System

Formalization of the state space H for ChronoFold AGD.
The state space is modeled as a normed space over ℝ.
-/

namespace Chronofold

-- Removing 'variable' to see if it's causing the issue in this version of Lean 4
-- using explicit parameters instead.

/-- An operator on the state space H. -/
def Operator (H : Type*) [NormedAddCommGroup H] [NormedSpace ℝ H] := H → H

/-- The distance between two states in H. -/
noncomputable def agd_dist {H : Type*} [NormedAddCommGroup H] [NormedSpace ℝ H] (ψ₁ ψ₂ : H) : ℝ := ‖ψ₁ - ψ₂‖

/-- A transformation lineage can be represented as a list of states. -/
def Lineage (H : Type*) := List H

end Chronofold
