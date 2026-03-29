
import Chronofold.Operators

namespace Chronofold

theorem auto_theorem_021540 (s : State) :
  0 ≤ (step s).x := by
  unfold step Δ Ω Ξ
  simp
  apply Real.log_nonneg
  have : 0 ≤ s.x ^ 2 := by exact sq_nonneg _
  linarith

end Chronofold

import Chronofold.Operators

namespace Chronofold

-- Ω remains bounded under TθΞ dynamics

theorem thm_1774769187 (s : State) :
  0 ≤ (step s).x := by
  unfold step Δ Ω Ξ
  simp
  apply Real.log_nonneg
  have : 0 ≤ s.x ^ 2 := by exact sq_nonneg _
  linarith

end Chronofold

