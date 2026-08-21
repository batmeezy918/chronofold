import Mathlib.Data.Nat.GCD.Basic
import Mathlib.Data.Nat.Basic

namespace Chronofold

-- Base Rho step
def rho_step (x c n : Nat) : Nat :=
  (x * x + c) % n

-- Ω operator (algebraic probe)
def omega (x n : Nat) : Nat :=
  Nat.gcd (x * x - x) n

-- Ω-augmented step
def omega_step (x c n : Nat) : Nat :=
  (rho_step x c n + omega x n) % n

-- ==========================================
-- THEOREM 1: Ω divides n (core structure)
-- ==========================================
theorem omega_divides_n (x n : Nat) :
  omega x n ∣ n := by
  unfold omega
  exact Nat.gcd_dvd_right (x * x - x) n

-- ==========================================
-- THEOREM 2: Ω is nonnegative (sanity)
-- ==========================================
theorem omega_nonneg (x n : Nat) :
  0 ≤ omega x n := by
  unfold omega
  exact Nat.zero_le _

-- ==========================================
-- THEOREM 3: Ω bounded by n
-- ==========================================
theorem omega_le_n (x n : Nat) :
  omega x n ≤ n := by
  unfold omega
  exact Nat.gcd_le_right (x * x - x) n

end Chronofold
