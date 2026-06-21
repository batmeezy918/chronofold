namespace Chronofold
def H := Nat → Int
def Invariant (_ψ : H) : ℝ := 0
def Omega (ψ : H) : H := ψ
theorem omega_preserves_invariant (ψ : H) :
  Invariant (Omega ψ) = Invariant ψ := by
  unfold Omega
  unfold Invariant
  rfl
end Chronofold
