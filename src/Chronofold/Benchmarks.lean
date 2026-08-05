import Chronofold.AgdClosure

/-!
# Benchmarks placeholder

Runtime benchmarks live in Python (`chronofold_x`, `core/src/optimizers`).
This module exists so the import graph in `Chronofold.lean` stays valid.
-/

namespace Chronofold.AGD

/-- Marker that the AGD kernel is loaded. -/
def kernelLoaded : Bool := true

end Chronofold.AGD
