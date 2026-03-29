namespace Chronofold

def H (n : Nat) := Nat → Nat

variable {n : Nat}
variable (O : H n → H n)

def Ξ (x : H n) : Int :=
  (x 2 : Int) - 2 * (x 1 : Int) + (x 0 : Int)

theorem T2_curvature
  (hO : ∀ x : H n, Ξ (O x) = Ξ x) :
  ∀ x : H n, Ξ (O x) = Ξ x := by
  intro x
  exact hO x

end Chronofold
