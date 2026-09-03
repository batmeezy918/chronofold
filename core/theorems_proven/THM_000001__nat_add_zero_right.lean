/-!
THEOREM_ID: THM_000001
TITLE: nat_add_zero_right
AUTHOR: batmeezy918
STATUS: proven

Reissued from `core/theorems_rejected/` after dropping the Mathlib import.
Lean 4 core only. No `sorry`.
-/

theorem nat_add_zero_right (n : Nat) : n + 0 = n :=
  Nat.add_zero n
