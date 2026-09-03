/-!
THEOREM_ID: THM_000003
TITLE: omega_divides_n
AUTHOR: batmeezy918
STATUS: proven

Reissued from stalled PR #63 (`Chronofold/Auto.lean` on `auto`).
Lean 4 core only. No `sorry`. No Mathlib.
-/

def omega (x n : Nat) : Nat :=
  Nat.gcd (x * x - x) n

theorem omega_divides_n (x n : Nat) : omega x n ∣ n := by
  unfold omega
  exact Nat.gcd_dvd_right (x * x - x) n

theorem omega_nonneg (x n : Nat) : 0 ≤ omega x n :=
  Nat.zero_le _

theorem omega_le_n (x n : Nat) (hn : 0 < n) : omega x n ≤ n := by
  unfold omega
  exact Nat.le_of_dvd hn (Nat.gcd_dvd_right (x * x - x) n)
