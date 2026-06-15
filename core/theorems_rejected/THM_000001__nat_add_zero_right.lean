import Mathlib
import Verify

/--
THEOREM_ID: THM_000001
TITLE: nat_add_zero_right
AUTHOR: user
STATUS: candidate
-/

theorem nat_add_zero_right (n : Nat) : n + 0 = n := by
  simp
