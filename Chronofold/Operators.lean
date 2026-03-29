import Chronofold.Base

namespace Chronofold

def step (s : State) : State :=
  Ξ (Ω (Δ s))

end Chronofold
