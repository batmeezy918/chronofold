/-!
# Auto Ω-operator theorems (reissued from stalled PR #63 / `auto`)

Mathlib-free Lean 4 core proofs. No `sorry`.
Originally blocked because `Chronofold/Auto.lean` imported Mathlib.Data.Nat.*
and targeted the stale `auto` branch instead of `main`.
-/

namespace Chronofold.AutoOmega

/-- Base Rho step. -/
def rho_step (x c n : Nat) : Nat :=
  (x * x + c) % n

/-- Ω operator (algebraic probe). -/
def omega (x n : Nat) : Nat :=
  Nat.gcd (x * x - x) n

/-- Ω-augmented step. -/
def omega_step (x c n : Nat) : Nat :=
  (rho_step x c n + omega x n) % n

/-- THEOREM 1: Ω divides n. -/
theorem omega_divides_n (x n : Nat) :
    omega x n ∣ n := by
  unfold omega
  exact Nat.gcd_dvd_right (x * x - x) n

/-- THEOREM 2: Ω is nonnegative. -/
theorem omega_nonneg (x n : Nat) :
    0 ≤ omega x n :=
  Nat.zero_le _

/-- THEOREM 3: Ω is bounded by n when n is positive.
`n = 0` is excluded: `Nat.gcd a 0 = a`, which need not be `≤ 0`. -/
theorem omega_le_n (x n : Nat) (hn : 0 < n) :
    omega x n ≤ n := by
  unfold omega
  exact Nat.le_of_dvd hn (Nat.gcd_dvd_right (x * x - x) n)

end Chronofold.AutoOmega
