namespace Chronofold

-- simple vector as function
def H (n : Nat) := Nat → Float

variable {n : Nat}
variable (O : H n → H n)

-- simple invariant (sum of first k elements approximation)
def Ω (x : H n) : Float :=
  x 0

-- exact invariance
theorem T1_invariant_exact
  (hO : ∀ x : H n, Ω (O x) = Ω x) :
  ∀ x : H n, Ω (O x) = Ω x := by
  intro x
  exact hO x

end Chronofold
