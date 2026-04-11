namespace Chronofold

def H (n : Nat) := Nat → Nat

variable {n : Nat}
variable (O : H n → H n)

def Ω (x : H n) : Nat :=
  x 0

theorem T1_invariant
  (hO : ∀ x : H n, Ω (O x) = Ω x) :
  ∀ x : H n, Ω (O x) = Ω x := by
  intro x
  exact hO x

end Chronofold
