import Mathlib

namespace Chronofold

structure State where
  x : ℝ

def Δ (s : State) : State :=
  ⟨s.x + 1⟩

def Ω (s : State) : State :=
  ⟨s.x * s.x⟩

def Ξ (s : State) : State :=
  ⟨Real.log (1 + s.x^2)⟩

end Chronofold
