import random
import datetime

name_id = datetime.datetime.now().strftime("%H%M%S")

theorem_name = f"auto_theorem_{name_id}"

template = f"""
import Chronofold.Operators

namespace Chronofold

theorem {theorem_name} (s : State) :
  0 ≤ (step s).x := by
  unfold step Δ Ω Ξ
  simp
  apply Real.log_nonneg
  have : 0 ≤ s.x ^ 2 := by exact sq_nonneg _
  linarith

end Chronofold
"""

with open("Chronofold/Auto.lean", "a") as f:
    f.write(template)

print(f"Generated: {theorem_name}")
