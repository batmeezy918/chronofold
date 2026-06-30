import Mathlib.LinearAlgebra.Matrix.Rank
import Mathlib.Data.Matrix.Basic

variable {m n p : Type*} [Fintype m] [Fintype n] [Fintype p]
variable {K : Type*} [Field K] [DecidableEq n] [DecidableEq m] [DecidableEq p]

/-- GEMM A B := A * B -/
def GEMM (A : Matrix m n K) (B : Matrix n p K) : Matrix m p K :=
  A * B

/-- C_GEMM(r) := rank(A) ≤ r -/
def C_GEMM (A : Matrix m n K) (r : ℕ) : Prop :=
  Matrix.rank A ≤ r

set_option linter.unusedSectionVars false in
/-- rank(A*B) ≤ min(rank A)(rank B) -/
theorem rank_mul_le_min (A : Matrix m n K) (B : Matrix n p K) :
  Matrix.rank (A * B) ≤ min (Matrix.rank A) (Matrix.rank B) :=
  le_min (Matrix.rank_mul_le_left A B) (Matrix.rank_mul_le_right A B)
