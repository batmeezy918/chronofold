/-!
# AGD-GEMM Work Model

Arithmetic work-reduction only.
Does not prove semantic equivalence, reconstruction, wall-clock speedup,
or hardware superiority.
Lean 4 core. No Mathlib. No sorry. No extra axioms.
-/

namespace Chronofold.AGDGemmWork

/-- Full GEMM arithmetic work: `2mnk` scalar operations. -/
def fullWork (m n k : Nat) : Nat :=
  2 * m * n * k

/-- Quotient GEMM arithmetic work: `2rsk` scalar operations. -/
def quotientWork (r s k : Nat) : Nat :=
  2 * r * s * k

/-- Square GEMM work on outer dimension `d` with inner dimension `k`. -/
def squareWork (d k : Nat) : Nat :=
  fullWork d d k

/-- Exact modeled work ratio when the denominator divides the numerator. -/
def workRatio (full reduced : Nat) : Nat :=
  full / reduced

/-- Full 1024³ GEMM contains 2,147,483,648 modeled operations. -/
theorem fullWork_1024 :
    fullWork 1024 1024 1024 = 2147483648 := by
  native_decide

/-- 256 × 256 × 1024 quotient GEMM contains 134,217,728 operations. -/
theorem quotientWork_256 :
    quotientWork 256 256 1024 = 134217728 := by
  native_decide

/-- The canonical quotient reduces modeled work by exactly 16×. -/
theorem canonical_ratio :
    fullWork 1024 1024 1024 = 16 * quotientWork 256 256 1024 := by
  native_decide

/-- The canonical quotient performs strictly less modeled work. -/
theorem strict_work_reduction :
    quotientWork 256 256 1024 < fullWork 1024 1024 1024 := by
  native_decide

/-- If both outer dimensions scale by `q` and `k` is held fixed, work scales by `q²`. -/
theorem square_reduction (q r k : Nat) :
    squareWork (q * r) k = q * q * squareWork r k := by
  unfold squareWork fullWork
  simp [Nat.mul_assoc, Nat.mul_left_comm, Nat.mul_comm]

/-- 1024 = 4 × 256, hence reducing both outer dimensions by 4 gives 4² = 16. -/
theorem factor_four_gives_sixteen :
    squareWork 1024 1024 = 16 * squareWork 256 1024 := by
  native_decide

/-- Canonical modeled work ratio is 16. -/
theorem canonical_workRatio :
    workRatio (fullWork 1024 1024 1024) (quotientWork 256 256 1024) = 16 := by
  native_decide

/-- Packaged arithmetic closure. No runtime claim. -/
theorem work_model_closure :
    fullWork 1024 1024 1024 = 2147483648 ∧
    quotientWork 256 256 1024 = 134217728 ∧
    fullWork 1024 1024 1024 = 16 * quotientWork 256 256 1024 ∧
    quotientWork 256 256 1024 < fullWork 1024 1024 1024 ∧
    squareWork 1024 1024 = 16 * squareWork 256 1024 ∧
    workRatio (fullWork 1024 1024 1024) (quotientWork 256 256 1024) = 16 :=
  ⟨fullWork_1024, quotientWork_256, canonical_ratio,
   strict_work_reduction, factor_four_gives_sixteen, canonical_workRatio⟩

end Chronofold.AGDGemmWork
