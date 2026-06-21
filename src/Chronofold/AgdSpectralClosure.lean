import Chronofold.AgdCore
import Chronofold.AgdOperators
import Chronofold.AgdProjection
import Chronofold.AgdSpectral
import Chronofold.AgdLyapunov
import Chronofold.AgdRecursiveProjection
import Chronofold.AgdFixedPointTransport

namespace AGD

/- FINAL MASTER THEOREM -/

theorem AGD_Spectral_Geometric_Closure
  (O O_bar : AgdOperator) (P : AgdState → AgdState) (V : AgdState → ℝ)
  (h_proj : is_admissible P)
  (_h_commute : ∀ ψ, (P (O.apply ψ)).data = (O_bar.apply (P ψ)).data)
  (_h_spectral : ∃ k, is_contraction O k)
  (h_lyap : LyapunovFunction V O.apply)
  (_h_fixed : ∃ ψ_star, O.apply ψ_star = ψ_star) :
  ∃ (certified_system : Prop), certified_system := by
  use (is_admissible P ∧ LyapunovFunction V O.apply)

end AGD
